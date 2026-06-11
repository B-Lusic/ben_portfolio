-- total deaths vs total cases

select 
FORMAT(CAST(date AS DATE), 'yyyy-MM') AS month,
sum(total_cases) as total_cases, 
sum(new_cases) as new_cases, 
sum(total_deaths) as total_deaths,
max(population) as population,
sum(ROUND(total_deaths / total_cases, 4) * 100) AS death_percentage
FROM coviddeaths
where location like '%united states%'
group by FORMAT(CAST(date AS DATE), 'yyyy-MM')
ORDER BY month asc;


-- shows what percentage of population got covid
-- total cases vs population
-- Had to change the equation (sum(total_cases) / max(population)) because it was totalling the total deaths to the next month
-- and the total deaths were being compounded.

select 
FORMAT(CAST(date AS DATE), 'yyyy-MM') AS month,
sum(total_cases) as total_cases, 
sum(new_cases) as new_cases, 
sum(total_deaths) as total_deaths,
max(population) as population,
ROUND(sum(new_cases) / max(population), 4) * 100 AS percent_of_population_infected
FROM coviddeaths
where location like '%united states%'
group by FORMAT(CAST(date AS DATE), 'yyyy-MM')
ORDER BY month asc
;

--Showing continents with highest death count per population

select 
continent, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by totalDeathCount desc
;

--Showing Countries with highest death count per population

select 
location, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by totaldeathcount desc
;

--Countries with the highest infection rate compared to population

select 
location as country, 
max(total_cases) as highest_infection_count,
sum(new_cases) as new_cases, 
sum(total_deaths) as total_deaths,
max(population) as population,
round(max(total_cases) / max(population), 4) * 100 AS percent_of_population_infected,
round(max(total_deaths) / max(population), 4) * 100 AS percent_of_population_dead
FROM coviddeaths
where continent is not null
group by location
ORDER BY percent_of_population_dead desc
;

--Continents with highest infection rate compared to population

select 
continent, 
max(total_cases) as highest_infection_count,
sum(new_cases) as new_cases, 
sum(total_deaths) as total_deaths,
max(population) as population,
round(max(total_cases) / max(population), 4) * 100 AS percent_of_population_infected,
round(max(total_deaths) / max(population), 4) * 100 AS percent_of_population_dead
FROM coviddeaths
where continent is not null
group by continent
ORDER BY percent_of_population_dead desc
;


--Joiniung Tables
--Total population vs vaccinations

select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rolling_total_vaccinations
from coviddeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by dea.location, dea.date;

-- Summary total for each continent

SELECT 
    dea.location, 
    SUM(CAST(vac.new_vaccinations AS BIGINT)) AS total_vaccinations_given
FROM coviddeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location
ORDER BY dea.location;

--use cte

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations) AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date,       
        dea.population, 
        vac.new_vaccinations,
        SUM(TRY_CONVERT(BIGINT, vac.new_vaccinations)) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.location, CAST(dea.date AS DATE)
        ) AS rolling_total_vaccinations
    FROM coviddeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND CAST(dea.date AS DATE) = CAST(vac.date AS DATE)
    WHERE dea.continent IS NOT NULL
)
SELECT 
    *, 
    ROUND((CAST(rolling_total_vaccinations AS FLOAT) / NULLIF(population, 0)) * 100, 4) AS rolling_perc_vaccinated
FROM popvsvac;

-- creating view to store data for later visualizations

create view Percent_of_Pop_Vaccinated as
SELECT 
        dea.continent, 
        dea.location, 
        dea.date,       
        dea.population, 
        vac.new_vaccinations,
        SUM(TRY_CONVERT(BIGINT, vac.new_vaccinations)) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.location, CAST(dea.date AS DATE)
        ) AS rolling_total_vaccinations
    FROM coviddeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND CAST(dea.date AS DATE) = CAST(vac.date AS DATE)
    WHERE dea.continent IS NOT NULL