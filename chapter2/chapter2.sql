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
group by gender;

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
from example;

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
    , struct('female' as gender, [3236735, 1260893] as numtrips) as female;

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
);

-- [
--   {
--     "num_items": "2",
--     "first_gender": "male"
--   }
-- ]


-- UNNEST an array: can be usable with **from** item
select * from unnest(
    [
        struct('male' as gender, [9306602, 3955871] as numtrips)
        , struct('female' as gender, [3236735, 1260893] as numtrips)
    ]
);

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


--

WITH bicycle_rentals AS (
    SELECT    COUNT (starttime) as num_trips,    EXTRACT(DATE from starttime) as trip_date
    FROM `bigquery-public-data`.new_york_citibike.citibike_trips
    GROUP BY trip_date
),

rainy_days AS(
    SELECT  date,  (MAX(prcp) > 5) AS rainy
    FROM (
        SELECT
            wx.date AS date
            , IF (wx.element = 'PRCP', wx.value/10, NULL) AS prcp
        FROM  `bigquery-public-data`.ghcn_d.ghcnd_2016 AS wx
        WHERE  wx.id = 'USW00094728')
    GROUP BY  date
    )
    SELECT
        ROUND(AVG(bk.num_trips)) AS num_trips
        ,  wx.rainy
    FROM bicycle_rentals AS bk JOIN rainy_days AS wx ON wx.date = bk.trip_date
    GROUP BY wx.rainy

-- [
--   {
--     "num_trips": "39107.0",
--     "rainy": false
--   },
--   {
--     "num_trips": "32052.0",
--     "rainy": true
--   }
-- ]

WITH bicycle_rentals AS (
  SELECT
    COUNT(starttime) as num_trips,
    EXTRACT(DATE from starttime) as trip_date
  FROM `bigquery-public-data`.new_york_citibike.citibike_trips
  GROUP BY trip_date
)
SELECT * from bicycle_rentals LIMIT 5

-- [
--   {
--     "num_trips": "30622",
--     "trip_date": "2015-11-01"
--   },
--   {
--     "num_trips": "34217",
--     "trip_date": "2016-09-19"
--   },
--   {
--     "num_trips": "27977",
--     "trip_date": "2014-08-13"
--   },
--   {
--     "num_trips": "53288",
--     "trip_date": "2016-08-29"
--   },
--   {
--     "num_trips": "67455",
--     "trip_date": "2018-05-10"
--   }
-- ]


-- INNER JOIN

with from_item_a as (
    select 'Portland' as city, 'OR' as state
    union all
    select 'Paris', 'Ile-de-France'
    union all
    select 'Madrid', 'Madridas'
),

from_item_b as (
     select 'OR' as state, 'USA' as country
     union all
     select 'Ile-de-France', 'France'
     union all
     select 'Madridas', 'Spain'
)

select from_item_a.*, country
from from_item_a
         join from_item_b on from_item_a.state = from_item_b.state
;


-- [
--   {
--     "city": "Portland",
--     "state": "OR",
--     "country": "USA"
--   },
--   {
--     "city": "Paris",
--     "state": "Ile-de-France",
--     "country": "France"
--   },
--   {
--     "city": "Madrid",
--     "state": "Madridas",
--     "country": "Spain"
--   }
-- ]


-- An interesting join type

select from_item_a.*, country
from from_item_a
         join from_item_b on from_item_a.state != from_item_b.state
;

-- city	    state	        country
-- Portland	OR	            France
-- Portland	OR	            Spain
-- Paris	Ile-de-France	USA
-- Paris	Ile-de-France	Spain
-- Madrid	Madridas	    USA
-- Madrid	Madridas	    France


-- Basic Join

with winners as (
    select 'John' as person, '100m' as event
    union all select 'Luc', '200m'
    union all select 'Joe', '400m'
),
gifts as (
    select 'Iphone' as gift, '100m' as event
    union all select 'Samsung', '200m'
    union all select 'Huawei', '400m'
)
select winners.*, gifts.gift
from winners join gifts on gifts.event = winners.event

-- person	event	gift
-- John	    100m	Iphone
-- Luc	    200m	Samsung
-- Joe	    400m	Huawei


-- Cross Join (on cluse can not be used) => Comma cross join

with winners as (
    select 'John' as person, '100m' as event
    union all select 'Luc', '200m'
    union all select 'Joe', '400m'
),
gifts as (
    select 'Iphone' as gift, '100m' as event
    union all select 'Samsung', '200m'
    union all select 'Huawei', '400m'
)
select winners.*, gifts.gift
from winners cross join gifts
;

-- Can be also written as:

select winners.*, gifts.gift
from winners, gifts
;

-- person	event	gift
-- John	    100m	Iphone
-- John	    100m	Samsung
-- John	    100m	Huawei
-- Luc	    200m	Iphone
-- Luc	    200m	Samsung
-- Luc	    200m	Huawei
-- Joe	    400m	Iphone
-- Joe	    400m	Samsung
-- Joe	    400m	Huawei


