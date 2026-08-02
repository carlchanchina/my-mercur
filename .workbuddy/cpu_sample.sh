#!/bin/bash
PID=$(docker exec 7f3971c4c377 sh -c 'pgrep -f "cli.js db:migrate" | head -1')
echo "PID=$PID"
# sample CPU: read utime+stime twice with delay
docker exec 7f3971c4c377 sh -c "cat /proc/$PID/stat" | awk '{print "t0 utime="$14" stime="$15}'
sleep 8
docker exec 7f3971c4c377 sh -c "cat /proc/$PID/stat" | awk '{print "t8 utime="$14" stime="$15}'
echo "=== thread wchan/state ==="
docker exec 7f3971c4c377 sh -c "ps -L -p $PID -o pid,tid,stat,pcpu,wchan:20 2>/dev/null | head -20"
