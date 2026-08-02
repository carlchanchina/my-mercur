#!/bin/bash
set -x
echo "=== kill all db:migrate processes in container ==="
docker exec 7f3971c4c377 sh -c 'pkill -9 -f "db:migrate"; sleep 2; ps aux | grep "[d]b:migrate" | wc -l'
echo "=== PG connections after kill ==="
docker exec 3742c16834f0 psql -U carl -d mercur_db -tAc "SELECT count(*) FROM pg_stat_activity WHERE datname='mercur_db' AND state IN ('idle','active','idle in transaction') AND backend_type='client backend'"
