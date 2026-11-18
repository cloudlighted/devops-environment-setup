#!/usr/bin/env bash
# collect-evidence.sh
# Builds the Tooling Verification Report and Local Cluster Proof
# for the DevOps environment-setup mini-project.
# Author: Ifeanyi Mathew Duru

OUT_DIR="$HOME/devops-submission"
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/tooling-verification-report.txt"
CLUSTER="$OUT_DIR/local-cluster-proof.txt"

run() {
  echo "\$ $*"
  if command -v "$1" >/dev/null 2>&1; then
    "$@" 2>&1
  else
    echo "NOT INSTALLED: $1"
  fi
  echo
}

{
  echo "=============================================="
  echo " TOOLING VERIFICATION REPORT"
  echo " User: $(whoami)   Host: $(hostname)"
  echo " Date: $(date)"
  echo "=============================================="
  echo
  echo "---- System ----"
  run lsb_release -a
  run uname -srm
  echo "CPUs: $(nproc)"
  echo
  free -h
  echo
  df -h "$HOME"
  echo

  echo "---- Version control ----"
  run git --version
  echo "Git user : $(git config --global user.name 2>/dev/null || echo '(not set)')"
  echo "Git email: $(git config --global user.email 2>/dev/null || echo '(not set)')"
  echo

  echo "---- Containers & Kubernetes ----"
  run docker --version
  run kubectl version
  run k3s --version
  run helm version
  run minikube version

  echo "---- Cloud CLIs ----"
  run aws --version
  run az version

  echo "---- Runtime & utilities ----"
  run node -v
  run npm -v
  run jq --version

  echo "---- Infrastructure as Code & configuration management ----"
  run terraform version
  run ansible --version
} | tee "$REPORT"

{
  echo "=============================================="
  echo " LOCAL CLUSTER PROOF"
  echo " Distribution: K3s (air-gapped install)"
  echo " Date: $(date)"
  echo "=============================================="
  echo
  echo "\$ docker run --rm hello-world"
  docker run --rm hello-world 2>&1
  echo
  echo "\$ systemctl is-active k3s"
  systemctl is-active k3s 2>&1
  echo
  run kubectl get nodes -o wide
  run kubectl get pods -A
  run kubectl cluster-info
  run helm list -A
} | tee "$CLUSTER"

echo
echo "Saved:"
echo "  $REPORT"
echo "  $CLUSTER"
