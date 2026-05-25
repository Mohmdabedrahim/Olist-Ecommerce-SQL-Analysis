use e_commerce;
/*
Step 4 — Delivery Performance Analysis

Purpose:
Analyze delivery performance by measuring delivery time, late orders,
late delivery rate, and delivery delay patterns by state.
*/

--Delivery Performance Analysis 
select * from orders;
--Avg delivery time
select
	count(*) as delivered_order,
	cast(avg(DATEDIFF(day,order_purchase_timestamp,order_delivered_customer_date)) as decimal(10,2)) as Avg_delivery_days,
	min(datediff(day,order_purchase_timestamp,order_delivered_customer_date)) as min_delivery_days,
	max(datediff(day,order_purchase_timestamp,order_delivered_customer_date)) as max_delivery_days
from orders
where order_status = 'delivered'
	and order_purchase_timestamp is not null
	and order_delivered_customer_date is not null;


-- see how many orders deliverd in the same day
SELECT 
    COUNT(*) AS same_day_deliveries
FROM orders
WHERE CAST(order_purchase_timestamp AS DATE) = CAST(order_delivered_customer_date AS DATE)
  AND order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;

--Avg Delays days
select 
	count(*) as delay_days,
	cast(avg(datediff(day,order_estimated_delivery_date,order_delivered_customer_date)) as decimal(10,2)) as avg_delay_days,
	min(datediff(day,order_estimated_delivery_date,order_delivered_customer_date)) as earliest_delivery_days,
	max(datediff(day,order_estimated_delivery_date,order_delivered_customer_date)) as max_delay_days
from orders
where order_status='delivered'
	and order_estimated_delivery_date is not null
	and order_delivered_customer_date is not null
--Negative value = delivered before estimated date "earliest delivery"
--Positive value = delivered late 
--Zero = delivered exactly on estimated date	

--on time VS delay delivery
select 
	case when order_delivered_customer_date<= order_estimated_delivery_date then 'On-time' else 'delayed' end as delivery_status,
	count(*)  as Total_order,
	cast( 100 * count(*) / sum(count(*)) over() as decimal(10,2)) as percentage_of_order
from orders
where order_status = 'delivered'
	and order_delivered_customer_date is not null
	and order_estimated_delivery_date is not null
group by 
	case when order_delivered_customer_date<= order_estimated_delivery_date then 'On-time' else 'delayed' end;


-- late delivery by customer state
select
	c.customer_state,
	count(*) as delivery_orders,
	sum(case when o.order_delivered_customer_date > o.order_estimated_delivery_date then 1 else 0 end) as delivery_date,
	cast(100 * sum(case when o.order_delivered_customer_date > o.order_estimated_delivery_date then 1 else 0 end)/count(*) as decimal(10,2)) as percentage_delivery_late
from orders o 
join customer c 
	on o.customer_id = c.customer_id
where o.order_status='delivered'

	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
group by 
	c.customer_state
order by percentage_delivery_late desc;

--late delivery by product category 


select top 10
	coalesce(t.product_cat_name_eng,p.product_category_name) as product_category,
	count(distinct o.order_id) as total_order,
	sum(case when order_delivered_customer_date>order_estimated_delivery_date then 1 else 0 end ) as delivery_late,
	cast(100 * sum(case when order_delivered_customer_date>order_estimated_delivery_date then 1 else 0 end )/count(distinct o.order_id) as decimal(10,2)) as delivery_percentage_late
from orders o
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
left join product_category_name_translation t on p.product_category_name = t.product_cat_name_eng
where o.order_status = 'delivered'
group by 
	coalesce(t.product_cat_name_eng,p.product_category_name)
having count(distinct o.order_id) >=100
order by delivery_percentage_late desc;

--review score by delivery status
select
	case	
		when o.order_delivered_customer_date>o.order_estimated_delivery_date then 'Late' else 'On Time' end as delivery_status,
	cast(avg(cast(r.review_score as decimal(10,2))) as decimal(10,2)) as Avg_score
from orders o
join order_reviews r 
	on o.order_id = r.order_id
where o.order_status='delivered'
	and o.order_delivered_customer_date is not null 
	and o.order_estimated_delivery_date is not null 
group by 
	case	
		when o.order_delivered_customer_date>o.order_estimated_delivery_date then 'Late' else 'On Time' end;

--top sellers with highest late delivery rate
select top 10
	oi.seller_id,
	s.seller_city,
	s.seller_state,
	sum(case when o.order_delivered_customer_date>o.order_estimated_delivery_date then 1 else 0 end) as late_delivery,
	cast(100 * sum(case when o.order_delivered_customer_date>o.order_estimated_delivery_date then 1 else 0 end)/count(distinct o.order_id) as decimal(10,2)) as delivery_rate
from order_items oi 
join sellers s 
	on oi.seller_id = s.seller_id
join orders o 
	on oi.order_id=o.order_id
where o.order_status='delivered'
group by 
	oi.seller_id,
	s.seller_city,
	s.seller_state
HAVING COUNT(DISTINCT o.order_id) >= 50
order by delivery_rate desc;



SELECT
    CASE
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) <= -7 THEN '7+ Days Early'
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) BETWEEN -6 AND -1 THEN '1-6 Days Early'
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) = 0 THEN 'On Estimated Date'
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) BETWEEN 1 AND 7 THEN '1-7 Days Late'
        ELSE '8+ Days Late'
    END AS delay_group,
    COUNT(DISTINCT o.order_id) AS total_orders,
    CAST(AVG(CAST(r.review_score AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_review_score
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY
    CASE
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) <= -7 THEN '7+ Days Early'
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) BETWEEN -6 AND -1 THEN '1-6 Days Early'
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) = 0 THEN 'On Estimated Date'
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) BETWEEN 1 AND 7 THEN '1-7 Days Late'
        ELSE '8+ Days Late'
    END
ORDER BY
    avg_review_score DESC;

