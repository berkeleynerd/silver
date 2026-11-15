# Reduced-host recovery — 2026-11-15

The owner resumed #370/#29 through complete validation, critical review and
reviewable publication. Authorization is recorded on main in `903dac970`.
The published starting point is `32895f4827`; the
[November 13 failure packet](../../scalar-procedures-20261109/final-failures-20261113/README.md)
retains the exact implementation, native assertion failure and Lean memory
failure. Those failed complete checks remain failed.

## Workspace and evidence recovery

The current host is Linux ARM64 with twelve available CPUs and approximately
15.8 GiB RAM. Original Linux x86_64 workspaces and binary proof objects are
absent here. The committed input/report/session packets are retained; their
presence is historical evidence, not a fresh ARM64 result. `host.json` records
this observation and the selected delegated models/efforts. Live lead settings
and whole-team token/cost measurements are not independently exposed.

Isolated worktrees initially restored under the mounted repository encountered
`Too many open files` in both GNAT translation and Lean/Lake imports. Linux's
per-process descriptor limit is 1,048,576; the Lean investigation isolated an
approximately 9,832-handle limit on the mounted filesystem, while the same
probe exceeded 12,000 handles on native storage. The failed launches are kept
in the respective investigation packets. They did not test the proof goals.

A dedicated Docker volume, `silver-recovery-370-20261115`, supplies native ext4
storage, bound at `/home/agent/silver-workspaces/recovery-volume`. Integration,
native diagnosis and certificate reconstruction use its separate worktrees.
The isolated function-source investigation uses native overlay storage at
`/home/agent/silver-worktrees/procedures-lean-370`. Each installation is separately
configured after relocation; no writable proof workspace is shared. These are
sandbox-local workspaces: retained deliverable evidence is committed and pushed
through the existing PR; local caches are not implied to exist on the host.

## Focused work and checkpoint order

- Astra Max native investigation: compare the unchanged array-declaration
  assertion with retained sessions, then check the whole helper and affected
  caller under the canonical compiler policy. Retained success under a different
  budget is not current-policy success.
- Astra Max function-source investigation: check the previously failing
  `DeclarationLoopFunctionLocals` closure in isolation, with one worker,
  automatic process threads and an 8 GiB threshold. Monitor process RSS and host
  headroom. This reduction is justified by this host's measured memory limit.
- Astra Ultra certificate investigation: determine a kernel-checked complete
  source reconstruction that fits this host. The earlier aggregate footprint
  exceeded current RAM. Preserve every source byte, checked lexer result,
  authoritative binding and final audited argument.

Native diagnosis initially reserves at most two workers alongside the isolated
Lean run; only small certificate lemma experiments may overlap. Reassess these
allocations before each larger run. Full contracts and declared domains,
canonical proof policy, all obligations and source correspondence remain intact.
No blind complete retry, timeout increase or successor implementation is selected.

`test-inventory.json` identifies 691 distinct tests at the starting point;
it records discovery, not execution or successful regression validation.
Complete native assurance, complete Lean/source/module/axiom/provenance checking,
all applicable regression cases, final critical review and Rosetta reconciliation
remain pending. Subsequent focused results and exact final inputs must be linked
here before a complete-checkpoint claim.
