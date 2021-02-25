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


