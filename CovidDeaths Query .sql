Select * 
from Project ..CovidDeaths
WHere continent is not null
ORDER BY 3,4
select *
from Project ..CovidVaccinations
order by 3,4

--cases vs deaths 
Select location, date, total_cases ,new_cases,total_deaths,(total_deaths/total_cases)*100
as DeathPercentage 
from Project ..CovidDeaths
where location like '%state%'
and continent is not null 
order by 1,2

--cases vs population 
select location ,date ,population , total_cases, (total_cases/population)*100 as casePercentage 
from Project ..CovidDeaths
where location like '%state%'
and continent is not null 
order by 1,2

--Countries with highest infection rate compared to population 

Select location, population, MAX(total_cases) as HighestInfectionRate,
Max(total_cases/population)*100 as PercentagePopulationInfected
from Project ..CovidDeaths
--where location like '%state%'
group by location, population
order by PercentagePopulationInfected desc

--Countries with highest death count vs population 
Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount  
from Project ..CovidDeaths
Where continent is null 
Group by location
order by TotalDeathCount

--Record by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeadthCount
from Project ..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeadthCount 

--Global Number
select SUM(new_cases) as totalCases, SUM( Cast (new_deaths as int ))as TotalDeaths, 
SUM(Cast (new_deaths as int))/ sum(new_cases)*100 as Deathpercentage 
from Project ..CovidDeaths
Where continent is not null
--order by 1,2 

--vaccination record vs population
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert (int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
From Project ..CovidDeaths dea
Join Project ..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--using CTE to perform Calculation on Partition By in previous query
With popvsVac( continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert (int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
From Project ..CovidDeaths dea
Join Project ..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
Select *
,(RollingPeopleVaccinated/population)*100
From PopvsVac

--temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




