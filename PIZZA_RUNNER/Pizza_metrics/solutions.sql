--1. How many pizzas were ordered?
SELECT COUNT(PIZZA_ID) AS TOTAL_PIZZA_ORDER FROM DBO.CUSTOMER_ORDERS;

--2 How many unique customer orders were made?
SELECT COUNT(DISTINCT ORDER_ID) FROM DBO.CUSTOMER_ORDERS;

--3 How many successful orders were delivered by each runner?
select runner_id, count(order_id) as success_order
from dbo.runner_orders
where cancellation is null
group by runner_id;

--4. How many of each type of pizza was delivered?
select n.pizza_name, count(*) as no_of_pizza_delivered
from (dbo.runner_orders r inner join dbo.customer_orders c on r.order_id=c.order_id)
inner join dbo.pizza_names n on c.pizza_id=n.pizza_id
where r.cancellation is null
group by n.pizza_name;

--5 How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id, n.pizza_name, count(n.pizza_name) as no_of_orders
from (dbo.runner_orders r inner join dbo.customer_orders c on r.order_id=c.order_id)
inner join dbo.pizza_names n on c.pizza_id=n.pizza_id
group by c.customer_id, n.pizza_name;

--6 What was the maximum number of pizzas delivered in a single order?
select top(1) order_id, count(pizza_id) as no_of_pizza_delivered
from dbo.customer_orders
group by order_id
order by count(pizza_id) desc;

--7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id,
 sum(case when c.exclusions is not null or c.extras is not null then 1 else 0 end) as with_changes,
 sum(case when c.exclusions is null and c.extras is null then 1 else 0 end) as without_changes
 from dbo.customer_orders c inner join dbo.runner_orders r on c.order_id=r.order_id
 where r.cancellation is NULL
 group by customer_id;
 
 --8. How many pizzas were delivered that had both exclusions and extras?
 select sum(c.pizza_id) as total_pizzas
from (dbo.customer_orders c inner join dbo.runner_orders r on c.order_id=r.order_id)
where r.cancellation is null
and (c.exclusions is not null and c.extras is not null);

--9. What was the total volume of pizzas ordered for each hour of the day?
select DATEPART(HOUR, order_time) as hour_of_day,
count(pizza_id) as volume
from dbo.customer_orders
group by DATEPART(HOUR, order_time)
order by DATEPART(HOUR, order_time);

--10. What was the volume of orders for each day of the week?
select DATENAME(WEEKDAY, order_time) as hour_of_day,
count(pizza_id) as volume
from dbo.customer_orders
group by DATENAME(WEEKDAY, order_time)
order by DATENAME(WEEKDAY, order_time);
