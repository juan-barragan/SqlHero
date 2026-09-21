-- PostgreSQL Tutorial - Database Setup Script with Schema
-- This script creates all tables in the 'from_zero_to_hero' schema

-- ==============================================================================
-- SCHEMA CREATION
-- ==============================================================================

-- Drop schema if exists (CASCADE removes all objects in it)
DROP SCHEMA IF EXISTS from_zero_to_hero CASCADE;

-- Create the schema
CREATE SCHEMA from_zero_to_hero;

-- Set search path to use this schema by default
SET search_path TO from_zero_to_hero, public;

-- Verify current schema
SELECT current_schema();

-- ==============================================================================
-- SECTION 1: BASIC TABLES (For exercises 1-3)
-- ==============================================================================

-- Employees Table
CREATE TABLE from_zero_to_hero.employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    department VARCHAR(50) NOT NULL,
    job_title VARCHAR(100),
    manager_id INTEGER,
    bonus NUMERIC(10, 2),
    FOREIGN KEY (manager_id) REFERENCES from_zero_to_hero.employees(id)
);

-- Departments Table
CREATE TABLE from_zero_to_hero.departments (
    id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(100),
    budget NUMERIC(12, 2)
);

-- Products Table
CREATE TABLE from_zero_to_hero.products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    cost NUMERIC(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    supplier_id INTEGER,
    supplier_email VARCHAR(100),
    last_restocked DATE
);

-- Sales Representatives Table
CREATE TABLE from_zero_to_hero.sales_reps (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    total_sales NUMERIC(12, 2) NOT NULL DEFAULT 0,
    customer_count INTEGER NOT NULL DEFAULT 0,
    join_date DATE NOT NULL
);

-- ==============================================================================
-- SECTION 2: E-COMMERCE TABLES (For exercises 4-5 and Capstone)
-- ==============================================================================

-- Customers Table
CREATE TABLE from_zero_to_hero.customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    signup_date DATE NOT NULL
);

-- Suppliers Table
CREATE TABLE from_zero_to_hero.suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100),
    rating NUMERIC(3, 2) CHECK (rating >= 0 AND rating <= 5)
);

-- Orders Table
CREATE TABLE from_zero_to_hero.orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10, 2),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    shipping_cost NUMERIC(8, 2) DEFAULT 0,
    product_category VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES from_zero_to_hero.customers(id)
);

-- Order Items Table
CREATE TABLE from_zero_to_hero.order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    customer_id INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES from_zero_to_hero.orders(id),
    FOREIGN KEY (product_id) REFERENCES from_zero_to_hero.products(id),
    FOREIGN KEY (customer_id) REFERENCES from_zero_to_hero.customers(id)
);

-- Reviews Table
CREATE TABLE from_zero_to_hero.reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_date DATE NOT NULL,
    review_text TEXT,
    FOREIGN KEY (product_id) REFERENCES from_zero_to_hero.products(id),
    FOREIGN KEY (customer_id) REFERENCES from_zero_to_hero.customers(id)
);

-- ==============================================================================
-- SECTION 3: ANALYTICS TABLES (For exercises 6-8)
-- ==============================================================================

-- Monthly Sales Table
CREATE TABLE from_zero_to_hero.monthly_sales (
    id SERIAL PRIMARY KEY,
    month DATE NOT NULL,
    salesperson VARCHAR(100) NOT NULL,
    revenue NUMERIC(12, 2) NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- Transactions Table
CREATE TABLE from_zero_to_hero.transactions (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    transaction_date DATE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    category VARCHAR(50),
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('completed', 'failed', 'pending'))
);

-- Projects Table
CREATE TABLE from_zero_to_hero.projects (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL,
    employee_id INTEGER,
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMERIC(12, 2),
    status VARCHAR(20) DEFAULT 'planning' CHECK (status IN ('planning', 'in_progress', 'completed', 'on_hold')),
    FOREIGN KEY (employee_id) REFERENCES from_zero_to_hero.employees(id)
);

-- ==============================================================================
-- DATA LOADING COMMANDS
-- ==============================================================================

-- IMPORTANT: Update the file paths below to match where you saved the CSV files
-- For example, if you saved them in /home/user/datasets/, update the path accordingly

-- Method 1: Using COPY command (requires superuser privileges or appropriate permissions)
-- Replace '/path/to/datasets/' with your actual path

/*
COPY from_zero_to_hero.employees(id, first_name, last_name, email, phone_number, hire_date, salary, department, job_title, manager_id, bonus)
FROM '/path/to/datasets/employees.csv' 
DELIMITER ',' 
CSV HEADER;

COPY from_zero_to_hero.departments(id, dept_name, location, budget)
FROM '/path/to/datasets/departments.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.products(id, name, category, price, cost, stock_quantity, supplier_id, supplier_email, last_restocked)
FROM '/path/to/datasets/products.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.sales_reps(id, name, region, total_sales, customer_count, join_date)
FROM '/path/to/datasets/sales_reps.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.customers(id, name, email, city, country, signup_date)
FROM '/path/to/datasets/customers.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.suppliers(id, name, country, rating)
FROM '/path/to/datasets/suppliers.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.orders(id, customer_id, order_date, total_amount, status, shipping_cost, product_category)
FROM '/path/to/datasets/orders.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.order_items(id, order_id, product_id, quantity, unit_price, customer_id)
FROM '/path/to/datasets/order_items.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.reviews(id, product_id, customer_id, rating, review_date, review_text)
FROM '/path/to/datasets/reviews.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.monthly_sales(month, salesperson, revenue, region)
FROM '/path/to/datasets/monthly_sales.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.transactions(id, customer_id, transaction_date, amount, category, status)
FROM '/path/to/datasets/transactions.csv'
DELIMITER ','
CSV HEADER;

COPY from_zero_to_hero.projects(id, project_name, employee_id, start_date, end_date, budget, status)
FROM '/path/to/datasets/projects.csv'
DELIMITER ','
CSV HEADER;
*/

-- Method 2: Using \copy command in psql (works without superuser)
-- Run these commands in psql terminal:
/*
\copy from_zero_to_hero.employees(id, first_name, last_name, email, phone_number, hire_date, salary, department, job_title, manager_id, bonus) FROM 'employees.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.departments(id, dept_name, location, budget) FROM 'departments.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.products(id, name, category, price, cost, stock_quantity, supplier_id, supplier_email, last_restocked) FROM 'products.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.sales_reps(id, name, region, total_sales, customer_count, join_date) FROM 'sales_reps.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.customers(id, name, email, city, country, signup_date) FROM 'customers.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.suppliers(id, name, country, rating) FROM 'suppliers.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.orders(id, customer_id, order_date, total_amount, status, shipping_cost, product_category) FROM 'orders.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.order_items(id, order_id, product_id, quantity, unit_price, customer_id) FROM 'order_items.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.reviews(id, product_id, customer_id, rating, review_date, review_text) FROM 'reviews.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.monthly_sales(month, salesperson, revenue, region) FROM 'monthly_sales.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.transactions(id, customer_id, transaction_date, amount, category, status) FROM 'transactions.csv' DELIMITER ',' CSV HEADER;
\copy from_zero_to_hero.projects(id, project_name, employee_id, start_date, end_date, budget, status) FROM 'projects.csv' DELIMITER ',' CSV HEADER;
*/

-- ==============================================================================
-- UPDATE SEQUENCES (Important: Run this after loading data)
-- ==============================================================================

-- Reset sequences to match the loaded data
SELECT setval('from_zero_to_hero.employees_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.employees));
SELECT setval('from_zero_to_hero.departments_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.departments));
SELECT setval('from_zero_to_hero.products_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.products));
SELECT setval('from_zero_to_hero.sales_reps_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.sales_reps));
SELECT setval('from_zero_to_hero.customers_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.customers));
SELECT setval('from_zero_to_hero.suppliers_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.suppliers));
SELECT setval('from_zero_to_hero.orders_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.orders));
SELECT setval('from_zero_to_hero.order_items_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.order_items));
SELECT setval('from_zero_to_hero.reviews_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.reviews));
SELECT setval('from_zero_to_hero.monthly_sales_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.monthly_sales));
SELECT setval('from_zero_to_hero.transactions_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.transactions));
SELECT setval('from_zero_to_hero.projects_id_seq', (SELECT MAX(id) FROM from_zero_to_hero.projects));

-- ==============================================================================
-- CREATE INDEXES (For performance - Section 9)
-- ==============================================================================

-- Foreign key indexes
CREATE INDEX idx_employees_manager ON from_zero_to_hero.employees(manager_id);
CREATE INDEX idx_employees_department ON from_zero_to_hero.employees(department);
CREATE INDEX idx_orders_customer ON from_zero_to_hero.orders(customer_id);
CREATE INDEX idx_order_items_order ON from_zero_to_hero.order_items(order_id);
CREATE INDEX idx_order_items_product ON from_zero_to_hero.order_items(product_id);
CREATE INDEX idx_reviews_product ON from_zero_to_hero.reviews(product_id);
CREATE INDEX idx_reviews_customer ON from_zero_to_hero.reviews(customer_id);
CREATE INDEX idx_projects_employee ON from_zero_to_hero.projects(employee_id);

-- Query optimization indexes
CREATE INDEX idx_employees_hire_date ON from_zero_to_hero.employees(hire_date);
CREATE INDEX idx_employees_salary ON from_zero_to_hero.employees(salary);
CREATE INDEX idx_orders_date ON from_zero_to_hero.orders(order_date);
CREATE INDEX idx_orders_status ON from_zero_to_hero.orders(status);
CREATE INDEX idx_products_category ON from_zero_to_hero.products(category);
CREATE INDEX idx_transactions_date ON from_zero_to_hero.transactions(transaction_date);
CREATE INDEX idx_monthly_sales_month ON from_zero_to_hero.monthly_sales(month);

-- Composite indexes
CREATE INDEX idx_employees_dept_salary ON from_zero_to_hero.employees(department, salary);
CREATE INDEX idx_orders_customer_date ON from_zero_to_hero.orders(customer_id, order_date);

-- ==============================================================================
-- VERIFICATION QUERIES
-- ==============================================================================

-- Check row counts
SELECT 'employees' as table_name, COUNT(*) as row_count FROM from_zero_to_hero.employees
UNION ALL
SELECT 'departments', COUNT(*) FROM from_zero_to_hero.departments
UNION ALL
SELECT 'products', COUNT(*) FROM from_zero_to_hero.products
UNION ALL
SELECT 'sales_reps', COUNT(*) FROM from_zero_to_hero.sales_reps
UNION ALL
SELECT 'customers', COUNT(*) FROM from_zero_to_hero.customers
UNION ALL
SELECT 'suppliers', COUNT(*) FROM from_zero_to_hero.suppliers
UNION ALL
SELECT 'orders', COUNT(*) FROM from_zero_to_hero.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM from_zero_to_hero.order_items
UNION ALL
SELECT 'reviews', COUNT(*) FROM from_zero_to_hero.reviews
UNION ALL
SELECT 'monthly_sales', COUNT(*) FROM from_zero_to_hero.monthly_sales
UNION ALL
SELECT 'transactions', COUNT(*) FROM from_zero_to_hero.transactions
UNION ALL
SELECT 'projects', COUNT(*) FROM from_zero_to_hero.projects
ORDER BY table_name;

-- List all tables in the schema
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'from_zero_to_hero'
ORDER BY table_name;

-- Sample data check
SELECT 'Sample Employees:' as info;
SELECT * FROM from_zero_to_hero.employees LIMIT 5;

SELECT 'Sample Orders:' as info;
SELECT * FROM from_zero_to_hero.orders LIMIT 5;

SELECT 'Sample Products:' as info;
SELECT * FROM from_zero_to_hero.products LIMIT 5;

-- ==============================================================================
-- SCHEMA USAGE EXAMPLES
-- ==============================================================================

-- Now you can query tables in three ways:

-- 1. Using fully qualified names (always works)
SELECT * FROM from_zero_to_hero.employees;

-- 2. Set search_path for your session
SET search_path TO from_zero_to_hero, public;
SELECT * FROM employees;  -- No schema prefix needed!

-- 3. Set default search_path for a specific user
-- ALTER USER your_username SET search_path TO from_zero_to_hero, public;

COMMIT;