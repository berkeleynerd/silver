# Bounded regression applicability resolution — 2026-11-08

This packet resolves reuse and actual successful outcomes for the current
637-ID inventory. It does not establish full regression completion, native
assurance, Lean assurance or applicability after a future Rosetta promotion.
No tests, native tools, Lean builds or project Python modules were executed by
this audit. Static parsing uses Python's standard-library AST; evidence
inspection, byte hashing and Git reads are read-only.

Final disposition: all 286 proposed reusable outcomes are accepted, with no
rejected reuse. They comprise 285 original passes and the successful repaired
chunk fixture. All 335 actual fresh passes from the failed repaired run also
apply. This gives 621 successful applicable outcomes and sixteen pending IDs:

| Disposition | Unique IDs |
| --- | ---: |
| Accepted retained outcome | 286 |
| Accepted fresh outcome | 335 |
| Pending actual compilation timeout | 3 |
| Pending original platform wrapper | 1 |
| Pending platform bodies through that wrapper | 12 |
| Total current inventory | 637 |

`resolution-overview.json` supplies exact pending IDs, the per-file retained
counts and the three future Rosetta refresh IDs. It also independently confirms
that every disposition's defining method equals the reconstructed inventory.

## Exact targets and origins

The initial complete byte comparison captures integration
`896995129a235235fde99dc0c485752edcc63372`.
`docs-only-target-extension.json` extends it to
`3d38fedb6866b537ddc4a8d2a634b7d0b339360f`: only AGENTS.md, development.md and
the agent-workflow, proof-iteration and session-memory documents changed.
The resumed audit preserves those completed commit-blob comparisons and rehashes
the actual files against them after checking unchanged governed Git roots.
The governed source remains `f6308191545c1012d76132ae535977e55fd4f018`.
The regression checkout is `4281f71171477c24995eae18c983ae69b1cd1747`.

The audited roots are src, proof, tests, scripts, samples, catalogue, rosetta,
silver.gpr and alire.toml. The main audit compares every tracked file to its
commit blob and both actual worktrees, and separately checks Python test-file
membership. Its original applicability baseline is
`d396db2aeb498cd132bbe4b9f0ea3f0fb93687f8`; the only governed-input changes from
that baseline are the production parser and 21 Lean files. The current target
extension changes none of the audited roots.

Fresh build `20261108T093134-afb39e7e6b4f` finished successfully in the regression
checkout. The actual native-tool phase exit is 0; the stored top-level finished
returncode is null. Its 2,588 prepared source/configuration inputs match the
current native identity map, and its 12 tool identities match the repaired test
map. Raw build events and log are retained compressed here. The compiler hash
is the repaired test's prepared/postflight identity, not a binary attestation.
Integration has no installed compiler or adapter; no integration-binary
execution claim is made.

- Parser SHA256: `036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`.
- Compiler SHA256: `807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`.
- Adapter SHA256: `0d7900091323ec642d58f1cc53df1db73a1b6b477aaec3784d6aede0ee15b751`.

`per-id-resolution.json` is the exhaustive disposition, including exact defining
method, dependency reason, repository Python import closure and actual evidence
run. `raw-success-origins.json` preserves parsed outcomes from the actual raw
logs. The independent static inventory matches both the original census and
the earlier independent AST inventory. It preserves the five inherited Array
report methods and nine imported `tests.test_shared_bindings` aliases as distinct
IDs; all imported shared-binding aliases require the fresh compiler results.

## Dependency findings supporting retention

Method AST equality alone is insufficient. The reviewed dependencies include
imports, shared helpers, actual source copies, generated fixture inputs, projects,
tools and configuration. Conservative Python import closures are byte-identical
to the accepted baseline. Runtime data dependencies were inspected separately:

- Argument normalization compiles an explicit seven-file project: one literal
  generated main and six unchanged runtime files. It excludes the parser.
- Library-report, report-projection and image-model probes compile explicit
  unchanged mains and Ada `with` closures. The reconstructed closures match the
  prior independent record and exclude `silver_output_profile.adb`. SPARK/native
  library inputs are covered by the native-build identity map.
- Two retained adapter methods use unchanged adapter/vendor failure and help
  paths on synthetic models. Compiler-consuming adapter methods are fresh.
- Evidence, provenance, development and run-history fixtures substitute ROOT,
  PROOF, HostLayout, tools or native runner calls. Production copies are unchanged
  GPRs, scripts and runtime/image/vendor bindings. The false-static-contract
  probe has a synthetic Ada project and the retained native toolchain.
- LeanRunHistoryTests aliases the unchanged LeanRunnerPhaseTests fixture. Native
  Lean fixtures copy unchanged AxiomAudit, binding modules, lakefile and pin,
  with synthetic source bytes; they do not copy the repaired parser.
- Nine retained Lean-source methods inspect unchanged generator literals,
  bindings/lake metadata or the fixed Lexical, Admission, Cursor, SourceLexer,
  CertificateWitness and AxiomAudit chain. The seven production-source or
  inventory-policy methods have fresh results in the repaired run.
- Capacity-envelope arithmetic uses unchanged report/platform constants. The
  independent Boolean task oracle reads unchanged sample expectations without
  invoking the compiler.
- Three retained installation methods avoid the changed worker helpers and full
  production Lean copy. The original symlinked-TMPDIR wrapper and its twelve
  nested bodies need fresh evidence on the repaired production input tree.
- Three Rosetta outcomes apply to the current unchanged render/assessment inputs
  only. All three need fresh results after the promotion patch.

## Shared helper repairs

`helper-normalization-resolution.json` repeats only the earlier static
whole-module AST normalization against original snapshot
`c437a41d30dbdbd174773cab1f5d647dc6e7bbf3`. It reverses exactly the approved
watchdog edits: LeanModuleTests.lake's keyword-only default 60 and forwarding,
the chunk method's explicit 180, the platform inner constant replacing 60,
and the outer wrapper's 180-to-900 change. Both complete normalized module ASTs
equal the originals. The other two LeanModule methods still use default 60;
the three retained installation methods do not use the altered worker helpers.
The repaired chunk method's success comes from its own repaired-input fixture.

## Identity checks and retained chunk

The main audit verifies the original retained compressed payloads, all 34 indexed
repaired-run payloads, and the archived chunk fixture. It reconciles the original
1,031 prepared inputs, 2,588 native build inputs, 14 native/compiler/adapter records
and two Lean/Lake records with earlier independent evidence and live current
hashes. Changed parser/compiler records are preserved as changes; their old
compiler-consuming outcomes are not reused.

The historical maps have three stages. Original prepared bytes are the prior
independent audit's `old` values; its accepted checkpoint is `current`; the new
packet's `previous` equals that accepted `current` on all 1,031 rows. Ten earlier
proof/watchdog changes distinguish the original and accepted maps. The first
script incorrectly compared `previous` to `old` and stopped after completing
the tracked-byte comparisons. `audit-script-correction.json` records the repair;
`original-to-accepted-identities.json` binds `old` to the original raw prepared
event and preserves every earlier difference. Nothing is relabeled unchanged.

All 1,115 repaired-run prepared/postflight rows and 13 tool entries are rehashed.
`selector-membership-resolution.json` independently enumerates each declared
selector with the exact scripts/dev.py hash_paths rules: recursively select
files for directories, exclude __pycache__, and resolve paths. Its resulting
set equals the prepared input keys, with no additions or omissions.

Chunk run `20261108T065724-7d260468ca14` remains applicable on its 20 exact copied
inputs in both current worktrees. Its unchanged archived bundle has 60 members,
3,032,373 bytes and SHA256
`b576f78b7ab40dc4dc3e618999e47f34fbcead11e904ffae89501c01082613e7`.
Every archive member is reconciled with the retained file. The successful result
contains one method, eleven edits, 25 builds and twelve fresh audits, with no
errors, failures or skips. The fixture is not rerun.

The original fixture already retained a successful 18,381-entry Lean distribution
verification against inventory SHA256
`400788b072dcfcf616681a4cf17902e85c3a9ab78df144661acc6966c2459f65`.
This review preserves that historical result and freshly checks the scoped
Lean/Lake executable identities and 20 fixture inputs. It does not claim a new
whole-distribution rehash or impose a new broad attestation requirement.

## Pending work and reporting limits

The failed repaired run remains failed. Its three TimeoutExpired outcomes are
pending, as are the original platform wrapper and twelve nested bodies. Fresh
successes do not turn that run into a successful suite. The native/Lean complete
runs and future Rosetta promotion are separate requirements owned by the
coordinator. This review neither launches nor interrupts them.

Selected reviewer: GPT-6 Astra / Extra High for this bounded inventory audit.
Runtime model/effort telemetry, token/cost measurements and a complete elapsed
review measurement are unavailable. This does not claim a live switch to the
owner's newly selected Astra / Max for future critical proof work. Actual host:
Linux x86-64. Live goal is null; CLI memory is not updated. No production/config
changes, signals, leases, caches, publication or merge are part of this audit.
