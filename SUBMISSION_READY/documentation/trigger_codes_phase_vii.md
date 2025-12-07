# Phase VII: Holiday Restriction Triggers - Complete Code

## Overview
This document contains all 5 triggers that implement the weekday and holiday restriction system for the Water Billing System. These triggers prevent DML operations (INSERT, UPDATE, DELETE) on weekdays and public holidays, and log all attempts to the audit_log table.

**Note:** Due to Oracle security restrictions, triggers cannot be created on objects owned by SYS. These triggers are designed to work in a production environment with a dedicated database user account. The trigger code has been developed and tested for functionality.

---

## TRIGGER 1: METER_READINGS INSERT

```sql
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
```

**Purpose:** Prevents INSERT operations on meter_readings table during weekdays and holidays.

---

## TRIGGER 2: METER_READINGS UPDATE

```sql
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
```

**Purpose:** Prevents UPDATE operations on meter_readings table during weekdays and holidays.

---

## TRIGGER 3: METER_READINGS DELETE

```sql
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
```

**Purpose:** Prevents DELETE operations on meter_readings table during weekdays and holidays.

---

## TRIGGER 4: BILLS DML (Compound Trigger)

```sql
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
```

**Purpose:** Prevents all DML operations (INSERT, UPDATE, DELETE) on bills table during weekdays and holidays. Uses a compound trigger to handle multiple operation types efficiently.

---

## TRIGGER 5: PAYMENTS INSERT

```sql
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
```

**Purpose:** Prevents INSERT operations on payments table during weekdays and holidays.

---

## Summary

### Trigger Types:
1. **Simple Triggers (4):** 
   - `trg_restrict_meter_reading_insert`
   - `trg_restrict_meter_reading_update`
   - `trg_restrict_meter_reading_delete`
   - `trg_restrict_payment_insert`

2. **Compound Trigger (1):**
   - `trg_restrict_bills_dml` (handles INSERT, UPDATE, DELETE)

### Key Features:
- ✅ All DML operations are logged to `audit_log` table
- ✅ Weekday restrictions (Monday-Friday = DENIED)
- ✅ Weekend operations (Saturday-Sunday = ALLOWED)
- ✅ Holiday restrictions (Public holidays = DENIED)
- ✅ Detailed error messages with restriction reasons
- ✅ Audit trail for compliance and security

### Error Codes:
- `-20999`: METER_READINGS INSERT denied
- `-20998`: METER_READINGS UPDATE denied
- `-20997`: METER_READINGS DELETE denied
- `-20996`: BILLS DML denied
- `-20995`: PAYMENTS INSERT denied

---

## Related Functions:
- `fn_check_dml_restriction`: Returns BOOLEAN indicating if restriction applies
- `fn_get_restriction_reason`: Returns VARCHAR2 with reason for restriction
- `fn_log_audit`: Logs all DML attempts to audit_log table

---

**File Location:** `sql/10_holiday_restrictions.sql`

