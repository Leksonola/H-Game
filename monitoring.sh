#!/bin/bash

echo "=== H-Game Production Health Dashboard ==="
echo "Generated: $(date)"
echo

echo "=== Container Status ==="
docker-compose ps

echo
echo "=== Resource Usage ==="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo
echo "=== Health Checks ==="
for service in frontend backend redis postgres; do
    health=$(docker inspect --format='{{.State.Health.Status}}' $service 2>/dev/null || echo "no-healthcheck")
    echo "$service: $health"
done

echo
echo "=== Application Status ==="
echo -n "Frontend: "
curl -s -o /dev/null -w "%{http_code}" http://localhost/ || echo "ERROR"

echo -n "API Health: "
curl -s -o /dev/null -w "%{http_code}" http://localhost/api/health || echo "ERROR"

echo -n "Backend Health: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/health || echo "ERROR"

echo
echo "=== Recent Logs (Last 5 lines per service) ==="
for service in frontend backend redis postgres; do
    echo "--- $service ---"
    docker-compose logs --tail 5 $service 2>/dev/null | tail -5
    echo
done
