CREATE DATABASE pizza_sales;
USE pizza_sales;
select * from orders;

#Retrieve the total number of orders placed.
Select count(order_id) as total_orders FROM orders;

#Calculate the total revenue generated from pizza sales.
Select round(sum(order_details.quantity * pizzas.price),2) as total_sales
from order_details join pizzas 
on pizzas.pizza_id = order_details.pizza_id ;

#Identify the highest-priced pizza.
Select pizza_types.name ,pizzas.price 
from pizza_types join pizzas 
on pizzas.pizza_type_id=pizza_types.pizza_type_id 
order by pizzas.price desc limit 1 ;

#Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details 
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by order_count desc;

#List the top 5 most ordered pizza types along with their quantities
SELECT pizza_types.name, SUM(order_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name 
ORDER BY quantity DESC 
LIMIT 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,
sum(order_details.quantity) as quantity
from pizza_types 
join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id 
join order_details 
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by quantity desc;

#Determine the distribution of orders by hour of the day.
Select hour(time), count(order_id) as order_count from orders
group by hour(time);

#Join relevant tables to find the category-wise distribution of pizzas.
 select category , count(name) from pizza_types
 group by category ;
 
#Group the orders by date and calculate the average number of pizzas ordered per day.
Select avg(quantity) as average_quantity from
(select orders.date , sum(order_details.quantity) as quantity
from orders join order_details 
on orders.order_id=order_details.order_id 
group by orders.date) as order_quantity;

#Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue from pizza_types 
join pizzas on pizzas.pizza_type_id= pizza_types.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

#Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
       round((SUM(order_details.quantity * pizzas.price) /
       (SELECT SUM(order_details.quantity * pizzas.price)
        FROM order_details
        JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,2) AS total_percentage
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_percentage DESC;

#Analyze the cumulative revenue generated over time.
SELECT date,
       SUM(revenue) OVER (ORDER BY date) AS cum_revenue
FROM (
    SELECT orders.date,
           SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS sales;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Select name , revenue from
(select category, name, revenue,rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas 
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on order_details.pizza_id =pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b 
where rn<4 ;

 





