-- Assessment_Q1.sql
-- High-Value Customers with Multiple Products

-- This query identifies customers who have both a savings and an investment plan
-- and sorts them by total deposit amount in descending order.

SELECT 
    u.id AS owner_id,  -- Unique identifier of the user
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full customer name
    s.savings_count,  -- Count of savings plans owned by the customer
    i.investment_count,  -- Count of investment plans owned by the customer
    ROUND(IFNULL(d.total_deposits, 0) / 100, 2) AS total_deposits  -- Total deposit amount converted from kobo to currency format
FROM users_customuser u

-- Find customers who have savings plans
INNER JOIN (
    SELECT owner_id, COUNT(*) AS savings_count
    FROM plans_plan
    WHERE is_regular_savings = 1  -- Filter for savings plans
    GROUP BY owner_id
) s ON u.id = s.owner_id

-- Find customers who have investment plans
INNER JOIN (
    SELECT owner_id, COUNT(*) AS investment_count
    FROM plans_plan
    WHERE is_a_fund = 1  -- Filter for investment plans
    GROUP BY owner_id
) i ON u.id = i.owner_id

-- Calculate total deposits for each customer
LEFT JOIN (
    SELECT owner_id, SUM(confirmed_amount) AS total_deposits
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0  -- Ensure deposits are funded
    GROUP BY owner_id
) d ON u.id = d.owner_id

-- Sorting results by total deposits in descending order
ORDER BY total_deposits DESC;
