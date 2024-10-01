USE transactions;

-- Level 1
-- Exercise 1
-- create table credit_card
create table if not exists credit_card(
id varchar(15) primary key, 
iban varchar(35), 
pan varchar(20), 
pin char(4) CHECK (LENGTH(pin) = 4),                   
cvv char(4) CHECK (LENGTH(cvv) = 3 OR LENGTH(cvv) = 4),
expiring_date varchar(10)
);

-- introduce data

-- add foreign key to table transaction
alter table transaction add 
foreign key (credit_card_id) references credit_card(id);

-- Exercise 2
-- Change IBAN for user with ID 'CcU-2938' to 'R323456312213576817699999'.
select * from credit_card where id = 'CcU-2938';
update credit_card set iban = 'R323456312213576817699999'
where id = 'CcU-2938';
select * from credit_card where id = 'CcU-2938';

-- Exercise 3
-- add new row into the 'transaction' table with the following information
-- id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD', credit_card_id = 'CcU-9999', compny_id = 'b-9999', user_id = '9999', 
-- lat = '829.999', longitude = '-117.999', amount = '111.11', declined = '0' 
select * from transaction where id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';
insert into company (id, company_name, phone, email, country, website) VALUES ('b-9999', null, null, null, null, null);
insert into credit_card (id, iban, pan, pin, cvv, expiring_date) VALUES ('CcU-9999', null, null, null, null, null);
insert into transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', null, '111.11', '0');
select * from transaction where credit_card_id = 'CcU-9999';

-- Exercise 4
-- delete the "pan" column from the credit_card table
alter table credit_card drop column pan;
describe credit_card;

-- Level 2
-- Exercise 1
-- Remove from the table 'transaction' the record with ID 02C6201E-D90A-1859-B4EE-88D2986D3B02
select * from transaction where id='02C6201E-D90A-1859-B4EE-88D2986D3B02';
select * from transaction where credit_card_id = (select credit_card_id from transaction where id='02C6201E-D90A-1859-B4EE-88D2986D3B02'); -- if there are more transactions with the same credit card
select * from transaction where company_id = (select company_id from transaction where id='02C6201E-D90A-1859-B4EE-88D2986D3B02'); -- if that company has more transactions

delete from transaction where id='02C6201E-D90A-1859-B4EE-88D2986D3B02';
select * from transaction where id='02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Exercise 2
-- Create a veiw VistaMarketing that contains the following information: 
-- company name, phone number, country, average purchase made by each company. 
-- Present the created view, sorting the data from highest to lowest purchase average.
create view VistaMarketing as
select c.company_name, c.phone, c.country, round(AVG(t.amount), 2) as avg_purchase
from company as c
join transaction as t on c.id=t.company_id
where t.declined = 0 and c.company_name is not null
group by c.id;

select * from VistaMarketing
order by avg_purchase desc;

-- Exercise 3
-- Companies from 'VistaMarketing' that have their country of residence in "Germany".
select * from VistaMarketing
where country = 'Germany';


-- Level 3
-- Exercise 1
-- Update DB 'Transactions' according to provided EER diagram

-- delete 'website' column from table 'company'
alter table company drop column website;
describe company;

-- add column 'fecha_actual' into the 'credit_card' table
alter table credit_card add column fecha_actual DATE default (current_date);
select * from credit_card limit 5;

-- change the data types in the excisting tables
alter table credit_card modify id varchar(20), modify iban varchar(50), modify pin varchar(4), modify cvv int;
describe credit_card;

-- add table data_user: run script 'estructura_datos_user.sql' and 'datos_introducir_user'

-- change table name 'user' to 'data_user'
rename table user to data_user;

-- change column names
alter table data_user rename column email to personal_email;

-- drop foreign key
alter table data_user drop foreign key data_user_ibfk_1;

-- add foreign key into table 'transaction'
set foreign_key_checks = 0;
alter table transaction add constraint transaction_ibfk_3 
foreign key (user_id) references data_user(id);
set foreign_key_checks = 1;


-- Exercise 2
-- Create a view "Technical Report" that contains the following information: 
-- transaction ID, name of the user, surname of the user, IBAN of the credit card used, 
-- name of the company of the transaction carried out. 
-- Present the created view, sorting the data in descending order based on the transaction ID.
create view TechnicalReport as
select t.id as transaction_id, u.name as user_name, u.surname as user_surname, cc.iban, c.company_name
from transaction as t
join data_user as u on t.user_id=u.id
join credit_card as cc on t.credit_card_id=cc.id
join company as c on t.company_id=c.id;

select * from TechnicalReport
order by transaction_id desc;
