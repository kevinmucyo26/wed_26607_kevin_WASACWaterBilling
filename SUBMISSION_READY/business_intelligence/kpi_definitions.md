# KPI Definitions
## Water Billing and Usage Management System

## Revenue KPIs

### 1. Total Monthly Revenue
**Definition:** Sum of all payments received in a given month  
**Formula:** `SUM(amount_paid) WHERE payment_date BETWEEN start_date AND end_date`  
**Target:** Increase by 5% month-over-month  
**Frequency:** Monthly  
**Owner:** Finance Department

### 2. Collection Rate
**Definition:** Percentage of bills paid on or before due date  
**Formula:** `(Bills paid on time / Total bills issued) * 100`  
**Target:** > 85%  
**Frequency:** Monthly  
**Owner:** Billing Department

### 3. Average Revenue Per Customer (ARPC)
**Definition:** Total revenue divided by number of active customers  
**Formula:** `Total Revenue / Active Customers`  
**Target:** Increase by 3% quarterly  
**Frequency:** Monthly  
**Owner:** Management

### 4. Revenue Growth Rate
**Definition:** Month-over-month percentage change in revenue  
**Formula:** `((Current Month Revenue - Previous Month Revenue) / Previous Month Revenue) * 100`  
**Target:** > 0% (positive growth)  
**Frequency:** Monthly  
**Owner:** Management

## Operational KPIs

### 5. Total Water Usage
**Definition:** Total cubic meters of water consumed in a period  
**Formula:** `SUM(usage_m3) WHERE reading_month BETWEEN start_date AND end_date`  
**Target:** Track and analyze trends  
**Frequency:** Monthly  
**Owner:** Operations

### 6. Average Usage Per Customer
**Definition:** Total usage divided by number of customers  
**Formula:** `Total Usage / Number of Customers`  
**Target:** Identify high/low usage patterns  
**Frequency:** Monthly  
**Owner:** Operations

### 7. Peak Usage Period
**Definition:** Month with highest water consumption  
**Formula:** `MAX(SUM(usage_m3)) GROUP BY reading_month`  
**Target:** Plan for peak demand  
**Frequency:** Quarterly  
**Owner:** Operations

### 8. Customer Retention Rate
**Definition:** Percentage of customers who remain active  
**Formula:** `(Active Customers / Total Customers) * 100`  
**Target:** > 95%  
**Frequency:** Quarterly  
**Owner:** Management

## Financial KPIs

### 9. Outstanding Balance
**Definition:** Total amount of unpaid bills  
**Formula:** `SUM(total_amount_due - total_paid) WHERE status IN ('PENDING', 'OVERDUE', 'PARTIAL')`  
**Target:** < 10% of monthly revenue  
**Frequency:** Weekly  
**Owner:** Finance Department

### 10. Overdue Amount
**Definition:** Total amount of bills past due date  
**Formula:** `SUM(total_amount_due - total_paid) WHERE due_date < SYSDATE AND status != 'PAID'`  
**Target:** < 5% of monthly revenue  
**Frequency:** Weekly  
**Owner:** Billing Department

### 11. Average Days to Payment
**Definition:** Average number of days from bill issue to payment  
**Formula:** `AVG(payment_date - issued_at) WHERE status = 'PAID'`  
**Target:** < 30 days  
**Frequency:** Monthly  
**Owner:** Billing Department

### 12. Payment Method Distribution
**Definition:** Percentage breakdown by payment method  
**Formula:** `(Count by method / Total payments) * 100`  
**Target:** Diversify payment methods  
**Frequency:** Monthly  
**Owner:** Finance Department

## Customer KPIs

### 13. Active Customers
**Definition:** Customers with meter readings in last 3 months  
**Formula:** `COUNT(DISTINCT customer_id) WHERE reading_month >= SYSDATE - 90`  
**Target:** Maintain or increase  
**Frequency:** Monthly  
**Owner:** Operations

### 14. High Usage Customers
**Definition:** Top 10% of customers by water consumption  
**Formula:** `Customers WHERE usage_m3 >= PERCENTILE_CONT(0.9)`  
**Target:** Identify for special programs  
**Frequency:** Quarterly  
**Owner:** Management

### 15. Overdue Customers
**Definition:** Number of customers with overdue bills  
**Formula:** `COUNT(DISTINCT customer_id) WHERE has_overdue_bill = TRUE`  
**Target:** < 10% of total customers  
**Frequency:** Weekly  
**Owner:** Billing Department

### 16. New Customers
**Definition:** Customers added in current month  
**Formula:** `COUNT(*) WHERE created_at >= start_of_month`  
**Target:** Track growth  
**Frequency:** Monthly  
**Owner:** Management

## Audit KPIs

### 17. Audit Violations
**Definition:** Number of denied DML operations  
**Formula:** `COUNT(*) WHERE operation_status = 'DENIED'`  
**Target:** 0 violations  
**Frequency:** Daily  
**Owner:** IT/Admin

### 18. Weekend Operations
**Definition:** Number of allowed operations on weekends  
**Formula:** `COUNT(*) WHERE operation_status = 'ALLOWED' AND is_weekend = TRUE`  
**Target:** Track weekend activity  
**Frequency:** Weekly  
**Owner:** Operations

## Calculation Queries

### Total Monthly Revenue
```sql
SELECT 
    TO_CHAR(payment_date, 'MON-YYYY') as month,
    SUM(amount_paid) as total_revenue
FROM payments
GROUP BY TO_CHAR(payment_date, 'MON-YYYY')
ORDER BY month;
```

### Collection Rate
```sql
SELECT 
    TO_CHAR(b.issued_at, 'MON-YYYY') as month,
    COUNT(CASE WHEN b.status = 'PAID' AND p.payment_date <= b.due_date THEN 1 END) * 100.0 / 
    COUNT(b.bill_id) as collection_rate
FROM bills b
LEFT JOIN payments p ON b.bill_id = p.bill_id
GROUP BY TO_CHAR(b.issued_at, 'MON-YYYY')
ORDER BY month;
```

### Outstanding Balance
```sql
SELECT 
    SUM(b.total_amount_due - NVL(SUM(p.amount_paid), 0)) as outstanding_balance
FROM bills b
LEFT JOIN payments p ON b.bill_id = p.bill_id
WHERE b.status IN ('PENDING', 'OVERDUE', 'PARTIAL')
GROUP BY b.bill_id, b.total_amount_due;
```

### Overdue Amount
```sql
SELECT 
    SUM(b.total_amount_due - NVL(SUM(p.amount_paid), 0)) as overdue_amount
FROM bills b
LEFT JOIN payments p ON b.bill_id = p.bill_id
WHERE b.due_date < SYSDATE
AND b.status != 'PAID'
GROUP BY b.bill_id, b.total_amount_due;
```

