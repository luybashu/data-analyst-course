-- Level 1
-- create and populare database
CREATE DATABASE IF NOT EXISTS transactions_db;

USE transactions_db;

-- create table 'companies'
CREATE TABLE IF NOT EXISTS companies (
    company_id VARCHAR(20),
    company_name VARCHAR(255),
    phone VARCHAR(30),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

-- load data from companies.csv file
LOAD DATA
INFILE '/usr/local/mysql/data/transactions_db/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add primary key to table companies
alter table companies add primary key (company_id);

-- create table credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
    credit_card_id VARCHAR(15),
    user_id INT,
    iban VARCHAR(35),
    pan VARCHAR(20),
    pin CHAR(4),
    cvv CHAR(4),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(10)
);

-- load data from credit_cards.csv file
LOAD DATA
INFILE '/usr/local/mysql/data/transactions_db/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add primary key to table credit_cards
alter table credit_cards add primary key (credit_card_id);

-- create table users
CREATE TABLE IF NOT EXISTS users (
    user_id INT,
    user_name VARCHAR(100),
    user_surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(10),
    address VARCHAR(255)
);

-- load data from users_usa.csv file
LOAD DATA
INFILE '/usr/local/mysql/data/transactions_db/users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- load data from users_uk.csv file
LOAD DATA
INFILE '/usr/local/mysql/data/transactions_db/users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- load data from users_ca.csv file
LOAD DATA
INFILE '/usr/local/mysql/data/transactions_db/users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- add primary key to table users
alter table users add primary key (user_id);

-- create table transactions
CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(255),
	credit_card_id VARCHAR(15),
	company_id VARCHAR(20), 
	transaction_date TIMESTAMP,
	amount DECIMAL(10, 2),
	declined BOOLEAN,
	product_ids varchar (255),
	user_id INT,
	lat FLOAT,
	longitude FLOAT
    );

-- load data from transactions.csv file
LOAD DATA
INFILE '/usr/local/mysql/data/transactions_db/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- add primary key and foreign keys to table transaction
alter table transactions add primary key (id),
add foreign key (company_id) references companies(company_id), 
add foreign key (credit_card_id) references credit_cards(credit_card_id),
add foreign key (user_id) references users(user_id);

-- Exercise 1
-- Users with more than 30 transactions
select *
from users
where user_id IN (select u.user_id
from users as u 
join transactions as t on (u.user_id=t.user_id)
group by u.user_id
having count(t.id) > 30);

-- Exercise 2
-- Average amount by IBAN of the credit cards in the Donec Ltd company
select cc.iban, round(avg(t.amount), 2) as avg_amount
from credit_cards as cc
join transactions as t on (cc.credit_card_id=t.credit_card_id)
where t.company_id = (select company_id from companies where company_name = 'Donec Ltd')
group by cc.iban;


-- Level 2
-- Table that reflects the credit card status based on whether the last three transactions were declined 
create view credit_card_status as

with transactions_order as 
(select credit_card_id, transaction_date, declined, 
row_number() over(partition by credit_card_id order by transaction_date desc) as trans_order,
datediff(max(transaction_date) over(), transaction_date) as days_inactive
from transactions)

select credit_card_id, 
case
    -- inactive because last three transactions were declined
    when sum(declined) = 3 then 0  
    -- only two transactions, last one occurred > 8 months ago
    when count(declined) = 2 and MAX(case when trans_order = 1 then days_inactive end) > 240 then 0
    -- only one transaction performed > 6 months ago
    when count(declined) = 1 and MAX(days_inactive) > 180 then 0
    else 1 
end as is_active
from transactions_order
where trans_order <=3
group by credit_card_id;

select * from credit_card_status;

-- Exercise 1
-- How many credit cards are active?
select count(*) as credit_card_number, sum(is_active) as active_credit_card_number
from credit_card_status;

-- Level 3
-- create table products
CREATE TABLE IF NOT EXISTS products (
    product_id INT,
    product_name VARCHAR(255),
    price VARCHAR(30), 
    colour VARCHAR(30),
    weight FLOAT,
    warehouse_id varchar (10)
);

LOAD DATA
INFILE '/usr/local/mysql/data/transactions_db/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- add primary key to table products
alter table products add primary key (product_id);

-- Table that connects data from the products.csv file with the transactions_db database
-- temporary table with integers from 1 to 15
create table ints (
    i int
);
INSERT INTO ints(i) 
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15);

-- create table transaction_product
create table transaction_product as 
select id as transaction_id, 
substring_index(substring_index(product_ids,',',i), ',', -1) as product_id
from transactions, ints
where i <= (length(product_ids) - length(replace(product_ids, ',', ''))+1)
order by id;

-- change data type of product_id to integer
alter table transaction_product modify product_id INT;

-- delete temporary table
drop table ints;

-- add primary key
alter table transaction_product add primary key (transaction_id, product_id),
-- add foreign keys
add foreign key(transaction_id) references transactions(id),
add foreign key(product_id) references products(product_id);

-- Exercise 1
-- The number of times each product has been sold
with product_count as (
select tp.product_id, count(tp.product_id) as number_of_sold
from transaction_product as tp
join transactions as t on (tp.transaction_id = t.id)
where t.declined = 0
group by tp.product_id)

select p.product_id, p.product_name, coalesce(pc.number_of_sold, 0) as number_of_sold
from products as p
left join product_count as pc
using (product_id);