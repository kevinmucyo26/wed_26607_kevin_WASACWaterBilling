-- ============================================================================
-- Water Billing System - FUNCTIONS
-- ============================================================================
-- Functions for calculations and data retrieval
-- ============================================================================

-- ============================================================================
-- FUNCTION 1: Calculate tiered tariff amount
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_calculate_tiered_amount(
    p_usage_m3 IN NUMBER
) RETURN NUMBER
IS
    v_total_amount NUMBER(12,2) := 0;
    v_remaining_usage NUMBER(10,2) := p_usage_m3;
    v_tier_usage NUMBER(10,2);
    v_tier_range NUMBER(10,2);
    CURSOR c_tiers IS
        SELECT tier_level, min_usage_m3, NVL(max_usage_m3, 999999) as max_usage_m3, rate_per_m3
        FROM tariff_rates
        WHERE is_active = 'Y'
        AND effective_from <= SYSDATE
        AND (effective_to IS NULL OR effective_to >= SYSDATE)
        ORDER BY tier_level;
BEGIN
    -- Loop through tiers and calculate amount
    FOR tier_rec IN c_tiers LOOP
        IF v_remaining_usage > 0 THEN
            -- Calculate tier range (number of m3 in this tier)
            -- Tiers represent cumulative usage: Tier 1 (0-10), Tier 2 (11-20), etc.
            -- Tier 1: range = 10 - 0 = 10
            -- Tier 2: range = 20 - (11-1) = 10
            IF tier_rec.min_usage_m3 = 0 THEN
                v_tier_range := tier_rec.max_usage_m3 - tier_rec.min_usage_m3;
            ELSE
                v_tier_range := tier_rec.max_usage_m3 - (tier_rec.min_usage_m3 - 1);
            END IF;
            
            -- Calculate usage in this tier
            IF v_remaining_usage <= v_tier_range THEN
                v_tier_usage := v_remaining_usage;
            ELSE
                v_tier_usage := v_tier_range;
            END IF;
            
            -- Add to total amount
            v_total_amount := v_total_amount + (v_tier_usage * tier_rec.rate_per_m3);
            
            -- Reduce remaining usage
            v_remaining_usage := v_remaining_usage - v_tier_usage;
        ELSE
            EXIT;
        END IF;
    END LOOP;
    
    RETURN v_total_amount;
END;
/

-- ============================================================================
-- FUNCTION 2: Get tier breakdown for a given usage
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_get_tier_breakdown(
    p_usage_m3 IN NUMBER,
    p_tier1_amount OUT NUMBER,
    p_tier2_amount OUT NUMBER,
    p_tier3_amount OUT NUMBER,
    p_tier4_amount OUT NUMBER,
    p_tier5_amount OUT NUMBER,
    p_base_amount OUT NUMBER
) RETURN NUMBER
IS
    v_total_amount NUMBER(12,2) := 0;
    v_remaining_usage NUMBER(10,2) := p_usage_m3;
    v_tier_usage NUMBER(10,2);
    v_tier_count NUMBER := 0;
    v_tier_range NUMBER(10,2);
    CURSOR c_tiers IS
        SELECT tier_level, min_usage_m3, NVL(max_usage_m3, 999999) as max_usage_m3, rate_per_m3
        FROM tariff_rates
        WHERE is_active = 'Y'
        AND effective_from <= SYSDATE
        AND (effective_to IS NULL OR effective_to >= SYSDATE)
        ORDER BY tier_level;
BEGIN
    -- Initialize tier amounts
    p_tier1_amount := 0;
    p_tier2_amount := 0;
    p_tier3_amount := 0;
    p_tier4_amount := 0;
    p_tier5_amount := 0;
    p_base_amount := 0;
    
    -- Base amount (fixed charge) - typically for first tier
    -- For WASAC, base amount is usually a fixed connection fee
    p_base_amount := 5000; -- Fixed base charge in RWF
    
    -- Loop through tiers
    FOR tier_rec IN c_tiers LOOP
        v_tier_count := v_tier_count + 1;
        
        IF v_remaining_usage > 0 THEN
            -- Calculate tier range (number of m3 in this tier)
            -- Tiers represent cumulative usage ranges:
            -- Tier 1: 0-10 means usage 0-10 m3 (range = 10 m3)
            -- Tier 2: 11-20 means usage 11-20 m3 (range = 10 m3, since 20-10=10)
            -- So range = max - min for tier 1, and max - previous_max for others
            -- But simpler: range = max - min + 1 for all tiers (inclusive)
            -- However, for usage calculation: if min=0,max=10, range=10 (not 11)
            -- If min=11,max=20, range=10 (20-11+1=10, but we want 10, not 11)
            -- Actually: Tier 1 (0-10) = 10 m3, Tier 2 (11-20) = 10 m3
            -- So: range = max - min for tier 1, range = max - min for tier 2
            -- But 20-11=9, which is wrong. The correct is: range = max - previous_tier_max
            -- For tier 1: range = 10 - 0 = 10
            -- For tier 2: range = 20 - 10 = 10
            -- So we need previous tier's max, which is min_usage_m3 - 1
            IF tier_rec.min_usage_m3 = 0 THEN
                v_tier_range := tier_rec.max_usage_m3 - tier_rec.min_usage_m3;
            ELSE
                v_tier_range := tier_rec.max_usage_m3 - (tier_rec.min_usage_m3 - 1);
            END IF;
            
            -- Calculate how much usage falls in this tier
            IF v_remaining_usage <= v_tier_range THEN
                -- All remaining usage is in this tier
                v_tier_usage := v_remaining_usage;
            ELSE
                -- Only part of usage is in this tier
                v_tier_usage := v_tier_range;
            END IF;
            
            -- Calculate tier amount
            v_total_amount := v_total_amount + (v_tier_usage * tier_rec.rate_per_m3);
            
            -- Assign to appropriate tier variable
            CASE v_tier_count
                WHEN 1 THEN p_tier1_amount := v_tier_usage * tier_rec.rate_per_m3;
                WHEN 2 THEN p_tier2_amount := v_tier_usage * tier_rec.rate_per_m3;
                WHEN 3 THEN p_tier3_amount := v_tier_usage * tier_rec.rate_per_m3;
                WHEN 4 THEN p_tier4_amount := v_tier_usage * tier_rec.rate_per_m3;
                WHEN 5 THEN p_tier5_amount := v_tier_usage * tier_rec.rate_per_m3;
            END CASE;
            
            -- Reduce remaining usage
            v_remaining_usage := v_remaining_usage - v_tier_usage;
        ELSE
            EXIT;
        END IF;
    END LOOP;
    
    -- Add base amount to total
    v_total_amount := v_total_amount + p_base_amount;
    
    RETURN v_total_amount;
END;
/

-- ============================================================================
-- FUNCTION 3: Get customer total outstanding balance
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_get_customer_balance(
    p_customer_id IN NUMBER
) RETURN NUMBER
IS
    v_total_due NUMBER(12,2) := 0;
    v_total_paid NUMBER(12,2) := 0;
    v_balance NUMBER(12,2) := 0;
BEGIN
    -- Get total amount due from all pending/overdue bills
    SELECT NVL(SUM(total_amount_due), 0)
    INTO v_total_due
    FROM bills
    WHERE customer_id = p_customer_id
    AND status IN ('PENDING', 'OVERDUE', 'PARTIAL');
    
    -- Get total paid for those bills
    SELECT NVL(SUM(p.amount_paid), 0)
    INTO v_total_paid
    FROM payments p
    INNER JOIN bills b ON p.bill_id = b.bill_id
    WHERE b.customer_id = p_customer_id
    AND b.status IN ('PENDING', 'OVERDUE', 'PARTIAL');
    
    v_balance := v_total_due - v_total_paid;
    
    RETURN v_balance;
END;
/

-- ============================================================================
-- FUNCTION 4: Get monthly usage statistics
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_get_monthly_usage(
    p_customer_id IN NUMBER,
    p_month IN DATE
) RETURN NUMBER
IS
    v_usage NUMBER(10,2) := 0;
BEGIN
    SELECT NVL(usage_m3, 0)
    INTO v_usage
    FROM meter_readings
    WHERE customer_id = p_customer_id
    AND TRUNC(reading_month, 'MM') = TRUNC(p_month, 'MM');
    
    RETURN v_usage;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-- ============================================================================
-- FUNCTION 5: Check if bill is overdue
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_is_bill_overdue(
    p_bill_id IN NUMBER
) RETURN BOOLEAN
IS
    v_due_date DATE;
    v_status VARCHAR2(20);
BEGIN
    SELECT due_date, status
    INTO v_due_date, v_status
    FROM bills
    WHERE bill_id = p_bill_id;
    
    IF v_status = 'PAID' THEN
        RETURN FALSE;
    ELSIF v_due_date < SYSDATE THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;
/

COMMIT;
