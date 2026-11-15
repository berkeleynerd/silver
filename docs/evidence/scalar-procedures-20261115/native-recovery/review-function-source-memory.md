# Independent review: function-source memory repair

**Disposition: accept the bounded two-file repair at `81e09276c9cd16d18665aea034cbb56acb72ccc4`.**
No unresolved material production finding remains. One evidence-log labeling
issue was corrected and independently verified at `dbcacf8d5`. This review does
not complete #370 or establish the pending integrated assurance checkpoint.

The reviewer did not author these Lean changes. The parent selected GPT-6 Astra
with Max effort for this critical proof/source-correspondence review; independent
live model/effort telemetry is unavailable. Total review elapsed time, tokens
and cost were not measured. The native tool times below are separate evidence,
not estimates of review or whole-team cost. Review date: 2026-11-15.

| Round | Intended result | Result and rework | Measurement scope |
| --- | --- | --- | --- |
| Independent critical review, selected Astra / Max | Check exact theorem, kernel trust, full-source uniqueness and evidence identities | Accepted; exact runner logs retained after identifying ambiguous launcher-log naming | Read-only source/evidence inspection and independent Python comparisons; no new Lean/native run or replay |

## Exact target and applicable guarantees

The production target consists of
`proof/Silver/FunctionSourceParts/DeclarationLoopFunctionLocals.lean` and
`proof/Silver/FunctionSourceParts/FunctionLocalsExpectedTokens.lean`.
Their SHA-256 values are respectively
`45eaf9319360555ebd868887480a9f5fa1b289bd058ec7621707ba09a278d560` and
`d8460db722d511aae77e3b12ca0648902f2cbd105ff0bb37c424ef7edc574899`.
Supplemental controls and cleanup are at `9fd138afb`; log clarification is at
`dbcacf8d5`. These evidence commits do not change the frozen production bytes.

The review applies the Oracle's unchanged-source, complete-domain and
no-suppressed-obligation requirements, its prohibition of unfinished proofs or
unproved project axioms, and the documented Lean kernel/local-object trust
boundary. It checks the repair's contribution to source correspondence without
substituting a focused candidate theorem for authoritative-source integration.

## Proof and source checks

- The exported leaf statement is byte-identical to its parent at `3eedf80d6`.
  It still selects loop entry index 1 and applies the original
  `ordinaryFunction` to **all** of `Output.SourceShape.outputImplementation`.
  No slice, prefix, segmented scanner or restricted input replaces that argument.
- Independent extraction compared the loop entry, leaf and both helper string
  occurrences: all four contain the same 909 ASCII characters/UTF-8 bytes.
  Both 909-character lists equal that string exactly. The helper and leaf token
  lists contain the same 171 ordered tokens; an independent lexical check for
  this exact ASCII fragment also agrees.
- Independent extraction of the complete reviewed list counted 72,709 tokens.
  The two `function_locals` headers are its specification and its sole ordinary
  body. That complete body contains exactly the expected 171 tokens. This
  extraction corroborates the retained kernel proof; it is not a replacement
  proof or a claim about authoritative-source reconstruction.
- The character theorem uses standard `String.toList_ofList`. Kernel conversion
  must identify `String.ofList` of the supplied characters with the original
  string literal. The token theorem unfolds the unchanged `expectedTokens`,
  `lexLine` and `compilerSource`, rewrites the character equality, and uses
  `decide +kernel`. Alphabet validation, lexical fuel and the complete lexer
  result remain checked.
- The leaf rewrites this proved token equality and supplies an explicit
  `Eq.refl` witness. The existing `kernel_exact` elaborates the closed witness
  without the goal as an expected type, then synchronously checks it through
  `mkAuxLemma` at the exact goal type. Lean's auxiliary cache is keyed by the
  type, privacy and definitional-equality flag, and also checks level parameters.
  The reviewed witnesses are closed; no new axiom or kernel bypass is introduced.
- `ordinaryFunctions` still examines the complete list and retains every
  matching ordinary body. `ordinaryFunction` still succeeds only on a singleton
  result. `FunctionSourceCandidate.declarations` still uses this same leaf;
  `FunctionSourceChecks.checked_source` still requires
  `Output.SourceBridge.actual_complete_shape.2.1` to reach authoritative tokens.

## Evidence and controls

The [supporting JSON](review-function-source-memory.json) records the independent
comparisons, selected source/artifact hashes, full focused import inventory and
retained evidence identities. At the recorded comparison time, all 1,105
run-input files matched the main success. The final cleanup has the identical
input inventory/digest; all 1,000 cleanup workspace inputs matched, as did the
12 retained/current artifact
entries for the two production modules. Neither production run's module, input,
workspace or artifact inventory contains the retired probe, segmented candidate
or temporary controls. Their files are absent from production source/workspace.

The [main success](../lean-recovery/focused-success-evidence.json.gz),
`20261115T173223-fb4134e2af34`, builds the original full-source leaf and freshly
audits **107 modules / 15,604 declarations** on Linux aarch64, Lean 4.34.1.
Only `propext`, `Classical.choice` and `Quot.sound` occur. It uses one Lake worker,
automatic 12 Lean threads and the original 8,192 MiB periodic per-process
threshold. Build time is 74.043 s; audit time 1.088 s; monitored invocation
85.077 s, exit 0. Sampled largest-process RSS is 4,860,656 KiB and summed RSS
5,987,024 KiB. Sampling can miss peaks and double-count shared pages. This is
an incremental focused success, with no independent kernel replay.

The earlier 2 GiB success, `20261115T172007-8dc3d8f5e77f`, targets the now-retired
`FunctionLocalsExpectedTokensProbe`. It does not establish a separate 2 GiB
build of the final production module. The final production helper is covered
by the main 8 GiB leaf audit. Earlier 2/4 GiB whole-leaf attempts remain failures.

The [negative control source](../lean-recovery/negative-controls.lean.gz) changes
only the first candidate character from `C` to `X` while retaining the complete
909-character witness; its other candidate omits exactly the first token,
`current`. Run `20261115T173611-b27c8626e3d1` rejects the former with an explicit
kernel declaration type mismatch and the latter with `decide` proving the
proposition false. These are intended logical rejections, not memory failures;
the failed run has no successful audit.

The [positive control source](../lean-recovery/positive-controls.lean.gz) uses
the exact production body. Run `20261115T173725-aa334a489da8` proves five bounded
checks: unique extraction succeeds; duplicates before and after the body fail,
including a header spanning an append boundary; dropping the first body token
and reversing the body cannot satisfy the expected result. Its fresh 2 GiB
audit covers 91 modules / 10,541 declarations with the same three foundations.
These controls supplement the full fixed-source theorem and universal semantics.

The [cleanup run](../lean-recovery/production-cleanup-evidence.json.gz),
`20261115T173917-d7a06c23e3ca`, freshly audits the same production-only 107 modules
and 15,604 declarations after removing controls. No module rebuild is reported.
It preserves the successful proof inputs and confirms the restored audit scope.

## Resolved finding and remaining integration

The initial `focused-success.log.gz` was monitored launcher output, so its
decompressed hash differed from the runner-log hash recorded in the evidence.
The exact matching runner log existed in the managed run. Commit `dbcacf8d5`
retains it as `focused-success-runner.log.gz`, retains the corresponding exact
logs for three other successful runs, and explains both log roles. The reviewer
independently verified all four uncompressed runner-log hashes against their
evidence. The original observations remain intact. This was an evidence
retention/labeling correction, not a production proof defect.

The lead still owns the final authoritative-source/certificate joins, affected
caller/facade integration, complete native proof and whole-project Lean/axiom/
provenance/regression checkpoint. Changed source or pins require evidence for
those final inputs. This review supplies no new language limit, global memory
setting, macOS validation or resource-independent guarantee.

The reviewer modified only this report and its supporting JSON. No production
file or cache was changed, no proof/native job was started, and no GitHub write
or CLI-memory update was made. The live harness goal was observed as null.
Unrelated scratch in the reviewer's native worktree remains preserved.
