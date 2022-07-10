select * from Portfolio_project..CovidDeaths
where continent is not null
order by 3,4;

--select * from Portfolio_project..CovidVaccinations
--order by 3,4

--TO SELECT THE DATA THAT WILL BE USED
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project..CovidDeaths
Order by 1,2;

--TOTAL CASES VS. TOTAL DEATHS, TO SHOW DEATH RATE BY COUNTRY
select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases*100), 2) as death_rate
from Portfolio_project..CovidDeaths
where location like '%nigeria%'
Order by 1,2;

--INFECTION RATES BY COUNTRY
select location, date, total_cases, population, ROUND((total_cases/population*100), 2) as infection_rate
from Portfolio_project..CovidDeaths
where location like '%nigeria%'
Order by 1,2;

--COUNTRIES WITH HIGHEST INFECTION RATES
select TOP (10) location, MAX(total_cases) as most_cases, population, MAX(ROUND((total_cases/population*100), 2)) as infection_rate
from Portfolio_project..CovidDeaths
Group by location, population
Order by infection_rate desc;

--LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNTS AND RATES
select TOP (10) location, MAX(total_deaths) as most_deaths, population, MAX(ROUND((total_deaths/total_cases*100), 2)) as death_rate
from Portfolio_project..CovidDeaths
where continent is not null
Group by location, population
Order by most_deaths desc;

select TOP (10) location, MAX(cast(total_deaths as int)) as most_deaths
from Portfolio_project..CovidDeaths
where continent is not null 
Group by location
order by most_deaths desc;

--HIGHEST DEATH COUNT BY CONTINENT
select location, MAX(cast(total_deaths as int)) as most_deaths
from Portfolio_project..CovidDeaths
where continent is null 
Group by location
order by most_deaths desc;

--GLOBAL FIGURES
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases)*100), 2) as death_rate,
ROUND((SUM(new_cases)/SUM(population)*100), 4) as infection_rate
from Portfolio_project..CovidDeaths
where continent is not null 
order by 1,2; 

--COVID VACCINATIONS VS POPULATION
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as total_vax
from Portfolio_project..CovidDeaths cd
join Portfolio_project..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv. date
where cv.new_vaccinations is not null and cd.continent is not null
order by 2,3;

--TOP VACCINATING COUNTRIES
select TOP (10) cd.location, MAX(cast(cv.new_vaccinations as int)) as total_vax
from Portfolio_project..CovidDeaths cd
join Portfolio_project..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv. date
where cv.new_vaccinations is not null and cd.continent is not null 
Group by cd.location
order by total_vax desc;


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vax, Total_Vax)
as
(select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as total_vax
from Portfolio_project..CovidDeaths cd
join Portfolio_project..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv. date
where cv.new_vaccinations is not null and cd.continent is not null
)
select *, ROUND((Total_Vax/Population)*100, 3) as Percent_Vax
from PopvsVac

--VIEWS FOR VISUALIZATION
Create view PercentVaxPopulation as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as total_vax
from Portfolio_project..CovidDeaths cd
join Portfolio_project..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv. date
where cv.new_vaccinations is not null and cd.continent is not null

select * from PercentVaxPopulation

create view Death_rate as
select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases*100), 2) as death_rate
from Portfolio_project..CovidDeaths
where continent is not null
--Order by 1,2;

create view Infection_rate as
select location, date, total_cases, population, ROUND((total_cases/population*100), 2) as infection_rate
from Portfolio_project..CovidDeaths
where continent is not null
--Order by 1,2;

create view Countries_with_high_IR as
select location, MAX(total_cases) as most_cases, population, MAX(ROUND((total_cases/population*100), 2)) as infection_rate
from Portfolio_project..CovidDeaths
where continent is not null
Group by location, population
--Order by infection_rate desc;

create view Countries_with_high_DR as
select location, MAX(total_deaths) as most_deaths, population, MAX(ROUND((total_deaths/total_cases*100), 2)) as death_rate
from Portfolio_project..CovidDeaths
where continent is not null
Group by location, population
--Order by most_deaths desc;

create view Global_COVID_Figures as
select
SUM(cd.new_cases) as total_cases, SUM(cast(cd.new_deaths as int)) as total_deaths, 
ROUND((SUM(cast(cd.new_deaths as int))/SUM(cd.new_cases)*100), 2) as death_rate,
ROUND((SUM(cd.new_cases)/SUM(cd.population)*100), 4) as infection_rate,
SUM(cast(cv.new_vaccinations as int)) as total_vax
from Portfolio_project..CovidDeaths cd
join Portfolio_project..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv. date
where cv.new_vaccinations is not null and cd.continent is not null

create view Top_Vaccinating_countries as
select cd.location, MAX(cast(cv.new_vaccinations as int)) as total_vax
from Portfolio_project..CovidDeaths cd
join Portfolio_project..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv. date
where cv.new_vaccinations is not null and cd.continent is not null 
Group by cd.location
--order by total_vax desc;

--FINISH