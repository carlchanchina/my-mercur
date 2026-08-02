#!/bin/bash
echo "=== mig process ==="
docker exec 7f3971c4c377 sh -c 'ps aux | grep "[d]b:migrate"'
echo "=== node pids and threads ==="
MIGPID=$(docker exec 7f3971c4c377 sh -c 'ps -eo pid,cmd | grep "[c]li.js db:migrate" | grep -v timeout | head -1' | awk '{print $1}')
echo "MIGPID=$MIGPID"
docker exec 7f3971c4c377 sh -c "ls /proc/$MIGPID/task | wc -l; echo ---; cat /proc/$MIGPID/stat 2>/dev/null | awk '{print \"utime=\"\$14,\"stime=\"\$15,\"nthreads=\"\$20,\"state=\"\$3}'"
echo "=== child processes of the mig (forked workers?) ==="
docker exec 7f3971c4c377 sh -c "for p in \$MIGPID \$(docker exec -d true >/dev/null 2>&1; echo); do cat /proc/$MIGPID/children 2>/dev/null; done"
