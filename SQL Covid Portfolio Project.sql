-- SELECT *
-- FROM Covid_Deaths
-- ORDER BY 3, 4

-- SELECT *
-- FROM Covid_Vaccinations
-- ORDER BY 3, 4

-- SELECT Data that we will use

-- SELECT location, date, total_cases, new_cases, total_deaths, population
-- FROM Covid_Deaths
-- ORDER BY 1, 2



-- Total Cases vs Total Deaths

-- SELECT location, date, total_cases, total_deaths, 
-- CASE 
--     WHEN total_cases = 0 THEN NULL
--     ELSE (CAST(total_deaths AS FLOAT)/total_cases) * 100 
-- END AS DeathPerc
-- FROM Covid_Deaths
-- WHERE location like '%belize%'
-- ORDER BY 1, 2


-- Total Cases vs Population
SELECT location, date, population, total_cases, total_deaths, 
CASE 
     WHEN total_cases = 0 THEN NULL
     ELSE (CAST(total_cases AS FLOAT)/population) * 100 
END AS CovidContractedPerc
FROM Covid_Deaths
WHERE location like '%states'
ORDER BY 1, 2

-- Countries with High Infection Rate
SELECT location, population, MAX(total_cases) as MaxInfectionCount, 
CASE 
     WHEN MAX(total_cases) = 0 THEN NULL
     ELSE CAST(MAX(total_cases) AS FLOAT)/population * 100 
END AS InfectedPerc
FROM Covid_Deaths
WHERE location like '%states'
GROUP BY location, population
order by InfectedPerc DESC


--Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Covid_Deaths
--WHERE location like '%states'
Where continent is not NULL
GROUP BY location, population
order by TotalDeathCount DESC

--Continents with Highest Death Count
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Covid_Deaths
--WHERE location like '%states'
Where continent is not NULL
GROUP BY continent
order by TotalDeathCount DESC

-- Global Numbers
SELECT date, sum(new_cases) as totalNewCases, sum(new_deaths) as totalDeaths, 
CASE 
    WHEN sum(new_cases) = 0 THEN NULL
    ELSE (sum(cast(new_deaths as float)) / sum(new_cases)) * 100 
END as DeathPerc
FROM Covid_Deaths
WHERE new_cases <> 0
group by date
order by 1, 2



-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, population, vax.new_vaccinations,
SUM(cast(new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as VaxAmount
FROM Covid_Deaths dea
Join Covid_Vaccinations vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE new_vaccinations is not null
order by 2, 3


-- CTE
-- WITH PopVsVac (continent, location, date, population, new_vacctionations, VaxAmount)
-- as (
-- SELECT dea.continent, dea.location, dea.date, population, vax.new_vaccinations,
-- SUM(cast(new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as VaxAmount
-- FROM Covid_Deaths dea
-- Join Covid_Vaccinations vax
--     ON dea.location = vax.location
--     AND dea.date = vax.date
-- WHERE dea.continent is not null
-- )

-- select *, VaxAmount/Population * 100
-- from PopVsVac

-- Creating view for later visualizations
CREATE VIEW PopVsVac AS 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vax.new_vaccinations,
    SUM(CAST(vax.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS VaxAmount
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL;



