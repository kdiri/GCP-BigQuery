select distinct gender
from `bigquery-public-data`.new_york_citibike.citibike_trips;

-- simple select
select gender, tripduration
from `bigquery-public-data`.new_york_citibike.citibike_trips
limit 5;
