-- ============================================================================
-- Analytics Queries for Business Intelligence
-- ============================================================================
-- These queries support dashboard creation and KPI calculations
-- ============================================================================

-- ============================================================================
-- QUERY 1: Total Monthly Revenue (KPI)
-- ============================================================================
SELECT 
    TO_CHAR(p.payment_date, 'MON-YYYY') as month,
    SUM(p.amount_paid) as total_revenue,
    COUNT(p.payment_id) as payment_count,
    AVG(p.amount_paid) as avg_payment_amount
FROM payments p
GROUP BY TO_CHAR(p.payment_date, 'MON-YYYY')
ORDER BY TO_DATE(TO_CHAR(p.payment_date, 'MON-YYYY'), 'MON-YYYY');

-- ============================================================================
-- QUERY 2: Collection Rate (KPI)
-- ============================================================================
SELECT 
    TO_CHAR(b.issued_at, 'MON-YYYY') as month,
    COUNT(b.bill_id) as total_bills,
    COUNT(CASE WHEN b.status = 'PAID' THEN 1 END) as paid_bills,
    COUNT(CASE WHEN b.status = 'PAID' AND p.payment_date <= b.due_date THEN 1 END) as on_time_payments,
    ROUND(
        COUNT(CASE WHEN b.status = 'PAID' AND p.payment_date <= b.due_date THEN 1 END) * 100.0 / 
        COUNT(b.bill_id), 
        2
    ) as collection_rate_percent
FROM bills b
LEFT JOIN payments p ON b.bill_id = p.bill_id
GROUP BY TO_CHAR(b.issued_at, 'MON-YYYY')
ORDER BY TO_DATE(TO_CHAR(b.issued_at, 'MON-YYYY'), 'MON-YYYY');

-- ============================================================================
-- QUERY 3: Outstanding Balance (KPI)
-- ============================================================================
SELECT 
    SUM(b.total_amount_due - NVL(paid.total_paid, 0)) as total_outstanding,
    COUNT(b.bill_id) as outstanding_bills,
    AVG(b.total_amount_due - NVL(paid.total_paid, 0)) as avg_outstanding_per_bill
FROM bills b
LEFT JOIN (
    SELECT bill_id, SUM(amount_paid) as total_paid
    FROM payments
    GROUP BY bill_id
) paid ON b.bill_id = paid.bill_id
WHERE b.status IN ('PENDING', 'OVERDUE', 'PARTIAL')
AND (b.total_amount_due - NVL(paid.total_paid, 0)) > 0;

-- ============================================================================
-- QUERY 4: Overdue Amount (KPI)
-- ============================================================================
SELECT 
    SUM(b.total_amount_due - NVL(paid.total_paid, 0)) as total_overdue,
    COUNT(b.bill_id) as overdue_bills,
    AVG(SYSDATE - b.due_date) as avg_days_overdue
FROM bills b
LEFT JOIN (
    SELECT bill_id, SUM(amount_paid) as total_paid
    FROM payments
    GROUP BY bill_id
) paid ON b.bill_id = paid.bill_id
WHERE b.due_date < SYSDATE
AND b.status != 'PAID'
AND (b.total_amount_due - NVL(paid.total_paid, 0)) > 0;

-- ============================================================================
-- QUERY 5: Payment Method Distribution (KPI)
-- ============================================================================
SELECT 
    p.payment_method,
    COUNT(p.payment_id) as payment_count,
    SUM(p.amount_paid) as total_amount,
    ROUND(COUNT(p.payment_id) * 100.0 / (SELECT COUNT(*) FROM payments), 2) as percentage
FROM payments p
GROUP BY p.payment_method
ORDER BY total_amount DESC;

-- ============================================================================
-- QUERY 6: Average Usage Per Customer (KPI)
-- ============================================================================
SELECT 
    TO_CHAR(mr.reading_month, 'MON-YYYY') as month,
    COUNT(DISTINCT mr.customer_id) as active_customers,
    SUM(mr.usage_m3) as total_usage,
    ROUND(AVG(mr.usage_m3), 2) as avg_usage_per_customer
FROM meter_readings mr
GROUP BY TO_CHAR(mr.reading_month, 'MON-YYYY')
ORDER BY TO_DATE(TO_CHAR(mr.reading_month, 'MON-YYYY'), 'MON-YYYY');

-- ============================================================================
-- QUERY 7: Revenue Trend Analysis (12 Months)
-- ============================================================================
SELECT 
    TO_CHAR(p.payment_date, 'MON-YYYY') as month,
    SUM(p.amount_paid) as revenue,
    LAG(SUM(p.amount_paid), 1) OVER (ORDER BY TO_CHAR(p.payment_date, 'MON-YYYY')) as previous_month_revenue,
    SUM(p.amount_paid) - LAG(SUM(p.amount_paid), 1) OVER (ORDER BY TO_CHAR(p.payment_date, 'MON-YYYY')) as revenue_change,
    ROUND(
        ((SUM(p.amount_paid) - LAG(SUM(p.amount_paid), 1) OVER (ORDER BY TO_CHAR(p.payment_date, 'MON-YYYY'))) * 100.0 / 
        LAG(SUM(p.amount_paid), 1) OVER (ORDER BY TO_CHAR(p.payment_date, 'MON-YYYY'))), 
        2
    ) as revenue_growth_rate
FROM payments p
GROUP BY TO_CHAR(p.payment_date, 'MON-YYYY')
ORDER BY TO_DATE(TO_CHAR(p.payment_date, 'MON-YYYY'), 'MON-YYYY');

-- ============================================================================
-- QUERY 8: Top Customers by Usage
-- ============================================================================
SELECT 
    c.customer_id,
    c.full_name,
    c.meter_number,
    SUM(mr.usage_m3) as total_usage,
    COUNT(mr.reading_id) as reading_count,
    RANK() OVER (ORDER BY SUM(mr.usage_m3) DESC) as usage_rank
FROM customers c
INNER JOIN meter_readings mr ON c.customer_id = mr.customer_id
GROUP BY c.customer_id, c.full_name, c.meter_number
ORDER BY total_usage DESC
FETCH FIRST 10 ROWS ONLY;

-- ============================================================================
-- QUERY 9: Customer Segmentation by Usage
-- ============================================================================
SELECT 
    CASE 
        WHEN total_usage >= PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_usage) THEN 'High Usage'
        WHEN total_usage >= PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_usage) THEN 'Medium Usage'
        ELSE 'Low Usage'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(total_usage) as avg_usage,
    SUM(total_usage) as segment_total_usage
FROM (
    SELECT 
        c.customer_id,
        SUM(mr.usage_m3) as total_usage
    FROM customers c
    INNER JOIN meter_readings mr ON c.customer_id = mr.customer_id
    GROUP BY c.customer_id
)
GROUP BY 
    CASE 
        WHEN total_usage >= PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_usage) THEN 'High Usage'
        WHEN total_usage >= PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_usage) THEN 'Medium Usage'
        ELSE 'Low Usage'
    END
ORDER BY avg_usage DESC;

-- ============================================================================
-- QUERY 10: Average Days to Payment (KPI)
-- ============================================================================
SELECT 
    TO_CHAR(b.issued_at, 'MON-YYYY') as month,
    AVG(p.payment_date - b.issued_at) as avg_days_to_payment,
    MIN(p.payment_date - b.issued_at) as min_days,
    MAX(p.payment_date - b.issued_at) as max_days
FROM bills b
INNER JOIN payments p ON b.bill_id = p.bill_id
WHERE b.status = 'PAID'
GROUP BY TO_CHAR(b.issued_at, 'MON-YYYY')
ORDER BY TO_DATE(TO_CHAR(b.issued_at, 'MON-YYYY'), 'MON-YYYY');

-- ============================================================================
-- QUERY 11: Revenue by Customer Tier
-- ============================================================================
SELECT 
    CASE 
        WHEN SUM(mr.usage_m3) > 50 THEN 'Tier 5 (51+)'
        WHEN SUM(mr.usage_m3) > 30 THEN 'Tier 4 (31-50)'
        WHEN SUM(mr.usage_m3) > 20 THEN 'Tier 3 (21-30)'
        WHEN SUM(mr.usage_m3) > 10 THEN 'Tier 2 (11-20)'
        ELSE 'Tier 1 (0-10)'
    END as usage_tier,
    COUNT(DISTINCT c.customer_id) as customer_count,
    SUM(p.amount_paid) as total_revenue,
    AVG(p.amount_paid) as avg_revenue_per_customer
FROM customers c
INNER JOIN meter_readings mr ON c.customer_id = mr.customer_id
INNER JOIN bills b ON mr.reading_id = b.reading_id
INNER JOIN payments p ON b.bill_id = p.bill_id
GROUP BY 
    CASE 
        WHEN SUM(mr.usage_m3) > 50 THEN 'Tier 5 (51+)'
        WHEN SUM(mr.usage_m3) > 30 THEN 'Tier 4 (31-50)'
        WHEN SUM(mr.usage_m3) > 20 THEN 'Tier 3 (21-30)'
        WHEN SUM(mr.usage_m3) > 10 THEN 'Tier 2 (11-20)'
        ELSE 'Tier 1 (0-10)'
    END
ORDER BY total_revenue DESC;

-- ============================================================================
-- QUERY 12: Monthly Summary Dashboard Data
-- ============================================================================
SELECT 
    TO_CHAR(SYSDATE, 'MON-YYYY') as current_month,
    (SELECT COUNT(*) FROM customers WHERE status = 'ACTIVE') as active_customers,
    (SELECT COUNT(*) FROM meter_readings 
     WHERE TO_CHAR(reading_month, 'MON-YYYY') = TO_CHAR(SYSDATE, 'MON-YYYY')) as readings_this_month,
    (SELECT SUM(usage_m3) FROM meter_readings 
     WHERE TO_CHAR(reading_month, 'MON-YYYY') = TO_CHAR(SYSDATE, 'MON-YYYY')) as usage_this_month,
    (SELECT SUM(total_amount_due) FROM bills 
     WHERE TO_CHAR(billing_period, 'MON-YYYY') = TO_CHAR(SYSDATE, 'MON-YYYY')) as billed_this_month,
    (SELECT SUM(amount_paid) FROM payments 
     WHERE TO_CHAR(payment_date, 'MON-YYYY') = TO_CHAR(SYSDATE, 'MON-YYYY')) as paid_this_month,
    (SELECT COUNT(*) FROM bills 
     WHERE status = 'OVERDUE') as overdue_bills
FROM DUAL;

COMMIT;

