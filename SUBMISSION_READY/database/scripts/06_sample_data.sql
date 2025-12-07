-- ============================================================================
-- Water Billing System - SAMPLE DATA
-- ============================================================================
-- This script populates the database with realistic sample data for testing
-- ============================================================================

-- Clear existing data (optional - uncomment if needed)
-- DELETE FROM payments;
-- DELETE FROM bills;
-- DELETE FROM meter_readings;
-- DELETE FROM tariff_rates;
-- DELETE FROM customers;

-- ============================================================================
-- SETUP TARIFF RATES (5-Tier Structure)
-- ============================================================================
-- Tier 1: 0-10 m3 at 500 RWF/m3
-- Tier 2: 11-20 m3 at 750 RWF/m3
-- Tier 3: 21-30 m3 at 1000 RWF/m3
-- Tier 4: 31-50 m3 at 1500 RWF/m3
-- Tier 5: 51+ m3 at 2000 RWF/m3

INSERT INTO tariff_rates (tariff_id, tier_level, min_usage_m3, max_usage_m3, rate_per_m3, effective_from, is_active)
VALUES (seq_tariff_id.NEXTVAL, 1, 0, 10, 500, TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'Y');

INSERT INTO tariff_rates (tariff_id, tier_level, min_usage_m3, max_usage_m3, rate_per_m3, effective_from, is_active)
VALUES (seq_tariff_id.NEXTVAL, 2, 11, 20, 750, TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'Y');

INSERT INTO tariff_rates (tariff_id, tier_level, min_usage_m3, max_usage_m3, rate_per_m3, effective_from, is_active)
VALUES (seq_tariff_id.NEXTVAL, 3, 21, 30, 1000, TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'Y');

INSERT INTO tariff_rates (tariff_id, tier_level, min_usage_m3, max_usage_m3, rate_per_m3, effective_from, is_active)
VALUES (seq_tariff_id.NEXTVAL, 4, 31, 50, 1500, TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'Y');

INSERT INTO tariff_rates (tariff_id, tier_level, min_usage_m3, max_usage_m3, rate_per_m3, effective_from, is_active)
VALUES (seq_tariff_id.NEXTVAL, 5, 51, NULL, 2000, TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'Y');

-- ============================================================================
-- ADD SAMPLE CUSTOMERS
-- ============================================================================
DECLARE
    v_cust_id NUMBER;
BEGIN
    -- Customer 1: Jean Baptiste
    proc_add_customer(
        p_full_name => 'Jean Baptiste Uwimana',
        p_phone => '0788123456',
        p_address => 'KG 123 St, Kigali',
        p_meter_number => 'MT001234',
        p_status => 'ACTIVE',
        p_customer_id => v_cust_id
    );
    
    -- Customer 2: Marie Claire
    proc_add_customer(
        p_full_name => 'Marie Claire Mukamana',
        p_phone => '0788234567',
        p_address => 'KG 456 St, Kigali',
        p_meter_number => 'MT002345',
        p_status => 'ACTIVE',
        p_customer_id => v_cust_id
    );
    
    -- Customer 3: Paul Nkurunziza
    proc_add_customer(
        p_full_name => 'Paul Nkurunziza',
        p_phone => '0788345678',
        p_address => 'KG 789 St, Kigali',
        p_meter_number => 'MT003456',
        p_status => 'ACTIVE',
        p_customer_id => v_cust_id
    );
    
    -- Customer 4: Grace Uwera
    proc_add_customer(
        p_full_name => 'Grace Uwera',
        p_phone => '0788456789',
        p_address => 'KG 321 St, Kigali',
        p_meter_number => 'MT004567',
        p_status => 'ACTIVE',
        p_customer_id => v_cust_id
    );
    
    -- Customer 5: David Nsengimana
    proc_add_customer(
        p_full_name => 'David Nsengimana',
        p_phone => '0788567890',
        p_address => 'KG 654 St, Kigali',
        p_meter_number => 'MT005678',
        p_status => 'ACTIVE',
        p_customer_id => v_cust_id
    );
    
    DBMS_OUTPUT.PUT_LINE('Sample customers added successfully');
END;
/

-- ============================================================================
-- ADD SAMPLE METER READINGS (for past 3 months)
-- ============================================================================
DECLARE
    v_reading_id NUMBER;
    v_cust1_id NUMBER;
    v_cust2_id NUMBER;
    v_cust3_id NUMBER;
    v_cust4_id NUMBER;
    v_cust5_id NUMBER;
BEGIN
    -- Get customer IDs
    SELECT customer_id INTO v_cust1_id FROM customers WHERE meter_number = 'MT001234';
    SELECT customer_id INTO v_cust2_id FROM customers WHERE meter_number = 'MT002345';
    SELECT customer_id INTO v_cust3_id FROM customers WHERE meter_number = 'MT003456';
    SELECT customer_id INTO v_cust4_id FROM customers WHERE meter_number = 'MT004567';
    SELECT customer_id INTO v_cust5_id FROM customers WHERE meter_number = 'MT005678';
    
    -- Customer 1: January 2024
    proc_record_meter_reading(
        p_customer_id => v_cust1_id,
        p_reading_month => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_previous_reading => 0,
        p_current_reading => 8,
        p_notes => 'Initial reading',
        p_reading_id => v_reading_id
    );
    
    -- Customer 1: February 2024
    proc_record_meter_reading(
        p_customer_id => v_cust1_id,
        p_reading_month => TO_DATE('2024-02-15', 'YYYY-MM-DD'),
        p_previous_reading => 8,
        p_current_reading => 18,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 1: March 2024
    proc_record_meter_reading(
        p_customer_id => v_cust1_id,
        p_reading_month => TO_DATE('2024-03-15', 'YYYY-MM-DD'),
        p_previous_reading => 18,
        p_current_reading => 25,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 2: January 2024
    proc_record_meter_reading(
        p_customer_id => v_cust2_id,
        p_reading_month => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_previous_reading => 0,
        p_current_reading => 12,
        p_notes => 'Initial reading',
        p_reading_id => v_reading_id
    );
    
    -- Customer 2: February 2024
    proc_record_meter_reading(
        p_customer_id => v_cust2_id,
        p_reading_month => TO_DATE('2024-02-15', 'YYYY-MM-DD'),
        p_previous_reading => 12,
        p_current_reading => 28,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 2: March 2024
    proc_record_meter_reading(
        p_customer_id => v_cust2_id,
        p_reading_month => TO_DATE('2024-03-15', 'YYYY-MM-DD'),
        p_previous_reading => 28,
        p_current_reading => 45,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 3: January 2024
    proc_record_meter_reading(
        p_customer_id => v_cust3_id,
        p_reading_month => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_previous_reading => 0,
        p_current_reading => 5,
        p_notes => 'Initial reading',
        p_reading_id => v_reading_id
    );
    
    -- Customer 3: February 2024
    proc_record_meter_reading(
        p_customer_id => v_cust3_id,
        p_reading_month => TO_DATE('2024-02-15', 'YYYY-MM-DD'),
        p_previous_reading => 5,
        p_current_reading => 9,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 3: March 2024
    proc_record_meter_reading(
        p_customer_id => v_cust3_id,
        p_reading_month => TO_DATE('2024-03-15', 'YYYY-MM-DD'),
        p_previous_reading => 9,
        p_current_reading => 15,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 4: January 2024
    proc_record_meter_reading(
        p_customer_id => v_cust4_id,
        p_reading_month => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_previous_reading => 0,
        p_current_reading => 35,
        p_notes => 'Initial reading - High usage',
        p_reading_id => v_reading_id
    );
    
    -- Customer 4: February 2024
    proc_record_meter_reading(
        p_customer_id => v_cust4_id,
        p_reading_month => TO_DATE('2024-02-15', 'YYYY-MM-DD'),
        p_previous_reading => 35,
        p_current_reading => 72,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 4: March 2024
    proc_record_meter_reading(
        p_customer_id => v_cust4_id,
        p_reading_month => TO_DATE('2024-03-15', 'YYYY-MM-DD'),
        p_previous_reading => 72,
        p_current_reading => 110,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 5: January 2024
    proc_record_meter_reading(
        p_customer_id => v_cust5_id,
        p_reading_month => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_previous_reading => 0,
        p_current_reading => 22,
        p_notes => 'Initial reading',
        p_reading_id => v_reading_id
    );
    
    -- Customer 5: February 2024
    proc_record_meter_reading(
        p_customer_id => v_cust5_id,
        p_reading_month => TO_DATE('2024-02-15', 'YYYY-MM-DD'),
        p_previous_reading => 22,
        p_current_reading => 40,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    -- Customer 5: March 2024
    proc_record_meter_reading(
        p_customer_id => v_cust5_id,
        p_reading_month => TO_DATE('2024-03-15', 'YYYY-MM-DD'),
        p_previous_reading => 40,
        p_current_reading => 55,
        p_notes => NULL,
        p_reading_id => v_reading_id
    );
    
    DBMS_OUTPUT.PUT_LINE('Sample meter readings added successfully');
    DBMS_OUTPUT.PUT_LINE('Note: Bills are automatically generated by triggers');
END;
/

-- ============================================================================
-- ADD SAMPLE PAYMENTS
-- ============================================================================
DECLARE
    v_payment_id NUMBER;
    v_bill1_id NUMBER;
    v_bill2_id NUMBER;
    v_bill3_id NUMBER;
    v_bill4_id NUMBER;
BEGIN
    -- Get some bill IDs (January bills)
    SELECT bill_id INTO v_bill1_id FROM bills b
    INNER JOIN customers c ON b.customer_id = c.customer_id
    WHERE c.meter_number = 'MT001234' AND b.billing_period = TO_DATE('2024-01-15', 'YYYY-MM-DD');
    
    SELECT bill_id INTO v_bill2_id FROM bills b
    INNER JOIN customers c ON b.customer_id = c.customer_id
    WHERE c.meter_number = 'MT002345' AND b.billing_period = TO_DATE('2024-01-15', 'YYYY-MM-DD');
    
    SELECT bill_id INTO v_bill3_id FROM bills b
    INNER JOIN customers c ON b.customer_id = c.customer_id
    WHERE c.meter_number = 'MT003456' AND b.billing_period = TO_DATE('2024-01-15', 'YYYY-MM-DD');
    
    SELECT bill_id INTO v_bill4_id FROM bills b
    INNER JOIN customers c ON b.customer_id = c.customer_id
    WHERE c.meter_number = 'MT001234' AND b.billing_period = TO_DATE('2024-02-15', 'YYYY-MM-DD');
    
    -- Payment 1: Full payment for Customer 1 January bill
    proc_process_payment(
        p_bill_id => v_bill1_id,
        p_amount_paid => (SELECT total_amount_due FROM bills WHERE bill_id = v_bill1_id),
        p_payment_method => 'CASH',
        p_reference_number => 'PAY001',
        p_received_by => 'Agent John',
        p_payment_id => v_payment_id
    );
    
    -- Payment 2: Full payment for Customer 2 January bill
    proc_process_payment(
        p_bill_id => v_bill2_id,
        p_amount_paid => (SELECT total_amount_due FROM bills WHERE bill_id = v_bill2_id),
        p_payment_method => 'MOMO PAY',
        p_reference_number => 'MOMO001',
        p_received_by => 'Agent John',
        p_payment_id => v_payment_id
    );
    
    -- Payment 3: Full payment for Customer 3 January bill
    proc_process_payment(
        p_bill_id => v_bill3_id,
        p_amount_paid => (SELECT total_amount_due FROM bills WHERE bill_id = v_bill3_id),
        p_payment_method => 'BANK TRANSFER',
        p_reference_number => 'BT001',
        p_received_by => 'Agent Mary',
        p_payment_id => v_payment_id
    );
    
    -- Payment 4: Partial payment for Customer 1 February bill
    proc_process_payment(
        p_bill_id => v_bill4_id,
        p_amount_paid => 5000,
        p_payment_method => 'CASH',
        p_reference_number => 'PAY002',
        p_received_by => 'Agent John',
        p_payment_id => v_payment_id
    );
    
    DBMS_OUTPUT.PUT_LINE('Sample payments added successfully');
END;
/

COMMIT;

DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Sample data loaded successfully!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Summary:');
DBMS_OUTPUT.PUT_LINE('- 5 Tariff rates (5 tiers)');
DBMS_OUTPUT.PUT_LINE('- 5 Customers');
DBMS_OUTPUT.PUT_LINE('- 15 Meter readings (3 months x 5 customers)');
DBMS_OUTPUT.PUT_LINE('- 15 Bills (auto-generated)');
DBMS_OUTPUT.PUT_LINE('- 4 Payments');
DBMS_OUTPUT.PUT_LINE('========================================');

