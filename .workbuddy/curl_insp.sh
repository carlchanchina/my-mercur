#!/bin/bash
echo "=== curl inspector from inside container ==="
docker exec 7f3971c4c377 sh -c 'curl -s http://127.0.0.1:9229/json/version 2>&1 | head; echo; wget -qO- http://127.0.0.1:9229/json/list 2>&1 | head -c 500; echo'
echo "=== host has curl to 9229 via tunnel? ==="
curl -s http://127.0.0.1:9229/json/version 2>&1 | head
