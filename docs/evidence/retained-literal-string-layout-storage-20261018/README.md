# Cold Standard.String layout storage evidence

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-18. Independent review is pending. The
[source argument](../../research/retained-literal-string-layout-storage.md)
is the review target; the executable checks corroborate its identities,
arithmetic and selected source branches.

The residual surrounding the accepted helper94 interval contributes at most
**216 direct GGC requests / 13,149 caller bytes / 17,112 separately rounded
slot bytes**, and **three ordinary requests / 192 bytes**. Adding helper94
once gives **310 GGC requests / 19,981 + 2P caller bytes /
25,024 + 2 rho(P+33) slot bytes**, and **five ordinary requests / 272 bytes**.
These are cumulative request bounds, not allocator, collector or RSS bounds.

The interval starts at the first complete Standard.String conversion in an
imported I/O profile and ends at its final association/deferred processing.
Both complete allocating self_referential_size invocations are excised into
helper94, including all of their direct requests and shared demands. The
original extent expressions and subsequent XUT layout remain here. The later
synthetic173, original Main/elaboration including Main/null helper11, and
per-literal subtype/constructor intervals are excluded. Shared-container
backing is consumed by its existing aggregate component, using this packet's
residual demands plus helper94's separate demands exactly once.

Run from the repository root:

```sh
python3 -B docs/evidence/retained-literal-string-layout-storage-20261018/check.py \
  --output docs/evidence/retained-literal-string-layout-storage-20261018/check-results.json
```

The checker accepts `--gcc-root`, `--ada-root` and `--matcher` for relocated
retained source trees. The recorded run used these defaults:

| Input | Retained location |
| --- | --- |
| GCC root | `/tmp/silver-backend-compose-20261018/full-source` |
| Ada root | `/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada` |
| Matcher | `/tmp/silver-backend-compose-20261018/folding-sources/match.pd` |
| GCC source revision | `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` |
| Frozen Silver input revision | `62471752d9823fe73300f03825c8716999d9e127` |

The retained result is **PASS: 42 checks**, 34 source files, 14 frozen Silver
inputs, 49 signed-bound extent fixtures and 12 XUT alignment fixtures. Six
new raw commit-URL byte comparisons were performed during the research round:
Ada `layout.adb`, `exp_dbug.adb`, `namet.ads`, `namet.adb`, `opt.ads` and
`uintp.ads`. The other upstream identities reuse identified frozen manifests.
The checker verifies local bytes, SHA-256 and Git blob IDs, and the frozen
identity origins; it makes no network requests. Historical Silver inputs are
read with `git show` at the pinned revision, not from mutable working files.

`derive.py` contains the explicit request rows and exports `interface.json`.
`fold-audit.json` retains the original-extent/XUT shape rows and the scalar
factory ledger. `source-manifest.json` pins the review inputs.
`check-results.json` records the run and its limitations. Source landmarks and
finite fixtures do not establish universal fold/control-flow closure; that
obligation is the handwritten argument and its independent review. The packet
retains the prior installed/source relevant-behavior premise and makes no new
binary identity or language-admission claim.

Selected worker: GPT-6 Astra / Extra High. Runtime-setting confirmation and
token/cost data were unavailable. The round began at 21:31:43 UTC and its
passing check ran at 21:51:59 UTC, after approximately 20.3 minutes, taking
0.126 seconds on Linux x86-64. The checker initially used Python's broad
line splitter; source landmark checks exposed that GCC form feeds must not
advance LF source line numbers. That checker error was corrected; the ledger
did not change. During source review, the three scalar return-in-memory
predicates were resolved to `examine_argument`, which constructs no REG;
the six REGs in synthetic173 remain separately charged.

Native compiler/build/prover/full-test runs: **zero**. No production, Oracle,
admission, tool, proof-pin, aggregate, GitHub or memory files are changed.
Imported-frontend, shared-container, collector and whole-pipeline completion
flags remain false. The cold-String direct-constructor claim awaits review.
