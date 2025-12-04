/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--these solutions are executed on SQL Server database with schema name as dbo

--1. What is the total amount each customer spent at the restaurant?
SELECT   customer_id,
         sum(price) AS total_sales
FROM     dbo.menu m INNER JOIN dbo.sales s on m.product_id=s.product_id
GROUP BY customer_id
ORDER BY customer_id;

--2. How many days has each customer visited the restaurant?
select s.customer_id, datediff(day, min(s.order_date), max(s.order_date)) as total_no_days
from dbo.sales s
group by customer_id;
--3. What was the first item from the menu purchased by each customer?
with ranked_rows as (
select s.customer_id, s.order_date, s.product_id, m.product_name, rank() over (partition by s.customer_id order by order_date) as rank_
from dbo.sales s inner join dbo.menu m
on s.product_id=m.product_id)

select customer_id, product_name
from ranked_rows
where rank_=1
group by customer_id, product_name;
--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select top(1) m.product_name, count(*) as num_of_times_purchased
from dbo.sales s inner join dbo.menu m on s.product_id=m.product_id
group by m.product_name
order by count(*) desc;
--5. Which item was the most popular for each customer?
with partitioned_data as (
select s.customer_id, m.product_name, count(m.product_id) as order_count, rank() over (partition by s.customer_id order by count(m.product_id) desc) as rank_
from dbo.sales s inner join dbo.menu m on s.product_id=m.product_id
group by s.customer_id, m.product_name)

select customer_id, product_name, order_count
from partitioned_data
where rank_=1;
--6. Which item was purchased first by the customer after they became a member?
with data as (
select s.customer_id, m.product_name, rank() over (partition by s.customer_id order by datediff(day, mm.join_date, s.order_date)) as first_purchased
from (dbo.sales s inner join dbo.menu m  on s.product_id=m.product_id)
inner join dbo.members mm on s.customer_id=mm.customer_id
where s.order_date>=mm.join_date)

select customer_id, product_name
from data
where first_purchased=1;
--7. Which item was purchased just before the customer became a member?
with data as (
select s.customer_id, m.product_name, rank() over (partition by s.customer_id order by s.order_date) as first_purchased
from (dbo.sales s inner join dbo.menu m  on s.product_id=m.product_id)
inner join dbo.members mm on s.customer_id=mm.customer_id
where s.order_date<mm.join_date)

select customer_id, product_name
from data
where first_purchased=1;
--8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(s.product_id) as total_items, sum(p.price) as total_amount
from (dbo.sales s inner join dbo.menu p on s.product_id=p.product_id)
inner join dbo.members m on s.customer_id=m.customer_id
where s.order_date<m.join_date
group by s.customer_id;
--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with data as (
select s.customer_id,
case when m.product_name='sushi' then m.price*10*2
else m.price*10
end as amount
from dbo.sales s inner join dbo.menu m
on s.product_id=m.product_id)

select customer_id, sum(amount)
from data
group by customer_id;
--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with points_to_customers as (
select s.customer_id, s.product_id, p.price, s.order_date,
case when (s.order_date between m.join_date and DATEADD(day, 6, m.join_date)) then p.price*2*10
when (s.order_date not between m.join_date and DATEADD(day, 6, m.join_date)) and p.product_name='sushi' then p.price*2*10
when (s.order_date not between m.join_date and DATEADD(day, 6, m.join_date)) and p.product_name!='sushi' then p.price*10
end as total_points
from (dbo.sales s inner join dbo.menu p on s.product_id=p.product_id)
inner join dbo.members m on s.customer_id=m.customer_id
where s.order_date<= '2021-01-31' and s.order_date >= m.join_date
)

select customer_id, sum(total_points) as Total
from points_to_customers
group by customer_id;

--bonus question 1:
--The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
select s.customer_id, s.order_date, p.product_name, p.price,
case when s.order_date>=m.join_date then 'Y'
else 'N'
end as member_
from (dbo.sales s inner join dbo.menu p on s.product_id=p.product_id)
left outer join dbo.members m on m.customer_id=s.customer_id;

--bonus question 2:
--Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking 
--values for the records when customers are not yet part of the loyalty program.
with data_ as (select s.customer_id, s.order_date, p.product_name, p.price,
case when s.order_date>=m.join_date then 'Y'
else 'N'
end as member_
from (dbo.sales s inner join dbo.menu p on s.product_id=p.product_id)
left outer join dbo.members m on m.customer_id=s.customer_id)

select customer_id, order_date, product_name, price, member_,
case when member_='Y' then rank() over (partition by customer_id, member_ order by order_date)
else null 
end as ranking
from data_;

