# Original Standard.String size-helper construction evidence

Authorized research [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-18. The [source argument](../../research/retained-literal-original-string-storage.md)
closes the two complete `self_referential_size` invocations, including private
copies and all four `substitute_in_expr`/GENERIC-fold traversals. Independent
review is pending.

- [derive.py](derive.py) exports [interface.json](interface.json): at most
  **94 GGC requests**, **6,832+2P caller bytes**, and
  **7,912+2 rho(P+33)** separately rounded slot bytes; two ordinary requests
  totaling 80 bytes. P bounds the cleaned filename/global-object name
  component. rho rounds each request to the next power of two.
- [fold-audit.json](fold-audit.json) records the handwritten matcher/legacy
  fold case partition. The substitution envelope is 10 unary, 22 binary
  and four ternary nodes, including reassociation and inversion candidates.
  It is not a generated-matcher simulation or a proof by source search.
- [source-manifest.json](source-manifest.json) pins 27 GCC sources at
  `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and 13 historical Silver inputs
  at `316f40e7b2c0b7ffc57eca81c7aff39784cdd35a`. Three source files were
  additionally compared byte-for-byte with their raw upstream commit URLs;
  the other source identities reuse the named retained manifests.
- [check.py](check.py) and [check-results.json](check-results.json) retain
  36 passing offline identity, source-landmark, shape and arithmetic checks,
  including 192 finite shape fixtures. No native compiler/build/prover runs.

From the repository root:

```sh
python3 docs/evidence/retained-literal-original-string-storage-20261018/check.py
```

Optional `--gcc-root`, `--ada-root` and `--matcher` arguments select retained
source locations; `--output PATH` records a new result. The checker does not
fetch inputs, execute GCC or prove the handwritten control-flow closure.
The installed/source relevant-behavior premise is inherited unchanged.

The constructor interval ends with its returned CALL_EXPR, before later
synthetic gimplification. It exports four identifier entries and two type-hash
records to shared backing, at most three existing small-constant cache writes,
eight DECL UIDs, four type UIDs and two helper-name suffixes. It adds zero
finalizers, symbol registrations and constant-pool entries. The broader
Standard.String conversion, original Main/empty-elaboration construction,
the corrected 173-event synthetic interval, shared backing, collector pages,
ordinary allocator metadata, stack and system-library internals remain
separate. This is not a complete literal-pipeline capacity result.

Selected worker: GPT-6 Astra / Extra High; runtime-setting confirmation and
token/cost data unavailable. Round start: 2026-10-18 20:58:57 UTC. The retained
check finished at 21:18:46 UTC in 0.108 seconds, about 20 minutes after that
start. The same round first corrected the six return-ABI REG omissions in
the separate synthetic leaf (`316f40e7b2`), then completed this constructor
leaf. No production, proof-provenance, Oracle, admission, aggregate, GitHub or
CLI-memory files were changed by this packet. Independent review is pending.
