# MySQL-Portfolio

# US Household Income Data Cleaning

#Income Statistics
SELECT *
FROM us_project.us_household_income_statistics;

alter table us_project.us_household_income_statistics rename column `ï»¿id` to `ID`;

SELECT *
FROM us_project.us_household_income u
join us_project.us_household_income_statistics us
on u.id = us.id
where mean <> 0;


SELECT u.state_name, round(avg(mean),1) as mean, round(avg(median),1) as median
FROM us_project.us_household_income u
join us_project.us_household_income_statistics us
    on u.id = us.id
where mean <> 0
group by u.state_name
order by 3 desc;

SELECT type, count(type), round(avg(mean),1) as mean, round(avg(median),1) as median
FROM us_project.us_household_income u
join us_project.us_household_income_statistics us
    on u.id = us.id
where mean <> 0
group by type
having count(type) > 100
order by 4 desc;

SELECT u.state_name, city, round(avg(mean),1) as mean, round(avg(median),1) as median
FROM us_project.us_household_income u
join us_project.us_household_income_statistics us
    on u.id = us.id
group by u.state_name, city
order by round(avg(mean),1) desc
;


#household income
select *
FROM us_project.us_household_income
;

SELECT id, count(id)
FROM us_project.us_household_income
Group by id
having count(id) > 1
;

select *
from (
select row_id,
id,
row_number() over(partition by id order by id) row_num
FROM us_project.us_household_income
) duplicates
where row_num > 1
;


delete FROM us_project.us_household_income
where row_id in (
    select row_id
    from (
        select row_id,
        id,
        row_number() over(partition by id order by id) row_num
        FROM us_project.us_household_income
        ) duplicates
    where row_num > 1)
;

select state_name, count(state_name)
FROM us_project.us_household_income
group by state_name
;

update us_project.us_household_income
set state_name = 'Georgia'
where state_name = 'georia';

update us_project.us_household_income
set state_name = 'Alabama'
where state_name = 'alabama';

update us_project.us_household_income
set place = 'Autaugaville'
where county = 'Autauga County'
and city = 'Vinemont';

select type, count(type)
FROM us_project.us_household_income
group by type
;

update us_project.us_household_income
set type = 'Borough'
where type = 'Boroughs';

select aland, awater
from us_project.us_household_income
where (awater = 0 or awater = '' or awater is null)
and (aland = 0 or aland = '' or aland is null)
; 
