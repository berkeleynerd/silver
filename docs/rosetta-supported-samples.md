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
| 20 | [Write language name in 3D ASCII](../rosetta/w/write-language-name-in-3d-ascii/task.wiki) | Silver lettering with front faces, extrusion strokes and back edges. |
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
files are preserved. Linux x86-64 is the actual validation host.

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

## Next proposal

After #9, a bounded next increment under [#11](https://github.com/berkeleynerd/silver/issues/11)
could admit static named Integer subtypes and object declarations using those names,
motivated by the reusable `1 .. 10` range in
[Define a primitive data type](../rosetta/d/define-a-primitive-data-type/task.wiki).
Its scope would specify static range evaluation, name visibility, initialization,
assignment and composition with existing loops and Integer Image, together with
the complete universal, source-correspondence and native validation obligations.
Named distinct types, conversions, scalar guard refinement, other scalar Images
and broader loop forms would remain separate. This would advance part of #11;
it would not complete its broad construct identifiers.

This is a proposal for the owner's scope decision, not implementation authorization.
The next construct stage, deferred #119 work and #88–#94 remain unstarted here.
