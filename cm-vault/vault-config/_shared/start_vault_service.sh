#!/usr/bin/env bash

set -euo pipefail

NODE_PORT=30200
CONTAINER_PORT=8200
SERVICE="service/vault"
NAMESPACE="vault"

echo "Executing 'kubectl port-forward' to establish the connection to Vault installed in Kubernetes"

echo -en "kubectl port-forward $SERVICE $NODE_PORT:$CONTAINER_PORT -n $NAMESPACE\n disown" > run_service.sh && chmod +x run_service.sh
nohup bash run_service.sh </dev/null >/dev/null 2>&1 &

# sleep was to give it a chance to finish establishing the connection before terragrunt/terraform starts running
echo "Sleeping for 10s while waiting for connection to be established"
sleep 10s
