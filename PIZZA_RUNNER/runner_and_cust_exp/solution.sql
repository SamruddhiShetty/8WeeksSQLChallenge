--1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select datepart(week, registration_date) as week_num,
count(runner_id) as num_of_runners
from dbo.runners
group by datepart(week, registration_date)
order by datepart(week, registration_date);

--2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Declare @decimalpoints int = 2;

select r.runner_id, avg(round(cast(datediff(second, c.order_time, r.pickup_time)as float) /60, @decimalpoints)) as avg_time
from dbo.runner_orders r inner join dbo.customer_orders c on r.order_id=c.order_id
group by r.runner_id
order by r.runner_id;

--3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
declare @decimalpoints int = 2;

with data as (select c.order_id, count(c.pizza_id) as pizza_count, round(cast(datediff(second, c.order_time, r.pickup_time) as float)/60, @decimalpoints) as dur_to_prepare
from dbo.customer_orders c inner join dbo.runner_orders r
on c.order_id=r.order_id
where r.cancellation is null
group by c.order_id, c.order_time, r.pickup_time)

select pizza_count, avg(dur_to_prepare) as avg_time_to_prep
from data
group by pizza_count;

--4 What was the average distance travelled for each customer?
select c.customer_id, avg(cast(r.distance as float)) as avg_dist
from dbo.customer_orders c inner join dbo.runner_orders r
on c.order_id=r.order_id
where r.cancellation is null
group by c.customer_id;

--5 What was the difference between the longest and shortest delivery times for all orders?
select max(cast(duration as int))-min(cast(duration as int))
from runner_orders;

--6 What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id, order_id, cast(duration as float)/60 as duration_hr, distance, (cast(distance as float)*60/cast(duration as float)) as avg_speed
from runner_orders
where cancellation is null
order by runner_id;

--7 What is the successful delivery percentage for each runner?
with data as (select runner_id, order_id, case when cancellation is null then 1 else 0 end as delivery_succ
from runner_orders)

select runner_id, (sum(delivery_succ)*100)/count(order_id) as deliv_succ_pct
from data
group by runner_id;
