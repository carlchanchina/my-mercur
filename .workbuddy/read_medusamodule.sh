#!/bin/bash
M=/app/node_modules/.bun/@medusajs+modules-sdk@2.17.2+e003b90efe82948e/node_modules/@medusajs/modules-sdk/dist/medusa-module.js
docker exec 7f3971c4c377 sh -c "sed -n '440,540p' $M"
