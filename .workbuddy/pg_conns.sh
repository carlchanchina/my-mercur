#!/bin/bash
docker exec 3742c16834f0 psql -U carl -d mercur_db -tAc "SELECT pid, state, wait_event_type, wait_event, left(query,80), backend_start FROM pg_stat_activity WHERE datname='mercur_db' AND backend_type='client backend'"
