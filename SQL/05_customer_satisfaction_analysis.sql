use e_commerce;
/*
Step 5 — Customer Satisfaction Analysis

Purpose:
Analyze customer satisfaction using review scores,
bad review rates, good review rates, and the relationship
between delivery performance and customer reviews.
*/

--Customer Satisfaction Analysis with SQL Server

--Review score distribuation
select
	review_score,
	count(*) as total_reviews,
	cast(
		100 * count(*)/sum(count(*)) over() as decimal(10,2)) as review_percentage
from order_reviews
group by 
	review_score
order by 
	review_score

--Average review score overall
select 
	count(*) as total_reviews,
	cast(
		avg(review_score)  as decimal(10,2)) as avg_review_score
	
from order_reviews
group by 
	review_score

--Reveiew score by product category
select top 10
	coalesce(t.product_cat_name_eng,p.product_category_name) as product_category,
	cast(
		avg(cast(r.review_score as decimal(10,2)))  as decimal(10,2)) as avg_review_score
from products p
join product_category_name_translation t 
	on p.product_category_name = t.product_cat_name
join order_items oi
	on p.product_id = oi.product_id
left join order_reviews r
	on oi.order_id = r.order_id
group by 
	coalesce(t.product_cat_name_eng,p.product_category_name)
having 
	count(distinct r.review_id)>=100
order by avg_review_score desc;


--lowest rated product categories
select top 10
	coalesce(t.product_cat_name_eng,p.product_category_name) as product_category,
	count(distinct r.review_id) as total_review,
	cast(
		avg(cast(r.review_score as decimal(10,2)))  as decimal(10,2)) as avg_review_score
from products p
join product_category_name_translation t 
	on p.product_category_name = t.product_cat_name
join order_items oi
	on p.product_id = oi.product_id
left join order_reviews r
	on oi.order_id = r.order_id
group by 
	coalesce(t.product_cat_name_eng,p.product_category_name)
having 
	count(distinct r.review_id)>=100
order by avg_review_score ;

--Review score by customer state
select 
	c.customer_state,
	 count(distinct r.review_id) as total_reviews,
	cast(
		avg(cast(r.review_score as decimal(10,2)))  as decimal(10,2)) as avg_review_score
from customer c
join orders o 
	on o.customer_id = c.customer_id
left join order_reviews r
	on r.order_id=o.order_id
group by 
	c.customer_state
having 
	count(distinct r.review_id)>=100
order by avg_review_score ;

--Review score by payment type
select
	p.payment_type,
	count(distinct r.review_id) as total_reviews,
	cast(
		avg(cast(r.review_score as decimal(10,2)))  as decimal(10,2)) as avg_review_score
from 
	order_payments p
join orders o 
	on p.order_id=o.order_id
left join order_reviews r
	on o.order_id = r.order_id
group by
	p.payment_type
having 
	count(distinct r.review_id)>=100
order by 
	avg_review_score desc;


--Bad reviews score (1 or 2) 
select 
	count(*) as total_reviews,
	SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,
	cast(
		100 * sum(case when review_score<=2 then 1 else 0 end)/count(*) as decimal(10,2)) as percentage_bad
	
from order_reviews
	
--bad review rate by deliver status
select
	case when o.order_estimated_delivery_date > o.order_delivered_customer_date then 'On time' else 'late' end as delivery_status,
	count(distinct r.review_id) as total_reviews,
	 sum( case when r.review_score <=2 then 1 else 0 end) as bad_reviews,
	cast(
		100 * sum( case when r.review_score <=2 then 1 else 0 end)/count(distinct r.review_id) as decimal(10,2)) as bad_review_percentage

from orders o 
join order_reviews r 
	on o.order_id= r.order_id
where 
	o.order_status='delivered'
	and o.order_estimated_delivery_date is not null
	and o.order_delivered_customer_date is not null
group by 
	case when o.order_estimated_delivery_date > o.order_delivered_customer_date then 'On time' else 'late' end;


