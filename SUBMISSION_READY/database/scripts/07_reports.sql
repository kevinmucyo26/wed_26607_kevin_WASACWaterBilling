-- ============================================================================
-- Water Billing System - REPORT GENERATION PROCEDURES
-- ============================================================================
-- Procedures for generating real-time reports on usage, payments, and overdue accounts
-- ============================================================================

-- ============================================================================
-- PROCEDURE 1: Generate Usage Report
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_usage_report(
    p_customer_id IN NUMBER DEFAULT NULL,
    p_start_date IN DATE DEFAULT NULL,
    p_end_date IN DATE DEFAULT NULL
)
IS
    CURSOR c_usage IS
        SELECT 
            c.customer_id,
            c.full_name,
            c.meter_number,
            mr.reading_month,
            mr.previous_reading,
            mr.current_reading,
            mr.usage_m3,
            b.total_amount_due,
            b.status
        FROM meter_readings mr
        INNER JOIN customers c ON mr.customer_id = c.customer_id
        LEFT JOIN bills b ON mr.reading_id = b.reading_id
        WHERE (p_customer_id IS NULL OR c.customer_id = p_customer_id)
        AND (p_start_date IS NULL OR mr.reading_month >= p_start_date)
        AND (p_end_date IS NULL OR mr.reading_month <= p_end_date)
        ORDER BY c.full_name, mr.reading_month DESC;
    
    v_total_usage NUMBER(10,2) := 0;
    v_total_amount NUMBER(12,2) := 0;
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('WATER USAGE REPORT');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    IF p_customer_id IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Customer ID: ' || p_customer_id);
    END IF;
    IF p_start_date IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Start Date: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY'));
    END IF;
    IF p_end_date IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('End Date: ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
    END IF;
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Customer Name', 25) || RPAD('Meter', 12) || 
                        RPAD('Month', 12) || RPAD('Usage(m3)', 12) || 
                        RPAD('Amount(RWF)', 15) || 'Status');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    FOR rec IN c_usage LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(rec.full_name, 1, 24), 25) ||
            RPAD(rec.meter_number, 12) ||
            RPAD(TO_CHAR(rec.reading_month, 'MON-YYYY'), 12) ||
            RPAD(TO_CHAR(rec.usage_m3, '9999.99'), 12) ||
            RPAD(TO_CHAR(NVL(rec.total_amount_due, 0), '999,999,999.99'), 15) ||
            NVL(rec.status, 'N/A')
        );
        v_total_usage := v_total_usage + rec.usage_m3;
        v_total_amount := v_total_amount + NVL(rec.total_amount_due, 0);
        v_count := v_count + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Total Records: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('Total Usage: ' || TO_CHAR(v_total_usage, '999,999.99') || ' m3');
    DBMS_OUTPUT.PUT_LINE('Total Amount: ' || TO_CHAR(v_total_amount, '999,999,999.99') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
END;
/

-- ============================================================================
-- PROCEDURE 2: Generate Payment Report
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_payment_report(
    p_customer_id IN NUMBER DEFAULT NULL,
    p_start_date IN DATE DEFAULT NULL,
    p_end_date IN DATE DEFAULT NULL,
    p_payment_method IN VARCHAR2 DEFAULT NULL
)
IS
    CURSOR c_payments IS
        SELECT 
            c.customer_id,
            c.full_name,
            c.meter_number,
            p.payment_id,
            p.payment_date,
            p.amount_paid,
            p.payment_method,
            p.reference_number,
            p.received_by,
            b.bill_id,
            b.billing_period,
            b.total_amount_due
        FROM payments p
        INNER JOIN bills b ON p.bill_id = b.bill_id
        INNER JOIN customers c ON b.customer_id = c.customer_id
        WHERE (p_customer_id IS NULL OR c.customer_id = p_customer_id)
        AND (p_start_date IS NULL OR p.payment_date >= p_start_date)
        AND (p_end_date IS NULL OR p.payment_date <= p_end_date)
        AND (p_payment_method IS NULL OR p.payment_method = p_payment_method)
        ORDER BY p.payment_date DESC, c.full_name;
    
    v_total_paid NUMBER(12,2) := 0;
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('PAYMENT REPORT');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    IF p_customer_id IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Customer ID: ' || p_customer_id);
    END IF;
    IF p_start_date IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Start Date: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY'));
    END IF;
    IF p_end_date IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('End Date: ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
    END IF;
    IF p_payment_method IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Payment Method: ' || p_payment_method);
    END IF;
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Customer', 25) || RPAD('Payment Date', 12) || 
                        RPAD('Amount(RWF)', 15) || RPAD('Method', 15) || 
                        RPAD('Reference', 15) || 'Received By');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    FOR rec IN c_payments LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(rec.full_name, 1, 24), 25) ||
            RPAD(TO_CHAR(rec.payment_date, 'DD-MON-YYYY'), 12) ||
            RPAD(TO_CHAR(rec.amount_paid, '999,999,999.99'), 15) ||
            RPAD(rec.payment_method, 15) ||
            RPAD(NVL(rec.reference_number, 'N/A'), 15) ||
            rec.received_by
        );
        v_total_paid := v_total_paid + rec.amount_paid;
        v_count := v_count + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Total Records: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('Total Amount Paid: ' || TO_CHAR(v_total_paid, '999,999,999.99') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
END;
/

-- ============================================================================
-- PROCEDURE 3: Generate Overdue Accounts Report
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_overdue_accounts_report
IS
    CURSOR c_overdue IS
        SELECT 
            c.customer_id,
            c.full_name,
            c.phone,
            c.address,
            c.meter_number,
            b.bill_id,
            b.billing_period,
            b.due_date,
            b.total_amount_due,
            b.status,
            NVL(SUM(p.amount_paid), 0) as total_paid,
            (b.total_amount_due - NVL(SUM(p.amount_paid), 0)) as outstanding_balance,
            (SYSDATE - b.due_date) as days_overdue
        FROM bills b
        INNER JOIN customers c ON b.customer_id = c.customer_id
        LEFT JOIN payments p ON b.bill_id = p.bill_id
        WHERE b.status IN ('OVERDUE', 'PENDING')
        AND b.due_date < SYSDATE
        GROUP BY c.customer_id, c.full_name, c.phone, c.address, c.meter_number,
                 b.bill_id, b.billing_period, b.due_date, b.total_amount_due, b.status
        HAVING (b.total_amount_due - NVL(SUM(p.amount_paid), 0)) > 0
        ORDER BY days_overdue DESC, outstanding_balance DESC;
    
    v_total_overdue NUMBER(12,2) := 0;
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('OVERDUE ACCOUNTS REPORT');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Customer Name', 25) || RPAD('Phone', 15) || 
                        RPAD('Due Date', 12) || RPAD('Days Overdue', 15) || 
                        RPAD('Outstanding(RWF)', 18) || 'Status');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    FOR rec IN c_overdue LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(rec.full_name, 1, 24), 25) ||
            RPAD(rec.phone, 15) ||
            RPAD(TO_CHAR(rec.due_date, 'DD-MON-YYYY'), 12) ||
            RPAD(TO_CHAR(rec.days_overdue, '999'), 15) ||
            RPAD(TO_CHAR(rec.outstanding_balance, '999,999,999.99'), 18) ||
            rec.status
        );
        v_total_overdue := v_total_overdue + rec.outstanding_balance;
        v_count := v_count + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Total Overdue Accounts: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('Total Outstanding Amount: ' || TO_CHAR(v_total_overdue, '999,999,999.99') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
END;
/

-- ============================================================================
-- PROCEDURE 4: Generate Customer Statement
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_customer_statement(
    p_customer_id IN NUMBER
)
IS
    v_customer_name VARCHAR2(120);
    v_customer_phone VARCHAR2(15);
    v_customer_address VARCHAR2(150);
    v_customer_meter VARCHAR2(12);
    v_total_balance NUMBER(12,2);
    CURSOR c_bills IS
        SELECT 
            b.bill_id,
            b.billing_period,
            b.usage_m3,
            b.total_amount_due,
            b.due_date,
            b.status,
            NVL(SUM(p.amount_paid), 0) as total_paid,
            (b.total_amount_due - NVL(SUM(p.amount_paid), 0)) as balance
        FROM bills b
        LEFT JOIN payments p ON b.bill_id = p.bill_id
        WHERE b.customer_id = p_customer_id
        GROUP BY b.bill_id, b.billing_period, b.usage_m3, b.total_amount_due, b.due_date, b.status
        ORDER BY b.billing_period DESC;
BEGIN
    -- Get customer details
    SELECT full_name, phone, address, meter_number
    INTO v_customer_name, v_customer_phone, v_customer_address, v_customer_meter
    FROM customers
    WHERE customer_id = p_customer_id;
    
    -- Get total balance
    v_total_balance := fn_get_customer_balance(p_customer_id);
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('CUSTOMER STATEMENT');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || p_customer_id);
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_customer_name);
    DBMS_OUTPUT.PUT_LINE('Phone: ' || v_customer_phone);
    DBMS_OUTPUT.PUT_LINE('Address: ' || v_customer_address);
    DBMS_OUTPUT.PUT_LINE('Meter Number: ' || v_customer_meter);
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Billing Period', 15) || RPAD('Usage(m3)', 12) || 
                        RPAD('Amount Due(RWF)', 18) || RPAD('Paid(RWF)', 15) || 
                        RPAD('Balance(RWF)', 15) || RPAD('Due Date', 12) || 'Status');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    FOR rec IN c_bills LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(TO_CHAR(rec.billing_period, 'MON-YYYY'), 15) ||
            RPAD(TO_CHAR(rec.usage_m3, '9999.99'), 12) ||
            RPAD(TO_CHAR(rec.total_amount_due, '999,999,999.99'), 18) ||
            RPAD(TO_CHAR(rec.total_paid, '999,999,999.99'), 15) ||
            RPAD(TO_CHAR(rec.balance, '999,999,999.99'), 15) ||
            RPAD(TO_CHAR(rec.due_date, 'DD-MON-YYYY'), 12) ||
            rec.status
        );
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL OUTSTANDING BALANCE: ' || TO_CHAR(v_total_balance, '999,999,999.99') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20050, 'Customer not found');
END;
/

-- ============================================================================
-- PROCEDURE 5: Generate Monthly Summary Report
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_monthly_summary(
    p_month IN DATE
)
IS
    v_total_customers NUMBER := 0;
    v_total_readings NUMBER := 0;
    v_total_usage NUMBER(10,2) := 0;
    v_total_billed NUMBER(12,2) := 0;
    v_total_paid NUMBER(12,2) := 0;
    v_pending_amount NUMBER(12,2) := 0;
BEGIN
    -- Count customers
    SELECT COUNT(DISTINCT customer_id)
    INTO v_total_customers
    FROM customers
    WHERE status = 'ACTIVE';
    
    -- Count readings for the month
    SELECT COUNT(*)
    INTO v_total_readings
    FROM meter_readings
    WHERE TRUNC(reading_month, 'MM') = TRUNC(p_month, 'MM');
    
    -- Total usage
    SELECT NVL(SUM(usage_m3), 0)
    INTO v_total_usage
    FROM meter_readings
    WHERE TRUNC(reading_month, 'MM') = TRUNC(p_month, 'MM');
    
    -- Total billed
    SELECT NVL(SUM(total_amount_due), 0)
    INTO v_total_billed
    FROM bills
    WHERE TRUNC(billing_period, 'MM') = TRUNC(p_month, 'MM');
    
    -- Total paid for the month's bills
    SELECT NVL(SUM(p.amount_paid), 0)
    INTO v_total_paid
    FROM payments p
    INNER JOIN bills b ON p.bill_id = b.bill_id
    WHERE TRUNC(b.billing_period, 'MM') = TRUNC(p_month, 'MM');
    
    v_pending_amount := v_total_billed - v_total_paid;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('MONTHLY SUMMARY REPORT');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Report Period: ' || TO_CHAR(p_month, 'MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Total Active Customers: ' || v_total_customers);
    DBMS_OUTPUT.PUT_LINE('Total Meter Readings: ' || v_total_readings);
    DBMS_OUTPUT.PUT_LINE('Total Water Usage: ' || TO_CHAR(v_total_usage, '999,999.99') || ' m3');
    DBMS_OUTPUT.PUT_LINE('Total Amount Billed: ' || TO_CHAR(v_total_billed, '999,999,999.99') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('Total Amount Paid: ' || TO_CHAR(v_total_paid, '999,999,999.99') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('Pending Amount: ' || TO_CHAR(v_pending_amount, '999,999,999.99') || ' RWF');
    DBMS_OUTPUT.PUT_LINE('Collection Rate: ' || 
        CASE 
            WHEN v_total_billed > 0 THEN TO_CHAR((v_total_paid / v_total_billed * 100), '999.99') || '%'
            ELSE '0.00%'
        END);
    DBMS_OUTPUT.PUT_LINE('============================================================================');
END;
/

COMMIT;

