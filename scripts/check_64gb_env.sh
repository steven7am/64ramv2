#!/usr/bin/env bash
set -euo pipefail

echo "== 64GB DS4 environment check =="
echo

uname -a || true
echo

if command -v sw_vers >/dev/null 2>&1; then
  echo "macOS:"
  sw_vers || true
  echo
fi

if command -v sysctl >/dev/null 2>&1; then
  mem_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
  if [ "$mem_bytes" != "0" ]; then
    python3 - <<PY
mem=$mem_bytes
print(f"System RAM: {mem/1024**3:.1f} GiB")
PY
  fi
fi

if command -v free >/dev/null 2>&1; then
  free -h || true
fi

echo
if command -v df >/dev/null 2>&1; then
  echo "Disk space for current directory and /tmp:"
  df -h . /tmp 2>/dev/null || df -h . || true
fi

echo
if command -v nvidia-smi >/dev/null 2>&1; then
  echo "NVIDIA GPU:"
  nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader || true
else
  echo "nvidia-smi: not found"
fi

echo
if command -v xcrun >/dev/null 2>&1; then
  echo "Apple developer tools: found xcrun"
else
  echo "xcrun: not found"
fi

echo
if command -v make >/dev/null 2>&1; then
  echo "make: $(make --version | head -n 1)"
else
  echo "make: not found"
fi

if command -v cc >/dev/null 2>&1; then
  echo "cc: $(cc --version 2>/dev/null | head -n 1 || true)"
else
  echo "cc: not found"
fi

echo
cat <<'EOF'
Recommended first 64GB test:
  DS4_64GB_CTX=2048 bash scripts/run_64gb_prompt.sh "Say hello in one sentence."

If that works, try:
  DS4_64GB_CTX=4096 bash scripts/run_64gb_prompt.sh "Say hello in one sentence."
EOF
