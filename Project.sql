--select top(3) *
--from dbo.CovidDeaths

-- selecting data we are going to use
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

--- total deaths vs total cases percent
select location, date, total_cases,total_deaths, (round(total_deaths/total_cases * 100,2)) as Death_percent
from ..CovidDeaths
order by 1,2


-- total cases vs population

select location, date, total_cases, population, (round(total_cases/population *100,2)) as Cases_percent
from ..CovidDeaths
where location='india'
order by 1,2			


--- sotred procedure for location ---
create procedure totalCases @loca varchar(20)
as
select location, date, total_cases, population, (round(total_cases/population *100,2)) as Cases_percent
from ..CovidDeaths
where location= @loca
order by 1,2	

exec totalCases @loca= 'United Kingdom'


--- country with highest infection rate ---

select  location, population ,MAX(total_cases) as mm, max(round(total_cases/population *100,2)) as percent_infec
from ..CovidDeaths
group by location, population
order by percent_infec desc

--select total_cases , location 
--from ..CovidDeaths
--where total_cases = (select MAX(total_cases)from ..CovidDeaths)

--- country max deaths --

select location, max(cast(total_deaths as int)) as mdeaths
from ..CovidDeaths
where continent is not NULL
group by location
order by mdeaths desc

--- continent with max deaths --

select continent, max(cast(total_deaths as int)) as mdeaths
from ..CovidDeaths
where continent is not NULL	
group by continent
order by mdeaths desc

--- global number -- 

select date, sum(new_cases) as newcases,sum(cast (new_deaths as int)) as gdeaths, (sum(cast (new_deaths as int))/sum(new_cases) *100) as DeathPercent
from ..CovidDeaths
where continent is not null
group by date 
order by DeathPercent desc

--- covid vaccinations ---

-- total population vs vaccination ---

select * from ..CovidVaccinations

select cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rolling_count
from ..CovidVaccinations as cv
join ..CovidDeaths as cd
on cv.location = cd.location and cv.date= cd.date
where cd.continent is not null
order by 2,3

--CTE--

with popvsvac ( continent, location, date, population, new_vaccinations, rollowing_count)
as (
select cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rolling_count
from ..CovidVaccinations as cv
join ..CovidDeaths as cd
on cv.location = cd.location and cv.date= cd.date
where cd.continent is not null
--order by 2,3 -- cant be in cte
)

select * , ((rollowing_count)/population*100) as percent_vacc
from popvsvac
order by location, date



--- TEMP TABEL ---

drop table if exists  #pop

create table #pop (continent varchar(50), location varchar(50), date datetime, 
population varchar(50), new_vaccinations int, rollowing_count float)

insert into #pop
select cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rolling_count
from ..CovidVaccinations as cv
join ..CovidDeaths as cd
on cv.location = cd.location and cv.date= cd.date
where cd.continent is not null


select * , ((rollowing_count)/population*100) as percent_vacc
from #pop
order by location, date