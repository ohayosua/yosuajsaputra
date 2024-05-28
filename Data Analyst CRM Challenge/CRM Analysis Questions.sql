/* (Question 1) Count unique active customers */
 
select count(distinct CustomerID) as unique_active_customers
from sales -- 6635 (Assuming "active" customers are customers in the sales table indicating customers who have made a sale.)
; 



/* (Question 2) Find and highlight duplicate customer records for removal */

--  As stated in the email, it is OK to just share the count of duplicates (no need to actually highlight)
-- Finding duplicate customer records
select *
from customers; -- 10,059 records
select distinct *
from customers; -- 10,059 records
	-- Both queries have the same number of records, indicating that there are no duplicate records in the customers table.

select *
from sales; -- 50,000
select distinct *
from sales; -- 44,912

select 
(select count(*) as total_records from sales) -- total records
- 
(select count(*) as non_duped_records from -- total non duplicate records
	(select distinct * from sales) a) as total_duplicate_records -- 5088 duplicated records
;

	--  Additional: Listing of all the duplicate records in the sales table.
select *
from (
select *
,	row_number() over(partition by SKU, CustomerID, Price, Tax, Store, TransactionID, Descr, Class, Category order by CustomerID) as dupes
from sales) dupes_record
where dupes > 1
;



/* (Question 3) Count total unique transactions */

select count(distinct TransactionID) as unique_transactions
from sales -- 19268
;



/* (Question 4) Count unique Customers with 10+ Transactions */

select count(distinct CustomerID) as num_customers_with_ten_or_more_transactions
from (
	select CustomerID, count(distinct TransactionID) as transaction_num
	from sales
	group by CustomerID
	having count(distinct TransactionID) >= 10
	) a
; -- 270 (CustomerIDs with 10 or more unique TransactionIDs)



/* (Question 5) Total Sales $$ for 10+ Transactions w/ Tax */

with customerids_over_ten as (
	select CustomerID, count(distinct TransactionID) as transaction_num
	from sales
	group by CustomerID
	having count(distinct TransactionID) >= 10
	),
customers_over_ten as (
	select s.*, transaction_num, (Price + Tax) as price_and_tax
	from sales s
	left join customerids_over_ten ct
	on s.CustomerID = ct.CustomerID
	where ct.CustomerID is not null
	),
duplicate_count as (
	select *
	, row_number() over(partition by SKU, CustomerID, Price, Tax, Store, TransactionID, Descr, Class, Category, transaction_num, price_and_tax
		order by CustomerID) as dupe_cnt
	from customers_over_ten
	)
-- Another method without duplicate_count CTE: select sum(price_and_tax) as total_sales from (select distinct * from customers_over_ten) a;
select sum(price_and_tax) as total_sales
from duplicate_count
where dupe_cnt = 1
-- Answer: $439671.612







	-- Additional Note: Example of customers with dupicate records
select *
from sales
where CustomerID = 71008873--9945061593
;
