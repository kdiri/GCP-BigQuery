-- Numeric types and functions
with example as (
    select 'Sat' as day, 1451 as numrides, 1018 as oneways
    union all select 'Sun', 2376, 936
)
select *, (oneways / numrides ) as frac_oneway from example

-- day	        numrides	oneways	frac_oneway
-- Sat	1451	1018	    0.7015851137146796
-- Sun	2376	936	        0.3939393939393939

-- With Round

with example as (
    select 'Sat' as day, 1451 as numrides, 1018 as oneways
    union all select 'Sun', 2376, 936
)
select *, round(oneways / numrides, 2) as frac_oneway from example

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

-- day	numrides	oneways	frac_oneway
-- Sat	1451	    1018	0.7
-- Sun	2376	    936	    0.39
-- Wed	0	        0	    NaN

-- SAFE functions
-- We can make scalar function return 0 instead of raising an error.
select log(10, -3)
-- become
select safe.log(10, -3)


-- Safe division and filtering
with example as (
    select 'Sat' as day, 1451 as numrides, 1018 as oneways
    union all select 'Sun', 2376, 936
    union all select 'Tue', IEEE_Divide(-3, 0), 0
)
select * from example
where numrides < 2000

-- day	numrides	oneways
-- Sat	1451.0	    1018
-- Tue	-Infinity	0
