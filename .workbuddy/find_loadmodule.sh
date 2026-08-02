#!/bin/bash
U=/app/node_modules/.bun/@medusajs+modules-sdk@2.17.2+e003b90efe82948e/node_modules/@medusajs/modules-sdk/dist/utils
echo "=== utils files ==="
docker exec 7f3971c4c377 sh -c "ls $U"
echo "=== grep loadModuleMigrations ==="
docker exec 7f3971c4c377 sh -c "grep -rln 'loadModuleMigrations' $U | head"
