#!/bin/bash
echo "=== TCP connect test to valkey & postgres ==="
docker exec 7f3971c4c377 node -e '
const net=require("net");
function t(host,port,label){return new Promise(res=>{const s=net.connect(port,host);s.setTimeout(5000);s.on("connect",()=>{console.log(label,"CONNECTED");s.destroy();res()});s.on("timeout",()=>{console.log(label,"TIMEOUT");s.destroy();res()});s.on("error",e=>{console.log(label,"ERR",e.message);res()})})}
(async()=>{await t("infradb-shared-fi5pyt_valkey",6379,"VALKEY");await t("infradb-shared-fi5pyt_postgres",5432,"PG");process.exit(0)})()
'
