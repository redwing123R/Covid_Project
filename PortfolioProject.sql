Select *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4


-- Selecting Data I will be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'South Africa'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of papulation that contracted covid

 Select location, date,population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'South Africa'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population


 Select location, 
        population, 
		MAX(total_cases) AS Highest_Infection_Count,
		Round(MAX((total_cases/population)),2)*100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'South Africa'
Group By location, population
ORDER BY Percent_Population_Infected desc


-- I take these out as they are not included in the above queries and i want to be consistant
-- European Union is part of Europe

SELECT location,
       SUM(CAST(new_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
AND location NOT IN ('World','European_Union','International')
GROUP BY location
ORDER BY Total_Death_Count

-- Showing Countries with Highest Death Count per Population

 Select location,  
		MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'South Africa'
WHERE continent IS NOT NULL
Group By location
ORDER BY Total_Death_Count desc

-- Broke down by continent

-- Select location,  
--		MAX(cast(total_deaths as int)) AS Total_Death_Count
--FROM PortfolioProject..CovidDeaths$
---- WHERE location = 'South Africa'
--WHERE continent IS NOT NULL
--Group By location
--ORDER BY Total_Death_Count desc

 Select continent,  
		MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'South Africa'
WHERE continent IS NOT NULL
Group By continent
ORDER BY Total_Death_Count desc

-- Showing continents with highest death count per population

 Select continent,  
		MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'South Africa'
WHERE continent IS NOT NULL
Group By continent
ORDER BY Total_Death_Count desc

-- Global numbers

Select date, 
       sum(new_cases) AS Total_Cases, 
	   SUM(cast(new_deaths as int)) AS Total_Deaths, 
	   SUM(cast(New_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'South Africa'
WHERE continent IS NOT NULL
GROUP By date
ORDER BY 1,2

-- ABOVE TOTALS 
-- Removed group by date

Select sum(new_cases) AS Total_Cases, 
	   SUM(cast(new_deaths as int)) AS Total_Deaths, 
	   SUM(cast(New_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'South Africa'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS INT)) 
	   OVER (Partition by dea.location ORDER BY dea.location, dea.date)
	   AS Rolling_People_Vaccinated
-- ,   (Rolling_People_Vaccinated/ Population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccines$ vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USING CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, Rolling_People_Vaccinated)
AS(
SELECT dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS INT)) 
	   OVER (Partition by dea.location ORDER BY dea.location, dea.date)
	   AS Rolling_People_Vaccinated
-- ,   (Rolling_People_Vaccinated/ Population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccines$ vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)

SELECT *,(Rolling_People_Vaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS INT)) 
	   OVER (Partition by dea.location ORDER BY dea.location, dea.date)
	   AS Rolling_People_Vaccinated
-- ,   (Rolling_People_Vaccinated/ Population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccines$ vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *,(Rolling_People_Vaccinated/population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS INT)) 
	   OVER (Partition by dea.location ORDER BY dea.location, dea.date)
	   AS Rolling_People_Vaccinated
-- ,   (Rolling_People_Vaccinated/ Population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccines$ vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

















































