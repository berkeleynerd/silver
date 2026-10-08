# Assurance review repairs

This is the historical repair record for commit `8b8619f`, following the
independent review on 2026-10-08. That commit did not change the then-current
Oracle or admitted Silver language. The Oracle has since been amended with the
owner's approval; current requirements are in [oracle.md](../oracle.md), and
current workflows and platform evidence are in [proof-workflow.md](proof-workflow.md).
The commands, counts and artifact hashes below describe the repair baseline,
not the later proof workflows. Compiler implementation remains SPARK; Python is
setup, proof orchestration, evidence auditing, and test code.

## Source correspondence

`AuthoritativeSource.lean` owns the fixed includes of the actual SPARK profile.
The generator emits candidate certificates against those definitions. Both the
generator and kernel-checked lexer reject unsupported compiler-source bytes,
including VT/FF inside comments. The supported lexical fragment also rejects
percent-bracket strings and ambiguous qualified-character syntax.

`ReviewedSourceShape` records the complete reviewed specification/body tokens.
The final `CheckedSource` theorem requires whole-source equality, not only
selected function-body matches. Additional operators, helpers, context clauses,
or changed declaration scopes therefore require explicit proof changes.

`RecursiveBridge` interprets recursive calls parametrically. It applies the
comment, trivia, and suffix uniqueness lemmas and composes their results into
membership equivalence for every interpretation satisfying the checked body
equations. An explicit model witnesses that those equations are consistent.
The complete source facts are included in the final theorem.

The approved GNAT front end, inherited predefined semantics, and GNATprove's
machine-bound/normalization contracts supply the interpretation of the fixed
SPARK fragment. The restricted Silver-to-Ada lexical correspondence is still
identified as a reviewed argument. These proofs do not implement or verify a
general Ada front end; see [assurance.md](assurance.md).

## Evidence and runtime behavior

The audited compiler proof used a fixed complete-analysis configuration and
forced unit analysis. This regenerated reports while allowing native session
reuse; it did not establish an uncached runtime bound. A content manifest binds
compiler sources, generated configuration, project files, orchestration scripts,
Alire resolution/configuration, concrete
tools/versions, and final reports. Changes during verification invalidate the
run. The project itself must match its reviewed token shape, preventing a new
configuration-pragma file or source-selection override from approving itself.

The auditor compares `.spark`, SARIF, and text-summary coverage and diagnostics,
checks real suppression fields, and resolves assumption dependencies to proved
owned entities or explicitly named runtime interfaces. Historical totals are
not an acceptance threshold. Separate exploratory tool invocations cannot
produce the audited compiler-success manifest.

Lean replay obtains its module inventory from the imported Lean environment,
audits transitive axioms, and runs the pinned independent `leanchecker --fresh`.
Proof evidence also fingerprints the driver scripts, tools, replay inputs, and
resulting objects. Candidate generation must preserve the captured handwritten
proof inputs.

The expensive `Silver_Reports` ghost model and its refinement annotations use
SPARK's predefined `Static` level. GNATprove still verifies all their obligations;
GNAT erases the proof computations from runtime. `-gnata`, `-gnato`, executable
report validation, and the 262,144-byte report domain are retained. The driver
computes the report result once and requires both the runtime Boolean guard and
the static semantic predicate before build/publication. A deliberately false
static postcondition is rejected by the real GNATprove in the regression suite.

## Installation and catalogue

Generated configuration anchors filesystem and shell paths to the installation.
The binary can run from another working directory without selecting that
directory's tools. Fixed shell paths are quoted; only the validated alphanumeric
workspace suffix is appended. The installation-path tests include spaces,
quotes, shell punctuation, and Unicode. Moving the checkout requires bootstrap
and rebuild. Native host outputs remain isolated.

Inherited GPR project/configuration overrides are cleared, and the platform
test fixture canonicalizes symlinked temporary paths. This is targeted tool
selection control, not a fully hermetic operating environment.

The catalogue explicitly records the three admitted constructs, their
conditions and token spans, and the one permitted composition. It retains the
shared token/byte rules and exact compiler-export comparison.

## Validation

Linux ARM64 validation of the final compiler and evidence scripts:

- `python3 scripts/dev.py prove`: **662 checks proved**, comprising 125 flow
  checks and 537 proof checks across eight units and 73 entities. Eleven
  imported declarations remain explicitly trusted. Twelve documented optional
  recursion limitation notes remain; no obligation is unproved or justified.
- `python3 scripts/dev.py build`: passed with runtime assertions and overflow
  checking enabled.
- `python3 scripts/dev.py test`: **61 tests passed** in 13.504 seconds. This
  includes real GNATprove/build/run, exact catalogue export, foreign-CWD and
  quoted/Unicode installation paths, symlinked temporary directories, evidence
  mutations, maximum-size reports, and rejection of a false static contract.
- `python3 scripts/check_evidence.py`: the final content-bound audit passed
  again after the integration tests.
- The focused report proof retains all **256 original obligations** (27 flow,
  229 proof). Its large-report regression exercises both successful validation
  and rejection, including the full declared capacity and overflow detection.
- The original `null.adb` was proved and compiled unchanged in the integration
  suite; its executable returned zero. Its SHA256 remains
  `7b448e583d98d9f037b90d1379fe6afa1a16a93be16a7270c85aed30161a5021`.

`python3 scripts/check_lean.py` passed a clean **Lean 4.34.1** replay,
actual import-inventory check, axiom audit of **3,828 declarations** across
**17 proof modules**, and independent **`leanchecker --fresh Silver.Audit`**
kernel recheck. Total elapsed time was **284.07 seconds** on this Linux
ARM64 environment. Only `propext`, `Quot.sound`, and `Classical.choice` occur as
logical foundations. All captured source/script/workspace/tool hashes remained
stable. The evidence is `.silver/linux-aarch64/lean-evidence.json` (SHA256
`c29ea7c6086f842f33ae3cd3bac667ef1da227eb86ca269e2effade7936f3e07`), with its log at
`.silver/linux-aarch64/lean-proof.log`.

The machine-readable compiler evidence is
`.silver/linux-aarch64/compiler/obj/gnatprove/proof-provenance.json`, with SHA256
`8033dbacd184d5ed16f866ff6664165fb76d1546df1a879bb6a138166f58a156`.
It records GNAT/GNATprove 16.1.0, GPRbuild executable 26.0.0 (Alire release
26.0.1), CVC5 1.3.2, Z3 4.15.4, and Alt-Ergo 2.6.1. Logs are
`.silver/linux-aarch64/compiler-proof.log`, `compiler-build.log`, and `tests.log`.
These local artifacts are ignored by Git; configured CI retains its own
corresponding evidence when the remote repository is available.

## Remaining platform and extension work

At this baseline, the user requested local work because
`github.com/berkeleynerd/silver` did not yet exist. CI was configured but had not
run remotely; no repository was created or published. Native macOS validation
was then pending and nonblocking. Subsequent external reviews validated this
repair baseline and the later staged incremental workflows on macOS ARM64.
See [proof-workflow.md](proof-workflow.md) for the corroborated artifacts,
reviewer-reported results and remaining platform scope. Linux x86-64 execution
remains unmeasured here.

The semantics are a valid specialization for the null-only language, whose
user-program obligations are empty. Before admitting a construct that generates
checks, extend the catalogue, operational semantics, source correspondence,
report handling, and universal automatic-discharge proof together. Use a
decidable obligation language or checked proof certificates, and pin the
user-program prover configuration and warning policy. Compiler proof scheduling
currently retains a wall-clock timeout, so runner performance still matters.
No new language construct is admitted by these repairs.
