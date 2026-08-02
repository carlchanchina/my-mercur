#!/bin/bash
set -x
CLI=/app/node_modules/.bun/@medusajs+cli@2.17.2+178e511e62867ab4/node_modules/@medusajs/cli/cli.js
# kill prior hung migration
docker exec 7f3971c4c377 sh -c 'pkill -f "cli.js db:migrate" 2>/dev/null; sleep 1; rm -f /tmp/mig4.log; echo killed'
# launch fresh
docker exec -d 7f3971c4c377 sh -c "cd /app/packages/api && DEBUG=mikro-orm:* MEDUSA_WORKER_MODE=server timeout 150 node $CLI db:migrate --concurrency 1 > /tmp/mig4.log 2>&1"
echo "launched"
sleep 30
echo "=== LOG at 30s ==="
docker exec 7f3971c4c377 sh -c 'tail -70 /tmp/mig4.log'
