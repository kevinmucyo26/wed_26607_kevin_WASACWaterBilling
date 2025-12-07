-- ============================================================================
-- Audit Queries for Security and Compliance
-- ============================================================================
-- Phase VII: Advanced Programming & Auditing
-- ============================================================================

-- ============================================================================
-- QUERY 1: All Audit Log Entries
-- ============================================================================
SELECT 
    audit_id,
    table_name,
    operation_type,
    operation_status,
    user_name,
    session_user,
    TO_CHAR(attempt_timestamp, 'DD-MON-YYYY HH24:MI:SS') as attempt_time,
    error_message,
    record_id,
    additional_info
FROM audit_log
ORDER BY attempt_timestamp DESC;

-- ============================================================================
-- QUERY 2: Denied Operations Summary
-- ============================================================================
SELECT 
    table_name,
    operation_type,
    COUNT(*) as denied_count,
    MIN(attempt_timestamp) as first_denial,
    MAX(attempt_timestamp) as last_denial
FROM audit_log
WHERE operation_status = 'DENIED'
GROUP BY table_name, operation_type
ORDER BY denied_count DESC;

-- ============================================================================
-- QUERY 3: Audit Violations by Day of Week
-- ============================================================================
SELECT 
    TO_CHAR(attempt_timestamp, 'Day') as day_of_week,
    COUNT(*) as violation_count,
    COUNT(DISTINCT user_name) as unique_users,
    LISTAGG(DISTINCT table_name, ', ') WITHIN GROUP (ORDER BY table_name) as tables_affected
FROM audit_log
WHERE operation_status = 'DENIED'
GROUP BY TO_CHAR(attempt_timestamp, 'Day')
ORDER BY 
    CASE TO_CHAR(attempt_timestamp, 'D')
        WHEN '1' THEN 1
        WHEN '2' THEN 2
        WHEN '3' THEN 3
        WHEN '4' THEN 4
        WHEN '5' THEN 5
        WHEN '6' THEN 6
        WHEN '7' THEN 7
    END;

-- ============================================================================
-- QUERY 4: Audit Violations by User
-- ============================================================================
SELECT 
    user_name,
    session_user,
    COUNT(*) as total_attempts,
    COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) as denied_count,
    COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) as allowed_count,
    ROUND(
        COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) as denial_rate
FROM audit_log
GROUP BY user_name, session_user
ORDER BY denied_count DESC;

-- ============================================================================
-- QUERY 5: Recent Violations (Last 24 Hours)
-- ============================================================================
SELECT 
    audit_id,
    table_name,
    operation_type,
    user_name,
    TO_CHAR(attempt_timestamp, 'DD-MON-YYYY HH24:MI:SS') as attempt_time,
    error_message
FROM audit_log
WHERE operation_status = 'DENIED'
AND attempt_timestamp >= SYSDATE - 1
ORDER BY attempt_timestamp DESC;

-- ============================================================================
-- QUERY 6: Audit Statistics by Table
-- ============================================================================
SELECT 
    table_name,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN operation_type = 'INSERT' THEN 1 END) as insert_count,
    COUNT(CASE WHEN operation_type = 'UPDATE' THEN 1 END) as update_count,
    COUNT(CASE WHEN operation_type = 'DELETE' THEN 1 END) as delete_count,
    COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) as denied_count,
    COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) as allowed_count
FROM audit_log
GROUP BY table_name
ORDER BY total_operations DESC;

-- ============================================================================
-- QUERY 7: Holiday Restriction Effectiveness
-- ============================================================================
SELECT 
    h.holiday_date,
    h.holiday_name,
    COUNT(a.audit_id) as total_attempts,
    COUNT(CASE WHEN a.operation_status = 'DENIED' THEN 1 END) as denied_attempts,
    COUNT(CASE WHEN a.operation_status = 'ALLOWED' THEN 1 END) as allowed_attempts
FROM public_holidays h
LEFT JOIN audit_log a ON TRUNC(a.attempt_timestamp) = h.holiday_date
WHERE h.is_active = 'Y'
GROUP BY h.holiday_date, h.holiday_name
ORDER BY h.holiday_date;

-- ============================================================================
-- QUERY 8: Weekend Operations Analysis
-- ============================================================================
SELECT 
    CASE 
        WHEN TO_CHAR(attempt_timestamp, 'D') IN ('1', '7') THEN 'Weekend'
        ELSE 'Weekday'
    END as day_type,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) as allowed_operations,
    COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) as denied_operations
FROM audit_log
GROUP BY 
    CASE 
        WHEN TO_CHAR(attempt_timestamp, 'D') IN ('1', '7') THEN 'Weekend'
        ELSE 'Weekday'
    END;

-- ============================================================================
-- QUERY 9: Audit Compliance Report
-- ============================================================================
SELECT 
    TO_CHAR(attempt_timestamp, 'MON-YYYY') as month,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) as violations,
    ROUND(
        COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) as violation_rate,
    COUNT(DISTINCT user_name) as unique_users
FROM audit_log
GROUP BY TO_CHAR(attempt_timestamp, 'MON-YYYY')
ORDER BY TO_DATE(TO_CHAR(attempt_timestamp, 'MON-YYYY'), 'MON-YYYY');

-- ============================================================================
-- QUERY 10: Detailed Violation Report
-- ============================================================================
SELECT 
    a.audit_id,
    a.table_name,
    a.operation_type,
    a.user_name,
    TO_CHAR(a.attempt_timestamp, 'DD-MON-YYYY HH24:MI:SS') as attempt_time,
    TO_CHAR(a.attempt_timestamp, 'Day') as day_of_week,
    a.error_message,
    a.record_id,
    a.additional_info,
    CASE 
        WHEN h.holiday_name IS NOT NULL THEN 'Holiday: ' || h.holiday_name
        WHEN TO_CHAR(a.attempt_timestamp, 'D') IN ('2', '3', '4', '5', '6') THEN 'Weekday'
        ELSE 'Weekend'
    END as restriction_reason
FROM audit_log a
LEFT JOIN public_holidays h ON TRUNC(a.attempt_timestamp) = h.holiday_date AND h.is_active = 'Y'
WHERE a.operation_status = 'DENIED'
ORDER BY a.attempt_timestamp DESC;

-- ============================================================================
-- QUERY 11: Upcoming Holidays (Next 30 Days)
-- ============================================================================
SELECT 
    holiday_id,
    holiday_date,
    holiday_name,
    TO_CHAR(holiday_date, 'Day') as day_of_week,
    (holiday_date - SYSDATE) as days_until
FROM public_holidays
WHERE holiday_date >= SYSDATE
AND holiday_date <= SYSDATE + 30
AND is_active = 'Y'
ORDER BY holiday_date;

-- ============================================================================
-- QUERY 12: Audit Summary Dashboard Data
-- ============================================================================
SELECT 
    (SELECT COUNT(*) FROM audit_log) as total_audit_entries,
    (SELECT COUNT(*) FROM audit_log WHERE operation_status = 'DENIED') as total_violations,
    (SELECT COUNT(*) FROM audit_log WHERE operation_status = 'ALLOWED') as total_allowed,
    (SELECT COUNT(*) FROM audit_log 
     WHERE attempt_timestamp >= SYSDATE - 7) as operations_last_week,
    (SELECT COUNT(*) FROM audit_log 
     WHERE operation_status = 'DENIED' 
     AND attempt_timestamp >= SYSDATE - 7) as violations_last_week,
    (SELECT COUNT(*) FROM public_holidays 
     WHERE holiday_date >= SYSDATE 
     AND holiday_date <= SYSDATE + 30 
     AND is_active = 'Y') as upcoming_holidays
FROM DUAL;

COMMIT;

