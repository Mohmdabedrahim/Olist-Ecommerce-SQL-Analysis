use e_commerce;


/*
Step 7 — Category Performance Analysis

Purpose:
Analyze product category performance using delivered orders, revenue,
average order value, late delivery rate, and customer review score.
This helps identify high-performing and underperforming product categories.
*/
select * from order_items

--count orders by product categories 
select top 10
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders
from orders o
join order_items oi 
	on o.order_id = oi.order_id
join products p 
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
group by 
	pct.product_cat_name_eng 
order by 
	total_orders desc;

--Revenue by categories( which product category generate the highest revenue ?)
select top 10
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue
from orders o
join order_items oi 
	on o.order_id = oi.order_id
join products p 
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
group by 
	pct.product_cat_name_eng 
order by 
	Total_revenue desc;

-- AVerage revenue per product category
select top 10
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue,
		cast(
			sum(oi.price + oi.freight_value)/count(distinct o.order_id)
				as decimal(10,2)) as AOV
from orders o
join order_items oi 
	on o.order_id = oi.order_id
join products p 
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
group by 
	pct.product_cat_name_eng 
having count(distinct o.order_id)>=100
order by 
	AOV desc;



with total_revenue as ( select top 10
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue
from orders o
join order_items oi 
	on o.order_id = oi.order_id
join products p 
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
group by 
	pct.product_cat_name_eng 
order by 
	Total_revenue desc)
select 
	product_category,
	cast(
		total_revenue *100 /sum(total_revenue) over() as decimal(10,2)
		)  percentage_of_revenue
from total_revenue

After this result we will change almost every thing we thought about before 
The hieghest aov is comoouters products category the acheive 129011.16 per order

--Average Review score by category
select top 10
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue,
		avg(cast(r.review_score as decimal(10,2))) as avg_review_score
	
from orders o
join order_items oi 
	on o.order_id = oi.order_id
join products p 
	on oi.product_id = p.product_id
left join order_reviews r
	on o.order_id = r.order_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
group by 
	pct.product_cat_name_eng 
having count(distinct o.order_id)>=100
order by 
	avg_review_score desc;

--lowest review score category
select top 10
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue,
		avg(cast(r.review_score as decimal(10,2))) as avg_review_score
	
from orders o
join order_items oi 
	on o.order_id = oi.order_id
join products p 
	on oi.product_id = p.product_id
left join order_reviews r
	on o.order_id = r.order_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
group by 
	pct.product_cat_name_eng 
having count(distinct o.order_id)>=100
order by 
	avg_review_score;

--delivery time  by projevt category
select top 20
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue,
		avg(cast(r.review_score as decimal(10,2))) as avg_review_score,
		cast(
		avg(DATEDIFF(day,o.order_purchase_timestamp,o.order_delivered_customer_date)) as decimal(10,2)) as avg_delivery_days
		
from orders o
join order_items oi
	on o.order_id = oi.order_id
left join order_reviews r
	on o.order_id = r.order_id
join products p
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
	and o.order_purchase_timestamp is not null
	and o.order_delivered_customer_date is not null
group by 
	pct.product_cat_name_eng
	
having count(distinct o.order_id)>=100
order by 
	avg_delivery_days desc;

--late delivery rate by category
select top 20
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue,
		avg(cast(r.review_score as decimal(10,2))) as avg_review_score,
		cast(
		avg(DATEDIFF(day,o.order_purchase_timestamp,o.order_delivered_customer_date)) as decimal(10,2)) as avg_delivery_days,
		count (distinct case
				 when order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end) as late_delivered,
		cast(
			count (distinct case
				 when order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end) *100.0 /count(distinct o.order_id) as decimal(10,2))
				 as late_delivery_rate
		
from orders o
join order_items oi
	on o.order_id = oi.order_id
left join order_reviews r
	on o.order_id = r.order_id
join products p
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
	and o.order_estimated_delivery_date is not null
	and o.order_delivered_customer_date is not null
group by 
	pct.product_cat_name_eng
	
having count(distinct o.order_id)>=100
order by 
	late_delivery_rate desc;

-- Compare Late Vs On-time Reviews by prduct category

select top 20
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue,
	count(distinct case	
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then o.order_id end ) as On_time_orders,
	count(distinct case	
			when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) as late_orders,
	avg(cast(r.review_score as decimal(10,2))) as avg_review_score,
	round(avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end),2) as avg_on_time_review,
	round(avg( case
			when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end),2) as avg_late_review,
		
	cast(
		avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end) 
				-
		avg( case
				when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end)
				as float) as review_score_gap

from orders o
join order_items oi
	on o.order_id = oi.order_id
left join order_reviews r
	on o.order_id = r.order_id
join products p
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
	and o.order_estimated_delivery_date is not null
	and o.order_delivered_customer_date is not null
group by 
	pct.product_cat_name_eng
	
having count(distinct o.order_id)>=100
order by 
	review_score_gap desc;			

--category priority score
select top 20
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue,
	count(distinct case	
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then o.order_id end ) as On_time_orders,
	count(distinct case	
			when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) as late_orders,
	avg(cast(r.review_score as decimal(10,2))) as avg_review_score,
	round(avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end),2) as avg_on_time_review,
	round(avg( case
			when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end),2) as avg_late_review,
		
	cast(
		avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end) 
				-
		avg( case
				when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end)
				as float) as review_score_gap,
	cast(
		count (distinct case
				 when order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end) *100.0 /count(distinct o.order_id) as decimal(10,2))
				 as late_delivery_rate,
	case
		when count(distinct case	
			when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) >= 200 and
			cast(
		avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end) 
				-
		avg( case
				when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end)
				as float) >=1.5
				then 'High priority' 
			when count(distinct case	
							when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) >=100 and 
			cast(
		avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end) 
				-
		avg( case
				when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end)
				as float)>=1.0 
					then 'Medium Priority'
			else 'Low Priority' end  as	priority_levels

from orders o
join order_items oi
	on o.order_id = oi.order_id
left join order_reviews r
	on o.order_id = r.order_id
join products p
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
	and o.order_estimated_delivery_date is not null
	and o.order_delivered_customer_date is not null
group by 
	pct.product_cat_name_eng
	
having count(distinct o.order_id)>=100
order by 
	review_score_gap desc;

--category performance summary
select 
	pct.product_cat_name_eng as product_category,
	count(distinct o.order_id) as total_orders,
	cast(
		sum(oi.price + oi.freight_value) as decimal(10,2)
		) as Total_revenue,
	cast(
		sum(oi.price + oi.freight_value)/count(distinct o.order_id)
				as decimal(10,2)) as AOV,
	count(distinct case	
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then o.order_id end ) as On_time_orders,
	count(distinct case	
			when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) as late_orders,
	cast(
		avg(case when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast( datediff(day,o.order_estimated_delivery_date, o.order_delivered_customer_date)as float) end)as float) as avg_late_delay_days,
	avg(cast(r.review_score as decimal(10,2))) as avg_review_score,
	round(avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end),2) as avg_on_time_review,
	round(avg( case
			when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end),2) as avg_late_review,
		
	cast(
		avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end) 
				-
		avg( case
				when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end)
			as decimal(10,2))	 as review_score_gap,
	cast(
		count (distinct case
				 when order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end) *100.0 /count(distinct o.order_id) as decimal(10,2))
				 as late_delivery_rate,
	case
		when count(distinct case	
			when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) >= 200 and
			cast(
		avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end) 
				-
		avg( case
				when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end)
				as float) >=1.5
				then 'High priority' 
			when count(distinct case	
							when o.order_delivered_customer_date > o.order_estimated_delivery_date then o.order_id end ) >=100 and 
			cast(
		avg( case
			when o.order_delivered_customer_date <= o.order_estimated_delivery_date then cast(r.review_score as float) end) 
				-
		avg( case
				when o.order_delivered_customer_date > o.order_estimated_delivery_date then cast(r.review_score as float) end)
				as float)>=1.0 
					then 'Medium Priority'
			else 'Low Priority' end  as	priority_levels

from orders o
join order_items oi
	on o.order_id = oi.order_id
left join order_reviews r
	on o.order_id = r.order_id
join products p
	on oi.product_id = p.product_id
left join product_category_name_translation pct
	on p.product_category_name = pct.product_cat_name

where 
	o.order_status = 'delivered'
	and o.order_estimated_delivery_date is not null
	and o.order_delivered_customer_date is not null
group by 
	pct.product_cat_name_eng
	
having count(distinct o.order_id)>=100
order by 
	late_orders desc;
