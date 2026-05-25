use e_commerce;
--order status destribuation
SELECT COUNT(*) AS total_customers FROM customer;

SELECT COUNT(*) AS total_orders FROM orders;

SELECT COUNT(*) AS total_order_items FROM order_items;

SELECT COUNT(*) AS total_payments FROM order_payments;

SELECT COUNT(*) AS total_reviews FROM order_reviews;

SELECT COUNT(*) AS total_products FROM products;

SELECT COUNT(*) AS total_sellers FROM sellers;

SELECT COUNT(*) AS total_categories FROM product_category_name_translation;

SELECT COUNT(*) AS total_geolocation_rows FROM geolocation;



--Joins between orders, customers, products, payments, and reviews

select 
	o.order_id,
	c.customer_id,
	c.customer_unique_id,
	c.customer_city,
	c.customer_state,
	o.order_status,
	o.order_purchase_timestamp
from orders o
join customer c
	on c.customer_id = o.customer_id


-- Cheking the missing value in the customer

select
	sum( case when customer_unique_id is null then 1 else 0 end) as Misiing_customer_id,
	sum( case when customer_id is null then 1 else 0 end) as Misiing_customer_id,
	sum( case when customer_zip_code_prefix  is null then 1 else 0 end) as Missing_zip_code,
	sum(case when customer_city is null then 1 else 0 end) as Missing_customer_city,
	sum(case when customer_state is null then 1 else 0 end) as misiing_customer_state
from customer;

--Cheking the missing Value in orders
select
	sum(case WHEN order_id IS NULL THEN 1 ELSE 0 END ) as Missing_order_id,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS missing_order_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_date,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS missing_approved_date,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS missing_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_customer_delivery_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS missing_estimated_delivery_date
from orders;

Select 
	order_status,
	count(*) as Total_order
from orders
group by order_status
order by Total_order desc;

--cheking the duplicated customers 
select 
	customer_id,
	count(*) as duplicated
from customer
group by customer_id
having count(*)>1; -- No duplicated customers

-- Cheking Duplicated Orders 
select
	order_id,
	count(*) as duplicated_order
from orders
group by order_id
having count(*)>1; -- No duplicated order

-- cheking for invaled delivery date
select top 20
		order_id,
		order_purchase_timestamp,
		order_delivered_customer_date,
		DATEDIFF(day,order_purchase_timestamp,order_delivered_customer_date) as deliver_days
from orders 
where order_delivered_customer_date < order_purchase_timestamp;

--check for late delivery
select
	count(*) as Total_orders,
	sum(case when order_delivered_customer_date > order_estimated_delivery_date then 1 else 0 end) as late_orders , 
	sum(case when order_delivered_customer_date < order_estimated_delivery_date then 1 else 0 end) as on_time_order
from orders 
where 
	order_status = 'delivered'
	and order_delivered_customer_date is not null
	and order_estimated_delivery_date is not null;
-- percentage of late delivery
select 
	count(*) as Total_deliverd_orders,
	sum(case when order_delivered_customer_date > order_estimated_delivery_date then 1 else 0 end ) as late_orders,
	cast(
		100 * sum(case when order_delivered_customer_date >order_estimated_delivery_date then 1 else 0 end)/count(*) as decimal(10,2)) as late_delivery_percentage
from orders 
where 
	order_status = 'delivered'
	and order_delivered_customer_date is not null
	and order_estimated_delivery_date is not null;


-- check orders without payment record
select 
	count(*) as Order_Without_payment
from orders o 
left join order_payments p on o.order_id = p.order_id
where p.order_id is null;



--check orders without review record 

select
	count(*) as orders_without_review 
from orders o 
left join order_reviews rev on o.order_id = rev.order_id 
where rev.order_id is null;

SELECT
    COUNT(*) AS items_without_product_details
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


