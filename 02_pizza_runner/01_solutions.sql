SET search_path = pizza_runner;

--A. Pizza Metrics
--How many pizzas were ordered?
select count(*) as qtd_pizza from customer_orders;

--How many unique customer orders were made?
select count(distinct customer_id) as qtd_customers from customer_orders;
--How many successful orders were delivered by each runner?
select runner_id, 
count(*) as successful_orders
from(
select*,
case
when cancellation is null  
or cancellation = ''
or cancellation = 'null'then 1
ELSE 0 END flg_order
from runner_orders )
as sub_query
where flg_order = 1
group by runner_id;
--How many of each type of pizza was delivered?
select pizza_name, 
count(*) as successful_orders
from(
select a.order_id,
b.customer_id, 
b.pizza_id,
c.pizza_name,
case
when a.cancellation is null  
or a.cancellation = ''
or a.cancellation = 'null'then 1
ELSE 0 END flg_order
from runner_orders a
left join customer_orders b
on a.order_id = b.order_id
left join pizza_names c
on b.pizza_id = c.pizza_id)
as sub_query
where flg_order = 1
group by pizza_name;

--How many Vegetarian and Meatlovers were ordered by each customer?
select a.customer_id,
b.pizza_name,
count(*) as qtd
from customer_orders a
left join pizza_names b
on a.pizza_id = b.pizza_id
group by a.customer_id, b.pizza_name
order by a.customer_id, b.pizza_name;
--What was the maximum number of pizzas delivered in a single order?
select a.order_id,
count(a.pizza_id) as qtd
from customer_orders a
join (
select*,
case
when cancellation is null  
or cancellation = ''
or cancellation = 'null'then 1
ELSE 0 END flg_order
from runner_orders 
) as tmp
on a.order_id  = tmp.order_id
group by a.order_id
order by qtd desc
limit 1;
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

--How many pizzas were delivered that had both exclusions and extras?
--What was the total volume of pizzas ordered for each hour of the day?
--What was the volume of orders for each day of the week?

--B. Runner and Customer Experience
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--Is there any relationship between the number of pizzas and how long the order takes to prepare?
--What was the average distance travelled for each customer?
--What was the difference between the longest and shortest delivery times for all orders?
--What was the average speed for each runner for each delivery and do you notice any trend for these values?
--What is the successful delivery percentage for each runner?
--C. Ingredient Optimisation
--What are the standard ingredients for each pizza?
--What was the most commonly added extra?
--What was the most common exclusion?
--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
--D. Pricing and Ratings
--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
--What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra
--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
--Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas
--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
--E. Bonus Questions
--If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?