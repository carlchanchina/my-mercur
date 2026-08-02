#!/bin/bash
PG=3742c16834f0
echo "=== active connections ==="
docker exec $PG psql -U carl -d mercur_db -tAc "SELECT pid, state, wait_event_type, wait_event, left(query,90) FROM pg_stat_activity WHERE datname='mercur_db' AND pid<>pg_backend_pid()" 
echo "=== advisory locks ==="
docker exec $PG psql -U carl -d mercur_db -tAc "SELECT pid, classid, objid, mode, granted FROM pg_locks WHERE locktype='advisory'"
echo "=== migration tables ==="
docker exec $PG psql -U carl -d mercur_db -tAc "SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename LIMIT 30"
echo "=== mikro_orm_migrations rowcount ==="
docker exec $PG psql -U carl -d mercur_db -tAc "SELECT count(*) FROM mikro_orm_migrations" 2>&1
