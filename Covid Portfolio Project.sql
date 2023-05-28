 -- Creating Data Base 
 Create Database PortfolioProject;
 
 -- Looking at the data
 Select * from PortfolioProject..CovidDeaths ;

 Select * from PortfolioProject..CovidVaccinations;

 Use PortfolioProject;

 -- Select data that we are going to be use

 Select Location, date, total_cases, new_cases, total_deaths,population from PortfolioProject..CovidDeaths order by 1,2;


 -- Looking at total cases Vs total deaths
 -- Shows likelihood of dying if you contract covid in your country

 Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths where location like '%Pakistan%'  order by 1,2;


 --Looikng at the total case vs population
 -- Shows what percentage of population got covid in united states

  Select Location, date, total_cases,Population,(total_cases/population)*100 as PercentagePopulationInfect from CovidDeaths where location like '%states%'  order by 1,2;


-- Countries with highest infection rate compared to population 

  Select Location,Population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
  PercentagePopulationInfected 
  from CovidDeaths 
  group by location,population  
  order by PercentagePopulationInfected Desc;


  -- LET'S BREAK THINGS DOWN BY CONTINENT

  -- Continents with highest death count per Population

  Select continent,Max(cast(total_deaths as int)) as TotalDeathCount 
  from PortfolioProject..CovidDeaths
  where continent is not null
  group by continent
  order by TotalDeathCount Desc;


  -- Global Numbers 
  select  sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
  from PortfolioProject..CovidDeaths where continent is not null
 order by 1,2;

 -- Covid Vaccination data
 -- looking at Total Population vs Vaccination


 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
 sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations 
 vac On dea.location= vac.location and dea.date = vac.date
 where dea.continent is not null 
 order by 2,3


 -- CTE 
 with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
 sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations 
 vac On dea.location= vac.location and dea.date = vac.date
 where dea.continent is not null 
  )

  select *, (RollingPeopleVaccinated/Population) from PopvsVac


  -- Temp Table

  drop table if exists #PercentagePopulationVaccinated
  create table #PercentagePopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric)

  insert into #PercentagePopulationVaccinated
  select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
 sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations 
 vac On dea.location= vac.location and dea.date = vac.date
 where dea.continent is not null 

  select *, (RollingPeopleVaccinated/Population) from #PercentagePopulationVaccinated


-- Creating view to store data for later visualizations

Create view PercentagePopulationVaccinated as 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
 sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations 
 vac On dea.location= vac.location and dea.date = vac.date
 where dea.continent is not null 

 select * from PercentagePopulationVaccinated