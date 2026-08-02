#!/bin/bash
echo "=== redis hostname resolves? ==="
docker exec 7f3971c4c377 sh -c 'getent hosts infradb-shared-fi5pyt_valkey 2>&1; echo ---; getent hosts infradb-shared-fi5pyt_postgres 2>&1'
echo "=== test redis connectivity via node ==="
docker exec 7f3971c4c377 sh -c 'node -e "const i=require(\"ioredis\");const r=new ioredis({host:\"infradb-shared-fi5pyt_valkey\",port:6379});r.on(\"ready\",()=>{console.log(\"REDIS_READY\");r.ping().then(console.log).then(()=>r.quit())});r.on(\"error\",e=>console.log(\"REDIS_ERR\",e.message))" 2>&1'
