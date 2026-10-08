# Assurance argument for the initial Silver profile

## Scope and current status

The [Oracle](../oracle.md) requires a language-wide guarantee: every source
admitted by explicit, decidable rules must automatically discharge every required
Bronze and Silver obligation. Prover success does not define membership. A proof
failure on admitted source is a toolchain or implementation defect.

The current [language specification](../language.md) states the admitted syntax,
restrictions and behavior. This document records its assurance argument and
evidence. Future capabilities remain in the [roadmap](../roadmap.md) until they
complete the [admission workflow](../development.md).

The initial SPARK compiler and native proof/build/run pipeline support the
null-only production below. Current validation is recorded in
[proof-workflow.md](proof-workflow.md); the earlier repair baseline is in
[review-repairs.md](review-repairs.md). Pinned Lean 4.34.1 proves
membership, safety of the permitted composition, and discharge of its empty
obligation set. The compiler bridge checks authoritative bytes and the complete
reviewed source token shape, then proves membership equivalence for every
interpretation satisfying the checked definition equations. Interpreting those
equations as SPARK uses the approved front end and GNATprove's checked machine
bounds and contracts. A separate conditional theorem composes the external tool
contracts; it does not verify GNAT, the OS, or an arbitrary Ada front end.

Inherited meanings come from the checked-in
[Ada 2022 Reference Manual](../references/ada/2022/RM-TOC.html) and
[SPARK 16.1 Reference Manual](../references/spark/16.1/docs/lrm/source/index.rst).
The assurance targets are the SPARK User's Guide definitions of
[Bronze](../references/spark/16.1/docs/ug/en/source/bronze_level.rst) and
[Silver](../references/spark/16.1/docs/ug/en/source/silver_level.rst).

## Independent membership rule

Let a source be a finite sequence of bytes. It belongs to the initial profile
exactly when all of the following conditions hold:

1. It contains between 1 and 4096 bytes, inclusive.
2. Its non-comment whitespace consists only of space, horizontal tab, carriage
   return, and line feed.
3. Comments have Ada's `--` introducer and continue to carriage return, line
   feed, or end of file. Their contents consist only of printable ASCII bytes
   or horizontal tabs.
4. The explicit trivia/token grammar removes the permitted comments and
   whitespace and matches the entire following sequence with ASCII
   case-insensitive word equality and whole-word boundaries:

   ```text
   procedure Main is pragma SPARK_Mode ( On ) ; begin null ; end Main ;
   ```

All other bytes, tokens, and token combinations are excluded. In particular,
word tokens must retain their Ada lexical boundaries: removing a separator
between two words does not concatenate them into two tokens. Both occurrences
of the procedure name must be `Main`, ignoring ASCII letter case. No additional
compilation unit, context clause, declaration, or statement is admitted.

This rule is a predicate on source bytes, independent of any invocation or
result of GNATprove. A finite scan followed by comparison with the fixed token
sequence decides it. The source-size limit is an explicit language restriction;
it is not a limit inferred from a prover timeout.

The typed SPARK catalogue drives token comparison and JSON export. Character,
case-folding, comment-ending, and word-boundary rules are likewise shared
between recognition and export. The checked-in JSON is compared with the real
compiler output by the integration suite. The SPARK recognizer has a proved
postcondition equating its result with the independent ghost `Is_Member`
specification. The Lean source bridge checks the authoritative specification and
expression bodies, their typed syntax and precedence, and the denotation of
those expressions. `RecursiveBridge` interprets recursive calls parametrically,
applies the three uniqueness lemmas, and composes the resulting equivalences
with cursor/grammar equivalence in the final source theorem. A complete reviewed
token shape fixes surrounding declarations and binding scopes as well as the
selected bodies. The JSON also names the three admitted constructs, their
conditions, token spans, and the sole permitted composition.

## Structural language proof

**Theorem.** Under the inherited Ada/SPARK semantics and the trusted external
toolchain/runtime boundary, every source satisfying the membership rule has the
same user-program behavior as the displayed null procedure and satisfies the
required Bronze and Silver safety properties.

**Lexical step (reviewed Ada correspondence).** Lean proves the custom grammar
and scanner equivalent. Agreement of that restricted grammar with Ada's lexical
rules is the following reviewed argument, not a theorem about a complete Ada
lexer. By membership condition 4, every admitted source has exactly
the displayed token sequence. The other conditions permit only Ada whitespace,
comments, and ASCII case variations, which do not change the meaning of those
tokens. Therefore each admitted source parses as the same single library
procedure body, named `Main`, with no parameters, one `SPARK_Mode (On)` pragma,
one null statement, and a matching named end. There is no second source unit or
additional executable construct hidden in an admitted layout or comment.

**Declaration step.** The procedure declares no objects, types, nested
subprograms, or other runtime entities. `SPARK_Mode (On)` selects SPARK analysis;
it introduces no executable computation. Thus the admitted declarative part
requires no user-code initialization or elaboration operation that could fail.

**Execution step.** Ada's null statement performs no action. Executing the
procedure body reaches that statement once and then returns. There are no
expressions, assignments, parameters, user-code calls, branches, loops, or
recursive edges. Consequently the user program has one execution path and no
value-dependent input domain. Its only argument tuple is the empty tuple.

**Bronze consequences.** No user variable is read, so uninitialized data cannot
be read. No parameters or globals are accessed, so parameter/global interference
and unintended global accesses cannot occur. There are no functions requiring
a function-termination argument; the sole procedure itself also terminates by
the execution step. No relaxed-initialization or exceptional-control-flow
construct can undermine these conclusions because none is admitted.

**Silver consequences.** There is no operation that can raise an unexpected
exception in the user program: no arithmetic, range conversion, indexing,
dereference, assertion, explicit raise, or subprogram call. Hence no source-level
runtime-check obligation can fail. Together with the Bronze consequences, this
establishes the required source-level safety properties.

**Composition step.** The profile permits precisely one composition of semantic
constructs: the library procedure wrapper, its permitted pragma, and its single
null statement. Its declaration and execution steps have already been covered.
Every remaining permitted variation is lexical and preserves this composition
by the lexical step. Thus the proof quantifies over all admitted sources and
all permitted compositions, not merely the checked-in `null.adb` example.

This argument concerns the Silver source program. The GNAT-generated startup,
binder, linker, operating-system interaction, and runtime behavior rely on the
explicit external trust boundary; this document does not prove their
implementations.

## Compiler verification evidence

`Silver_Profile.Accepts` is the actual source recognizer. Its postcondition is
`Accepts'Result = Is_Member (Source)`. The independent ghost specification uses
recursive comment/trivia boundaries, token spans, lexical boundaries, and the
fixed token sequence; it does not call the imperative recognizer. Loop invariants
and contracts establish the connection inside SPARK. The functions specifying
whitespace, allowed bytes, identifier characters, comment endings, case folding,
and word-token classification also have proved numeric postconditions.

`Silver_Numbers.Decimal` now also has a proved exact-value contract. Its ghost
`Represents` relation requires the last digit to equal the value's remainder
modulo ten, the preceding text to represent the quotient, and the empty prefix
to represent zero. This is positional decimal identity, without a saturating or
overflowing parser. The postcondition additionally forbids leading zeroes except
for a one-character result and retains the original length/digit bounds. The
full `Natural` input domain and the fixed-width reverse algorithm are preserved;
GNATprove unrolls its bounded loop and proves all unit checks.

`Silver_Reports.Complete_Null_Proof` has an exact functional postcondition:
its result equals the independent ghost predicate `Recognizes_Null_Report`.
The proofs cover removal of space/HT/LF/CR, quantified occurrence of the eight
required field patterns, and the first SPARK-entity prefix's single-entity shape.
Recursive congruence and helper refinements connect that predicate to the actual
bounded scanner. This is exact report-pattern recognition; the genuine pinned
GNATprove producer and its report schema remain trusted. It does not authenticate
arbitrary JSON or establish report provenance by text matching.

The compiler proof covers bounds, overflow, initialization, preconditions,
postconditions, invariants, and applicable termination checks. All owned entities
must have full SPARK coverage. The eight audited units comprise five
implementation units, two bodyless trusted import specifications, and generated
`Silver_Build`. Eleven reviewed imports have specification-only coverage; their
existing implementation bodies are outside the approved compiler boundary.
See the current [validation record](review-repairs.md) for totals.

The report model and its refinement assertions use SPARK's predefined `Static`
level. GNATprove still verifies their bodies, recursive termination, contracts,
and loop invariants; GNAT omits those mathematical computations from the
executable. The actual bounded report scan and `-gnata`/`-gnato` remain enabled.
The driver checks the report once, retains its Boolean result as a runtime
guard, and has a separate static precondition requiring the semantic report
predicate before build/publication. The report domain remains 262,144 bytes.
The regression suite passes maximum-sized positive/negative reports through the
real CLI and verifies that GNATprove rejects a deliberately false static
postcondition. This is ghost erasure, not removal of proof obligations.

Optional diagnostics describe limitations on using recursive contracts and
numeric-variant expression bodies inside proofs. They withhold information; no
obligation is waived. The evidence auditor counts exactly those documented
limitation codes and rejects failed checks, incomplete coverage, source
suppressions, `pragma Assume`, unapproved external assumption dependencies,
justified obligations, and other warnings. The
[trusted-boundary document](trusted-boundary.md) specifies the exact imports,
contracts, report assumptions, and diagnostic classification.

Reproduce the compiler evidence from the repository root:

```sh
python3 scripts/dev.py prove --full
```

The full validation command supplies the required `SILVER_HOST`, forces unit
analysis, fixes semantic proof options, records parallelism, and audits the result.
A manifest binds all compiler/project/generated inputs, driver scripts, Alire
resolution/configuration, tool identities, and final reports by content hashes.
Before/after fingerprints must agree. SARIF and `.spark` diagnostics must agree
by rule, location and message; the summary must agree with check/entity counts.
No fixed historical check count is used as an acceptance criterion. The project has no
fallback output directory when that host setting is omitted.
The selected host's generated `Silver_Build` specification is included in the
same source-policy and proof-coverage audits as the shared compiler units. Its
constants select native tool/settings/context and output paths. Generated
configuration, Alire state, and compiler outputs belong to that host alone.

The audited regime explicitly selects `--mode=all --report=all
--warnings=error --checks-as-errors=on --level=2 --prover=cvc5,z3,altergo
--timeout=30`, a selected worker count (`-j 0` by default), a native filesystem
solver cache and `-f`. The cache is scoped by host and Alire lock identity;
GNATprove determines reuse for its proof tasks. Existing sessions are also
retained. A full audit therefore does not establish an uncached runtime bound.
Optional `dev.py prove --cold` implies the same full audit with fresh native
output, sessions and solver cache in a unique host-local workspace, preserving
ordinary warm state. It rejects custom `--subdirs` and prints its evidence path.
`--jobs N` controls resource usage. Other exploratory flags belong to
`dev.py tool`; direct exploratory GNATprove calls require an `explore` output
subdirectory and cannot select an audit-managed cache. This catches routine
command mistakes, not arbitrary wrapper behavior. Such runs do not create
audited success evidence. The wall-clock timeout remains machine-dependent;
passing evidence is not a performance guarantee on every host. Before admitting
nonempty user-program obligations, their prover configuration and complete
automatic-discharge argument must be specified together. The normal report
directory is `.silver/<host>/compiler/obj/gnatprove/`; cold runs use the printed
path under `.silver/<host>/compiler/obj/cold-<random>/gnatprove/`.
`gnatprove.out` provides the readable summary; `.spark` and SARIF supply the
machine-audited coverage and individual results. A process exit status alone is
not sufficient evidence.

Without `--full`, `dev.py prove` preserves sessions/reports and allows GNATprove
to skip unchanged units. The same logical options apply, but this incremental
feedback does not establish a newly audited complete report set. Before that
invocation, the selected directory's previous completed proof manifest is
invalidated. Development builds remain independent of proof state; compiler
binary attestation is deferred under the [pre-1.0 policy](../development.md).

## Source identity and automatic program verification

Membership is evaluated on bytes read from the author's actual Ada/SPARK source.
After admission, the compiler allocates a fresh private workspace and writes the
same bytes to `main.adb`. It rereads and compares that snapshot after writing,
after proof, and after compilation. GNATprove and GPRbuild use the same generated
project and the same explicitly named snapshot. The generated project selects
Ada 2022 and enables assertion/overflow checking; it adds no source contracts,
pragmas, or declarations.

These checks have proved contracts. Ghost transcripts record bytes observed by
the actual read/write calls, closure/EOF observations, exact command text, and
returned process status. `Same_Source` establishes equality with the admitted
source from those observations. The driver's ordered proof/build/publication
guards require successful source and project writes, matching snapshots,
successful named tool invocations, and accepted proof evidence before publishing
an executable. These are connected contracts for the real SPARK procedures.
The external filesystem, libc calls, and tool behavior retain their documented
trusted meanings; their implementations are not verified here.

The null program's real GNATprove report confirms one analyzed entity, full
SPARK coverage, completed flow/proof analysis, zero checks, and no skipped or
assumed obligations. These zero counts follow from the admitted semantics.
They are checked alongside coverage so an empty or incomplete run cannot count
as success. Verification failures return an error for an admitted program; they
do not turn the prover into the membership rule.

The regression suite exercises the actual SPARK CLI with case changes, comments,
CR/LF/tab layouts, maximum-length sources, extra constructs, identifier-boundary
errors, forbidden bytes, inaccessible files, and oversized sources. Two real
proof/build/run cases verify snapshot identity, including a 4096-byte variant.
Additional cases simulate external tool failure, incomplete proof reports,
skipped/assumed obligations, and source changes during proof or compilation.
These tests are implementation evidence, not a universal language theorem.

Current regression results are recorded in [review-repairs.md](review-repairs.md).
Platform workers exercise hostile inherited tool settings, symlinked temporary
paths, and preservation of other-host artifacts. Those workers simulate foreign
hosts; only native execution establishes a platform's ABI compatibility. Actual
CLI tests also exercise installation paths containing spaces, quotes, shell
punctuation and Unicode, and invocation from another working directory.

## Mechanical proofs and their correspondence

Lean 4.34.1 is installed by `scripts/bootstrap_lean.py` from a release archive
whose upstream SHA256 is pinned for each supported platform. The version is also
recorded in `proof/lean-toolchain`. The Lake project treats warnings as errors
and has no Mathlib dependency. Declaration checking defaults to one thread per
Lean process as a conservative memory setting; `--threads N` can adjust it.
This default has not been benchmarked against higher thread counts. Lake retains
its native scheduling of independent modules.

Each native host uses its own `.tools/<host>/lean` installation and
`.silver/<host>/proof` replay workspace. The checker copies shared proof inputs
without modifying them and writes the generated candidate certificate only in
that host's workspace. Lake's manifest and objects are isolated there too.
The workspace's sibling `src` link resolves directly to the authoritative
repository `src`, so `include_str` continues to bind the actual SPARK files.
A non-link source directory is rejected; the runner repairs its own outdated
source symlink and verifies that it resolves to the authoritative directory. No global mutable
host selector is used, and other-host or legacy flat artifacts are preserved.
Lean subprocesses discard inherited Lean/Lake/Elan overrides, bind the pinned
native installation explicitly, and use host-local system-config/cache paths.
External artifact restoration is disabled. Local Lake artifacts are preserved
unless `--clean` is requested. A real Lake probe with
poisoned inherited settings selected the same native tools and search paths as
the clean environment and left the foreign-host sentinel unchanged.

`scripts/check_lean.py` checks the pinned version, synchronizes proof inputs,
regenerates candidate source certificates and builds incrementally. It executes
`Silver.Audit` afresh after building, even on a cache hit, and requires every
project module in that audit's actual import closure. `--full` additionally
rechecks exported objects with the pinned `leanchecker --fresh Silver.Audit`;
`--clean` first discards the host workspace and implies `--full`. The imported-module
inventory comes from Lean's actual environment rather than source-text regexes. That audit inspects the transitive
axioms of every declaration originating in a Silver proof module, including
private and generated declarations. It permits only Lean's standard `propext`,
`Quot.sound`, and `Classical.choice` foundations. Unfinished proofs,
project-specific axioms, and native-evaluation trust axioms fail the audit.
A successful replay writes `.silver/<host>/lean-proof.log` and
`.silver/<host>/lean-evidence.json`, recording the version, modules, duration, and input
fingerprints for both shared inputs and the exact workspace copies, together
with the mode and whether a separate kernel recheck ran. Input changes
during replay are rejected; the current host's stale success evidence is removed
before setup or generation begins. Other hosts' evidence is untouched.

The earlier clean replay is recorded in [review-repairs.md](review-repairs.md);
incremental/full workflow validation is in [proof-workflow.md](proof-workflow.md).
Evidence hashes include
the orchestration scripts and verification tools as well as proof/source inputs.

```sh
python3 scripts/bootstrap_lean.py
python3 scripts/check_lean.py --full
```

The proof chain has distinct checked components:

1. `Lexical` and `Admission` define an independent grammar for comments, trivia,
   token spelling and boundaries, and the sole admitted token production. They
   prove scanner soundness/completeness and `accepts_iff_member`.
2. `Cursor` proves that the 1-based cursor specification denotes exactly that
   grammar (`Cursor.isMember_iff`). `Uniqueness` proves that the recursive
   comment/trivia/suffix equations uniquely determine their meanings on the
   verified domains.
3. Handwritten `AuthoritativeSource` fixes the two `include_str` paths to the
   real `silver_profile.ads/.adb`. `SourceLexer` rejects bytes outside HT/LF/CR
   and printable ASCII, including inside comments, and rejects unsupported
   lexical syntax. Generated certificates check each line and reconstruct the
   exact included source. The generator supplies candidates; it cannot choose
   the authoritative binding. Python and Lean enforce the source alphabet.
4. `SourceBridge.CheckedSource` combines lexical certificates, all body/header
   checks, catalogue constants and refinement contracts, and equality with the
   complete checked-in `ReviewedSourceShape`. An added operator, helper,
   context clause, or changed scope cannot hide behind unchanged selected
   bodies. `Precedence` checks grouping; the typed expression model records the
   predefined operator interpretation for the reviewed fragment.
5. `RecursiveBridge` defines `Expressions.DefinitionEquations`, describing the
   checked expressions with
   arbitrary recursive callees. All three uniqueness lemmas are applied to
   derive their cursor meanings and membership equivalence. The final theorem
   quantifies over every interpretation satisfying these equations and retains
   every `CheckedSource` fact. An explicit model witness establishes consistency
   of the equation interface. GNATprove separately proves actual `Accepts =
   Is_Member`, normalization, primitive predicates and machine-bound safety.
   Reading the fixed fragment as these equations uses the trusted Ada/SPARK
   front end and inherited predefined semantics; Lean does not verify GNAT's
   implementation or perform general Ada overload resolution.

6. `Semantics.admitted_assurance` covers every admitted source, every initial
   state, and every execution of its permitted composition. All runs return
   normally with unchanged state and an empty trace. Syntax-directed generation
   yields zero obligations, and a total checker has an explicit one-step
   discharge certificate for them.

The two embedded Ada files are declared as binary Lake input dependencies of
the whole Silver Lean library. Editing either invalidates that entire library's
cached build. Content rehashing detects changed source even if
timestamps are restored; line-ending differences remain significant. A cached
Lean object for different Ada source is not accepted as current evidence. Kernel
regression theorems reject unsupported comment/literal forms and prove
that inserted declarations or a changed size constant alter the complete
reviewed token shape. Python tests reject unsupported bytes before generation
and check that the generator cannot supply authoritative bindings. Candidate
parity is checked separately. These are kernel/source-policy checks, not a
claim that every mutation has been replayed through a full altered-source build.
The shared authoritative files remain untouched by these tests. Fingerprints
record provenance; source equality is established
by the checked certificates themselves.

## Automatic completion and the external boundary

`SupportedTools` states its dependencies as explicit theorem parameters, without
adding axioms. Its operations describe parsing, obligation generation, proving,
building, and executing. Its contract requires faithful parsing of the modeled
Ada production, faithful generation of its obligations, terminating acceptance
of an empty obligation set, terminating compilation, and forward/backward
preservation of the source semantics. The parse-completion premise includes
allowed ASCII bytes. Parsing and compilation use the same source parameter.

`admitted_pipeline_completes` derives completion for every member from these
contracts for this restricted null-program pipeline and the proved
empty-obligation result. It does not assume
that Silver membership directly implies tool success or require a solver
complete for arbitrary SPARK. `supported_pipeline_preserves` and
`supported_pipeline_executes` establish safety and realization of the permitted
execution through that pipeline. `checked_membership_supported_pipeline`
connects source-checked membership to this conditional completion result.

Instantiation for physical GNAT/GNATprove invocations uses the approved external
toolchain and a supported operational environment: matching installed tools,
accessible immutable source/project files, sufficient resources, successful I/O,
and completion of the invoked processes. Runtime startup, linking, libc, and
the OS remain within the explicit trust boundary. The theorem does not establish
those implementations or assert infallibility under tool crashes or resource
exhaustion. Real GNATprove evidence checks positive coverage and empty flow/proof lists;
identifying those records with semantic obligations uses the external tool contract; the driver's proved guards connect observed success to artifact
publication. There is no separate single theorem modeling the entire CLI and OS.

| Claim | How established | Scope and premises |
| --- | --- | --- |
| Decidable membership | Lean grammar/cursor equivalence; checked source shape; applied recursive uniqueness; GNATprove refinement | Fixed compiler-source fragment, interpreted with the approved frontend and checked numeric/normalization contracts. |
| Construct/composition safety | Lean universal execution theorem; reviewed Ada lexical/semantic argument | One null-only composition, unchanged state, no user-level faults. |
| Catalogue correspondence | Shared SPARK rules, Lean source checks, exact JSON integration comparison | Explicit construct metadata and token/byte tables for the sole production; no general serializer theorem. |
| Compiler Bronze/Silver | GNATprove and content-bound coverage/result audit | All owned units; eleven pinned external imports and the documented runtime assumptions. |
| Component functional correctness | GNATprove contracts; Lean recognition bridge | Membership, normalization, decimal rendering, report recognition, I/O observations and ordered driver guards. |
| Source preservation | GNATprove snapshot/transcript contracts; integration tests | Same snapshot around proof/build; immutable project/filesystem and faithful external tools remain premises. |
| Automatic discharge | Lean empty-obligation certificate; conditional external-tool theorem; real report checks | All admitted null-program sources. No claim of a solver complete for arbitrary SPARK or future nonempty obligations. |
| Native support | Native build/proof/tests plus simulated routing tests | Linux results and independently reviewed macOS workflow results have explicit input/mode scope in the workflow record; the newest cold/guard changes await native macOS validation. CI is configured; no remote run exists yet. |

These boundaries do not change membership or waive any obligation. Failure on an
admitted source remains an implementation or toolchain defect. Any extension of
the initial language must extend the catalogue, source correspondence, and
universal composition/discharge arguments before it is admitted.

For a language extension, first specify its constructs, decidable admission and
composition rules, inherited semantics, and generated obligation classes. Select
a decidable obligation language or checked certificate discipline, then prove
generation soundness and complete automatic discharge over the entire admitted
fragment. Update the source bridge and report checker before admitting the new
syntax. Empty-obligation arguments remain valid for the null specialization;
they do not establish anything about future checks. Solver steps/parallelism,
warning policy, supported report schemas and capacity tests belong to that
extension's validation. See [review-repairs.md](review-repairs.md).
