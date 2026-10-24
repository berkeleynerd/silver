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

The original checker is reproducible in the exact36d478da0c checkout. Its
predecessor-document pin intentionally records the pre-#207 text. For the
current repaired frontend exports, run from this repository root:

```sh
python3 docs/evidence/retained-general-native-capacity-20261024/repair-string-pack.py
```

Use `--output docs/evidence/retained-general-native-capacity-20261024/string-pack-current.json`
to refresh the current export. The original `check.py`/`check-result.json` and
predecessor inputs remain historical at their exact author freeze.

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
Prior evidence was preserved. The confirmed finding is #207; its authored
[repair](string-pack-repair.md) now supplies the seven-entry first-layout
transfer, digit/descriptor/workspace bounds, once-per-entity argument and
mandatory monotone current overlay. Independent review is pending.

Author checkpoint: selected model GPT-6 Astra / Extra High; runtime setting
confirmation unavailable. The outcome is the new source-backed local kernel,
with fixed imports, symbolic folding and all later phases still open. Total
author elapsed time, token and cost measurements are unavailable. Independent
review is pending. No claim of #201 completion or implementation of #89 is made.

The repair adds `string-pack-sources.tar.gz`, its manifest with29 LF witnesses,
`repair-string-pack.py`, `string-pack-repair.md` and `string-pack-current.json`.
The focused check passed16 source files, three frozen inputs,29 witnesses and
3600 signed/digit-boundary pairs in0.491806 seconds. A one-time source inventory
hashed1041 retained Ada bodies and found nine calls plus the Layout_Type
procedure declaration; the portable checker rechecks their retained matching
files, not the full negative search. Current Uints/Udigits backing checks are
recomputed; no changed-table historical success flag is reused. Old native
expansion generator and JSON bytes remain unchanged. The repair uses no new
compiler/prover/predecessor replay and does not complete #201.
