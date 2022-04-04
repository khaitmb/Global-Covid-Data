SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2 -- 1 = location, 2 = date

-- Total Cases vs. Total Deaths
-- Likeliohood of dying if you contract Covid in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%' 
    AND continent IS NOT NULL
ORDER BY 1, 2

-- Total Cases vs. Population
-- Percentage of the population thta contracted Covid

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%states%' 
    AND continent IS NOT NULL
ORDER BY 1, 2

-- Countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- CONTINENT COMPARISON

-- Continents with highest death count

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

-- Per day

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Global average

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total Population vs. Vaccinations

SELECT dea.continent, 
    dea.location, 
    dea.date,
    dea.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--    ,(RollingPeopleVaccinated / dea.population) * 100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--    ,(RollingPeopleVaccinated / dea.population) * 100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3 
)
SELECT *, (RollingPeopleVaccinated / population) * 100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated (
continent nvarchar(100),
location nvarchar(100),
date DATETIME,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--    ,(RollingPeopleVaccinated / dea.population) * 100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated / population) * 100
FROM #PercentPopulationVaccinated

-- Creating Views to store data for later visualizations
-- Global Averages
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Daily Counts
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Highest Percentage and Count
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Percent of Population Infected by Country
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
