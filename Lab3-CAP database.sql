--List the ordno and dollars of all orders
select ordno, dollars
from orders;
--List the name and city of agents named Smith
select name, city
from agents
where name ='Smith';
--List the pid,name and priceUSD of products with quantity more than 208,000
select pid,name,priceUSD
from products
where quantity > 208000;
--List the names and cities of customers in Dallas
select name, city
from customers
where city = 'Dallas';
--List the names of agents not in New York and not in Tokyo
select name
from agents
where city <> 'New York'
and city <> 'Tokyo';
--List all data for products not in Dallas or Duluth that cost US$1 or more
select *
from products
where city <> 'Dalls'
and city <> 'Duluth'
and priceUSD >= 1.00;
--List all data for orders in January or March
select *
from orders
where mon IN('jan','mar');
--List all data for orders in February less than US$500
select *
from orders
where mon ='feb'
and dollars < 500.00;
--List all orders form the customer whose cid is C005
select *
from orders
where cid ='c005';







