create database pizzahut;
use pizzahut;
create table orders(
order_id int not null primary key,
order_date date not null,
order_time time not null);

create table order_details(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);


-- Retrieve the total number of orders placed.
select count(order_id) from orders;


-- Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as tot_revenue
from order_details 
join pizzas
on order_details.pizza_id=pizzas.pizza_id;


-- Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
from pizzas
join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc
limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_id) as common_size
from pizzas
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size
order by count(order_details.order_id) desc
limit 1;


-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(order_details.quantity) as tot_q
from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by tot_q desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category,sum(order_details.quantity) as total_q
from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category
order by total_q desc;


-- Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as tot_orders
from orders 
group by hour(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.


select round(avg(quantity),1) from
(select orders.order_date,sum(order_details.quantity) as quantity
from orders
join order_details
on orders.order_id=order_details.order_id
group by orders.order_date) as order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.

select pizzas.pizza_type_id,sum((order_details.quantity*pizzas.price)) as revenue
from pizzas
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizzas.pizza_type_id
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
 round(sum(order_details.quantity*pizzas.price) / (SELECT
ROUND(SUM(order_details.quantity * pizzas.price),
2) AS total_sales

from order_details
JOIN
pizzas ON pizzas.pizza_id = order_details.pizza_id) *100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;


-- Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;

