/*
Awesome Chocolates - Sales Analysis with SQL

Dataset: "Awesome Chocolates"
Source Link: https://files.chandoo.org/sql/awesome-chocolates-data.sql
*/


-- Calculating a new column from existing columns
-- Giving the new column a name
SELECT SaleDate, Amount, Boxes, Amount / Boxes AS 'Amount per box' FROM sales;



-- Filtering sales above 10000
-- Ordering those from high to low (descending order)
SELECT * FROM Sales
	WHERE Amount > 10000
	ORDER BY Amount DESC;



-- Filtering for just the GeoID of G1
-- Sorting by multiple criteria (first by Product ID, then by Amount)
SELECT * FROM Sales
	WHERE GeoID = 'G1'
    ORDER BY PID, Amount DESC;



-- Filtering for sales in year 2022 which are greater than 10000
-- Sorting sales amount from high to low
SELECT SaleDate, GeoID, PID, Amount FROM Sales
	WHERE Amount > 10000 AND year(SaleDate) = 2022
	ORDER BY Amount DESC;



-- Filtering for sales where boxes are BETWEEN 0 AND 50
SELECT * FROM Sales
	WHERE Boxes BETWEEN 0 AND 50
    ORDER BY Boxes DESC;



-- Filtering for sales shipments on Fridays
-- NOTE: SQL's weekday function defines Monday = 0 and Sunday = 6, so Friday = 4.
SELECT SaleDate, Amount, Boxes, weekday(SaleDate) AS 'Day of Week'
	FROM Sales
	WHERE weekday(SaleDate) = 4;



-- Using CASE function to separately label sales amounts under 4 categories
SELECT SaleDate, Amount,
	CASE	WHEN Amount < 1000 THEN 'Under 1k'
			WHEN Amount < 5000 THEN 'Between 1k and 5k'
			WHEN Amount < 10000 THEN 'Between 5k and 10k'
			ELSE '10k or more'
	END AS 'Amount Category'
FROM Sales
ORDER BY Amount DESC;



-- Filtering for people from specific teams with IN clause
SELECT * FROM People
	WHERE Team IN ('Delish', 'Jucies');

-- Filtering for salespersons whose names start with B using LIKE function
SELECT * FROM People
	WHERE Salesperson LIKE 'B%';

/*
B coming first, then the %, tells SQL that we want names that start with B.
So SQL returns all Salespersons starting with B.
But note that this is only first names starting with B.
Now what if we want salespersons with a B anywhere in their name?
Then, we place % on both sides of B.
*/

-- Filtering for salespersons with a B anywhere in their name
SELECT * FROM People
	WHERE Salesperson LIKE '%B%';



-- Sales table does not display salesperson's name. People table does.
-- So if we want to see sales data with salesperson's name, we have to JOIN.
-- The common column between both tables is the salesperson ID (SPID).
SELECT Sales.SaleDate, Sales.Amount, People.Salesperson, Sales.SPID
	FROM Sales
    JOIN People ON People.SPID = Sales.SPID;



-- Analyzing sales of products by joining Sales and Products tables
SELECT Sales.SaleDate, Sales.Amount, Sales.PID, Products.Product
	FROM Sales
    LEFT JOIN Products ON Products.PID = Sales.PID;
/*
We are using LEFT JOIN, so that if there is a product name and product ID in the
sales table, but it does not have a matching product name and product ID in the
products table, it will still show up in results. But it will be displayed as
blank or null, because there is no matching value there.
*/



-- Joining multiple tables - sales, people and products
SELECT Sales.SaleDate, Sales.Amount, Products.Product, People.Salesperson, People.Team
	FROM Sales
    JOIN People ON People.SPID = Sales.SPID
	JOIN Products ON Products.PID = Sales.PID;



-- Filtering multiple jointed table for Delish team's sales where amount less than 500
SELECT Sales.SaleDate, Sales.Amount, Products.Product, People.Salesperson, People.Team
	FROM Sales
    JOIN People ON People.SPID = Sales.SPID
	JOIN Products ON Products.PID = Sales.PID
	WHERE People.Team = 'Delish' AND Sales.Amount < 500;



-- Filtering multiple joined table for salespersons without teams, sales less than 500
SELECT Sales.SaleDate, Sales.Amount, Products.Product, People.Salesperson, People.Team
	FROM Sales
    JOIN People ON People.SPID = Sales.SPID
	JOIN Products ON Products.PID = Sales.PID
	WHERE People.Team = '' AND Sales.Amount < 500;
/*
We can use WHERE People.Team IS NULL, but in this database the Team values which
are empty are not marked as NULL, which in SQL will appear as a small gray box within
the field. In this database, they are blank, but not NULL. So we just use quote marks
'' with no characters between them, to filter for blank fields in Team column.
*/



-- Filtering above query for teamless sales, less than 500, shipped to NZ or India
SELECT Sales.SaleDate, Sales.Amount, Products.Product, People.Salesperson, People.Team
	FROM Sales
    JOIN People ON People.SPID = Sales.SPID
	JOIN Products ON Products.PID = Sales.PID
    JOIN Geo ON Geo.GeoID = Sales.GeoID
	WHERE People.Team = '' AND Sales.Amount < 500
    AND Geo.Geo IN ('New Zealand','India')
    ORDER BY SaleDate;
/*
Note that there is no 'Geo' column in the results. This is because, though we have
joined the Geo table and included a filter for the Geo.Geo column, we have not
SELECTed the Geo.Geo column to be displayed in the final results. So SQL will apply
the filter, but not display the Geo.Geo column in the final results.
*/



-- GROUP BY function to aggregate Sales Amounts by geographic region
SELECT GeoID, sum(Amount), avg(Amount), sum(Boxes)
	FROM Sales
    GROUP BY GeoID;



-- Using GROUP BY on multiple joined tables to get reporting-style overview
-- Useful to get quick summary-level data of business divisions
SELECT Geo.Geo, sum(Amount), avg(Amount), sum(Boxes)
	FROM Sales
    JOIN Geo ON Geo.GeoID = Sales.GeoID
    GROUP BY Geo.Geo;
/* GeoID is replaced by Geo.Geo in order to get the name of the geographic region.
This would be much clearer and more user-friendly for reporting than G1, G3 etc. */



-- Grouping and sorting multiple joined tables for sales by team per product category
SELECT Products.Category, People.Team, sum(Boxes), sum(Amount)
	FROM Sales
    JOIN People ON People.SPID = Sales.SPID
    JOIN Products ON Products.PID = Sales.PID
    GROUP BY Products.Category, People.Team
	ORDER BY Products.Category, People.Team;
/* NOTE:
After the JOINs, before GROUP BY, we can add the following line:
	WHERE People.Team <> ''
    (i.e. where Team is anything other than empty)
in order to exclude teamless sales and just focus on the three teams' performance.
*/



-- Total Sales Amounts by product, filtering for only Top 10 products
SELECT Products.Product, sum(Sales.Amount) AS 'Total Sales Amount'
	FROM Sales
	JOIN Products ON Products.PID = Sales.PID
    GROUP BY Products.Product
    ORDER BY `Total Sales Amount` DESC
    LIMIT 10;


/*  END  */