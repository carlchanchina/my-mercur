#!/bin/bash
docker exec 7f3971c4c377 sh -c 'sed -n "350,410p" /app/node_modules/.bun/@medusajs+modules-sdk@2.17.2+e003b90efe82948e/node_modules/@medusajs/modules-sdk/dist/medusa-app.js'
