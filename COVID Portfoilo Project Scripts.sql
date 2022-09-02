-- SELECT *
-- FROM PortfolioProject1..Coviddeaths
-- ORDER BY 3,4

-- SELECT *
-- FROM PortfolioProject1..covidVax
-- ORDER BY 3,4

-- WORK DATA SELECTION AND ORGANIZE BY LOCATION NAME
--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject1..Coviddeaths
--ORDER BY 1,2

-- Looking at total cases vs total deaths
-- likelihood of dying if covid infected in Bangladesh.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject1..Coviddeaths
where location like '%desh%'
ORDER BY 1,2

-- Looking at total cases vs Populations
-- shows what percentage of population got covid.
SELECT location, date, total_cases, population, (total_cases/population)*100 as casePercentage
FROM PortfolioProject1..Coviddeaths
where location = 'Bangladesh'
ORDER BY 1,2

-- What country has the highest infection rate compared to population?
SELECT location, MAX(total_cases) as highestCovidPostive, population, Max(total_cases/population)*100 as MaxCasePercentage
FROM PortfolioProject1..Coviddeaths
GROUP BY location, population
ORDER BY MaxCasePercentage DESC

-- Showing Countries Highest Death Count per Population
---- issue: with data type as it was var 255. converted to int.
---- issue with grouped data as world, africa etc (checked table and find all those have null in continent column)
SELECT location, MAX(CAST (total_deaths AS INT)) as totalDeathCount
FROM PortfolioProject1..Coviddeaths
WHERE continent IS NOT NULL
Group by location
ORDER BY totalDeathCount DESC

-- Showing continents with Highest Death Count per Population
---- issue: with data type as it was var 255. converted to int.
SELECT Continent, MAX(CAST (total_deaths AS INT)) as totalDeathCount
FROM PortfolioProject1..Coviddeaths
WHERE Continent is not null
Group by Continent
ORDER BY totalDeathCount DESC

-- GLOBAL NUMBERS
-- CASES / DAY
-- DEATHS / DAY
--
SELECT SUM(new_cases) as CasesPerDay, 
			 SUM(CAST(new_deaths AS INT)) AS DeathsPerDay, 
			(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject1..Coviddeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2




------------- covid vax ------------------
--SELECT * FROM PortfolioProject1..covidVax

--join 2 tables
-- LOOKING AT TOTAL POPULATION VS VACCINATION
-- DOING STUFF ASSUMING TOTAL VALUE ISN'T THERE (EX: TOTAL VAX)
-- ENCOUNTERED: Arithmetic overflow error converting expression to data type int.// SOLVE: BIGINT
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations,
		SUM(CONVERT(BIGINT, vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) 
		AS RollingPeopleGotVax --,RollingPeopleGetVax/population)*100
FROM PortfolioProject1..Coviddeaths as death
JOIN PortfolioProject1..CovidVax as vax
	ON death.location = vax.location
	and death.date = vax.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE 
-- keep column number same or it will show error
WITH PopvsVax (Continent, location, Date, Population, new_vaccinations, RollingPeopleGotVax) 
AS
(
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations,
		SUM(CONVERT(BIGINT, vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) 
		AS RollingPeopleGotVax 
	--, (RollingPeopleGetVax/population)*100
FROM PortfolioProject1..Coviddeaths as death
JOIN PortfolioProject1..CovidVax as vax
	ON death.location = vax.location
	and death.date = vax.date
WHERE death.continent IS NOT NULL
)
SELECT * ,(RollingPeopleGotVax/population)*100
FROM PopvsVax

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationGotVax
CREATE TABLE #PercentPopulationGotVax
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
population numeric,
NewVax numeric,
RollingPeopleGotVax numeric
)

INSERT INTO #PercentPopulationGotVax
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations,
		SUM(CONVERT(BIGINT, vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) 
		AS RollingPeopleGotVax --,RollingPeopleGetVax/population)*100
FROM PortfolioProject1..Coviddeaths as death
JOIN PortfolioProject1..CovidVax as vax
	ON death.location = vax.location
	and death.date = vax.date
--WHERE death.continent IS NOT NULL

SELECT * ,(RollingPeopleGotVax/population)*100
FROM #PercentPopulationGotVax



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION 


CREATE VIEW PercentPopulationGotVax AS
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations,
	SUM(CONVERT(BIGINT, vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) 
	AS RollingPeopleGotVax 
	--,RollingPeopleGetVax/population)*100
FROM PortfolioProject1..Coviddeaths as death
JOIN PortfolioProject1..CovidVax as vax
	ON death.location = vax.location
	and death.date = vax.date
WHERE death.continent IS NOT NULL

CREATE VIEW CaseGrowthBD AS
SELECT location, date, total_cases, population, (total_cases/population)*100 as casePercentage
FROM PortfolioProject1..Coviddeaths
where location = 'Bangladesh'


CREATE VIEW DeathCountByCountry AS
-- Showing Countries Highest Death Count per Population
---- issue: with data type as it was var 255. converted to int.
---- issue with grouped data as world, africa etc (checked table and find all those have null in continent column)
SELECT location, MAX(CAST (total_deaths AS INT)) as totalDeathCount
FROM PortfolioProject1..Coviddeaths
WHERE continent IS NOT NULL
Group by location

CREATE VIEW CasePercentageByCountry AS 
-- What country has the highest infection rate compared to population?
SELECT location, MAX(total_cases) as highestCovidPostive, population, Max(total_cases/population)*100 as MaxCasePercentage
FROM PortfolioProject1..Coviddeaths
GROUP BY location, population
