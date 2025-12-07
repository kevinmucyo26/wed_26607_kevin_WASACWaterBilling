-- Water Billing System Database Schema
-- Target DBMS: PostgreSQL
-- Run these commands with a superuser account (e.g. postgres)

CREATE DATABASE water_billing_system_db;

\c water_billing_system_db;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    address VARCHAR(150) NOT NULL,
    meter_number VARCHAR(12) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE meter_readings (
    reading_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    reading_month DATE NOT NULL,
    previous_reading NUMERIC(10,2) NOT NULL CHECK (previous_reading >= 0),
    current_reading NUMERIC(10,2) NOT NULL CHECK (current_reading >= previous_reading),
    usage_m3 NUMERIC(10,2) GENERATED ALWAYS AS (current_reading - previous_reading) STORED,
    notes VARCHAR(255)
);

CREATE TABLE bills (
    bill_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    reading_id INTEGER NOT NULL UNIQUE REFERENCES meter_readings(reading_id) ON DELETE CASCADE,
    billing_period DATE NOT NULL,
    rate_per_m3 NUMERIC(10,2) NOT NULL,
    amount_due NUMERIC(12,2) NOT NULL CHECK (amount_due >= 0),
    due_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    bill_id INTEGER NOT NULL REFERENCES bills(bill_id) ON DELETE CASCADE,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    amount_paid NUMERIC(12,2) NOT NULL CHECK (amount_paid > 0),
    payment_method VARCHAR(30) NOT NULL,
    reference_number VARCHAR(50) UNIQUE,
    received_by VARCHAR(100) NOT NULL
);

-- Seed data for quick testing
INSERT INTO customers (full_name, phone, address, meter_number, status) VALUES
('Alice Uwimana', '0788000001', 'Kigali - Nyarugenge', 'MT000001', 'ACTIVE'),
('Jean Bosco', '0788000002', 'Kigali - Gasabo', 'MT000002', 'ACTIVE'),
('Claire Mukamana', '0788000003', 'Kigali - Kicukiro', 'MT000003', 'INACTIVE');

-- Default readings for sample customers
INSERT INTO meter_readings (customer_id, reading_month, previous_reading, current_reading, notes) VALUES
(1, DATE '2025-10-01', 120.0, 150.0, 'October visit'),
(2, DATE '2025-10-01', 90.0, 110.0, 'October visit');

-- Example bills based on the readings (rate 845 RWF per m3)
INSERT INTO bills (customer_id, reading_id, billing_period, rate_per_m3, amount_due, due_date, status) VALUES
(1, 1, DATE '2025-10-01', 845.00, (150.0 - 120.0) * 845, DATE '2025-10-30', 'PENDING'),
(2, 2, DATE '2025-10-01', 845.00, (110.0 - 90.0) * 845, DATE '2025-10-30', 'PAID');

-- Sample payment for customer 2
INSERT INTO payments (bill_id, payment_date, amount_paid, payment_method, reference_number, received_by) VALUES
(2, DATE '2025-10-15', (110.0 - 90.0) * 845, 'MOMO PAY', 'PMT-2025-0001', 'Agent Beata');



