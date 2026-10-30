# Boolean native implementation observations

Issue #291, Linux x86_64, 2026-10-30. The selected worker was GPT-6 Astra /
Extra High per the lead briefing; runtime model confirmation and token/cost
measurements are unavailable. Native implementation checkpoint `a7c82fa07e`
adds the agreed xor restriction to `828dd16e6e`. Producer evidence and the
source-route account are in [producer-review.md](producer-review.md).

The current source/operator/operand budgets and strict report policy are
unchanged. The source tree hashes, catalogue dependency `048d658fb6`, final
Boolean test file digest and retained managed-run logs are recorded in
[native-validation/inputs.json](native-validation/inputs.json).

- Build `20261030T101759-11062aba76bc` passed with the xor restriction.
- `20261030T102003-472181d589ec` ran twelve Boolean test methods in 62.121 s.
  The eleven existing methods passed, including compiled truth tables and
  snapshots, Rosetta boundaries, eager operand safety, name hiding, arrays,
  and existing source/operator limits. The new span method initially failed
  four fixtures because literal-to-literal String equality is excluded by
  the existing named-operand rule. Replacing one operand with a named String
  kept the intended lexical cases; the corrected method passed separately
  in `20261030T102137-95973b991800`, 3.959 s. No native code changed between
  these runs. This is the union of passing method results, not one claimed
  successful twelve-method suite run.
- `20261030T101857-6c61f1e3dcdb` was interrupted after a test-selection mistake
  began broader discovery; the selected test run uses `-p test_boolean_objects.py`.
- Four exact 4096-byte sources passed admission under an explicit 8192 KiB
  stack in `20261030T102331-35ed542d5735`: deep Boolean grouping, nested `not`,
  150 Boolean objects plus grouping, and 100 scalar objects plus grouping.
  [Stack observations](stack/observations.json) retain byte hashes, commands,
  return codes and durations. The first fixture attempt omitted the required
  Silver_IO context for declarations and was rejected; its sources and logs
  remain in `stack/initial-no-context/` with run `20261030T102306-4d660fefb49b`.
- The exact 4096-byte grouped initializer additionally passed checking,
  original-source compilation and execution under the same stack limit in
  `20261030T102453-b9bb6a308428`. Compilation discharged all 66 reported checks.
  The existing strict report auditor independently passed on the retained
  original reports; the generated main source exactly matched the input.
  [Compile observations](stack/compile/observation.json) and compressed reports
  are retained. The broad artifact workspace reservation caused about ninety
  seconds of registry-lock contention during baseline scanning; subsequent
  application probes should use the managed test route.

The additional one-worker native context was explicitly authorized by the lead
alongside the preserved two-worker output-profile proof of `828dd16e6e`.
Temporary validation source/tests/samples in the original root checkout were
restored after the observations; unrelated files and all validation/proof
artifacts were preserved. The older unit proof remains a separate checkpoint;
it cannot discharge the new scanner or xor restrictions. Complete native,
Lean/source-correspondence and feature capacity integration remain pending.
