USE transactions;

-- Table 'company'
-- Number companies 
select count(*)
from company;

-- Number of company names
select count(company_name), count(DISTINCT company_name)
from company;

-- If there are companies with the same name (company names repeat)
select company_name, count(id) as repeat_number
from company
group by company_name
having repeat_number > 1;

-- Number of non-missing values
select count(phone), count(email), count(website)
from company;

-- Number of missing values
select
    sum(case when phone is null then 1 else 0 end) as phone_null_count,
    sum(case when email is null then 1 else 0 end) as email_null_count,
    sum(case when website is null then 1 else 0 end) as website_null_count
from company;

-- Table 'transaction'
-- period of time
select min(date(timestamp)) as first_date, max(date(timestamp)) as last_date
from transaction;

-- Number of transactions 
select count(*) as total_number,
count(*)-sum(declined) as successful_number,
sum(declined) as declined_number, 
round(sum(declined)/count(*)*100, 0) as declined_percentage
from transaction;

-- number of companies that have registered transactions
select count(DISTINCT company_id)
from transaction;

SELECT *
FROM company
WHERE id NOT IN (SELECT DISTINCT company_id from transaction);

-- Number of non-missing values
select count(*) as total_rows, count(credit_card_id), count(company_id), 
       count(user_id), count(timestamp), count(amount)
from transaction;