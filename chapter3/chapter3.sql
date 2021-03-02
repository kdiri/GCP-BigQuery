-- Numeric types and functions
with example as (
    select 'Sat' as day, 1451 as numrides, 1018 as oneways
    union all select 'Sun', 2376, 936
)
select *, (oneways / numrides ) as frac_oneway from example
;
-- day	        numrides	oneways	frac_oneway
-- Sat	1451	1018	    0.7015851137146796
-- Sun	2376	936	        0.3939393939393939

-- With Round

with example as (
    select 'Sat' as day, 1451 as numrides, 1018 as oneways
    union all select 'Sun', 2376, 936
)
select *, round(oneways / numrides, 2) as frac_oneway from example
;
-- day	        numrides	oneways	frac_oneway
-- Sat	1451	1018	    0.7
-- Sun	2376	936	        0.39


-- Safe division by zero
with example as (
    select 'Sat' as day, 1451 as numrides, 1018 as oneways
    union all select 'Sun', 2376, 936
    union all select 'Wed', 0, 0
)
select *, ROUND(IEEE_Divide(oneways, numrides), 2) as frac_oneway from example
;
-- day	numrides	oneways	frac_oneway
-- Sat	1451	    1018	0.7
-- Sun	2376	    936	    0.39
-- Wed	0	        0	    NaN

-- SAFE functions
-- We can make scalar function return 0 instead of raising an error.
select log(10, -3);
-- become
select safe.log(10, -3);


-- Safe division and filtering
with example as (
    select 'Sat' as day, 1451 as numrides, 1018 as oneways
    union all select 'Sun', 2376, 936
    union all select 'Tue', IEEE_Divide(-3, 0), 0
)
select * from example
where numrides < 2000
;
-- day	numrides	oneways
-- Sat	1451.0	    1018
-- Tue	-Infinity	0


-- When not to use numeric function
with example as (
    select 1.23 as payment
    union all select 7.89
    union all select 12.43
)
select
    sum(payment) as total_paid,
    avg(payment) as avg_paid
from example
;
-- total_paid	        avg_paid
-- 21.549999999999997	7.183333333333334


-- With use of NUMERIC
with example as (
    select numeric '1.23' as payment
    union all select numeric '7.89'
    union all select numeric '12.43'
)
select
    sum(payment) as total_paid,
    avg(payment) as avg_paid
from example
;

-- it is now more beautiful
-- total_paid	avg_paid
-- 21.55	    7.183333333

-- Casting and Coersion
-- In case of conversion of non digit str to int, it blocks
-- raising an error
with example as (
    select 'John' as employee, 'Paternity Leave' as worked_hour
    union all select 'Janaki', '35'
    union all select 'Joe', 'Vacation'
    union all select 'Foo', '40'
)
select
    sum(SAFE_CAST(worked_hour as INT64)) as total_worked_hour
from example
;

-- total_worked_hour
-- 75

-- Cast BOOL to INT to be able to count
with example as (
    select true as is_vowel, 'a' as letter, 1 as position,
    union all select false, 'b', 2
    union all select false, 'c', 3
    union all select false, 'd', 4
    union all select true, 'e', 5
)
select sum(cast (is_vowel as INT64)) as num_vowels
from example
;

-- num_vowels
-- 2

-- BUT IF approach is better that casting (performance)
-- Same results
with example as (
    select true as is_vowel, 'a' as letter, 1 as position,
    union all select false, 'b', 2
    union all select false, 'c', 3
    union all select false, 'd', 4
    union all select true, 'e', 5
)
select countif(is_vowel) as num_vowels
from example

-- Some STR functions
with example as (
    select * from unnest([
        'New York', 'Seattle', 'Madrid', 'Singapore'
    ]) as city
)
select
    city
    , length(city) as len
    , lower(city) as low
    , strpos(city, 'or') -- find the position of given str at right
from example

-- city	     len	low	        f0_
-- New York	 8	    new york	6
-- Seattle	 7	    seattle	    0
-- Madrid	 6	    madrid	    0
-- Singapore 9	    singapore	7

WITH email_addresses AS
  (SELECT
    "foo@example.com" AS email_address
  UNION ALL
  SELECT
    "foobar@example.com" AS email_address
  UNION ALL
  SELECT
    "foobarbaz@example.com" AS email_address
  UNION ALL
  SELECT
    "quxexample.com" AS email_address)

SELECT
  STRPOS(email_address, "@") AS example
FROM email_addresses;

-- example
-- 4
-- 7
-- 10
-- 0


-- Some cool things
with example as (
    select 'abc@email.com' as email, 'Minneapolis' as city
    union all select 'reno@abc.com', 'Chicago'
    union all select 'keke@keko.com', 'Medford'
)
select
    concat(
        substr(email, 1, STRPOS(email, '@') -1 ), -- username
        ' from ', city
    ) as callers
from example

-- callers
-- abc from Minneapolis
-- reno from Chicago
-- keke from Medford


-- A timestamp represents an absolute point in time regardless of location.
-- Thus a timestamp of 2021-03-02 07:30:00.45 (Mar 02, 2021, at 07:30 UTC)
-- represents the same time as 2021-03-02 08:30:00.45+1:00 (8:30 a.m. at a time zone that is an hour behind):

select t1, t2, timestamp_diff(t1, t2, microsecond)
from (
    select
    timestamp "2021-03-02 07:30:00.45" as t1,
    timestamp "2021-03-02 08:30:00.45+1" as t2
)

-- t1	                        t2	                         f0_
-- 2021-03-02 07:30:00.450 UTC	2021-03-02 07:30:00.450 UTC	 0


