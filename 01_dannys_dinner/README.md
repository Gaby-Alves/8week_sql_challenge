# 🍜 Case Study 01: Danny's Diner

![image](https://8weeksqlchallenge.com/images/case-study-designs/1.png)
---
# Introdução
Em 2021 Danny decidiu abrir um restaurante de comida japonesa que vende as suas 3 comidas favoritas: sushi, curry e ramen.

---
## Definição do problema
Danny quer usar os dados para responder algumas questões simples sobre os seus consumidores, especialmente sobre os seus padrões de visita, quanto eles gastam e qual é o item favorito deles.
Esse conhecimento profundo de seus clinetes irá ajudar a entregar uma experiência mais personalizada para os seus clientes leais.
Ele planeja usar esses insights para ajudá-lo a decidir se ele deveria expandir o atual programa de fidelidade para os seus clientes leais.

---
## Relacionamento entre as tabelas
![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

---
## Questões e soluções
Para responder as questões foi utilizado o PostgreSQL.

**1. What is the total amount each customer spent at the restaurant?**

````sql
SELECT a.customer_id, 
sum(b.price) as total_sales
FROM sales a 
LEFT JOIN menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id
ORDER BY a.customer_id;
````
#### Passo a passo 🦶🦶:
- Dado que precisamos do preço para saber quanto cada cliente gastou no restaurante, precisamos fazer um join com a tabela de produtos partindo da tabela de vendas.
- A partir do momento que temos essa informação poodemos fazer o somatório das vendas através do preço.
- Por fim precisamos agregar por cliente.

##### Resposta:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---

**2. How many days has each customer visited the restaurant?**
````sql
SELECT customer_id, count(DISTINCT ORDER_DATE) as visits
FROM SALES
GROUP BY customer_id 
ORDER BY customer_id;
````
#### Passo a passo 🦶🦶:
- Para determinar o número de visitas é necessário fazer um count() utilizando o distinct, visto que o mesmo cliente pode ter pedido maios de um pedido no mesmo dia ou até mesmo visitado 2x no mesmo dia.
#### Resposta
| customer_id | visits |
|-------------|--------|
| A           | 4      |
| B           | 6      |
| C           | 2      |

---
**3.What was the first item from the menu purchased by each customer?**
````sql
WITH sales_ranked AS (SELECT  a.*,b.product_name,
DENSE_RANK() OVER(PARTITION BY a.customer_id ORDER BY a.order_date) AS row_num
FROM sales a
LEFT JOIN menu b
ON a.product_id = b.product_id )

SELECT customer_id, product_name
FROM sales_ranked 	
WHERE row_num = 1
GROUP BY customer_id, product_name;
````
#### Passo a passo 🦶🦶:
- Precisamos de uma CTE ou uma subquery para primeiro criar a ordenação e depois a partir dessa tabela com ordenação podermos filtrar pelo primeiro row.
- O dense_rank com over partition vai fazer uma contagem agrupada por customer porém se o mesmo item se existir mais de um produto na mesma data o dense_rank vai atribuir o mesmo número, diferente do rank() que criaria os ranks com base nos valores que fossem aparecendo, se houvesse repetição ele atribuiria um número e na próxima repetição seria número + 1.
#### Resposta
| customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---
**4.What is the most purchased item on the menu and how many times was it purchased by all customers?**
````sql
WITH product_counts AS(
SELECT b.product_name as,
COUNT(*) AS qtd
FROM sales a
LEFT JOIN menu b
ON a.product_id = b.product_id
GROUP BY product_name)

SELECT *
FROM product_counts
WHERE qtd = (SELECT MAX(qtd) FROM product_counts);
````
#### Passo a passo 🦶🦶:
- Precisamos criar uma CTE ou uma subquery para criar a contagem de itens.
- Depois acessamos essa tabela e pegamos o valor máximo através de uma subquery, pois precisamos calcular o máximo para poder comparar.
#### Resposta
| product_name | qtd |
|--------------|-----|
| ramen        | 8   | 
---

**5.Which item was the most popular for each customer?**
````sql
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

SELECT customer_id, product_name, qtd
FROM tmp1 
WHERE dense_rank = 1;
````
#### Passo a passo 🦶🦶:
- Precisamos criar 2 CTEs, uma inicialmente apenas com a seleção de consumidor, produto e a contagem por consumidor.
- Depois uma segunda para incluir o dense_rank.
- Por fim acessamos a última CTE para pegar o primeiro registro através do DENSE_RANK(), que vai rankear a partiar do customer a contagem.
- Foi utilizado o dense_rank() em vez do row_number() visto que pode haver repetição.
#### Resposta
| customer_id | product_name | qtd |
|-------------|--------------|-----|
| A           | ramen        | 3   |
| B           | ramen        | 2   |
| B           | sushi        | 2   |
| B           | curry        | 2   |
| C           | ramen        | 3   |
---

**6.Which item was purchased first by the customer after they became a member?**
````sql
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
````
#### Passo a passo 🦶🦶:
- Primeiro criamos uma tabela CTE que traga o customer_id, produto e a order de compra.
- Usamos o dense rank para ordernar por consumidor a partir do order date
- Filtramos a order_date que tem que ser maior que a data que o consumidor entrou para a base de membros.
#### Resposta
| customer_id | product_name |
|-------------|--------------|
| A           | ramen        |
| B           | sushi        |
---

**7.Which item was purchased just before the customer became a member?**
````sql
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
````
#### Passo a passo 🦶🦶:
- Bem similar com a query anterior, mudamos apenas o where do para pegar pedidos antriores a data de entrada no programa de membros.
- E dessa vez fazemos um dense rank decrescente para pegar a última compra antes de se tornar membro.
#### Resposta
| customer_id | product_name |
|-------------|--------------|
| A           | sushi        |
| A           | curry        |
| B           | sushi        |
---

**8. What is the total items and amount spent for each member before they became a member?**
````sql
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
````
#### Passo a passo 🦶🦶:
- Primeiro precisamos de uma tabela CTE para criar o campo de qtd, que é a quantidade de pedidos por customer.
- Agrupamos por customer e também por preço, pois vamos usar o preço depois.
- Usamos a tabela criada para criar tanto a soma total da quantidade quanto de preço e agrupamentos apenas por customer.


#### Resposta
| customer_id | total_qtd | total_sum |
|-------------|-----------|-----------|
| A           | 2         | 25        |
| B           | 3         | 40        |

---
**9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
````sql
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
````

#### Passo a passo 🦶🦶:
- Criamos uma tabela CTE para criar o novo campo chamado points com as regras de acordo com o produto.
- Depois usamos essa tabela e agrupamos por customer id e somamos o pontos.

#### Resposta
| customer_id | total_pts |
|-------------|-----------|
| A           | 860       |
| B           | 940       |
| C           | 360       |

----
***10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?***
````sql
-- criando as regras de preços
with tmp as(
select 
a.customer_id,
a.order_date,
c.join_date,
c.join_date + 6 as end_week_promo,
date('2021-01-31') as end_jan,
b.price,
b.product_name
from sales a
left join menu b
on a.product_id = b.product_id
left join members c
on a.customer_id = c.customer_id
)

select customer_id,
sum(case 
when product_name = 'sushi' then price * 2 * 10
when order_date between join_date and end_week_promo then price * 2 * 10
else price * 10
end ) as total_pts
from tmp

where order_date >= join_date AND order_date <= end_jan
group by customer_id;

````

#### Passo a passo 🦶🦶:
- Primeiro criamos uma tabela com as datas especiais e os campos que usaremos..
- Depois criamos um case when com as condições e já somamos.
- Por fim filtramos as datas e agrupamos por cliente.
#### Resposta
| customer_id | total_pts |
|-------------|-----------|
| A           | 1020      |
| B           | 320       |

