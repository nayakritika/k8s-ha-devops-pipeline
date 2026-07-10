#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="default"

LOADGEN_DEPLOY="loadgenerator"

FRONTEND_ADDR="10.13.37.100:80"

USER_COUNTS=(500 1000 1500 2000 2500 3000)

RUN_DURATION=200

RESULTS_DIR="task6_results"
mkdir -p "${RESULTS_DIR}"

for users in "${USER_COUNTS[@]}"; do
  echo "Setting loadgenerator USERS=${users}, FRONTEND_ADDR=${FRONTEND_ADDR} and restarting..."
  kubectl set env deployment/"${LOADGEN_DEPLOY}" \
    -n "${NAMESPACE}" \
    USERS="${users}" \
    FRONTEND_ADDR="${FRONTEND_ADDR}" \
    RATE="100" --overwrite

  kubectl rollout restart deployment/"${LOADGEN_DEPLOY}" -n "${NAMESPACE}"
  kubectl rollout status deployment/"${LOADGEN_DEPLOY}" -n "${NAMESPACE}"

  timestamp="$(date +%Y%m%d-%H%M%S)"
  logfile="${RESULTS_DIR}/allservices_users_${users}_${timestamp}.log"

  # Get the current loadgenerator pod name
  LOADGEN_POD="$(
    kubectl get pod -n "${NAMESPACE}" -l app="${LOADGEN_DEPLOY}" \
      -o jsonpath='{.items[0].metadata.name}'
  )"

  echo "Using loadgenerator pod: ${LOADGEN_POD}"

  # Start following logs in the background
  kubectl logs -n "${NAMESPACE}" "${LOADGEN_POD}" -f > "${logfile}" 2>&1 &
  LOG_PID=$!

  sleep "${RUN_DURATION}"

  # Stop log collection
  if kill -0 "${LOG_PID}" 2>/dev/null; then
    kill "${LOG_PID}" || true
  fi

  echo "Log collection done for users=${users}"
  echo "Saved to: ${logfile}"
  echo
done


echo "======================================================"
echo "All runs complete."
