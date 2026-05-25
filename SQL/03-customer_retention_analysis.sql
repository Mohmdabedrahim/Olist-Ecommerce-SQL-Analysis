use e_commerce;
/*
Step 3 — Customer Retention Analysis

Purpose:
Analyze customer purchase behavior by identifying one-time customers,
returning customers, and the overall customer retention rate.
*/

--Customer Retention Analysis 

--Total Unique Customers
select
	count(distinct customer_unique_id) as Total_Customers_unique
from customer;

--customer Order Frequency
select 
	c.customer_unique_id,
	count(distinct  o.order_id) as Total_Orders
from orders o 
join customer c
	on o.customer_id=c.customer_id
where
	o.order_status='delivered'
group by
	c.customer_unique_id
order by 
	Total_Orders desc;

--One time Vs Returning Customer
with customer_order as(
select 
	c.customer_unique_id,
	count(distinct  o.order_id) as Total_Orders
from orders o 
join customer c
	on o.customer_id=c.customer_id
where
	o.order_status='delivered'
group by
	c.customer_unique_id
)
select 
	case
		when Total_Orders=1 then 'One-Time Customer' else 'Returning Customer' end as customer_type,
		count(*) as Total_customers
from customer_order
group by 
		case
		when Total_Orders=1 then 'One-Time Customer' else 'Returning Customer' end;


--Retention Rate
with customer_order as (
select
	c.customer_unique_id,
	count(distinct o.order_id ) as Total_Orders
from orders o 
join customer c
on o.customer_id=c.customer_id
where order_status='delivered'
group by
	customer_unique_id )
select 
	sum(case when Total_Orders=1 then 1 else 0 end) as one_time_customer,
	sum(case when Total_Orders>1 then 1 else 0 end) as Returning_customer,
	cast(
		100 * sum(case when Total_Orders>1 then 1 else 0 end)/count(*) as decimal(10,2)) as Retention_rate
from customer_order;
	
--Top 10 customer by number of orders and total spent
select top 10 
	c.customer_unique_id,
	count(distinct o.order_id) as Total_Orders,
	cast(sum(oi.price + oi.freight_value) as decimal(10,2)) as Total_spent
from orders o
join order_items oi 
	on o.order_id=oi.order_id
join customer c
	on o.customer_id=c.customer_id
where o.order_status='delivered'
group by 
	c.customer_unique_id
order by 
	Total_Orders desc,
	Total_spent desc ;

-- group the customer by total spending
with customer_spending as(
	select
		c.customer_unique_id,
		count(distinct o.order_id) as Total_Orders,
		cast(sum(oi.price + oi.freight_value) as decimal(10,2)) as Total_spent
	from orders o
	join order_items oi 
		on o.order_id=oi.order_id
	join customer c
		on o.customer_id=c.customer_id
	where 
		o.order_status='delivered'
	group by 
		c.customer_unique_id )
select
	case when Total_spent <100 then 'Low Value'
		when Total_spent >=100 and Total_spent<300 then 'Medium Value'
		when Total_spent >=300 and Total_spent <700 then 'High Value'
		else 'Very high Value' end 
		as Customer_Segment,
	count(*) as Total_Customers,
	cast(sum(Total_spent) as decimal(10,2)) as Total_Revenue
from  customer_spending
group by 
	case when Total_spent <100 then 'Low Value'
		when Total_spent >=100 and Total_spent<300 then 'Medium Value'
		when Total_spent >=300 and Total_spent <700 then 'High Value'
		else 'Very high Value' end 
order by
	Total_Revenue;

--New Customer Monthly
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customer c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        c.customer_unique_id
)
SELECT
    YEAR(first_purchase_date) AS purchase_year,
    MONTH(first_purchase_date) AS purchase_month,
    COUNT(*) AS new_customers
FROM first_purchase
GROUP BY
    YEAR(first_purchase_date),
    MONTH(first_purchase_date)
ORDER BY
    purchase_year,
    purchase_month;

--monthly returning customer
WITH customer_order_sequence AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_sequence
    FROM customer c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
)
SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT customer_unique_id) AS returning_customers
FROM customer_order_sequence
WHERE order_sequence > 1
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;
