#!/usr/bin/env bash

REGION="$1"
RESOURCE_GROUP="$2"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ -z "${APIKEY}" ]]; then
  echo "The APIKEY is required"
  exit 1
fi

ibmcloud config --check-version=false

ibmcloud login -r "${REGION}" -g "${RESOURCE_GROUP}" --apikey "${APIKEY}"