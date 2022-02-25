--num of distinct entries in activity table
select count(distinct id)
from activity;
--33 distinct records

--number of distinct entries in sleep table
select count(distinct id)
from sleep;
--24 distinct records

--number of distinct entries in weight table
select count(distinct id)
from weight;
--8 distinct records

--finding the time period from which data is collected for activity table
select 
max(activitydate) as max_date,
min(activitydate) as min_date,
count(distinct activitydate) as num_of_dates
from activity;
--the data is of 1 month(31 days) duration from 12-04-2016 to 12-05-2016

--finding the time period of data collection for sleep table
select 
min(sleep_day) as min_date,
max(sleep_day) as max_date,
count(distinct sleep_day) as num_of_dates
from sleep
--the data is of 1 month(31 days) from 12-04-2016 to 12-05-2016

--finding the time period of data collection for weight table
select 
min(date) as min_date,
max(date) as max_date,
count(distinct date) as num_of_dates
from weight
--the data is of 1 month(31 days) from 12-04-2016 to 12-05-2016

--checking consistency of id column for activity table
select * 
from activity
where length(cast(id as text)) <> 10;
--no incosistent values found

--checking consistency of id column for sleep table
select * 
from sleep
where length(cast(id as text)) <> 10;
--no incosistent values found

--checking consistency of id column for weight table
select * 
from weight
where length(cast(id as text)) <> 10;
--no incosistent values found

--checking for duplicate entries in activity table
select id , activitydate, count(activitydate)
from activity
group by activitydate, id
having count(id) > 1 and count(activitydate) > 1
--no duplicate entries found

--checking for duplicate entries in sleep table
select id , sleep_day, count(sleep_day)
from sleep
group by sleep_day, id
having count(id) > 1 and count(sleep_day) > 1
--3 duplicate entries found

--checking for duplicate entries in weight table
select id , date, count(date)
from weight
group by date, id
having count(id) > 1 and count(date) > 1
--no duplicate entries found

--determining if weight logids are its primary key
select 
count(distinct log_id) as unique_logids,
count(log_id) as total_logids
from weight
--logids are NOT the primary keys

-------------------------------Analysis---------------------------------------

--analyzing total steps column of activity table
select
min(totalsteps) as min_steps,
max(totalsteps) as max_steps,
avg(totalsteps) as av_steps
from activity
--min = 0, max = 36019, avg = 7638

--how many entries are there with  total steps
select count(*), count(distinct id)
from activity
where cast(totalsteps as integer) = 0
--77 entries with 0 total_steps out of  which 15 are distinct ids(different people)

--let us look at the data of the people with no activity
select *
from activity
where cast(totalsteps as integer) = 0
group by id, num
--there are 2 possibilites - these people spend their entire 24 hrs sitting or they do not wear the fitbit tracker band.

--joining the tables
select *
from activity inner join sleep
on activity.id = sleep.id and activity.activitydate = sleep.sleep_day
inner join weight on weight.date = sleep.sleep_day and weight.id = sleep.id
-----the table contains 35 rows  


select avg(veryactiveminutes) as avg_very_active,
avg(fairlyactiveminutes) as avg_fairly_active,
avg(lightlyactiveminutes) as avg_lightly_active,
avg(sedentaryminutes) as avg_sedentary
from activity


--grouping on the basis of type of user - active, sedentary etc
select user_type, count(user_type)
from (select *,
case 
	when veryactiveminutes > 21.1648936170212766 and lightlyactiveminutes < 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes < 991.2106382978723404 then 'very_active'
	when fairlyactiveminutes > 13.5648936170212766 and lightlyactiveminutes < 192.8127659574468085 and veryactiveminutes < 21.1648936170212766 and sedentaryminutes < 991.2106382978723404 then 'fairly_active'
	when veryactiveminutes < 21.1648936170212766 and lightlyactiveminutes > 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes < 991.2106382978723404 then 'lightly_active'
	when veryactiveminutes < 21.1648936170212766 and lightlyactiveminutes < 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes > 991.2106382978723404 then 'sedentary'
	else 'dont_know'
end as user_type
from activity
group by num) as temp_1
group by user_type	 

--grouping by day of the week mon, tue etc
select *, to_char(activitydate, 'Day') as Day
from activity
limit 5


--analyzing types of user for activity
select user_type, avg(totalsteps) as avg_steps, avg(totaldistance) as avg_dist, avg(calories) as avg_cal
from(
		select *,
		case 
			when veryactiveminutes > 21.1648936170212766 and lightlyactiveminutes < 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes < 991.2106382978723404 then 'very_active'
			when fairlyactiveminutes > 13.5648936170212766 and lightlyactiveminutes < 192.8127659574468085 and veryactiveminutes < 21.1648936170212766 and sedentaryminutes < 991.2106382978723404 then 'fairly_active'
			when veryactiveminutes < 21.1648936170212766 and lightlyactiveminutes > 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes < 991.2106382978723404 then 'lightly_active'
			when veryactiveminutes < 21.1648936170212766 and lightlyactiveminutes < 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes > 991.2106382978723404 then 'sedentary'
		end as user_type
		from activity
		group by num
	) as temp_table
group by user_type
--very_active and fairly_active users travel more steps and cover more distance and hence burn more calories
--while lighly_active and sedentary users travel less distance and burn lesser calories

--analyzing types of user for sleep
select user_type, sum(total_sleep_records) as total_sleep, avg(total_minutes_asleep) as avg_sleep
from(
		select *,
			case 
				when veryactiveminutes > 21.1648936170212766 and lightlyactiveminutes < 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes < 991.2106382978723404 then 'very_active'
				when fairlyactiveminutes > 13.5648936170212766 and lightlyactiveminutes < 192.8127659574468085 and veryactiveminutes < 21.1648936170212766 and sedentaryminutes < 991.2106382978723404 then 'fairly_active'
				when veryactiveminutes < 21.1648936170212766 and lightlyactiveminutes > 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes < 991.2106382978723404 then 'lightly_active'
				when veryactiveminutes < 21.1648936170212766 and lightlyactiveminutes < 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes > 991.2106382978723404 then 'sedentary'
			end as user_type
		from(
				select *
				from activity inner join sleep
				on activity.id = sleep.id and activity.activitydate = sleep.sleep_day
				inner join weight on weight.date = sleep.sleep_day and weight.id = sleep.id
			) as temp_1
	) as temp_2
group by user_type
--very active and fairly active users take normal sleep while lightly active and sedentary either undersleep or oversleep.

--analyzing types of user for weight
select user_type, avg(weight_kg) as avg_weight, avg(bmi) as avg_bmi
from(
		select *,
			case 
				when veryactiveminutes > 21.1648936170212766 and lightlyactiveminutes < 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes < 991.2106382978723404 then 'very_active'
				when fairlyactiveminutes > 13.5648936170212766 and lightlyactiveminutes < 192.8127659574468085 and veryactiveminutes < 21.1648936170212766 and sedentaryminutes < 991.2106382978723404 then 'fairly_active'
				when veryactiveminutes < 21.1648936170212766 and lightlyactiveminutes > 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes < 991.2106382978723404 then 'lightly_active'
				when veryactiveminutes < 21.1648936170212766 and lightlyactiveminutes < 192.8127659574468085 and fairlyactiveminutes < 13.5648936170212766 and sedentaryminutes > 991.2106382978723404 then 'sedentary'
			end as user_type
		from(
				select *
				from activity inner join sleep
				on activity.id = sleep.id and activity.activitydate = sleep.sleep_day
				inner join weight on weight.date = sleep.sleep_day and weight.id = sleep.id
			) as temp_1
	) as temp_2
group by user_type
--very active and fairly active users have normal weight and bmi

--analyzing day of week for activity
select count(*) as count_, avg(totalsteps) as avg_steps, avg(calories) as avg_calories, day_of_week
from(
		select *, to_char(activitydate, 'Day') as day_of_week
		from activity
	)as temp
group by day_of_week
order by count_
--more steps are taken on mon, tue and sunday whereas more activity takes place on tue, wed and thu

-- analyzing day of week for sleep
select sum(total_sleep_records) as total_no_of_sleeps, avg(total_minutes_asleep) as avg_sleep, day_of_week
from(
		select *, to_char(activitydate, 'Day') as day_of_week
		from(
				select *
				from activity inner join sleep
				on activity.id = sleep.id and activity.activitydate = sleep.sleep_day
				inner join weight on weight.date = sleep.sleep_day and weight.id = sleep.id
			) as temp_1
	) as temp_2
group by day_of_week
--maximum sleeps are on wed and thu

-- weight vs sleep 
select distinct total_sleep_records as total_sleeps, avg(weight_kg) as avg_wt
from(
		select *
		from activity inner join sleep
		on activity.id = sleep.id and activity.activitydate = sleep.sleep_day
		inner join weight on weight.date = sleep.sleep_day and weight.id = sleep.id
	) as temp_1
group by total_sleeps
order by avg_wt desc
--people with less or more sleeps tend to have more weight