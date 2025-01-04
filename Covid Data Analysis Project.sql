select location,date,total_cases,new_cases,total_deaths,population 
from [dbo].[CovidDeaths]
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location,date,total_deaths,total_cases,(cast(total_deaths as float)/cast(total_cases as float)) * 100 as DeathPercentage
from [dbo].[CovidDeaths]
where location = 'India'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

select location,date,population,total_cases,(cast(total_cases as float)/cast(population as float)) * 100 as CovidCasesPercentage
from [dbo].[CovidDeaths]
where location = 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount,
Max(cast(total_cases as float)/cast(population as float)) * 100 as PercentPopulationInfected
from [dbo].[CovidDeaths]
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--Showing the countries with Highest Death Count per population

select location,max(total_deaths) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by location
order by TotalDeathCount desc


--Showing the continent with the highest death count

select continent,max(total_deaths) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select SUM(new_cases) as total_cases,
SUM(new_deaths) as  total_deaths,
(SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent is not null

--Looking at Total population vs Total Vaccinations

select
cd.continent,
cd.location,
cd.date,
cd.population,
cv.new_vaccinations,
SUM(new_vaccinations) OVER(Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from
[dbo].[CovidDeaths] cd
join [dbo].[CovidVaccinations] cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

--Using CTE

With Popvsvac as
(
select
cd.continent,
cd.location,
cd.date,
cd.population,
cv.new_vaccinations,
SUM(new_vaccinations) OVER(Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from
[dbo].[CovidDeaths] cd
join [dbo].[CovidVaccinations] cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
)

select
*,
(cast(RollingPeopleVaccinated as float)/(cast(population as float))) * 100 as RollingPercentPeopleVaccinated
from
Popvsvac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select
cd.continent,
cd.location,
cd.date,
cd.population,
cv.new_vaccinations,
SUM(new_vaccinations) OVER(Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from
[dbo].[CovidDeaths] cd
join [dbo].[CovidVaccinations] cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null

select
*,
(RollingPeopleVaccinated/population) * 100 as RollingPercentPeopleVaccinated
from
#PercentPopulationVaccinated
order by 2,3

--Creating View to store data for visualizations

create view PercentPopulationVaccinated as
select
cd.continent,
cd.location,
cd.date,
cd.population,
cv.new_vaccinations,
SUM(new_vaccinations) OVER(Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from
[dbo].[CovidDeaths] cd
join [dbo].[CovidVaccinations] cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null

select * from PercentPopulationVaccinated



