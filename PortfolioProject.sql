
Select *
From PortfolioProject..['COVID Deaths$']
Where continent is not null
order by 3,4 

--Select *
--From PortfolioProject..['COVID Vaccinations$']
--order by 3,4 

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..['COVID Deaths$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['COVID Deaths$']
Where location like '%states%'
order by 1,2 


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['COVID Deaths$']
Where location like '%states%'
order by 1,2 


-- Looking at Countries with Highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfecctionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..['COVID Deaths$']
--Where location like '%ststes%' 
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with the Highest Death Count Per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID Deaths$']
--Where location like '%ststes%' 
Where continent is not null
Group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID Deaths$']
--Where location like '%ststes%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['COVID Deaths$']
--Where location like '%states%'
where continent is not null 
Group by date
order by 1,2 


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100 
From PortfolioProject.. ['COVID Deaths$'] dea
Join PortfolioProject..['COVID Vaccinations$'] vac
	On dea.location =vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVacccinated) 
as
(
Select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100 
From PortfolioProject.. ['COVID Deaths$'] dea
Join PortfolioProject..['COVID Vaccinations$'] vac
	On dea.location =vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVacccinated/Population)*100
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert #PercentPopulationVaccinated
Select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100 
From PortfolioProject.. ['COVID Deaths$'] dea
Join PortfolioProject..['COVID Vaccinations$'] vac
	On dea.location =vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100 
From PortfolioProject.. ['COVID Deaths$'] dea
Join PortfolioProject..['COVID Vaccinations$'] vac
	On dea.location =vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated



