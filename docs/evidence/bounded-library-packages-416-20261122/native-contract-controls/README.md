# Native scalar contracts and special package identities — 2026-11-22

Canonical focused whole-unit run `20261122T145409-e3b75ceb67be` proved every
check in `silver_scalar_expressions.adb`: **312 checks = 269 proof + 43 flow**,
23 entities, final-policy classification, no unresolved checks or skipped
entities. This includes the complete `Read_Reference` contract, qualified
lookup, and all scalar reader callers within the unit. The run used the
primary Linux installation, two managed workers and affinity 0–1, sharing the
host's eight CPUs. Retained focused-policy solver sessions were used; this is
not a cold complete-compiler proof. The managed input inventory and full
focused report are retained under `runs/`.

Run `20261122T145750-43302dbbd2cc` renamed the original three `package_counter`
units to `Standard` and `GNAT` without annotations or flattening. Each original
file was compared byte for byte after membership checking and compilation.
Both membership checks accepted on the pre-exclusion parser.

- `Standard` compiled, passed the complete application report audit across six
  units and 21 entities (**68 checks = 48 proof + 20 flow**), and executed with
  status 0, stdout ` 9\n`, and empty stderr. Workspace originals were also
  byte-identical. It remains an admitted package identity.
- `GNAT` produced 68 discharged checks but the selected prover emitted
  `assumed-global-null` for Reset, Increment and Read, and
  `assumed-always-terminates` for Reset and Increment. The existing complete
  evidence audit correctly rejected compilation with status 3. No executable
  success is claimed. Commit `e2e787a067` excludes this demonstrated identity
  collision; the earlier no-op frontend-only observation remains historical.

The control run used two managed workers. Its custom workspace reservation
named `.silver/linux-x86_64/artifacts`, while the driver actually wrote the
retained sibling `program-*` directories under `.silver/linux-x86_64`.
No other primary native job was active during this control (the scalar proof
had ended), and the actual output paths are retained. This reservation mismatch
is a runner coordination defect in this invocation; later custom driver runs
must reserve the actual host artifact root. It does not change the observed
source, producer report, audit or execution results.

`special-name-results.json` retains
exact commands, diagnostics, input hashes, the successful report totals and
execution observation. `special-names/` retains original units and selected
producer reports for both outcomes. All evidence predates the GNAT exclusion;
its post-change regression is a separate root-owned check. Complete
Output_Profile helper proofs, Lean actual-source correspondence, and the
integrated complete admission checkpoint remain outstanding.
