#!/bin/bash
echo "=== 9229 listening in container? ==="
docker exec 7f3971c4c377 sh -c 'ss -tlnp 2>/dev/null | grep 9229 || netstat -tlnp 2>/dev/null | grep 9229 || echo "not found"; echo ---; pgrep -f "inspect" '
echo "=== host ssh listening ==="
ss -tlnp 2>/dev/null | grep 9229 || netstat -an 2>/dev/null | grep 9229
