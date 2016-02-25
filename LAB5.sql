--1. Show the cities of agents booking an order for a customer whose id is 'c002'. Use joins; no subqueries 
select agents.city
from agents,customers
where customers.cid = 'c002';

--2. Show the ids of products ordered through any agent who makes at least one order for a customer in Dallas, sorted
--by pid from highest to lowest. Use joins; no subqueries
select pid
from orders
join customers
on orders.cid = customers.cid
where orders.cid = 'c002'
or orders.cid = 'c003'
order by pid desc;

--3. Show the names of customers who have never placed an order. Use a subquery
select name
from customers
where customers.cid NOT in (select cid
			      from orders);

--4. Show the names of customers who have never placed an order. Use an outer join
select name
from customers
full outer join orders
on customers.cid=orders.cid
where customers.cid NOT in (select cid
		from orders);

--5. Show the names of customers who placed at least one order through an agent in their own city, 
--along with those agent(s') names.
select distinct customers.name, agents.name
from customers, agents, orders
where orders.cid = customers.cid
and agents.aid = orders.aid
and agents.city = customers.city;

--6. Show the names of customers and agents living in the same city, along with the name of the shared 
-- city, regardless of whether or not the customer has ever placed an order with that agent.
select c.name, a.name
from customers as c, agents as a
where c.city = a.city;
--7. Show the name and city of customers who live in the city that makes the fewest different kinds of products.
select city
from products
group by city
order by count(pid)
limit 1;

			      
		             
	   

