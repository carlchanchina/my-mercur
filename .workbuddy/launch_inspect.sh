#!/bin/bash
set -x
CLI=/app/node_modules/.bun/@medusajs+cli@2.17.2+178e511e62867ab4/node_modules/@medusajs/cli/cli.js
# ensure clean
docker exec 7f3971c4c377 sh -c 'pkill -9 -f "db:migrate" 2>/dev/null; rm -f /tmp/mig5.log; sleep 1'
# launch with inspector
docker exec -d 7f3971c4c377 sh -c "cd /app/packages/api && NODE_OPTIONS='--inspect=0.0.0.0:9229' MEDUSA_WORKER_MODE=server timeout 200 node $CLI db:migrate --concurrency 1 > /tmp/mig5.log 2>&1"
echo "launched inspector migration"
sleep 8
echo "=== mig5 log ==="
docker exec 7f3971c4c377 sh -c 'cat /tmp/mig5.log'
