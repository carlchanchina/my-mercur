#!/bin/bash
# Launch migration with debug, return immediately
set -x
CLI=/app/node_modules/.bun/@medusajs+cli@2.17.2+178e511e62867ab4/node_modules/@medusajs/cli/cli.js
docker exec 7f3971c4c377 sh -c "rm -f /tmp/mig3.log"
# First try: does cli.js db:migrate accept these cwd/env? Run via direct node
docker exec -d 7f3971c4c377 sh -c "cd /app/packages/api && DEBUG=mikro-orm:* MEDUSA_WORKER_MODE=server timeout 120 node $CLI db:migrate --concurrency 1 > /tmp/mig3.log 2>&1"
echo "launched pid present:"
docker exec 7f3971c4c377 sh -c "ps aux | grep -c '[d]b:migrate'"
