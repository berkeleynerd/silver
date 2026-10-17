# Unbounded programs

**Scope proposal, 2026-10-17; not an admitted capability.** At the owner's
request, this record turns a research-backed proposal into
[milestone 5](https://github.com/berkeleynerd/silver/milestone/5) and its
work packages. The owner's direct request authorizes only
[scope work #87](https://github.com/berkeleynerd/silver/issues/87): this
document, its evidence record, the roadmap order, the milestone and the issues.
Implementation packages #88–#94 remain Backlog until the owner says "proceed"
and a dated [session-memory](session-memory.md#2026-10-17--unbounded-programs-scoping-requested)
entry on `main` records it. That "proceed" also confirms the reading of the
[full stops](#full-stops) below. [language.md](../language.md) and the
[catalogue](../catalogue/silver.json) continue to describe current support.

## Goal and owner direction

The owner wants Silver without "unadjustable or unnecessary arbitrary limits".
The owner asked for "the most expansive, expensive, and best option research can
prove is tractable in every case", without option menus, and for any full stop
to be reported. Compilation should "fail through resource exhaustion, which is
acceptable in this profile, rather than a safe lower limit with a thousand knobs
unless that is truly the only way". A fixed limit remains only where it is truly
the only way: a hard limit of a pinned tool that would otherwise make an admitted
program fail, or inherited Ada/SPARK meaning.

The owner also directed that, once the compiler's assurance is established,
running GNATprove on each program "should be nothing more than a safety check
with any failure a bug report". Compilation becomes verified admission plus
build; the universal assurance argument carries the guarantee.

The [Oracle](../oracle.md) supports this model without amendment. "If it
compiles, it proves" is a universal property whose guarantee "must be proved for
the language and its composition rules"; Lean is approved for the "completeness
of automatic obligation discharge"; a rejection or proof failure of a valid
program is an implementation defect; and implementation resource limits must be
explicit with their purpose documented. [language.md](../language.md) already
treats sufficient host resources as an operational premise.

Research cannot prove that the pinned provers complete every admitted program's
obligations "in every case". That remains an explicit
[trusted premise](#trusted-premises), as it is today, and every confirmation tests
it.

## Full stops

- **No Oracle amendment is needed.** The kept language limits are pinned-tool
  maxima or inherited Ada meaning, and the resource-outcome model follows the
  Oracle's existing text.
- **Procedural step.** Implementation starts only after the owner's "proceed" is
  recorded in a dated session-memory entry on `main`.
- **Research-recorded items, resolved here:**
  - The native-capacity track would have kept the 4096-byte, 64-leaf and
    63-operator membership limits until solver completion was shown for unbounded
    programs. Confirmation no longer gates builds, so a non-proof becomes an
    inconclusive or defect report, never a rejected or failed compilation; the
    solver premise is stated explicitly.
  - The tool-limits track described the frontend rules as an amendment. They are
    explicit pre-1.0 language rules, documented as tool-derived, not an Oracle
    change.
  - The proof-scaling track asked whether to give up reproducible step limits.
    Confirmation runs uncapped with racing provers; since it no longer gates
    builds, the variation affects only which prover proves a check.
- **Conditional full stop.** If confirmation ever finds a definite non-proof with
  resources remaining that cannot be fixed, work stops and the owner decides on the
  narrowest assurance-motivated rule. Nothing is pre-decided.
- **Forced, not chosen.** The total-source rule is derived from GNAT's fixed
  internal tables and source-position space (see
  [pinned-tool limits](#pinned-tool-and-inherited-language-limits)). It may be well
  below 2^31 bytes.

## Design

### Compilation and confirmation

| Step | Role | Failure meaning |
| --- | --- | --- |
| Admission (`silver check` and the first step of every command) | Verified, decidable membership by explicit rules | Status 2 only for nonmembership or a usage error |
| Build (`silver compile`, `silver run`) | GNAT/GPRbuild compile of the admitted bytes with the identity-checked runtime library | Frontend rejection of admitted source or a failed build is a defect (status 3); exhausted resources give status 4 |
| Confirmation (after `silver compile` by default, or `silver confirm WORKSPACE`) | GNATprove proves Main and the six identity-bound runtime library files as today (`-U`); the report audit applies the existing exact policy to the Main report and all four library-unit reports | Never removes or blocks the built executable; outcomes are classified below |

- `silver compile` admits, builds and prints the executable path, then confirms
  unless `--no-confirm` is given.
- `silver run` admits, builds and executes the program without confirming.
- `silver confirm WORKSPACE` confirms the exact `main.adb` and library snapshots
  of a printed build workspace. It rechecks their identity with the compiler
  before and after GNATprove, so the confirmed bytes are the built bytes, as the
  Oracle requires.
- Confirmation has no time limit. An interrupt ends GNATprove, and the driver
  reports "not confirmed" without changing the build status or the executable.

The SPARK `Publish` contract changes to state that publication follows admission,
build and identity checks, and that a "confirmed" report follows only an audited
report. Bootstrap continues to bind the library bytes to the compiler by embedding
them; it does not prove them, so confirmation keeps proving them.

"If it compiles, it proves" then rests on the universal Lean argument and the
explicit trusted premises, and every confirmation checks them for its program.
Executables keep GNAT's run-time checks (`-gnata -gnato`), so a violation that the
argument missed fails with an exception instead of misbehaving silently.

### Outcomes and exit statuses

| Status | Meaning |
| --- | --- |
| 0 | `check`/`catalogue`: admitted or exported; `compile`/`run`: admitted and built (`run` then forwards the program's own status); `confirm`: confirmed |
| 1 | `run` only: forwarded from the program (Reject, an output failure, or the program's own `Storage_Error`) |
| 2 | Rejected: the source is not Silver, or the command line is invalid |
| 3 | Defect: a toolchain, implementation or infrastructure failure, including frontend rejection of admitted source, or a defect outcome from `silver confirm` |
| 4 | Resource exhaustion of the compiler or its tools (memory, time, disk, stack, process or operating-system limits), or an inconclusive outcome from `silver confirm`; the source remains admitted Silver and nothing is reported as success |

Today an unhandled `Storage_Error` in the compiler exits 1, which `silver run`
also uses for the program's own Reject. Status 4 removes that ambiguity for the
compiler.

Today's process boundary cannot observe these causes: tools run through `system()`,
GNAT `Spawn` reports a failed `execve` (including `E2BIG`) as 1 and a signal death
as −1, and Silver's own I/O does not read `errno`. #88 therefore adds explicit
observation:

- Decode `system()` wait statuses, documenting how `/bin/sh` and `alr exec`
  propagate a child's signal.
- Read `errno` after Silver's own failed I/O to separate `ENOSPC`, `EFBIG`,
  `ENOMEM` and `EMFILE`.
- Replace or supplement `Spawn` for `silver run`, so a spawn `E2BIG` (beyond the
  OS argument limit) is status 4.
- Add a top-level `Storage_Error` handler to `silver.adb` and
  `silver_image_adapter.adb`.
- Run the driver under a supervising parent that maps its own `SIGKILL`,
  `SIGXCPU` and `SIGXFSZ` deaths to 4, or document those deaths as uncaught
  environmental terminations.
- Classify an ambiguous tool failure, such as a GNAT bug box reporting
  `Storage_Error`, as 3 unless a rule marks it as resource exhaustion.
- List every new libc import in [trusted-boundary.md](trusted-boundary.md).

| Confirmation outcome | Condition | Result |
| --- | --- | --- |
| Confirmed | Some prover proved every check and the report audit accepted all five reports | Recorded with the per-check prover results |
| Inconclusive | Every unproved check ended only through attributable resource exhaustion (an `OutOfMemory`, `Timeout` or `StepLimitExceeded` answer, or a prover the driver observed killed by `SIGKILL` or `SIGXCPU`); a recorded [confirmation-only tool limit](#confirmation-only-tool-limits) was reached; or the run was interrupted | Status 4 from `silver confirm`; environmental |
| Defect | Some check had no proving attempt and at least one attempt ended in `Unknown`, `Invalid` or a crash not attributable to resources; or the report audit rejected a report | Status 3 from `silver confirm`; a bug-report bundle with the source, reports, tool identities and commands |

A defect takes precedence over an inconclusive result.

### Confirmation prover configuration

Confirmation keeps `-U --mode=all --report=all --checks-as-errors=on
--no-loop-unrolling` and the mode's `--warnings` setting, drops `--level`, and
removes every per-check cap:

```text
--prover=cvc5,z3,altergo --timeout=0 --memlimit=0 --steps=0
--counterexamples=off -j<max(3, available CPUs)>
```

- `--level=2` silently keeps a 1,000 MiB address-space limit on every prover,
  even with `--memlimit=0`. Without `--level`, `--memlimit=0` removed the limit in
  a small probe, except for one trivial-goal attempt that still recorded
  1,000 MiB. #88 confirms this on real programs.
- An explicit `-j` of at least 3 lets the three provers race on each check, and
  the others are interrupted when one proves it. So a prover that never finishes
  cannot hold up a check that another prover proves. A check on which no prover
  finishes holds its slots indefinitely, and confirmation then ends only through
  interruption or host limits, as an inconclusive outcome. `-j0` would run the
  provers in turn on a single-CPU host.
- A finite `--steps` must never exceed 5,368,146: above that, Z3's resource
  limit wraps modulo 2^32 and silently becomes a different, usually much smaller,
  limit.
- The driver re-executes itself once with `RLIMIT_STACK` raised to the hard
  limit (or the recognizer uses explicit heap work stacks). GNATprove, GPRbuild
  and the Image adapter inherit that limit; gnat2why otherwise inherits an 8 MiB
  stack and fails on deep nesting.
- Classification reads each report's `unproved_status` together with its
  per-prover `check_tree` results, because GNATprove reports a crashed or killed
  prover as `gave_up`, like a genuine `Unknown`.
- On Linux the driver sets `oom_score_adj` to 1000 for confirmation children, so
  that on a shared host the kernel's out-of-memory killer selects them first. This
  needs no privilege and is not a limit.
- After a not-confirmed outcome the driver prints the paths and sizes of retained
  `program-*` and `imagews-*` workspaces, so repeated large confirmations cannot
  fill a disk unnoticed.

## Limits

### Removed limits

| Limit today | Location | Replacement | Package |
| --- | --- | --- | --- |
| Source length 1–4096 bytes | [language.md](../language.md#source-and-lexical-rules), both profile recognizers | The derived source rule below | #91, #92 |
| 63 operators per program | [language.md](../language.md#common-string-expressions), `Work_Tail`/`Within_Work_Budget` | None | #92 |
| 64 leaves per expression | `Max_Expression_Operands`, `Max_Operands`, catalogue `max_expression_operands`, `max_operands`, `max_dynamic_references` | None | #92 |
| 341 binding slots (`Max_Source_Length / 12`) | `src/silver_output_profile.ads`, `src/silver_scalar_expressions.ads` | Sized from the input | #89 |
| 16 MiB retained report buffer, `Natural`-indexed report storage | `Silver_Report_Storage`, `Max_Report_Length` | 64-bit-indexed or streaming report audit, bounded by host resources | #89 |
| 16 MiB file reads and writes; an oversized source reports Rejected | `Silver_Platform.Max_File_Length`, `Read_File`/`Write_File` and their ghost arrays, the snapshot length check in `src/silver.adb` | Growable reads and writes with ghost sequences; no read or size failure maps to status 2 | #88, #89 |
| 4,096-character name bound in the report policies | `src/silver_library_reports.adb:1213`, `:2088`, `scripts/check_evidence.py` | The identifier rule below | #89 |
| Numeric exponent at most 4096 | [scalar numerals](../language.md#immutable-integer-expressions-and-comparisons), [length literals](../language.md#integer-literals-in-length-predicates), `Max_Exponent` | The pinned maximum 799,999 | #92 |
| String value, output and argument lengths of 4096 bytes; length literals 0–4096 | `Silver_IO.Max_Length`, `Silver_Path_Facts.Max_Length`, catalogue `max_argument_bytes` | `Integer'Last`, which is 2,147,483,647 on the pinned target | #93 |
| 100,000 prover steps and 1,000 MiB per prover | [src/silver.adb](../src/silver.adb) proof command | None during confirmation | #88 |

Today the value 4096 serves the source, String value, argument, output and
length-literal roles through several constants that are not tied to one another:
`Max_Source_Length` in both profiles, `Silver_IO.Max_Length` and
`Silver_Path_Facts.Max_Length`. The String value domain is also enforced partly
through `Max_Source_Length` itself. Separating those roles is the first step of
#89 and #90.

### Pinned-tool and inherited language limits

These remain as explicit, decidable rules, documented as the pinned GNAT 16.1
frontend's maxima or as inherited Ada meaning rather than as Ada requirements:

| Rule | Value | Evidence |
| --- | --- | --- |
| Physical line width, with each horizontal tab expanded to the next multiple of 8 columns | At most 32,765 columns | 32,765 is accepted with LF, CR, CRLF or no terminator; 32,766 gives "this line is longer than 32766 characters". A 39-byte program line padded with tabs is accepted at 4,130 bytes and rejected at 4,131. |
| Identifier length | At most 4,096 characters | 4,097 gives "Name buffer overflow; Max_Length = 4096" and a GNAT bug box (`Program_Error` at `namet.adb:141`) in every tested role and mode |
| Numeric literal exponent | At most 799,999 | 800,000 gives "exponent too large" in every tested base (2, 10 and 16) and mantissa; GNAT's scanner source confirms the check |
| Total source length | The smaller of two derived bounds, given below | Forced by GNAT's fixed internal capacities |
| `Integer` range; String length at most `Integer'Last` | Inherited | Exceeding them would change inherited Ada meaning, which only an Oracle amendment could allow; this milestone does not propose that |

The total-source rule is the smaller of:

- **The source-position bound.** GNAT places every unit of one compilation in a
  single 2^31 source-position space with 4 KiB alignment, so the maximum for
  `main.adb` depends on the other units loaded. The bound is 2^31 − 1 minus a
  stated upper bound on all other units and alignment, in null and output modes.
  2,130,706,432 bytes (2^31 − 2^24) is the largest accepted size tested, leaving a
  16 MiB margin; 2,147,483,647 bytes crashes `gnat1` with heap corruption, and 2^31
  loops indefinitely.
- **The internal-table bound.** This is the largest size for which no GNAT internal
  table can be exhausted: 100,000,000 Names, Lists, Elists, Elmts, Strings and
  Ureal entries, about 1.5e9 Uints and 2,000,000,000 nodes. It is derived from the
  maximum number of table entries per source byte. The tables were not probed. The
  research estimates the List cap near 50 million `elsif` arms, a source of about
  1.5 GB that needs about 44 GB of memory, and `table.adb` does not check overflow.
  A host-independent premise is therefore not acceptable.

#91 derives both bounds, re-derives them whenever the runtime library or
toolchain changes, and adopts the smaller as the rule. It may be far below 2^31.

### Confirmation-only tool limits

These bound confirmation, not compilation, and are recorded with their purpose:

- **Image node counter.** The producer's counter is 2^31 − 1. At about 25–52 node
  identifiers per source byte, it is reached near 40–80 MB of source, through a
  model of more than 100 GB, so host memory normally runs out first. Exceeding it
  is an inconclusive confirmation that names the limit. #89 widens the adapter's
  own node identifier to the 63-bit byte-count range; that does not lift the
  producer's counter.
- **Report writer.** If GNATprove's report writer is limited to about 2 GiB through
  `Natural`-indexed strings, that is another confirmation-only limit. Measured
  reports are 19–350 bytes per source byte, so it would be reached at about
  6–115 MB of source. #89 verifies the writer from producer source and records the
  outcome.
- **JSON nesting depth.** It is 64, fixed by the report schema, and does not grow
  with programs.

Retained implementation capacities that do not grow with the program are also
recorded with their purpose:

- The runtime-library and null-program reports, bounded at 262,144 bytes, and the
  16,384-byte runtime library files are fixed inputs, re-derived when the runtime
  changes (#93).
- Paths of 4096 bytes and command text of 16,384 bytes are OS-derived
  infrastructure. Exceeding them is status 3, never a membership decision.

### Trusted premises

- **Solver completion.** For every source schema accepted by Lean's
  endpoint-discharge checker, some pinned prover proves the generated goal given
  sufficient resources. Under the 4096-byte bound the set of goals was finite. It
  is now unbounded, so this is a stronger assumption, resting on the solvers
  acting as decision procedures for range, length and overflow schemas (linear
  integer arithmetic over intervals, plus bounded nonlinear goals for products).
  Every confirmation tests it, and it can no longer make a build fail.
- **Frontend acceptance.** The pinned frontend accepts every source that
  satisfies the explicit rules, including the derived total-source rule. This is
  supported by GNAT source review and differential tests rather than proof.
- **Existing producer premises.** Faithful static evaluation, complete obligation
  and report generation, accepted producer shapes and the per-program Image
  translation premises in [trusted-boundary.md](trusted-boundary.md) remain. They
  were previously checked for each program by the gating proof and report audit;
  confirmation now checks them without gating, and a confirmation that contradicts
  one is a defect.
- **Resource outcomes.** The compiler, tools and operating system may exhaust
  resources. That outcome is reported distinctly, and is never nonmembership,
  success or publication of an unbuilt program.

Prover incompleteness — a definite non-proof with resources remaining — is not
covered by any premise. It remains an implementation or toolchain defect under the
Oracle and, if it cannot be fixed, a [full stop](#full-stops).

## Research evidence

Five read-only research tracks ran on 2026-10-17 on the Linux x86_64 host
(22 CPUs, 31 GB RAM, no swap), using the pinned toolchain and scratch workspaces.
The [evidence record](evidence/unbounded-programs/scoping-research.json)
summarizes their measurements. The raw notes, scripts, generated programs and
reports are retained locally in `tmp/unbounded-programs-research/` with a SHA-256
manifest.

| Finding | Class |
| --- | --- |
| Today's uniform length-range schema ⟨L,L⟩ is valid only when 2L ≤ 32,767, so any source or value bound of 16,384 or more makes `Current.uniform_discharge` false. The exact schema S + K·C ≤ V ≤ 2,147,483,647 covers every intermediate. | Proved in kernel-checked Lean probes |
| About 95–96% of the affected Lean declaration groups lift to a symbolic bound unchanged, for example 4,154 of 4,347. Failed declarations were re-added unchecked, so their dependants are checked conditionally. | Proved by kernel-checking each lifted declaration |
| None of the failing proofs is a decidability, termination, uniqueness or fuel argument | Observed: a manual classification of the failing proof terms |
| A resource-indexed tool contract composes with `Current.ToolContract` and is inhabited | Proved in a probe |
| The pinned-frontend limits in the table above | Observed with `gcc -gnatc`. Identifier length was also tested with `-O0` builds and GNATprove check, flow and proof modes, and total size with a 100 MB `-O0` build. GNAT source confirms the line, identifier and exponent checks. |
| `--level=2` keeps 1,000 MiB per prover and `--steps=0` is unlimited | Observed in session files and direct Z3 runs |
| The Z3 step threshold, prover racing and the `gave_up` mapping | Derived from producer source |
| 17 proof runs used the production command with `-j8`; two option smokes varied `--steps` and `--memlimit`. All 16 that completed proved every check, up to 32.5 KB of mixed code (1,011 statements) and 16.3 KB of straight-line code. There was no unproved check, tool crash, hard error or check where every prover failed. Losing-prover attempts ended as "High failure" in 11 of 16 runs, at every size and also with `--memlimit=16000` (likely racing interruptions; not diagnosed). Another prover always proved those checks. | Observed on this host |
| Proof time grows roughly quadratically with source size (fitted exponents 1.82–1.99). Peak gnatwhy3 memory grows with exponent 1.0 for mixed code, 1.43 for straight-line code and 1.98 for dense String copies (the last from two sizes only). Single-threaded gnatwhy3 dominates; the winning prover used at most 1,340 steps. Timings were taken under concurrent research load. | Observed on this host |
| Dense 4 KB code took 23 minutes and 5.9 GiB. The 8 KB dense probe was stopped by its 14 GiB guard after 263 seconds, projected at about 23 GiB. | Observed resource stop |
| The recognizer copies whole binding environments at every loop level: 29 KiB per level at 4096 bytes, about 113 KiB at a 16 KiB limit. Nested-loop stack therefore grows quadratically. Parenthesized conditions also take quadratic time, and `compile` re-parses the source up to six times. | Observed with the production binary and scratch rebuilds |
| `gcc -gnatc` time grows quadratically with sequence length and nesting: 100,000 nested loops exceeded an 1,800-second timeout | Observed |
| The documented report envelope exceeds the 16 MiB buffer above 4,502 bytes of source and reaches `Natural'Last` near 587 KB | Derived from the documented envelope |
| Linux delivers a single argument of at most 131,071 bytes; larger fails `execve` with `E2BIG` | Observed |

These results are scoping research: kernel-checked probes, host-specific
observations and source analysis. They neither validate an implementation nor
establish universal solver behaviour.

## Work packages and order

| Order | Work package | Depends on | Effect on admission |
| --- | --- | --- | --- |
| 1 | [#87 Scope and design](https://github.com/berkeleynerd/silver/issues/87) | — | None |
| 2 | [#88 Proof confirmation and resource outcomes](https://github.com/berkeleynerd/silver/issues/88) | #87 | None; compilation no longer waits for proof |
| 3 | [#89 Compiler storage and complexity that scale with input](https://github.com/berkeleynerd/silver/issues/89) | #88 | None |
| 4 | [#90 Parameterized Lean assurance](https://github.com/berkeleynerd/silver/issues/90) | #88; shares source certificates with #89 | None |
| 5 | [#91 Pinned-frontend and derived source limits](https://github.com/berkeleynerd/silver/issues/91) | Derivations after #87; rules after #89 and #90 | None while the 4096-byte bound remains |
| 6 | [#92 Remove source, operator and expression caps](https://github.com/berkeleynerd/silver/issues/92) | #88, #91, #89, #90 | Admits larger programs |
| 7 | [#93 String and argument lengths up to Integer'Last](https://github.com/berkeleynerd/silver/issues/93) | #89, #90; may run alongside #92 | Admits longer values; arguments over 4096 bytes become valid |
| 8 | [#94 Validation, review and delivery](https://github.com/berkeleynerd/silver/issues/94) | All | Records support |

#89 introduces each separated native constant, including identifier length,
and #90 ties each to its Lean counterpart; #91 uses them. Only one agent writes
a host's proof workspace at a time, and #89 and #90 rebuild the same source
certificates, so they coordinate their checkpoints. Each package leaves the
project valid. The milestone closes only when #94 completes.

## Validation plan

Packages use the focused checks in [development.md](../development.md#proof-loop-and-validation)
and share one complete checkpoint in #94, which revises the checkpoint itself:

- Boundary tests at each explicit limit and one past it: line width, identifier
  length, exponent and the derived total-source rule.
- Universal Lean theorems whose only size hypotheses are the explicit language
  limits and the recorded side conditions (minimum bounds, the order between the
  separate bounds, and V ≤ the pinned `Integer'Last`). A fresh axiom audit allows
  only `propext`, `Classical.choice` and `Quot.sound`.
- A geometric scaling ladder from 4 KiB to 1 MiB for each cost-dominant shape:
  mixed code, straight-line code, dense String copies, deep nesting, long
  expressions and nonlinear product chains. Record the size reached, time, memory,
  maximum steps per goal, report bytes and stack. These costs are records, not
  thresholds.
- Differential fuzzing of admission against the pinned frontend at large sizes,
  extending the [review's harness](reviews/review-b79b986403.md#b1--blocker-admitted-vacuous-scalar-assignments-in-empty-loops-fail-the-pinned-gnat-frontend).
- No incompleteness outcome anywhere in the corpus or the ladder. One that cannot
  be fixed is a [full stop](#full-stops).
- Resource-failure tests under `ulimit -v`, `-s`, `-f` and `-t` and a full disk:
  - When admission or build exhausts a resource, the command never returns 0 or 2
    and publishes no executable.
  - When only confirmation exhausts it, `compile` and `run` keep their build
    status and executable and report the confirmation as not confirmed, and
    `silver confirm` returns 4.
- Exit-status tests for every observation mechanism #88 implements.
- Native macOS re-probes of the tool-derived limits and stack (the macOS hard stack
  limit is about 64 MiB) remain independent and nonblocking.

## Risks and non-goals

- **Confirmation cost.** It grows roughly quadratically; dense 16 KB code
  projects near 90 GiB (a two-point extrapolation). Large confirmations may end
  inconclusive on ordinary hosts, while builds are unaffected. Shrinking the
  context each check carries (for example by splitting Main or by compiler-chosen
  cut points) is a separate design with its own obligations, not part of this
  milestone.
- **Build cost.** It is also superlinear, because the frontend is quadratic in
  sequence length and nesting.
- **Total-source rule.** Derived from GNAT's internal tables, it may be far below
  2^31 bytes.
- **Solver premise.** It is broader and rests on evidence rather than proof. #92
  must cover nonlinear product chains in its scaling ladder.
- **Host safety.** Uncapped confirmation can drive a shared host into the kernel's
  out-of-memory killer. `oom_score_adj` makes confirmation children its first
  choice.
- **Reproducibility.** Racing provers changes which prover proves a check, not
  whether it is proved, unless resources run out.
- **Platforms.** macOS limits must be re-probed; Linux remains primary.

Not included: new language constructs (the [Rosetta stages](../rosetta/progression.md)
remain separate), String values beyond `Integer'Last`, macOS validation as a gate,
and hosted CI.

## Scoping validation

The research workflow and this proposal are documentation and planning. The
scoping probes ran in scratch directories with recorded side effects; one retained
Image-adapter workspace, `.silver/linux-x86_64/imagews-n5nSxf`, remains from a
guard-stopped probe. Three independent read-only reviews checked the drafts for
accuracy, planning conventions and technical soundness, and their corrections are
incorporated. No implementation was changed, and no compiler, Lean or test
validation of an implementation was run. Link, anchor and whitespace checks are
recorded in the [scope issue](https://github.com/berkeleynerd/silver/issues/87)
handoff.
