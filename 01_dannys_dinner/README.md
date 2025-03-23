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

**01.What is the total amount each customer spent at the restaurant?

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
"A"	76
"B"	74
"C"	36  
