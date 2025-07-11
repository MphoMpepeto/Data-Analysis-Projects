-- EXPLORATORY DATA ANALYSIS ON LAYOFFS DATA
-- The purpose of this project is to ask questions about the data and generate answers.

SELECT*
FROM layoffs_staging3;

-- Companies that went under completely?

SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- which companies laid off the most employees?

SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

-- 	When did the layoffs start and end?

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging3;

-- What industry had the most layoffs?
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY industry
ORDER BY 2 DESC;

-- What country did most of the layoffs occur in?

SELECT country, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY country
ORDER BY 2 DESC;

-- Looking at the number of layoffs by date

SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY `date`
ORDER BY 1 DESC;

-- What year did the layoffs occur in the most.

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- what stage are the companies with the highest number of layoffs in?

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY stage
ORDER BY 2 DESC;

-- How did the layoffs progess overtime in months

SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging3
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;

-- Let's look at the rolling sum of layoffs over the months

WITH rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging3
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`, total_off, SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_total;

-- How many people did individual companies lay off per year?

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH company_year (Company, Years, Total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY Years ORDER BY total_laid_off DESC) AS Ranks
FROM company_year
WHERE Years IS NOT NULL
ORDER BY Ranks ASC;

-- Ranking the top 5 companies to lay people off over the years

WITH company_year (Company, Years, Total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY Years ORDER BY total_laid_off DESC) AS Ranks
FROM company_year
WHERE Years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranks <=5;
