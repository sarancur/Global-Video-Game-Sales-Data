--Sales KPI--
--Total Global Sales--
SELECT Round(sum(Global_Sales),0) as Global_Sales
FROM `VG_Sales.GameSales`;
--Regional Sales Contribution--
WITH Total_Sales As 
  (Select Round(sum(Global_Sales)) as Global_total
    From `VG_Sales.GameSales`)
SELECT Round(sum(GS.NA_Sales)/TS.Global_total*100) as NA_Sales_PRCNTG,
Round(sum(GS.EU_Sales)/TS.Global_total*100) as EU_Sales_PRCNTG,
Round(sum(GS.JP_Sales)/TS.Global_total*100) as JP_Sales_PRCNTG,
Round(sum(GS.Other_Sales)/TS.Global_total*100) as Other_Sales_PRCNTG,
FROM `VG_Sales.GameSales` as GS
CROSS JOIN Total_Sales as TS
Group by TS.Global_total;
--Top Selling Games--
SELECT Name, Publisher,Round(sum(Global_Sales),2) As Global_Sales,
RANK() OVER (ORDER BY Round(sum(Global_Sales),2)DESC) AS Top_Selling_Game
FROM `VG_Sales.GameSales`
GROUP BY Name, Publisher
Order by Top_Selling_Game
LIMIT 100;

SELECT Name, Publisher, Global_Sales
FROM `VG_Sales.GameSales`
Where Name Like 'Grand Theft%'
--Top Publisher by Global Sales--
SELECT Publisher, Round(sum(Global_Sales),2) AS Total_Sales
FROM `VG_Sales.GameSales`
GROUP BY Publisher
ORDER BY Total_Sales DESC
Limit 30;
--Top Genre by Global Sales--
SELECT Genre, ROUND(SUM(Global_Sales),2) As Total_Sales
FROM `VG_Sales.GameSales`
GROUP BY Genre
ORDER BY Total_Sales DESC;
--Trend KPIs--
--Yearly Global Sales Trend--
SELECT Year, ROUND(SUM(Global_Sales),2) AS Total_Sales
FROM `VG_Sales.GameSales`
Where Year IS NOT NULL
GROUP BY Year
ORDER BY Year;
--Platform Popularity Over Time--
WITH PlatformYearRank AS (
    SELECT Year, Platform,
        ROUND(SUM(Global_Sales), 2) AS Total_Global_Sales,
        RANK() OVER (PARTITION BY Year ORDER BY SUM(Global_Sales) DESC) AS Sales_Rank
    FROM `VG_Sales.GameSales`
    WHERE Year IS NOT NULL
    GROUP BY Year, Platform
)
SELECT *
FROM PlatformYearRank
WHERE Sales_Rank = 1
ORDER BY Year;
--Using Sub Clauses--
SELECT Year, Platform, Total_Sales
FROM
(select Year, Platform, Round(sum(Global_Sales),2) as Total_Sales,
RANK() Over(PARTITION BY Year ORDER BY sum(Global_Sales) DESC) as Rank_Sales
FROM `VG_Sales.GameSales`
GROUP BY Year, Platform
ORDER BY Year)
Where Rank_Sales = 1
ORDER BY Year;
--Best Selling Genre per decade--
WITH PERFORMING_GENRE AS
    (
      SELECT
      CASE 
        WHEN Year BETWEEN '1980' AND '1989' THEN '1980s'
        WHEN Year BETWEEN '1990' AND '1999' THEN '1990s'
        WHEN Year BETWEEN '2000' AND '2009' THEN '2000s'
        WHEN Year BETWEEN '2010' AND '2020' THEN '2010s'
        ELSE 'Others'
      END AS DECADE,
      Genre, Round(sum(Global_Sales),2) AS Total_Sales,
      From `VG_Sales.GameSales`
      GROUP BY DECADE, Genre
      )
    SELECT *
    FROM (
      Select DECADE, Genre, Total_Sales,
      Rank() Over(Partition by DECADE ORDER BY Total_Sales DESC) AS Sales_Rank
      FROM PERFORMING_GENRE
        )
    Where Sales_Rank = 1
    ORDER BY DECADE;  
--ANSI Compliant Approach--
WITH GenreDecadeSales AS (
    SELECT
        CASE 
            WHEN Year BETWEEN '1980' AND '1989' THEN '1980s'
            WHEN Year BETWEEN '1990' AND '1999' THEN '1990s'
            WHEN Year BETWEEN '2000' AND '2009' THEN '2000s'
            WHEN Year BETWEEN '2010' AND '2019' THEN '2010s'
            ELSE 'Other'
        END AS Decade,
        Genre,
        ROUND(SUM(Global_Sales), 2) AS Total_Global_Sales
    FROM `VG_Sales.GameSales`
    WHERE Year IS NOT NULL
    GROUP BY 
        CASE 
            WHEN Year BETWEEN '1980' AND '1989' THEN '1980s'
            WHEN Year BETWEEN '1990' AND '1999' THEN '1990s'
            WHEN Year BETWEEN '2000' AND '2009' THEN '2000s'
            WHEN Year BETWEEN '2010' AND '2019' THEN '2010s'
            ELSE 'Other'
        END,
        Genre
)
SELECT *
FROM (
    SELECT
        Decade,
        Genre,
        Total_Global_Sales,
        RANK() OVER (
            PARTITION BY Decade
            ORDER BY Total_Global_Sales DESC
        ) AS Sales_Rank
    FROM GenreDecadeSales
)
WHERE Sales_Rank = 1
ORDER BY Decade;
--Market Insights KPIs--
--Platform+Genre Combination Performance--
With Comb_Perf AS 
    (
      SELECT Platform, Genre, Round(sum(Global_Sales),2) as Combination_Performance,
      Rank() Over(PARTITION BY Platform ORDER BY ROUND(SUM(Global_Sales),2) DESC) AS Sales_Rank
      FROM `VG_Sales.GameSales`
      Group by Platform, Genre
    )
  SELECT Platform, Genre, Comb_Perf.Combination_Performance
  FROM Comb_Perf
  Where Sales_Rank = 1
  ORDER BY Comb_Perf.Combination_Performance DESC;  
--Regional Market Leaders--
WITH RankedNA AS (
    SELECT
        'NA' AS Region,
        Publisher,
        ROUND(SUM(NA_Sales), 2) AS Total_Sales,
        RANK() OVER (ORDER BY SUM(NA_Sales) DESC) AS Sales_Rank
    FROM `VG_Sales.GameSales`
    GROUP BY Publisher
),
RankedEU AS (
    SELECT
        'EU' AS Region,
        Publisher,
        ROUND(SUM(EU_Sales), 2) AS Total_Sales,
        RANK() OVER (ORDER BY SUM(EU_Sales) DESC) AS Sales_Rank
    FROM `VG_Sales.GameSales`
    GROUP BY Publisher
),
RankedJP AS (
    SELECT
        'JP' AS Region,
        Publisher,
        ROUND(SUM(JP_Sales), 2) AS Total_Sales,
        RANK() OVER (ORDER BY SUM(JP_Sales) DESC) AS Sales_Rank
    FROM `VG_Sales.GameSales`
    GROUP BY Publisher
),
RankedOther AS (
    SELECT
        'Other' AS Region,
        Publisher,
        ROUND(SUM(Other_Sales), 2) AS Total_Sales,
        RANK() OVER (ORDER BY SUM(Other_Sales) DESC) AS Sales_Rank
    FROM `VG_Sales.GameSales`
    GROUP BY Publisher
)
SELECT Region, Publisher, Total_Sales
FROM (
    SELECT * FROM RankedNA WHERE Sales_Rank = 1
    UNION ALL
    SELECT * FROM RankedEU WHERE Sales_Rank = 1
    UNION ALL
    SELECT * FROM RankedJP WHERE Sales_Rank = 1
    UNION ALL
    SELECT * FROM RankedOther WHERE Sales_Rank = 1
)
ORDER BY Region;
