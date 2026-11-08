# Focused native parser equality repair — 2026-11-07

This packet covers the bounded parser repair for #298. It is focused Linux
evidence, not a complete compiler or actual-source assurance checkpoint.

Commit `1ddd3a21b5` adds Static ghost equality helpers for the complete signature
and formal arrays and uses them, with both counts, in `Same_Parser_State`.
The helpers compare every slot, including unused slots. Their `Logical_Equal`
annotations are proved, without a validity or reachability restriction.

Commit `f102afeeb0` reuses the existing Integer and Boolean word constants and
adds `Character_Type_Word` at six paired hiding checks in the model and ordinary
array-declaration function. The words, bounds, branches, contracts and required
assertion are unchanged. The independently reviewed private function-body
precondition repair `e56af1b1a2` was imported as `bd46e051c2`; that duplicate
dependency is not a new repair to integrate.

## Results and scope

Every run used the pinned GNATprove 16.1.0 toolchain, level 2,
CVC5/Z3/Alt-Ergo and a 30-second prover limit on native `linux-x86_64`.
Initial helper and full consumer runs reserved two workers. Later focused
consumers reserved ten after peer work released its reservations. The input
hashes, commands, tools, worker counts, durations and outcomes are retained
verbatim in each run's compressed `events.jsonl` and `native.log`.

| Managed run | Exact selected scope | Outcome |
| --- | --- | --- |
| `20261107T210802-62535ab82b11` | Initial region-limited attempt | Interrupted after discovering that this limiter translated unrelated entities; not proof success. |
| `20261107T212356-e9d9fa606dc6` | `Same_Parser_Function_Items` | All 3 checks proved, including `Logical_Equal`. |
| `20261107T212454-2e87c9d6241b` | `Same_Parser_Formal_Items` | All 3 checks proved, including `Logical_Equal`. |
| `20261107T212602-9427c02d1099` | `Same_Parser_State` | All 3 checks proved, including `Logical_Equal`. |
| `20261107T212806-7ec67439cb0b` | Whole `Array_Declaration_At` subprogram on helper-only source | Failed: 57 of 58 checks proved; assertion at line 2268 remained unproved. |
| `20261107T221115-a5b819bc3c92` | `Boolean_Array_Values_At` postcondition at line 2089, plus associated selected checks | All 4 checks proved. |
| `20261107T221844-106c3eae8695` | Repaired `Array_Declaration_At` assertion at line 2269 | All 3 selected checks proved, including the original required assertion. |
| `20261107T222113-945ea27e618b` | `Function_Body_At` postcondition at line 5757 | All 4 selected checks proved. |
| `20261107T222322-cb585b946ae2` | `Function_Declaration_At` call precondition at line 5834 | All 3 selected checks proved, including every conjunct of the strengthened precondition. |

The last four runs combine `--limit-subp` with the exact source-line limiter.
Their wrapper also requires the reported proof inventory to contain the intended
`VC_POSTCONDITION`, `VC_ASSERT` or `VC_PRECONDITION` at that line. This prevents
an empty or wrong selection from counting as success. Associated flow checks
remain in the selected report; the unselected obligations are not claimed.
The [selected inventories](selected-inventories.json) extract the analyzed
subprogram names and proof-check locations from the archived reports; each
selected report names exactly its intended subprogram.

The earlier full declaration run remains failed. Its 57 successful checks and
the later selected assertion are not presented as a fresh complete check of the
final source. The whole compiler native audit, complete source correspondence
and final provenance remain the integration lead's responsibility. The successful
Boolean postcondition precedes only the subsequent unrelated named-word change;
the function-body/caller checks use that final source.

## Diagnosis and retained artifacts

The [independent diagnosis](diagnosis/review.md) inspected the exact failed
generated task and found three distinct array-valued literal symbols for the
same Integer, Boolean and Character words in the model and executable hiding
predicates. Both initializer contracts already supplied logical equality, and
the inspected normalized terms had no unmatched record-conversion boundary.
This rejected the initial generic equality-transport hypothesis in favor of
the existing shared-word pattern.

The retained [original comparison](diagnosis/normalized-comparison.json) has
three differences. The [regenerated comparison](diagnosis/array-word-normalized-comparison.json)
has zero after the six replacements and new constant, using the same diagnostic
reductions. These comparisons explain the experiment; they are not proof
certificates. The subsequent selected native assertion proof is the discharge
evidence.

[index.json](index.json) records the packet's uncompressed SHA-256 hashes.
It includes native reports, per-entity sessions, source snapshots, original
failed sessions, the complete generated AST for the failed helper-only consumer,
the read-only diagnosis and current scratch runner sources. Earlier raw failure
ASTs remain at their explicitly recorded local paths; their hashes are retained.
The first two helper runs predate automatic per-run report archival, so their
logs and separately retained entity/session reports are included explicitly.
The current runner sources are retained as tooling context; historical command
and input identities remain those in each run record.

The diagnosis was assigned GPT-6 Astra / Max for the named unresolved equality
problem; its review distinguishes selection from independent runtime
confirmation. The resumed implementation thread's live model/effort and
token/cost measurements were not independently exposed. Native elapsed times
are in the run records and are not whole-team cost measurements.
