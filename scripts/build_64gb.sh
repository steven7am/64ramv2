#!/usr/bin/env bash
set -euo pipefail

BUILD="${DS4_64GB_BUILD:-auto}"

if [ "$BUILD" = "auto" ]; then
  if [ "$(uname -s)" = "Darwin" ]; then
    BUILD="metal"
  elif command -v nvidia-smi >/dev/null 2>&1; then
    BUILD="cuda-generic"
  else
    BUILD="cpu"
  fi
fi

echo "== Building DS4 for 64GB test =="
echo "Build target: ${BUILD}"
echo

case "$BUILD" in
  metal)
    make
    ;;
  cuda-generic)
    make cuda-generic
    ;;
  cuda-spark)
    make cuda-spark
    ;;
  cpu)
    echo "warning: CPU build is for diagnostics and may be extremely slow."
    make cpu
    ;;
  *)
    echo "error: unknown DS4_64GB_BUILD target: $BUILD" >&2
    echo "valid: auto, metal, cuda-generic, cuda-spark, cpu" >&2
    exit 1
    ;;
esac

echo
echo "Build complete."
