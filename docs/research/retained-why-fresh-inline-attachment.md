# Fresh first-inline graph and identifier attachment

2026-10-20 UTC, #119 / #153, Round 50, Linux x86_64. Base
`5cbf04b56480a830e336c58908352dcc7f741732`.

**The earlier 1,145-registration local inline bound now attaches to fresh
PID 17869's first Input_Is_Valid/CVC5 entry.** Its complete prepared input and
declaration-cache projection satisfy the earlier theorem's exact conditions.
The corresponding local arithmetic is `60,496 + 1,145 = 61,641`. This resolves
the specific fresh-state attachment left open in the
[task-acceptance note](retained-cvc5-task-acceptance.md#removal-entries-require-a-different-counter-argument).
It does not include pending save/report registrations or bound another driver,
task, transform or the entire continuation.

The [focused offline packet](../evidence/retained-why-fresh-inline-attachment-20261020/README.md)
consumes the retained fresh graph/table and the accepted projection/refinement
functions. It performs no capture, native run, observer replay or predecessor
`compose()` replay. Existing evidence remains unchanged.

## Same process and the exact prepared input

The [accepted fresh capture](../evidence/retained-why-save-state-capture-20261020/README.md)
retains `capture-input-is-valid.tar.gz`, under
`inline/input_is_valid/capture/`. This attachment binds its `process.json`,
`summary.json`, `inline-entry-graph.json`, `hsdecl-table.json` and
`identifier-state.json` to the manifest and common archive's `inline/plan.json`.
The process is PID 17869, with one initial thread, no new threads, successful
completion and no protected guard failures. Its single driver preparation has
visited `counterexamples_dependent_intros` and then `inline_trivial`; the stop
is before executing inline. The prepared task address, ordered declarations,
graph identity and the 512-node chain agree with the same-run summary. Printer,
submission and save guards have zero hits. Historical plan endpoint wording is
not used to substitute a registration cut for this inline cut.

The executable identity remains `7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`,
with Why3 `9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84`. The captured instruction prefixes
for the declaration-table and identifier observers match the exact plan.
This reuses the accepted relevant-source/native and capture correspondence;
it introduces no stronger historical-binary claim.

The accepted `project.input_isomorphism` checks all **244 prepared logical
roots** against the original first-entry input. It follows all **14,477 blocks**
reachable from those roots, preserving sharing, constructor tags, sizes,
immediate values and opaque bytes. This includes the actual attributes, types,
triggers and delayed-substitution representations. Only process addresses and
header colour bits are immaterial. The input subgraph's opaque blocks are
strings; no custom-operations address normalization is used. The packet records
every root pair and a digest of the recomputed full pointer bijection.

The logical declaration counts are unchanged: 17 type, 16 data, 68 parameter,
81 singleton logic and 62 proposition declarations. The fresh optional-choice
refinement reproduces the entire accepted `details.json`, covering every
`inline:no` exclusion set. It does not assume unread Meta payloads are empty.
The source model retains 45 eligible definitions and 85 possible hits; its
mapped-root upper coordinate sums are `(n,b,p,a) = (1613,168,12,594)`.

## Fresh declaration-cache projection

The fresh table is checked independently of the old table's addresses. The
accepted `validate_table` covers every bucket, key slot, cached hash and nonempty
declaration root; `validate_graph` checks complete graph-edge closure.

| Fresh state | Value |
| --- | ---: |
| Outer buckets / allocated weak slots | 5,003 / 11,968 |
| Nonempty slots / distinct old declarations | 6,704 / 6,704 |
| Maximum bucket length / next declaration tag | 7 / 6,836 |
| Combined prepared-input/table blocks | 326,456 |
| Retained graph header and payload bytes | 9,058,224 |

Nonempty weak slots form a conservative selectable superset. A later collection
can remove an entry; no strong-liveness assumption is made. Opaque custom blocks
elsewhere in the complete table do not become part of the surviving input-root
representative family or receive a new resource bound here.

The fresh `project()` invocation runs the accepted refinement on these roots,
checks all 143 mapped keys are distinct, and examines all 6,704 old objects.
Kind/symbol mismatch excludes 6,559 objects. The 145 same-key objects are the
142 non-goal input declarations plus the following three alternatives:

| Extra old proposition | Old `(n,b,p,a)` | Candidate upper | Exclusion |
| --- | --- | --- | --- |
| `concat_singleton_left_def` | `(72,8,0,19)` | `(72,7,0,19)` | Binder slots |
| `bool_eq_rev` | `(53,7,0,18)` | `(52,7,0,18)` | Term occurrences |
| `argument_count__post_axiom` | `(17,2,0,8)` | `(16,2,0,8)` | Term occurrences |

These coordinates are computed from the fresh old-representative graphs, with
the earlier per-root candidate ceilings. The accepted strict-equality argument
requires equal opened coordinates, so none can be returned for a covered
candidate. Each remaining old object is that root's exact input declaration.
For all 143 mapped roots the fresh refinement also checks that selecting every
optional miss reproduces the exact opened input, including attributes.

This discharges the state inputs to the
[accepted representative theorem](retained-why-inline-representative-state.md#local-insertion-closure-and-actual-opened-attributes).
Its source insertion argument is reused: the fresh fold memo begins empty at
this goal entry; each non-goal mapped key has one merge, earlier local candidates
cannot match a later distinct key, and the goal uses `Hsdecl.unique`. Wrapper
interning preserves the declaration and predecessor under the existing valid
cache-map premises. Weak clearing/rehashing cannot invent a representative.
The selected synchronous source/no-foreign-insertion conditions remain those
of the original theorem; a matching numeric counter is not their substitute.

## Attached charge and its exact boundary

The representative envelope is again `E=8, V=6, T=3, A=80`. The unchanged
[operational source transfer](retained-why-inline-operations.md) therefore gives:

| Local identifier-producing work | Upper bound |
| --- | ---: |
| Inline term kernel | 235 |
| Logic formals outside the kernel | `6*123 = 738` |
| Logic-termination body opening | 4 |
| Task `check_match` body opening | 168 |
| Total | **1,145** |

The [comparand result](retained-why-inline-comparand-capacity.md) already shows
that strict/shallow comparison and hashing add no identifier registrations.
The graph/cache join attaches the existing arithmetic; it does not rebuild a
different operational model or claim exact native execution of inline.

The same fresh `identifier-state.json` contains tagged word 120,993, decoding
to 60,496, and the
[initial-registration theorem](retained-why-initial-registration-bound.md)
proves pre-cut no-wrap for this PID. The existing pure counter transfer checks
`60,496 + 1,145 <= 2^62-1`, with final upper 61,641 for the accounted local
source operations. In a continuation with additional registrations, those
remain an explicit extra summand. The inherited well-formedness, valid-cache,
freshness and source/runtime premises retain their scope.

The historical blanket claim that every signal save exits is not revived.
An escaping save exception can be caught by continuing code, as the
[callback analysis](retained-why-inline-callback-closure.md) explains. There is
still one global allowance of two save-entering callbacks, three saves and
`e <= 2`; this packet neither resets that budget nor absorbs its registration
charges into 1,145. Other shared counters, backing/allocation/stack capacity and
the remaining transforms still require their respective joins. Whole `R` stays
null. The next composition can now use this established local component while
deriving the other actual preparation and callback charges.

Selected worker: GPT-6 Astra / Extra High, parent-confirmed selection. Runtime
confirmation and token/cost telemetry are unavailable. The round record retains
measured offline validation and elapsed time. No GitHub, memory or harness write
occurred; parent owns review and integration.
