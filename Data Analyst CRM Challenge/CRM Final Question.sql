/*
You're tasked with doing segmentation for an email marketing campaign aiming for a 10% engagement rate. Given the provided customer and transactional data, 
what would be your initial steps in devising a segment to achieve this goal? Walk us through your approach, 
including specific factors you would consider and how you would arrive at your conclusion. Provide a sample customer list if able.
*/



/*
Initial Thoughts:
- What is defined as engagement?
	- We can use the Transaction IDs per each customers to measure engagement.
- How can we calculate engagement rate?
	- What KPIs can we come up with. 
	- Not given a formula for engagement rate and therefore we need to construct one on our own.

What we are provided with:
- Customer names, their address/location, price of their transactions, store ID, product description, class, and category

What we are not provided with:
- Any dates that indicate when the purchase or sales happened
- Data on customer actions. Examples include clicks, visits, etc.
	- My initial thoughts as to calculating the engagement rate..


Ways to create engagement rate (Aiming for 10% engagement rate):
- Look into boosting content/marketing ads for lower engaged classes/categories
- Segment the customers for insights that could lead to business decisions: Targeting specific email campaigns for the specifically divided groups.

Other factors to consider:
- Analyzing the customers. We need to understand our audience and what most are interests in. 
	- We could segment Category and Class variables based on their engagement.



Initial Steps:
- Define engagement. Find customers who are mostly engaged (based on transaction type)
- Divide customer list into smaller targeted groups to create more effective email marketing campaigns. (engagement level: low, avg, high)
- Cleaning & Structuring the Data before Segmentation Analysis:
	- We can join the segmented engagement level customers to the customers and sales table to segment even further.
- Geographical Segmentation: state/city with the highest number of transactions or by the quality of the customers.
- Behavioral Segmentation: divide into groups based on engagement, spending habits, or both.


-- Overall Question: We want to segment the data for an email marketing campaign which sends out emails targeting specific segmented groups that could potentially increase engagement rate.
*/


--  These are the most engaged customers based on their number of transactions.
select CustomerID, count(distinct TransactionID) as transaction_num
from sales
group by CustomerID
order by 2 desc
;


-- THE FIRST STEP --
-- Dividing the customers based on their level of engagement.
with engagement_rank as (
	select *, PERCENT_RANK() over(order by transaction_num) as engagement_percentile
	from (
		select CustomerID, count(distinct TransactionID) as transaction_num
		from sales
		group by CustomerID) a
	),
-- Creating the engagement level column. The levels are determined by dividing into three equal groups based on the percentile ranks.
engagement_levels as (
	select *, 
	case when engagement_percentile <= cast(1 as float)/3 then 'low'
		when engagement_percentile between cast(1 as float)/3 and cast(2 as float)/3 then 'average' 
		when engagement_percentile > cast(2 as float)/3 then 'high' end as engagement_level
	from engagement_rank
	),
-- I want to now remove all duplicate records in the sales table and join it onto the engagement table.
deduped_sales as (
	select distinct * 
	from sales),
-- Removing duplicate customer records in the customer table. We will include only the first city that occurs in the dupicate records as I will assume it is a typo until further context given.
deduped_customers as (
	select * from (
		select *
		,	row_number() over(partition by CustomerID, [First Name], [Last Name] order by CustomerID) as dupes
		from customers) cust_dupes
	where dupes = 1)
select ds.*, transaction_num, engagement_percentile, engagement_level, [First Name], [Last Name], Address, City, State, Zip
from deduped_sales ds
join engagement_levels e
on ds.CustomerID = e.CustomerID
join deduped_customers dc
on ds.CustomerID = dc.CustomerID

-- Note: there are two customer IDs in the customers table that does not exist in the sales table: 102005068 and 120006235
-- Now with this table that we have constructed, we can devise segments for an email marketing campaign aiming to increase engagement rate.

/* I will continue this analysis utilizing python moving forward. Here is the link to my file:
	 https://github.com/ohayosua/yosuajsaputra/blob/main/Data%20Analyst%20CRM%20Challenge/CRM%20-%20Analysis%20Challenge.ipynb
*/
