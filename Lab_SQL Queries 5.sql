/* Lab | SQL Queries 5 */

/* Instructions */

-- 1. Drop column picture from staff.
alter table sakila.staff
drop column picture;

-- 2. A new person is hired to help Jon. Her name is TAMMY SANDERS, and she is a customer. Update the database accordingly.
select * from sakila.customer
where first_name = 'TAMMY' and last_name = 'SANDERS';

insert into sakila.staff values
(3, 'Tammy', 'Sanders', 79, 'Tammy.Sanders@sakilacustomer.org', 2, 1, 'Tammy', '', current_timestamp());

select * from sakila.staff;

/* 3. Add rental for movie "Academy Dinosaur" by Charlotte Hunter from Mike Hillyer at Store 1. 
You can use current date for the rental_date column in the rental table. 
Hint: Check the columns in the table rental and see what information you would need to add there. You can query those pieces of information. 
For eg., you would notice that you need customer_id information as well. To get that you can use the following query: */
select customer_id, store_id from sakila.customer
where first_name = 'CHARLOTTE' and last_name = 'HUNTER'; -- Charlotte's customer_id is 130

-- checking what's the "Academy Dinosaur" film_id and rental durantion
select * from sakila.film
where title like '%Academy Dinosaur%'; -- film_id = 1 and rental_duration = 6

-- checking what's the inventory_id for the film_id = 1 (Academy Dinosaur) and store_id = 1
select * from sakila.inventory
where film_id = 1 and store_id = 1;

-- checking what's Mikke Hillyer staff_id
select * from sakila.staff
where first_name = 'Mike'; -- staff_id = 1

select date_add(current_timestamp(), interval 6 day);

select max(rental_id) from sakila.rental; -- checking the last rental id

insert into sakila.rental values
(16049 + 1, current_date(), 4, 130, date_add(current_timestamp(), interval 6 day), 1, current_timestamp());

select * from sakila.rental
where rental_id = (select max(rental_id) from sakila.rental);

/* 4. Delete non-active users, but first, create a backup table deleted_users to store customer_id, email, and the date for the users that would be deleted. Follow these steps:
	-> Check if there are any non-active users
	-> Create a table backup table as suggested
	-> Insert the non active users in the table backup table
	-> Delete the non active users from the table customer */

--  -> Checking if there are any non-active users
select * from sakila.customer
where active = 0;

select count(*) as 'Number of non-active' from sakila.customer
where active = 0;

describe sakila.customer;

-- -> Creating a backup table as suggested
create table deleted_users (
  `customer_id` int UNIQUE NOT NULL, -- AS PRIMARY KEY
  `email` char(50) DEFAULT NULL,
  `create_date` datetime,
  CONSTRAINT PRIMARY KEY (customer_id)  -- constraint keyword is optional but its a good practice
);

select * from sakila.deleted_users;

-- -> Inserting the non active users in the table backup table

-- Listing the users to delete first
select customer_id, email, create_date from sakila.customer
where active = 0; 

-- Inserting those users into the deleted_users table
insert into sakila.deleted_users(customer_id, email, create_date)
	select customer_id, email, create_date from sakila.customer
	where active = 0;  
    
select * from sakila.deleted_users;

-- -> Deleting the non active users from the table customer
set sql_safe_updates = 0;

-- Due to the foreign key constraint we need to delete the payments and rentals for this deleted_users
delete from sakila.payment
where customer_id in (select customer_id from sakila.deleted_users);

delete from sakila.rental
where customer_id in (select customer_id from sakila.deleted_users);

-- Now we can delete from the customer table
delete from sakila.customer
where active = 0;

select count(*) as 'Number of non-active' from sakila.customer
where active = 0;