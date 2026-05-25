use e_commerce;
/*
Step 8 — State Priority Analysis

Purpose:
Analyze customer states by order volume, revenue, delivery performance,
late delivery rate, average delay days, review score, and priority level.
This helps identify which states need the most business attention.
*/

--check the distribuation by state(how many customer exist in each state) 
select
	customer_state,
	count(distinct customer_unique_id) as total_customer
from customer
group by 
	customer_state
order by 
	total_customer desc;

--count order by customer state
select 
	c.customer_state,
	count(distinct c.customer_unique_id) as Total_customer,
	count(distinct o.order_id) as Delivered_orders
from customer c
join orders o 
	on o.customer_id = c.customer_id
where 
	o.order_status = 'delivered'
group by 
	customer_state
order by 
	Delivered_orders desc;

--Revenue and AOV by customer state
select 
	c.customer_state,
	count(distinct c.customer_unique_id) as Total_customer,
	count(distinct o.order_id) as Delivered_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)) as Total_revenue,
	cast(
		cast(
			sum(oi.price + oi.freight_value) as decimal(10,2)) /count(distinct o.order_id) as decimal(10,2)) as AOV

from customer c
join orders o 
	on o.customer_id = c.customer_id
join order_items oi 
	on o.order_id = oi.order_id
where 
	o.order_status = 'delivered'
group by 
	customer_state
order by 
	AOV desc;


--late delivery rate by customer state
select 
	c.customer_state,
	count(distinct order_id) as delivered_order,
	count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then order_id end ) as late_orders,
	cast(count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then order_id end ) *100.0 / count(distinct order_id) as decimal(10,2)) as late_delivery_rate
from orders o 
join customer c 
	 on o.customer_id = c.customer_id
where 
	o.order_status = 'delivered' 
	and o.order_delivered_customer_date is not null 
	and o.order_estimated_delivery_date is not null
group by 
	customer_state
order by
	late_delivery_rate desc;
	
select 
	c.customer_state,
	count(distinct order_id) as delivered_order,
	cast(avg(
			cast(datediff(day,o.order_purchase_timestamp,order_delivered_customer_date) as float)) as decimal(10,2) ) as avg_delivery_days,

	cast(avg(
			case when
			o.order_delivered_customer_date > o.order_estimated_delivery_date 
			then 
			cast(datediff(day,o.order_estimated_delivery_date,order_delivered_customer_date) as float) end ) as decimal(10,2)) as avg_late_delay_days
from orders o 
join customer c 
	 on o.customer_id = c.customer_id
where 
	o.order_status = 'delivered' 
	and o.order_delivered_customer_date is not null 
	and o.order_estimated_delivery_date is not null
group by 
	customer_state
order by
	avg_late_delay_days desc;
	
--review score by customer state
select 
	c.customer_state,
	count(distinct o.order_id) as delivered_order,
	cast(avg(
			cast(datediff(day,o.order_purchase_timestamp,order_delivered_customer_date) as float)) as decimal(10,2) ) as avg_delivery_days,
	count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) as late_orders,
	cast(count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) *100.0 / count(distinct o.order_id) as decimal(10,2)) as late_delivery_rate,
	cast(avg(
			case when
			o.order_delivered_customer_date > o.order_estimated_delivery_date 
			then 
			cast(datediff(day,o.order_estimated_delivery_date,order_delivered_customer_date) as float) end ) as decimal(10,2)) as avg_late_delay_days,
	round(avg(
			cast(r.review_score as float)),2) as avg_review_score
from orders o 
join customer c 
	 on o.customer_id = c.customer_id
join order_items oi 
	on oi.order_id = o.order_id
left join order_reviews r
	on oi.order_id = r.order_id
where 
	o.order_status = 'delivered' 
	and o.order_delivered_customer_date is not null 
	and o.order_estimated_delivery_date is not null
group by 
	customer_state
order by
	avg_review_score ;

	
--Compare On-time Vs Late review by state
select 
	c.customer_state,
	count(distinct o.order_id) as delivered_order,
	cast(avg(
			cast(datediff(day,o.order_purchase_timestamp,order_delivered_customer_date) as float)) as decimal(10,2) ) as avg_delivery_days,
	count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) as late_orders,
	cast(count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) *100.0 / count(distinct o.order_id) as decimal(10,2)) as late_delivery_rate,
	cast(avg(
			case when
			o.order_delivered_customer_date > o.order_estimated_delivery_date 
			then 
			cast(datediff(day,o.order_estimated_delivery_date,order_delivered_customer_date) as float) end ) as decimal(10,2)) as avg_late_delay_days,
	round(avg(
			cast(r.review_score as float)),2) as avg_review_score,
	cast(avg(
		case when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float)end) as decimal(10,2)) as On_time_delivered_review,
	cast(avg(
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float)end) as decimal(10,2)) as Late_delivered_review,
	cast(
		cast(avg(
			case when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float)end) as decimal(10,2))
			-
	cast(avg(
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float)end) as decimal(10,2)) as float) as Review_score_gap
from orders o 
join customer c 
	 on o.customer_id = c.customer_id
left join order_reviews r
	on o.order_id = r.order_id
where 
	o.order_status = 'delivered' 
	and o.order_delivered_customer_date is not null 
	and o.order_estimated_delivery_date is not null
group by 
	customer_state
order by
	Review_score_gap desc ;

--state priority level
with state_performance as (
select 
	c.customer_state,
	count(distinct o.order_id) as delivered_order,
	cast(avg(
			cast(datediff(day,o.order_purchase_timestamp,order_delivered_customer_date) as float)) as decimal(10,2) ) as avg_delivery_days,
	count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) as late_orders,
	cast(count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) *100.0 / count(distinct o.order_id) as decimal(10,2)) as late_delivery_rate,
	cast(avg(
			case when
			o.order_delivered_customer_date > o.order_estimated_delivery_date 
			then 
			cast(datediff(day,o.order_estimated_delivery_date,order_delivered_customer_date) as float) end ) as decimal(10,2)) as avg_late_delay_days,
	round(avg(
			cast(r.review_score as float)),2) as avg_review_score,
	cast(avg(
		case when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float)end) as decimal(10,2)) as On_time_delivered_review,
	cast(avg(
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float)end) as decimal(10,2)) as Late_delivered_review,
	cast(
		cast(avg(
			case when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float)end) as decimal(10,2))
			-
	cast(avg(
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float)end) as decimal(10,2)) as float) as Review_score_gap,
	CASE
    WHEN 
        COUNT(DISTINCT CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
            THEN o.order_id 
        END) >= 150
        AND
        (
            AVG(CASE 
                WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date 
                THEN CAST(r.review_score AS FLOAT)
            END)
            -
            AVG(CASE 
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
                THEN CAST(r.review_score AS FLOAT)
            END)
        ) >= 1.5
    THEN 'High Priority'

    WHEN 
        COUNT(DISTINCT CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
            THEN o.order_id 
        END) >= 50
        AND
        (
            AVG(CASE 
                WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date 
                THEN CAST(r.review_score AS FLOAT)
            END)
            -
            AVG(CASE 
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
                THEN CAST(r.review_score AS FLOAT)
            END)
        ) >= 1.0
    THEN 'Medium Priority'

    ELSE 'Low Priority'
	END AS priority_levels
from orders o 
join customer c 
	 on o.customer_id = c.customer_id
left join order_reviews r
	on o.order_id = r.order_id
where 
	o.order_status = 'delivered' 
	and o.order_delivered_customer_date is not null 
	and o.order_estimated_delivery_date is not null
group by 
	customer_state
)
select * from state_performance
order by
case when priority_levels ='High Priority' then 1
	when priority_levels = 'lowe Priority' then 2
	else 3 end ,
late_orders desc;

--Revnue with priority 

WITH state_delivery_reviews AS (
    SELECT 
        c.customer_state,

        COUNT(DISTINCT o.order_id) AS delivered_orders,

        CAST(
            AVG(CAST(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS FLOAT))
            AS DECIMAL(10,2)
        ) AS avg_delivery_days,

        COUNT(DISTINCT CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
            THEN o.order_id 
        END) AS late_orders,

        CAST(
            COUNT(DISTINCT CASE 
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
                THEN o.order_id 
            END) * 100.0 / COUNT(DISTINCT o.order_id)
            AS DECIMAL(10,2)
        ) AS late_delivery_rate,

        CAST(
            AVG(CASE 
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN CAST(DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS FLOAT)
            END)
            AS DECIMAL(10,2)
        ) AS avg_late_delay_days,

        CAST(
            AVG(CAST(r.review_score AS FLOAT))
            AS DECIMAL(10,2)
        ) AS avg_review_score,

        CAST(
            AVG(CASE 
                WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
                THEN CAST(r.review_score AS FLOAT)
            END)
            AS DECIMAL(10,2)
        ) AS on_time_delivered_review,

        CAST(
            AVG(CASE 
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN CAST(r.review_score AS FLOAT)
            END)
            AS DECIMAL(10,2)
        ) AS late_delivered_review,

        CAST(
            AVG(CASE 
                WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
                THEN CAST(r.review_score AS FLOAT)
            END)
            -
            AVG(CASE 
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN CAST(r.review_score AS FLOAT)
            END)
            AS DECIMAL(10,2)
        ) AS review_score_gap

FROM orders o
JOIN customer c
     ON o.customer_id = c.customer_id
LEFT JOIN order_reviews r
      ON o.order_id = r.order_id

WHERE 
     o.order_status = 'delivered'
     AND o.order_delivered_customer_date IS NOT NULL
     AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY 
	 c.customer_state
),

state_revenue AS (
    SELECT 
        c.customer_state,

        CAST(
            SUM(oi.price + oi.freight_value)
            AS DECIMAL(10,2)
        ) AS total_revenue,

        CAST(
            SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id)
            AS DECIMAL(10,2)
        ) AS AOV

FROM orders o
JOIN customer c
	ON o.customer_id = c.customer_id
JOIN order_items oi
	ON o.order_id = oi.order_id

WHERE 
    o.order_status = 'delivered'
GROUP BY 
	c.customer_state
),

final_state_performance AS (
SELECT
        d.customer_state,
        d.delivered_orders,
        r.total_revenue,
        r.AOV,
        d.avg_delivery_days,
        d.late_orders,
        d.late_delivery_rate,
        d.avg_late_delay_days,
        d.avg_review_score,
        d.on_time_delivered_review,
        d.late_delivered_review,
        d.review_score_gap,

        CASE
            WHEN d.late_orders >= 150 
                 AND d.review_score_gap >= 1.5
            THEN 'High Priority'

            WHEN d.late_orders >= 50 
                 AND d.review_score_gap >= 1.0
            THEN 'Medium Priority'

            ELSE 'Low Priority'
        END AS priority_level

FROM state_delivery_reviews d
JOIN state_revenue r
	ON d.customer_state = r.customer_state
)

SELECT *
FROM final_state_performance
ORDER BY
    CASE
        WHEN priority_level = 'High Priority' THEN 1
        WHEN priority_level = 'Medium Priority' THEN 2
        ELSE 3
    END,
    late_orders DESC;
