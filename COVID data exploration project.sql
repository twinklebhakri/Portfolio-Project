/*

COVID 19 Data exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select * from PortfolioProject..covid_death
where continent is not null
order by 3,4

--select * from PortfolioProject..covid_vaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_death
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,4) as DeathPercentage
from PortfolioProject..covid_death
where location like '%canada%' and continent is not null
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got covid

select location, date, population, total_cases, round((total_cases/population)*100,4) as TotalCasesPercentage
from PortfolioProject..covid_death
--where location like '%canada%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationAffected
from PortfolioProject..covid_death
--where location like '%india%'
group by location, population
order by PercentPopulationAffected desc

--Showing Continent with Highest Death Count per Population
select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..covid_death
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Delete the income groups from location
delete from PortfolioProject..covid_death
where location = 'Low income'

--Showing Countries with Highest Death Count per Population
select location, population, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..covid_death
--where location like '%india%'
where continent is not null
group by location, population
order by TotalDeathCount desc

-- Global Numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covid_death
--where location like '%canada%'
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccination
with PopvsVac(Continent, Location, Date, Population, New_vacinnations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(convert(float,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
from PortfolioProject..covid_death dea
join PortfolioProject..covid_vaccination vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac

--Temp Table

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(convert(float,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
from PortfolioProject..covid_death dea
join PortfolioProject..covid_vaccination vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(convert(float,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
from PortfolioProject..covid_death dea
join PortfolioProject..covid_vaccination vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
