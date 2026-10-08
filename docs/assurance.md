# Assurance argument for the initial Silver profile

## Scope and current status

The [Oracle](../oracle.md) requires a language-wide guarantee: every source
admitted by explicit, decidable rules must automatically discharge every required
Bronze and Silver obligation. Prover success does not define membership. A proof
failure on admitted source is a toolchain or implementation defect.

The initial SPARK compiler and native proof/build/run pipeline work on Linux
ARM64. The host-isolated build discharged all 655 compiler checks, and the source
recognizer has a proved functional postcondition. The structural argument below covers the
whole initial language. Pinned Lean 4.34.1 proofs establish decidable membership,
composition safety, exact correspondence with the authoritative recognizer
expressions, and automatic discharge of the generated empty obligation set.
A separate conditional theorem covers completion and preservation through
approved external tools. Its tool and operational premises are stated explicitly.

Inherited meanings come from the checked-in
[Ada 2022 Reference Manual](../references/ada/2022/RM-TOC.html) and
[SPARK 16.1 Reference Manual](../references/spark/16.1/docs/lrm/source/index.rst).
The assurance targets are the SPARK User's Guide definitions of
[Bronze](../references/spark/16.1/docs/ug/en/source/bronze_level.rst) and
[Silver](../references/spark/16.1/docs/ug/en/source/silver_level.rst).

## Independent membership rule

Let a source be a finite sequence of bytes. It belongs to the initial profile
exactly when all of the following conditions hold:

1. It contains at most 4096 bytes.
2. Its non-comment whitespace consists only of space, horizontal tab, carriage
   return, and line feed.
3. Comments have Ada's `--` introducer and continue to carriage return, line
   feed, or end of file. Their contents consist only of printable ASCII bytes
   or horizontal tabs.
4. After Ada tokenization and removal of comments and whitespace, its entire
   token sequence, compared with ASCII case-insensitive word equality, is:

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
those expressions. Recursive-equation uniqueness and cursor/grammar equivalence
connect the SPARK specification to independent mathematical membership.

## Structural language proof

**Theorem.** Under the inherited Ada/SPARK semantics and the trusted external
toolchain/runtime boundary, every source satisfying the membership rule has the
same user-program behavior as the displayed null procedure and satisfies the
required Bronze and Silver safety properties.

**Lexical step.** By membership condition 4, every admitted source has exactly
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
GNATprove unrolls its bounded loop and proves all eighteen unit checks.

`Silver_Reports.Complete_Null_Proof` has an exact functional postcondition:
its result equals the independent ghost predicate `Recognizes_Null_Report`.
The proofs cover removal of space/HT/LF/CR, quantified occurrence of the eight
required field patterns, and the first SPARK-entity prefix's single-entity shape.
Recursive congruence and helper refinements connect that predicate to the actual
bounded scanner. This is exact report-pattern recognition; the genuine pinned
GNATprove producer and its report schema remain trusted. It does not authenticate
arbitrary JSON or establish report provenance by text matching.

The host-isolated compiler proof discharged 655 checks: 124 through flow
analysis and 531 through automated proof. This includes bounds, overflow,
initialization, preconditions, postconditions, invariants, and applicable
termination checks. The eight audited units comprise five implementation units,
two bodyless trusted import specifications, and the generated `Silver_Build`
specification. Of 73 reported entities, eleven
are explicitly reviewed OS/runtime imports with specification-only coverage;
their implementation bodies are outside the approved compiler boundary.

Twelve optional diagnostics describe limitations on using recursive contracts and
numeric-variant expression bodies inside proofs. They withhold information; no
obligation is waived. The evidence auditor counts exactly those documented
limitation codes and rejects failed checks, incomplete coverage, source
suppressions, assumptions, justified obligations, and other warnings. The
[trusted-boundary document](trusted-boundary.md) specifies the exact imports,
contracts, report assumptions, and diagnostic classification.

Reproduce the compiler evidence from the repository root:

```sh
python3 scripts/dev.py prove
```

The native development command supplies the required `SILVER_HOST` scenario
value and runs the strict evidence auditor after GNATprove. The project has no
fallback output directory when that host setting is omitted.
The selected host's generated `Silver_Build` specification is included in the
same source-policy and proof-coverage audits as the shared compiler units. Its
constants select native tool/settings/context and output paths. Generated
configuration, Alire state, and compiler outputs belong to that host alone.

The project enables `--warnings=error`, `--level=2`, and `--timeout=30`; no checks
are suppressed. The report directory is `.silver/<host>/compiler/obj/gnatprove/`.
`gnatprove.out` provides the readable summary; `.spark` and SARIF supply the
machine-audited coverage and individual results. A process exit status alone is
not sufficient evidence.

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

The final native regression run passed all 32 tests in 26.401 seconds with the
rebuilt host-isolated compiler and runtime assertion checking enabled. Platform
workers also exercised hostile inherited Alire/Lean settings, native path
selection, and preservation of other-host artifacts. The original `null.adb`
was proved, built, and run successfully; its source bytes remained unchanged.

## Mechanical proofs and their correspondence

Lean 4.34.1 is installed by `scripts/bootstrap_lean.py` from a release archive
whose upstream SHA256 is pinned for each supported platform. The version is also
recorded in `proof/lean-toolchain`. The Lake project treats warnings as errors,
checks declarations sequentially to bound peak memory, and has no Mathlib
dependency.

Each native host uses its own `.tools/<host>/lean` installation and
`.silver/<host>/proof` replay workspace. The checker copies shared proof inputs
without modifying them and writes the generated candidate certificate only in
that host's workspace. Lake's manifest and objects are isolated there too.
The workspace's sibling `src` link resolves directly to the authoritative
repository `src`, so `include_str` continues to bind the actual SPARK files.
An existing divergent source directory or link is rejected. No global mutable
host selector is used, and other-host or legacy flat artifacts are preserved.
Lean subprocesses discard inherited Lean/Lake/Elan overrides, bind the pinned
native installation explicitly, and use host-local system-config/cache paths.
Artifact restoration is disabled for the clean replay. A real Lake probe with
poisoned inherited settings selected the same native tools and search paths as
the clean environment and left the foreign-host sentinel unchanged.

`scripts/check_lean.py` checks the pinned version, regenerates candidate source
certificates, requires every project module in the audit import closure, cleans
before rebuilding, and runs `Silver.Audit`. That audit inspects the transitive
axioms of every declaration originating in a Silver proof module, including
private and generated declarations. It permits only Lean's standard `propext`,
`Quot.sound`, and `Classical.choice` foundations. Unfinished proofs,
project-specific axioms, and native-evaluation trust axioms fail the audit.
A successful replay writes `.silver/<host>/lean-proof.log` and
`.silver/<host>/lean-evidence.json`, recording the version, modules, duration, and input
fingerprints for both shared inputs and the exact replay copies. Input changes
during replay are rejected; the current host's stale success evidence is removed
before setup or generation begins. Other hosts' evidence is untouched.

The isolated Linux ARM64 clean replay passed in 1305.561 seconds. It checked all
14 project proof modules and audited 3,616 declarations. Only the three standard foundations
listed above occurred, including in the actual-source membership, catalogue,
universal assurance, and conditional pipeline theorems. All 136 recorded shared
and legacy proof artifacts, including the shared Lake outputs and checked-in
candidate certificate, retained their exact contents and file set.

```sh
python3 scripts/bootstrap_lean.py
python3 scripts/check_lean.py
```

The proof chain has distinct checked components:

1. `Lexical` and `Admission` define an independent grammar for comments, trivia,
   token spelling and boundaries, and the sole admitted token production. They
   prove scanner soundness/completeness and `accepts_iff_member`.
2. `Cursor` proves that the 1-based cursor specification denotes exactly that
   grammar (`Cursor.isMember_iff`). `Uniqueness` proves that the recursive
   comment/trivia/suffix equations uniquely determine their meanings on the
   verified domains.
3. `SourceLexer` and generated `SourceCertificates` embed the actual
   `src/silver_profile.ads` and `.adb` files. The kernel checks every candidate
   line tokenization, including quoted literals and comments, and a balanced
   composition certificate reconstructs every original byte and final newline.
   The Python generator is untrusted: incorrect candidates fail these proofs.
4. `SourceBridge` matches the uniquely named actual expression bodies to typed
   syntax trees. `Precedence` checks Ada grouping and operator precedence;
   `Expressions` proves the trees' denotations, including the signed arithmetic
   needed for cursor bounds. The bridge also checks exact function headers,
   token enumeration/order/spellings, required tokens, source-size and comment
   constants, the `Accepts` postcondition, and `Normalized`'s byte/length/index
   contract. `authoritative_source_member_iff` includes both complete source
   token certificates and the membership equivalence.
5. GNATprove proves the actual imperative `Accepts` result equals `Is_Member`,
   with no caller precondition. Its checked normalization and numeric helper
   contracts supply the implementation side of the preceding correspondence.
   The approved Ada/SPARK front end supplies the enclosing declaration, type,
   machine-bound, and inherited-language interpretation.
6. `Semantics.admitted_assurance` covers every admitted source, every initial
   state, and every execution of its permitted composition. All runs return
   normally with unchanged state and an empty trace. Syntax-directed generation
   yields zero obligations, and a total checker has an explicit one-step
   discharge certificate for them.

A clean build is required because the source bridge reads Ada files outside the
Lake tree. A cached Lean object is not evidence for changed Ada source. An
isolated negative check changed the actual specification's size literal from
`4_096` to `4_095` while retaining its original candidate certificate. Lean
rejected the exact source-reconstruction theorem. The shared authoritative files
were untouched. Fingerprints record provenance; source equality is established
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
general tool laws and the proved empty-obligation result. It does not assume
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
exhaustion. Real GNATprove evidence checks positive coverage and the exact empty
obligation set; the driver's proved guards connect observed success to artifact
publication. There is no separate single theorem modeling the entire CLI and OS.

| Claim | Checked evidence and explicit scope |
| --- | --- |
| Decidable source membership | Independent grammar/scanner equivalence, cursor equivalence and recursive uniqueness, exact authoritative-source expression checks, and the actual GNATprove `Accepts = Is_Member` refinement. |
| Construct/composition safety | Universal state/execution safety and finite execution for the source production selected by the checked grammar; semantic clauses are the inherited Ada/SPARK clauses identified above. |
| Catalogue correspondence | The finite, no-input catalogue exports shared source-checked token/byte/case rules. Every exported table and the checked-in JSON are compared exactly; decimal rendering has a proved exact-value contract. This covers the current finite catalogue without claiming a general JSON-serializer theorem. |
| Compiler Bronze/Silver assurance | All 655 checks discharged in the host-isolated build; full coverage audited with eleven explicitly trusted imported entry points. Native results presently cover Linux ARM64. |
| Compiler functional correctness | Recognition and normalization refinements, exact decimal rendering, exact report-pattern recognition, observed I/O/command transcripts, and ordered proof/build/publication guards. These are component contracts for the actual implementation, composed with the stated external-tool laws. |
| Source preservation | Proved snapshot equality and read/write transcripts bracket proof/build; publication requires the successful ordered guards and the same source. Physical file persistence and faithful tool use of the named immutable project remain external premises. |
| Automatic discharge | Zero generated obligations and a terminating discharge certificate for every member; conditional completion/preservation through supported external tools; real positive-coverage GNATprove reports check the same zero obligations. |
| Native platform support | Portable Alire setup and CI cover Linux/macOS, ARM64/x86-64. Linux ARM64 has run locally. Linux x86-64 and native macOS remain unrun configurations; macOS validation is independent and does not block the Linux milestone under the Oracle. |

These boundaries do not change membership or waive any obligation. Failure on an
admitted source remains an implementation or toolchain defect. Any extension of
the initial language must extend the catalogue, source correspondence, and
universal composition/discharge arguments before it is admitted.
