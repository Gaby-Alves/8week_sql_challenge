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
SELECT a.customer_id, b.product_name, count(*)
FROM sales a
LEFT JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id, b.product_name
--Which item was purchased first by the customer after they became a member?
--Which item was purchased just before the customer became a member?
--What is the total items and amount spent for each member before they became a member?
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?