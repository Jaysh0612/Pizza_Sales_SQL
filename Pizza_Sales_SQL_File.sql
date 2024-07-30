CREATE DATABASE Pizzahut;

USE pizzahut;

Create table Orders(
Order_id int Not Null,
Orders_date date Not Null,
Orders_time time Not Null,
primary key(Order_id)
);


Create table Order_details(
Order_details_id int Not Null,
Order_id int Not Null,
Pizza_id text Not Null,
Quantity int Not Null,
primary key(Order_details_id)
);

# Quetions & Answers:-
-- 1) Retierve the total number of orders placed
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- 2) Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_Sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- 3) Identify the highest-priced pizza.
SELECT 
    Pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4) Identify the most common pizza size ordered.
SELECT 
    Pizzas.size,
    COUNT(order_details.order_details_id) AS Order_Count
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Pizzas.size
ORDER BY Order_Count DESC;

-- 5) List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS Quantities
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantities DESC
LIMIT 5;
----------------------------------------------------------------------------------------------------------

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders_time) AS Hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(orders_time);

-- Join relevant tables to find the category-wise distribution of pizzas
SELECT 
    Category, COUNT(name) AS Pizzas
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average 
-- number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantiy), 0) AS Pizzas_order_per_day
FROM
    (SELECT 
        orders.orders_date, SUM(order_details.quantity) AS quantiy
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.orders_date) AS Order_Quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.Name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON Pizza_types.Pizza_type_id = Pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.Name
ORDER BY Revenue DESC
LIMIT 3;

----------------------------------------------------------------------------------

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS Total_Sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = Pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

----------------------------------------------------------------------------------------------------------
-- Analyze the cumulative revenue generated over time.

SELECT orders_date, SUM(revenue) OVER(Order BY orders_date) AS Cumulative_Revenue
FROM
(SELECT orders.orders_date,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN orders ON orders.order_id = order_details.order_id GROUP BY orders.orders_date) AS Sales;

----------------------------------------------------------------------------------------------------------
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT Category, Name, Revenue, Top_3_Rank
FROM
(SELECT Category, Name, Revenue,
rank() over(partition by category order by revenue desc) as Top_3_Rank
FROM
(SELECT pizza_types.category, Pizza_types.name,
SUM(order_details.Quantity * pizzas.price) AS Revenue
FROM pizza_types JOIN Pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id JOIN Order_details
ON order_details.pizza_id = Pizzas.pizza_id
GROUP BY pizza_types.category, Pizza_types.name) AS A) AS B
WHERE Top_3_Rank <=3;