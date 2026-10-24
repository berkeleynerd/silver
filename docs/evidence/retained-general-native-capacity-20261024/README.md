# General native Main: local type kernel, 2026-10-24

Author packet for [#201](https://github.com/berkeleynerd/silver/issues/201).
The [argument](../../research/retained-general-native-capacity.md) closes the
selected local natural-layout/padding gate and derives cumulative direct
constructor coefficients. General native capacity remains incomplete.

The new result covers Main's local signed subtypes, constrained String types,
String-literal types and constrained access types. It includes canonical and
dummy/debug candidates, RM/metadata vectors, direct scalar constants, discarded
DECL_EXPRs, layout SAVE nodes and the two constrained-array alloca requests.
It attaches the local size-annotation root multiset and adds a direct two-field
String-template vector/element kernel. Symbolic helper/root weights, descriptor
validation and fixed import entry states are explicit remaining obligations.

Contents:

- `source-manifest.json`: 22 complete GCC source files, matched to existing
  predecessor manifests at GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
- `type-kernel-sources.tar.gz`: deterministic projection of those complete
  source files; no network or installed source tree is needed to check it.
- `source-witnesses.json`: 50 exact LF-based line witnesses and excerpts.
  Form-feed is retained inside its line; Python `splitlines()` is not used.
- `inputs.json`: exact predecessor document/manifest/evidence hashes, at base
  `3276f0de3d`. A changed dependency requires review and an intentional input
  update; no predecessor checker is replayed.
- `check.py`: offline identity, witness and arithmetic checker.
- `check-result.json`: retained successful result, including the five existing
  sample E_Main projections and explicit false completeness fields.

Run from the repository root:

```sh
python3 docs/evidence/retained-general-native-capacity-20261024/check.py
```

For a new retained output, add `--output` and the desired path. The checker
reads predecessor input files and the five actual sample sources, verifies
hashes, checks the direct coefficient assembly, and checks all4096 small
nonnegative disjoint family assignments against the coarse E_Main projection.
It does not infer semantic branch coverage from an excerpt or prove the
argument. The coarse projections do not supply actual Ts/Ta/Tl/Tp counts,
symbolic helper costs, annotation Q or a native capacity predicate.

The recorded check passed in0.528750 seconds on Linux x86_64:22 source files,
50 witnesses and7 predecessor inputs. There were zero compiler/prover runs and
zero predecessor replays. `git diff --check` was also clean. No production,
pin, Oracle or admission file changed. Native execution time was zero; the
check's time is offline checker time.

Material author finding: Standard.String carries an internally generated
pragma Pack even though frozen Character8 requires no packed representation.
`layout.adb:510–553` can therefore set a constrained static String's exact
natural size. The new no-padding lemma covers unknown **or exact natural**
size, and charges up to three-digit Uint-to-GCC conversions. The earlier
`retained-native-expansion.md:879–883` zero-layout suffix and its use at
`:2365–2375` require focused review for potentially missing frontend Uint
arithmetic. The literal-specific clearing rule at`:5587–5592` remains distinct.
Prior evidence was preserved; the lead owns that finding's disposition.

Author checkpoint: selected model GPT-6 Astra / Extra High; runtime setting
confirmation unavailable. The outcome is the new source-backed local kernel,
with fixed imports, symbolic folding and all later phases still open. Total
author elapsed time, token and cost measurements are unavailable. Independent
review is pending. No claim of #201 completion or implementation of #89 is made.
