
--Covid death table
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
order by 3,4;


--COVID DEATH DATA

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


--TOTAL CASES V/S TOTAL DEATHS
--Chances of dying in india, canada and United states if you get COVID on 30th of JUNE 2021

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE date = '2021-06-30' AND location IN ('India', 'Canada','United states')
ORDER BY 1,2;

--Total cases V/S population
-- % of population got COVID in india, canada and United states on 30th of JUNE 2021

SELECT location,date,total_cases,population, (total_cases/population)*100 AS infected_percentage
FROM CovidDeaths
WHERE date = '2021-06-30' AND location IN ('India', 'Canada','United states')
ORDER BY 1,2;

--Total cases V/S population
-- % of population got COVID in india, canada and United states

SELECT location,date,total_cases,population, (total_cases/population)*100 AS infected_percentage
FROM CovidDeaths
WHERE location IN ('India', 'Canada','United states')
ORDER BY 1,2;

--Countries with highest infection rate compared to population

SELECT location,population,Max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS infected_percentage
FROM CovidDeaths
--WHERE location IN ('India', 'Canada','United states')
GROUP BY location,population
ORDER BY infected_percentage DESC;

--Countries with highest death count compared to population

SELECT location,population,Max(cast(total_deaths as int)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY HighestDeathCount DESC;

--Let's Break things down by continent
--Showing the continents with the highest death count per population

SELECT continent,Max(cast(total_deaths as int)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY HighestDeathCount DESC;


-- Global numbers

SELECT date, sum(new_cases) As total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 As death_percentage
FROM CovidDeaths
WHERE  continent is not null
GROUP BY date
ORDER BY 1,2;

SELECT sum(new_cases) As total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 As death_percentage
FROM CovidDeaths
WHERE  continent is not null
ORDER BY 1,2;


--Covid Vaccinations table
SELECT *
FROM CovidVaccinations
order by 3,4;

--Let's Join Covid death table with Covid vaccination table

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date

--Looking at total population v/s vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated,
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--Common_table_expression(CTE)

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS 
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac;


--OR 

-- USE OF TEMP TABLE instead of CTE

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;

--Creating View for later data visualization 

Create view PercentPopulationVaccinated as

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated 





