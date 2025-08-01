
#Filtering, WHERE Clauses, Aggregation
# What is the total number of individuals employed in the Manufacturing sector across all congressional districts in 2019?

# Total in Manufacturing in 2019 ordered by cd
SELECT cd, year, SUM(Total_Manufacturing)
FROM industry
WHERE Year = '2019'
GROUP BY cd
ORDER BY SUBSTRING_INDEX(cd, '_', -1),  -- state code (e.g., FL)
  CAST(SUBSTRING_INDEX(cd, '_', 1) AS UNSIGNED)
;

# Ranking
# Which 5 districts had the highest total employment in the Information sector in 2019?
# Top 5 districts in total employment in 2019
SELECT year, cd AS District, Total_Information
FROM industry
WHERE year = '2019'
ORDER BY Total_Information DESC
LIMIT 5
;

# Percentage Calculations
# What percentage of total employment in each district in 2020 was in the manufaturing sector? Order by state then district, express in percentage.
SELECT cd AS District, 
	CONCAT(ROUND(Total_Manufacturing/(Male + Female)*100, 0), '%') as Percent_Manufacturing
FROM industry
WHERE Year = '2020'
ORDER BY SUBSTRING_INDEX(cd, '_', -1),  -- state code (e.g., FL)
  CAST(SUBSTRING_INDEX(cd, '_', 1) AS UNSIGNED)
  
# Ordered by Percent_Manufacturing DESC
SELECT 
	RANK() OVER (ORDER BY Total_Manufacturing / (Male + Female) DESC) AS rank_mfg,
	cd AS District, 
	CONCAT(ROUND(Total_Manufacturing/(Male + Female)*100, 3), '%') as Percent_Manufacturing
FROM industry
WHERE Year = '2020'
ORDER BY (Total_Manufacturing)/(Male + Female) DESC
;

# Comparative
# Which congressional districts had more people with bachelor’s degrees or higher than those with only high school or some college in 2021? Order by state then district.
SELECT cd AS District, Bachelors_degree_or_higher, high_school_or_some_degree,
	Bachelors_degree_or_higher-high_school_or_some_degree AS Difference,
    CONCAT(ROUND((Bachelors_degree_or_higher-high_school_or_some_degree)/high_school_or_some_degree * 100, 2), '%') AS per_difference
FROM educationv
WHERE Bachelors_degree_or_higher > high_school_or_some_degree AND Year = '2021'
ORDER BY SUBSTRING_INDEX(cd, '_', -1),  -- state code (e.g., FL)
  CAST(SUBSTRING_INDEX(cd, '_', 1) AS UNSIGNED)
;

# What are the top 10 congressional districts had more people with bachelor’s degrees or higher than those with only high school or some college in 2021? Order by percentage difference.
SELECT cd AS District, Bachelors_degree_or_higher, high_school_or_some_degree,
	Bachelors_degree_or_higher-high_school_or_some_degree AS Difference,
    CONCAT(ROUND((Bachelors_degree_or_higher-high_school_or_some_degree)/high_school_or_some_degree * 100, 2), '%') AS per_difference
FROM educationv
WHERE Bachelors_degree_or_higher > high_school_or_some_degree AND Year = '2021'
ORDER BY (Bachelors_degree_or_higher-high_school_or_some_degree)/high_school_or_some_degree DESC
LIMIT 10
;

# Income shift
# Find the district with the largest increase in individuals earning $75,000–$99,999 from 2019 to 2021.
SELECT a.cd, a.`$75000_to_$99999` AS '2019_75k-100k', b.`$75000_to_$99999` AS '2021_75k-100k',
	b.`$75000_to_$99999` - a.`$75000_to_$99999` AS Difference,
    CONCAT(ROUND((b.`$75000_to_$99999` - a.`$75000_to_$99999`)/a.`$75000_to_$99999`*100, 2), '%') AS Pct_Diff
FROM finance AS a
JOIN finance AS b
ON a.cd = b.cd
WHERE a.year IN ('2019') AND b.year IN ('2021')
ORDER BY (b.`$75000_to_$99999` - a.`$75000_to_$99999`)/a.`$75000_to_$99999` DESC
LIMIT 5
;

## Which districts have the highest number of people in the low-income brackets (below $50,000) in 2020?
SELECT cd AS District, 
		`Less_than_$5000`+`$5000_to_$9999`+ 
		`$10000_to_$14999`+`$15000_to_$19999`+
        `$20000_to_$24999`+`$25000_to_$34999`+
        `$35000_to_$49999` AS Low_Income_Sum
FROM finance
WHERE year = '2020'
ORDER BY Low_Income_Sum DESC
LIMIT 5
;
