-- ============================================================================
-- Water Billing System - WINDOW FUNCTIONS & ANALYTICS
-- ============================================================================
-- Phase VI: Database Interaction & Transactions
-- Demonstrates ROW_NUMBER(), RANK(), DENSE_RANK(), LAG(), LEAD()
-- ============================================================================

-- ============================================================================
-- WINDOW FUNCTION 1: ROW_NUMBER() - Rank customers by total usage
-- ============================================================================
SELECT 
    c.customer_id,
    c.full_name,
    c.meter_number,
    SUM(mr.usage_m3) as total_usage,
    ROW_NUMBER() OVER (ORDER BY SUM(mr.usage_m3) DESC) as usage_rank
FROM customers c
INNER JOIN meter_readings mr ON c.customer_id = mr.customer_id
GROUP BY c.customer_id, c.full_name, c.meter_number
ORDER BY usage_rank;

-- ============================================================================
-- WINDOW FUNCTION 2: RANK() - Rank bills by amount (handles ties)
-- ============================================================================
SELECT 
    b.bill_id,
    c.full_name,
    b.billing_period,
    b.total_amount_due,
    RANK() OVER (ORDER BY b.total_amount_due DESC) as amount_rank
FROM bills b
INNER JOIN customers c ON b.customer_id = c.customer_id
ORDER BY amount_rank;

-- ============================================================================
-- WINDOW FUNCTION 3: DENSE_RANK() - Rank without gaps
-- ============================================================================
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(b.bill_id) as bill_count,
    DENSE_RANK() OVER (ORDER BY COUNT(b.bill_id) DESC) as bill_count_rank
FROM customers c
LEFT JOIN bills b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY bill_count_rank;

-- ============================================================================
-- WINDOW FUNCTION 4: LAG() - Compare current month with previous month
-- ============================================================================
SELECT 
    c.customer_id,
    c.full_name,
    mr.reading_month,
    mr.usage_m3 as current_usage,
    LAG(mr.usage_m3, 1) OVER (
        PARTITION BY c.customer_id 
        ORDER BY mr.reading_month
    ) as previous_usage,
    mr.usage_m3 - LAG(mr.usage_m3, 1) OVER (
        PARTITION BY c.customer_id 
        ORDER BY mr.reading_month
    ) as usage_change
FROM meter_readings mr
INNER JOIN customers c ON mr.customer_id = c.customer_id
ORDER BY c.customer_id, mr.reading_month;

-- ============================================================================
-- WINDOW FUNCTION 5: LEAD() - Compare current month with next month
-- ============================================================================
SELECT 
    c.customer_id,
    c.full_name,
    mr.reading_month,
    mr.usage_m3 as current_usage,
    LEAD(mr.usage_m3, 1) OVER (
        PARTITION BY c.customer_id 
        ORDER BY mr.reading_month
    ) as next_usage,
    LEAD(mr.usage_m3, 1) OVER (
        PARTITION BY c.customer_id 
        ORDER BY mr.reading_month
    ) - mr.usage_m3 as projected_change
FROM meter_readings mr
INNER JOIN customers c ON mr.customer_id = c.customer_id
ORDER BY c.customer_id, mr.reading_month;

-- ============================================================================
-- WINDOW FUNCTION 6: PARTITION BY - Monthly totals per customer
-- ============================================================================
SELECT 
    c.customer_id,
    c.full_name,
    TO_CHAR(mr.reading_month, 'MON-YYYY') as month,
    mr.usage_m3,
    SUM(mr.usage_m3) OVER (
        PARTITION BY c.customer_id 
        ORDER BY mr.reading_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_usage,
    AVG(mr.usage_m3) OVER (PARTITION BY c.customer_id) as avg_monthly_usage
FROM meter_readings mr
INNER JOIN customers c ON mr.customer_id = c.customer_id
ORDER BY c.customer_id, mr.reading_month;

-- ============================================================================
-- WINDOW FUNCTION 7: Multiple Window Functions - Comprehensive Analysis
-- ============================================================================
SELECT 
    b.bill_id,
    c.full_name,
    b.billing_period,
    b.usage_m3,
    b.total_amount_due,
    -- Ranking functions
    ROW_NUMBER() OVER (ORDER BY b.total_amount_due DESC) as amount_row_num,
    RANK() OVER (ORDER BY b.total_amount_due DESC) as amount_rank,
    DENSE_RANK() OVER (ORDER BY b.total_amount_due DESC) as amount_dense_rank,
    -- Aggregation with OVER
    SUM(b.total_amount_due) OVER (PARTITION BY c.customer_id) as customer_total,
    AVG(b.total_amount_due) OVER (PARTITION BY TO_CHAR(b.billing_period, 'YYYY')) as yearly_avg,
    -- LAG for comparison
    LAG(b.total_amount_due, 1) OVER (
        PARTITION BY c.customer_id 
        ORDER BY b.billing_period
    ) as previous_bill_amount
FROM bills b
INNER JOIN customers c ON b.customer_id = c.customer_id
ORDER BY c.customer_id, b.billing_period;

-- ============================================================================
-- WINDOW FUNCTION 8: Payment Trends Analysis
-- ============================================================================
SELECT 
    p.payment_date,
    SUM(p.amount_paid) as daily_total,
    AVG(SUM(p.amount_paid)) OVER (
        ORDER BY p.payment_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as seven_day_avg,
    LAG(SUM(p.amount_paid), 1) OVER (ORDER BY p.payment_date) as previous_day,
    SUM(p.amount_paid) - LAG(SUM(p.amount_paid), 1) OVER (ORDER BY p.payment_date) as day_over_day_change
FROM payments p
GROUP BY p.payment_date
ORDER BY p.payment_date;

-- ============================================================================
-- WINDOW FUNCTION 9: Customer Payment Ranking
-- ============================================================================
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(p.payment_id) as payment_count,
    SUM(p.amount_paid) as total_paid,
    RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) as payment_rank,
    PERCENT_RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) as payment_percentile
FROM customers c
LEFT JOIN bills b ON c.customer_id = b.customer_id
LEFT JOIN payments p ON b.bill_id = p.bill_id
GROUP BY c.customer_id, c.full_name
ORDER BY payment_rank;

-- ============================================================================
-- WINDOW FUNCTION 10: Monthly Usage Trends with Moving Averages
-- ============================================================================
SELECT 
    TO_CHAR(mr.reading_month, 'MON-YYYY') as month,
    SUM(mr.usage_m3) as total_usage,
    COUNT(DISTINCT mr.customer_id) as active_customers,
    AVG(SUM(mr.usage_m3)) OVER (
        ORDER BY mr.reading_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as three_month_avg,
    LAG(SUM(mr.usage_m3), 1) OVER (ORDER BY mr.reading_month) as previous_month_usage,
    SUM(mr.usage_m3) - LAG(SUM(mr.usage_m3), 1) OVER (ORDER BY mr.reading_month) as month_over_month_change
FROM meter_readings mr
GROUP BY mr.reading_month
ORDER BY mr.reading_month;

COMMIT;

PROMPT ============================================================================
PROMPT Window Functions Examples Created!
PROMPT ============================================================================
PROMPT These queries demonstrate:
PROMPT - ROW_NUMBER(), RANK(), DENSE_RANK()
PROMPT - LAG(), LEAD()
PROMPT - PARTITION BY, ORDER BY
PROMPT - Aggregates with OVER clause
PROMPT ============================================================================

