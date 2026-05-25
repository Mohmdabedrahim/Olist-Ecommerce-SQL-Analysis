use e_commerce;

/*
Step 9 — Final Executive KPI Summary

Purpose:
Create a categorized executive KPI table for the Olist e-commerce project.
This summary combines order volume, customer count, revenue, delivery performance,
customer retention, and customer satisfaction into one final SQL output.
*/
--Vertical 
with main_kpis as (
select 
	count(distinct o.order_id ) as delivered_orders,
	count(distinct c.customer_unique_id) as total_customers,
	cast( sum(
			oi.price + oi.freight_value) as decimal(10,2)) as total_revenue,
	cast(sum(oi.price + oi.freight_value) / count(distinct o.order_id ) as decimal(10,2)) as  aov,
	cast(avg(
			datediff(day,o.order_purchase_timestamp,o.order_delivered_customer_date)) as decimal(10,2)) as avg_delivery_days,
	count(distinct
		case when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end) as late_orders,
	cast(
		count(distinct
			case when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end) *100.0 / count(distinct o.order_id )
			 as decimal(10,2)) as late_delivery_rate
from orders o 
join customer c 
	on o.customer_id = c.customer_id
join order_items oi 
	on o.order_id = oi.order_id
where 
	o.order_status = 'delivered' 
	and o.order_delivered_customer_date is not null 
	and o.order_estimated_delivery_date is not null ),
customer_orders as (
select 
	c.customer_unique_id,
	count(distinct o.order_id) as total_orders
from orders o  
join customer c
	on o.customer_id = c.customer_id
where 
	o.order_status = 'delivered'
group by
	c.customer_unique_id
),
retention_kpis as (

select 
	count(case when total_orders = 1 then customer_unique_id end) as one_time_customers,
	count(case when total_orders >1 then customer_unique_id end) as returning_customers,
	cast(
		count(case when total_orders >1 then customer_unique_id end)*100.0/ count(distinct customer_unique_id) as decimal(10,2)) as retention_rate
from customer_orders
),
review_kpis as (
select  
		round(avg(cast( r.review_score as float)),2)as avg_review_score,
		count(distinct
			case when r.review_score <=2 then o.order_id end) as bad_review_orders,
		count(distinct
			case when r.review_score >= 4 then o.order_id end) as good_review_orders,
		cast(
			count(distinct
				case when r.review_score <=2 then o.order_id end) *100.0 / count(distinct case when r.review_score is not null then o.order_id end ) as decimal(10,2)
			) as  bad_review_rate,
		cast(
			count(distinct
				case when r.review_score >= 4 then o.order_id end) *100.0 / count(distinct case when r.review_score is not null then o.order_id end ) as decimal(10,2)
			) as good_review_rate
from orders o
left join order_reviews r
	on o.order_id = r.order_id
where 
	o.order_status = 'delivered'
),
final_kpis as(
select *
from main_kpis
cross join 
retention_kpis
cross join 
review_kpis
)
select 
    'Orders' as kpi_category,
    'Delivered Orders' as kpi_name,
    cast(delivered_orders as varchar(50)) as kpi_value
from final_kpis

union all

select 
    'Customers',
    'Total Customers',
    cast(total_customers as varchar(50))
from final_kpis

union all

select 
    'Revenue',
    'Total Revenue',
    cast(total_revenue as varchar(50))
from final_kpis

union all

select 
    'Revenue',
    'Average Order Value',
    cast( aov as varchar(50))
from final_kpis

union all

select 
    'Delivery',
    'Average Delivery Days',
    cast(avg_delivery_days as varchar(50))
from final_kpis

union all

select 
    'Delivery',
    'Late Orders',
    cast(late_orders as varchar(50))
from final_kpis

union all

select 
    'Delivery',
    'Late Delivery Rate (%)',
    cast(late_delivery_rate as varchar(50))
from final_kpis

union all

select 
    'Customer Retention',
    'Retention Rate (%)',
    cast(retention_rate as varchar(50))
from final_kpis
union all

select 
    'Customer Satisfaction',
    'Average Review Score',
    cast(avg_review_score as varchar(50))
from final_kpis

union all

select 
    'Customer Satisfaction',
    'Bad Review Rate (%)',
    cast( bad_review_rate as varchar(50))
from final_kpis

union all

select 
    'Customer Satisfaction',
    'Good Review Rate (%)',
    cast(good_review_rate as varchar(50))
from final_kpis;
