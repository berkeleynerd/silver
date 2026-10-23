# Canonical response bytes in the selected J12 JSON report

2026-10-23 UTC, #119 / #153. **Candidate, pending independent review.**
This joins the prospective adapter's bounded published files to Why3's answer
and JSON interfaces. It uses the actual combined J12 registration metadata,
not the older serial scheduling counts. It changes no production invocation
and does not close raw solver-file storage or whole-process capacity.
The [packet](../evidence/retained-why-canonical-json-input-20261023/README.md)
retains source ranges, provider identities and the new arithmetic.

## Published files and stored answers

The accepted [outcome interface](retained-adapter-outcome-interface.md) publishes
an immutable canonical file only after its bounded contents, close and identity
checks succeed. A forwarded Finished response names that file; it never names
the raw backend file. All 31 selected canonical rows contain at most 76 bytes.
Queued cancellation has an empty filename and does not read a file. A failed
publication does not acquire a successful filename or a raw-file fallback.
These are required future proxy/adapter refinement conditions, not a claim
that the production compiler already implements them. Raw files, the adapter's
own processing and its startup/error outputs retain separate capacity owners.

The file-taking `Call_provers.parse_prover_run` wrapper reads the named file and
passes its complete bytes to its parser; returned `pr_output` is exactly those bytes. The
empty-filename branch instead supplies an empty output and fixed interrupted
answer. Fresh registration's synthetic Trivial result has `pr_output="unsat"`
(five bytes), fixed Valid answer, and no model. Session updates store these
results; they do not concatenate their raw outputs. The accepted fresh,
nonreplay, CE-off and no-manual route introduces no other result producer.

For A reported answer occurrences and N parser invocations, including abandoned
prefixes, therefore choose

```
O_A <= 76 A; O_P <= 76 N; O = 76 max(A,N).
```

This counts a shared result each time it is reported and a parser each time it
is entered. No uniqueness, successful completion, or amortization across
separate processes is assumed. The synthetic Trivial branch overcounts safely.
Use the accepted general answer/warning transfer
`L_A<=4O+64A`, `W_c<=O+N`, `L_c<=514O+512N`.
Some canonical rows deliberately preserve a warning, so setting W_c to zero
would be wrong. The full parser/Buffer representation, raw files and protocol
owners are not proved merely by this downstream substitution.

## Current process and occurrence attachment

The [logging-prefix result](retained-parallel-logging-prefix.md#constructor-trace-goal-ids-and-serial-table-interface)
retains exact J12 registration counters and complete forest correspondence.
The [combined startup](retained-combined-parallel-startup.md) preserves that
construction and the normalized input/check identities. Every raw forest has
one parent goal 0, one split transformation and children 1..nextNode-1; there
are no child transformations. The accepted
[callback closure](retained-why-callback-demand.md) preserves this domain:
no later splitting, CE/RAC insertion or logical goal graft is selected.
Saves alter their already charged metadata, not this immutable goal forest.

Each registered goal belongs to its extracted check; the per-check toplevel
container is a set. `check_to_json` visits each such goal once and its
`transformations_to_json` is empty for these leaves. Thus the number of
reported goal occurrences is at most the number of raw children, even though
some raw trivial/unregistered children are omitted. Input's bound here is four
raw registration children; it is not the old post-CE one-root value.

The new scheduling-owner bound E comes from accepted R63/R65 and already
includes the one global exceptional allowance. Each owner calls the one
`graft_proof_attempt` site at most once before enqueueing. Its partial failure
does not locally retry that graft. A repeated scheduling owner is already
charged in E; signal saves create no proof attempt. At most one new binding
occurrence can therefore be added per owner, including duplicate keys. A
reported attempt visit is a visit to one such binding. Starting with the
exact J12 `next_proofAttemptID` upper bound on initial bindings gives
`A<=A0+E`. Failed lookups or reporting prefixes can abandon visits but do not
restart the report. No set-cardinality argument discards duplicate bindings.

This uses the accepted [attempt-table growth](retained-why-save-attempt-growth.md)
and [native table-prefix contract](retained-why-save-hashtbl-prefix.md), retained
in the [206-table integration](../evidence/retained-why-save-round31-20261020/README.md).
Counting source add sites alone would not exclude duplicated cells from an
interrupted resize. These per-goal tables start with at most one Trivial binding
and have at most three selected prover additions plus the single global e<=2
exceptional allowance. Their 16-bucket initial capacity therefore does not
resize. The existing no-resize insertion/prefix theorem bounds physical binding
occurrences even if a failed insertion has already published a cell. During
the controlled successful registration prefix, one binding is created per
allocated attempt ID; the exact J12 metadata/counter relation supplies A0.
The update-result route changes fields, not the per-goal binding list. All
native/signal, key/payload, valid-state and first-violation premises of these
providers remain required; no general atomic-Hashtbl premise is introduced.

The fixed-input R bounds count possible registered check keys, from the accepted
JSON/schema input attachment. The normalized JSON input is unchanged in the
combined startup. They conservatively include keys absent from the actual J12
registered root map. Reporting does not create a new key: `register` rejects
an existing message key and the caller iterates the existing check map.

| Case | Raw children G | Initial attempts A0 | Scheduling/parser N=E | Reported attempts A | Check bound R | Weighted O |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 64 | 14 | 155 | 169 | 22 | 12,844 |
| Put | 53 | 12 | 128 | 140 | 18 | 10,640 |
| First_Or_Default | 32 | 10 | 68 | 78 | 9 | 5,928 |
| Is_Message | 3 | 1 | 8 | 9 | 1 | 684 |
| Input_Is_Valid | 4 | 3 | 5 | 8 | 1 | 608 |

N bounds all entries to answer analysis, even if cancellation or failed
preparation means no file is parsed. The source ownership relation supplies at
most one analysis per published call owner. Fresh requests, callbacks and saves
do not acquire a second E allowance. This table comes from the exact current
registration and continuation interfaces, rather than transplanting mutable
serial or post-CE state into another process.

## Remaining JSON inputs and service conditions

Reuse the [standard JSON schema](retained-why-standard-json-inputs.md), with
one attempted normal report and two attempted abort reports, S<=5R,
K<=26, timing-key bytes<=1051 and final debug-buffer copy D<=1/H<=26619.
Source `opt_debug_prover_errors` starts false, its only option setter is absent
from the exact combined argv, and its immutable exported Boolean remains false.
There is no separate raw-output warning at that site. The selected J12 callback
drops InternalFailure payloads, and replay-only warnings remain excluded.
In-body and initial warnings are still W_o/L_o, owned by their separate source
argument; no zero is substituted for them.

The new contribution is obtained directly from the existing affine schema:

```
B_JSON <= 14864 + 3732R + 189G + 873A + 3075N + 3111O
          + 3 + 6*26619 + 84 + 3W_o + 6L_o + 6X
E_JSON <= 2313 + 753R + 73G + 194A + 1027N + 1039O
          + 3 + 2*26619 + 106 + 3W_o + 2L_o + 2X.
```

X sums the at-most-two abort payload lengths. The new table/constants and
the remaining coefficients are retained in result.json. Shared stderr's R66
64E-byte/8E-event fragment belongs to its separate formatter once per process;
it is not added to the standard stdout JSON owner or multiplied by drivers.

No complete B/E guard is claimed before W_o/L_o/X and the other standard
writers are joined. JSON result construction, private answer/annotation
formatters, logging and downstream report consumers retain their own owners.
Normal numeric conversion, valid numeric locale, finite timing values when
valid JSON is claimed, well-formed metadata and source/native correspondence
remain the existing named premises. A small encoded output does not establish
successful services, correct proof attribution or complete obligation discharge.

The Oracle, installed tools and pins, current admission, and process-global
e<=2/two-save-callback/three-save allowance are unchanged. Ordinary physical
memory, stack and I/O sufficiency remains trusted; no aggregate gate is added.
Production #88–#94 remains unstarted, #119/#153 incomplete and PR #121 draft.
Lead model/effort and token telemetry are unavailable; the evidence record
distinguishes this root-authored candidate from its later independent review.
