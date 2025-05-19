-- Assessment_Q4.sql
-- Customer Lifetime Value (CLV) Estimation
-- Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
-- Account tenure (months since signup), Total transactions, Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction), Order by estimated CLV from highest to lowest
-- Tables: users_customuser & savings_savingsaccount

SELECT 
    u.id AS customer_id,  -- Selecting user ID as the customer's unique identifier
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full customer name, combining first and last name
    TIMESTAMPDIFF(MONTH, u.date_joined, NOW()) AS tenure_months,  -- Calculating account tenure in months
    COUNT(s.id) AS total_transactions,  -- Counting the total number of transactions for each user
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, NOW()), 0)) * 12 * 
        (0.001 * SUM(s.confirmed_amount) / COUNT(s.id)), 1  -- Applying CLV formula and rounding to 1 decimal place
    ) AS estimated_clv
FROM users_customuser u
LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id  -- Joining savings transactions with user details
WHERE s.plan_id IS NOT NULL  -- Ensuring only valid transactions linked to a plan are considered
GROUP BY u.id, name, tenure_months  -- Grouping by each unique customer
ORDER BY estimated_clv DESC;  -- Sorting customers from highest to lowest estimated CLV