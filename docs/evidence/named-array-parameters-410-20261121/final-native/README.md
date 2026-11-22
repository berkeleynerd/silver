# Corrected complete native audit — 2026-11-21

Managed run `20261121T191055-5cced625eb47` passed in 492.560 seconds on Linux
x86_64 with two workers, inherited OS affinity to guest CPUs 4–5, and a 16 MiB
invoking-shell stack. It used full forced unit analysis and retained native
sessions/solver cache; it is not a cold runtime measurement.

The audited totals are 78 units, 1,265 entities, 1,775 flow checks and 18,219 proof
checks: 19,994 discharged checks. The audit also classified 361 limitation notes,
18 imported entities, 6,268 trusted-math notes, 62 vendor-spec entities, five
array-initialization advisories and 29 other accepted operator-reassociation
advisories. The new scalar-expression warning is absent. Accepted warning policy
and all obligation-discharge requirements were unchanged.

The source-only grouping repair and bounded driver are on the native worktree
at `adf639b865`; the primary proof/source implementation has additional Lean
integration commits. `source-comparison.json` records exact equality of all 135
Ada files and ten Python scripts with the integration tree. Generated installation
paths and native tool identities retain their actual native-worktree scope in
`proof-provenance.json.gz`; no other installation identity is claimed.

The original complete run `20261121T135513-089c46fa489d` remains failed: the prover
reported all 19,994 checks, but the strict audit rejected the scalar-expression
operator-reassociation warning. Grouping the wide Length subtraction repaired
that warning without changing mathematical evaluation, native helper contracts
or language membership. The typed Lean tree and source pin were repaired together.
The canonical focused declaration check `20261121T185720-c8b8943aaecb` passed all
38 helper checks. Its earlier body-line selection `20261121T185537-7700045ce968`
remains failed because the report identifies the helper at its spec declaration.

The retained run directories contain compressed original runner events/logs;
the two complete runs also retain their original reports. The summary is a
lead-written index, not substituted runner output. At this native checkpoint,
complete Lean/source assurance, final regression
coverage and delivery review remained outstanding. The later
[complete Lean/source packet](../final-lean/README.md) and
[final delivery reconciliation](../../../named-array-parameters.md#delivery-assurance-and-validation)
record their actual subsequent outcomes without changing this run’s scope.
