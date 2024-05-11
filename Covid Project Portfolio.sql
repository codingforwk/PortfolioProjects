SELECT *
FROM PortfolioProjects..coviddeaths$
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..coviddeaths$
ORDER BY 1,2

--total cases vs total deaths
--likelihood of dying if you contract covid in x country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..coviddeaths$
WHERE location like '%states%'
ORDER BY 1,2



-- total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentageInfectedPopulation
FROM PortfolioProjects..coviddeaths$
WHERE location like '%states%'
ORDER BY 1,2

--countries with highest rate
SELECT location, population, MAX(total_cases) as highestinfectioncount, MAX(total_cases/population)*100 as PercentageInfectedPopulation
FROM PortfolioProjects..coviddeaths$
Group BY location,population
ORDER BY PercentageInfectedPopulation


--highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..coviddeaths$
WHERE continent is not null
Group BY location,population
ORDER BY TotalDeathCount desc


--continents with highest death count

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..coviddeaths$
WHERE continent is not null
Group BY continent
ORDER BY TotalDeathCount desc



--global numbers
SELECT date,SUM(new_cases) --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..coviddeaths$
WHERE continent is not null
group by date 
ORDER BY 1,2

--total population vs vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order by dea.location, dea.date ) as SumOfVaccinatedPopulation
--,(SumOfVaccinatedPopulation/population)*100
FROM PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--cte

WITH PopvsVac  (continent, location, date,population,new_vaccinations,SumOfVaccinatedPopulation)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order by dea.location, dea.date ) as SumOfVaccinatedPopulation
--,(SumOfVaccinatedPopulation/population)*100
FROM PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)

Select * , (SumOfVaccinatedPopulation/population)*100 as PercentOfPopulationVac
From PopvsVac
Order by 2,3


--temp table

DROP Table if exists #PercentOfPopulationVac 
Create Table #PercentOfPopulationVac 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
SumOfVaccinatedPopulation numeric
)

Insert into #PercentOfPopulationVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order by dea.location, dea.date ) as SumOfVaccinatedPopulation
--,(SumOfVaccinatedPopulation/population)*100
FROM PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select * , (SumOfVaccinatedPopulation/population)*100 as PercentOfPopulationVac
From #PercentOfPopulationVac
Order by 2,3


-- create view to store data for visualization

Create View PercentOfPopulationVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order by dea.location, dea.date ) as SumOfVaccinatedPopulation
--,(SumOfVaccinatedPopulation/population)*100
FROM PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


select *
From PercentOfPopulationVac
