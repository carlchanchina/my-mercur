#!/bin/bash
set -x
CFG=/app/packages/api/medusa-config.ts
# Insert redisUrl after databaseUrl line in source config
docker exec 7f3971c4c377 sh -c "grep -n 'databaseUrl:' $CFG"
docker exec 7f3971c4c377 sh -c "sed -i \"s/    databaseUrl: process.env.DATABASE_URL,/    databaseUrl: process.env.DATABASE_URL,\\n    redisUrl: process.env.REDIS_URL,/\" $CFG"
echo "=== after ==="
docker exec 7f3971c4c377 sh -c "sed -n '18,24p' $CFG"
