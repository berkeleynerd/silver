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

## Focused repairs and final-input checkpoint

The native repair at `03141a9fe` binds the existing model expression once in a
`Ghost => Static` constant, without changing the runtime initializer, exported
contract, full domain or 30-second canonical proof policy. The whole helper
passed 56 proof and two flow checks; the unchanged direct caller retains 11
proof and two flow checks with exact continuity evidence. The corresponding
Lean renderer passed run `20261115T173050-5f33a5830ee5`, freshly auditing 13,678
declarations. The [independent review](../certificate-memory/review-native-ghost-constant.md)
accepts the source, wrapper and exact reviewed-token delta.

The [function-source repair](../lean-recovery/README.md) preserves the full-source
duplicate-detecting scan and public theorem while normalizing the expected
string through a proved character identity. Focused run
`20261115T173223-fb4134e2af34` passed at the ordinary 8 GiB threshold; its process
tree peaked at 5.710 GiB. Corrupt character/token and duplicate controls remain
retained. The [certificate repair](../certificate-memory/README.md) constructs
the existing reconstruction theorem through the checked auxiliary-lemma path.
Its actual-size join passed at 3 GiB. These results favor a proof representation
and string-normalization bottleneck; they do not establish an asymptotic bound
on the entire proof pipeline or complete assurance.

The old-source certificate run was deliberately interrupted after the required
native repair invalidated its source, with no memory failure. Five completed
line buckets, all inputs and compiled artifacts remain retained. Its final
aggregate and audit did not run. Resume on the combined source and reuse only
matching artifacts through normal Lake dependency checks.

All 40 generated candidates were independently regenerated on the final Ada
bytes and refreshed together; [the refresh inventory](generated-candidate-refresh.json)
identifies the seven changed files, including the formerly stale output
specification candidate. [The reviewed pin delta](reviewed-output-pin-delta.json)
contains exactly one static declaration and two references to it.
[Lean cache seed identities](lean-cache-seed.json) record matching ARM64 artifacts,
not proof success. Before the full Lean run, check the two largest inherited
function headers with one worker/default process threads and the same 8 GiB
threshold. Complete native validation may proceed on the fixed Ada/tool inputs.
All final complete checks and the 691-ID regression inventory remain outstanding.
