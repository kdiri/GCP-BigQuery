select distinct gender
from `bigquery-public-data`.new_york_citibike.citibike_trips;

-- simple select
select gender, tripduration
from `bigquery-public-data`.new_york_citibike.citibike_trips
limit 5;


-- This query will process 0 B when run.
-- Bigquery UNNEST and SPLIT example
select city,
       SPLIT(city, " ") as parts
from (
      select * from UNNEST(["SEATTLE WA", "NEW YORK", "Singapore"]) as city
         )


-- UNION ALL and WITH
with example as (
        select 'Sat' As day, 1451 as numrides, 1018 as oneways
    UNION ALL
        select 'Sun', 2376, 936
    UNION ALL
        select 'Mon', 1476, 736
)
select *
from example
where numrides < 2000

[
  {
    "day": "Sat",
    "numrides": "1451",
    "oneways": "1018"
  },
  {
    "day": "Mon",
    "numrides": "1476",
    "oneways": "736"
  }
]
