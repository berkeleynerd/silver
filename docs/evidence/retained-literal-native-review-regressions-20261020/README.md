# Focused native review regressions and GCC source retention

2026-10-20, #150 follow-up within owner-resumed #119. This supplements accepted
research evidence for review findings L3/L5/L14/L17. The target remains
`a3af18004743d36328a499760699305357389fb8`, implementation freeze `4f29a3bf85`;
this packet was added from research base `19b26ac8a15d7c356b03a25e41096d882bf4dbe0`.
No frozen evaluator, predecessor, result or any of the 94 aggregate inputs changed.

The [research note](../../research/retained-literal-native-review-regressions.md)
states the interpretation and remaining limitations.

- [check.py](check.py) calls the actual frozen aggregate `attach` function with
  explicitly synthetic mutations and cached copies of retained component outputs.
  [Results](check-results.json): 27 cases in 0.282113290 s; 19 false verdicts,
  seven malformed-input `ValueError` cases, one retained successful join replay.
  No source `Context` or component evaluator runs in these mutation checks.
- Stages 7, 9 and 12 each test both conjunction operands as `False` and `None`.
  Stage 8's typed ALI component guard returns a false verdict for `False` and
  raises `ValueError` for `None`. Every case checks the corresponding named
  residual and both aggregate maps. Six component guard maps are tested with
  `False` and malformed `None`; a synthetic predecessor-key collision must raise
  `ValueError: no predecessor guard overwritten`.
- [Original reviewer probe](original-reviewer-probe.py) is copied unchanged from
  the already preserved review archive. Its fault-injection pattern was adapted
  for the small retained check. The original script was **not executed** here;
  its historical absolute paths remain unchanged. [Inputs](inputs.json) records
  archive member, script and baseline hashes.
- [check-public-rejection.py](check-public-rejection.py) freshly evaluated one
  genuine family member through the public API, with no supplied or modified
  component result. [Result](public-rejection-result.json): 30,654 one-byte
  `Put` calls, zero null statements, 643,809 bytes; false aggregate verdict in
  31.718790136 s. The bytes/counts match the retained relocation fixture exactly.
  Both `fixed_signed_relocation_reach` and `EH_signed_fields` fail. The register
  predecessor short-circuits, leaving every late stage uncomputed and no late
  component joins. This is one aggregate rejection, **not** an aggregate
  acceptance boundary at 30,653 or a maximum call count.
- [Public output retention](public-output-retention.json) identifies the exact
  compressed [source](rejected-30654.adb.gz) and complete 52,962,928-byte
  [public return](public-return.json.gz). The latter expands to about 53 MB
  because the frozen evaluator repeats per-call arrays in nested predecessors.
  Retention did not repeat evaluation.
- [sources.tar.gz](sources.tar.gz) retains complete `gcc/gimple-range-edge.cc`
  and `gcc/value-query.cc` from the existing local mirror. [sources.json](sources.json)
  records their identities, observed local origins, GCC revision provenance and
  matches against three pre-existing source manifests. No network fetch or new
  upstream/source-to-binary correspondence claim is made. [retain-sources.py](retain-sources.py)
  builds the archive deterministically (USTAR, fixed ownership/mode/mtime,
  lexical members, gzip empty filename and zero mtime).

Run the smallest retained check from the repository root:

```sh
python3 docs/evidence/retained-literal-native-review-regressions-20261020/check.py
```

It needs only the checkout and Python standard library. It verifies all 94
aggregate pins, the named regression inputs and retained GCC archive identities.
Its returned synthetic aggregate records are used only for assertions; the
frozen `attach` function's `fresh_actual_source` metadata does not turn these
cached-component mutations into source-capacity evidence.

To repeat the separate public check, supply corpora/header roots matching the
existing transitive manifests and an isolated scratch directory. The successful
run's actual local roots are recorded in `public-rejection-result.json`.

```sh
python3 docs/evidence/retained-literal-native-review-regressions-20261020/check-public-rejection.py \
  --gcc-root /path/to/existing/gcc-corpus \
  --ada-root /path/to/existing/ada-corpus \
  --plugin-include /path/to/existing/toolchain/plugin/include \
  --gas-root /path/to/existing/binutils-corpus \
  --scratch-root /path/to/isolated/scratch \
  --output /path/to/owned/public-rejection-result.json
```

The [managed preflight](managed-preflight.json) found no active runs or reserved
workers; the latest successful native run remained `20261019T145323-b23fa45c07bb`.
The [verification record](verification.json) confirms the 94 input files equal
the exact target commit, the compressed public input/return match their summary,
and rebuilding the two-file source archive and manifest produces identical bytes.
The new work executed zero compilers, binders, assemblers, linkers, provers or
Lean builds. The 3,301-case author suite and predecessor suites were not replayed.
[Harness development attempts](development-attempts.json) records two adapter
mistakes and the reason for repeating the initially failed focused public check.

Selected worker: GPT-6.1 Sol / Extra High; runtime confirmation of that selection
and token/monetary measurements are unavailable. Elapsed values measure the named
offline scripts, not total task cost. This packet makes no new universal assurance,
production admission, installed-tool or Oracle claim.
