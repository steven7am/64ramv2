#!/usr/bin/env bash
set -euo pipefail

PROMPT="${1:-Say hello in one sentence.}"
CTX="${DS4_64GB_CTX:-4096}"
TOKENS="${DS4_64GB_TOKENS:-256}"
MODEL="${DS4_64GB_MODEL:-ds4flash.gguf}"

if [ ! -x ./ds4 ]; then
  echo "error: ./ds4 not found. Run: bash scripts/build_64gb.sh" >&2
  exit 1
fi

if [ ! -e "$MODEL" ]; then
  echo "error: model not found: $MODEL" >&2
  echo "Run: bash scripts/setup_64gb_model.sh" >&2
  exit 1
fi

echo "== Running DS4 64GB prompt test =="
echo "Context: $CTX"
echo "Tokens:  $TOKENS"
echo "Model:   $MODEL"
echo

./ds4 \
  -m "$MODEL" \
  --ctx "$CTX" \
  --nothink \
  -n "$TOKENS" \
  -p "$PROMPT"
