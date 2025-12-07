-- Open SQL*Plus or SQL Developer
-- Connect as SYSDBA
CONNECT sys/password@localhost:1521/XE AS SYSDBA;

CREATE PLUGGABLE DATABASE wed_26607_Kevin_WaterBilling_db
ADMIN USER admin_user IDENTIFIED BY Kevin
FILE_NAME_CONVERT = ('pdbseed', 'wed_26607_Kevin_WaterBilling_db');

ALTER PLUGGABLE DATABASE wed_26607_Kevin_WaterBilling_db OPEN;

ALTER SESSION SET CONTAINER = wed_26607_Kevin_WaterBilling_db;
CONNECT admin_user/Kevin@localhost:1521/wed_26607_Kevin_WaterBilling_db;

-- Data tablespace
CREATE TABLESPACE water_billing_data
DATAFILE 'water_billing_data.dbf' SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M;

-- Index tablespace
CREATE TABLESPACE water_billing_index
DATAFILE 'water_billing_index.dbf' SIZE 50M
AUTOEXTEND ON NEXT 5M MAXSIZE 200M;

-- Temporary tablespace
CREATE TEMPORARY TABLESPACE water_billing_temp
TEMPFILE 'water_billing_temp.dbf' SIZE 50M
AUTOEXTEND ON NEXT 5M MAXSIZE 200M;

-- Grant privileges
GRANT CONNECT, RESOURCE, DBA TO admin_user;
ALTER USER admin_user DEFAULT TABLESPACE water_billing_data;
ALTER USER admin_user TEMPORARY TABLESPACE water_billing_temp;