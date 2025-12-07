# Water Billing and Usage Management System for WASAC Agent

**Student Name:** MUCYO Kevin  
**Student ID:** 26607  
**Group:** wed  
**Course:** Database Development with PL/SQL (INSY 8311)  
**Lecturer:** Eric Maniraguha  
**Institution:** Adventist University of Central Africa (AUCA)  
**Submission Date:**07/12/2025

---

## Project Overview

This PL/SQL system automates water billing for WASAC agents by calculating consumption from meter readings, generating bills with tiered tariffs, and tracking payments across seven database tables. It uses triggers and procedures to eliminate manual errors and provides real-time reports on usage, payments, and overdue accounts.

**Problem Statement:** Manual water billing processes are error-prone, tiered tariff calculations are complex, and there's no real-time reporting. This system automates the entire billing process.

**Key Objectives:**
- Automate bill generation from meter readings
- Implement 5-tier tariff calculations
- Track payments and update bill status automatically
- Generate real-time reports for decision-making
- Implement security restrictions (weekday/holiday blocking)
- Comprehensive audit logging

---

## Quick Start

### Installation

1. **Connect to Oracle Database:**
   ```sql
   CONNECT username/password@database_name;
   SET SERVEROUTPUT ON;
   ```

2. **Run Master Installation Script:**
   ```sql
   @database/scripts/00_install_all.sql
   ```

3. **Test the System:**
   ```sql
   @database/scripts/08_test_script.sql
   ```

---

## Project Structure

```
water-billing-system/
├── README.md (this file)
├── database/
│   ├── scripts/
│   │   ├── 00_install_all.sql
│   │   ├── 01_create_schema.sql
│   │   ├── 02_triggers.sql
│   │   ├── 03_functions.sql
│   │   ├── 04_procedures.sql
│   │   ├── 05_packages.sql
│   │   ├── 06_sample_data.sql
│   │   ├── 07_reports.sql
│   │   ├── 08_test_script.sql
│   │   ├── 09_audit_system.sql
│   │   ├── 10_holiday_restrictions.sql
│   │   ├── 11_window_functions.sql
│   │   └── 12_explicit_cursors.sql
│   └── documentation/
│       └── data_dictionary.md
├── queries/
│   ├── data_retrieval.sql
│   ├── analytics_queries.sql
│   └── audit_queries.sql
├── business_intelligence/
│   ├── bi_requirements.md
│   ├── kpi_definitions.md
│   └── dashboards.md
├── screenshots/
│   ├── er_diagram.png (add your ER diagram)
│   ├── business_process.png (add your BPMN diagram)
│   ├── database_structure/
│   ├── sample_data/
│   ├── procedures_triggers/
│   ├── test_results/
│   └── audit_logs/
└── documentation/
    ├── phase_i_problem_statement.pptx (add your presentation)
    ├── phase_ii_business_process/
    ├── phase_iii_logical_design/
    └── presentation.pptx (add your 10-slide presentation)
```

---

## Key Features

### Database Schema (7 Tables)
1. **CUSTOMERS** - Customer information and meter details
2. **TARIFF_RATES** - Tiered pricing structure (5 tiers)
3. **METER_READINGS** - Monthly meter readings
4. **BILLS** - Generated bills with tiered calculations
5. **PAYMENTS** - Payment records
6. **PUBLIC_HOLIDAYS** - Holiday management (Phase VII)
7. **AUDIT_LOG** - Complete audit trail (Phase VII)

### PL/SQL Components
- **8+ Functions** - Calculations and validations
- **10+ Procedures** - Business logic operations
- **11+ Triggers** - Automation and restrictions
- **1 Package** - Billing operations
- **5 Reports** - Business intelligence reports

### Advanced Features (Phase VII)
- **Holiday Restrictions** - DML blocked on weekdays and holidays
- **Audit Logging** - Complete audit trail
- **Window Functions** - Advanced analytics
- **Explicit Cursors** - Multi-row processing

---

## Testing

### Test Critical Requirements (Phase VII)

**Weekday Restriction Test:**
```sql
-- On Monday-Friday, this should FAIL
DECLARE
    v_id NUMBER;
BEGIN
    proc_record_meter_reading(
        p_customer_id => 1,
        p_reading_month => SYSDATE,
        p_previous_reading => 100,
        p_current_reading => 115,
        p_reading_id => v_id
    );
END;
/
-- Expected: DML Operation DENIED
```

**Weekend Test:**
```sql
-- On Saturday/Sunday, this should SUCCEED
-- Same code as above
-- Expected: Success
```

**Audit Log Check:**
```sql
SELECT * FROM audit_log 
ORDER BY attempt_timestamp DESC;
```

---

## Documentation

- **Data Dictionary:** `database/documentation/data_dictionary.md`
- **BI Requirements:** `business_intelligence/bi_requirements.md`
- **KPI Definitions:** `business_intelligence/kpi_definitions.md`
- **Dashboard Mockups:** `business_intelligence/dashboards.md`

---

## Screenshots Required

Please add screenshots showing:
1. ER diagram with all 7 tables
2. Business process diagram (BPMN)
3. Database structure in SQL Developer
4. Sample data (5-10 rows per table)
5. Procedures/triggers in editor
6. Test execution results
7. Audit log entries
8. **IMPORTANT:** All screenshots must show project name

---

## Submission

**Email to:** eric.maniraguha@auca.ac.rw

**Include:**
1. GitHub repository link
2. PowerPoint presentation (10 slides max)
3. Google Drive link (optional)

**Deadline:** December 7, 2025

---

## Contact

**Lecturer:** Eric Maniraguha  
**Email:** eric.maniraguha@auca.ac.rw

---

## License

This project is created for academic purposes as part of the PL/SQL Capstone Project at AUCA.


