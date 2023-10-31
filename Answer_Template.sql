--SQL Advance Case Study
select * from DIM_CUSTOMER
select * from DIM_DATE
select * from DIM_LOCATION
select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from FACT_TRANSACTIONS

--Q1--BEGIN 
    
	SELECT L.State, D.YEAR FROM DIM_LOCATION L
	INNER JOIN FACT_TRANSACTIONS F
	ON F.IDLocation=L.IDLocation
	INNER JOIN DIM_DATE D
	ON D.DATE=F.Date
	WHERE YEAR>=2005




--Q1--END

--Q2--BEGIN
   
   SELECT top 1 L.State,COUNT(M.Manufacturer_Name) AS Manufacture_Name FROM DIM_LOCATION L
   INNER JOIN FACT_TRANSACTIONS F
   ON L.IDLocation=F.IDLocation
   INNER JOIN DIM_MODEL MO
   ON MO.IDModel=F.IDModel
   INNER JOIN DIM_MANUFACTURER M
   ON M.IDManufacturer=MO.IDManufacturer
   WHERE L.Country='US' AND M.Manufacturer_Name = 'SAMSUNG'
   GROUP BY State
   order by Manufacture_Name desc





--Q2--END

--Q3--BEGIN      
	
	SELECT count(f.IDCustomer) as No_of_Transactions,l.ZipCode,l.State FROM FACT_TRANSACTIONS f
	inner join DIM_LOCATION l
	on l.IDLocation=f.IDLocation
	group by ZipCode,State

	
   
--Q3--END

--Q4--BEGIN
   
   SELECT TOP 1 M.Manufacturer_Name,MO.Model_Name,MO.Unit_price AS PRICE   FROM DIM_MANUFACTURER M
   INNER JOIN DIM_MODEL MO
   ON M.IDManufacturer=MO.IDManufacturer
   ORDER BY PRICE




--Q4--END

--Q5--BEGIN

   select mo.Model_Name,avg(mo.Unit_price) as avg_price from DIM_MODEL mo
   inner join DIM_MANUFACTURER m
   on m.IDManufacturer=mo.IDManufacturer
   where Manufacturer_Name in
   (select top 5 m.Manufacturer_Name from FACT_TRANSACTIONS f
   inner join DIM_MODEL mo
   on mo.IDModel=f.IDModel
   inner join  DIM_MANUFACTURER m
   on m.IDManufacturer=mo.IDManufacturer
   group by m.Manufacturer_Name
   order by sum(f.Quantity) desc
   )
   group by Model_Name
   order by avg_price desc













--Q5--END

--Q6--BEGIN

   select c.Customer_Name, avg(f.TotalPrice) as avg_amount from DIM_CUSTOMER c
   inner join FACT_TRANSACTIONS f
   on f.IDCustomer=c.IDCustomer
   inner join DIM_DATE d
   on d.DATE=f.Date
   where d.YEAR=2009
   group by Customer_Name
   having avg(f.TotalPrice)>500


--Q6--END
	
--Q7--BEGIN  

  select top 5 mo.Model_Name,count(f.Quantity) as Quantity  from DIM_MODEL mo
  inner join FACT_TRANSACTIONS f
  on f.IDModel=mo.IDModel
  inner join DIM_DATE d
  on d.DATE=f.Date
  where d.YEAR=2008 or d.YEAR=2009 or d.YEAR=2010
  group by Model_Name
  order by Quantity desc


--Q7--END	
--Q8--BEGIN

  select top 2*
  from
  (
  select top 2 m.Manufacturer_Name,sum(f.TotalPrice) as sales,year(f.Date) as Year  from DIM_MODEL mo
  inner join  FACT_TRANSACTIONS f
  on f.IDModel=mo.IDModel
  inner join DIM_MANUFACTURER m
  on m.IDManufacturer=mo.IDManufacturer
  where YEAR(f.Date)=2009
  group by Manufacturer_Name,year(f.date)
  order by sales desc
  union 
  select top 2 m.Manufacturer_Name,sum(f.TotalPrice) as sales,year(f.Date) as Year  from DIM_MODEL mo
  inner join  FACT_TRANSACTIONS f
  on f.IDModel=mo.IDModel
  inner join DIM_MANUFACTURER m
  on m.IDManufacturer=mo.IDManufacturer
  where YEAR(f.Date)=2010
  group by Manufacturer_Name,year(f.date)
  order by sales desc
  ) as A
  order by sales







--Q8--END
--Q9--BEGIN
	
   select m.Manufacturer_Name from DIM_MANUFACTURER m
   inner join DIM_MODEL mo
   on mo.IDManufacturer=m.IDManufacturer
   inner join FACT_TRANSACTIONS f
   on f.IDModel=mo.IDModel
   where YEAR(f.date)=2010
   except
   select m.Manufacturer_Name from DIM_MANUFACTURER m
   inner join DIM_MODEL mo
   on mo.IDManufacturer=m.IDManufacturer
   inner join FACT_TRANSACTIONS f
   on f.IDModel=mo.IDModel
   where YEAR(f.date)=2009
  



--Q9--END

--Q10--BEGIN

	with cte as
	(
	select top 100 c.Customer_Name,	avg(f.TotalPrice) as avg_spend,avg(f.Quantity) as avg_qty,year(f.Date) as year from DIM_CUSTOMER c---doubt---(year and %)
	inner join FACT_TRANSACTIONS f
	on f.IDCustomer=c.IDCustomer
	group by year(f.Date), c.Customer_Name
	)
	select *,

	(sum([avg_spend]) over (partition by Customer_Name order by [year] rows between 1 preceding and 1 preceding) -
	 sum([avg_spend]) over (partition by Customer_Name order by [year] rows between current row and current row))/
	 sum([avg_spend]) over (partition by Customer_Name order by [year] rows between 1 preceding and 1 preceding)*(-100) as '% change of AVG Spend'
	 from cte
	 order by year desc
	 	 	

--Q10--END
	