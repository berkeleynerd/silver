# Fixed-size Integer arrays — final delivery review

Date: 2026-10-28. Exact target:
`a197a9f77aa460bd4aaf9a8caf727d8eaa261dcc` (clean `tmp/fixed-integer-arrays`).
Final implementation: `6e18e13c06`; integrated Rosetta metadata: `64c9f8036e`.
Independent reviewer selected GPT-6 Astra / Extra High; runtime-confirmed
settings and token/cost measurements unavailable. Read-only closing review;
no native/Lean/build/test/probe/renderer runs or repository/GitHub writes.
Only this report was written. First recorded clock sample was 03:02:08 UTC,
after initial reads; report completed 03:04:25 UTC. These timestamps exclude initial reads.

No consequential finding remains. The retained complete native and Lean/source
checkpoints, reviewed semantic/source repairs and complete regression inventory
support completion of the bounded #260 capability. The successful complete
actual-source checkpoint discharges the remaining validation condition for
#262. The lead's planned report integration, completion wording and issue-closing
commit remain administrative delivery steps; this review did not perform them.

## Final delta and correspondence

The three Sequence files and literal-header candidate exactly match the hashes
already independently reviewed. The only later proof change is
`SequenceEquations.initial_valid`: its existing simplification now unfolds
`ArrayBindings.ValidEnvironment`, `ValidMetadata` and `ValidInitials` for the
unchanged empty initial state. Statement, domain, constructor and semantics are
unchanged. This proves the existing obligation rather than assuming validity or
restricting arrays. Final SequenceEquations SHA-256 is
`fc53bc4369f2844f1184f2a0185cd69c202b78f4614e33b68e75e5ca697cda56`.

The earlier semantic, native/specification, capacity, caller-domain, header and
Sequence-state reviews remain applicable. In particular, #262's repaired
aggregate helper equations retain the caller's actual native scalar conditions;
complete source checks now validate that repaired chain. No Oracle amendment,
native/source pin, generator or proof-policy change was introduced by the final
repair. The documented frontend/producer/solver and runtime assumptions remain.

## Completed evidence and identity

- Native run `20261027T104107-f971342569f8`: terminal success at 2026-10-27
  18:34:46 UTC, full mode with complete coverage/provenance audit. All 16,697
  checks passed: 1,418 flow plus 15,279 proof; 76 units and 1,068 entities.
  I independently matched all 143 tracked provenance inputs to the target and
  verified all 78 report digests against retained decompressed reports, with
  zero differences. The original record retains 2,558 inputs, including its
  own generated/toolchain files; those are not asserted byte-identical across
  checkout paths. The successful build `20261027T113126-109aa8ee133a` retains
  the previously reviewed applicability to unchanged native/build inputs.
- Complete Lean run `20261028T025546-5dcc21502246`: terminal success, build
  39.708 s and fresh audit 10.449 s. I independently matched all 646 captured
  source hashes and compared the audited module inventory with all current
  project modules: exactly 531, with no missing or extra module. The audit
  checked 112,162 declarations with only `propext`, `Classical.choice` and
  `Quot.sound`. This includes the authoritative source chain and retained
  Sequence witness. Input digest:
  `b0fbf84e8e62dd17772a0b4ab580010fb54065a373315ad0cc535b4d266d7ecc`.
- The complete failed Lean attempts remain failed. Their successful expensive
  ComposeSourceCandidate (4,604 s) and PredicateSourceCandidate (4,278 s)
  artifacts were reused; the subsequent complete successful build and fresh
  audit establish closure. No independent kernel replay, clean-build timing,
  macOS or hosted CI outcome is claimed.

These are successful complete-scope incremental checkpoints, with permitted
cache reuse. Their scope is not inferred by composing focused proof results.

## Final regression and support record

The existing independent 530-identity census and applicability reviews remain
valid after the final proof-only changes. No native/test/harness/tooling,
source-policy marker, import/module inventory or affected fixture property
changed. The current inventory is still exactly 530 distinct identities,
SHA-256 `11539742a6e231777bb36ca14e4d872ef82f2c2905ee9400bac9788f41591530`.

Rosetta run `20261028T025725-858b560a8320` has terminal success and all three
expected test identities passed in 4.463 s. Its 785 captured inputs match
current bytes. All 86 integrated Rosetta patch files are byte-equal to the
independently reviewed prepared commit
`87cb365cc1746f3f9dec0f45f185b31cbedf3d14`. Those three fresh successes replace
their three retained successes: **76 fresh + 454 retained = 530**, without
missing or failing required tests. The original full-suite run remains failed
and its five failures/errors remain preserved alongside their successful reruns.

README, roadmap/capability table, assurance discussion, capability record,
session checkpoint and evidence packet consistently describe the narrow
fragment and final evidence. Rosetta adds only `fixed-integer-arrays` and the
faithful left-rotation driver; broad arrays and #12 remain open. The language,
catalogue and sample bytes remain the reviewed implementation. Earlier pending
statements inside historical review/round records are not new obligations;
the final status wording can now reference this completed review.

## Review inputs

This closing review reused the established reviews at `899a15a5a0`,
`529df9a6c4`, the literal-header snapshot and the exact Sequence-state patch.
It inspected the final initial-validity delta, final documentation/metadata,
the complete run events/logs/evidence and current input inventories. It did not
repeat the broad implementation investigation or rerun successful tests.

Primary retained artifact SHA-256 values below identify decompressed bytes;
paths are in `docs/evidence/fixed-integer-arrays/delivery-20261027/runs/` under
the run IDs above.

| Artifact | SHA-256 |
| --- | --- |
| `Lean evidence JSON` | `9de37059cb592f9c5fdad2015adb6df3384463a311640d205059c927544eba2d` |
| `Lean completed log` | `e2f111601043dec99cf4f89c824d6ed0f97594656ff289054b4efea6f11c51ad` |
| `Native provenance JSON` | `f3086e5a36ee40c193a31157d98a613cea4fede8537a0e4456c9dba764e9ab58` |
| `Rosetta test log` | `94744426e818650678bce177ff6bb129439097a98dcdd610d14fb6ba023d4481` |
