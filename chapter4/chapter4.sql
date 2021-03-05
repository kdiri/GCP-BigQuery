-- GIS
select
    state_name
from `bigquery-public-data`.utility_us.us_states_area
where
    ST_Contains(
        state_geom,
        ST_GeogPoint(-122.33, 47.61)
    )

-- state_name
-- Washington

