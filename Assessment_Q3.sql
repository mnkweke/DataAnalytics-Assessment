-- Assessment_Q3.sql
-- Account Inactivity Alert: Identify accounts with no transactions in the last 365 days

WITH active_accounts AS (
  SELECT DISTINCT
    sa.savings_id,   
    sa.owner_id,     
    sa.plan_id       
  FROM savings_savingsaccount sa
  JOIN plans_plan p ON sa.plan_id = p.id
  WHERE p.is_deleted = 0 AND p.status_id = 1  -- Ensure the plan is active
)

SELECT 
  aa.plan_id,  
  aa.owner_id, 
  CASE 
    WHEN p.is_regular_savings = 1 THEN 'Savings'  
    WHEN p.is_a_fund = 1 THEN 'Investment'  
    ELSE 'Other'  
  END AS type,  
  COALESCE(MAX(sa.transaction_date), '1900-01-01') AS last_transaction_date,  -- Ensure no NULLs
  COALESCE(DATEDIFF(NOW(), MAX(sa.transaction_date)), 9999) AS inactivity_days  -- Compute correct inactivity days
FROM active_accounts aa

LEFT JOIN savings_savingsaccount sa  
  ON aa.savings_id = sa.savings_id 
  AND sa.confirmed_amount > 0  -- Ensure transactions are actual inflows

JOIN plans_plan p ON aa.plan_id = p.id

-- Ensure grouping is structured properly
GROUP BY aa.plan_id, aa.owner_id, type  

-- Sorting results by plan ID
ORDER BY plan_id;