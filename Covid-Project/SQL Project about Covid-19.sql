select *
from PorfolioProject..[Covid Deaths]
where continent is not null
order by 3,4

-- Select data for our project
select location, date, total_cases, new_cases, total_deaths,population
from PorfolioProject..[Covid Deaths]
order by 1,2


--Looking at Total Cases versus Total Deaths
--Show likelihood of dying if contract covid in Vietnam
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProject..[Covid Deaths]
where location like 'Vietnam'
and continent is not null
order by 1,2

-- Looking at Total Cases versus Population
--Show what percentage of population got covid in Vietnam
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PorfolioProject..[Covid Deaths]
where location like 'Vietnam'
order by 1,2

-- Looking at Countries with the Highest Infection Rates compared to Population
select location, population, Max(total_cases) as HighInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PorfolioProject..[Covid Deaths]
--where location like 'Vietnam'
group by location, population
order by PercentPopulationInfected desc

-- Break things down in more detail by different Continents
-- Showing continents with the highest death count per population
select continent, Max(total_deaths) as TotalDeathCount
from PorfolioProject..[Covid Deaths]
--where location like 'Vietnam'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Show Global New_Cases
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorfolioProject..[Covid Deaths]
--where location like 'Vietnam'
where continent is not null
order by 1,2

-- Looking at the Total Population versus Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as NumberofPeopleVaccinated
from PorfolioProject..[Covid Deaths] dea
join PorfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac(Continent, Location, Date, Population,New_Vaccinations, NumberofPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as NumberofPeopleVaccinated
from PorfolioProject..[Covid Deaths] dea
join PorfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (NumberofPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
NumberofPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--Use bigint instead of int because of error agg 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as NumberofPeopleVaccinated

from PorfolioProject..[Covid Deaths] dea
join PorfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3
Select *, (NumberofPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--Use bigint instead of int because of error agg 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as NumberofPeopleVaccinated

from PorfolioProject..[Covid Deaths] dea
join PorfolioProject..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null
--order by 2,3