create database pizza_hut;
use pizza_hut;

select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

# Q1) Retrieve the total number of orders placed.
select count(*) as "total_order" from orders;

# Q2) Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(order_details.quantity * pizzas.price) AS 'total revenue'
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

# Q3) Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

# Q4) Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(order_details.order_id) AS 'most common'
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY COUNT(order_details.order_id) DESC
LIMIT 1;

# Q5) List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS 'total quantity'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

# Q6) Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS 'total quantity'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

# Q7) Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders.time) AS 'hour',
    COUNT(orders.order_id) AS 'total order'
FROM
    orders
GROUP BY 1
ORDER BY 2 DESC;

# Q8) Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pizza_types.category,
    COUNT(orders.order_id) AS 'total orders'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY 1
ORDER BY 2 DESC;

# Q9) Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(order_details.quantity) AS 'average order'
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS 'sum_quantity'
    FROM
        order_details
    JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY orders.date);


# Q10) Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS 'revenue'
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

# Q11) Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS 'total sales'
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS 'revenue'
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

# Q12) Analyze the cumulative revenue generated over time.
select date, sum(revenue) over(order by date) as "cumulative_revenue"
from
(select orders.date, sum(order_details.quantity * pizzas.price) as "revenue"
from order_details
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by orders.date) as daily_order_revenue;

# Q13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, category, revenue from

(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = order_details.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn <= 3;
