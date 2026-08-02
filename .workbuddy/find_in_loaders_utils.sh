#!/bin/bash
U=/app/node_modules/.bun/@medusajs+modules-sdk@2.17.2+e003b90efe82948e/node_modules/@medusajs/modules-sdk/dist/loaders/utils.js
docker exec 7f3971c4c377 sh -c "grep -n 'loadModuleMigrations\|async function\|runMigration\|getModuleMigrations' $U | head -30"
