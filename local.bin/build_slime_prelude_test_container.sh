#!/usr/bin/env bash
set -euo pipefail
## run this using 'sudo -E ./thisscript
if (( $EUID != 0 )); then
    echo "Please run as root"
    echo "sudo -E ./run-slime-prelude-sqlite.sh"
    exit
fi
CONTAINER_NAME="prelude-sqlite"
REGISTRY_URL="us.icr.io/netdev-config-mgmt/slime/prelude-sqlite"


docker login --username iamapikey --password-stdin us.icr.io/netdev-config-mgmt < "${HOME}/.ssh/myibm_apikey"
docker remove -f $CONTAINER_NAME
docker pull $REGISTRY_URL 

docker run -dit --name=$CONTAINER_NAME --hostname=$CONTAINER_NAME \
  --env VAULT_TOKEN=$VAULT_TOKEN \
  -e INVENTORY=lab \
  -e ENVIRONMENT=CI \
  -e SSOT_ENV=production \
  -v /mnt/inventory:/mnt/inventory \
  -v /home/slime/cse_testing/data:/mnt/data \
  $REGISTRY_URL \
  "cd /opt/prelude && source /opt/prelude/dcn30/tekton/setup_only.sh && bash"

docker exec $CONTAINER_NAME bash -c "cd /opt/prelude && git merge -m CI origin/master && source /opt/prelude/dcn30/tekton/setup_only.sh"

docker exec -it $CONTAINER_NAME bash




