#!/bin/bash
# Diagnostic: locate MedusaAppMigrateUp / runModulesMigrations source
set -x
docker exec 7f3971c4c377 sh -c 'ls /app/node_modules/.bun/ | grep -i "modules-sdk"'
echo "=== grep runModulesMigrations in modules-sdk ==="
docker exec 7f3971c4c377 sh -c 'grep -rln "runModulesMigrations" /app/node_modules/.bun/@medusajs+modules-sdk* 2>/dev/null | head'
echo "=== grep MedusaAppMigrateUp ==="
docker exec 7f3971c4c377 sh -c 'grep -rln "MedusaAppMigrateUp" /app/node_modules/.bun/@medusajs+modules-sdk* 2>/dev/null | head'
echo "DONE"
