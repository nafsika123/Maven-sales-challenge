CREATE VIEW combined_sales_data AS
SELECT
    sp.opportunity_id,
    sp.sales_agent,
    sp.product,
    sp.account,
    sp.deal_stage,
    sp.engage_date,
    sp.close_date,
    sp.close_value,
    sp.engage_status,
    sp.close_status,
    sp.quarter,
    a.sector,
    a.year_established,
    a.revenue,
    a.employees,
    a.office_location,
    a.subsidiary_of,
    p.series,
    p.sales_price,
    st.manager,
    st.regional_office
FROM sales_pipeline AS sp
LEFT JOIN accounts AS a ON sp.account = a.account
LEFT JOIN products AS p ON sp.product = p.product 
LEFT JOIN sales_teams AS st ON sp.sales_agent = st.sales_agent;


-- Verification of Missing Values Introduced in Right Tables Due to Left Join Operation
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN sector IS NULL THEN 1 ELSE 0 END) AS missing_sector,
    SUM(CASE WHEN year_established IS NULL THEN 1 ELSE 0 END) AS missing_year_established,
    SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS missing_revenue,
    SUM(CASE WHEN employees IS NULL THEN 1 ELSE 0 END) AS missing_employees,
    SUM(CASE WHEN office_location IS NULL THEN 1 ELSE 0 END) AS missing_office_location,
    SUM(CASE WHEN series IS NULL THEN 1 ELSE 0 END) AS missing_series,
    SUM(CASE WHEN sales_price IS NULL THEN 1 ELSE 0 END) AS missing_sales_price,
    SUM(CASE WHEN manager IS NULL THEN 1 ELSE 0 END) AS missing_manager,
    SUM(CASE WHEN regional_office IS NULL THEN 1 ELSE 0 END) AS missing_regional_office
FROM combined_sales_data;


-- Check if the 1425 missing values in the fields of the accounts table are associated with 
-- the presence of 'MISSING_ACCOUNT' in the account field of the left table
SELECT 
    SUM(CASE 
        WHEN sector IS NULL 
        AND year_established IS NULL 
        AND revenue IS NULL 
        AND employees IS NULL 
        AND office_location IS NULL 
        AND account = 'Missing_Account' 
        THEN 1 ELSE 0 END) AS missing_values_for_missing_account
FROM combined_sales_data;

