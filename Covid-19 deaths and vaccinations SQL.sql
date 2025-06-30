--EXPLORING COVID-19 DATA POINTS FROM THE 24TH OF FEBRUARY 2020 TO THE 30TH OF APRIL 2021

--select both data files from the project database

select *
from PortfolioProject..CovidDeaths$
where continent is not null --excludes entire continents from our data and only shows individual countries
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select the data that will be used from CovidDeaths$

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- looking at  total cases vs total deaths
--shows the likelihood of dying from covid if you contract it in any specific country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths$
where continent is not null
where location like '%south africa%'
order by 1,2

--Total cases vs Population
--shows the percentage of the population that contracted covid at any given point in time in each country

select location, date, total_cases, population, (total_cases/population)*100 as cases_per_capita
from PortfolioProject..CovidDeaths$
where continent is not null
where location like '%south africa%'
order by 1,2

--Countries with the highest infection rate

select location, MAX(total_cases) as Highest_infection_count, population, MAX((total_cases/population))*100 as percent_population_infected
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%south africa%'
group by location, population
order by percent_population_infected desc

--Highest death count per capita

select location, MAX(cast(total_deaths as int)) as Highest_death_count
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%south africa%'
group by location
order by Highest_death_count desc

--Highest death count via continents

select location, MAX(cast(total_deaths as int)) as Highest_death_count
from PortfolioProject..CovidDeaths$
where continent is null
--where location like '%south africa%'
group by location
order by Highest_death_count desc

--GLOBAL NUMBERS - TOTAL CASES AND TOTAL DEATHS PER DAY ACROSS THE WORLD

select date, SUM(new_cases) as new_cases, SUM(CAST(new_deaths as int)) as new_deaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Total vaccinations per capita

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as cumulative_vaccinations --a rolling count of the number of people vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE to find the cumulative vaccinations and the percentage vaccinations per capita

WITH popvsvac (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as cumulative_vaccinations --a rolling count of the number of people vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (cumulative_vaccinations/population)*100 as cumulative_vac_per_capita
from popvsvac

--Using a temporary table to find the cumulative vaccinations and the percentage vaccinations per capita

DROP table if exists #vaccinations_per_capita
create table #vaccinations_per_capita
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric
) 
insert into #vaccinations_per_capita
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as cumulative_vaccinations --a rolling count of the number of people vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (cumulative_vaccinations/population)*100 as cumulative_vac_per_capita
from #vaccinations_per_capita

--Creating VIEW to store data for later visualisations

create view vaccinations_per_capita as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as cumulative_vaccinations --a rolling count of the number of people vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from vaccinations_per_capita