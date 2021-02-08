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

-- [
--   {
--     "day": "Sat",
--     "numrides": "1451",
--     "oneways": "1018"
--   },
--   {
--     "day": "Mon",
--     "numrides": "1476",
--     "oneways": "736"
--   }
-- ]


-- Array AGG

select gender
     , ARRAY_AGG(numtrips order by year) as numtrips
from (
         select gender
              , EXTRACT(year from starttime) as year
              , COUNT(1)                     as numtrips
         from `bigquery-public-data.new_york_citibike.citibike_trips`
         where gender != "unknown"
           and starttime is not null
         group by gender, year
         having year > 2016
     )
group by gender

-- [
--   {
--     "gender": "male",
--     "numtrips": [
--       "9306602",
--       "3955871"
--     ]
--   },
--   {
--     "gender": "female",
--     "numtrips": [
--       "3236735",
--       "1260893"
--     ]
--   }
-- ]


-- Arrays with non null elements
with example as (
    select TRUE as is_vowel, 'a' as letter, 1 as position
    UNION ALL
    select false, 'b', 2
    UNION ALL
    select false, 'c', 3
)
select ARRAY_LENGTH(ARRAY_AGG(IF(position = 2, null, position)))
from example

-- [
--   {
--     "f0_": "3"
--   }
-- ]


-- Struct
select [
    struct('male' as gender, [9306602, 3955871] as numtrips)
    , struct('female' as gender, [3236735, 1260893] as numtrips)
    ] as bikerides

-- [
--   {
--     "bikerides": [
--       {
--         "gender": "male",
--         "numtrips": [
--           "9306602",
--           "3955871"
--         ]
--       },
--       {
--         "gender": "female",
--         "numtrips": [
--           "3236735",
--           "1260893"
--         ]
--       }
--     ]
--   }
-- ]

select
    struct('male' as gender, [9306602, 3955871] as numtrips) as male
    , struct('female' as gender, [3236735, 1260893] as numtrips) as female

-- [
--   {
--     "male": {
--       "gender": "male",
--       "numtrips": [
--         "9306602",
--         "3955871"
--       ]
--     },
--     "female": {
--       "gender": "female",
--       "numtrips": [
--         "3236735",
--         "1260893"
--       ]
--     }
--   }
-- ]



-- Array length and getting an element from an array

select
    ARRAY_LENGTH(bikerides) as num_items
    , bikerides[OFFSET(0)].gender as first_gender
from (
    select [
        struct('male' as gender, [9306602, 3955871] as numtrips)
        , struct('female' as gender, [3236735, 1260893] as numtrips)
        ] as bikerides
)

-- [
--   {
--     "num_items": "2",
--     "first_gender": "male"
--   }
-- ]
