# Failed final checkpoints and bounded advisory repair

This packet retains the two complete attempts that finished during the owner-requested evening pause, plus the first bounded auditor repair after resumption on 2026-11-13. Neither complete attempt passed. Current implementation and delivery state are in the [capability record](../../../scalar-procedures.md).

## Native attempt

Run `20261110T181302-a4553e500d15` failed with exit 1 at 2026-11-11 03:27:05 UTC after 33,241.304 managed seconds. It used 14 workers, all flow/proof and reports, level 2, CVC5/Z3/Alt-Ergo and the canonical 30-second compiler timeout. It began without canonical sessions/cache in the primary worktree and performed fresh analysis; no cold-mode or independent replay claim is made.

The retained summary counts 19,428 checks: 1,712 flow, 17,715 proved proof and one unproved proof. `Procedure_Updates` has 30 of 31 checks proved; its static result/model postcondition at `silver_output_profile.adb:5412:20` timed out with all three provers. Complete native assurance therefore remains failed. The ordinary successful provenance manifest was not emitted after GNATprove failed, and the strict audits rejected that state.

The diagnostic continuation through the existing auditor also identified two rejected operator-reassociation advisory records from `silver_procedure_bindings.ads:61:39`, in the own-unit and output-profile reports. Its enumeration is diagnostic only; continuing to list requirements does not turn failed checks into assurance.

[native-failure.tar.gz](native-failure.tar.gz) preserves the original actual-exit packet with 2,595 captured native inputs, 78 SPARK reports and supporting SARIF/summary/input records, the actual managed state, command log, failure details and diagnostic enumeration. All current/prepared/launch/retained-copy inputs matched when the monitor collected the packet. The parser identity is `735f4bbb8cd0f9ecf816e17df3242113417f9ddeeafdf4bcb8ae2ecc25d41758`; primary HEAD then was documentation-only `c27f3ebab5`. Original sessions/cache remain in the original workspace and are not duplicated here.

## Lean attempt

Run `20261110T214613-eae8ec3e5581` failed its complete build with exit 1 at 2026-11-11 02:19:31 UTC after 16,329.237 build seconds. Eight Lake workers and 22 threads per process were coordinated with the native run. Eleven modules produced seventeen diagnostic locations: stale Basic/Boolean/callable-token/function-local/scalar-header/parser-state source expectations and one omitted existing arithmetic premise. No complete fresh module/axiom/provenance audit ran after the failed build.

[lean-failure.tar.gz](lean-failure.tar.gz) preserves the complete failed-run packet: logs/events/status, all 1,101 captured shared input copies, 40 generated candidates, the unchanged 994-module inventory, 425 successful new module-build names and an inventory of 5,768 existing cache artifact hashes. These successful objects remain useful for subsequent dependency-checked reuse; their inventory is not a complete audit. Original compiled caches were preserved in place, not archived here.

Earlier eight-chunk run `20261110T181505-9a359fa38440` and aggregate run `20261110T193335-f2328f201990` passed. The aggregate build took 7,756.777 seconds and its fresh focused audit took 24.556 seconds, covering 50,876 declarations / 16 actual project modules using the three allowed foundations. Its success is narrower than the failed complete checkpoint. Source worktree `tmp/scalar-procedures-source-semantic-370/tmp/final-source-integration-20261110/` retains both successful artifact packets and the original failed inputs. The archived pause handoff records exact proposed patches and restart checks; its pause instruction is historical and was superseded by the owner's 2026-11-13 resumption.

## Reviews and first repair

The [independent final-delta review](../../../reviews/review-scalar-procedures-delta-bfe82aeb81.md) inspected implementation `bfe82aeb81` and confirmed missing handwritten `out` token checks as F1, tracked in #375 within this delivery. Its static comparisons, finding evidence and retained-focused-evidence recount are copied here. It did not accept the complete delivery.

The [bounded advisory review](../../../reviews/review-scalar-procedure-advisory-20261113.md) independently checked the native specification, retained diagnostics, arithmetic domains and corresponding model before accepting exactly two owner/source-origin additions. Commit `faa9f17415` implements that change in the existing classifier and its origin documentation. It preserves all field/schema, SARIF multiplicity, application, suppression, obligation and provenance checks. The synthetic test fixture now accounts for 14 advisories and four proved checks separately.

Managed run `20261113T092238-18c9ef927da9` passed all five focused `OperatorReassociationAdvisoryTests` methods in 0.212 seconds. `advisory-test-092238/` retains the managed events/input capture and test log. The reviewer inspected the exact implementation and attributed this test result to the lead; no independent test/proof replay was performed. This bounded classification pass does not resolve the native postcondition or the Lean failures.

## Retention and scope

`retained-files.json` records exact hashes and sizes for the archived/copied files. The archive contents are copies of existing evidence, without filtering failed results into successes. The final native monitor selected Sol High; the source and critical-review roles selected Astra Max. Live runtime settings and token/cost telemetry were not independently exposed. Evidence collection and this documentation added no proof, compiler build or application run. Preserve complete native/source assurance and final regression requirements before delivery.
