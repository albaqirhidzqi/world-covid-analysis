use PortofolioProject;

select *
from CovidDeaths$
order by 3,4;

select 
	location
	, total_cases
	, new_cases
	, total_deaths
	, population
from CovidDeaths$
order by 1,2;

-- total cases vs total deaths

select 
	location
	, date 
	, total_cases
	, total_deaths
	, (total_deaths/total_cases)*100 as death_pencent
from CovidDeaths$
where location like '%Indo%'
order by 1,2;

-- total cases vs population

select 
	location
	, date 
	, population
	, total_cases
	, total_deaths
	, (total_deaths/population)*100 as death_pencent
from CovidDeaths$
where location like '%Indo%'
order by 1,2;

-- lookin at COuntries with Highest Infection Rate compared

select location, population, max(total_cases) as Highest_infection_count, Max((total_cases/population))*100 as Percen_population_Infected
from coviddeaths$
group by location, population
order by Percen_Population_Infected desc;

-- showing countries with highest Death count per population

select location, MAX(cast(total_deaths as int)) as Total_Death_count
from CovidDeaths$
where continent is not null
group by location
order by Total_Death_count desc;

-- let's break things down by continent

select location, MAX(cast(total_deaths as int)) as Total_Death_count
from CovidDeaths$
where continent is null
group by location
order by Total_Death_count desc;

--showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from CovidDeaths$
where continent is not null
group by continent
order by Total_Death_count desc;

-- Global Numbers

select 
	date, 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_percent
from CovidDeaths$
where continent is not null
group by date
order by 1,2;

select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_percent
from CovidDeaths$
where continent is not null
order by 1,2;



select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(convert(int, cv.new_vaccinations)) OVER (Partition by cd.location) as given_vac
from CovidDeaths$ cd
join CovidVaccinations$ cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3;

-- use cte

with popvsvac (continent, location, date, population, new_vacctinations, given_vac)
as 
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(convert(int, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as given_vac
from CovidDeaths$ cd
join CovidVaccinations$ cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)

select *, (given_vac/population)*100
from popvsvac;


-- TEMP TABLE

drop table if exists #PercentPopulationVacc;

CREATE TABLE #PercentPopulationVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacctinations numeric,
Given_vac numeric
)


insert into #PercentPopulationVacc
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(convert(int, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as given_vac
from CovidDeaths$ cd
join CovidVaccinations$ cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select *, (given_vac/population)*100
from #PercentPopulationVacc;

create view PercentPopulationVac as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(convert(int, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as given_vac
from CovidDeaths$ cd
join CovidVaccinations$ cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select *
from PercentPopulationVac;