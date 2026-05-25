 use e_commerce;
 /*Step 2 — Revenue Analysis

Purpose:
Analyze total revenue, order volume, average order value,
and revenue distribution across product categories.
*/
--Total Revenue from order items 
select 
	cast (sum(price) as decimal(18,2)) as Total_Items_Revenue,
	cast(sum(freight_value)as decimal(18,2)) as Total_Freight_Revenue,
	cast(sum(price + freight_value) as decimal(18,2)) as Total_Revenue
from order_items;

	
--Total Revenue from delivered Items 
select 
	cast (sum(price) as decimal(18,2)) as Total_Items_Revenue,
	cast(sum(freight_value)as decimal(18,2)) as Total_Freight_Revenue,
	cast(sum(price + freight_value) as decimal(18,2)) as Total_Revenue
from order_items oi 
join orders o on o.order_id = oi.order_id
where o.order_status = 'delivered'

--Total Orderes,customer , and avg order value

select
	count(distinct o.order_id) as Total_Order,
	COUNT(distinct c.customer_unique_id) as Total_customer,
	CAST(SUM(oi.price + oi.freight_value) AS DECIMAL(18,2)) AS total_revenue,
	cast(sum(oi.price + oi.freight_value) / count(distinct o.order_id) as decimal(18,2)) as Avg_Order_Value
from orders o
join customer c on o.customer_id=c.customer_id
join order_items oi on o.order_id = oi.order_id
where o.order_status = 'delivered';

-- monthy Revenue Trend
select
	year(o.order_purchase_timestamp) as order_year,
	month(o.order_purchase_timestamp) as order_month,
	count(distinct o.order_id) as Total_Order,
	cast(sum(oi.price + oi.freight_value) / count(distinct o.order_id) as decimal(18,2)) as Avg_Order_Value,
	cast(sum(oi.price + oi.freight_value) as decimal(18,2)) as Total_Revenue
from orders o 
join order_items oi on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by
	month(o.order_purchase_timestamp),
	year(o.order_purchase_timestamp) 
order by
	order_year,
	order_month;

-- top 10 product over revenue
select top 10
		coalesce(t.product_cat_name_eng,p.product_category_name) as Product_category_name,
		count(distinct o.order_id) as Total_Order,
		cast(sum(oi.price + oi.freight_value) as decimal(18,2)) as Total_Revenue
from orders o
join order_items oi on o.order_id=oi.order_id
join products p on oi.product_id = p.product_id
left join product_category_name_translation t on p.product_category_name=t.product_cat_name
where o.order_status='delivered'
group by coalesce(t.product_cat_name_eng,p.product_category_name)
order by Total_Revenue desc;

--Revenue by customer state
select
	c.customer_state,
	COUNT(DISTINCT c.customer_unique_id) AS total_customers,
	count(distinct o.order_id) as total_order,
	cast(sum(oi.price + oi.freight_value) as decimal(18,2)) as Total_Revenue
from orders o 
join customer c on o.customer_id = c.customer_id
join order_items oi on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by c.customer_state
order by Total_Revenue desc;


--payment Method  Revnue 
select
	p.payment_type,
	count(distinct c.customer_unique_id) as Total_customer,
	count(distinct o.order_id) as Total_Order,
	cast(sum(p.payment_value) as decimal(18,2)) as Total_Payment_Value,
	cast(avg(p.payment_value) as decimal(18,2)) as Avg_payment_value
from orders o
join order_payments p on o.order_id = p.order_id
left join order_items oi on o.order_id = oi.order_id
left join customer c on o.customer_id = c.customer_id
where o.order_status = 'delivered' 
group by p.payment_type
order by Total_Payment_Value desc;
