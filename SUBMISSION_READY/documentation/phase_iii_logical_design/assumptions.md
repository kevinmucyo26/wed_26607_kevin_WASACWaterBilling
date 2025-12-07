ASSUMPTIONS - Water Billing System

1. All monetary values are in Rwandan Francs (RWF)

2. Meter readings are taken monthly by field agents

3. Bills are generated automatically when meter readings are recorded

4. Multiple payments per bill are allowed (partial payments supported)

5. 5-tier pricing structure with base amount (connection fee)

6. Weekend definition: Saturday (7) and Sunday (1) are weekends

7. Holiday restriction: Only upcoming month holidays are checked for DML restrictions

8. Only ACTIVE customers can have meter readings recorded

9. Time zone: All timestamps use database server time zone

10. Data retention: Historical data is retained for audit purposes

11. Normalization: All tables are in 3rd Normal Form (3NF)

12. Tariff rates can change over time (slowly changing dimension)