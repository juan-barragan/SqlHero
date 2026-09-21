# PostgreSQL Tutorial - Datasets and Setup Guide

This folder contains all the CSV datasets and SQL scripts you need to practice the exercises from the PostgreSQL tutorial.

## 📂 Files Included

### CSV Datasets
- `employees.csv` - 30 employee records with salaries, departments, managers
- `departments.csv` - 5 departments with locations and budgets
- `products.csv` - 30 products with categories, prices, stock info
- `sales_reps.csv` - 30 sales representatives with regional data
- `customers.csv` - 20 customers from various countries
- `suppliers.csv` - 7 suppliers with ratings
- `orders.csv` - 50 orders spanning 2023-2024
- `order_items.csv` - 78 line items from orders
- `reviews.csv` - 45 product reviews
- `monthly_sales.csv` - Monthly performance data for salespeople
- `transactions.csv` - 50 transaction records
- `projects.csv` - 10 project assignments

### SQL Scripts
- `setup_database.sql` - Complete database schema and loading instructions

## 🚀 Quick Start

### Option 1: Using PostgreSQL locally

1. **Install PostgreSQL** (if not already installed)
   ```bash
   # macOS
   brew install postgresql
   
   # Ubuntu/Debian
   sudo apt-get install postgresql
   
   # Windows
   # Download from https://www.postgresql.org/download/
   ```

2. **Start PostgreSQL**
   ```bash
   # macOS/Linux
   psql postgres
   
   # Or connect to specific database
   psql -U your_username -d your_database
   ```

3. **Create a new database**
   ```sql
   CREATE DATABASE tutorial_db;
   \c tutorial_db
   ```

4. **Run the setup script**
   ```bash
   # From command line
   psql -U your_username -d tutorial_db -f setup_database.sql
   
   # Or from within psql
   \i setup_database.sql
   ```

5. **Load the CSV data**
   
   Navigate to the datasets folder in your terminal, then in psql:
   ```sql
   \copy employees(id, first_name, last_name, email, phone_number, hire_date, salary, department, job_title, manager_id, bonus) FROM 'employees.csv' DELIMITER ',' CSV HEADER;
   
   \copy departments(id, dept_name, location, budget) FROM 'departments.csv' DELIMITER ',' CSV HEADER;
   
   \copy products(id, name, category, price, cost, stock_quantity, supplier_id, supplier_email, last_restocked) FROM 'products.csv' DELIMITER ',' CSV HEADER;
   
   \copy sales_reps(id, name, region, total_sales, customer_count, join_date) FROM 'sales_reps.csv' DELIMITER ',' CSV HEADER;
   
   \copy customers(id, name, email, city, country, signup_date) FROM 'customers.csv' DELIMITER ',' CSV HEADER;
   
   \copy suppliers(id, name, country, rating) FROM 'suppliers.csv' DELIMITER ',' CSV HEADER;
   
   \copy orders(id, customer_id, order_date, total_amount, status, shipping_cost, product_category) FROM 'orders.csv' DELIMITER ',' CSV HEADER;
   
   \copy order_items(id, order_id, product_id, quantity, unit_price, customer_id) FROM 'order_items.csv' DELIMITER ',' CSV HEADER;
   
   \copy reviews(id, product_id, customer_id, rating, review_date, review_text) FROM 'reviews.csv' DELIMITER ',' CSV HEADER;
   
   \copy monthly_sales(month, salesperson, revenue, region) FROM 'monthly_sales.csv' DELIMITER ',' CSV HEADER;
   
   \copy transactions(id, customer_id, transaction_date, amount, category, status) FROM 'transactions.csv' DELIMITER ',' CSV HEADER;
   
   \copy projects(id, project_name, employee_id, start_date, end_date, budget, status) FROM 'projects.csv' DELIMITER ',' CSV HEADER;
   ```

6. **Reset sequences** (Important!)
   ```sql
   SELECT setval('employees_id_seq', (SELECT MAX(id) FROM employees));
   SELECT setval('departments_id_seq', (SELECT MAX(id) FROM departments));
   SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));
   SELECT setval('sales_reps_id_seq', (SELECT MAX(id) FROM sales_reps));
   SELECT setval('customers_id_seq', (SELECT MAX(id) FROM customers));
   SELECT setval('suppliers_id_seq', (SELECT MAX(id) FROM suppliers));
   SELECT setval('orders_id_seq', (SELECT MAX(id) FROM orders));
   SELECT setval('order_items_id_seq', (SELECT MAX(id) FROM order_items));
   SELECT setval('reviews_id_seq', (SELECT MAX(id) FROM reviews));
   SELECT setval('monthly_sales_id_seq', (SELECT MAX(id) FROM monthly_sales));
   SELECT setval('transactions_id_seq', (SELECT MAX(id) FROM transactions));
   SELECT setval('projects_id_seq', (SELECT MAX(id) FROM projects));
   ```

### Option 2: Using Docker

```bash
# Pull and run PostgreSQL
docker run --name postgres-tutorial \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_DB=tutorial_db \
  -p 5432:5432 \
  -v $(pwd)/datasets:/datasets \
  -d postgres:latest

# Connect to the database
docker exec -it postgres-tutorial psql -U postgres -d tutorial_db

# Then follow steps 4-6 from Option 1
```

### Option 3: Using Online PostgreSQL

If you don't want to install anything locally, you can use:
- **ElephantSQL** - https://www.elephantsql.com/ (Free tier available)
- **Supabase** - https://supabase.com/ (Free tier available)
- **Neon** - https://neon.tech/ (Free tier available)

Upload the CSV files through their web interfaces or use the SQL script provided.

## 📊 Table Relationships

```
employees ──┬─→ departments (via department name)
            └─→ employees (self-join for managers)
            └─→ projects (via employee_id)

products ──→ suppliers (via supplier_id)
        └──→ order_items (via product_id)
        └──→ reviews (via product_id)

customers ──→ orders (via customer_id)
          └─→ order_items (via customer_id)
          └─→ reviews (via customer_id)

orders ──→ order_items (via order_id)
```

## 🎯 Practice Tips

1. **Start Simple**: Begin with SELECT queries on single tables
2. **Build Complexity**: Gradually add WHERE, ORDER BY, and aggregations
3. **Join Tables**: Practice different types of joins
4. **Use Window Functions**: Try ranking and running totals
5. **Optimize**: Use EXPLAIN to understand query performance

## 📝 Example Queries to Get Started

```sql
-- Quick verification
SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM orders;

-- Simple query
SELECT * FROM employees WHERE department = 'Engineering';

-- Join example
SELECT 
    e.first_name,
    e.last_name,
    d.dept_name,
    d.location
FROM employees e
INNER JOIN departments d ON e.department = d.dept_name;

-- Aggregation example
SELECT 
    department,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;
```

## 🛠️ Troubleshooting

**Problem**: Permission denied when loading CSV
**Solution**: Use `\copy` instead of `COPY` in psql, or make sure the CSV files are readable

**Problem**: Sequence errors when inserting new rows
**Solution**: Run the sequence reset commands from step 6

**Problem**: Foreign key constraint violations
**Solution**: Load tables in the correct order (parent tables before child tables)

## 📚 Next Steps

Once you have the data loaded:
1. Open the tutorial HTML file
2. Work through each section
3. Try the exercises with real data
4. Experiment with your own queries!

## 💡 Additional Resources

- PostgreSQL Documentation: https://www.postgresql.org/docs/
- PostgreSQL Tutorial: https://www.postgresqltutorial.com/
- SQL Practice: https://pgexercises.com/

Happy learning! 🎓
