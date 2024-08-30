/***************************************************************************************
                       Full Project - Data Cleaning in MySQL 
****************************************************************************************/


-- Create the database:
CREATE DATABASE world_layoffs;


-- Select the newly created database:
USE world_layoffs;


SELECT * 
FROM `layoffs`;



/******************************************************************************************
--- Steps for cleaning the raw data:
-- 1. Remove duplicates
-- 2. Standardize the data (issues with spelling, white spaces at the beganning etc)
-- 3. NULL values or blank values
-- 4. Remove Any Columns OR Rows
******************************************************************************************/





-- This method creates a new table with the same structure but without copying any data(staging).
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

-- selecting the data to make sure table is created.
SELECT * 
FROM world_layoffs.layoffs_staging;


-- insert the data from layoffs to layoffs_staging table.
INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;





-- check for duplicates.

SELECT company, industry, total_laid_off, percentage_laid_off, `date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
	FROM world_layoffs.layoffs_staging;
    
    



SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
	FROM world_layoffs.layoffs_staging;
    
    
    
WITH duplicate_cte AS
(
SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
	FROM world_layoffs.layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num >1;
        



-- let's just look at oda to confirm.
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda';
-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate.        
        
-- these are our real duplicates.
        
WITH duplicate_cte AS
(        
SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging
) 
SELECT *
FROM duplicate_cte
WHERE row_num >1;



SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Casper';


-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially
        
WITH duplicate_cte AS
(        
SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging
) 
DELETE
FROM duplicate_cte
WHERE row_num >1;




SELECT *
FROM world_layoffs.layoffs_staging;

CREATE TABLE `layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT default NULL,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int default NULL,
row_num INT
);




SELECT *
FROM world_layoffs.layoffs_staging2;
        
        
INSERT INTO world_layoffs.layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
FROM layoffs_staging;
        
        
        
        

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;
        
        
-- Now that we have this we can delete rows were row_num is greater than 1

-- delete the duplicates.
DELETE
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;
        

SELECT *
FROM world_layoffs.layoffs_staging2;






SELECT * 
FROM world_layoffs.layoffs_staging2;




SELECT company, TRIM(company)
FROM world_layoffs.layoffs_staging2;



UPDATE world_layoffs.layoffs_staging2
SET company = TRIM(company);



-- if we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry LIKE 'Crypto%';


UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';



-- lets take a look at location
SELECT DISTINCT location
FROM world_layoffs.layoffs_staging2
ORDER BY  location;


-- lets take a look at country
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY  country;



-- fix the period at the end of United States.

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM world_layoffs.layoffs_staging2
ORDER BY country;

UPDATE world_layoffs.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';



-- format the date

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs.layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


SELECT `date`
FROM world_layoffs.layoffs_staging2;



-- now we can convert the data type properly
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;






SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  total_laid_off IS NULL;



SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  total_laid_off IS NULL
AND percentage_laid_off IS NULL;



SELECT * 
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL
OR industry = '';


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company = 'Airbnb';


SELECT *
FROM world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
  ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


SELECT t1.industry, t2.industry
FROM world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
  ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';



-- update it now 
UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;




SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';




SELECT *
FROM world_layoffs.layoffs_staging2;




SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  total_laid_off IS NULL
AND percentage_laid_off IS NULL;




-- delete all rows that have null value for both total_laid_off and for precentage_laid_off
DELETE
FROM world_layoffs.layoffs_staging2
WHERE  total_laid_off IS NULL
AND percentage_laid_off IS NULL;




-- dont need the row_num column anymore

ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;




-- clean data 
SELECT *
FROM world_layoffs.layoffs_staging2;





/********************************************************************************************************
We conducted data cleaning on the layoffs_staging2 table to ensure the data is accurate, consistent, 
and ready for analysis. This process included creating a new table with appropriate data types, transferring
and formatting the data, handling date conversion issues, trimming text fields, replacing empty values with
NULL, and filling in missing industry values based on company matches. Data cleaning is crucial because it
eliminates errors, inconsistencies, and inaccuracies, which can significantly impact the quality and 
reliability of any analysis or insights derived from the data. Clean data ensures that analysis results 
are valid and trustworthy, leading to better decision-making.
**********************************************************************************************************/








