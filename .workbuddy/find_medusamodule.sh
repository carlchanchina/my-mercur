#!/bin/bash
M=/app/node_modules/.bun/@medusajs+modules-sdk@2.17.2+e003b90efe82948e/node_modules/@medusajs/modules-sdk/dist/medusa-module.js
echo "=== migrateUp/migrateDown location ==="
docker exec 7f3971c4c377 sh -c "grep -n 'migrateUp\|migrateDown\|loadModuleMigrations\|runMigrations\|async function\|const migrateUp' $M | head -40"
