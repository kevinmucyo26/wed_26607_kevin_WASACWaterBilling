-- ============================================================================
-- Data Validation Queries
-- ============================================================================

-- Validation 1: Verify all constraints exist
SELECT constraint_name, table_name, constraint_type, status
FROM user_constraints
WHERE table_name IN ('CUSTOMERS', 'METER_READINGS', 'BILLS', 'PAYMENTS')
ORDER BY table_name, constraint_type;

-- Validation 2: Verify foreign key relationships (should return 0 rows)
SELECT 'Meter readings without customer' as check_type,
       COUNT(*) as violations
FROM meter_readings mr
WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = mr.customer_id);

-- Validation 3: Verify bills without readings (should return 0 rows)
SELECT 'Bills without readings' as check_type,
       COUNT(*) as violations
FROM bills b
WHERE NOT EXISTS (SELECT 1 FROM meter_readings mr WHERE mr.reading_id = b.reading_id);

-- Validation 4: Verify payments without bills (should return 0 rows)
SELECT 'Payments without bills' as check_type,
       COUNT(*) as violations
FROM payments p
WHERE NOT EXISTS (SELECT 1 FROM bills b WHERE b.bill_id = p.bill_id);

-- Validation 5: Verify data integrity - negative amounts (should return 0 rows)
SELECT 'Negative amounts in bills' as check_type,
       COUNT(*) as violations
FROM bills
WHERE total_amount_due < 0;

-- Validation 6: Verify usage_m3 is calculated correctly
SELECT 'Incorrect usage calculation' as check_type,
       COUNT(*) as violations
FROM meter_readings
WHERE usage_m3 != (current_reading - previous_reading)
AND usage_m3 IS NOT NULL;

-- Validation 7: Sample data display (5-10 rows each)
SELECT '=== CUSTOMERS SAMPLE (10 rows) ===' as info FROM DUAL;
SELECT * FROM customers WHERE ROWNUM <= 10;

SELECT '=== METER_READINGS SAMPLE (10 rows) ===' as info FROM DUAL;
SELECT * FROM meter_readings WHERE ROWNUM <= 10;

SELECT '=== BILLS SAMPLE (10 rows) ===' as info FROM DUAL;
SELECT * FROM bills WHERE ROWNUM <= 10;

SELECT '=== PAYMENTS SAMPLE (10 rows) ===' as info FROM DUAL;
SELECT * FROM payments WHERE ROWNUM <= 10;