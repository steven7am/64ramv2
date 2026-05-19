# DS4 64GB RAM Progress Track

This fork is intended to explore a 64GB-RAM execution path for `antirez/ds4` while preserving full DeepSeek V4 Flash functionality.

## Current status

The repo now has two layers:

1. **Usable test layer today** — scripts under `scripts/` make it easier to download q2-imatrix, build DS4, and run small-context prompt/server tests on a 64GB machine.
2. **Planned low-memory runtime layer** — the MoE routed-expert cache design in `docs/64gb-lowmem-expert-cache.md` is the path expected to make 64GB genuinely usable with less risk of OOM.

The current helper scripts do not yet implement routed expert caching. They make the smallest practical upstream DS4 configuration easier to test.

## Recommended first tests

```sh
bash scripts/check_64gb_env.sh
bash scripts/setup_64gb_model.sh
bash scripts/build_64gb.sh
DS4_64GB_CTX=2048 bash scripts/run_64gb_prompt.sh "Say hello in one sentence."
```

If that works:

```sh
DS4_64GB_CTX=4096 bash scripts/run_64gb_prompt.sh "Explain Redis streams in one paragraph."
```

## 64GB defaults

- Model: `q2-imatrix`
- Context: `4096`
- Generation test: `--nothink`
- Disk KV cache: enabled for server script
- MTP: disabled by default

## Why this is still hard

The upstream q2 model is designed for 96GB/128GB-class machines. Even with a small context, model memory can still exceed what a 64GB machine can comfortably provide.

The future optimization should exploit routed MoE sparsity:

1. Keep dense/shared model parts resident.
2. Keep routed expert tensors compressed.
3. Cache routed experts by `(layer, expert, tensor_kind)`.
4. Load missing expert tensors on demand from the mmap-backed GGUF.
5. Prefetch likely next-layer experts asynchronously.
6. Evict cold experts with an LRU/score policy.

## Next implementation tasks

- Identify all routed expert tensor names and byte ranges during GGUF load.
- Add `ds4_expert_cache` metadata and an LRU eviction layer.
- Split routed expert access from existing always-bound tensor assumptions.
- Add async prefetch hooks after router top-k selection.
- Add memory-budget flags to CLI and server.
- Add benchmark mode comparing no-lowmem, lowmem cold cache, lowmem warm cache, and lowmem with prefetch.
- Add correctness checks using existing logprob/vector tests.

## Non-goals for first prototype

- Do not invent a q1 quant first.
- Do not remove tool calling.
- Do not remove server API compatibility.
- Do not make CPU-only the main path.
