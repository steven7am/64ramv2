#!/usr/bin/env bash
set -euo pipefail

CTX="${DS4_64GB_CTX:-4096}"
KV_DIR="${DS4_64GB_KV_DIR:-/tmp/ds4-kv}"
KV_MB="${DS4_64GB_KV_MB:-32768}"
MODEL="${DS4_64GB_MODEL:-ds4flash.gguf}"
HOST="${DS4_64GB_HOST:-127.0.0.1}"
PORT="${DS4_64GB_PORT:-8000}"

if [ ! -x ./ds4-server ]; then
  echo "error: ./ds4-server not found. Run: bash scripts/build_64gb.sh" >&2
  exit 1
fi

if [ ! -e "$MODEL" ]; then
  echo "error: model not found: $MODEL" >&2
  echo "Run: bash scripts/setup_64gb_model.sh" >&2
  exit 1
fi

mkdir -p "$KV_DIR"

echo "== Starting DS4 64GB server =="
echo "Context: $CTX"
echo "KV dir:  $KV_DIR"
echo "KV MB:   $KV_MB"
echo "Model:   $MODEL"
echo "Bind:    $HOST:$PORT"
echo

exec ./ds4-server \
  -m "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --ctx "$CTX" \
  --kv-disk-dir "$KV_DIR" \
  --kv-disk-space-mb "$KV_MB"
