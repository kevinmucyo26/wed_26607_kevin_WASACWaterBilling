-- ============================================================================
-- Water Billing and Usage Management System for WASAC Agent
-- Database Schema Creation Script
-- ============================================================================
-- This script creates 5 tables for the water billing system:
-- 1. customers - Customer information and meter details
-- 2. meter_readings - Monthly meter readings
-- 3. tariff_rates - Tiered pricing structure
-- 4. bills - Generated bills with tiered calculations
-- 5. payments - Payment records
-- ============================================================================

-- Drop existing tables (in reverse order of dependencies)
DROP TABLE payments CASCADE CONSTRAINTS;
DROP TABLE bills CASCADE CONSTRAINTS;
DROP TABLE meter_readings CASCADE CONSTRAINTS;
DROP TABLE tariff_rates CASCADE CONSTRAINTS;
DROP TABLE customers CASCADE CONSTRAINTS;

-- ============================================================================
-- TABLE 1: CUSTOMERS
-- ============================================================================
CREATE TABLE customers (
    customer_id NUMBER(10) PRIMARY KEY,
    full_name VARCHAR2(120) NOT NULL,
    phone VARCHAR2(15) NOT NULL UNIQUE,
    address VARCHAR2(150) NOT NULL,
    meter_number VARCHAR2(12) NOT NULL UNIQUE,
    status VARCHAR2(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_customer_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

-- Sequence for customer_id
CREATE SEQUENCE seq_customer_id START WITH 1 INCREMENT BY 1;

-- ============================================================================
-- TABLE 2: TARIFF_RATES (Tiered Pricing Structure)
-- ============================================================================
CREATE TABLE tariff_rates (
    tariff_id NUMBER(10) PRIMARY KEY,
    tier_level NUMBER(2) NOT NULL UNIQUE,
    min_usage_m3 NUMBER(10,2) NOT NULL,
    max_usage_m3 NUMBER(10,2),
    rate_per_m3 NUMBER(10,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active CHAR(1) DEFAULT 'Y',
    CONSTRAINT chk_tier_level CHECK (tier_level BETWEEN 1 AND 5),
    CONSTRAINT chk_tariff_active CHECK (is_active IN ('Y', 'N')),
    CONSTRAINT chk_usage_range CHECK (max_usage_m3 IS NULL OR max_usage_m3 > min_usage_m3)
);

-- Sequence for tariff_id
CREATE SEQUENCE seq_tariff_id START WITH 1 INCREMENT BY 1;

-- ============================================================================
-- TABLE 3: METER_READINGS
-- ============================================================================
CREATE TABLE meter_readings (
    reading_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10) NOT NULL,
    reading_month DATE NOT NULL,
    previous_reading NUMBER(10,2) NOT NULL,
    current_reading NUMBER(10,2) NOT NULL,
    usage_m3 NUMBER(10,2),
    reading_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR2(255),
    CONSTRAINT fk_reading_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT chk_previous_reading CHECK (previous_reading >= 0),
    CONSTRAINT chk_current_reading CHECK (current_reading >= previous_reading),
    CONSTRAINT chk_usage CHECK (usage_m3 >= 0)
);

-- Sequence for reading_id
CREATE SEQUENCE seq_reading_id START WITH 1 INCREMENT BY 1;

-- ============================================================================
-- TABLE 4: BILLS
-- ============================================================================
CREATE TABLE bills (
    bill_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10) NOT NULL,
    reading_id NUMBER(10) NOT NULL UNIQUE,
    billing_period DATE NOT NULL,
    usage_m3 NUMBER(10,2) NOT NULL,
    base_amount NUMBER(12,2) NOT NULL,
    tier1_amount NUMBER(12,2) DEFAULT 0,
    tier2_amount NUMBER(12,2) DEFAULT 0,
    tier3_amount NUMBER(12,2) DEFAULT 0,
    tier4_amount NUMBER(12,2) DEFAULT 0,
    tier5_amount NUMBER(12,2) DEFAULT 0,
    total_amount_due NUMBER(12,2) NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR2(20) NOT NULL DEFAULT 'PENDING',
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bill_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_bill_reading FOREIGN KEY (reading_id) REFERENCES meter_readings(reading_id) ON DELETE CASCADE,
    CONSTRAINT chk_bill_status CHECK (status IN ('PENDING', 'PAID', 'OVERDUE', 'PARTIAL', 'CANCELLED')),
    CONSTRAINT chk_total_amount CHECK (total_amount_due >= 0)
);

-- Sequence for bill_id
CREATE SEQUENCE seq_bill_id START WITH 1 INCREMENT BY 1;

-- ============================================================================
-- TABLE 5: PAYMENTS
-- ============================================================================
CREATE TABLE payments (
    payment_id NUMBER(10) PRIMARY KEY,
    bill_id NUMBER(10) NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid NUMBER(12,2) NOT NULL,
    payment_method VARCHAR2(30) NOT NULL,
    reference_number VARCHAR2(50) UNIQUE,
    received_by VARCHAR2(100) NOT NULL,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_bill FOREIGN KEY (bill_id) REFERENCES bills(bill_id) ON DELETE CASCADE,
    CONSTRAINT chk_payment_amount CHECK (amount_paid > 0),
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('CASH', 'MOMO PAY', 'BANK TRANSFER', 'CHEQUE', 'OTHER'))
);

-- Sequence for payment_id
CREATE SEQUENCE seq_payment_id START WITH 1 INCREMENT BY 1;

-- ============================================================================
-- INDEXES for Performance
-- ============================================================================
CREATE INDEX idx_customers_meter ON customers(meter_number);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_readings_customer ON meter_readings(customer_id);
CREATE INDEX idx_readings_month ON meter_readings(reading_month);
CREATE INDEX idx_bills_customer ON bills(customer_id);
CREATE INDEX idx_bills_status ON bills(status);
CREATE INDEX idx_bills_due_date ON bills(due_date);
CREATE INDEX idx_payments_bill ON payments(bill_id);
CREATE INDEX idx_payments_date ON payments(payment_date);

-- ============================================================================
-- COMMENTS for Documentation
-- ============================================================================
COMMENT ON TABLE customers IS 'Stores customer information and meter details';
COMMENT ON TABLE tariff_rates IS 'Stores tiered pricing structure for water consumption';
COMMENT ON TABLE meter_readings IS 'Stores monthly meter readings from field agents';
COMMENT ON TABLE bills IS 'Stores generated bills with tiered tariff calculations';
COMMENT ON TABLE payments IS 'Stores payment records for bills';

COMMIT;
