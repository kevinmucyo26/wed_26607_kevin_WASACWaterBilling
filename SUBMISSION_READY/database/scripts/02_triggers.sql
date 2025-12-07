-- ============================================================================
-- Water Billing System - TRIGGERS
-- ============================================================================
-- Triggers automate bill generation, payment status updates, and usage calculations
-- ============================================================================

-- ============================================================================
-- TRIGGER 1: Auto-calculate usage_m3 when meter reading is inserted/updated
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_calculate_usage
BEFORE INSERT OR UPDATE ON meter_readings
FOR EACH ROW
BEGIN
    -- Automatically calculate usage from previous and current readings
    :NEW.usage_m3 := :NEW.current_reading - :NEW.previous_reading;
    
    -- Validation: Ensure usage is non-negative
    IF :NEW.usage_m3 < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Current reading must be greater than or equal to previous reading');
    END IF;
END;
/

-- ============================================================================
-- TRIGGER 2: Auto-generate bill when meter reading is inserted
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_auto_generate_bill
AFTER INSERT ON meter_readings
FOR EACH ROW
DECLARE
    v_bill_id NUMBER(10);
    v_due_date DATE;
BEGIN
    -- Set due date to 30 days from reading month
    v_due_date := ADD_MONTHS(:NEW.reading_month, 1) - 1;
    
    -- Call procedure to generate bill with tiered tariffs
    pkg_billing.generate_bill_from_reading(
        p_reading_id => :NEW.reading_id,
        p_due_date => v_due_date
    );
END;
/

-- ============================================================================
-- TRIGGER 3: Update bill status when payment is inserted
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_update_bill_status
AFTER INSERT OR UPDATE OR DELETE ON payments
FOR EACH ROW
DECLARE
    v_total_paid NUMBER(12,2);
    v_amount_due NUMBER(12,2);
    v_new_status VARCHAR2(20);
BEGIN
    IF INSERTING OR UPDATING THEN
        -- Calculate total payments for the bill
        SELECT NVL(SUM(amount_paid), 0)
        INTO v_total_paid
        FROM payments
        WHERE bill_id = :NEW.bill_id;
        
        -- Get bill amount due
        SELECT total_amount_due
        INTO v_amount_due
        FROM bills
        WHERE bill_id = :NEW.bill_id;
        
        -- Determine new status
        IF v_total_paid >= v_amount_due THEN
            v_new_status := 'PAID';
        ELSIF v_total_paid > 0 THEN
            v_new_status := 'PARTIAL';
        ELSE
            v_new_status := 'PENDING';
        END IF;
        
        -- Update bill status
        UPDATE bills
        SET status = v_new_status
        WHERE bill_id = :NEW.bill_id;
        
    ELSIF DELETING THEN
        -- Recalculate when payment is deleted
        SELECT NVL(SUM(amount_paid), 0)
        INTO v_total_paid
        FROM payments
        WHERE bill_id = :OLD.bill_id;
        
        SELECT total_amount_due
        INTO v_amount_due
        FROM bills
        WHERE bill_id = :OLD.bill_id;
        
        IF v_total_paid >= v_amount_due THEN
            v_new_status := 'PAID';
        ELSIF v_total_paid > 0 THEN
            v_new_status := 'PARTIAL';
        ELSE
            v_new_status := 'PENDING';
        END IF;
        
        UPDATE bills
        SET status = v_new_status
        WHERE bill_id = :OLD.bill_id;
    END IF;
END;
/

-- ============================================================================
-- TRIGGER 4: Auto-update overdue bills status
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_check_overdue_bills
BEFORE UPDATE OF status ON bills
FOR EACH ROW
BEGIN
    -- If bill is not paid and due date has passed, mark as overdue
    IF :NEW.status = 'PENDING' AND :NEW.due_date < SYSDATE THEN
        :NEW.status := 'OVERDUE';
    END IF;
END;
/

-- ============================================================================
-- TRIGGER 5: Validate customer status before meter reading
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_validate_customer_status
BEFORE INSERT ON meter_readings
FOR EACH ROW
DECLARE
    v_customer_status VARCHAR2(20);
BEGIN
    -- Check if customer is active
    SELECT status INTO v_customer_status
    FROM customers
    WHERE customer_id = :NEW.customer_id;
    
    IF v_customer_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Cannot create meter reading for ' || v_customer_status || ' customer');
    END IF;
END;
/

-- ============================================================================
-- TRIGGER 6: Prevent duplicate readings for same month
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_prevent_duplicate_reading
BEFORE INSERT ON meter_readings
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Check if reading already exists for this customer and month
    SELECT COUNT(*)
    INTO v_count
    FROM meter_readings
    WHERE customer_id = :NEW.customer_id
    AND TRUNC(reading_month, 'MM') = TRUNC(:NEW.reading_month, 'MM');
    
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'Meter reading already exists for this customer in the specified month');
    END IF;
END;
/

COMMIT;
