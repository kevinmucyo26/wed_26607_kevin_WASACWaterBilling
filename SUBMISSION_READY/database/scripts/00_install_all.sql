-- ============================================================================
-- Water Billing System - MASTER INSTALLATION SCRIPT
-- ============================================================================
-- This script installs the entire system in the correct order
-- Run this script to set up the complete Water Billing System
-- ============================================================================

SET SERVEROUTPUT ON SIZE 1000000;
SET ECHO ON;
SET FEEDBACK ON;

PROMPT ============================================================================
PROMPT WATER BILLING AND USAGE MANAGEMENT SYSTEM FOR WASAC AGENT
PROMPT Master Installation Script
PROMPT ============================================================================
PROMPT
PROMPT This script will install:
PROMPT - Database schema (7 tables including audit)
PROMPT - Functions (7+ functions)
PROMPT - Procedures (10+ procedures)
PROMPT - Packages (1 package)
PROMPT - Triggers (11+ triggers including restrictions)
PROMPT - Report procedures (5 reports)
PROMPT - Audit system (Phase VII)
PROMPT - Holiday restrictions (Phase VII)
PROMPT - Window functions examples
PROMPT - Explicit cursors examples
PROMPT - Sample data (optional)
PROMPT ============================================================================
PROMPT

-- ============================================================================
-- STEP 1: Create Database Schema
-- ============================================================================
PROMPT
PROMPT Step 1/11: Creating database schema (7 tables)...
PROMPT ============================================================================
@@01_create_schema.sql

-- ============================================================================
-- STEP 2: Create Functions
-- ============================================================================
PROMPT
PROMPT Step 2/11: Creating functions (5+ functions)...
PROMPT ============================================================================
@@03_functions.sql

-- ============================================================================
-- STEP 3: Create Procedures
-- ============================================================================
PROMPT
PROMPT Step 3/11: Creating procedures (6+ procedures)...
PROMPT ============================================================================
@@04_procedures.sql

-- ============================================================================
-- STEP 4: Create Packages
-- ============================================================================
PROMPT
PROMPT Step 4/11: Creating packages (1 package)...
PROMPT ============================================================================
@@05_packages.sql

-- ============================================================================
-- STEP 5: Create Basic Triggers
-- ============================================================================
PROMPT
PROMPT Step 5/11: Creating basic triggers (6 triggers)...
PROMPT ============================================================================
@@02_triggers.sql

-- ============================================================================
-- STEP 6: Create Report Procedures
-- ============================================================================
PROMPT
PROMPT Step 6/11: Creating report procedures (5 reports)...
PROMPT ============================================================================
@@07_reports.sql

-- ============================================================================
-- STEP 7: Create Audit System (Phase VII)
-- ============================================================================
PROMPT
PROMPT Step 7/11: Creating audit system (Phase VII)...
PROMPT ============================================================================
@@09_audit_system.sql

-- ============================================================================
-- STEP 8: Create Holiday Restriction Triggers (Phase VII - CRITICAL)
-- ============================================================================
PROMPT
PROMPT Step 8/11: Creating holiday restriction triggers (Phase VII - CRITICAL)...
PROMPT ============================================================================
@@10_holiday_restrictions.sql

-- ============================================================================
-- STEP 9: Create Window Functions Examples (Phase VI)
-- ============================================================================
PROMPT
PROMPT Step 9/11: Creating window functions examples (Phase VI)...
PROMPT ============================================================================
@@11_window_functions.sql

-- ============================================================================
-- STEP 10: Create Explicit Cursors Examples (Phase VI)
-- ============================================================================
PROMPT
PROMPT Step 10/11: Creating explicit cursors examples (Phase VI)...
PROMPT ============================================================================
@@12_explicit_cursors.sql

-- ============================================================================
-- STEP 11: Load Sample Data (Optional - Comment out if not needed)
-- ============================================================================
PROMPT
PROMPT Step 11/11: Loading sample data...
PROMPT ============================================================================
PROMPT (You can skip this step by commenting out the next line)
@@06_sample_data.sql

-- ============================================================================
-- VERIFICATION
-- ============================================================================
PROMPT
PROMPT Verifying installation...
PROMPT ============================================================================

PROMPT
PROMPT Checking tables...
SELECT 'Tables: ' || COUNT(*) || ' created' as status
FROM user_tables
WHERE table_name IN ('CUSTOMERS', 'TARIFF_RATES', 'METER_READINGS', 'BILLS', 'PAYMENTS', 'PUBLIC_HOLIDAYS', 'AUDIT_LOG');

PROMPT
PROMPT Checking sequences...
SELECT 'Sequences: ' || COUNT(*) || ' created' as status
FROM user_sequences
WHERE sequence_name LIKE 'SEQ_%';

PROMPT
PROMPT Checking triggers...
SELECT 'Triggers: ' || COUNT(*) || ' created' as status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_%';

PROMPT
PROMPT Checking procedures...
SELECT 'Procedures: ' || COUNT(*) || ' created' as status
FROM user_procedures
WHERE object_type = 'PROCEDURE' AND object_name LIKE 'PROC_%';

PROMPT
PROMPT Checking functions...
SELECT 'Functions: ' || COUNT(*) || ' created' as status
FROM user_procedures
WHERE object_type = 'FUNCTION' AND object_name LIKE 'FN_%';

PROMPT
PROMPT Checking packages...
SELECT 'Packages: ' || COUNT(*) || ' created' as status
FROM user_objects
WHERE object_type = 'PACKAGE' AND object_name LIKE 'PKG_%';

PROMPT
PROMPT ============================================================================
PROMPT INSTALLATION COMPLETE!
PROMPT ============================================================================
PROMPT
PROMPT The Water Billing System has been successfully installed.
PROMPT
PROMPT Next steps:
PROMPT 1. Review the installation_guide.md for usage instructions
PROMPT 2. Run test_script.sql to see the system in action
PROMPT 3. Start using the system with your data
PROMPT
PROMPT ============================================================================

COMMIT;

