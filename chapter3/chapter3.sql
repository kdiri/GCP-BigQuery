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


-- Some string operations
SELECT
  ENDS_WITH('Hello', 'o') -- true
  , ENDS_WITH('Hello', 'h') -- false
  , STARTS_WITH('Hello', 'h') -- false
  , STRPOS('Hello', 'e') -- 2
  , STRPOS('Hello', 'f') -- 0 for not-found
  , SUBSTR('Hello', 2, 4) -- 1-based
  , CONCAT('Hello', 'World')
;

-- f0_	f1_	    f2_	    f3_	 f4_	f5_	    f6_
-- true	false	false	2	 0	    ello	HelloWorld


-- More str operations
SELECT
  LPAD('Hello', 10, '*') -- left pad with *
  , RPAD('Hello', 10, '*') -- right pad
  , LPAD('Hello', 10) -- left pad with spaces
  , LTRIM('   Hello   ') -- trim whitespace on left
  , RTRIM('   Hello   ') -- trim whitespace on right
  , TRIM ('   Hello   ') -- trim whitespace both ends
  , TRIM ('***Hello***', '*') -- trim * both ends
  , REVERSE('Hello') -- reverse the string ;
;

-- f0_	        f1_	             f2_	f3_	           f4_	    f5_	    f6_	    f7_
-- *****Hello	Hello*****	     Hello	Hello   	   Hello	Hello	Hello	olleH


-- REGEX
SELECT
  column
  , REGEXP_CONTAINS(column, r'\d{5}(?:[-\s]\d{4})?') has_zipcode
  , REGEXP_CONTAINS(column, r'^\d{5}(?:[-\s]\d{4})?$') is_zipcode
  , REGEXP_EXTRACT(column, r'\d{5}(?:[-\s]\d{4})?') the_zipcode
  , REGEXP_EXTRACT_ALL(column, r'\d{5}(?:[-\s]\d{4})?') all_zipcodes
  , REGEXP_REPLACE(column, r'\d{5}(?:[-\s]\d{4})?', '*****') masked
FROM (
  SELECT * from unnest([
     '12345', '1234', '12345-9876',
     'abc 12345 def', 'abcde-fghi',
     '12345 ab 34567', '12345 9876'
  ]) AS column
);


-- Parse Times
SELECT
  fmt, input, zone
  , PARSE_TIMESTAMP(fmt, input, zone) AS ts
FROM (
  SELECT '%Y%m%d-%H%M%S' AS fmt, '20210303-220800' AS input, '+0' as zone
  UNION ALL SELECT '%c', 'Wed Mar 03 21:26:00 2018', 'Europe/Paris'
  UNION ALL SELECT '%x %X', '04/03/21 22:08:00', 'CET'
)

-- fmt	            input	                     zone	        ts
-- %Y%m%d-%H%M%S	20210303-220800	             +0	            2021-03-03 22:08:00 UTC
-- %c	            Wed Mar 03 21:26:00 2018	 Europe/Paris	2018-03-03 20:26:00 UTC
-- %x %X	        04/03/21 22:08:00	         CET	        2021-04-03 20:08:00 UTC


-- Format timestamps
SELECT
  ts, fmt
  , FORMAT_TIMESTAMP(fmt, ts, '+1') AS ts_output -- +1 to get the results in CET
FROM (
  SELECT CURRENT_TIMESTAMP() AS ts, '%Y%m%d-%H%M%S' AS fmt
  UNION ALL SELECT CURRENT_TIMESTAMP() AS ts, '%c' AS fmt
  UNION ALL SELECT CURRENT_TIMESTAMP() AS ts, '%x %X' AS fmt
)

-- ts	                            fmt	            ts_output
-- 2021-03-03 08:29:50.261608 UTC	%Y%m%d-%H%M%S	20210303-092950
-- 2021-03-03 08:29:50.261608 UTC	%c	            Wed Mar  3 09:29:50 2021
-- 2021-03-03 08:29:50.261608 UTC	%x %X	        03/03/21 09:29:50


-- Extracting calendar parts
select
    ts
    , format_timestamp('%c', ts) as repr
    , extract(DAYOFWEEK from ts) as dayofweek
    , extract(YEAR from ts) as year
    , extract(WEEK from ts) as week
from (
    select parse_timestamp('%Y%m%d-%H%M%S', '20210303-093000') as ts
)
-- Sunday is the first day of the week by default
-- ts	                    repr	                    dayofweek	year	week
-- 2021-03-03 09:30:00 UTC	Wed Mar  3 09:30:00 2021	4	        2021	9
