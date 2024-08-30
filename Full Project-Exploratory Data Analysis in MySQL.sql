/**********************************************************************************************
                       Full Project-Exploratory Data Analysis
**********************************************************************************************/
SELECT *
FROM world_layoffs.layoffs_staging2;

-- how many people were laid off
SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;

-- what % of people were laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs.layoffs_staging2;

-- which company had a full 100% laid off
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;



-- which company had the largest laid off
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;



-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;



-- by location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC;


-- Summarize total layoffs by country, sorted by the highest totals.
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- Retrieve the earliest and latest dates from the layoffs data.
SELECT MIN(`date`) AS min_date, 
	   MAX(`date`) AS max_date
FROM world_layoffs.layoffs_staging2;


-- which industry had the most laid off
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


-- which country had the most laid off
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- which year had the most
SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;



-- Sum the total layoffs for each stage and order the results by the sum in descending order.
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;




-- Group the total layoffs by month and order the results by month in ascending order.
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, 
	   SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;



SELECT *
FROM world_layoffs.layoffs_staging2;



-- Calculate the rolling total of layoffs by month.
WITH Rolling_Total AS
(
-- Group the total layoffs by month.
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, 
	   SUM(total_laid_off) AS total_off
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
-- Calculate the rolling total of layoffs.
SELECT `MONTH`, 
	    total_off, 
        SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;



-- Summarize total layoffs by company and sort in descending order.
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;




-- Summarize total layoffs by company and year, and sort in descending order of total layoffs.
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;





-- Calculate total layoffs by company and year, rank them by total layoffs within each year, and filter to show top 5 rankings per year.
WITH Company_YEAR(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;
-- Large-scale layoffs occurred at companies like Google, Amazon, and Microsoft, 
--    especially in the last few years. The corporations with the most layoffs in
--    a given year were ranked, with Uber and Booking.com topping the list in 2020 
--    and Google and Microsoft in 2023.








/***********************************************************************************************
According to the data, there were a lot of layoffs in 2022 and 2023, with the largest numbers 
occurring at big businesses like Google, Amazon, and Microsoft. The top corporations with the
most layoffs, the greatest layoff rates by year, and the effects of layoffs in various areas 
and industries are some of the important conclusions.
************************************************************************************************/


