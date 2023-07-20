--select *
--from PortfolioProject..CovidDeaths
--where continent is not null
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- Select Data That We Are Going To Be Using
--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths
--order by 1,2

--Looking at Total Cases vs. Total Deaths
--Shows Likelihood of Dying If You Contract COVID in Your Country
--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where location like '%indo%'
--and continent is not null
--order by 1,2

--Looking at Total Cases vs. Population
--Shows What Percentage of Population Got COVID
--select location, date, population, total_cases, (total_cases/population)*100 as	PopulationPercentage
--from PortfolioProject..CovidDeaths
--where location like '%states%'
--order by 1,2

--Looking at Countries With Highest Infection Rate Compared to Population
--select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
--from PortfolioProject..CovidDeaths
--group by location, population
--order by PercentPopulationInfected desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--select continent, max(cast(total_deaths as int)) as TotalDeathsCount
--from PortfolioProject..CovidDeaths
--where continent is not null
--group by continent
--order by TotalDeathsCount desc

--Showing the Continents With Highest Death Count per Population
--select continent, max(cast(total_deaths as int)) as TotalDeathsCount
--from PortfolioProject..CovidDeaths
--where continent is not null
--group by continent
--order by TotalDeathsCount desc


--Showing Countries With Highest Death Count per Population
select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc

--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

SELECT
    Dea.continent,
    Dea.location,
    Dea.date,
    Dea.population,
    Vac.new_vaccinations,
    SUM(convert(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
    ON Dea.location = Vac.location
    AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE
WITH PopulationvsVaccination (Continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
    SELECT
        Dea.continent,
        Dea.location,
        Dea.date,
        Dea.population,
        Vac.new_vaccinations,
        SUM(convert(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
        -- (RollingPeopleVaccinated/population)*100  -- Commented out the line to fix the syntax error
    FROM PortfolioProject..CovidDeaths Dea
    JOIN PortfolioProject..CovidVaccinations Vac
        ON Dea.location = Vac.location
        AND Dea.date = Vac.date
    WHERE Dea.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM PopulationvsVaccination;


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT
        Dea.continent,
        Dea.location,
        Dea.date,
        Dea.population,
        Vac.new_vaccinations,
        SUM(convert(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths Dea
    JOIN PortfolioProject..CovidVaccinations Vac
        ON Dea.location = Vac.location
        AND Dea.date = Vac.date
    --WHERE Dea.continent IS NOT NULL

	SELECT *, (rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
create view PercentPopulationVaccinated as 
SELECT
        Dea.continent,
        Dea.location,
        Dea.date,
        Dea.population,
        Vac.new_vaccinations,
        SUM(convert(int,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths Dea
    JOIN PortfolioProject..CovidVaccinations Vac
        ON Dea.location = Vac.location
        AND Dea.date = Vac.date
    WHERE Dea.continent IS NOT NULL

	select *
	from PercentPopulationVaccinated