# Target E-commerce Case Study (Scaler)

This repository contains a SQL-based case study analyzing e-commerce order data, completed as part of a **Scaler** data analytics case study assignment.

The dataset is based on the **Target Brazilian E-commerce dataset** (the well-known Olist public dataset), covering customers, orders, order items, payments, reviews, products, sellers, and geolocation data.

The full analysis was carried out twice, using two different SQL environments:
- **Google BigQuery**
- **MySQL (via MySQL Workbench)**

Both versions answer the same set of business questions, so you can compare syntax and behavior across the two engines side by side.

## Repository Contents

| File | Description |
|---|---|
| `Target_Case_Study_BigQuery.sql` | All case study queries written in BigQuery Standard SQL |
| `Target_case_study_MySQLscript.sql` | The same queries converted to MySQL syntax |
| `Target - Business Case Study - Prathik Raju.pdf` | Case study writeup with BigQuery query outputs, charts, and insights |
| `Target - Business Case Study.pdf` | Original case study assignment/brief |
| `Target Case study data/` | Raw CSV source files |
| `README.md` | This file |

## Dataset Overview

The dataset consists of 8 tables:

- `customers` – customer IDs, location (city/state/zip)
- `orders` – order status and timestamps (purchase, approval, delivery)
- `order_items` – products in each order, price, freight value
- `payments` – payment type, installments, payment value
- `order_reviews` – customer review scores and comments
- `products` – product category and physical dimensions
- `sellers` – seller location
- `geolocation` – zip code to lat/long mapping

## Business Questions Answered

**Q1 — Exploratory Analysis**
- Column data types in the customers table
- Time range covered by the orders data
- Number of distinct cities/states customers ordered from

**Q2 — In-depth Exploration**
- Year-over-year order volume trend
- Monthly seasonality in order volume
- Time-of-day order placement patterns (Dawn/Morning/Afternoon/Night)

**Q3 — Evolution of E-commerce in Brazil**
- Month-on-month order volume by state
- Customer distribution across states

**Q4 — Impact on Economy**
- % change in order value (2017 vs. 2018, Jan–Aug)
- Total & average order price by state
- Total & average freight value by state

**Q5 — Sales, Freight & Delivery Time**
- Delivery time and estimated-vs-actual delivery gap per order
- Top/bottom 5 states by average freight cost
- Top/bottom 5 states by average delivery time
- States where actual delivery beat the estimate the most

**Q6 — Payments Analysis**
- Month-on-month order volume by payment type
- Order volume by number of payment installments

## Key Insights & Recommendations

- There's a significant gap between estimated and actual delivery time in several states, suggesting logistics/ETA models could be tightened.
- Order volume is growing year over year, but growth is concentrated in a handful of states (SP, RJ, MG) rather than distributed nationally — signaling where expansion efforts are and aren't reaching.
- Credit card is by far the dominant payment method, making payment reliability and security a priority area.
- The majority of sellers are based in São Paulo (SP); diversifying seller presence to other states, and optimizing SP logistics further, could improve delivery speed nationally.
- The highest-volume product categories (bed/table/bath, furniture/decoration, housewares) tend to be bulky items — warehouse space planning should account for this.

## Tools Used

- **Google BigQuery** – SQL editor, INFORMATION_SCHEMA metadata queries, CTEs, EXTRACT/DATE_DIFF functions
- **MySQL Workbench** – local MySQL instance, LOAD DATA INFILE for CSV ingestion, CTEs, EXTRACT/DATEDIFF functions

## Notes on BigQuery vs. MySQL Differences

A few syntax differences were handled during the conversion between the two versions:

- BigQuery's `` `project.dataset.table` `` references become plain `table_name` in MySQL (after `USE database_name;`)
- `INFORMATION_SCHEMA.COLUMNS` works in both, but MySQL requires filtering by `table_schema`
- BigQuery's `DATE_DIFF(a, b, DAY)` becomes MySQL's `DATEDIFF(a, b)`
- String sorting differs by default: BigQuery sorts case-sensitively, while MySQL's default collation is case-insensitive — this can affect the row order of text columns (e.g., payment_type) unless a binary collation is explicitly specified

## How to Run

**BigQuery:**
1. Open BigQuery in the Google Cloud Console
2. Load the 8 CSV files into a dataset (e.g., `Target_Ecommerce`)
3. Update the project/dataset name at the top of `Target_Case_Study_BigQuery.sql` if different
4. Run each query block individually in the query editor

**MySQL:**
1. Create a database (e.g., `target`) in MySQL Workbench
2. Run the `CREATE TABLE` statements (or the schema section of the script) to set up tables
3. Load the CSVs using `LOAD DATA LOCAL INFILE`
4. Run `Target_case_study_MySQLscript.sql` top to bottom
