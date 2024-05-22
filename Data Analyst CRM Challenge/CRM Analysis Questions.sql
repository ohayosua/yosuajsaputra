/* Count unique active customers */
 
select count(distinct CustomerID) as unique_active_customers
from customers -- 10017
; 


/* Find and highlight duplicate customer records for removal */

-- Finding duplicate customer records
select *
,	row_number() over(partition by CustomerID, [First Name], [Last Name] order by CustomerID) as dupes
from customers
;

-- Listing only duplicate customer records
select *
from customers 
where CustomerID IN (
	select CustomerID from (
		select CustomerID, count(*) as freq
		from customers
		group by CustomerID
		having count(*) > 1) a
		)
order by CustomerID
;



/* Count total unique transactions */

select count(distinct TransactionID) as unique_transactions
from sales -- 19268
;


/* Count unique Customers with 10+ Transactions */

select count(distinct CustomerID) as num_customers_with_ten_or_more_transactions
from (
	select CustomerID, count(distinct TransactionID) as transaction_num
	from sales
	group by CustomerID
	having count(distinct TransactionID) >= 10
	) a
; -- 270 (CustomerIDs with 10 or more unique TransactionIDs)



/* (Total Sales $$ for 10+ Transactions w/ Tax) */

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







-- Example of customers with dupicate records
select *
from sales
where CustomerID = 71008873--9945061593
;
