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
- Precisamos de uma CTE ou uma subquery para primeiro criar a ordenação e depois a partir dessa tabela com ordenação podermos filtrar pelo primeiro row.
- O dense_rank com over partition vai fazer uma contagem agrupada por customer porém se o mesmo item se existir mais de um produto na mesma data o dense_rank vai atribuir o mesmo número, diferente do rank() que criaria os ranks com base nos valores que fossem aparecendo, se houvesse repetição ele atribuiria um número e na próxima repetição seria número + 1.
#### Resposta
| customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |
