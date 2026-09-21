# PostgreSQL Schemas - Complete Guide

## What is a Schema?

A **schema** is a namespace that contains database objects (tables, views, indexes, functions, etc.). Think of it as a folder that organizes your database objects.

```
Database: tutorial_db
├── Schema: from_zero_to_hero
│   ├── employees
│   ├── departments
│   ├── products
│   └── ...
├── Schema: public (default)
│   ├── some_other_table
│   └── ...
└── Schema: another_project
    └── ...
```

## Why Use Schemas?

1. **Organization**: Group related tables together
2. **Isolation**: Multiple projects in one database without naming conflicts
3. **Security**: Grant permissions per schema
4. **Multi-tenancy**: Separate data for different clients/tenants

## Creating and Using the `from_zero_to_hero` Schema

### Method 1: Use the Enhanced Setup Script

Simply run the `setup_with_schema.sql` file:

```bash
psql -U your_username -d tutorial_db -f setup_with_schema.sql
```

### Method 2: Manual Setup

```sql
-- Create schema
CREATE SCHEMA from_zero_to_hero;

-- Create table in the schema
CREATE TABLE from_zero_to_hero.employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

-- Insert data
INSERT INTO from_zero_to_hero.employees (name) VALUES ('John Doe');
```

## Querying Tables in a Schema

### Option 1: Fully Qualified Names (Always Works)

```sql
-- Use schema_name.table_name
SELECT * FROM from_zero_to_hero.employees;
SELECT * FROM from_zero_to_hero.products;
SELECT * FROM from_zero_to_hero.orders;
```

### Option 2: Set Search Path (Temporary for Session)

```sql
-- Set search path for current session
SET search_path TO from_zero_to_hero, public;

-- Now you can omit the schema prefix
SELECT * FROM employees;
SELECT * FROM products;

-- Check current search path
SHOW search_path;
```

### Option 3: Set Default Search Path (Permanent for User)

```sql
-- Set default search path for a specific user
ALTER USER your_username SET search_path TO from_zero_to_hero, public;

-- Reconnect to apply changes
-- Now every session will use this search path automatically
```

## Search Path Behavior

The `search_path` works like PATH in Unix/Linux. PostgreSQL searches schemas in order:

```sql
SET search_path TO from_zero_to_hero, public;
```

When you run `SELECT * FROM employees;`, PostgreSQL:
1. First looks in `from_zero_to_hero` schema
2. If not found, looks in `public` schema
3. If not found, throws error

## Common Operations

### List All Schemas
```sql
SELECT schema_name 
FROM information_schema.schemata
ORDER BY schema_name;
```

### List All Tables in a Schema
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'from_zero_to_hero'
ORDER BY table_name;
```

### See Current Schema
```sql
SELECT current_schema();
```

### Drop Schema
```sql
-- Drop empty schema
DROP SCHEMA from_zero_to_hero;

-- Drop schema and all objects in it
DROP SCHEMA from_zero_to_hero CASCADE;
```

### Move Table to Different Schema
```sql
ALTER TABLE employees SET SCHEMA another_schema;
```

## Loading CSV Data into Schema

When using `\copy`, specify the schema:

```bash
# In psql, navigate to your datasets folder first
cd /path/to/datasets

# Then run copy commands with schema prefix
\copy from_zero_to_hero.employees(id, first_name, last_name, email, phone_number, hire_date, salary, department, job_title, manager_id, bonus) FROM 'employees.csv' DELIMITER ',' CSV HEADER;

\copy from_zero_to_hero.departments(id, dept_name, location, budget) FROM 'departments.csv' DELIMITER ',' CSV HEADER;

\copy from_zero_to_hero.products(id, name, category, price, cost, stock_quantity, supplier_id, supplier_email, last_restocked) FROM 'products.csv' DELIMITER ',' CSV HEADER;

# ... and so on for all tables
```

## Foreign Keys Across Schemas

Foreign keys work across schemas:

```sql
CREATE TABLE from_zero_to_hero.employees (
    id SERIAL PRIMARY KEY,
    dept_id INTEGER REFERENCES public.departments(id)  -- References table in different schema
);
```

## Complete Workflow Example

```sql
-- 1. Connect to database
psql -U postgres -d tutorial_db

-- 2. Create schema
CREATE SCHEMA from_zero_to_hero;

-- 3. Set search path
SET search_path TO from_zero_to_hero, public;

-- 4. Create tables (run setup script)
\i setup_with_schema.sql

-- 5. Load CSV data
\copy employees(...) FROM 'employees.csv' DELIMITER ',' CSV HEADER;

-- 6. Query without schema prefix
SELECT * FROM employees;

-- 7. Join tables in same schema
SELECT 
    e.first_name,
    d.dept_name
FROM employees e
JOIN departments d ON e.department = d.dept_name;
```

## Best Practices

1. **Always specify schema in production scripts**
   ```sql
   -- Good
   SELECT * FROM from_zero_to_hero.employees;
   
   -- Risky (depends on search_path)
   SELECT * FROM employees;
   ```

2. **Use meaningful schema names**
   - `from_zero_to_hero` - tutorial data
   - `prod_data` - production data
   - `staging` - staging environment
   - `analytics` - analytics/reporting tables

3. **Grant schema-level permissions**
   ```sql
   -- Grant usage on schema
   GRANT USAGE ON SCHEMA from_zero_to_hero TO some_user;
   
   -- Grant select on all tables in schema
   GRANT SELECT ON ALL TABLES IN SCHEMA from_zero_to_hero TO some_user;
   ```

4. **Document your schema structure**
   ```sql
   COMMENT ON SCHEMA from_zero_to_hero IS 'Tutorial database for PostgreSQL learning';
   ```

## Schema vs Database

**When to use schemas:**
- Multiple related projects in one database
- Logical separation within a project
- Multi-tenant applications (one schema per tenant)

**When to use separate databases:**
- Completely independent applications
- Different backup/restore schedules
- Different access control requirements
- Performance isolation needed

## Quick Reference

```sql
-- Create
CREATE SCHEMA from_zero_to_hero;

-- Drop
DROP SCHEMA from_zero_to_hero CASCADE;

-- Set search path (session)
SET search_path TO from_zero_to_hero, public;

-- Set search path (user default)
ALTER USER myuser SET search_path TO from_zero_to_hero, public;

-- Query with schema
SELECT * FROM from_zero_to_hero.employees;

-- View current schema
SELECT current_schema();

-- View search path
SHOW search_path;

-- List all schemas
\dn

-- List tables in schema
\dt from_zero_to_hero.*
```

Happy learning! 🚀
