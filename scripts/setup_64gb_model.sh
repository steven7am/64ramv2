#!/usr/bin/env bash
set -euo pipefail

MODEL_KIND="${DS4_64GB_MODEL_KIND:-q2-imatrix}"

echo "== Downloading DS4 model for 64GB test =="
echo "Model kind: ${MODEL_KIND}"
echo

if [ ! -x ./download_model.sh ]; then
  echo "error: ./download_model.sh not found or not executable. Run this from the repository root." >&2
  exit 1
fi

./download_model.sh "$MODEL_KIND"

echo
echo "Model setup complete. Default model symlink/file should be ./ds4flash.gguf"
