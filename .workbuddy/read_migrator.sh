#!/bin/bash
FR=/app/node_modules/.bun/@medusajs+framework@2.17.2+e4a5600c9426e0c0/node_modules/@medusajs/framework
echo "=== migrator.js ==="
docker exec 7f3971c4c377 sh -c "cat $FR/dist/migrations/migrator.js"
