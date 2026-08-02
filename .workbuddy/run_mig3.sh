#!/bin/bash
# Run migration with debug in the api container, capture to log, then show log after wait
set -x
docker exec 7f3971c4c377 sh -c 'rm -f /tmp/mig3.log'
# Start migration in background inside container using bunx medusa CLI
docker exec -d 7f3971c4c377 sh -c 'cd /app/packages/api && DEBUG=mikro-orm:* timeout 100 node /app/node_modules/.bun/@medusajs+cli@2.17.2+178e511e62867ab4/node_modules/@medusajs/cli/cli.js db:migrate --concurrency 1 > /tmp/mig3.log 2>&1'
echo "launched"
sleep 20
echo "=== LOG at 20s ==="
docker exec 7f3971c4c377 sh -c 'tail -60 /tmp/mig3.log'
