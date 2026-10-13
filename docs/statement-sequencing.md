# Statement sequencing and assignment

Authorized on 2026-10-13 by the owner's “Proceed”, following the completed
[interpretation-witness repair](common-expressions.md#external-review-of-9b72d36)
at `3c1522f540`. This capability is **complete and supported**. Its implementation
and review target is the commit introducing `samples/statement_sequence.adb`;
the evidence below identifies the exact checked inputs.

## Scope

Generalize the current output-capable bodies into finite nonempty sequences of
`null`, fixed-bound String assignment, `Silver_IO.Put_Line`, and one-level String
equality conditionals. Both equality branches contain nonempty basic statement
sequences; multiple conditionals may appear in the enclosing sequence. Retain the
current contexts, ordered initialized declarations, expression rules, and the
outer argument-validity/optional-capacity guard with its Reject alternative.
An output-capable context may contain a sequence that makes no output call;
report dependencies must follow the source's actual approved calls.

Assignments preserve declared length shapes and initialized reads. Repeated calls
return normally on specified failure outcomes: later calls are still attempted,
accepted bytes accumulate in execution order, and a failure keeps the process
status failed. Nested equality conditionals, broader Boolean guards, context/name
closure, additional argument APIs and arbitrary new statement/call caps are not
part of this increment. Source size and existing expression/work bounds remain
explicit resource limits. Native capacity experiments must justify any necessary
report-buffer adjustment before the larger fragment is called supported.

## Implementation and validation

Reuse shared binding/expression facts. New sequence parsing must connect the
actual SPARK helper equations and executable refinements to a concrete inhabited
Lean interpretation, typed source grammar, sequential semantics and complete
obligation discharge. Matching pins alone are insufficient. Focused model checks
provide development feedback; one stable complete native/Lean checkpoint closes
the capability. Pair touched negative admission rules with admitted controls.

Native diagnostic/report-capacity experiments justify the precise policy and
application-buffer changes recorded below. The old repeated-output draft is preserved as unfinished historical
work; its four-call cap is not adopted. Linux is primary, GitHub Actions remains
disabled, independent replay is optional and macOS proof work is out of scope.

Evidence and preserved prior-state snapshots are under
`/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/sequencing-20261013T192421Z/`.
`tmp/sequencing-active.json` records recovery paths and isolated proof lanes.
All earlier caches, failed logs, review reports and scratch remain preserved.

## Implemented rules and proof structure

The old fixed bodies are replaced by three shells: static, argument-validity
and argument-validity/capacity. Their nonempty statement lists share null,
fixed-bound assignment, returning output and one-level equality. Both arms use
nonempty basic lists; several choices may occur in sequence. The source limit,
sixteen expression leaves and thirty concatenations remain. The separate
context-free null program is unchanged. There is no independent statement or
output-count cap.

`SequenceAdmission` gives the terminating scalar scanner. The token, basic,
list, conditional, header and shell grammar modules prove soundness,
completeness, unique meaning and program validity. Disjoint shell prefixes make
the parsed argument/assignment/output flags exact. Shared binding/expression
lemmas remain in use. The old `Compose` helper interpretation is separated from
its obsolete fixed-shell recognition claims.

`SequenceExecution` proves initialized reads and fixed bounds after every
assignment and chosen arm. `SequenceMain` retains the actual token and payload
order of that same decoded program. `SequenceEffects` composes per-call accepted
bytes and sticky failure status, including later successful calls after an earlier
failure. Its bound scales with the actual output count; it does not incorrectly
claim that a failed cumulative trace is one prefix. `SequenceObligations` covers
all initializer/expression ranges and assignment lengths, including both arms.
`Current` uses this language and retains the conditional external-tool completion
and pipeline interface. `SequenceCorrespondence` composes native membership and
selectors with Main semantics, complete modeled discharge and that pipeline.

`SequenceSourceBridge` renders and checks scanner bodies, contracts,
form tables and complete source shape. Arbitrary-callee equations and legal
range/progress contracts derive recognition and selectors. `SequenceModel`
provides an independent concrete inhabitant of all fields; the bridge retains
that witness separately from arbitrary-callee correspondence. The approved
Ada/frontend interpretation, faithful generation and solver-completion premises
remain explicit in [trusted-boundary.md](trusted-boundary.md).

## Native capacity and diagnostic experiment

The Linux sandbox exposes 12 CPUs, about 31 GiB RAM and no swap. It uses the
pinned local GNATprove toolchain and Lean 4.34.1. Available physical RAM on the
owner's machine is not the sandbox's allocation. Probe commands use production
application proof options plus a separate exploratory output/cache directory.
They are timed observations with cache reuse permitted, not cold bounds.

| Source | Proof result/time | Main report |
| --- | --- | --- |
| Two output calls | Passed, 6.03 s | 2,676 bytes |
| Eight output calls | Passed, 1.51 s | 13,424 bytes |
| Two nulls in IO context | Passed, 1.51 s | Main-only with no safety checks |
| Assignment/self-copy without output | Passed, 2.01 s | Main-only, one length check |
| 4096-byte source, 175 output calls | Passed, 2.51 s | 314,746 bytes; 696 ghost-output advisories |
| 4096-byte source, 60 assignments, 160 outputs, 30 concatenations | Passed, 92.59 s | 469,246 bytes; 60 length and 30 range checks, 636 ghost-output advisories |
| 4096-byte source, 800 assignments | Externally stopped after 180.49 s | No completed report; about 8.16 GiB sampled peak process-group RSS |

The last case is incomplete measurement, not a proved solver failure. Dense
assignment cost and the complete producer envelope remain explicit limitations.
The output/mixed results demonstrate an actual overflow of the earlier 256 KiB
application capacity, so application reports now use 2 MiB while runtime reports
retain 256 KiB. The driver accepts an exactly 2 MiB report and rejects one byte
more under the ordinary 8 MiB stack. Fitting every genuine admitted-program
report within that envelope remains a pinned-producer premise, not a Lean theorem
about arbitrary JSON. No truncation or replacement call-count limit is introduced.

Report policies retain exact entity/coverage/dependency sets for the observed
Main-only, argument-without-output and output shapes. They classify only the
existing initializer/assignment/constant-equality advisories plus the four exact
`Put_Line` ghost-output messages, all with their original provenance/location and
no-suppression requirements. Every emitted safety check and complete selected
runtime proof remains mandatory. The checker refinement required factoring the
empty-suffix map lemma; no policy condition or proof obligation was dropped.

Probe source/tool hashes, commands, reports, RSS samples and interruptions are in
`native-probes/results.json` under the task evidence directory. All seven probe
sources were subsequently admitted by the new native recognizer. The ordinary
test suite additionally compiles and runs the 175-output program through the
actual Silver driver.

## Validation record

Completed focused work includes native parser verification (617 checks),
report/evidence tests, delimiter-neighbour controls, failure injection showing
later output after a detected write/flush failure, and the model/semantic proofs.
Final actual-source closure passed in the complete checkpoint below.
The independent admission comparison has **2,083 sources, 574 admitted and zero
Ada/Lean disagreements** in 38.78 seconds; seeds include earlier samples, generated
sequences/choices, lexical mutations and source/expression boundaries. It compares
the compiled recognizer with `SequenceAdmission` plus null, not a proof of native
compiler correctness by testing.

The complete native compiler audit passed with **2,729 checks** (467 flow and
2,262 proof), 17 units, 246 entities, 59 classified limitation notes and 14 approved
imports. It forced analysis while retaining native sessions/solver cache; this
is a complete audit, not a cold measurement. The exact manifest and reports are
preserved in `native-full-reports/`, with the log in `native-full-proof.log`.
The native build and exact catalogue comparison passed. The full test invocation
passed **266/266 methods in 1,302.997 seconds**, with no skips/failures/errors,
while native/Lean checks shared the host. All sample cases and seven new sequence
methods passed. Native/tool/test inputs stayed stable; seven proof-file changes
during the suite are separately enumerated in `native-checkpoint/results.json`.
This is not a stable-whole-tree test timing; the subsequent complete Lean check
validates the final proof inputs. Certificate regeneration parity passed after
refreshing the two changed tracked candidates.

The final complete Lean check passed on stable final proof/source/tool inputs:
**144 modules, 37,293 audited declarations**, with only `propext`,
`Classical.choice` and `Quot.sound`. Its 221.481 seconds comprise a 216.740-second
cached build and 3.110-second fresh audit plus runner overhead. This is the final
integration time, not the time to develop or rebuild every proof. It reused 136
of 144 `.olean` artifacts byte-for-byte with unchanged timestamps, including
all twelve source certificates and both helper/scanner source checks. The six
repaired example modules, `Silver` import facade and `Silver.Audit` rebuilt. The final input digest was
independently recomputed and matches `lean-evidence.json`.

Focused lanes initially used four workers, four threads and 8192 MiB per process
while sharing the sandbox. Later source checks and the final canonical check used
twelve workers, twelve threads and 16384 MiB per process. The completed canonical
workspace is now the preferred warm cache; retain private/server sidecars and Lake
metadata. `canonical-checkpoint-results.json`, `lean-evidence.json`,
`lean-complete.log` and `lean-proof.log` in the task directory record the final
result and artifact comparison. Independent kernel replay was not requested;
no macOS or hosted CI claim is made.

Independent native/interface and semantic/source reviews found no material mismatch.
Current-document leftovers were corrected, and the retained `ComposeExecution`
fragment was restored to the complete audit import closure. Native provenance
verification additionally matches all 2,391 captured input hashes, 12 tool identities
and 19 preserved report hashes against the completed implementation. See
`native-checkpoint/review.md`, `native-checkpoint/provenance-verification.json`
and `semantics-review.md` in the task evidence.

## Source-check repairs and cache handling

The changed output-body certificate completed in 869 seconds. Shared helper
source checks completed in 859 seconds. The new scanner source check initially
could not kernel-reduce imported mutual renderers; rewriting with their existing
public equation lemmas preserves the exact propositions and let the repaired
check pass in 108 seconds. No native computation axiom, bypass or lint suppression
was used. A small independent kernel probe confirmed the renderer repair first.
These are observed phase times during shared-host development, not controlled
whole-build comparisons.

The focused `SequenceCorrespondence` check passed with its actual-source checks,
concrete interpretation witness and fresh axiom audit. The canonical complete
check then exposed six retained example witnesses still constructing the former
fixed-form membership type. Their one-line repairs use the sequence grammar and
keep the original sources and theorem statements. The first failed complete log
is preserved; its last known-invalid example compilation was stopped rather than
finishing work that could not produce a valid artifact.

Completed module groups from quiescent lanes were copied with their private/server
sidecars and Lake metadata; Lake still validates content dependencies. Original
lane caches remain available. The model lane's earlier rolling focused-result JSON
was replaced by a subsequent supported run; its timestamped logs, the separate
ranges-lane witness evidence and pre-task canonical evidence remain. No recovery
of that original rolling JSON is claimed. Source-check and correspondence result
JSON/log copies are now retained in the task record alongside the failed attempts.

The final native read-only scope review is in `native-final-review.md` under the
task evidence directory. It confirms the twelve removed rejection cases have
admitted replacements and rejected controls, and the report changes stay within
this capability.
