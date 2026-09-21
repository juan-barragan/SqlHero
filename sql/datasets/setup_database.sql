-- PostgreSQL Tutorial - Database Setup Script
-- This script creates all tables and provides commands to load the CSV data

-- ==============================================================================
-- SECTION 1: BASIC TABLES (For exercises 1-3)
-- ==============================================================================

-- Employees Table
DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees (
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
    FOREIGN KEY (manager_id) REFERENCES employees(id)
);

-- Departments Table
DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(100),
    budget NUMERIC(12, 2)
);

-- Products Table
DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE products (
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
DROP TABLE IF EXISTS sales_reps CASCADE;
CREATE TABLE sales_reps (
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
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    signup_date DATE NOT NULL
);

-- Suppliers Table
DROP TABLE IF EXISTS suppliers CASCADE;
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100),
    rating NUMERIC(3, 2) CHECK (rating >= 0 AND rating <= 5)
);

-- Orders Table
DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10, 2),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    shipping_cost NUMERIC(8, 2) DEFAULT 0,
    product_category VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Order Items Table
DROP TABLE IF EXISTS order_items CASCADE;
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    customer_id INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Reviews Table
DROP TABLE IF EXISTS reviews CASCADE;
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_date DATE NOT NULL,
    review_text TEXT,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- ==============================================================================
-- SECTION 3: ANALYTICS TABLES (For exercises 6-8)
-- ==============================================================================

-- Monthly Sales Table
DROP TABLE IF EXISTS monthly_sales CASCADE;
CREATE TABLE monthly_sales (
    id SERIAL PRIMARY KEY,
    month DATE NOT NULL,
    salesperson VARCHAR(100) NOT NULL,
    revenue NUMERIC(12, 2) NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- Transactions Table
DROP TABLE IF EXISTS transactions CASCADE;
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    transaction_date DATE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    category VARCHAR(50),
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('completed', 'failed', 'pending'))
);

-- Projects Table
DROP TABLE IF EXISTS projects CASCADE;
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL,
    employee_id INTEGER,
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMERIC(12, 2),
    status VARCHAR(20) DEFAULT 'planning' CHECK (status IN ('planning', 'in_progress', 'completed', 'on_hold')),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- ==============================================================================
-- DATA LOADING COMMANDS
-- ==============================================================================

-- IMPORTANT: Update the file paths below to match where you saved the CSV files
-- For example, if you saved them in /home/user/datasets/, update the path accordingly

-- Method 1: Using COPY command (requires superuser privileges or appropriate permissions)
-- Replace '/path/to/datasets/' with your actual path

/*
COPY employees(id, first_name, last_name, email, phone_number, hire_date, salary, department, job_title, manager_id, bonus)
FROM '/path/to/datasets/employees.csv' 
DELIMITER ',' 
CSV HEADER;

COPY departments(id, dept_name, location, budget)
FROM '/path/to/datasets/departments.csv'
DELIMITER ','
CSV HEADER;

COPY products(id, name, category, price, cost, stock_quantity, supplier_id, supplier_email, last_restocked)
FROM '/path/to/datasets/products.csv'
DELIMITER ','
CSV HEADER;

COPY sales_reps(id, name, region, total_sales, customer_count, join_date)
FROM '/path/to/datasets/sales_reps.csv'
DELIMITER ','
CSV HEADER;

COPY customers(id, name, email, city, country, signup_date)
FROM '/path/to/datasets/customers.csv'
DELIMITER ','
CSV HEADER;

COPY suppliers(id, name, country, rating)
FROM '/path/to/datasets/suppliers.csv'
DELIMITER ','
CSV HEADER;

COPY orders(id, customer_id, order_date, total_amount, status, shipping_cost, product_category)
FROM '/path/to/datasets/orders.csv'
DELIMITER ','
CSV HEADER;

COPY order_items(id, order_id, product_id, quantity, unit_price, customer_id)
FROM '/path/to/datasets/order_items.csv'
DELIMITER ','
CSV HEADER;

COPY reviews(id, product_id, customer_id, rating, review_date, review_text)
FROM '/path/to/datasets/reviews.csv'
DELIMITER ','
CSV HEADER;

COPY monthly_sales(month, salesperson, revenue, region)
FROM '/path/to/datasets/monthly_sales.csv'
DELIMITER ','
CSV HEADER;

COPY transactions(id, customer_id, transaction_date, amount, category, status)
FROM '/path/to/datasets/transactions.csv'
DELIMITER ','
CSV HEADER;

COPY projects(id, project_name, employee_id, start_date, end_date, budget, status)
FROM '/path/to/datasets/projects.csv'
DELIMITER ','
CSV HEADER;
*/

-- Method 2: Using \copy command in psql (works without superuser)
-- Run these commands in psql terminal:
/*
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
*/

-- ==============================================================================
-- UPDATE SEQUENCES (Important: Run this after loading data)
-- ==============================================================================

-- Reset sequences to match the loaded data
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

-- ==============================================================================
-- CREATE INDEXES (For performance - Section 9)
-- ==============================================================================

-- Foreign key indexes
CREATE INDEX idx_employees_manager ON employees(manager_id);
CREATE INDEX idx_employees_department ON employees(department);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);
CREATE INDEX idx_projects_employee ON projects(employee_id);

-- Query optimization indexes
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_monthly_sales_month ON monthly_sales(month);

-- Composite indexes
CREATE INDEX idx_employees_dept_salary ON employees(department, salary);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- ==============================================================================
-- VERIFICATION QUERIES
-- ==============================================================================

-- Check row counts
SELECT 'employees' as table_name, COUNT(*) as row_count FROM employees
UNION ALL
SELECT 'departments', COUNT(*) FROM departments
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sales_reps', COUNT(*) FROM sales_reps
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'monthly_sales', COUNT(*) FROM monthly_sales
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'projects', COUNT(*) FROM projects
ORDER BY table_name;

-- Sample data check
SELECT 'Sample Employees:' as info;
SELECT * FROM employees LIMIT 5;

SELECT 'Sample Orders:' as info;
SELECT * FROM orders LIMIT 5;

SELECT 'Sample Products:' as info;
SELECT * FROM products LIMIT 5;

COMMIT;