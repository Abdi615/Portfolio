Select *
From Portfolio..COVID#DEATHS$
where continent is not null
order by 3,4

--Select *
--From Portfolio..COVID#DEATHS$
--order by 3,4

--Select Data that we are going to using


Select Location, date, total_cases, new_cases, total_deaths, Population
from Portfolio..COVID#DEATHS$


--Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from Portfolio..COVID#DEATHS$
Where location like '%state%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)* 100 as CasePercentage
from Portfolio..COVID#DEATHS$
Where location like '%state%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Pouplation
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)* 100 as PercentPopulationInfected
from Portfolio..COVID#DEATHS$
--Where location like '%state%'
Group by Location, Population
order by PercentPopulationInfected desc


--LETS BREAK THINGS DOWN BY CONTINENT

-- Showing Countries with Highest Death Count Per Population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..COVID#DEATHS$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--SHowing continents with highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..COVID#DEATHS$
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from Portfolio..COVID#DEATHS$
Where continent is not null
Group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(int,vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..COVID#DEATHS$ dea
Join Portfolio..COVID#VACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVID#DEATHS$ dea
Join PortfolioProject..COVID#VACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..COVID#DEATHS$ dea
Join Portfolio..COVID#VACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to Store data for later Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..COVID#DEATHS$ dea
Join Portfolio..COVID#VACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



