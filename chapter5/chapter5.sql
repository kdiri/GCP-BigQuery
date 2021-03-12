curl -H "Authorization: Bearer $access_token"  \
    -H "Content-Type: application/json" \
    -X POST \
    -d "$request" \
    "https://www.googleapis.com/bigquery/v2/projects/$PROJECT/queries"

-- if a task takes more time than the timeout
-- it sends the jobId that can ben used to verify
-- if a job is ended
Q: fv{
 "useLegacySql": false,
 "timeoutMs": 0,
 "useQueryCache": false,
 "query": \"${QUERY_TEXT}\"
}
A: {
 "kind": "bigquery#queryResponse",
 "jobReference": {
  "projectId": "cloud-training-demos",
  "jobId": "job_gv0Kq8nWzXIkuBwoxsKMcTJIVbX4",
  "location": "EU"
 },
 "jobComplete": false
}

-- Send new query to verify the jobId
.../projects/<PROJECT>/jobs/<JOBID>

