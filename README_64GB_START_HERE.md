# 64GB RAM Start Here

This fork tracks `antirez/ds4` and adds a practical 64GB-RAM test path plus design notes for the real low-memory MoE expert-cache runtime.

## Important status

This repo is **testable today**, but true 64GB support is still experimental.

The current upstream DS4 q2 model is around the 96GB/128GB machine class. A 64GB laptop may still run out of memory unless the OS, GPU backend, and memory mapping behavior cooperate. The scripts here use the smallest practical settings first:

- q2-imatrix model
- small context, default `4096`
- non-thinking mode by default
- disk KV cache enabled
- no MTP/speculative model by default

The real long-term 64GB solution is a MoE-aware routed expert cache. See [`docs/64gb-lowmem-expert-cache.md`](docs/64gb-lowmem-expert-cache.md).

## Quick test

```sh
git clone https://github.com/steven7am/64ramv2.git
cd 64ramv2

bash scripts/check_64gb_env.sh
bash scripts/setup_64gb_model.sh
bash scripts/build_64gb.sh
bash scripts/run_64gb_prompt.sh "Say hello in one sentence."
```

## Start local server

```sh
bash scripts/run_64gb_server.sh
```

Default server command uses:

```sh
./ds4-server \
  --ctx 4096 \
  --kv-disk-dir /tmp/ds4-kv \
  --kv-disk-space-mb 32768
```

Then test it:

```sh
curl http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"deepseek-v4-flash",
    "messages":[{"role":"user","content":"List three Redis design principles."}],
    "max_tokens":128,
    "stream":false
  }'
```

## Tune the 64GB run

You can override defaults:

```sh
DS4_64GB_CTX=2048 bash scripts/run_64gb_prompt.sh "hello"
DS4_64GB_CTX=8192 DS4_64GB_KV_MB=65536 bash scripts/run_64gb_server.sh
```

Useful variables:

| Variable | Default | Meaning |
| --- | ---: | --- |
| `DS4_64GB_CTX` | `4096` | Context size. Use `2048` if memory is tight. |
| `DS4_64GB_KV_DIR` | `/tmp/ds4-kv` | Disk KV cache directory. |
| `DS4_64GB_KV_MB` | `32768` | Disk KV cache budget. |
| `DS4_64GB_MODEL_KIND` | `q2-imatrix` | Model download kind. |
| `DS4_64GB_BUILD` | auto | `metal`, `cuda-generic`, `cuda-spark`, or `cpu`. |
| `DS4_64GB_TOKENS` | `256` | Prompt test max generated tokens. |

## If it crashes or gets killed

Try:

```sh
DS4_64GB_CTX=2048 bash scripts/run_64gb_prompt.sh "hello"
```

Also close memory-heavy apps and make sure your disk has enough free space. The model download itself is large, and the disk KV cache can use tens of GB.

## What is still needed

The current scripts make DS4 easier to test on a 64GB machine. They do **not** yet implement the full routed-expert cache. The planned implementation is:

1. keep dense/shared weights resident;
2. keep routed expert tensors compressed;
3. load/cache only selected experts by `(layer, expert, tensor_kind)`;
4. async prefetch next likely experts;
5. evict cold experts with an LRU/score policy.

That is the path expected to make 64GB machines genuinely usable without destroying model quality.
