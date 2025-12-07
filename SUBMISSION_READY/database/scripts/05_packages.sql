-- ============================================================================
-- Water Billing System - PACKAGES
-- ============================================================================
-- Package for billing operations
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_billing AS
    -- Generate bill from reading
    PROCEDURE generate_bill_from_reading(
        p_reading_id IN NUMBER,
        p_due_date IN DATE
    );
END pkg_billing;
/

CREATE OR REPLACE PACKAGE BODY pkg_billing AS
    PROCEDURE generate_bill_from_reading(
        p_reading_id IN NUMBER,
        p_due_date IN DATE
    )
    IS
        v_bill_id NUMBER(10);
    BEGIN
        proc_generate_bill(p_reading_id, p_due_date, v_bill_id);
    END generate_bill_from_reading;
END pkg_billing;
/

COMMIT;
