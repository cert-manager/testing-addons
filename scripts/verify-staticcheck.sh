#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
cd "${REPO_ROOT}"

# Check terraform codes format
if ! terraform fmt -recursive -diff -check; then
  echo
  echo 'Please run "terraform fmt -recursive" to format the codes.'
  exit 1
fi

# Check terragrunt codes format
if ! terragrunt hclfmt --terragrunt-check; then
  echo
  echo 'Please run "terragrunt hclfmt" to format the codes.'
  exit 1
fi

# Check whether the configuration is valid 
terragrunt run-all init

if terragrunt run-all validate; then
  echo 'Congratulations! All Terraform source files have passed staticcheck.'
else
  echo
  echo 'Please review the above warnings.'
  echo 'If the above warnings do not make sense, feel free to file an issue.'
  exit 1
fi
