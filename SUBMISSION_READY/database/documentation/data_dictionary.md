# Data Dictionary
## Water Billing and Usage Management System

## Table: CUSTOMERS

| Column | Type | Constraints | Purpose | Notes |
|--------|------|-------------|---------|-------|
| customer_id | NUMBER(10) | PK, NOT NULL | Unique customer identifier | Auto-generated from seq_customer_id |
| full_name | VARCHAR2(120) | NOT NULL | Customer's full name | |
| phone | VARCHAR2(15) | NOT NULL, UNIQUE | Customer phone number | Format: 10 digits |
| address | VARCHAR2(150) | NOT NULL | Customer address | |
| meter_number | VARCHAR2(12) | NOT NULL, UNIQUE | Water meter number | Format: MT###### |
| status | VARCHAR2(20) | NOT NULL, DEFAULT 'ACTIVE' | Customer status | Values: ACTIVE, INACTIVE, SUSPENDED |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp | |

**Indexes:**
- idx_customers_meter ON customers(meter_number)
- idx_customers_status ON customers(status)

**Foreign Keys:** None (parent table)

**Business Rules:**
- Phone number must be unique
- Meter number must be unique
- Status must be one of: ACTIVE, INACTIVE, SUSPENDED

---

## Table: TARIFF_RATES

| Column | Type | Constraints | Purpose | Notes |
|--------|------|-------------|---------|-------|
| tariff_id | NUMBER(10) | PK, NOT NULL | Unique tariff identifier | Auto-generated from seq_tariff_id |
| tier_level | NUMBER(2) | NOT NULL, UNIQUE | Tier level (1-5) | Values: 1-5 |
| min_usage_m3 | NUMBER(10,2) | NOT NULL | Minimum usage for tier | |
| max_usage_m3 | NUMBER(10,2) | NULL | Maximum usage for tier | NULL for unlimited (Tier 5) |
| rate_per_m3 | NUMBER(10,2) | NOT NULL | Rate per cubic meter | In RWF |
| effective_from | DATE | NOT NULL | Effective start date | |
| effective_to | DATE | NULL | Effective end date | NULL for current rates |
| is_active | CHAR(1) | DEFAULT 'Y' | Active status | Values: Y, N |

**Indexes:** None

**Foreign Keys:** None

**Business Rules:**
- Tier level must be between 1 and 5
- Max usage must be greater than min usage (if not NULL)
- Only one active rate per tier at a time
- Used for slowly changing dimensions (historical rates)

---

## Table: METER_READINGS

| Column | Type | Constraints | Purpose | Notes |
|--------|------|-------------|---------|-------|
| reading_id | NUMBER(10) | PK, NOT NULL | Unique reading identifier | Auto-generated from seq_reading_id |
| customer_id | NUMBER(10) | NOT NULL, FK | Reference to customer | References customers(customer_id) |
| reading_month | DATE | NOT NULL | Month of reading | |
| previous_reading | NUMBER(10,2) | NOT NULL | Previous meter reading | Must be >= 0 |
| current_reading | NUMBER(10,2) | NOT NULL | Current meter reading | Must be >= previous_reading |
| usage_m3 | NUMBER(10,2) | NULL | Calculated usage | Auto-calculated by trigger |
| reading_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Reading record timestamp | |
| notes | VARCHAR2(255) | NULL | Additional notes | |

**Indexes:**
- idx_readings_customer ON meter_readings(customer_id)
- idx_readings_month ON meter_readings(reading_month)

**Foreign Keys:**
- fk_reading_customer: customer_id → customers(customer_id) ON DELETE CASCADE

**Business Rules:**
- Current reading must be >= previous reading
- Usage is auto-calculated: current_reading - previous_reading
- Only one reading per customer per month allowed
- Customer must be ACTIVE to have readings

---

## Table: BILLS

| Column | Type | Constraints | Purpose | Notes |
|--------|------|-------------|---------|-------|
| bill_id | NUMBER(10) | PK, NOT NULL | Unique bill identifier | Auto-generated from seq_bill_id |
| customer_id | NUMBER(10) | NOT NULL, FK | Reference to customer | References customers(customer_id) |
| reading_id | NUMBER(10) | NOT NULL, UNIQUE, FK | Reference to reading | References meter_readings(reading_id) |
| billing_period | DATE | NOT NULL | Billing period | |
| usage_m3 | NUMBER(10,2) | NOT NULL | Water usage in m³ | |
| base_amount | NUMBER(12,2) | NOT NULL | Base connection fee | Fixed amount (5000 RWF) |
| tier1_amount | NUMBER(12,2) | DEFAULT 0 | Tier 1 charges | |
| tier2_amount | NUMBER(12,2) | DEFAULT 0 | Tier 2 charges | |
| tier3_amount | NUMBER(12,2) | DEFAULT 0 | Tier 3 charges | |
| tier4_amount | NUMBER(12,2) | DEFAULT 0 | Tier 4 charges | |
| tier5_amount | NUMBER(12,2) | DEFAULT 0 | Tier 5 charges | |
| total_amount_due | NUMBER(12,2) | NOT NULL | Total bill amount | Must be >= 0 |
| due_date | DATE | NOT NULL | Payment due date | |
| status | VARCHAR2(20) | NOT NULL, DEFAULT 'PENDING' | Bill status | Values: PENDING, PAID, OVERDUE, PARTIAL, CANCELLED |
| issued_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Bill issue timestamp | |

**Indexes:**
- idx_bills_customer ON bills(customer_id)
- idx_bills_status ON bills(status)
- idx_bills_due_date ON bills(due_date)

**Foreign Keys:**
- fk_bill_customer: customer_id → customers(customer_id) ON DELETE CASCADE
- fk_bill_reading: reading_id → meter_readings(reading_id) ON DELETE CASCADE

**Business Rules:**
- One bill per reading (1:1 relationship)
- Total amount = base_amount + sum of tier amounts
- Status auto-updated based on payments
- Due date typically 30 days from billing period

---

## Table: PAYMENTS

| Column | Type | Constraints | Purpose | Notes |
|--------|------|-------------|---------|-------|
| payment_id | NUMBER(10) | PK, NOT NULL | Unique payment identifier | Auto-generated from seq_payment_id |
| bill_id | NUMBER(10) | NOT NULL, FK | Reference to bill | References bills(bill_id) |
| payment_date | DATE | NOT NULL | Payment date | Default: CURRENT_DATE |
| amount_paid | NUMBER(12,2) | NOT NULL | Payment amount | Must be > 0 |
| payment_method | VARCHAR2(30) | NOT NULL | Payment method | Values: CASH, MOMO PAY, BANK TRANSFER, CHEQUE, OTHER |
| reference_number | VARCHAR2(50) | UNIQUE | Payment reference | Optional |
| received_by | VARCHAR2(100) | NOT NULL | Agent who received payment | |
| processed_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Payment processing timestamp | |

**Indexes:**
- idx_payments_bill ON payments(bill_id)
- idx_payments_date ON payments(payment_date)

**Foreign Keys:**
- fk_payment_bill: bill_id → bills(bill_id) ON DELETE CASCADE

**Business Rules:**
- Payment amount must be > 0
- Total payments cannot exceed bill amount
- Payment method must be valid
- Reference number must be unique if provided

---

## Table: PUBLIC_HOLIDAYS

| Column | Type | Constraints | Purpose | Notes |
|--------|------|-------------|---------|-------|
| holiday_id | NUMBER(10) | PK, NOT NULL | Unique holiday identifier | Auto-generated from seq_holiday_id |
| holiday_date | DATE | NOT NULL, UNIQUE | Holiday date | |
| holiday_name | VARCHAR2(100) | NOT NULL | Holiday name | |
| is_active | CHAR(1) | DEFAULT 'Y' | Active status | Values: Y, N |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp | |

**Indexes:** None

**Foreign Keys:** None

**Business Rules:**
- Holiday date must be unique
- Used for DML restriction enforcement
- Only active holidays are checked

---

## Table: AUDIT_LOG

| Column | Type | Constraints | Purpose | Notes |
|--------|------|-------------|---------|-------|
| audit_id | NUMBER(10) | PK, NOT NULL | Unique audit identifier | Auto-generated from seq_audit_id |
| table_name | VARCHAR2(50) | NOT NULL | Table name | |
| operation_type | VARCHAR2(10) | NOT NULL | Operation type | Values: INSERT, UPDATE, DELETE |
| operation_status | VARCHAR2(20) | NOT NULL | Operation status | Values: ALLOWED, DENIED |
| user_name | VARCHAR2(100) | NULL | Database user | |
| session_user | VARCHAR2(100) | NULL | Session user | |
| attempt_timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Attempt timestamp | |
| error_message | VARCHAR2(500) | NULL | Error message | For denied operations |
| record_id | NUMBER(10) | NULL | Record ID | |
| additional_info | VARCHAR2(500) | NULL | Additional information | |

**Indexes:**
- idx_audit_table ON audit_log(table_name)
- idx_audit_timestamp ON audit_log(attempt_timestamp)
- idx_audit_status ON audit_log(operation_status)

**Foreign Keys:** None

**Business Rules:**
- All DML operations are logged
- Denied operations include error message
- Used for compliance and security auditing

---

## Sequences

| Sequence Name | Purpose | Start Value | Increment |
|---------------|---------|------------|-----------|
| seq_customer_id | Customer IDs | 1 | 1 |
| seq_tariff_id | Tariff IDs | 1 | 1 |
| seq_reading_id | Reading IDs | 1 | 1 |
| seq_bill_id | Bill IDs | 1 | 1 |
| seq_payment_id | Payment IDs | 1 | 1 |
| seq_holiday_id | Holiday IDs | 1 | 1 |
| seq_audit_id | Audit IDs | 1 | 1 |

---

## Assumptions

1. **Currency:** All monetary values are in Rwandan Francs (RWF)
2. **Meter Readings:** Readings are taken monthly
3. **Billing:** Bills are generated automatically when readings are recorded
4. **Payments:** Multiple payments per bill are allowed (partial payments)
5. **Tariff Structure:** 5-tier pricing structure with base amount
6. **Time Zone:** All timestamps use database server time zone
7. **Data Retention:** Historical data is retained for audit purposes
8. **Weekend Definition:** Saturday (7) and Sunday (1) are weekends
9. **Holiday Restriction:** Only upcoming month holidays are checked
10. **Customer Status:** Only ACTIVE customers can have meter readings

---

## Data Volume Estimates

| Table | Estimated Rows | Growth Rate |
|-------|----------------|-------------|
| CUSTOMERS | 1,000 - 10,000 | 50-100/month |
| TARIFF_RATES | 5-25 | 1-2/year |
| METER_READINGS | 12,000 - 120,000 | 1,000-10,000/month |
| BILLS | 12,000 - 120,000 | 1,000-10,000/month |
| PAYMENTS | 10,000 - 100,000 | 1,000-10,000/month |
| PUBLIC_HOLIDAYS | 10-20 | 1-2/year |
| AUDIT_LOG | 50,000 - 500,000 | 5,000-50,000/month |

---

## Relationships Summary

```
CUSTOMERS (1) ────< (M) METER_READINGS (1) ────< (1) BILLS (1) ────< (M) PAYMENTS
     │
     └───< (M) BILLS

TARIFF_RATES (independent table, referenced by functions)

PUBLIC_HOLIDAYS (independent table, referenced by triggers)

AUDIT_LOG (independent table, populated by triggers)
```

---

## Normalization

All tables are in **3rd Normal Form (3NF)**:
- ✅ **1NF:** No repeating groups
- ✅ **2NF:** No partial dependencies
- ✅ **3NF:** No transitive dependencies

---

## BI Considerations

### Fact Tables:
- **BILLS** - Primary fact table (transactional data)
- **PAYMENTS** - Secondary fact table (payment transactions)

### Dimension Tables:
- **CUSTOMERS** - Customer dimension
- **TARIFF_RATES** - Slowly changing dimension (historical rates)
- **TIME** - Implicit dimension (billing_period, payment_date)

### Aggregation Levels:
- Daily
- Monthly
- Quarterly
- Yearly

### Audit Trail:
- **AUDIT_LOG** - Complete audit trail for compliance

