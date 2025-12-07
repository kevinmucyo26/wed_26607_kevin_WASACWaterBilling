-- ============================================================================
-- Water Billing System - AUDIT SYSTEM
-- ============================================================================
-- Phase VII: Advanced Programming & Auditing
-- CRITICAL REQUIREMENT: Employees CANNOT INSERT/UPDATE/DELETE on weekdays or holidays
-- ============================================================================

-- ============================================================================
-- STEP 1: Create Public Holidays Table
-- ============================================================================
CREATE TABLE public_holidays (
    holiday_id NUMBER(10) PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    holiday_name VARCHAR2(100) NOT NULL,
    is_active CHAR(1) DEFAULT 'Y',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_holiday_active CHECK (is_active IN ('Y', 'N'))
);

CREATE SEQUENCE seq_holiday_id START WITH 1 INCREMENT BY 1;

-- Insert upcoming month holidays (example for December 2025)
INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, is_active)
VALUES (seq_holiday_id.NEXTVAL, TO_DATE('2025-12-25', 'YYYY-MM-DD'), 'Christmas Day', 'Y');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, is_active)
VALUES (seq_holiday_id.NEXTVAL, TO_DATE('2025-12-26', 'YYYY-MM-DD'), 'Boxing Day', 'Y');

-- Add more holidays as needed for upcoming month
COMMIT;

-- ============================================================================
-- STEP 2: Create Audit Log Table
-- ============================================================================
CREATE TABLE audit_log (
    audit_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL, -- INSERT, UPDATE, DELETE
    operation_status VARCHAR2(20) NOT NULL, -- ALLOWED, DENIED
    user_name VARCHAR2(100),
    session_user VARCHAR2(100),
    attempt_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    error_message VARCHAR2(500),
    record_id NUMBER(10),
    additional_info VARCHAR2(500),
    CONSTRAINT chk_operation_type CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT chk_operation_status CHECK (operation_status IN ('ALLOWED', 'DENIED'))
);

CREATE SEQUENCE seq_audit_id START WITH 1 INCREMENT BY 1;

CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_timestamp ON audit_log(attempt_timestamp);
CREATE INDEX idx_audit_status ON audit_log(operation_status);

-- ============================================================================
-- STEP 3: Audit Logging Function
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_log_audit(
    p_table_name IN VARCHAR2,
    p_operation_type IN VARCHAR2,
    p_operation_status IN VARCHAR2,
    p_record_id IN NUMBER DEFAULT NULL,
    p_error_message IN VARCHAR2 DEFAULT NULL,
    p_additional_info IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
    v_audit_id NUMBER(10);
BEGIN
    SELECT seq_audit_id.NEXTVAL INTO v_audit_id FROM DUAL;
    
    INSERT INTO audit_log (
        audit_id,
        table_name,
        operation_type,
        operation_status,
        user_name,
        session_user,
        error_message,
        record_id,
        additional_info
    ) VALUES (
        v_audit_id,
        p_table_name,
        p_operation_type,
        p_operation_status,
        USER,
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        p_error_message,
        p_record_id,
        p_additional_info
    );
    
    COMMIT;
    RETURN v_audit_id;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the operation
        RETURN NULL;
END;
/

-- ============================================================================
-- STEP 4: Restriction Check Function
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_check_dml_restriction
RETURN BOOLEAN
IS
    v_current_day VARCHAR2(10);
    v_is_weekday BOOLEAN := FALSE;
    v_is_holiday BOOLEAN := FALSE;
    v_holiday_name VARCHAR2(100);
BEGIN
    -- Get current day of week (1=Sunday, 2=Monday, ..., 7=Saturday)
    v_current_day := TO_CHAR(SYSDATE, 'D');
    
    -- Check if it's a weekday (Monday=2, Tuesday=3, Wednesday=4, Thursday=5, Friday=6)
    IF v_current_day IN ('2', '3', '4', '5', '6') THEN
        v_is_weekday := TRUE;
    END IF;
    
    -- Check if it's a public holiday
    SELECT COUNT(*), MAX(holiday_name)
    INTO v_is_holiday, v_holiday_name
    FROM public_holidays
    WHERE holiday_date = TRUNC(SYSDATE)
    AND is_active = 'Y';
    
    IF v_is_holiday > 0 THEN
        v_is_holiday := TRUE;
    ELSE
        v_is_holiday := FALSE;
    END IF;
    
    -- Return TRUE if restriction applies (weekday OR holiday)
    RETURN (v_is_weekday OR v_is_holiday);
END;
/

-- ============================================================================
-- STEP 5: Get Restriction Reason Function
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_get_restriction_reason
RETURN VARCHAR2
IS
    v_current_day VARCHAR2(10);
    v_day_name VARCHAR2(20);
    v_is_holiday BOOLEAN := FALSE;
    v_holiday_name VARCHAR2(100);
    v_reason VARCHAR2(200);
BEGIN
    -- Get current day name
    v_day_name := TO_CHAR(SYSDATE, 'Day');
    v_current_day := TO_CHAR(SYSDATE, 'D');
    
    -- Check if it's a weekday
    IF v_current_day IN ('2', '3', '4', '5', '6') THEN
        v_reason := 'Weekday restriction: DML operations are not allowed on ' || TRIM(v_day_name);
    END IF;
    
    -- Check if it's a holiday
    SELECT COUNT(*), MAX(holiday_name)
    INTO v_is_holiday, v_holiday_name
    FROM public_holidays
    WHERE holiday_date = TRUNC(SYSDATE)
    AND is_active = 'Y';
    
    IF v_is_holiday > 0 THEN
        IF v_reason IS NOT NULL THEN
            v_reason := v_reason || ' and ';
        END IF;
        v_reason := v_reason || 'Public holiday restriction: ' || v_holiday_name;
    END IF;
    
    RETURN v_reason;
END;
/

COMMIT;

