-- Data Cleaning in MySQL--
SELECT *
FROM layoffs;

-- TECHNIQUES
-- 1. Remove Duplicates if any
-- 2. Standardize the Data
-- 3. Investigate Null values or blank values 
-- 4. Remove columns if necesssary

-- first we create staging data so as to not permanantly change the raw data.

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- finding duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, country, stage, total_laid_off, funds_raised_millions, 'date') AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, country, stage, total_laid_off, funds_raised_millions, 'date') AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- check that the rows really are duplicates using one of the companies

SELECT *
FROM layoffs_staging
WHERE company = 'casper';

CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging3
WHERE row_num > 1;

INSERT INTO layoffs_staging3
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, country, stage, total_laid_off, funds_raised_millions, 'date') AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging3
WHERE row_num > 1;

-- STANDARDIZE DATA (look at issues in each column and fix)

SELECT *
FROM layoffs_staging3;

SELECT company, TRIM(company)
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET company = TRIM(company);

SELECT *
FROM layoffs_staging3
WHERE industry LIKE 'Crypto%'; 

UPDATE layoffs_staging3
SET industry = 'Crypto'
WHERE industry Like 'Crypto%';

SELECT distinct location, country
FROM layoffs_staging3
ORDER BY 1;

UPDATE layoffs_staging3
SET location = CASE
    WHEN location = 'DÃ¼sseldorf' THEN 'Düsseldorf'
    WHEN location = 'FlorianÃ³polis' THEN 'Florianópolis'
    WHEN location = 'MalmÃ¶' THEN 'Malmö'
    ELSE location
  END
WHERE location IN ('DÃ¼sseldorf', 'FlorianÃ³polis', 'MalmÃ¶');

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging3
ORDER BY 1;

UPDATE  layoffs_staging3
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'united states%';

SELECT `date`
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` DATE;


-- Investigate NULL values and fix

SELECT * 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off is NULL;

UPDATE layoffs_staging3
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging3
WHERE industry IS NULL
OR industry = '';

-- try to populate null and empty industry column for companies where possible

SELECT * 
FROM layoffs_staging3
WHERE company = 'Airbnb';

SELECT * 
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
ON 	t1.company = t2.company
AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Delete some data what will not be needed for our purposes which has NULL values

SELECT * 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off is NULL;

-- Finally we clean up the data by dropping the column we created 
SELECT * 
FROM layoffs_staging3;

ALTER TABLE layoffs_staging3
DROP COLUMN row_num;
