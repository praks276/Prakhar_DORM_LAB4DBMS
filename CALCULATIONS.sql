use `new-order-directory`;

----------------Display the total number of customers based on gender who have placed orders of worth at least Rs.3000.-------------
SELECT COUNT(t2.cus_gender) as NoOfCustomers, t2.cus_gender FROM 
(SELECT t1.cus_id, t1.cus_gender, t1.ord_amount, t1.cus_name FROM 
(SELECT `order`.*, customer.cus_gender, customer.cus_name FROM `order` inner join customer where `order`.cus_id=customer.cus_id having `order`.ord_amount>=3000)
as t1  group by t1.cus_id) as t2 group by t2.cus_gender;



-------------------Display all the orders along with product name ordered by a customer having Customer_Id=2------------
select product.pro_name, `order`.* from `order`, supplier_pricing, product 
where `order`.cus_id=2 and 
`order`.pricing_id=supplier_pricing.pricing_id and supplier_pricing.pro_id=product.pro_id;


---------------------Display the Supplier details of who is supplying more than one product.-----------------------
select supplier.* from supplier where supplier.supp_id in 
	(select supp_id from supplier_pricing group by supp_id having 
	count(supp_id)>1) 
group by supplier.supp_id;


---------------------Find the least expensive product from each category and print the table with category id, name, and price of the product
select category.cat_id,category.cat_name, min(t3.min_price) as Min_Price from category inner join
(select product.cat_id, product.pro_name, t2.* from product inner join  
(select pro_id, min(supp_price) as Min_Price from supplier_pricing group by pro_id) 
as t2 where t2.pro_id = product.pro_id)
as t3 where t3.cat_id = category.cat_id group by t3.cat_id;


------------------Display the Id and Name of the Product ordered after “2021-10-05”. -------------
select product.pro_id,product.pro_name from `order` inner join supplier_pricing on supplier_pricing.pricing_id=`order`.pricing_id inner join product on product.pro_id=supplier_pricing.pro_id where `order`.ord_date>"2021-10-05";

-----------------Display customer name and gender whose names start or end with character 'A'.-------------
select customer.cus_name,customer.cus_gender from customer where customer.cus_name like 'A%' or customer.cus_name like '%A';

-------------Create a stored procedure to display supplier id, name, rating and Type_of_supplier. If rating >4 then “Genuine Supplier” if rating >2 “Average Supplier” else “Supplier should not be considered”.---

DELIMITER &&  
CREATE PROCEDURE proc()
BEGIN
select report.supp_id,report.supp_name,report.Average,
CASE
	WHEN report.Average =5 THEN 'Excellent Service'
    	WHEN report.Average >4 THEN 'Good Service'
    	WHEN report.Average >2 THEN 'Average Service'
    	ELSE 'Poor Service’
END AS Type_of_Service from 
(select final.supp_id, supplier.supp_name, final.Average from
(select test2.supp_id, sum(test2.rat_ratstars)/count(test2.rat_ratstars) as Average from
(select supplier_pricing.supp_id, test.ORD_ID, test.RAT_RATSTARS from supplier_pricing inner join
(select `order`.pricing_id, rating.ORD_ID, rating.RAT_RATSTARS from `order` inner join rating on rating.`ord_id` = `order`.ord_id ) as test
on test.pricing_id = supplier_pricing.pricing_id) 
as test2 group by supplier_pricing.supp_id) 
as final inner join supplier where final.supp_id = supplier.supp_id) as report;
END &&  
DELIMITER ;  

call proc();

