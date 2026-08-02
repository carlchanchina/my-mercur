#!/bin/bash
echo "=== find loadModuleMigrations globally (limited scope) ==="
docker exec 7f3971c4c377 sh -c 'grep -rln "loadModuleMigrations" /app/node_modules/.bun/@medusajs+framework@2.17.2+e4a5600c9426e0c0/node_modules/@medusajs/framework/dist 2>/dev/null | head'
echo "=== also check the migrations helpers ==="
docker exec 7f3971c4c377 sh -c 'grep -rln "runModuleMigrations\|getModuleMigrationPlanner" /app/node_modules/.bun/@medusajs+framework@2.17.2+e4a5600c9426e0c0/node_modules/@medusajs/framework/dist 2>/dev/null | head'
