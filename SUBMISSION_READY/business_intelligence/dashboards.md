# Dashboard Mockups
## Water Billing and Usage Management System

## 1. Executive Summary Dashboard

### Layout:
```
┌─────────────────────────────────────────────────────────┐
│  EXECUTIVE SUMMARY DASHBOARD - Water Billing System    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [KPI Cards - 4 columns]                                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│
│  │Total     │ │Collection│ │Outstanding│ │Active    ││
│  │Revenue   │ │Rate      │ │Balance    │ │Customers ││
│  │RWF 2.5M  │ │85%       │ │RWF 250K   │ │1,250     ││
│  │↑ 5%      │ │↑ 2%      │ │↓ 10%      │ │↑ 3%      ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘│
│                                                          │
│  [Revenue Trend Chart - Line Chart]                     │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Revenue Over Time (Last 12 Months)               │ │
│  │                                                     │ │
│  │  3M ┤                                    ╱───╲     │ │
│  │  2M ┤                          ╱───╲    ╱     ╲    │ │
│  │  1M ┤                ╱───╲  ╱     ╲  ╱       ╲   │ │
│  │     └─────────────────────────────────────────────│ │
│  │      J  F  M  A  M  J  J  A  S  O  N  D          │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  [Payment Method Distribution - Pie Chart]             │
│  ┌──────────────┐  [Usage vs Revenue - Scatter]        │
│  │   CASH 45%   │  ┌────────────────────────────────┐ │
│  │   MOMO 30%   │  │ Usage vs Revenue Correlation    │ │
│  │   BANK 20%   │  │                                 │ │
│  │   OTHER 5%   │  │                                 │ │
│  └──────────────┘  └────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### KPIs Displayed:
1. Total Monthly Revenue (with trend indicator)
2. Collection Rate (with target comparison)
3. Outstanding Balance (with change indicator)
4. Active Customers (with growth rate)

### Charts:
- Revenue trend (line chart - 12 months)
- Payment method distribution (pie chart)
- Usage vs Revenue correlation (scatter plot)

---

## 2. Audit Dashboard

### Layout:
```
┌─────────────────────────────────────────────────────────┐
│  AUDIT DASHBOARD - Security & Compliance               │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [Audit Summary Cards]                                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  │Total         │ │Denied        │ │Allowed       │  │
│  │Attempts      │ │Operations    │ │Operations    │  │
│  │1,250         │ │25 (2%)      │ │1,225 (98%)   │  │
│  └──────────────┘ └──────────────┘ └──────────────┘  │
│                                                          │
│  [Violations Timeline - Bar Chart]                     │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Denied Operations by Day                         │ │
│  │                                                     │ │
│  │  10 ┤  ████                                        │ │
│  │   5 ┤  ██  ██  ██                                 │ │
│  │   0 └─────────────────────────────────────────────│ │
│  │     Mon Tue Wed Thu Fri Sat Sun                   │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  [Recent Audit Log - Table]                            │
│  ┌────────────────────────────────────────────────────┐ │
│  │Time    │Table      │Operation│Status│User         │ │
│  ├────────────────────────────────────────────────────┤ │
│  │10:30   │BILLS      │INSERT   │DENIED│agent001     │ │
│  │10:25   │READINGS   │INSERT   │DENIED│agent002     │ │
│  │09:15   │PAYMENTS   │INSERT   │ALLOWED│agent003    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  [Holiday Calendar]                                     │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Upcoming Holidays (Next 30 Days)                 │ │
│  │  Dec 25 - Christmas Day                            │ │
│  │  Dec 26 - Boxing Day                               │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Metrics:
- Total audit attempts
- Denied operations count and percentage
- Allowed operations count and percentage
- Violations by day of week
- Recent audit log entries
- Upcoming holidays

---

## 3. Performance Dashboard

### Layout:
```
┌─────────────────────────────────────────────────────────┐
│  PERFORMANCE DASHBOARD - Operations & Efficiency        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [Operational Metrics]                                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  │Total Usage   │ │Avg Usage    │ │Bills         │  │
│  │15,000 m³     │ │Per Customer │ │Generated     │  │
│  │              │ │12 m³        │ │1,250         │  │
│  └──────────────┘ └──────────────┘ └──────────────┘  │
│                                                          │
│  [Usage Trend - Area Chart]                            │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Monthly Water Usage (Last 6 Months)              │ │
│  │                                                     │ │
│  │ 20K ┤  ████████                                    │ │
│  │ 15K ┤  ████████  ████████                         │ │
│  │ 10K ┤  ████████  ████████  ████████               │ │
│  │  5K ┤  ████████  ████████  ████████  ████████     │ │
│  │     └─────────────────────────────────────────────│ │
│  │      Jul  Aug  Sep  Oct  Nov  Dec                 │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  [Top Customers by Usage - Bar Chart]                  │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Customer 1  ████████████████████ 250 m³         │ │
│  │  Customer 2  ████████████████ 200 m³              │ │
│  │  Customer 3  ████████████ 150 m³                 │ │
│  │  Customer 4  ██████████ 120 m³                    │ │
│  │  Customer 5  ████████ 100 m³                      │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  [Efficiency Metrics]                                   │
│  ┌──────────────┐ ┌──────────────┐                    │
│  │Avg Days to   │ │Bills per    │                    │
│  │Payment: 28   │ │Agent: 125   │                    │
│  └──────────────┘ └──────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

### Metrics:
- Total water usage
- Average usage per customer
- Bills generated
- Usage trends over time
- Top customers by usage
- Efficiency metrics

---

## 4. Customer Analytics Dashboard

### Layout:
```
┌─────────────────────────────────────────────────────────┐
│  CUSTOMER ANALYTICS DASHBOARD                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [Customer Segments]                                    │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  │High Usage    │ │Medium Usage  │ │Low Usage     │  │
│  │250 customers │ │750 customers │ │250 customers │  │
│  │20%           │ │60%           │ │20%           │  │
│  └──────────────┘ └──────────────┘ └──────────────┘  │
│                                                          │
│  [Customer Lifetime Value - Line Chart]                │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Average Revenue per Customer Over Time           │ │
│  │                                                     │ │
│  │ 15K ┤  ╱───╲                                        │ │
│  │ 10K ┤ ╱     ╲  ╱───╲                               │ │
│  │  5K ┤╱       ╲╱     ╲                             │ │
│  │     └─────────────────────────────────────────────│ │
│  │      Q1    Q2    Q3    Q4                         │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  [Payment Behavior - Heatmap]                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Payment Patterns by Day of Week                 │ │
│  │  Mon  Tue  Wed  Thu  Fri  Sat  Sun                │ │
│  │  ███  ███  ███  ███  ███  ██   ██                │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  [Customer Retention - Funnel Chart]                   │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Total Customers: 1,250                           │ │
│  │  Active (90 days): 1,100                          │ │
│  │  Active (30 days): 950                            │ │
│  │  Paid This Month: 800                             │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Metrics:
- Customer segmentation
- Customer lifetime value
- Payment behavior patterns
- Customer retention funnel

---

## Dashboard Implementation Notes

### Technology Stack (Suggested):
- **Frontend:** Power BI, Tableau, or custom web dashboard
- **Backend:** Oracle Database with PL/SQL procedures
- **Data Refresh:** Real-time or scheduled (hourly/daily)

### Data Sources:
- Bills table (fact table)
- Payments table
- Meter readings table
- Customers table (dimension)
- Audit log table

### Refresh Frequency:
- **Executive Dashboard:** Daily
- **Audit Dashboard:** Real-time
- **Performance Dashboard:** Hourly
- **Customer Analytics:** Daily

### Access Control:
- Executive Dashboard: Management only
- Audit Dashboard: IT/Admin only
- Performance Dashboard: Operations team
- Customer Analytics: Marketing/Billing

