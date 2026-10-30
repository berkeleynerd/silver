# Boolean context stack observations

Issue #291, native Linux, 2026-10-30. The final compiler checks, compiles with
proof, and executes both retained finite deepest-loop fixtures at an actual
8,192 KiB stack. These are concrete observations, not a universal stack bound.

The baseline is completed subtype source `fa6b5e982c`, immediately before the
Boolean implementation. Its 131 source files were copied exactly into the native
tool workspace; the project and Alire manifest match that commit. Managed unit
compile `20261030T123108-9994ca96f777` passed in 12.688 s using the normal project
compiler switches plus `-fstack-usage`, with one worker and an isolated output
directory. The exact source hashes, command/events, native log, `.ali` and `.su`
are retained under `baseline/`.

Final build `20261030T131151-8f53eb3ec741` passed with the same stack-usage flag.
Its 131 source hashes match the integrated final source at `927cc5e178`; the
native repair commit is `37b6e4777b`. Exact source and binary identities,
command/events, compiler log, `.ali` and `.su` are under `final-build/`.

| Ada function | Baseline `.su` entries | Final `.su` entries |
| --- | --- | --- |
| `Loop_Body` | 192 static; 31,968 dynamic | 192 static; 35,776 dynamic |
| `Body_Tail` | 208 static; 160 dynamic | 208 static; 160 dynamic |
| `Conditional_Body` | 192 static; 224 dynamic | 192 static; 240 dynamic |
| `Read_String_In_Flow` | 18,816 dynamic,bounded; 240 static | 18,848 dynamic,bounded; 240 static |
| `Context_Of` | 18,768 static | 18,768 static |

Sizes are bytes. These are individual compiler entries, including multiple
entries with the same Ada source name. The printed fixed portion of the dynamic
`Loop_Body` entry grows by 3,808 bytes. A dynamic entry's printed size is not a
bound on total runtime stack use. The figures are not summed into such a bound.

The unchanged retained observer is copied into `harness/observe.py`. The two
4,096-byte fixtures are byte-identical to the completed subtype evidence:
141 nested once-executing counted loops and 158 nested singleton-array foreach
loops. The historical two-element foreach fixture was not executed: its
iteration count would be exponential in nesting depth.

| Fixture | Check | Proof-backed compile | Execute | Proof audit |
| --- | --- | --- | --- | --- |
| Counted | exit 0, 0.120 s | exit 0, 30.649 s | exit 0, 0.019 s | 19 flow + 47 proof checks |
| Singleton foreach | exit 0, 0.068 s | exit 0, 35.546 s | exit 0, 0.004 s | 19 flow + 47 proof checks |

Each phase prints the actual 8,192 KiB stack limit and uses CPU affinity `[0,1]`.
Generated main files matched the fixture bytes; retained main `.ali` files
include `-gnatdM`. `scripts.check_evidence.audit_reports` independently accepted
both five-unit report sets with `application_kind='static', indexed_main=True`
and no warnings/advisories. Reports, logs, observation metadata and hashes are
retained in the fixture directories and `independent-audit.json`.

The observations ran within the 15-test focused run
`20261030T131722-0b2bed7eeddd`. The combined fixture test and 13 other test identities passed;
the run failed only on an unrelated Boolean hiding fixture, corrected and
successfully rerun as documented in [the focused record](../final-focused/README.md).
Production proof options, including the producer's `-j0`, were unchanged.
The runner reserved two workers and the test child inherited two-CPU affinity;
the producer reported internal `-j12`, so this is not a claim of a two-process
internal cap.

Two initial baseline command forms were rejected before managed execution
because custom compiler flags require the tool route and declared inputs and
workspaces. Managed run `20261030T123030-4b6db884dfd4` failed preflight because an
explicit proof-container input path did not exist; no compilation occurred.
Its events are retained. The successful correction declared the actual proof
input and writable output roots. No source, test, stack policy or proof budget
was weakened.

Selected native subthread: GPT-6 Astra / Extra High. Runtime model confirmation
and token/cost measurements are unavailable. Managed elapsed measurements are
recorded independently of any model-quality claim. Complete compiler native
proof, source assurance and the full regression suite remain separate obligations.
