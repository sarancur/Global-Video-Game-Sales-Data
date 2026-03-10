# Global Video Game Sales Analysis — KPI Dashboard
**$8.92B in Global Sales | 40+ Years of Data (1980–2016) | Tools: SQL (BigQuery), Tableau**

---

## Project Overview

End-to-end sales analytics pipeline covering four decades of global video game market data. Raw transaction records were queried and aggregated in Google BigQuery using advanced SQL (CTEs, window functions, CASE-based decade bucketing, UNION ALL for multi-region ranking), then visualized in a multi-panel Tableau dashboard spanning sales KPIs, trend analysis, and market intelligence insights.

The analysis is structured across three analytical layers:

- **Sales KPIs** — Total revenue, regional contribution breakdown, top games, top publishers, genre performance
- **Trend KPIs** — Yearly sales trajectory (1980–2016), platform dominance shifts by year
- **Market Insights** — Best genre per decade, platform × genre combination performance, regional market leaders by publisher

---

## Dataset

| Attribute | Detail |
|---|---|
| Source | Video Game Sales dataset (Kaggle) |
| Total Global Sales | $8,920M (~$8.92B) |
| Time Span | 1980 – 2016 (37 years) |
| Variables | Name, Platform, Year, Genre, Publisher, NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales |

---

## Key Findings

### Sales KPIs

**Regional market split — North America dominates:**

| Region | Share |
|---|---|
| North America | 49% |
| Europe | 27% |
| Japan | 14% |
| Other | 9% |

NA accounts for nearly half of all global video game revenue — almost 3.5x the Japanese market. This concentration has significant implications for publisher launch strategies and platform prioritization.

**Genre performance — Action overtook Platform games as the market matured:**

| Genre | Total Sales (M) |
|---|---|
| Action | $1,751 |
| Sports | $1,331 |
| Shooter | $1,037 |
| Role-Playing | $927 |
| Platform | $831 |
| Racing | $732 |

Action leads by a wide margin at $1.75B — 32% more than Sports in second place.

**Publisher concentration — Nintendo's extraordinary dominance:**

| Rank | Publisher | Total Sales (M) |
|---|---|---|
| 1 | Nintendo | $1,787 |
| 2 | Electronic Arts | $1,110 |
| 3 | Activision | $727 |
| 4 | Sony Computer Entertainment | $608 |
| 5 | Ubisoft | $475 |

Nintendo's $1.79B total is 61% higher than EA in second place — and more than the combined total of publishers ranked 3–5. Nintendo also holds the #1 position in every geographic region (NA, EU, JP), with Electronic Arts leading only the "Other" markets segment.

**Top games — Wii Sports leads all titles at $331M global sales**, followed by Grand Theft Auto V ($224M) and Super Mario Bros. ($181M).

---

### Trend KPIs

**Market growth trajectory (1980–2016):**

The market grew from near-zero in 1980 to a peak of $678.9M in 2008, driven by the PS2/Wii era. Post-2008 decline reflects market maturation, mobile gaming displacement, and digital distribution shifting revenue off physical units tracked in this dataset.

| Era | Peak Year | Peak Sales |
|---|---|---|
| Early Gaming (1980s) | 1989 | $73M |
| 16-bit / CD era (1990s) | 1998 | $256M |
| PS2 / Xbox era (2000s) | 2008 | $679M |
| HD / Mobile era (2010s) | 2010 | $600M |

**Platform dominance by year — complete succession:**

The dataset captures every major console transition across 37 years:

| Period | Dominant Platform |
|---|---|
| 1980–1982 | Atari 2600 |
| 1983–1988 | NES |
| 1989 | Game Boy |
| 1990–1994 | SNES |
| 1995–2000 | PlayStation |
| 2001–2005 | PS2 |
| 2006–2009 | Wii |
| 2010 | Xbox 360 |
| 2011–2013 | PS3 |
| 2014–2016 | PS4 |

Each platform transition is visible directly in the data, with no gap in market leadership.

---

### Market Insights

**Best-selling genre by decade — Platform gave way to Action:**

| Decade | Top Genre | Sales (M) |
|---|---|---|
| 1980s | Platform | $122M |
| 1990s | Platform | $209M |
| 2000s | Action | $859M |
| 2010s | Action | $674M |

The shift from Platform to Action between the 1990s and 2000s represents one of the clearest structural changes in gaming consumer preference — coinciding with the rise of 3D gaming and open-world titles.

**Top platform × genre combinations:**

| Platform | Best Genre | Sales (M) |
|---|---|---|
| PS3 | Action | $308M |
| Wii | Sports | $292M |
| Xbox 360 | Shooter | $279M |
| PS2 | Sports | $273M |
| DS | Misc | $138M |

PS3+Action, Wii+Sports, and Xbox 360+Shooter represent the three dominant format-genre pairings of the 2006–2013 console generation — each reflecting distinct consumer demographics.

**Regional market leaders:**
Nintendo holds the #1 publisher position in NA ($817M), EU ($419M), and JP ($455M). Electronic Arts leads only the "Other" region ($130M) — suggesting Nintendo's brand has uniquely global reach while EA's strength is more Western-market concentrated.

---

## SQL Highlights

The KPI file demonstrates a range of SQL techniques across 9 analytical queries:

```sql
-- Platform dominance by year using window function + CTE
WITH PlatformYearRank AS (
    SELECT Year, Platform,
        ROUND(SUM(Global_Sales), 2) AS Total_Global_Sales,
        RANK() OVER (PARTITION BY Year ORDER BY SUM(Global_Sales) DESC) AS Sales_Rank
    FROM `VG_Sales.GameSales`
    WHERE Year IS NOT NULL
    GROUP BY Year, Platform
)
SELECT * FROM PlatformYearRank WHERE Sales_Rank = 1 ORDER BY Year;

-- Best genre per decade using CASE bucketing + nested RANK
WITH GenreDecadeSales AS (
    SELECT
        CASE
            WHEN Year BETWEEN '1980' AND '1989' THEN '1980s'
            WHEN Year BETWEEN '1990' AND '1999' THEN '1990s'
            WHEN Year BETWEEN '2000' AND '2009' THEN '2000s'
            WHEN Year BETWEEN '2010' AND '2019' THEN '2010s'
        END AS Decade,
        Genre, ROUND(SUM(Global_Sales), 2) AS Total_Global_Sales
    FROM `VG_Sales.GameSales`
    WHERE Year IS NOT NULL
    GROUP BY Decade, Genre
)
SELECT * FROM (
    SELECT Decade, Genre, Total_Global_Sales,
        RANK() OVER (PARTITION BY Decade ORDER BY Total_Global_Sales DESC) AS Sales_Rank
    FROM GenreDecadeSales
) WHERE Sales_Rank = 1 ORDER BY Decade;

-- Regional market leaders using 4-CTE UNION ALL pattern
WITH RankedNA AS (...), RankedEU AS (...), RankedJP AS (...), RankedOther AS (...)
SELECT Region, Publisher, Total_Sales
FROM (
    SELECT * FROM RankedNA WHERE Sales_Rank = 1
    UNION ALL SELECT * FROM RankedEU WHERE Sales_Rank = 1
    UNION ALL SELECT * FROM RankedJP WHERE Sales_Rank = 1
    UNION ALL SELECT * FROM RankedOther WHERE Sales_Rank = 1
)
ORDER BY Region;
```

**SQL techniques used:** CTEs, window functions (`RANK() OVER PARTITION BY`), `CASE` decade bucketing, `CROSS JOIN` for percentage calculations, `UNION ALL` for multi-region aggregation, subquery filtering — all executed in Google BigQuery.

---

## Repository Contents

| File | Description |
|---|---|
| `VideoGame_Sales_KPI.sql` | All 9 BigQuery SQL queries across Sales, Trend, and Market Insights KPIs |
| `GamingGlobalSales.csv` | Total global sales aggregate |
| `Regional_Sales_Percentage.csv` | NA/EU/JP/Other percentage breakdown |
| `Top_Genre_by_Sales.csv` | All genres ranked by total global sales |
| `GlobalSales_by_Publisher.csv` | Top 30 publishers by cumulative sales |
| `SalesbyYear.csv` | Annual sales 1980–2016 |
| `Platform_Popularity_over_Time.csv` | #1 platform per year across full dataset |
| `Performing_Genre_by_Decade.csv` | Top genre per decade (1980s–2010s) |
| `Platform-Genre_CombinationPerformance.csv` | Best genre for each platform |
| `Regional_Market_Leaders.csv` | #1 publisher in each region (NA/EU/JP/Other) |
| `Book1.twbx` | Tableau packaged workbook (full dashboard) |
| `Dashboard_1.pdf` | Dashboard export — static PDF snapshot |

---

## Skills Demonstrated

| Domain | Competency |
|---|---|
| SQL | CTEs, window functions, CASE bucketing, CROSS JOIN, UNION ALL, subqueries — Google BigQuery |
| Data Visualization | Multi-panel KPI dashboard design in Tableau |
| Market Analysis | Publisher benchmarking, regional segmentation, platform lifecycle analysis, genre trend modeling |
| Data Pipeline | Raw CSV → BigQuery → SQL aggregation → Tableau visualization |

---

## Related Work

- [Walmart Sales Analysis](https://github.com/sarancur/Walmart_Sales-) — 18-month retail KPI dashboard using BigQuery SQL + Tableau
- [U.S. Supply Chain Risk Analysis](https://github.com/sarancur/Predictive-Analysis-on-US_Supply-Chain-2023) — Statistical inference pipeline using R, Python, and Excel

---

*Dataset sourced from Kaggle — Video Game Sales.*
