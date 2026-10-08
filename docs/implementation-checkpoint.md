# Historical implementation checkpoint

This is the historical checkpoint for the initial compiler milestone. It does
not describe the current assurance repairs; see [review-repairs.md](review-repairs.md). Its flat
artifact paths and command examples predate native host isolation. Use the
[README](../README.md) for current commands and the
[platform coexistence checkpoint](platform-coexistence.md) for the follow-up.

Updated during the 2026-10-08 implementation session. This records final evidence
and preserves the intermediate handoff history. `oracle.md` remains authoritative.

## Final Linux milestone status

Implementation and local validation are complete for the initial null-only
profile on Linux ARM64, within the explicitly approved external-tool/runtime
boundary. The final evidence supersedes the historical intermediate results
below:

- **650 SPARK checks passed:** 124 flow and 526 proof; seven units, 72 entities,
  eleven trusted imports, twelve documented optional limitation notes.
- **22 regression tests passed in 3.425 seconds**, with runtime assertions and
  ghost checks still enabled. The strengthened report contract added no observed
  integration-performance problem for the genuine null-program reports.
- **Clean Lean 4.34.1 replay and axiom audit passed:** fourteen project modules,
  3,616 declarations, 164.579 seconds. Only the three documented Lean foundations
  occur. Exact source certificates and an isolated source-mutation rejection
  check both passed.
- The unchanged original `null.adb` was proved, compiled and run successfully in
  `.silver/program-1l2iH1/`; its SHA256 still matches the value recorded below.
- README, assurance and trust documentation record the final counts and precise
  conditional scope. No single whole-OS/CLI theorem or unrun native platform
  result is claimed. macOS validation remains independently handled as approved.

All three proof workstreams have completed; their checkpoints preserve the
detailed evidence and reasoning needed for future extensions. Final logs are
`.tools/compiler-proof.log`, `.tools/tests.log`, `.silver/lean-proof.log`, and
`.silver/lean-evidence.json`.

## Objective and decisions

Finish the initial Silver compiler for the actual Ada program
`procedure Main is pragma SPARK_Mode (On); begin null; end Main;` and all lexical
variants admitted by the explicit `silver-null-0` catalogue. Membership must be
decided independently of prover success. All Silver compiler implementation is
SPARK, verified to Bronze and Silver. Lean 4.34.1 supplies additional language
and implementation-correspondence proofs, with no unfinished proofs or unproved
project axioms. Preserve the same source through admission, proof and compilation.

Approved external dependencies: GNAT, GNATprove, Alire, OS/runtime libraries.
Linux is primary. Native macOS validation is independently handled, secondary,
and does not block the Linux milestone; this decision is already in the Oracle.
Do not alter the Oracle without explicit user approval or ask for macOS access.

The user resumed implementation and asked to use subthreads to preserve context.
The goal service retained an old `paused` status during that work; following the
successful final requirement audit, the existing implementation goal was marked
**complete**. No replacement goal was created.

## Workstreams and ownership

| Agent | Owns | Next result |
| --- | --- | --- |
| `/root/minimal_feasibility` | `proof/Silver/SourceLexer.lean`, `SourceCertificates.lean`, `Source.lean`, `proof/generate_source_certificate.py` | Finish kernel-checked exact source/token certificates; remove scratch Lean modules |
| `/root/oracle_review` | Remaining `proof/` modules, `scripts/check_lean.py`, Lean setup, `README.md`, `docs/assurance.md` | Complete source bridge/import closure, clean replay, axiom audit, precise final assurance documentation |
| `/root/toolchain` | `src/silver_reports.ads/.adb`, isolated report proof | Prove exact functional report-recognizer contract, freeze source and report results |
| `/root` | Integration; driver/platform; evidence policy/tests; `docs/trusted-boundary.md`; this checkpoint | Final combined proof/build/tests/sample, current counts, requirement audit |

Agent-specific durable notes live under `.silver/checkpoints/`:
`source-proof.md`, `assurance.md`, `report-proof.md`. Agents update their own
notes before compaction. Consult them and live messages before restarting work.
Do not concurrently clean/build the same Lean tree while another agent uses it.

## Environment

Workspace: `/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver`.
Actual execution platform: Ubuntu 26.04 Linux ARM64. Shell: bash.
There is no Git remote or commit; project files are untracked. Do not invent
remote CI results or require a remote to finish local work.

Installed tools: `.tools/alr/bin/alr`, `.tools/lean/bin/{lean,lake}`.
Alire 2.1.1 manages GNAT 16.1.0, GNATprove 16.1.0, GPRbuild package 26.0.1
(executable identifies as 26.0.0). Corresponding major/minor versions must match
across supported platforms; patch differences are approved.
Bootstrap downloads are SHA256 pinned. Host `libc6-dev` is installed.

## Implemented behavior

- SPARK CLI: `silver catalogue`, `check SOURCE`, `compile SOURCE`, `run SOURCE`.
  Run from repository root. Exit 0 succeeds, 2 rejects source/usage, 3 reports
  infrastructure or admitted-program verification/build/execution failure.
- Catalogue: exact 15-token null-procedure grammar, ASCII case variations,
  space/HT/CR/LF and Ada comments; 4096-byte source limit. Everything else excluded.
- `Accepts` has a GNATprove-proved equality to independent ghost `Is_Member`.
- Exact source bytes are written into a fresh `.silver/program-XXXXXX/main.adb`.
  The project explicitly selects that file. Source comparisons bracket writing,
  proof and build. No annotated replacement is created.
- Driver contracts gate proof, build and publication using actual observed
  bytes, actual write results, actual command/status transcripts, accepted proof
  evidence and membership. Valid-command/path preconditions also rule out the
  corresponding local defensive failures on the admitted path.
- Platform ghost transcripts connect the owned loops to real libc calls:
  successful complete reads return exactly `fgetc`'s observed byte sequence,
  with EOF and successful close; successful writes pass exactly the supplied
  bytes to successful `fputc` calls in order and close successfully. `Run` records
  the actual command and `system` status. These are proved observations, not new
  imported assumptions. File/process meanings remain within approved libc trust.
- `Decimal` is proved numerically exact and canonical for the full `Natural`
  domain; the original fixed reverse loop remains.
- Trusted imported specifications remain pinned: 8 existing libc symbols and
  3 existing GNAT argument/exit-status symbols, with no owned external bodies.
- Report checker recognizes the genuine GNATprove 16.1 producer format. It is
  not an authenticator or a general hostile-JSON parser. The active report task
  adds a proved equality to an independent exact format-recognition predicate.

## Last complete native baseline

Before the ongoing report-contract changes, the final driver/platform/numbers
code passed the complete proof and strict evidence audit:

- **449 checks: 102 flow + 347 proof**.
- 7 units, 58 entities, 11 explicitly trusted imported entities.
- 6 documented optional recursive-proof limitation notes; no obligation waived.
- **22 test methods passed**; log `.tools/tests.log`.
- Original `null.adb` proved, built and ran successfully via
  `.silver/program-1ySXNW/`; original bytes remained unchanged.
- Original SHA256:
  `7b448e583d98d9f037b90d1379fe6afa1a16a93be16a7270c85aed30161a5021`.

The full proof log is `.tools/compiler-proof.log`. These counts must be refreshed
after the report agent freezes its changes. The last full native evidence is no
longer evidence for newer report-source edits.

`scripts/check_evidence.py` checks every owned entity, source/report freshness,
individual proof results, SARIF invocation, imports, assumptions/skips and
justifications. It also rejects source-level Assume/Suppress/check-policy pragmas
outside strings/comments. GNATprove can exit 0 with failed obligations; always
run the auditor. The only allowed optional limitation codes are
`contracts-recursive` and `numeric-variant`.

## Current proof work

### Report recognizer

The strengthened report refinement is now **253/253 checks green** (27 flow,
226 proof, 18 entities, six documented limitation notes) at the existing level 2
and 30-second timeout. Equal-string lemmas for substring/recursive scans close
the composed public contract. Strict isolated evidence, source policy and
freshness audits pass. Report sources are frozen; root has started the final
whole-compiler proof/build/integration rerun.
Specification: recursive `Filtered_Prefix`, quantified substring occurrence,
first-prefix/digit-span functions, and public `Recognizes_Null_Report`.
The contract specifies the actual whitespace/pattern recognizer, not JSON
authenticity. The only executable rewrite so far is an equivalent `One_Entity`
while scan and shared whitespace predicate. Check agent notes for current state.

The compiler builds with `-gnata`, which executes ghost checks too. New recursive
report specifications may add runtime cost. Keep the current assertion policy
while measuring meaningful integration behavior; do not silently suppress
obligations or change policy to make results pass.

### Lean

Independently checked modules cover lexical membership soundness/completeness,
cursor equations, expression AST denotations, precedence, recursive uniqueness,
null-program semantics, and conditional supported-tool completion/preservation.
`SupportedTools.Contract` contains explicit generic faithful parsing/generation,
empty-obligation proof completion and semantics-preserving compilation laws.
It does not assume `Member(source) -> proof success`, and does not prove OS/GNAT
implementations or success under unavailable resources.

The remaining source-certificate engineering blocker was kernel memory/time for
whole-file string concatenation. Per-line certificates already checked. Direct
and balanced byte-array joins were expensive (one run interrupted at 259 seconds
and 5.57 GB). The agents found a kernel-checked character-list append theorem;
a 10,450-byte body join checked in 7.2 seconds / 1.3 GB. That technique is now in
the generator. The complete certificate has now **kernel-checked successfully
in 146.2 seconds, with 1.83 GB peak RSS and exit 0**. Both actual source files,
all lexical lines and exact reconstruction are checked. SourceBridge integration
and the final clean full audit remain with `oracle_review`. An isolated negative
check also passed: changing only copied `Max_Source_Length` from `4_096` to
`4_095` made the unchanged certificate fail specifically at source reconstruction
(expected exit 1; 29.47 seconds, 1.05 GB). Original source files were untouched.
Exact evidence is in `.silver/checkpoints/source-binding-negative.log/.json`.
Do not revert to
`native_decide`, project axioms, hashes, or hand-matched models as substitutes.

The generator only proposes literals/certificates; the kernel must check every
line/token relation and exact original-file reconstruction, including final LF.
`include_str` reads the real profile `.ads/.adb` files, so final replay must be
clean. SourceBridge checks actual unique bodies, headers, constants, catalogue,
and refinement contracts against typed, precedence-checked ASTs. Its integrated
kernel check has now passed (8.8 seconds); the required clean full import-closure
build and transitive axiom audit are running under `oracle_review`.

`proof/Silver.lean` currently imports Admission, Cursor, Semantics, SourceBridge.
The final audit must also include all other proof modules (including Uniqueness
and SupportedTools). `scripts/check_lean.py` rejects any project module outside
the `Silver.Audit` import closure. It permits only Lean foundations `propext`,
`Quot.sound`, `Classical.choice`, rejecting unfinished proofs, project axioms,
and native-evaluation trust axioms.

## Final integration sequence

1. Obtain source freezes and successful isolated reports from the report and
   source/Lean agents. Do not duplicate their ongoing work.
2. Confirm all Lean modules are in the audit closure; remove scratch probe modules.
3. Run the native proof, strict audit, build, complete tests and original sample:

   ```sh
   .tools/alr/bin/alr -n exec -- gnatprove -P silver.gpr --mode=all --report=all -j 4
   python3 scripts/check_evidence.py
   .tools/alr/bin/alr -n exec -- gprbuild -P silver.gpr -p
   python3 -m unittest discover -s tests -v
   .silver/compiler/bin/silver run null.adb
   ```

4. Coordinate one clean Lean replay/axiom audit:

   ```sh
   python3 scripts/check_lean.py
   ```

   Expected successful evidence: `.silver/lean-proof.log` and
   `.silver/lean-evidence.json`. A green default build that omits modules does not
   count. If useful, run a source-change negative check in an isolated copied
   tree; never perturb the authoritative profile during another agent's build.
5. Refresh README/assurance/trusted-boundary counts, exact theorem scope and
   remaining platform results. CI already runs native proof/audit/tests and the
   clean Lean audit, retaining evidence. Only Linux ARM64 has run locally.
6. Audit each Oracle/goal requirement. Do not claim a single whole-CLI semantic
   refinement theorem if the result is a composition of recognizer/IO/protocol
   proofs and explicit approved external contracts. Catalogue serialization has
   a complete deterministic output comparison plus shared verified primitives;
   no general serializer theorem is claimed.
7. Mark the goal complete only when required work actually is complete, and give
   the user concise reproducible results with honest scope. No further approval
   is needed for the already-authorized implementation work.
