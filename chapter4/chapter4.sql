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


-- ALTER TABLE SET OPTIONS statement
-- To set the options on a table in BigQuery, use the ALTER TABLE SET OPTIONS DDL statement.

-- ALTER TABLE [IF EXISTS] [[project_name.]dataset_name.]table_name
-- SET OPTIONS(table_set_options_list)

ALTER TABLE SET OPTIONSALTER TABLE ch04.college_scorecard
 SET OPTIONS (
   expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(),
                                       INTERVAL 7 DAY),
   description="College Scorecard expires seven days from now"
 );


-- Get table names, column names, etc

SELECT
  table_name
  , column_name
  , ordinal_position
  , is_nullable
  , data_type
FROM
  bigquery-public-data.bitcoin_blockchain.INFORMATION_SCHEMA.COLUMNS

-- table_name	column_name	   ordinal_position	is_nullable	data_type
-- blocks	    block_id    	1	            YES	        STRING
-- blocks	    previous_block  2	            YES	        STRING
-- blocks	    merkle_root    	3	            YES	        STRING
-- blocks	    timestamp    	4	            YES	        INT64
-- blocks	    difficultyTarget 5	            YES	        INT64
-- blocks	    nonce    	    6	            YES	        INT64
-- blocks	    version    	    7	            YES	        INT64
-- blocks	    work_terahash   8	            YES	        INT64
-- blocks	    work_error    	9	            YES	        STRING



-- Write a function ans use it during the ETL phase
CREATE TEMP FUNCTION cleanup_numeric(x STRING) AS
(
  IF ( x != 'NULL' AND x != 'PrivacySuppressed',
       CAST(x as FLOAT64),
       NULL )
);

WITH etl_data AS (
   SELECT
     INSTNM
     , cleanup_numeric(ADM_RATE_ALL) AS ADM_RATE_ALL
     , cleanup_numeric(FIRST_GEN) AS FIRST_GEN
     , cleanup_numeric(MD_FAMINC) AS MD_FAMINC
     , cleanup_numeric(SAT_AVG) AS SAT_AVG
     , cleanup_numeric(MD_EARN_WNE_P10) AS MD_EARN_WNE_P10
   FROM
     `ch04.college_scorecard_gcs`
)

SELECT
  *
FROM
  etl_data
WHERE
  SAT_AVG  > 1300
  AND ADM_RATE_ALL < 0.2
  AND FIRST_GEN > 0.1
ORDER BY
  MD_FAMINC ASC
LIMIT 10
;


-- Create table & ETL
CREATE TABLE ch04.college_scorecard_etl
OPTIONS(description="Cleaned up college scorecard data") AS

WITH etl_data AS (
   SELECT
     INSTNM
     , cleanup_numeric(ADM_RATE_ALL) AS ADM_RATE_ALL
     , cleanup_numeric(FIRST_GEN) AS FIRST_GEN
     , cleanup_numeric(MD_FAMINC) AS MD_FAMINC
     , cleanup_numeric(SAT_AVG) AS SAT_AVG
     , cleanup_numeric(MD_EARN_WNE_P10) AS MD_EARN_WNE_P10
   FROM
     `ch04.college_scorecard_gcs`
)

SELECT * FROM etl_data
