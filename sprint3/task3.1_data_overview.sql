USE transactions;

-- Table 'credit_card'
-- Number of credit cards 
select count(*)
from credit_card;

-- Number of IBAN
select count(iban), count(DISTINCT iban)
from credit_card;

-- Number of non-missing values
select count(iban), count(pan), count(pin), count(cvv), count(expiring_date)
from credit_card;

-- check if all credit cards were used
select *
from credit_card
where id not IN (
select credit_card_id from transaction);

-- check if all transactions have credit_card info
select *
from transaction
where credit_card_id not IN (
select id from credit_card);


-- Table 'user'
-- Number of users 
select count(*), count(DISTINCT id)
from user;

-- Number of non-missing values
select count(*) as total_rows, count(name), count(surname), 
       count(phone), count(email), count(birth_date), count(country), 
       count(city), count(postal_code), count(address)
from user;

-- check if there is user info for all transactions
select *
from transaction
where user_id not IN (
select id from user);

-- add user '9999' into 'user' table
INSERT INTO user (id, name, surname, phone, email, birth_date, country, city, postal_code, address) 
VALUES ("9999", Null, Null, Null, Null, Null, Null, Null, Null, Null);
select * from user where id='9999';

-- check if all users made purchases
select *
from user
where id not IN (
select user_id from transaction);