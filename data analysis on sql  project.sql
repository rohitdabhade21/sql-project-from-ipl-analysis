--Task-1 creating table "matches" for match related data 


create table matches(
     id int,
     city varchar,
	 date date,
	player_of_match varchar,
	venue varchar,
	neutral_venue int,
	team1 varchar,
	team2 varchar,
	toss_winner varchar,
	toss_decision varchar,
	winner varchar,
	result varchar,
	result_margin int,
	eliminator varchar,
	method varchar,
	umpire1 varchar,
	umpire2 varchar
);


--Task-2 creating table "deliveries" for ball-to-ball related data 

create table deliveries(
    id int,
	inning int,
	over int,
	ball int,
	batsman varchar,
	non_striker varchar,
	bowler varchar,
	batsman_runs int,
	extra_runs int,
	total_runs int,
	is_wicket int,
	dismissal_kind varchar,
	player_dismissed varchar,
	fielder varchar,
	extras_type varchar,
	batting_team varchar,
	bowling_team varchar
);

--Task-3 Importing data from CSV file 'IPL_matches.csv' --- downloaded file from resources 

copy matches from 'C:\Program Files\PostgreSQL\16\data\CSV files\IPL_matches.csv'CSV header;

--Task-4 Importing data from CSV file 'IPL_Ball.csv' --- downloaded file from resources 

copy deliveries from 'C:\Program Files\PostgreSQL\16\data\CSV files\IPL_Ball.csv'CSV header;

--Task-5 Select the top 20 rows of the deliveries table 

select * from deliveries limit 20;


-- Task-6 Select the top 20 rows of the matches table.

select * from matches limit 20;


--Task-7 Fetch data of all the matches played on 2nd May 2013

select * from matches where date='02-05-2013';


--Task-8 Fetch data of all the matches where the margin of victory is more than 100 runs

select * from matches where result='runs' and result_margin>100;

-- Task-9 Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date
select * from matches where result='tie'
order by date desc;

-- Get the count of cities that have hosted an IPL match
select count(distinct city) from matches;

--Task-11 Create table deliveries_v02 with all the columns of deliveries and an additional column ball_result containing value boundary,
--dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number)

create table deliveries_v02
as select *,
  case
     when total_runs >=4 then 'boundary'
	 when total_runs =0 then 'dot'
	 else 'other'
  end as ball_result
from deliveries;
 
--Task-12 Write a query to fetch the total number of boundaries and dot balls

select ball_result,
   count(*) from deliveries_v02
   group by ball_result;

-- Task-13 Write a query to fetch the total number of boundaries scored by each team

select batting_team, count(*)
  from deliveries_v02
  where ball_result='boundary'
  group by batting_team
  order by count desc;
 
--Task-14 Write a query to fetch the total number of dot balls bowled by each team
 
select batting_team, count(*)
 from deliveries_v02
 where ball_result='dot'
 group by batting_team
 order by count desc;


--Task-15 Write a query to fetch the total number of dismissals by dismissal kinds

select dismissal_kind, count(is_wicket)
  from deliveries
  where is_wicket=1
  group by dismissal_kind
  order by count desc;
  
--Task-16 Write a query to get the top 5 bowlers who conceded maximum extra runs
SQL
select bowler, sum(extra_runs) as maximum_extra_runs
from deliveries
group by bowler
order by maximum_extra_runs desc
limit 5;

--Task-17 Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column
--(named venue and match_date) of venue and date from table matches

create table deliveries_v03 as select a.* , b.venue , b.match_date
from deliveries_v02 as a
left join(select max(venue) as venue ,max(date) as match_date, id from matches group by id) as b
on a.id=b.id;
```
--Task-18 Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.

select venue , sum(total_runs) as runs
from deliveries_v03
group by venue
order by runs desc;

--Task-19 Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored

select extract(year from match_date) as years,
       sum(total_runs) as runs
from deliveries_v03
where venue='Eden Gardens'
group by years
order by runs desc;


--Task-20 Get unique team1 names from the matches table, you will notice that there are two entries
--for Rising Pune Supergiant one with Rising Pune Supergiant and another one with Rising Pune Supergiants. 
--Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr containing team names
--with replacing Rising Pune Supergiants with Rising Pune Supergiant. Now analyse these newly created columns.

select distinct team1 from matches;

create table matches_corrected as select *,
replace(team1,'Rising Pune Supergaints','Rising Pune Supergaint') as team1_corr,
replace(team2,'Rising Pune Supergaints','Rising Pune Supergaint') as team2_corr
from matches;
```
-- Task-21 Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated by

create table deliveries_v04
as select concat(id,'-',inning,'-',over,'-',ball)
as ball_id , * from deliveries_v03;

--Task-22 Compare the total count of rows and total count of distinct ball_id in deliveries_v04

select count(distinct ball_id) from deliveries_v04;

select count(*) from deliveries_v04;
