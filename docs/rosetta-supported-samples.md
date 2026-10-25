# Rosetta samples for the current language

## Scope and selection

The owner authorized [#9](https://github.com/berkeleynerd/silver/issues/9) in
[PR #220](https://github.com/berkeleynerd/silver/pull/220), on main at
`7a2fb0b70a`, and explicitly selected its delivery on 2026-10-24. This delivery
covers the issue's original 31 tasks. The rendered progression now lists 35
baseline tasks because four drivers were delivered in earlier language milestones;
those additions do not enlarge this issue's scope.

The captured `task.wiki` requirements, current [language](../language.md), and
existing sample checks determine the selection. Assessment labels such as
“likely” are proposals, not admission or task-completion evidence. Fourteen tasks
have executable regressions, fourteen are prose/tooling answers or explicitly
omittable, and three are excluded as described below. Existing `null.adb` serves
the empty program; the other selected tasks have dedicated source files.

No construct, admission rule, capacity, tool pin or Oracle guarantee changes.
All selected source fits the current 4,096-byte bound. Samples exercise existing
rules; the [assurance argument](assurance.md) and [trusted boundary](trusted-boundary.md)
retain their existing claims and premises.

The Rosetta supported list and generated progression are unchanged. Under
[planning.md](planning.md#rosetta-progression), a construct admission triggers
the supported-list update and re-render; this delivery admits none. The task
dispositions below qualify the earlier assessments without rewriting the generated
progression by hand.

## Task dispositions

The numbering follows #9, not the current generated stage positions.

| # | Task requirement | Regression or disposition |
| --- | --- | --- |
| 1 | [Shell one-liner](../rosetta/s/shell-one-liner/task.wiki) | [rosetta_shell_one_liner.adb](../samples/rosetta_shell_one_liner.adb) — One physical source line; shell invocation below. |
| 2 | [Empty program](../rosetta/e/empty-program/task.wiki) | [null.adb](../samples/null.adb) — Existing null program, unchanged. |
| 3 | [Hello world/Newline omission](../rosetta/h/hello-world/newline-omission/task.wiki) | [rosetta_newline_omission.adb](../samples/rosetta_newline_omission.adb) — Exact text without LF. |
| 4 | [Hello world/Text](../rosetta/h/hello-world/text/task.wiki) | [rosetta_hello_world.adb](../samples/rosetta_hello_world.adb) — Exact task text, without the comma in the older Hello World sample. |
| 5 | [Start from a main routine](../rosetta/s/start-from-a-main-routine/task.wiki) | Skip: task permits omission when startup always invokes Main. |
| 6 | [Case-sensitivity of identifiers](../rosetta/c/case-sensitivity-of-identifiers/task.wiki) | [rosetta_identifier_case.adb](../samples/rosetta_identifier_case.adb) — Case variants denote one object. |
| 7 | [Comments](../rosetta/c/comments/task.wiki) | Skip: prose/lexical explanation, explicitly excluded by #9. |
| 8 | [Show the epoch](../rosetta/s/show-the-epoch/task.wiki) | Skip: documentation answer; no admitted date/time library. |
| 9 | [Sort stability](../rosetta/s/sort-stability/task.wiki) | Skip: prose report, explicitly excluded by #9. |
| 10 | [String concatenation](../rosetta/s/string-concatenation/task.wiki) | [rosetta_string_concatenation.adb](../samples/rosetta_string_concatenation.adb) — Construct a String from a variable and literal; display both. |
| 11 | [String interpolation (included)](../rosetta/s/string-interpolation-included/task.wiki) | Exclude: built-in placeholder substitution is absent. |
| 12 | [Random number generator (included)](../rosetta/r/random-number-generator-included/task.wiki) | Skip: task permits omission without a built-in RNG. |
| 13 | [Here document](../rosetta/h/here-document/task.wiki) | Exclude: no heredoc or multiline String literal syntax. |
| 14 | [Sealed classes and methods](../rosetta/s/sealed-classes-and-methods/task.wiki) | Skip: task permits omission without inheritance. |
| 15 | [Copy a string](../rosetta/c/copy-a-string/task.wiki) | [rosetta_copy_string.adb](../samples/rosetta_copy_string.adb) — Copy contents, mutate original, demonstrate independent values. |
| 16 | [Print debugging statement](../rosetta/p/print-debugging-statement/task.wiki) | [rosetta_print_debugging.adb](../samples/rosetta_print_debugging.adb) — Actual assignment trace with accurate literal source location and before/after values. |
| 17 | [Special variables](../rosetta/s/special-variables/task.wiki) | Skip: prose inventory of special variables. |
| 18 | [Draw a diamond](../rosetta/d/draw-a-diamond/task.wiki) | [rosetta_diamond.adb](../samples/rosetta_diamond.adb) — Faceted three-dimensional diamond/inverted pyramid. |
| 19 | [Special characters](../rosetta/s/special-characters/task.wiki) | [rosetta_special_characters.adb](../samples/rosetta_special_characters.adb) — Actual doubled-quote escaping; literal backslash and comment marker. |
| 20 | [Write language name in 3D ASCII](../rosetta/w/write-language-name-in-3d-ascii/task.wiki) | [rosetta_language_name_3d.adb](../samples/rosetta_language_name_3d.adb) — Silver lettering with front faces, extrusion strokes and back edges. |
| 21 | [Safe mode](../rosetta/s/safe-mode/task.wiki) | Skip: descriptive account of language restrictions. |
| 22 | [Documentation](../rosetta/d/documentation/task.wiki) | Skip: comments/source documentation explanation. |
| 23 | [Rubik's cube](../rosetta/r/rubiks-cube/task.wiki) | [rosetta_rubiks_cube.adb](../samples/rosetta_rubiks_cube.adb) — Fixed drawing with three visible 3-by-3 faces. |
| 24 | [Hello world/Newbie](../rosetta/h/hello-world/newbie/task.wiki) | Skip: installation/editor/build/run instructions. |
| 25 | [Interactive help](../rosetta/i/interactive-help/task.wiki) | Skip: implementation CLI/documentation task, not an application help handler. |
| 26 | [Operator precedence](../rosetta/o/operator-precedence/task.wiki) | Skip: precedence/associativity and parameter-passing explanation. |
| 27 | [Useless instructions](../rosetta/u/useless-instructions/task.wiki) | [rosetta_useless_instructions.adb](../samples/rosetta_useless_instructions.adb) — Compare actual elsif and nested-if computations; exercise choices and invalid input. |
| 28 | [Cross compilation](../rosetta/c/cross-compilation/task.wiki) | Skip: toolchain/platform documentation. |
| 29 | [Naming conventions](../rosetta/n/naming-conventions/task.wiki) | Skip: naming/style documentation. |
| 30 | [Rubik's Magic Simulation](../rosetta/r/rubiks-magic-simulation/task.wiki) | Exclude: the assessed fixed frames do not implement the requested simulation. |
| 31 | [Draw the Empire State Building](../rosetta/d/draw-the-empire-state-building/task.wiki) | [rosetta_empire_state_building.adb](../samples/rosetta_empire_state_building.adb) — Fixed building silhouette; optional rotation omitted. |

Built-in interpolation requires substitution within a string; concatenation is
a distinct admitted operation. The captured Ada alternative does use concatenation,
but does not establish a Silver interpolation feature. Heredoc syntax is absent,
and current literals cannot contain line breaks; repeated output does not add it.
Rubik's Magic needs an actual state-transition simulation; printing prescribed
frames is insufficient. This delivery does not select a future simulation design
or claim that any particular missing construct is indispensable to all designs.

The drawing tasks explicitly request output artwork, so literal drawings satisfy
them. The diamond has depth, the banner names Silver, and the cube depicts its
three visible faces. Empire State rotation is optional and is not implemented.
The tracing sample identifies the actual code fragment with a literal; it does
not claim automatic source-location introspection.

The shell task can be specified and executed in one command line from the
repository root after the [normal build](../README.md#set-up-verify-and-build):

```sh
printf '%s\n' 'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin Silver_IO.Put_Line ("Hello world!"); end Main;' > main.adb && "$(python3 scripts/dev.py paths --field executable)" run main.adb
```

## Validation

All required checks passed on Linux x86-64. The lead was the sole writer of the
selected proof workspaces.
The original native validation installation under
`tmp/bounded-mutable-integers-native` and retained Lean installation under
`tmp/review-b79-b1-lean` preserve effective cache paths. Their compiler, proof,
script and test sources were checked against main before reuse. Unrelated scratch
files are preserved. The native suite ran at implementation `247cc5c205`; the
Lean workspace was at main `7a2fb0b70a`, with its 581 authoritative inputs checked
byte-for-byte against the implementation commit. Linux x86-64 is the actual
validation host.

The manifest check admits each source, proves and builds its byte-identical
snapshot, audits the application and selected-library reports and effective prover
options, and compares application stdout, stderr and exit status. No native macOS
validation or hosted CI run is claimed.

The [machine-readable evidence index](evidence/rosetta-supported-samples/validation.json)
records actual commands, run IDs, host/workspace identities, measured elapsed
time, sample hashes and comparisons of captured inputs with the implementation
commit. Managed records, compiler proof reports and provenance remain in
`.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/`; Lean objects remain in the
retained workspace. The sample test audits and then cleans each application
workspace, so the suite log records successful checks rather than archiving
individual application proof reports.

| Check | Result | Managed run |
| --- | --- | --- |
| Complete native proof and provenance audit | Passed: 75 units, 1,000 entities, 1,295 flow checks and 13,860 proof checks; 44.169 s, six reserved workers | `20261025T070959-fd3da7c63f7a` |
| Native build | Passed; 7.601 s, six reserved workers | `20261025T071056-2f783520af81` |
| Complete cached Lean/source check and fresh audit | Passed: 466 modules, 89,369 declarations, only `propext`, `Classical.choice`, `Quot.sound`; 42.679 s reported by Lean runner, four workers/two threads per process | `20261025T071150-d336b7715e90` |
| Full regression suite including manifest samples | Passed: 473 tests, including all 35 manifest samples and 19 execution cases across the 13 new programs; 2,647.144 s unittest time (2,648.738 s managed elapsed), six reserved workers | `20261025T071332-d7b2607b6d27` |

The [full-suite summary](evidence/rosetta-supported-samples/full-suite-summary.txt)
and [compressed complete log](evidence/rosetta-supported-samples/full-suite.log.gz)
record one successful complete run, including the symlinked-TMPDIR portability regression.
Its 693 captured tracked inputs match `247cc5c205`; eight additional captured
inputs identify the executable, generated installation and environment. Application
proofs retained the pinned `-j0` policy; no other native/proof writer ran alongside
this suite.

The native proof/build inputs include 141 tracked repository files matching
`247cc5c205`; the complete Lean evidence matches all 581 authoritative
source/proof/script inputs. Generated installations and external tools retain
the recorded workspace identities. The native audit reused solver sessions/cache;
Lean reused compiled objects and freshly audited the full project. Neither is a
cold run or an independent kernel replay. Successful assurance was retained
while documentation changed; no source pin or semantic proof was altered.

## Review and rounds

| Work | Selected or confirmed settings | Outcome | Time and cost evidence |
| --- | --- | --- | --- |
| Task requirements and implementation | Author and independent task auditor: GPT-6.1 Sol, Extra High (selected through agent controls); lead runtime model/effort not exposed by this harness | Agreed 31-task disposition; rejected interpolation/heredoc output substitutes and fixed simulation frames; implementation integrated and independently reviewed | Auditor reported approximately two minutes; implementation elapsed not instrumented; token/cost measurements unavailable |
| Stable validation and integration | Lead runtime model/effort unavailable; independent implementation reviewer: GPT-6.1 Sol, Extra High (selected) | Native, complete Lean/source and full-suite checks passed; all 35 samples passed, no implementation rework required | Review 77 s; native and suite timing in the validation table; whole-team token/cost measurements unavailable |
| External review integration | Lead runtime setting unavailable; bounded recommendation check: GPT-6 Astra, Extra High (selected) | M1/L1/L2 repaired; authorization provenance clarified; planning overclaims corrected without implementation changes | Recommendation check 148 s excluding initial reads; lead elapsed and token/cost unavailable; prior successful validation retained |

Independent implementation review covered exactly
`7a2fb0b70a..247cc5c205acf1e5a9e93a76b5d4ba5420838e6e -- samples/`,
including all 13 new sources and manifest additions. The selected reviewer was
GPT-6.1 Sol at Extra High; runtime settings were not independently confirmed.
The read-only review took 77 seconds; token/cost measurements were unavailable.
No material findings remained. It checked the actual task behavior, admitted
syntax, ASCII/source bounds, capability identifiers and report policies,
expected bytes, all selected argument paths, artwork and the trace's literal
location (line 8, column 4). Native proof and execution are separate evidence.

The implementation commit is `247cc5c205`; later delivery edits are documentation
and evidence only. The shell invocation above supplies the environment portion
of the one-liner task, using the exact one-line regression source.

## External review disposition — 2026-10-25

The owner supplied [review-pr221-6a70c241db](reviews/review-pr221-6a70c241db.md),
reviewing PR #221 at `6a70c241db` and implementation `247cc5c205`. The report is
preserved verbatim; its recommendations are subject to the dispositions here.
Its Claude Fable 5.1 settings, 53-minute duration, 958k output tokens and 119-agent
accounting are reviewer-reported, not independently measured by this session.
The delivery verdict is accepted: no blocker or sample implementation defect.

| Finding | Disposition |
| --- | --- |
| M1, [#222](https://github.com/berkeleynerd/silver/issues/222) | Confirmed and fixed. Read the Lean ledger's `started.command` and `started.inputs.sources`; all 581 hashes were rechecked against `247cc5c205`. The index now contains the actual invocation and nonempty comparison. No proof result changed. |
| L1, [#223](https://github.com/berkeleynerd/silver/issues/223) | Confirmed and fixed: row 20 links its 3D language-name regression. |
| L2, [#224](https://github.com/berkeleynerd/silver/issues/224) | Confirmed and fixed: current roadmap/decision terminology is strict/extended, with an immutable citation to the owner's 2026-10-24 decision on draft PR #147 and a dated note on the historical terminology update. No Oracle or authorization change. |
| L3 | Clarified the native and Lean worktree revisions above; their actual input correspondence remains the same. |
| L4 | No policy defect: the tags selecting proof/report policy are correct, and the descriptive capability list is not an exhaustive syntax inventory. Cosmetic normalization is unnecessary for this delivery; manifest and samples remain unchanged. |
| Owner confirmation note | No new confirmation needed. The earlier message headed “Owner instruction, 2026-10-24” explicitly selected #9, repeated the deferrals and required a pull request. Session memory now identifies that conversation source and quotes the relevant instructions. |
| M2/L5 planning work | Assessment reconciliation remains the planning agent's separate work. Do not automatically adopt the report's permanent exclusions or seven-task progression claim; see below. No Rosetta render or next-stage implementation was performed here. |

The repair validation checks the JSON against the retained ledger, links and
whitespace. Existing native, Lean and full-suite evidence applies unchanged;
no source, proof, script, sample or manifest was edited and no expensive success
was rerun. The independent bounded recommendation check used selected GPT-6 Astra
Extra High (runtime setting not independently confirmed), reading this report,
the ten task texts, retained candidate sources and governing Ada/SPARK references.
Its observed clock interval was 148 seconds, excluding initial reads; token/cost
measurements are unavailable. It found the planning qualifications below.

For future reviews, use a focused pass plus checks tied to unresolved findings.
The supplied review's 119-agent expansion is disproportionate to these record
repairs; agent and token totals do not establish stronger evidence. No model-quality
comparison is inferred from the reported spending.

## Next proposal

Reconcile the stage-2 assessments and exact task interpretations before selecting
another implementation increment. Admission alone is not task fidelity, proof,
build or execution evidence. The supplied review's seven admitted candidates do
not yet justify moving seven tasks to supported status:

- Topic variable uses an ordinary explicit variable; it does not establish the
  [task's special topic-variable behavior](../rosetta/t/topic-variable/task.wiki).
- Integer sequence permits an implementation limit, so the signed-32-bit sequence
  is a valid candidate. Its 2,147,483,647 output lines still need an honest validation
  disposition; silently capping the sequence is not completion of that task.
- Compile-time calculation, the half-iteration loop, immutability and minimum cells
  have faithful core candidates. Literals/Integer needs a minor explanation of the
  full base range 2–16 and a comment correction: `7#1#E3` is 343, not 727.
  All remain undelivered candidates until their required validation passes.

Unicode identifiers are excluded by today's [source rules](../language.md#source-and-lexical-rules),
not the Oracle: Ada 2022 RM 2.3 permits Unicode letters, and SPARK 16.1 adds no
identifier restriction. The separate mutable-increment limitation comes from
current interval analysis. Native heredoc syntax conflicts with the unchanged
inherited Ada literal syntax. Permanent interpolation impossibility is not
established merely by absence of literal interpolation syntax: the captured
[Ada answer](../rosetta/s/string-interpolation-included/ada.wiki) uses existing
`Fixed.Index`/`Fixed.Replace_Slice`, and the Oracle permits selectively admitted
library operations. That approach needs an explicit task interpretation and
admission assessment. The #9 exclusions themselves remain justified.

Static named Integer subtypes and declarations using them remain a coherent
candidate under [#11](https://github.com/berkeleynerd/silver/issues/11), motivated
by the reusable `1 .. 10` range. A subtype mark in a for-loop range is related but
not necessary to the minimal driver. Distinguish a subtype from a distinct Ada
type and establish name resolution, range semantics and source correspondence;
reuse of interval machinery does not discharge those obligations by itself.
Assessment-derived task yields do not settle a subtype/division implementation
order. Scalar guard refinement also has independent value for guarded updates
of existing Integer objects; it does not require conversions to be useful.

The next sample batch and construct stage still require owner authorization.
Deferred #119 work and #88–#94 remain untouched.
