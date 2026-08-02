#!/bin/bash
echo "=== search loadModuleMigrations across medusa+framework ==="
docker exec 7f3971c4c377 sh -c 'grep -rln "loadModuleMigrations" /app/node_modules/.bun/@medusajs+medusa@2.17.2*/ /app/node_modules/.bun/@medusajs+framework@2.17.2*/ 2>/dev/null | head'
