-- Create `accounts` table
CREATE TABLE accounts (
    account TEXT,
    sector TEXT,
    year_established INT,
    revenue REAL,
    employees INT,
    office_location TEXT,
    subsidiary_of TEXT
);


-- Create `products` table  
CREATE TABLE products (
    product TEXT,
    series TEXT,
    sales_price REAL
);


-- Create `sales_teams` table
CREATE TABLE sales_teams (
    sales_agent TEXT,
    manager TEXT,
    regional_office TEXT
);


-- Create `sales_pipeline` table
CREATE TABLE sales_pipeline (
    opportunity_id TEXT,
    sales_agent TEXT,
    product TEXT,
    account TEXT,
    deal_stage TEXT,
    engage_date DATE,
    close_date DATE,
    close_value REAL
);

