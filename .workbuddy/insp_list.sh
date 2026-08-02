#!/bin/bash
echo "=== inspector client list ==="
curl -s http://127.0.0.1:9229/json/list 2>/dev/null | head -40
