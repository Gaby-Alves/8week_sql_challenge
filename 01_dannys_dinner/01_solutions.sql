-- Setando o schema
SET search_path = dannys_diner;

-- 01.What is the total amount each customer spent at the restaurant?
--select * from sales;
--select * from menu;

SELECT a.customer_id, 
sum(price) as total 
FROM sales a 
LEFT JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id
ORDER BY a.customer_id;


-- 02. How many days has each customer visited the restaurant?
SELECT * from sales;
SELECT customer_id, count(DISTINCT ORDER_DATE) 
FROM SALES
GROUP BY customer_id 
ORDER BY customer_id;

-- 03.What was the first item from the menu purchased by each customer?
WITH sales_ranked AS (SELECT  a.*,b.product_name,
DENSE_RANK() OVER(PARTITION BY a.customer_id ORDER BY a.order_date) AS row_num
FROM sales a
LEFT JOIN menu b
ON a.product_id = b.product_id )
SELECT customer_id, product_name
FROM sales_ranked 	
WHERE row_num = 1
GROUP BY customer_id, product_name;

-- 04.What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH product_counts AS(
SELECT b.product_name,
COUNT(*) AS qtd
FROM sales a
LEFT JOIN menu b
ON a.product_id = b.product_id
GROUP BY product_name)

SELECT *
FROM product_counts
WHERE qtd = (SELECT MAX(qtd) FROM product_counts);

--05.Which item was the most popular for each customer?
WITH tmp AS (SELECT a.customer_id, b.product_name, count(*) AS qtd
FROM sales a
LEFT JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id, b.product_name
ORDER BY a.customer_id, qtd DESC
),

tmp1 as(SELECT *,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY qtd DESC
)
FROM tmp
)

SELECT *
FROM tmp1 
WHERE dense_rank = 1;

--06.Which item was purchased first by the customer after they became a member?
with tmp as (select a.customer_id, b.product_name,
dense_rank() over(partition by a.customer_id order by a.order_date) as dense_rank
from sales a
left join menu b
on a.product_id = b.product_id
left join members c
on a.customer_id = c.customer_id
where c.join_date < a.order_date)

select customer_id, product_name from tmp
where dense_rank = 1;

-- 07. Which item was purchased just before the customer became a member?
with tmp as (select a.customer_id, b.product_name,
dense_rank() over(partition by a.customer_id order by a.order_date desc) as rank
from sales a
left join menu b
on a.product_id = b.product_id
left join members c
on a.customer_id = c.customer_id
where c.join_date > a.order_date)

select customer_id, product_name from tmp
where rank = 1;


--08. What is the total items and amount spent for each member before they became a member?
with tmp as (select a.customer_id,
count(*) as qtd,
b.price
from
sales a
left join menu b 
on a.product_id = b.product_id
left join members c
on a.customer_id = c.customer_id
where a.order_date < c.join_date
group by a.customer_id,b.price)


select customer_id,
sum(qtd) as total_qtd,
sum(qtd * price) as total_sum
from tmp
group by customer_id;

-- 09.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with tmp as(select *,
case when
product_name = 'sushi' THEN 10 * 2 * price
ELSE price * 10 END AS points
from sales a
left join menu b
on a.product_id = b.product_id)

select customer_id,
sum(points) as total_pts
from tmp
group by customer_id 
order by customer_id;
-- 10.In the first week after a customer joins the program (including their join date)
--they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select *,
join_date + 6 as first_week
from members;

with tmp as(
select a.customer_id, c.join_date,
case when
product_name = 'sushi' THEN 10 * 2 * price
ELSE price * 10 END AS points,
case when 
product_name <> 'sushi' then price * 10  * 2
ELSE 10 * 2 * price
end as promo,
join_date + 6 as first_week
from sales a
left join menu b
on a.product_id = b.product_id
left join members c 
on a.customer_id = c.customer_id 
where a.customer_id in ('A', 'B')),

tmp2 as (
select customer_id,
case when
join_date >= first_week then promo
else points
end as final_pts
from tmp
)


select customer_id,
sum(final_pts) as pts
from tmp2 
group by customer_id;


--The following questions are related creating basic data tables that Danny and his team can use to quickly
--derive insights without needing to join the underlying tables using SQL.
with tmp as (select a.customer_id, a.order_date, b.product_name,b.price,
case when
a.order_date >= c.join_date then 'Y'
else 'N'
END AS member
from sales a
left join menu b
on a.product_id = b.product_id
left join members c
on a.customer_id = c.customer_id
order by a.customer_id, a.order_date, b.product_name)

--Danny also requires further information about the ranking of customer products
--but he purposely does not need the ranking for non-member purchases so he expects 
--null ranking values for the records when customers are not yet part of the loyalty program.
SELECT *,
       CASE 
           WHEN member = 'N' THEN NULL  -- Retorna um NULL real
           ELSE DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) 
       END AS ranking
FROM tmp