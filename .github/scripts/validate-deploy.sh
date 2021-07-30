#!/usr/bin/env bash

export KUBECONFIG=$(cat ./kubeconfig)

kubectl get daemonset -n ibm-observe

echo "Checking for sysdig-agent daemonset"
if ! kubectl get daemonset sysdig-agent -n ibm-observe; then
  echo "sysdig-agent daemonset not found"
  exit 1
fi

echo "Checking logdna-agent pod status"
if ! kubectl rollout status daemonset/sysdig-agent -n ibm-observe; then
  echo "daemonset/sysdig-agent rollout status error"
  exit 1
fi
