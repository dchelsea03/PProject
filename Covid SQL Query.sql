SELECT *
FROM PortfolioProject..CovidDeath
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

-- Total Cases VS Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPerc
FROM PortfolioProject..CovidDeath
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2

-- Total Cases VS Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPerc
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%states%'
ORDER BY 1,2

--Highest Infection Rate
SELECT location, population, MAX(total_cases) as HighestCount, Max((total_cases/population))*100 AS CasesPercInf
FROM PortfolioProject..CovidDeath
GROUP BY location, population
ORDER BY CasesPercInf DESC

--Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCt
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCt DESC

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCt
FROM PortfolioProject..CovidDeath
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCt DESC

--categorize by continent
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCt
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCt DESC

--Global numbers, Total Cases, Deaths, Death Percentage across the world per date
SELECT date,SUM(new_cases) as TtlCases, SUM(cast(new_deaths as int)) as TtlDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--USING BOTH TABLES
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccination vac
	ON death.location=vac.location
	AND death.date=vac.date
WHERE death.continent is not null
ORDER BY 2,3

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
	death.Date) as RollingPplVac
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccination vac
	ON death.location=vac.location
	AND death.date=vac.date
WHERE death.continent is not null
ORDER BY 2,3

--USE CTE
With PopvsVac(continent, location, date, population,new_vaccinations,RollingPplVac)
AS 
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
	death.Date) as RollingPplVac
	--(RollingPplVac/population)*100
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccination vac
	ON death.location=vac.location
	AND death.date=vac.date
WHERE death.continent is not null
)

SELECT *, (RollingPplVac/population)*100 
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPplVac numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
	death.Date) as RollingPplVac
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccination vac
	ON death.location=vac.location
	AND death.date=vac.date
--WHERE death.continent is not null

SELECT *, (RollingPplVac/population)*100
FROM #PercentPopulationVaccinated

--Creating view for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) AS RollingPplVaccinated

FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccination vac
	ON death.location=vac.location
	AND death.date=vac.date
WHERE death.continent is not null