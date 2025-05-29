UPDATE covid_vaccinations
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE covid_vaccinations
MODIFY COLUMN `date` DATE;

SELECT *
FROM covid_deaths;

-- Percent who died from covid of people who had it
SELECT location, `date`, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_dead
FROM covid_deaths
ORDER BY 1, 2;

-- Percent who became infected
SELECT location, `date`, population, total_cases, (total_cases/population)*100 AS percent_infected
FROM covid_deaths
ORDER BY 1, 2;

-- Max percenatge infected
SELECT location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS percent_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_infected DESC;


-- Max people that died
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Total population vs. vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS rolling_percentage;


CREATE TEMPORARY TABLE max_vac
(
Continent text,
Location text,
Population bigint,
Total_Vaccinations int,
Percent_Pop_Vaccinated float
);

INSERT INTO max_vac
(
SELECT dea.continent, dea.location, dea.population, MAX(vac.total_vaccinations) AS total_vaccinations, 
(MAX(vac.total_vaccinations)/dea.population)*100 AS percent_pop_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.population
);

SELECT location, percent_pop_vaccinated
FROM max_vac
ORDER BY percent_pop_vaccinated DESC LIMIT 1;

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;



  