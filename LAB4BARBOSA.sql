--1. Get the cities of agents booking an order for a customer whose cid is ‘c002’
select city
from agents
where aid in (select aid 
	      from orders
	      where cid = 'c002');
--2. Get the ids of products ordered through any agent who takes at least one order from a customer in 
--Dallas, sorted by pid from highest to lowest. (This is not the same as asking for ids of products ordered
--by customers in Dallas.)
select distinct pid
from orders
where aid in (select aid 
	      from orders
	      where cid IN (select cid
		            from customers
		            where city = 'Dallas'))
		            order by pid desc;
--3. Get the ids and names of customers who did not place an order through agent a01.
select cid,name
from customers
where cid not in (select cid
	   from orders
	   where aid = 'a01');
--4. Get the ids of customers who ordered both product p01 and p07.
select distinct cid
from orders
where cid in (select cid
	      from orders
	      where pid = 'p01'
intersect    
	      select cid
	      from orders
	     where pid = 'p07');
--5. Get the ids of products not ordered by any customers who placed any order through agent a07 in pid
--order from highest to lowest.
select distinct pid
from orders
where cid not in(select cid
		  from orders
		  where aid = 'a07')
		  order by pid desc;
--6. Get the name, discounts, and city for all customers who place orders through agents in London or NewYork.
select name, discount, city
from customers
where cid in (select cid
	      from agents
	      where city = 'London' or city = 'New York');
--7. Get all customers who have the same discount as that of any customers in Dallas or London
SELECT name
FROM customers
WHERE discount IN (SELECT discount
                   FROM customers
                   WHERE city = 'Dallas'
                   OR city = 'London');
--Check constraints in sql allow the user to set a range for the value inputted for whatever the set datatype is. These are useful because they set a limit to the value range for the data. Implementing proper check constraints in
a database can help organize and structure the data being put into the columns. This is done by defining a check constraint.
Once a check constraint is defined for a column, only certain values are allowed for this column. An example of a good 
check constraint would be Varchar(3) for a column containing a 3 digit ID. Using the same ID column example from the previous 
example, a bad constraint would be varchar(255). This would be a bad constraint because the ID will always only be 3 digits, so it
is unnecessary to have a range of 255.


                  
		            
		            
		
