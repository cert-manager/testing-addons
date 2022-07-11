#!/usr/bin/env bash

set -euo pipefail

SERVICE="service/vault"

kill -9 $(ps -aux |grep $SERVICE |grep -v grep | awk '{print $2}')

rm -f run_service.sh
