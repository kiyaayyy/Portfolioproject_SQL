select*
from portfolioproject..CovidDeaths$
order by 3,4

select*
from portfolioproject..CovidVaccinations$
order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths$
order by 1,2


--looking at total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..CovidDeaths$
where location like '%india%'
order by 1,2

--looking at total cases vs population
--shows what percenatge of population got covid

select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths$
--where location like '%india%'
order by 1,2

--looking at countries with highest infection rate compared to  population

select location,population, Max(total_cases) as highestinfectionCount,  
max((total_cases/population))*100 as PercentPopulationInfected

from portfolioproject..CovidDeaths$

--where location like '%india%'
Group by location,population
order by PercentPopulationInfected desc

--showing countries with highest death count per population


select continent, Max(cast(total_deaths as int)) as TotalDeathcount

from portfolioproject..CovidDeaths$
where continent is not null

--where location like '%india%'
Group by continent
order by TotalDeathcount desc


--showing the continenst with highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathcount

from portfolioproject..CovidDeaths$
where continent is not null

--where location like '%india%'
Group by continent
order by TotalDeathcount desc

--global numbers

select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
--total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage

from portfolioproject..CovidDeaths$
where continent is not null
--where location like '%india%'
group by date
order by 1,2

--looking at total population vs  vaccinations

-- use cte
with PopvsVac(continent,location,date,population, New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select*,(RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table
DROP table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric

)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$  vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #Percentpopulationvaccinated


--creating view for store data for later visualizations

create view Percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
