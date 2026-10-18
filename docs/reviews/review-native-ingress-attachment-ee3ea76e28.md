# Independent review: native-ingress aggregate attachment

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119)
and accounting repair [#130](https://github.com/berkeleynerd/silver/issues/130).

**Disposition: accept the attachment; no material finding.** The aggregate
joins the reviewed native-ingress interfaces consistently, preserves their
allocation ownership, and keeps complete capacity unestablished.

## Inputs and scope

Exact target: `ee3ea76e280735657404d82a96273d1dd998b7c1`, reviewed from a clean
isolated worktree on `review/native-ingress-attachment-ee3ea76e28`.
The seven changed files are `README.md`, `check-results.json`, `check.py`,
`compose.py`, `inputs.json` and `result.json` in the
[aggregate packet](../evidence/retained-literal-pipeline-20261018/README.md),
plus [its research argument](../research/retained-literal-pipeline.md).

This review reuses the accepted `eb0471fa33b7c8b23bfdf0456c32e8aa4f9a79df`
source argument and `e4d170e8edb871759593df77afe2151a79353c3d` BIND repair.
Their [component review](review-native-ingress-eb0471fa33.md), originally
`fa74d21e58d5ced2c97deb21f93f255f65658a38`, is integrated as `ab5a273e78`.
I did not repeat the GCC branch/metadata proof or its focused checker.
The applicable project instructions and retained-tool authorization remain
those read for that review. No production source, rule or option changed.

## Attachment assessment

`Context` validates the aggregate input pins before loading the ingress
callable. The new pins cover `derive.py`, the source manifest, the focused
checker/result and the source argument. It then checks all 28 complete
ingress source files by length and SHA-256. Ada paths are resolved against the
provided Ada root, GCC files against the provided GCC root, and `match.pd`
against its explicit override or the manifest's separately retained path.
This avoids assuming that the full GCC capsule contains `gcc/match.pd`.
Reuse of the accepted matcher analysis is justified by those checked bytes.

The aggregate calls the ingress function with C/N from its actual-source
recognizer. The new `require` checks the following interfaces against the
existing direct/helper components:

| Interface | Matched bound |
| --- | ---: |
| Direct gimplifier event subtotal | 10C+2N+2 |
| CF block-location calls | 4C+2N+2 |
| Retained bind tuples / simultaneous depth | C+1 / 2 |
| Binding-stack capacity / maximum request | 16 slots / 136 bytes |
| Binding-stack requests / cumulative bytes | 2 / 208 |
| Local declaration-variable demand | C |
| Direct warning-copy calls | C+1 |
| Selected helper subtotal | prior 6C plus address delta 2C = 8C |

The local-variable check agrees with the unchanged `gc_vector(c,4)` demand.
The direct subtotal already contains the repaired bind term, so attachment
does not add that term again. Whole-body copying is exposed separately as
33C+9N+3. The `open_joins` availability record exports the 8C helper subtotal,
and neither sums it with the old 6C nor invents a complete gimplifier total.
The older helper component retains its own null ingress fields and diagnostic
boundary; the new ingress component supplies those interfaces separately.
The research text explains that ownership explicitly.

The new local predicate checks the recognized maximum literal length against
INT_MAX, the component's conditional ingress conclusion, existence of a
protected-set prime p, the unsigned probe intermediate `2p-3`, and the
individual `8p` backing request against the selected signed-size domain.
It does not equate prime existence with probe safety. Direct boundary
evaluation illustrates the distinction:

| C | Selected p | Prime exists | `2p-3 <= UINT_MAX` |
| --- | ---: | --- | --- |
| 1,073,741,822 | 2,147,483,647 | true | true |
| 1,073,741,823 | 4,294,967,291 | true | false |

Both individual requests fit the selected signed-size domain; the latter
still fails the probe conjunct. This is a local sufficient-condition boundary,
not an adopted source cap or a native failure observation. Ordinary set
backing remains separate from GGC copying, and set-object/allocator
bookkeeping remains open.

The complete-gimplifier event total remains null, its lifetime flag remains
false, and whole-pipeline/admission flags remain false. Original frontend/gigi
construction, incoming nowarn population/backing, remaining helpers, global
counters, collector composition, parent/binder storage and complete output
launch materialization remain named open obligations. The fixed prefix and
null-family whole-lifetime allowance are not used to close these gaps.

## Verification and round record

One fresh aggregate Python replay passed **all 67 cases** in
**3.604305878 seconds**, with exit status zero and no stderr. Its parsed
result exactly equals the frozen `check-results.json`. The seven source
variants exercise the new W/copy/address/helper interfaces, including equal
literals, a null, empty/escaped literals and 5000 calls. The added negative
case changes the component's direct subtotal and gets the required interface
join rejection. The existing intentional 5000-call linker-condition failure
and false whole-pipeline verdict are preserved.

The replay used GCC
`/tmp/silver-backend-compose-20261018/full-source`, Ada
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`, and the
selected GNAT 16.1.0 Linux x86-64 plugin include directory under this host's
`.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/`.
The default separately retained matcher path was exercised. A focused
negative check also supplied changed bytes through the matcher override;
`Context` rejected them with `changed native ingress source` before any
component replay. The frozen Hello World's entire ingress payload was
compared with the pinned callable at its recorded C/N and matched exactly;
default aggregate-result generation was not rerun.

Fresh outputs, command, elapsed time and the matcher rejection are retained
in local scratch `/tmp/silver-review-native-ingress-attachment-ee3ea76e28/`.
No committed evidence result was overwritten. Native compiler/prover/debugger
executions, broad suites and GitHub writes: zero.

Selected reviewer setting: **GPT-6 Astra / Extra High**. Independent runtime
model/effort confirmation and token/cost measurements were unavailable.
Review began at 2026-10-18 19:32:52 UTC; review, checks and report were
completed at 19:34:57 UTC, an elapsed 125 seconds. This is this review round's
time, not whole-team runtime. Intended result: verify only the aggregate
attachment. Achieved result: scoped acceptance, without implementation rework.
The live harness query returned no goal; no goal state was changed. CLI memory
was not updated. The parent owns integration and publication; #119 remains
incomplete.
