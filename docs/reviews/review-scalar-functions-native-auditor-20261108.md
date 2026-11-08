# Scalar-function native auditor review — 2026-11-08

Approve the narrow policy interpretation and implementation commit
`53d3a3b22bd0c2c0693bd81c662ad5dfc4658dcb` for findings
[#347](https://github.com/berkeleynerd/silver/issues/347) and
[#348](https://github.com/berkeleynerd/silver/issues/348), under
[#298](https://github.com/berkeleynerd/silver/issues/298). No blocking finding
remains in this correction. This approval permits using the corrected auditor
in the required validation; it is **not final capability acceptance**. Native
run `20261108T094547-29491e1d3036` remains failed, with no completed provenance.

## Target, independence and scope

The reviewer did not propose this policy. The reviewed patch has parent
`d39a2b21c8f9b74151967f748cc300b99d1f8302` and changes exactly
`scripts/check_evidence.py`, `tests/test_evidence.py` and
`docs/trusted-boundary.md`. Its worktree was clean apart from owned scratch.
The separate review branch starts at integration
`56af24f63b9070a5eb1e23c5405889ef16569f1a`; the underlying admitted-source
snapshot remains `f6308191545c1012d76132ae535977e55fd4f018`.

Read the Oracle, relevant AGENTS instructions, development validation and review
rules, proof-iteration invalidation matrix, source/report trusted boundary, the
[original diagnosis](review-scalar-functions-delivery-20261108.md#complete-native-policy-failure--2026-11-08),
its proposal/evidence, actual pinned references, finalized patch and retained
test/diagnostic packet. The earlier broad admission, composition, capacity and
source-correspondence reviews were not repeated.

Selected reviewer configuration: **GPT-6 Astra / Max**, explicitly requested.
Independent runtime model/effort confirmation, complete elapsed-review timing,
token use and cost measurements are unavailable. Actual host: Linux x86-64.
Live harness goal was null. CLI memory was not updated. This review ran no
production auditor, tests, native build/proof or Lean build/proof; it used
source inspection, static AST/hash/data comparisons and public pinned-source
retrieval. It changed only this report and its own scratch/worktree, with no
signals, cache/lease changes, issue/PR writes, push or merge.

## Independent policy assessment

The Oracle permits compiler/library-owned proof annotations while forbidding
application authors from supplying them. It also forbids silently narrowing
domains, changing behavior or suppressing required obligations. Those rules
are compatible with these two precise corrections; no Oracle amendment or new
external dependency is warranted.

The actual pinned
[annotation guide](../../references/spark/16.1/docs/ug/en/appendix/additional_annotate_pragmas.rst),
lines 1175–1217, explicitly describes caller-local
`Hide_Info, "Expression_Function_Body", F`. It removes an expression-function
definition from the entity's proof context. The example becomes unprovable
when that definition is needed. This supplies no assurance fact and does not
skip the caller's postcondition or the callee's verification. The four actual
pragmas in `Mixed_Termination_Witnesses` and `Mixed_Object` have exactly that
form, targeting `Raw_List_Spec` and `List_Spec`; their source and contracts are
unchanged. The retained full-source/report diagnostic below still checks
coverage, dependencies and all obligations. A generic Annotate exemption would
not follow from this argument and is not implemented.

The actual pinned
[portability guide](../../references/spark/16.1/docs/ug/en/appendix/portability_issues.rst),
lines 87–110, states that GNATprove adopts GNAT's implementation choices for
arithmetic association. The
[SPARK LRM](../../references/spark/16.1/docs/lrm/source/names-and-expressions.rst),
lines 431–443, identifies Ada's reassociation permission and states that GNAT
does not exercise it. This is a premise about the already trusted fixed
compiler, distinct from withholding proof information and from portability to
another compiler.

Pinned `vc_kinds.ads` places `Warn_Operator_Reassociation` in the pedantic
warning class, disabled by default; its message and `vc_kinds.adb` rule name
match the twelve retained diagnostics. Independent inspection of producer
commit `42554fc241fcd1fdf08d3a2feccb3f86912acbc0` confirms that
`Warning_Msg_N` still records disabled warnings, using empty `suppressed` and
the default trivial/unknown/empty-tree metadata. Its SARIF conversion maps the
empty suppression to exactly `[{"kind":"external"}]` and warning severity to
`open`/`warning`. The three fetched producer-file hashes match the earlier
[retained producer assessment](../evidence/scalar-guard-refinement/array-advisory-20261026/assessment.json).
This is source review under the existing pinned-tool premise, not binary/source
attestation.

That same producer representation can also arise from source warning
suppression. Consequently the exact diagnostic classifier is valid only
together with the unchanged prohibition on `pragma Warnings`, the other source
exclusions, fixed project/command policy and current provenance. The patch
preserves these controls. It does not treat an external SARIF marker by itself
as permission to ignore a warning or failed check.

## Concrete patch and negative controls

The source-policy exception compares the complete twelve-token pragma statement
in `silver_library_reports.adb` with only the two reviewed targets. Existing
`source_tokens` still validates compiler-source bytes and separates comments,
strings and character literals. Identifier case and exterior layout/comments
are immaterial; the quoted `"Expression_Function_Body"` remains case-sensitive
and exact. Missing/extra arguments, altered category/target/string, incomplete
closing syntax and other source units are rejected. The loop keeps examining
the rest of the file, so an allowed pragma cannot exempt a later forbidden one.
The forbidden pragma set and SPARK-Off checks remain intact. Application
admission and its one-permitted-pragma rule are unchanged.

Reassociation recognition triggers on either the exact rule or known message
before generic informational acceptance. It requires a compiler audit,
`warn_error`, the exact ten-field native schema, warning/trivial metadata,
positive integer coordinates, exact message, unknown status, empty tree and
empty suppression string. Only these report-owner/source pairs qualify:

| Report owner | Source |
| --- | --- |
| `silver_function_bindings` | `silver_function_bindings.ads` |
| `silver_library_reports` | `silver_library_reports.adb` |
| `silver_output_profile` | `silver_output_profile.adb` |
| `silver_output_profile` | `silver_function_bindings.ads` |

The SARIF branch compares the entire result, including nested location objects
and the single external marker, with an accepted native diagnostic before
extracting nested fields. Explicit integer-type checks prevent Python's
Boolean/float equality from accepting noninteger coordinates. Positive locations
follow from equality with the validated native record. Extra fields, foreign
paths, changed category/message/status, missing counterparts and extra
suppressions cannot qualify. The existing Counter equality remains unchanged,
so both occurrences of the imported bindings-spec location must be represented.
SARIF order need not be pinned.

The new class has its own counter and diagnostic multiset; it is not added to
`PROOF_LIMITATION_NOTES`. It contributes zero flow, proof or termination checks.
All coverage, dependency, skipped/assumed/justified/failed-check, invocation,
source-policy and summary-total checks remain in force. Exact field matching
also rejects empty justification fields and other unreviewed metadata.

The eight new test methods cover the two actual annotation targets, caller-local
placement, Ada case/layout/comments, malformed statements, wrong origins,
application policies, all native fields, rule-or-message detection, failed and
missing work, exact SARIF shapes and repeated-location multiplicity. Existing
negative controls were neither deleted nor weakened. Independent AST comparison
finds all 78 previous test/fixture methods in `test_evidence.py` unchanged;
the patch only adds two classes.

The implementer's first iteration had four failing synthetic subtests because
prior temporary `.spark` files obscured the intended origin-policy check. The
final fixture removes only its own TemporaryDirectory report files before
reconstructing each case. It does not modify production reports, relax an
assertion or change an old shared fixture. That iteration remains failed;
the following results are the subsequent actual successful runs.

## Retained validation and exact inputs

The finalized implementer packet is
`tmp/scalar-functions-auditor-repair-298/tmp/native-policy-repair-298/`.
All nine members match its `inventory.sha256`; that inventory's SHA256 is
`6deedbef3951e533eed24a01397daa9e48121505aaed79fa70e409256cb6c82b`.
Raw log outcomes were independently reconciled with the two test inventories,
including multiline managed-fixture output. They establish **137 distinct
successful ordinary Python test IDs**, with no failures or skips in these
final runs:

| Scope | IDs | Actual log |
| --- | ---: | --- |
| Evidence policy, including eight new methods | 73 | `evidence-provenance-tests.log` |
| Provenance and fixed-command controls | 24 | Same log; 97 tests in 3.373 seconds |
| Python Image and inherited Array evidence fixtures | 6 | `related-python-tests.log` |
| Image setup | 8 | Same log |
| Managed command fixtures | 26 | Same log; 40 tests in 5.227 seconds |

No test was re-executed by this reviewer. The managed commands printed by these
fixtures use mocked native tools; they are not another production proof run.

| Final input | SHA256 |
| --- | --- |
| `scripts/check_evidence.py` | `e88e27676d7b5dacc18c67d9dff1bcc6aa2ed0dda8025487a59be46505cfffa6` |
| `tests/test_evidence.py` | `29266ba7cf5d1126accd3dc7ec3861f39e2aff5f3514b480bdac19385b66de00` |
| `docs/trusted-boundary.md` | `fe1b5a407bf62f273d3df51f8d86058161057a9b905b29c1e51edda752b6d074` |

All 133 actual `src/` Ada files match the target commit in the repair,
integration and native parser-repair worktrees. The complete `src` and `proof`
Git trees are identical at the patch parent, reviewed patch and integration
`56af24f63b`. Integration's actual tracked source/proof/project/manifests also
have no difference from the reviewed target. No Ada, Lean, generator,
certificate pin, build configuration, contract, domain or proof option changes.

The implementer's read-only corrected `audit_sources` diagnostic passed the
original native source/generated/report inputs. Its captured command exactly
equals the actual run 094547 `proof-inputs.json` command, and its recorded
auditor hash equals the reviewed commit. It reports 77 units, 1,165 owned
entities, **1,605 flow and 16,920 proof checks**, 330 limitation notes, six
array-initialization notes and twelve separate reassociation advisories. The
18,525 check total is unchanged. All expected source/report, coverage,
dependency, SARIF-multiset and summary checks are executed on this path.

This cheap diagnostic supports entry to the corrected checkpoint. It does not
complete provenance or relabel the original failed run. The original native
directory still has no `proof-provenance.json` at this review.

## Regression applicability and remaining validation

The exact patch changes only two auditor functions and adds test classes;
function signatures, existing fixtures, constants used by proof configuration,
`dev.py`, provenance, platform and Lean runners remain unchanged. Reading an
auditor module through an import is not by itself evidence that a test's
executed behavior changed.

The six Python Image/Array evidence methods share `test_evidence` helpers and
exercise malformed-message interactions; they passed freshly. Their five native
Image/Array counterparts exercise the unchanged compiled SPARK report checker
and unchanged mutation helpers, so their existing successes remain applicable.
Provenance, Image setup and managed-command fixture consumers also passed
freshly. Existing Lean fixtures do not execute the modified native audit
functions, and their proof/generator/setup dependencies are unchanged. The three
previously accepted installation-environment methods do not call the changed
audit paths. The pending platform wrapper and twelve nested bodies still need
their previously required results.

Application/sample tests use Main and the selected runtime units. They do not
call the new compiler source-pragma path, and none of those report origins can
qualify for the reassociation allowance, including older calls that omit
`application_kind`. Existing successful genuine producer records follow the
same acceptance path; existing check counters have the same values, and callers
read individual statistics rather than comparing the whole dictionary. Native
source, compiler behavior, build inputs and generated application artifacts are
unchanged. These facts justify retaining the prior successful native cases
without recompiling every sample merely because the auditor is imported.

The targeted per-ID reconciliation extends the previously reviewed 637-ID
inventory by eight new methods:

| Disposition for this exact auditor delta | IDs |
| --- | ---: |
| Fresh current passes: 129 previous IDs plus eight new IDs | 137 |
| Other previous passes with retained applicability | 492 |
| Previously pending compilation/platform IDs | 16 |
| Expanded inventory | 645 |

Thus 629 IDs have applicable successful results at this stage. This preserves
the sixteen outstanding IDs and the requirement to refresh all three Rosetta
methods after capability promotion; it does not accept the entire final suite.
The per-ID extension is `tmp/regression-delta.json` in this review worktree,
bound to the earlier resolution by SHA256. Source/packet/hash reconciliation is
in `tmp/independent-verification.json`; fetched pinned producer files and hashes
are in `tmp/pinned-producer/`.

The remaining proof sequence is the existing supported one:

1. Freeze the corrected inputs in the preserved native checkout and run one
   ordinary managed warm `prove --full`, keeping native sessions/cache and
   logical options. Require actual managed success, complete source/report
   audit, current matching provenance and the mandatory standalone checker.
2. Preserve integration's running Lean inputs until actual exit. After applying
   this auditor delta, run ordinary cached complete Lean validation with a fresh
   whole-project module/axiom audit. Unchanged expensive proof objects remain
   reusable; no clean rebuild or independent replay is indicated by this delta.
3. Complete the sixteen pending regression IDs, later Rosetta refresh and final
   integrated delivery review before support/completion claims.

`proof_provenance.input_hashes` includes recursive Python scripts, and
`complete_proof` requires equality with the run snapshot. Standalone
`check_evidence` requires an existing completed manifest. Therefore the old
failed snapshot cannot be completed with this changed auditor by restamping
inputs or manufacturing a manifest. The ordinary cached checkpoints refresh
current evidence without discarding valid proof work. This review approves
the correction and its bounded evidence reuse, while leaving those completion
requirements intact.
