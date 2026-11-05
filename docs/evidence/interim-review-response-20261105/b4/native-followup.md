# B4 native proof follow-up — 2026-11-05

The casing implementation is in `475f0aa13a439d45f47b9907ed541f181305c24d`.
This follow-up factors one ghost observation call into `Observe_Proof_List` so
its field-name precondition can be proved in a small context. The wrapper keeps
the original text, object-observation and mixed-field conditions and instantiates
the original result at `JSON_proof`. Its body invokes the existing proved
`Projection_Field_Names` lemma and the unchanged `Observe_Object_List` helper.
The original helper and `Mixed_Object` contracts are retained.

The final `src/silver_library_reports.adb` SHA-256 is
`d4769797028160de4fa9598250e48a103699050654d0d071c4f200c7c2f1392e`.
Only that source file and this handoff change in the follow-up commit. The
helper is `Ghost => Static`; the original casing tests remain applicable.

## Diagnosis and focused evidence

All runs used native Linux x86-64, two workers, level 2, CVC5/Z3/altergo,
timeout 30, all mode, and warnings/checks as errors. Focused calls used
`--limit-name` in the original `explore/image-casing` object/session path.
These are development checks, not a complete audited native manifest.

| Managed run | Scope and result | Managed elapsed |
| --- | --- | --- |
| `20261105T090739-d879074d7877` | Report unit: 3,201 of 3,202 checks discharged. The sole failure was `Mixed_Object` at original line 4186:7: the `JSON_proof` call could not prove `Name = Flow_Name or else Name = Proof_Name`. The preceding `JSON_flow` call, final postcondition and casing-related checks passed. | 5,441.667 s |
| `20261105T104436-664f3661b7c1` | Repeating the proved field-name lemma immediately before the call left the same precondition unresolved. | 156.231 s |
| `20261105T104941-4b9cf01df67d` | An explicit `JSON_proof = Projection_Observations.Proof_Name` assertion passed, while the subsequent generic call's name disjunction still timed out. Both constants are the identical `String (1 .. 5)` literal `"proof"`. | 156.732 s |
| `20261105T105418-602baad69e0e` | Specialized `Observe_Proof_List`: all six checks passed, including the generic helper's name precondition and the specialized result contract. | 25.517 s |
| `20261105T105517-519789dbcad9` | `Mixed_Object` with that wrapper: all 49 checks passed, including the wrapper call and unchanged final postcondition. | 554.384 s |

The assertion result supported moving the generic call out of the accumulated
observation context. The successful wrapper and caller checks establish this
factoring without assuming the missing name condition or weakening a contract.
No solver budget was changed and no blanket unit retry followed the failure.
Managed diagnostic notes precede each successive hypothesis.

The original failed object/session tree was copied and byte-compared before
editing. Local preserved evidence is under
`tmp/image-case-repair/tmp/b4-evidence/`:

- `failed-20261105T090739-d879074d7877/`: complete original objects/sessions,
  raw reports, native log and source, about 563 MiB.
- `failed-repeat-20261105T104436-664f3661b7c1/` and
  `failed-assert-20261105T104941-4b9cf01df67d/`: exact changed entity
  JSON/session, source, raw reports and native log for each diagnostic.
- `native-followup-runs.json` and `handoff.md`: compact local outcome index.

Managed logs/reports also remain in the shared Git run registry under the
listed run IDs. The completed live object/session tree remains at
`tmp/image-case-repair/.silver/linux-x86_64/compiler/obj/explore/image-casing/`.
It is idle and ready for the lead's coordinated copy into the final native lane.

## Review and remaining integration

The independent reviewer, selected as GPT-6 Astra / Extra High, inspected the
exact final source hash above and found no soundness issue in the wrapper's specialization. Its report
is retained by the lead as integration `tmp/B4-policy-review.md`; its policy
review and the native annotation checks have distinct scopes.

The lead still owns complete integrated native proof/audit/provenance,
source-correspondence checks, regression inventory and final review. The focused
successes above do not complete that checkpoint or close #312. No publication
was performed here.

Selected implementation setting: GPT-6.1 Sol / Extra High. Runtime-confirmed
model/effort and token/cost measurements were unavailable. The table records
managed tool elapsed time, not total development or team cost. The final code
and contracts were reviewed together; the ineffective repeated lemma/assertion
experiments were removed.
