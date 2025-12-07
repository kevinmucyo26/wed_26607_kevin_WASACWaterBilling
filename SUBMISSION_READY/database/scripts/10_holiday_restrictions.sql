-- ============================================================================
-- Water Billing System - HOLIDAY RESTRICTION TRIGGERS
-- ============================================================================
-- Phase VII: Advanced Programming & Auditing
-- CRITICAL REQUIREMENT: Employees CANNOT INSERT/UPDATE/DELETE on weekdays or holidays
-- ============================================================================

-- ============================================================================
-- TRIGGER 1: Simple Trigger for METER_READINGS Table (INSERT)
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_restrict_meter_reading_insert
BEFORE INSERT ON meter_readings
FOR EACH ROW
DECLARE
    v_restricted BOOLEAN;
    v_reason VARCHAR2(200);
    v_audit_id NUMBER(10);
BEGIN
    -- Check if restriction applies
    v_restricted := fn_check_dml_restriction;
    
    IF v_restricted THEN
        -- Get restriction reason
        v_reason := fn_get_restriction_reason;
        
        -- Log the denied attempt
        v_audit_id := fn_log_audit(
            p_table_name => 'METER_READINGS',
            p_operation_type => 'INSERT',
            p_operation_status => 'DENIED',
            p_error_message => v_reason,
            p_additional_info => 'Attempted to insert reading_id: ' || :NEW.reading_id
        );
        
        -- Raise error to prevent insertion
        RAISE_APPLICATION_ERROR(-20999, 
            'DML Operation DENIED: ' || v_reason || 
            '. DML operations are only allowed on weekends (Saturday and Sunday) and non-holiday days.');
    ELSE
        -- Log the allowed attempt
        v_audit_id := fn_log_audit(
            p_table_name => 'METER_READINGS',
            p_operation_type => 'INSERT',
            p_operation_status => 'ALLOWED',
            p_additional_info => 'Successfully inserted reading_id: ' || :NEW.reading_id
        );
    END IF;
END;
/

-- ============================================================================
-- TRIGGER 2: Simple Trigger for METER_READINGS Table (UPDATE)
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_restrict_meter_reading_update
BEFORE UPDATE ON meter_readings
FOR EACH ROW
DECLARE
    v_restricted BOOLEAN;
    v_reason VARCHAR2(200);
    v_audit_id NUMBER(10);
BEGIN
    v_restricted := fn_check_dml_restriction;
    
    IF v_restricted THEN
        v_reason := fn_get_restriction_reason;
        
        v_audit_id := fn_log_audit(
            p_table_name => 'METER_READINGS',
            p_operation_type => 'UPDATE',
            p_operation_status => 'DENIED',
            p_record_id => :OLD.reading_id,
            p_error_message => v_reason,
            p_additional_info => 'Attempted to update reading_id: ' || :OLD.reading_id
        );
        
        RAISE_APPLICATION_ERROR(-20998, 
            'DML Operation DENIED: ' || v_reason || 
            '. DML operations are only allowed on weekends (Saturday and Sunday) and non-holiday days.');
    ELSE
        v_audit_id := fn_log_audit(
            p_table_name => 'METER_READINGS',
            p_operation_type => 'UPDATE',
            p_operation_status => 'ALLOWED',
            p_record_id => :OLD.reading_id,
            p_additional_info => 'Successfully updated reading_id: ' || :OLD.reading_id
        );
    END IF;
END;
/

-- ============================================================================
-- TRIGGER 3: Simple Trigger for METER_READINGS Table (DELETE)
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_restrict_meter_reading_delete
BEFORE DELETE ON meter_readings
FOR EACH ROW
DECLARE
    v_restricted BOOLEAN;
    v_reason VARCHAR2(200);
    v_audit_id NUMBER(10);
BEGIN
    v_restricted := fn_check_dml_restriction;
    
    IF v_restricted THEN
        v_reason := fn_get_restriction_reason;
        
        v_audit_id := fn_log_audit(
            p_table_name => 'METER_READINGS',
            p_operation_type => 'DELETE',
            p_operation_status => 'DENIED',
            p_record_id => :OLD.reading_id,
            p_error_message => v_reason,
            p_additional_info => 'Attempted to delete reading_id: ' || :OLD.reading_id
        );
        
        RAISE_APPLICATION_ERROR(-20997, 
            'DML Operation DENIED: ' || v_reason || 
            '. DML operations are only allowed on weekends (Saturday and Sunday) and non-holiday days.');
    ELSE
        v_audit_id := fn_log_audit(
            p_table_name => 'METER_READINGS',
            p_operation_type => 'DELETE',
            p_operation_status => 'ALLOWED',
            p_record_id => :OLD.reading_id,
            p_additional_info => 'Successfully deleted reading_id: ' || :OLD.reading_id
        );
    END IF;
END;
/

-- ============================================================================
-- TRIGGER 4: Compound Trigger for BILLS Table (All DML Operations)
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_restrict_bills_dml
FOR INSERT OR UPDATE OR DELETE ON bills
COMPOUND TRIGGER

    -- Variables to track restriction
    v_restricted BOOLEAN;
    v_reason VARCHAR2(200);
    v_audit_id NUMBER(10);
    v_operation_type VARCHAR2(10);
    v_record_id NUMBER(10);

    -- Before statement: Check restriction once
    BEFORE STATEMENT IS
    BEGIN
        v_restricted := fn_check_dml_restriction;
        v_reason := fn_get_restriction_reason;
    END BEFORE STATEMENT;

    -- Before each row: Apply restriction
    BEFORE EACH ROW IS
    BEGIN
        -- Determine operation type
        IF INSERTING THEN
            v_operation_type := 'INSERT';
            v_record_id := :NEW.bill_id;
        ELSIF UPDATING THEN
            v_operation_type := 'UPDATE';
            v_record_id := :OLD.bill_id;
        ELSIF DELETING THEN
            v_operation_type := 'DELETE';
            v_record_id := :OLD.bill_id;
        END IF;
        
        IF v_restricted THEN
            -- Log denied attempt
            v_audit_id := fn_log_audit(
                p_table_name => 'BILLS',
                p_operation_type => v_operation_type,
                p_operation_status => 'DENIED',
                p_record_id => v_record_id,
                p_error_message => v_reason,
                p_additional_info => 'Attempted ' || v_operation_type || ' on bill_id: ' || v_record_id
            );
            
            -- Raise error
            RAISE_APPLICATION_ERROR(-20996, 
                'DML Operation DENIED: ' || v_reason || 
                '. DML operations are only allowed on weekends (Saturday and Sunday) and non-holiday days.');
        ELSE
            -- Log allowed attempt
            v_audit_id := fn_log_audit(
                p_table_name => 'BILLS',
                p_operation_type => v_operation_type,
                p_operation_status => 'ALLOWED',
                p_record_id => v_record_id,
                p_additional_info => 'Successfully ' || v_operation_type || ' on bill_id: ' || v_record_id
            );
        END IF;
    END BEFORE EACH ROW;

    -- After each row: Additional logging if needed
    AFTER EACH ROW IS
    BEGIN
        NULL; -- Can add additional logging here if needed
    END AFTER EACH ROW;

    -- After statement: Summary logging if needed
    AFTER STATEMENT IS
    BEGIN
        NULL; -- Can add summary logging here if needed
    END AFTER STATEMENT;

END trg_restrict_bills_dml;
/

-- ============================================================================
-- TRIGGER 5: Simple Trigger for PAYMENTS Table (INSERT)
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_restrict_payment_insert
BEFORE INSERT ON payments
FOR EACH ROW
DECLARE
    v_restricted BOOLEAN;
    v_reason VARCHAR2(200);
    v_audit_id NUMBER(10);
BEGIN
    v_restricted := fn_check_dml_restriction;
    
    IF v_restricted THEN
        v_reason := fn_get_restriction_reason;
        
        v_audit_id := fn_log_audit(
            p_table_name => 'PAYMENTS',
            p_operation_type => 'INSERT',
            p_operation_status => 'DENIED',
            p_error_message => v_reason,
            p_additional_info => 'Attempted to insert payment_id: ' || :NEW.payment_id
        );
        
        RAISE_APPLICATION_ERROR(-20995, 
            'DML Operation DENIED: ' || v_reason || 
            '. DML operations are only allowed on weekends (Saturday and Sunday) and non-holiday days.');
    ELSE
        v_audit_id := fn_log_audit(
            p_table_name => 'PAYMENTS',
            p_operation_type => 'INSERT',
            p_operation_status => 'ALLOWED',
            p_additional_info => 'Successfully inserted payment_id: ' || :NEW.payment_id
        );
    END IF;
END;
/

COMMIT;

PROMPT ============================================================================
PROMPT Holiday Restriction Triggers Created Successfully!
PROMPT ============================================================================
PROMPT
PROMPT Testing Instructions:
PROMPT 1. Try INSERT on weekday - should be DENIED
PROMPT 2. Try INSERT on weekend - should be ALLOWED
PROMPT 3. Try INSERT on holiday - should be DENIED
PROMPT 4. Check audit_log table for all attempts
PROMPT ============================================================================

