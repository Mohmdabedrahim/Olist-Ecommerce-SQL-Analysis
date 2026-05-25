use e_commerce;
/*
Step 6 — Seller Performance Analysis

Purpose:
Analyze seller performance using delivered orders, revenue,
late delivery rate, average delivery delay, and average review score.
This helps identify strong sellers and underperforming sellers.
*/

-- seller perfromance analysis

--Total seller 
select 
	count(*) as total_seller 
from sellers


--total orders per seller
select top 10
	s.seller_id,
	count(distinct oi.order_id) as total_orders
from sellers s
left join order_items oi 
	on s.seller_id = oi.seller_id
group by 
	s.seller_id
order by total_orders desc;

--total revenue per seller 
select top 10
	s.seller_id,
	count(distinct oi.order_id) as total_orders,
	cast(sum(cast(oi.price + oi.freight_value as decimal(10,2))) as decimal(10,2)) as total_revenue
from sellers s
left join order_items oi 
	on s.seller_id = oi.seller_id
group by 
	s.seller_id
order by total_revenue desc;

--AOV by seller
select top 10
	s.seller_id,
	count(distinct oi.order_id) as total_orders,
	cast(sum(cast(oi.price + oi.freight_value as decimal(10,2))) as decimal(10,2)) as total_revenue,
	cast(sum(cast(oi.price + oi.freight_value as decimal(10,2)))/count(distinct oi.order_id) as decimal(10,2)) as AOV
from sellers s
left join order_items oi 
	on s.seller_id = oi.seller_id
group by 
	s.seller_id
having count(distinct oi.order_id)>=10
order by AOV desc;

--seller late delivery performance
select top 10 
	oi.seller_id,
	count(distinct o.order_id) as total_deliverd_orders,
	cast( count(distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) as decimal(10,2)) as late_deliverd_orders,
	cast( count( distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) *100/count(distinct o.order_id) as decimal(10,2)) as late_deliverd_rate
from order_items oi 
left join orders o
	on oi.order_id = o.order_id
where 
	o.order_status = 'delivered'
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
group by
	oi.seller_id 
having count(distinct o.order_id) >=10
order by late_deliverd_rate desc;

--best seller delivery performance
select top 10 
	oi.seller_id,
	count(distinct o.order_id) as total_deliverd_orders,
	cast( count(distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) as decimal(10,2)) as late_deliverd_orders,
	cast( count( distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) *100/count(distinct o.order_id) as decimal(10,2)) as late_deliverd_rate
from order_items oi 
left join orders o
	on oi.order_id = o.order_id
where 
	o.order_status = 'delivered'
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
group by
	oi.seller_id 
having count(distinct o.order_id) >=10
order by late_deliverd_rate;
--however, the late delivered is a big problem that impact the score view , therefore I demonstrate the lowest late delivered sellers.

select 
	oi.seller_id,
	count(distinct o.order_id) as delivered_orders,
	count(distinct case when  o.order_delivered_customer_date <= o.order_estimated_delivery_date then o.order_id end) as early_deliverd_orders,
	round(count(distinct case when  o.order_delivered_customer_date <= o.order_estimated_delivery_date then o.order_id end) *100.0 / count(distinct o.order_id),2) as early_delivered_rate
from order_items oi 
left join orders o
	on oi.order_id = o.order_id
where 
	o.order_status = 'delivered'
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
group by
	oi.seller_id 
having count(distinct o.order_id) >=1000
order by 
	early_delivered_rate desc;
-- I ranked sellers by on -time delivery rate by filtering for rellers with at least 1000 order delivered to avoid misleading result from sellers with 
--low number of delivered orders, for fair view about the delivery performance.


--seller review performance
select top 10
	oi.seller_id,
	count(distinct oi.order_id) as total_orders,
	round(avg(cast(r.review_score as float)),2) as avg_review_score
from order_items oi
join order_reviews r
	on oi.order_id = r.order_id
join orders o
	on o.order_id = oi.order_id
where
	o.order_status = 'delivered'
group by 
	oi.seller_id
having
	count(distinct oi.order_id)>=50
order by 
	avg_review_score desc;


select 
	oi.seller_id,
	count(distinct oi.order_id) as total_orders,
	round(avg(cast(r.review_score as float)),2) as avg_review_score
from order_items oi
join order_reviews r
	on oi.order_id = r.order_id
join orders o
	on o.order_id = oi.order_id
where 
	o.order_status='delivered'
group by 
	oi.seller_id
having
	count(distinct oi.order_id)>=1000
order by 
	avg_review_score desc;		
--I add the secound query for fair comparing between the higest orders with the highest review_score 

--worst seller review performance
select top 10
	oi.seller_id,
	count(distinct oi.order_id) as total_orders,
	round(avg(cast(r.review_score as float)),2) as avg_review_score
from order_items oi
join order_reviews r
	on oi.order_id = r.order_id
join orders o
	on o.order_id = oi.order_id
where
	o.order_status = 'delivered'
group by 
	oi.seller_id
having
	count(distinct oi.order_id)>=50
order by 
	avg_review_score asc;




select top 10
	oi.seller_id,
	count(distinct oi.order_id) as total_orders,
	cast(sum(cast(oi.price + oi.freight_value as decimal(10,2))) as decimal(10,2)) as total_revenue,
	cast( count(distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) as decimal(10,2)) as late_deliverd_orders,
	cast( count( distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) *100/count(distinct o.order_id) as decimal(10,2)) as late_deliverd_rate,
	round(avg(cast(r.review_score as float)),2) as avg_review_score
from orders o
join order_items oi 
	on o.order_id = oi.order_id
join order_reviews r
	on o.order_id = r.order_id
where 
	o.order_status = 'delivered'
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
group by 
	oi.seller_id
having 
	count(distinct oi.order_id) >= 50
order by total_revenue desc;


--over all performance
select 
	s.seller_id,
	s.seller_city,
	s.seller_state,
	count(distinct oi.order_id) as total_orders,
	cast(sum(cast(oi.price + oi.freight_value as decimal(10,2))) as decimal(10,2)) as total_revenue,
	cast(sum(cast(oi.price + oi.freight_value as decimal(10,2)))/count(distinct oi.order_id) as decimal(10,2)) as AOV,
	cast( count(distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) as decimal(10,2)) as late_deliverd_orders,
	cast( count( distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) *100/count(distinct o.order_id) as decimal(10,2)) as late_deliverd_rate,
	round(avg(cast(r.review_score as float)),2) as avg_review_score,
	case 
		when
			cast( count(distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) as decimal(10,2))<=5
				and round(avg(cast(r.review_score as float)),2)>= 4 
					then 'high performer' 
		when 
			cast( count(distinct case when o.order_delivered_customer_date > o.order_estimated_delivery_date then  o.order_id end ) as decimal(10,2)) > 15 
				and  round(avg(cast(r.review_score as float)),2)< 3
			then 'need attention'
		else 'average performer'
		end as seller_performance_status
from  orders o
join order_items oi 
	on o.order_id = oi.order_id
join order_reviews r
	on o.order_id = r.order_id
left join sellers s
	on s.seller_id = oi.seller_id
where 
	o.order_status ='delivered'
	and o.order_delivered_customer_date is not null
	and o.order_estimated_delivery_date is not null
group by
	s.seller_id,
	s.seller_city,
	s.seller_state
having 
	count(distinct oi.order_id)>20
order by total_revenue desc ;
		

