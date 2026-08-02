#!/bin/sh
set -e

echo "[start] Running migrations..."
/app/node_modules/.bin/medusa db:migrate

echo "[start] Starting server..."
/app/node_modules/.bin/medusa start
