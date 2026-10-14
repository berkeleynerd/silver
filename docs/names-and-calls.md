# Names and Calls

Status: complete on Linux x86-64, 2026-10-14. Baseline `04171a604b`.

This bounded unit completes the context/name and call-association portions of
roadmap items 2, 6 and 7. It changes source spelling and resolution for the existing
operations, preserving their semantics and current placement rules. No Oracle
amendment was made. Current support is specified in [language.md](../language.md).

## Scope and decisions

- Retain each shell's exact imported package set: `Silver_IO` for static bodies,
  and `Silver_IO` plus `Silver_Arguments` for argument bodies.
- Permit order/grouping of context clauses and context `use` visibility for those
  packages, subject to Ada visibility and hiding rules.
- Retain qualified calls and add correctly resolved unqualified existing calls.
- Permit `Item =>` for `Put_Line` and `Default =>` for `First_Or_Default`, retaining
  positional associations. Parameterless operations acquire no argument syntax.
- Keep the immutable argument initializer first and unique.

Ada hides an unqualified `First_Or_Default` inside an object declaration bearing
that same name, including its initializer. The qualified initializer remains
legal. Local `Put_Line`, `Reject` and `Input_Is_Valid` objects likewise hide the
unqualified operations while retaining ordinary String reads and assignments.
Formal labels `Item` and `Default` remain usable even when local objects have
those names. Focused pinned-GNAT probes confirmed these resolution decisions.

## Implementation and assurance

`Silver_Names` implements a bounded, iterative context scanner and operation
resolution for the two existing packages. It uses the established lexical
helpers. GNATprove checks the executable scanner and token matcher against their
functional refinements. The source bound limits repeated clauses; no new clause
count, declaration slot or runtime recursion was added.

The Names Lean model proves cursor bounds and progress, interprets the checked
typed native expression trees, and supplies `modelCalls`/`model_interpreted` as a
simultaneous concrete witness. Source checks cover all eight expression bodies,
declarations, headers, contracts, precedence and local scope; the new spec/body
certificates bind them to the exact Ada bytes. The composed and predicate
bridges carry those calls and their source checks into the existing admission,
semantic and automatic-discharge argument. Existing runtime contracts, report
policies and external-tool premises are unchanged.

Shell uniqueness follows from the successful context scan's imported-package
flag: exactly the argument shell requires `Silver_Arguments`. This replaces the
old fixed-token-prefix auxiliary and works with every admitted clause order.
The public reading-uniqueness, accepted-form-uniqueness and selector statements
are unchanged; the replacement adds no assumptions and passed independent review.

The regression tests pair newly admitted spellings with nearby rejection cases
for package requirements, visibility, hiding, formal names and initializer
placement. Two native compile/run methods exercise local operation names and
the qualified self-hidden initializer; the sample manifest covers the complete
unqualified named-call greeting. Three small parser proof examples exercise
named output and a locally hidden output operation's rejected/qualified pair.

Independent bounded reviews of native/specification/catalogue/test alignment and
the new source-equation witness found no unresolved correctness issue. These
reviews complement the checkpoint; they do not replace its complete proofs.

Three development proof issues were repaired without weakening statements or
accepted axioms. A scalar natural-number termination measure lets the Names
context scanner compute in the kernel; its recursive equations and native
correspondence remain checked. A staged helper proof avoids excessive unfolding
in the composed argument-initializer witness. Finally, explicit tokens for the
three qualified Names callees replace `String.splitOn` in the expression
renderer, which otherwise blocked kernel reduction at the module boundary.
The renderer repair passed five focused kernel probes before repeating the
composed source checks. The unsuccessful attempts and completed caches are
preserved alongside the subsequent validation.

The certificate reproducibility test also caught four stale or placeholder
checked-in candidates. Their already-validated generated copies were retained
in the source workspace and are now checked in byte-for-byte. The parity test
passed after that repair; no proof or test condition was removed. These generated
copies are excluded from the runner's protected shared inputs because every run
regenerates and checks the host-local candidates from the authoritative Ada.

## Validation workflow

Use focused native/model checks and admitted/rejected sibling tests during
implementation. Freeze coupled source/proof inputs before a single complete Linux
GNATprove/build/test and Lean source-correspondence checkpoint with a fresh axiom
audit. Preserve all existing objects, caches, reviews and scratch. Independent
kernel replay, macOS proof work and hosted CI are outside this unit.

## Linux checkpoint — 2026-10-14

Native implementation, focused regressions and complete Lean source/model
validation have passed. The final evidence matches the current implementation
and proof inputs; the test run and focused repairs are distinguished below.

The full Linux GNATprove audit passed **3,163 checks** across 20 units and
313 entities: 572 flow checks and 2,591 proof checks, with no unproved checks.
It reports 80 classified limitation notes and 14 imported entities. This was a
full audited run using existing native sessions and solver caches. Native source
and script inputs remained frozen throughout; concurrent Lean-only edits were
outside its captured input set. The normal provenance audit was rechecked against
the current inputs. Reports and the complete manifest are preserved under
`.silver/linux-x86_64/names-calls-20261014T153711Z/native-reports/`.

The compiler build passed and its catalogue exactly matches `catalogue/silver.json`.
The full suite ran **301 test methods in 1,132.370 seconds**. All but one method
passed; that method reported four certificate-copy parity failures, repaired as
described above. There were no skips or application-test failures. Native,
tooling, test, sample and catalogue inputs stayed unchanged throughout. One
handwritten proof file (`ComposeExpressions.lean`) and four generated certificate
copies changed during the run; the retained before/after snapshots name all five.
This was not a full-suite run over frozen final proof files.

The proof-sensitive recheck ran 61 Lean tests against the frozen renderer fix
and reported only the same parity failure; all **16 platform tests** passed.
After refreshing the four generated copies, all **10 source/certificate tests**
passed in **33.795 seconds**, with no captured input drift. Thus every test method
has a passing result for its relevant final inputs; the original failed runs
remain recorded, rather than being described as a clean 301-test pass.
The complete Lean build then exposed two unnecessary helper applications in
`PredicateFlags.lean`; direct simplification proves the same flag statements.
After that proof-only correction, the ten source/certificate tests passed again
in **32.182 seconds** with unchanged inputs. No native or tooling input changed.
The final selector repair replaces the obsolete fixed-prefix argument described
above. Its isolated proof check and independent review passed before the complete
checkpoint. All ten source/certificate tests passed once more after it in
**31.090 seconds**, with no input drift; the final snapshots are retained in
`source-test-checkpoint/`.
Earlier focused checks passed seven new Names/Calls methods and fourteen affected
existing methods. The full manifest test compiles and runs the new sample along
with the retained samples.

The isolated development builds checked the four affected source certificates:
Names spec/body in 37/351 seconds and Output spec/body in 64/1,106 seconds.
The repaired composed-source check took **1,159 seconds**, followed by its bridge
and concrete model witness. The independent predicate-source candidate took
328 seconds. These timings belong to development lanes with concurrent work;
they are neither cold-build benchmarks nor the final cached audit's duration.

Final integration preserved the previous canonical build and restored 124 coherent
module artifact groups from the development lanes, including private/server
sidecars, IR, hashes and Lake traces. Generated certificate artifacts came from
the validated source lane. Normal Lake rehashing and dependency invalidation
remain required. No certificate check was bypassed and no cache was discarded.

The complete canonical check passed over **252 modules**. Its fresh transitive
axiom audit inspected **56,748 declarations** and found only `propext`,
`Classical.choice` and `Quot.sound`. This declaration count is an axiom-audit
inventory, not an independent kernel replay. The final cached run took
**14.092 seconds**, including an 8.187-second build and 3.498-second fresh audit.
It rebuilt the selector, correspondence, root and audit modules; the earlier
integration runs and development lanes supplied the other checked artifacts.
The final input digest was independently recomputed and matched the evidence.

Evidence is under `.silver/linux-x86_64/names-calls-20261014T153711Z/`: native
reports, `final-tests/`, `proof-test-recheck/`, `source-test-final/`,
`source-test-after-flags/`, `source-test-checkpoint/`, development
logs, the canonical build backup and `cache-reuse.json`. Recovery is recorded in
`tmp/names-calls-active.json`. These are ignored local artifacts; this document
records their scope for other checkouts. Independent kernel replay, macOS proofs
and hosted CI were not run.

## Bounded output capacity — 2026-10-14

Unqualified calls permit more output statements within the unchanged source
bound. A Linux development probe therefore compiled a 4096-byte static program
containing **308 `Put_Line ("")` calls**, using `with Silver_IO; use Silver_IO;`.
The compact shell occupies 84 bytes and each compact call 13 bytes; 308 calls
leave eight padding bytes, while 309 would exceed the source bound. This is the
maximum for that repeated-empty-output shape, not a universal maximum across
all programs.

The ordinary Silver compile succeeded in **6.770 seconds** of measured wall time.
All **44 checks** passed: 13 flow and 31 proof checks across the selected five
units. The Main report contained the expected **1,228 overwritten-output
advisories** and no safety proof records. The report occupied **555,276 bytes
(26.478% of 2,097,152)**, leaving **1,541,876 bytes**. The executable printed
exactly 308 LF bytes and exited 0. The source copied for proof/build was byte
identical to the submitted source, and the existing report audit accepted it.

This is a development measurement, not an isolated performance benchmark or a
universal report-size bound. The large measured margin did not warrant an
additional argument-output run; no dense assignment proof was repeated. Earlier
assignment measurements retain their own source shapes and cannot be read as
maxima for this shorter spelling.

Local evidence is preserved in `tmp/names-output-capacity-jbhm_lp1/`, including
the source, input hashes, complete compiler log and `result.json`. The successful
program directory is `.silver/linux-x86_64/program-3ChsGv/`. These ignored local
artifacts supplement this recorded result; they are not shipped repository files.
