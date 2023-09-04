ALTER DATABASE portfolioProject MODIFY NAME = portfolioProject;

select * from portfolioProject..CovidDeaths
order by 3,4
select * from portfolioProject..CovidVaccinations
order by 3,4
--Select Data that we are going to be using
select Location, date, total_cases,new_cases,total_deaths, population
from  portfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select total_deaths,total_cases
from  portfolioProject..CovidDeaths

SELECT
     Location,
    date,
    total_cases,
    total_deaths,
    (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS death_percentage
FROM
    portfolioProject..CovidDeaths
WHERE
    continent = 'Africa'
ORDER BY
    1, 2;

	--Looking at Total Cases vs Population
SELECT
     Location,date,total_cases,Population,(total_cases/Population)*100 as percentPopulationInfection
FROM
    portfolioProject..CovidDeaths
WHERE
     Location = 'Algeria' and  continent is not null
ORDER BY
    1, 2;

	--Countries with Highest Infection Rate compare to population
	 SELECT
     Location,
    Population,
    MAX(total_cases) as HighestInfectionCount,
    (MAX(total_cases / Population)) * 100 as percentPopulationInfection
FROM
    portfolioProject..CovidDeaths
GROUP BY
    Location, Population
ORDER BY
    percentPopulationInfection desc

-- Showing Countries with Highst Death Count per Population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioProject..CovidDeaths
where continent is not null
GROUP BY
    Location
ORDER BY
  TotalDeathCount desc
  -- Showing  continent with Highst Death Count per Population
  --Group by continent
select  continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioProject..CovidDeaths
where continent is not null
GROUP BY
 continent
ORDER BY
  TotalDeathCount desc

  --Global Numbers
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From   portfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- join the death table with vaccination table
select * from   portfolioProject..CovidDeaths cd join   portfolioProject..CovidVaccinations  cv
On  cd.location = cv.location
and cd.date = cv.date

--- Total Population vs Vaccinations

-- USE CTE
with PopvsVac (continent, Loction,date,Population,new_vaccination,peopleVaccinated ) as 
(
select cd.continent,cd.Location,cd.date,cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as float)) OVER (Partition by cd.Location order by cd.Location, cd.date) as peopleVaccinated
from   portfolioProject..CovidDeaths cd join   portfolioProject..CovidVaccinations  cv
On  cd.Location = cv.Location
where cd.continent is not null
and cd.date = cv.date
--order by 2,3
)
select *,(peopleVaccinated/Population)*100
from  PopvsVac

-- TEMP TABLE
create table #percentPopulationVaccination
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
peopleVaccinated numeric
)
insert into #percentPopulationVaccination
select cd.continent,cd.Location,cd.date,cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as float)) OVER (Partition by cd.Location order by cd.Location, cd.date) as peopleVaccinated
from   portfolioProject..CovidDeaths cd join   portfolioProject..CovidVaccinations  cv
On  cd.Location = cv.Location
--where cd.continent is not null
and cd.date = cv.date
select *,(peopleVaccinated/Population)*100
from  #percentPopulationVaccination

-- Creating  View to store data for later visualizations
create View  PercentPopulationVaccination as
select cd.continent,cd.Location,cd.date,cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as float)) OVER (Partition by cd.Location order by cd.Location, cd.date) as peopleVaccinated
from   portfolioProject..CovidDeaths cd join   portfolioProject..CovidVaccinations  cv
On  cd.Location = cv.Location
and cd.date = cv.date
where cd.continent is not null
