# Selected literal emission closure evidence

Research for [#119](https://github.com/berkeleynerd/silver/issues/119).
The [source argument](../../research/retained-literal-emission-closure.md)
completes the selected compiler stream inventory and its ordinary/constant
label endpoint derivation. Independent review is pending.

For C calls, N nulls, W decoded bytes and maximum decoded length L, use
`I=7C+7N+45`. The ordinary-label next value is at most `39258+I`, and the
constant-label next value is at most `39257+2C`. Each must fit signed int.
The retained prefix is explicitly charged; it is not assumed empty. I is a
lifetime chain-constructor ceiling, including deleted objects. Target setup,
imported construction and cold helpers have explicit label-route exclusions;
they retain their allocation costs in their own packets.

The complete selected stream still fits the existing assembler interface:
`114+I+W+8C` lines, `7410+65I+13W+512C` bytes, longest line 512 bytes excluding
LF, local names 25 bytes excluding NUL and symbol names 26 bytes including NUL.
Main emits `.LFB1`/`.LFE1`. Its used external declarations populate pending
storage, but the selected ELF default-visibility hook adds no directive.

`derive.evaluate_source(raw)` validates the unchanged accepted source family
through the pinned existing recognizer, after enforcing today's printable
ASCII plus HT/CR/LF alphabet. `derive.evaluate(C,N,W,L)` is the internal
arithmetic interface for already recognized counts and mathematical endpoint
tests. Neither callable materializes or verifies production options. The
selected `-fsplit-wide-types` option and all other configuration/source-behavior
premises remain explicit. No production compiler option was changed.

Every result keeps separate false flags for production invocation/materialization,
complete non-label global counters, shared backing/collector capacity and whole
pipeline capacity. The parent can remove the selected whole-stream and
label-source residuals only; actual command/object routing and the fixed link
frontier remain required. Zero emitted lines are never substituted for zero
storage.

`source-manifest.json` binds 44 complete GCC/Ada files to GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, with length, SHA-256 and Git-blob
SHA-1. Forty-three match existing retained source manifests. The small additional
generator source is preserved in `supplemental-gengenrtl.cc.gz` from the same
retained upstream tree, with its original fetch-manifest row and URL.
Thirty-three historical repository inputs are frozen at
`13daeca1e97eef2d0894f6f5175789677df54ce9`; the checker reads them with `git show`
so later parent integration need not rewrite this packet.

```sh
python3 -B docs/evidence/retained-literal-emission-closure-20261018/check.py \
  --output /tmp/literal-emission-check.json
python3 -B docs/evidence/retained-literal-emission-closure-20261018/derive.py \
  --source samples/hello_world.adb --output /tmp/literal-emission-result.json
```

The checker accepts `--gcc-root` and `--ada-root` for the existing retained source
trees. Its 302 successful checks include complete identities/origins, the
counter and external-writer source landmarks, exact assembler-interface joins
for 125 C/N/length combinations, last passing/first failing signed endpoints,
large mathematical integers, doubled quotes/empty literals/comments/case,
5,000 calls, and invalid sources/counts. Source landmarks support the handwritten
control-flow argument; they do not mechanically verify GCC semantics.
`result.json` is the checked-recognizer Hello World example, C=1,N=0,W=L=13:
ordinary next <=39,310, constant next <=39,259, 187 lines and 11,471 bytes.

Selected settings: GPT-6 Astra / Extra High, assigned by parent. Runtime
confirmation and token/cost measurements are unavailable. Actual host:
Linux 7.0.14 x86-64, glibc 2.43, LP64. The successful checker ran in
0.295065 seconds and completed 2026-10-18 22:21:52 UTC, 479.240688 seconds
after the recorded round start. This interval covers source work through the
verification checkpoint; final documentation/commit handoff follows it.
One historical artifact pathname and one exact source-landmark string were
corrected during evidence construction; no semantic bound changed.

Intended/achieved: close selected global label endpoints and the complete
Main/data/unit-writer partition while preserving production and capacity
boundaries. Native compiler/capture/build/proof/solver runs: zero. No worker
reservation was needed. Oracle, production tools/pins/admission, aggregate,
GitHub and durable/CLI memory were unchanged. The child harness goal query
returned null; no goal state was written. Parent owns review and integration.
