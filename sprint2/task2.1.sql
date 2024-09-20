USE transactions;

-- Level 1. 
-- Exercise 2 (using JOIN).
-- Countries that make purchases.
SELECT DISTINCT c.country
FROM company as c
JOIN transaction as t ON t.company_id = c.id;

-- From how many countries the purchases are made.
SELECT count(DISTINCT c.country)
FROM company as c
JOIN transaction as t ON t.company_id = c.id;

-- Company with the highest average sales.
SELECT c.company_name, round(AVG(t.amount),2) as average_sales
FROM company as c
JOIN transaction as t ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.company_name
ORDER BY average_sales DESC
LIMIT 1;

-- Exercise 3 (subqueries without using JOIN).
-- All transactions made by companies in Germany.
SELECT * 
FROM transaction
WHERE company_id IN (SELECT id FROM company WHERE country = 'Germany');

-- Companies that have made transactions for an amount higher than the average of all transactions.
SELECT *
FROM company
WHERE id IN (SELECT company_id FROM transaction WHERE amount > (SELECT AVG(amount) FROM transaction));

-- Companies that do not have registered transactions
SELECT *
FROM company
WHERE id NOT IN (SELECT DISTINCT company_id from transaction);

-- Level 2.
-- Exercise 1. Five days that generated the largest amount of revenue for the company. 
-- Date of each transaction along with the total sales
select date(timestamp) as date, sum(amount) as total_sales
from transaction
where declined = 0
group by date(timestamp)
order by total_sales desc
limit 5;
 
-- Exercise 2. Average sales per country. 
-- Results are sorted from highest to lowest average sale.
select c.country, round(AVG(t.amount), 2) as average_sales
from transaction as t 
join company as c on t.company_id=c.id
where t.declined = 0
group by c.country
order by average_sales desc;

-- Excercise 3. Transactions carried out by companies that are located in the same country as "Non Institute" company.
-- Using subqueries
select *
from transaction
where company_id IN (
select id
from company
where country = (select country from company where company_name = 'Non Institute') 
and company_name != 'Non Institute')
order by id;

-- Using JOIN and subqueries
select t.*
from transaction as t
join company as c on t.company_id=c.id
where country = (select country from company where company_name = 'Non Institute')
and company_name != 'Non Institute'
order by id;

-- Level 3.
-- Exercise 1. Companies (name, telephone, country, date and amount) that made transactions with a value between 100 and 200 euros 
-- and on any of these dates: April 29, 2021, July 20, 2021 and March 13, 2022. 
-- Results are sirted from highest to lowest amount. 
select c.company_name, c.phone, c.country, date(t.timestamp) as date, t.amount
from company as c
join transaction as t on t.company_id=c.id
where t.amount between 100 and 200
and date(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
order by t.amount desc;

-- Amount of transactions that the companies carry out, specifing if they have more than 4 transactions or less
select c.company_name, count(t.id) as number_transactions,
CASE
    when count(t.id) > 4 then 1
    else 0
END as more_then_4_transactions
from company as c
left join transaction as t on t.company_id=c.id
group by c.company_name
order by number_transactions desc;