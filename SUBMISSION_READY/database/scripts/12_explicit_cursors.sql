-- ============================================================================
-- Water Billing System - EXPLICIT CURSORS
-- ============================================================================
-- Phase VI: Database Interaction & Transactions
-- Demonstrates explicit cursors for multi-row processing
-- ============================================================================

-- ============================================================================
-- PROCEDURE 1: Process All Overdue Bills Using Explicit Cursor
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_process_overdue_bills_cursor
IS
    -- Explicit cursor declaration
    CURSOR c_overdue_bills IS
        SELECT 
            b.bill_id,
            c.customer_id,
            c.full_name,
            b.total_amount_due,
            b.due_date,
            (SYSDATE - b.due_date) as days_overdue
        FROM bills b
        INNER JOIN customers c ON b.customer_id = c.customer_id
        WHERE b.status IN ('PENDING', 'OVERDUE')
        AND b.due_date < SYSDATE
        ORDER BY b.due_date;
    
    -- Variables for cursor data
    v_bill_id NUMBER(10);
    v_customer_id NUMBER(10);
    v_full_name VARCHAR2(120);
    v_total_amount_due NUMBER(12,2);
    v_due_date DATE;
    v_days_overdue NUMBER;
    v_processed_count NUMBER := 0;
    v_total_overdue NUMBER(12,2) := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Processing Overdue Bills Using Explicit Cursor');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    -- Open cursor
    OPEN c_overdue_bills;
    
    -- Loop through cursor
    LOOP
        -- Fetch next row
        FETCH c_overdue_bills INTO 
            v_bill_id, v_customer_id, v_full_name, 
            v_total_amount_due, v_due_date, v_days_overdue;
        
        -- Exit when no more rows
        EXIT WHEN c_overdue_bills%NOTFOUND;
        
        -- Process each overdue bill
        v_processed_count := v_processed_count + 1;
        v_total_overdue := v_total_overdue + v_total_amount_due;
        
        DBMS_OUTPUT.PUT_LINE(
            'Bill ID: ' || v_bill_id || 
            ' | Customer: ' || v_full_name ||
            ' | Amount: ' || TO_CHAR(v_total_amount_due, '999,999,999.99') ||
            ' | Days Overdue: ' || v_days_overdue
        );
        
        -- Update bill status to OVERDUE if not already
        UPDATE bills
        SET status = 'OVERDUE'
        WHERE bill_id = v_bill_id
        AND status = 'PENDING';
        
    END LOOP;
    
    -- Close cursor
    CLOSE c_overdue_bills;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Total Bills Processed: ' || v_processed_count);
    DBMS_OUTPUT.PUT_LINE('Total Overdue Amount: ' || TO_CHAR(v_total_overdue, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_overdue_bills%ISOPEN THEN
            CLOSE c_overdue_bills;
        END IF;
        RAISE;
END;
/

-- ============================================================================
-- PROCEDURE 2: Generate Customer Statements Using Cursor with Parameters
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_generate_customer_statements_cursor(
    p_customer_id IN NUMBER DEFAULT NULL
)
IS
    -- Parameterized cursor
    CURSOR c_customer_bills(p_cust_id NUMBER) IS
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
        WHERE b.customer_id = p_cust_id
        GROUP BY b.bill_id, b.billing_period, b.usage_m3, 
                 b.total_amount_due, b.due_date, b.status
        ORDER BY b.billing_period DESC;
    
    -- Variables
    v_customer_name VARCHAR2(120);
    v_customer_phone VARCHAR2(15);
    v_bill_id NUMBER(10);
    v_billing_period DATE;
    v_usage_m3 NUMBER(10,2);
    v_total_amount_due NUMBER(12,2);
    v_due_date DATE;
    v_status VARCHAR2(20);
    v_total_paid NUMBER(12,2);
    v_balance NUMBER(12,2);
    v_total_balance NUMBER(12,2) := 0;
BEGIN
    -- Get customer info
    SELECT full_name, phone
    INTO v_customer_name, v_customer_phone
    FROM customers
    WHERE customer_id = p_customer_id;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Customer Statement');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Customer: ' || v_customer_name);
    DBMS_OUTPUT.PUT_LINE('Phone: ' || v_customer_phone);
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    -- Open cursor with parameter
    OPEN c_customer_bills(p_customer_id);
    
    LOOP
        FETCH c_customer_bills INTO 
            v_bill_id, v_billing_period, v_usage_m3, 
            v_total_amount_due, v_due_date, v_status, 
            v_total_paid, v_balance;
        
        EXIT WHEN c_customer_bills%NOTFOUND;
        
        v_total_balance := v_total_balance + v_balance;
        
        DBMS_OUTPUT.PUT_LINE(
            'Period: ' || TO_CHAR(v_billing_period, 'MON-YYYY') ||
            ' | Usage: ' || TO_CHAR(v_usage_m3, '999.99') || ' m3' ||
            ' | Amount: ' || TO_CHAR(v_total_amount_due, '999,999.99') ||
            ' | Paid: ' || TO_CHAR(v_total_paid, '999,999.99') ||
            ' | Balance: ' || TO_CHAR(v_balance, '999,999.99') ||
            ' | Status: ' || v_status
        );
    END LOOP;
    
    CLOSE c_customer_bills;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Total Outstanding Balance: ' || TO_CHAR(v_total_balance, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20050, 'Customer not found');
    WHEN OTHERS THEN
        IF c_customer_bills%ISOPEN THEN
            CLOSE c_customer_bills;
        END IF;
        RAISE;
END;
/

-- ============================================================================
-- PROCEDURE 3: Bulk Operations Using Cursor FOR Loop
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_bulk_update_bill_status
IS
    -- Cursor for bills needing status update
    CURSOR c_bills_to_update IS
        SELECT 
            b.bill_id,
            b.due_date,
            b.status,
            NVL(SUM(p.amount_paid), 0) as total_paid,
            b.total_amount_due
        FROM bills b
        LEFT JOIN payments p ON b.bill_id = p.bill_id
        WHERE b.status IN ('PENDING', 'PARTIAL')
        GROUP BY b.bill_id, b.due_date, b.status, b.total_amount_due
        HAVING (b.total_amount_due - NVL(SUM(p.amount_paid), 0)) > 0;
    
    v_updated_count NUMBER := 0;
    v_new_status VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updating bill statuses using bulk operations...');
    
    -- Cursor FOR loop (implicit open, fetch, close)
    FOR bill_rec IN c_bills_to_update LOOP
        -- Determine new status
        IF bill_rec.total_paid >= bill_rec.total_amount_due THEN
            v_new_status := 'PAID';
        ELSIF bill_rec.total_paid > 0 THEN
            v_new_status := 'PARTIAL';
        ELSIF bill_rec.due_date < SYSDATE THEN
            v_new_status := 'OVERDUE';
        ELSE
            v_new_status := 'PENDING';
        END IF;
        
        -- Update if status changed
        IF bill_rec.status != v_new_status THEN
            UPDATE bills
            SET status = v_new_status
            WHERE bill_id = bill_rec.bill_id;
            
            v_updated_count := v_updated_count + 1;
        END IF;
    END LOOP;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Bills updated: ' || v_updated_count);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- ============================================================================
-- PROCEDURE 4: Cursor with Exception Handling
-- ============================================================================
CREATE OR REPLACE PROCEDURE proc_calculate_monthly_revenue_cursor
IS
    CURSOR c_monthly_payments IS
        SELECT 
            TO_CHAR(p.payment_date, 'MON-YYYY') as payment_month,
            SUM(p.amount_paid) as monthly_revenue,
            COUNT(p.payment_id) as payment_count
        FROM payments p
        GROUP BY TO_CHAR(p.payment_date, 'MON-YYYY')
        ORDER BY TO_CHAR(p.payment_date, 'MON-YYYY');
    
    v_payment_month VARCHAR2(20);
    v_monthly_revenue NUMBER(12,2);
    v_payment_count NUMBER;
    v_total_revenue NUMBER(12,2) := 0;
    v_total_payments NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Monthly Revenue Report (Using Explicit Cursor)');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    OPEN c_monthly_payments;
    
    BEGIN
        LOOP
            FETCH c_monthly_payments INTO 
                v_payment_month, v_monthly_revenue, v_payment_count;
            
            EXIT WHEN c_monthly_payments%NOTFOUND;
            
            v_total_revenue := v_total_revenue + v_monthly_revenue;
            v_total_payments := v_total_payments + v_payment_count;
            
            DBMS_OUTPUT.PUT_LINE(
                'Month: ' || v_payment_month ||
                ' | Revenue: ' || TO_CHAR(v_monthly_revenue, '999,999,999.99') ||
                ' | Payments: ' || v_payment_count
            );
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error processing row: ' || SQLERRM);
            -- Continue processing
    END;
    
    CLOSE c_monthly_payments;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Total Revenue: ' || TO_CHAR(v_total_revenue, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Total Payments: ' || v_total_payments);
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_monthly_payments%ISOPEN THEN
            CLOSE c_monthly_payments;
        END IF;
        RAISE;
END;
/

COMMIT;

PROMPT ============================================================================
PROMPT Explicit Cursors Created Successfully!
PROMPT ============================================================================
PROMPT Procedures created:
PROMPT - proc_process_overdue_bills_cursor (explicit cursor with OPEN/FETCH/CLOSE)
PROMPT - proc_generate_customer_statements_cursor (parameterized cursor)
PROMPT - proc_bulk_update_bill_status (cursor FOR loop)
PROMPT - proc_calculate_monthly_revenue_cursor (cursor with exception handling)
PROMPT ============================================================================

