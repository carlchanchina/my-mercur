#!/bin/bash
echo "=== runMigrations def ==="
docker exec 7f3971c4c377 sh -c 'grep -n "const runMigrations\|runMigrations\b\|async function runMigrations\|migrationsToExecute\|runModulesMigrations" /app/node_modules/.bun/@medusajs+modules-sdk@2.17.2+e003b90efe82948e/node_modules/@medusajs/modules-sdk/dist/medusa-app.js | head -30'
