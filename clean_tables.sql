-- CLEAN ACCOUNTS TABLE 
-- Step 1: Data Exploration
-- Preview the first 5 rows to inspect the data
SELECT *
FROM accounts
LIMIT 5;


-- Step 2: Identify and Correct Unique Values  
-- Check distinct values in the sector column to find inconsistencies  
SELECT DISTINCT sector
FROM accounts;
-- Correct the misspelling in the sector column 
UPDATE accounts
SET sector = 'technology'
WHERE sector = 'technolgy';


-- Step 3: Handle Missing Values
-- Identify rows with missing values in important columns
SELECT *
FROM accounts
WHERE account IS NULL 
      OR sector IS NULL
      OR year_established IS NULL
      OR revenue IS NULL 
      OR employees IS NULL
      OR office_location IS NULL;
-- Remove rows with missing values
DELETE FROM accounts
WHERE account IS NULL 
      OR sector IS NULL
      OR year_established IS NULL
      OR revenue IS NULL
      OR employees IS NULL
      OR office_location IS NULL;


-- Step 4: Handle Duplicates
-- Find duplicates based on the account column 
SELECT account, COUNT(*)
FROM accounts 
GROUP BY account
HAVING COUNT(*) > 1;
-- Remove duplicate rows, keeping only one occurrence of each account
WITH duplicate_rows AS (
    SELECT ctid,
	   account, 
           ROW_NUMBER() OVER (PARTITION BY account ORDER BY ctid) AS row_num
    FROM accounts
)
DELETE FROM accounts
WHERE ctid IN (
    SELECT ctid FROM duplicate_rows WHERE row_num > 1
);


-- Step 4: Trim Whitespace from Text Columns
UPDATE accounts 
SET account = TRIM(account),
    sector = TRIM(sector),
    office_location = TRIM(office_location),
    subsidiary_of = TRIM(subsidiary_of);


-- Step 5: Standardize Capitalization in Text Fields
UPDATE accounts
SET account = INITCAP(account),
    office_location = INITCAP(office_location),
    subsidiary_of = INITCAP(subsidiary_of);


-- Step 6: Validate and Clean Numeric Fields
-- Check for invalid `revenue` or `employees` (non-numeric characters)
SELECT *
FROM accounts
WHERE revenue::TEXT !~ '^\d+(\.\d+)?'
      OR employees::TEXT !~ '^\d+$';
-- Check for unreasonable `year_established` values
SELECT *
FROM accounts
WHERE year_established < 1900
      OR year_established > EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;


-- Step 7: Final Cleanup
-- Ensure there are no more missing values
SELECT * FROM accounts
WHERE account IS NULL
      OR sector IS NULL
      OR revenue IS NULL
      OR employees IS NULL
      OR office_location IS NULL;
-- Ensure there are no more duplicates
SELECT account, COUNT(*)
FROM accounts 
GROUP BY account
HAVING COUNT(*) > 1;


--------------------------------------------------------------------------------------------


-- CLEAN PRODUCTS TABLE 
SELECT *
FROM products;
-- The products table contains only 7 rows, making a full data cleaning process unnecessary. 
-- Instead, I manually inspected the table and found no missing values, duplicates, or incorrect data types. 
-- Since all values are accurate and properly formatted, no further cleaning steps were applied.


--------------------------------------------------------------------------------------------


-- CLEAN SALES_TEAMS TABLE 
SELECT *
FROM sales_teams 
-- The sales_teams table contains only 35 rows, making a full data cleaning process unnecessary. 
-- Instead, I manually inspected the table and found no missing values, duplicates, or incorrect data types. 
-- Since all values are accurate and properly formatted, no further cleaning steps were applied.


---------------------------------------------------------------------------------------------


-- CLEAN SALES_PIPELINE TABLE 
-- Step 1: Data Exploration
-- Preview the first 5 rows to inspect the data
SELECT * 
FROM sales_pipeline
LIMIT 5;


-- Step 2: Handle Missing Values
-- Count of total rows and missing values 
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN opportunity_id IS NULL THEN 1 ELSE 0 END) AS missing_opp_id,
    SUM(CASE WHEN sales_agent IS NULL THEN 1 ELSE 0 END) AS missing_sales_agent,
    SUM(CASE WHEN product IS NULL THEN 1 ELSE 0 END) AS missing_product,
    SUM(CASE WHEN account IS NULL THEN 1 ELSE 0 END) AS missing_account,
    SUM(CASE WHEN deal_stage IS NULL THEN 1 ELSE 0 END) AS missing_deal_stage,
    SUM(CASE WHEN engage_date IS NULL THEN 1 ELSE 0 END) AS missing_engage_date,
    SUM(CASE WHEN close_date IS NULL THEN 1 ELSE 0 END) AS missing_close_date,
    SUM(CASE WHEN close_value IS NULL THEN 1 ELSE 0 END) AS missing_close_value
FROM sales_pipeline;
-- Impute missing values in account with 'MISSING_ACCOUNT'
UPDATE sales_pipeline
SET account = 'Missing_Account'
WHERE account IS NULL;
-- Create `engage_status` field based on `engage_date`
-- The `engage_status` field indicates the engagement state:
-- 'Not Engaged' for records with a NULL `engage_date`
-- 'Engaged' for records with a non-NULL `engage_date`
ALTER TABLE sales_pipeline ADD COLUMN engage_status VARCHAR(20);
UPDATE sales_pipeline
SET engage_status = 
    CASE
        WHEN engage_date IS NULL THEN 'Not Engaged'
	ELSE 'Engaged'
    END;
-- Create `close_status` field based on `close_date`
-- The `close_status` field reflects the current status of the deal:
-- 'Open' for records with a NULL `close_date`
-- 'Closed' for records with a non-NULL `close_date`
ALTER TABLE sales_pipeline ADD COLUMN close_status VARCHAR(20);
UPDATE sales_pipeline
SET close_status = 
    CASE
        WHEN close_date IS NULL THEN 'Open'
	ELSE 'Closed'
    END;
-- Note: Both `close_date` and `close_value` have the same number of missing values.
-- This might suggest that deals with missing `close_date` are still in progress or haven't been closed yet.


-- Step 3: Remove Duplicate Opportunities (if any)
-- Remove duplicate records based on `opportunity_id`, keeping only the first occurrence of each opportunity
DELETE FROM sales_pipeline
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM sales_pipeline
    GROUP BY opportunity_id
);


-- Step 4: Trim Whitespaces from Text Columns
UPDATE sales_pipeline
SET sales_agent = TRIM(sales_agent),
    product = TRIM(product),
    account = TRIM(account),
    deal_stage = TRIM(deal_stage);


-- Step 5: Standardize Capitalization in Text Fields
UPDATE sales_pipeline
SET sales_agent = INITCAP(sales_agent),
    account = INITCAP(account),
    deal_stage = INITCAP(deal_stage);
	

-- Step 6: Correct Typos in Product Names
-- Review distinct product names in the sales_pipeline table to identify typos
SELECT DISTINCT product
FROM sales_pipeline;
-- Review distinct product names in the products table for comparison
SELECT DISTINCT product
FROM products;
-- Update product names in the sales_pipeline table by correcting the identified typo
UPDATE sales_pipeline
SET product = REPLACE(product, 'GTXPro', 'GTX Pro');


-- Step 7: Retrieve Distinct Values in `deal_stage`
-- Retrieve all distinct values of deal_stage to understand available categories
SELECT DISTINCT deal_stage 
FROM sales_pipeline;


-- Step 8: Check for Negative Values in `close_value`
SELECT *
FROM sales_pipeline
WHERE close_value < 0;


-- Step 9: Check for Logical Errors
-- If close_date happens before engage_date, it may indicate an error
SELECT *
FROM sales_pipeline
WHERE close_date < engage_date;


-- Step 10: Calculate Summary Statistics for Deal Values
-- Retrieve the average, minimum, and maximum values of the `close_value`
SELECT AVG(close_value) AS avg_value, 
       MIN(close_value) AS min_value, 
       MAX(close_value) AS max_value
FROM sales_pipeline;


-- Step 11: Add and Populate a New Field for Quarterly Classification Based on `close_date`
ALTER TABLE sales_pipeline ADD COLUMN quarter VARCHAR(20);
UPDATE sales_pipeline
SET quarter =
    CASE
        WHEN EXTRACT(MONTH FROM close_date) BETWEEN 1 AND 3 THEN 'Q1'
	WHEN EXTRACT(MONTH FROM close_date) BETWEEN 4 AND 6 THEN 'Q2'
	WHEN EXTRACT(MONTH FROM close_date) BETWEEN 7 AND 9 THEN 'Q3'
	WHEN EXTRACT(MONTH FROM close_date) BETWEEN 10 AND 12 THEN 'Q4'
    END;


