-- Assessment_Q2.sql
-- Transaction Frequency Analysis
-- 1. Calculate number of transactions per user per month
-- 2. Compute average monthly transactions per user
-- 3. Categorize users based on transaction frequency
-- 4. Aggregate results by frequency category


WITH monthly_tx_counts AS (
  -- Count qualifying inflow transactions per user per month
  SELECT 
    s.owner_id AS user_id,
    DATE_FORMAT(s.transaction_date, '%Y-%m') AS tx_month,
    COUNT(*) AS tx_count
  FROM savings_savingsaccount s
  JOIN plans_plan p ON s.plan_id = p.id
  WHERE 
    s.transaction_date IS NOT NULL
    AND s.confirmed_amount > 0                     -- Only actual inflow
    AND p.is_regular_savings = 1                   -- Only regular savings plans
  GROUP BY s.owner_id, DATE_FORMAT(s.transaction_date, '%Y-%m')
),

avg_tx_per_user AS (
  -- Calculate average transactions per user across all months
  SELECT 
    user_id,
    AVG(tx_count) AS avg_tx_per_month
  FROM monthly_tx_counts
  GROUP BY user_id
),

categorized_users AS (
  -- Assign frequency categories based on average monthly transactions
  SELECT 
    user_id,
    avg_tx_per_month,
    CASE 
      WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
      WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category
  FROM avg_tx_per_user
)

-- Final aggregation by frequency category
SELECT 
  frequency_category,
  COUNT(*) AS customer_count,
  ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY 
  FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
