# Why3 saved artifacts and the current proof/report path

2026-10-20 UTC, Linux x86_64, authorized research #119 / #153,
base `b1c0d89f7b652a1c12e957caa986887be890786e`.

For the selected **fresh, Per_Check, CE-off, automatic, non-replay** continuation,
the saved XML, shape dictionary/references and serialized prover IDs are not
inputs to the current proof-result JSON or its GNAT2Why/Silver consumers.
Their faithful serialization is therefore not an additional semantic premise
for that current continuation. **Save execution remains required:** it precedes
report construction, can interrupt ongoing proof through SIGINT, consumes
shared representations, and can fail before the producer emits any result.
This result removes no save capacity, typed-state, exception or report obligation.
Independent review is pending.

## Scope and dependency criterion

The [packet](../evidence/retained-why-save-artifact-dependency-20261020/README.md)
retains complete selected source files, exact excerpts, a read/write/caller map
and focused static checks. It reuses the accepted
[ordinary-ending control](retained-why-ordinary-ending-control.md),
[its review](../reviews/review-why-ordinary-ending-control-20261020.md),
[save outcomes](retained-why-session-save-outcomes.md), and
[driver envelope](retained-producer-driver-envelope.md).
No original process's numerical forest/atom bounds are generalized here.

The selected source revisions remain Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and SPARK
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. Relevant behavior correspondence
retains the [existing boundary](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary).
Retained source identity does not newly establish every installed binary input.
The ordinary-control native-frame, callback and finite well-formed live-input
requirements continue to apply; none is replaced by saved-file correctness.

[#88's dependency test](https://github.com/berkeleynerd/silver/issues/88), retained
in [the issue snapshot](../evidence/retained-why-save-artifact-dependency-20261020/issue-88.json),
permits observation-only treatment only when a named boundary cannot prevent
or alter required proof generation/discharge **and** has a reliable detection
path. [Current planning](../unbounded-programs.md#confirmation-only-tool-limits)
says the same. Absence of a later artifact read satisfies neither requirement
for all the operations used to produce that artifact. #88's future classifier
and optional-confirmation design are not implemented or adopted by this packet.
The current Silver implementation still checks proof results before building.

## Actual ordering and current consumers

`Gnat_checks.init_cont` loads an existing session only when `not force` and the
session directory exists (`gnat_checks:380–453`). Otherwise it creates an empty
session and adds the input file. Freshness is an existing selected-input
condition, separate from `replay=false`: an ordinary later invocation can load
and merge a saved session **without** `--replay`. The chosen fresh branch returns
before `reload_files`. Initialization precedes installing the save-on-SIGINT
handler (`gnat_main:331–355`). The selected entry must really take this branch;
an arbitrary pre-existing proof directory is outside this result.

Selected prover preparation obtains `Session_itp.get_task` from the live
`session_raw_tasks`, then calls `Driver.prove_task`, `prepare_task` and
`prove_task_prepared` (`controller_itp:412–440`, `driver:490–494`). It does not
reconstruct a task from the XML or shape file. Interactive script reuse and
controller reload/replay clients are outside the accepted automatic envelope.

On scheduler ending the order is fixed (`gnat_main:270–279`):

1. Remove valid CE attempts; CE-off makes the CE predicate false.
2. Execute the timed `C.save_session c` synchronously.
3. Iterate `report_messages c` over the registered checks.
4. Collect escaped diagnostics and print the final JSON.

`report_messages` uses the live check registry, goal/transformation links,
`pn_state`/`tn_state`, proof-attempt records, obsolete flags and prover records.
`session_proved_status` checks live validity; `extract_stats` selects successful
live attempts; `check_to_json` traverses the same live forest and emits prover
**names**, answers, times and steps (`gnat_checks:767–861,899–979,1110–1127`).
The unproved branch reads live attempts and registered extra information.
CE and manual-script payloads are absent in the selected mode; even their
generic branches use live records, not the saved session XML.

`Gnat_report.register` copies these values into `msg_set`; `print_messages`
serializes that table plus timings, entity and warnings (`gnat_report:59–85,
185–234`). No reader in this current projection accesses `session_prover_ids`,
the shape dictionary, per-goal saved shape lists or the serialized files.
The abstract `Session_itp.session` interface and complete local field-use
census support this separation; the source argument, not a token-absence test
alone, establishes which exported operations the callers reach.

GNAT2Why captures gnatwhy3 stdout/stderr to a temporary result file, waits, and
parses that file (`gnat2why-driver:243–255,1219–1300`). Its collector does not use
the wait-success Boolean as proof success. `Parse_Why3_Results` reads the JSON
`results`, `result`, identities and check tree; an `error` calls the fatal error
path (`gnat2why-error_messages:632–649,1226–1336`). `errout_wrapper:135–141`
retains the check tree and unproved status in the report; `Create_JSON_File`
writes the `.spark` report (`gnat2why-driver:351–382`). None loads Why3 XML/shapes.
The current Image adapter forwards execution to native gnatwhy3 rather than
turning saved-session contents into results (`silver_image_adapter:57–120`).

Silver creates a fresh build workspace, reads Main's `.spark` report and the
four selected library-unit reports, applies the complete-report policy, and
only then builds (`silver.adb:75–95,162–215,348–386`;
`silver_libraries.adb:42–79`). It does not audit `why3session.xml` as proof
evidence. This describes current source dependencies; it neither endorses the
current finite prover settings for the proposed family nor adopts the research
invocation or #88 workflow.

## What saving writes, and what consistency is needed

The exact [dependency map](../evidence/retained-why-save-artifact-dependency-20261020/dependency-map.json)
records callers, reads, writes, exceptions and successors. The distinctions are:

| State or artifact | Actual save behavior and current requirement | Later reuse requirement |
| --- | --- | --- |
| Raw tasks, goal/transformation links, attempt records, goal/transformation proved states | Direct save reads these; it does not graft tasks, replace attempts or write `pn_state`/`tn_state`. Their correctness and complete coverage remain essential for current proof/reporting. | A reload must faithfully reconstruct and match retained attempts to new tasks. |
| Theory/file status caches | `th_proved` and `file_proved` can populate missing `th_state`/`file_state` entries (`session_itp:752–764`). Do not claim save writes only artifact fields. Current check validity/JSON does not read these upper-level caches. Their operations and exceptions still count. | Serialized upper-level status is part of loaded session state. |
| Global shape maps, `n`, per-goal bound/old shapes | `clear_only_shape` resets them; uniformization recomputes them. Nested interrupted saves may leave inconsistent map relationships or references. Current report does not consume their meaning. Concrete map/list/string/integer validity and bounded execution remain required. | Dictionary line order, referenced indices and their association with the intended goal must agree for meaningful matching. |
| Per-goal checksums | `clear_only_shape` does **not** clear or recompute `session_sum_table`. Save reads checksums, with a default for absence. Current result projection does not read them; diagnostic session printing can. | Checksums and goal association participate in obsolete/matching decisions. |
| Serialized prover numbers | `get_prover_to_save` mutates the separate `session_prover_ids` map and builds a local prover context. Current proof/report uses prover records as keys and names as output, not these numeric IDs. Counter/search/container capacities remain required. | Header IDs must resolve each `<proof prover=...>` to the intended prover and default limits. |
| XML, shape files and backups | Save renames existing files, opens/truncates outputs, prints and closes. Current proof/report never reads their completed contents. Calls, channels, pathname/format buffers, failures and output-resource consumption remain on the path. | Parseability, complete goal order, checksums/shapes and header/proof association are required by a later loader; partial output is not certified reusable. |
| `session_dir_for_save` | In the pinned implementation it is declared and assigned, with no read; it is not exported. | No use in this source is inferred merely from its name. |
| Fresh identifiers, runtime/formatter state, timings and diagnostics | Save traversals can allocate/register fresh identifiers and affect shared runtime state. Timed saving updates the reported timing map. These effects are **not** covered by artifact nondependence and retain their existing capacity/frame/error obligations. | No later-cache argument can refund consumed counters or resources. |

In particular, neither `Gshape.write_shape_to_file` nor `string_of_shape`
checks the inverse dictionary/reference invariant: the former prints the
reverse map's values, the latter prints the integer list (`termcode:265–269,
587–599`). Serialization can therefore return without certifying a usable
saved pair. Current reporting does not subsequently validate or depend on that
pair. Similarly, the XML serializer sorts numeric prover IDs, but the JSON
serializer obtains prover names directly from live records.

Thus an inverse shape-map theorem, exact serialized shape association, unique
serialized prover-number correspondence and successful future reload are not
caller premises for the selected current result projection. This does not waive
the structurally valid containers, represented integers/strings, live key coverage,
finite traversal and exception behavior required to execute save itself. A
capacity argument may use weaker operational invariants instead of a faithful
artifact theorem, but must actually establish those weaker invariants for all
reached partial/resumed states. This packet supplies no numerical replacement.

## Where a later load depends on the artifacts

`load_session` reads XML with `read_file_session_and_shapes`, builds the session,
and copies the global dictionary (`session_itp:1260–1442`). Shape lines are
paired with goal elements in XML traversal order. SV6 bound-shape lists are
decoded and stored; `Goal_Bound_Shape` later dereferences their indices during
pairing (`:1462–1479`). Missing or malformed shape files sometimes cause warnings
and fallback, but that behavior is not a general artifact repair or safety proof.

The XML header creates an integer-to-prover map. Each proof entry resolves its
integer through that map and reconstructs a proof attempt (`:1103–1132,
1222–1240`); saved `valid` results become `Call_provers.Valid` (`:1009–1049`).
`reload_files` reparses and merges with the old session; checksum equality and
shape pairing determine associations/obsolescence before old attempts are
attached (`controller_itp:246–269`; `session_itp:1610–1620,1644–1657,
1701–1740`). Those are real correctness dependencies for reuse. This packet
does not justify trusting corrupted artifacts, disabling those checks, or
admitting reuse under the fresh-run conclusion.

## Exceptions, signals and the remaining obligation

Save has no encompassing retry or channel-cleanup `Fun.protect`
(`session_itp:2172–2244`). Its timing wrapper does run a finally action, whose
failure may replace the original exception (`debug:168–173`). A save failure
escaping ordinary ending prevents `report_messages`; the outer GNAT catch
formats an error, emits `error`/`internal`/empty `results` and exits, or reaches
uncaught/exit failure handling (`gnat_main:355–360`, `gnat_util:4–22`). The
scheduler's `Exit` handler does not protect or retry the ending body.
Missing/malformed/error results are not successful proof evidence for either
the current consumer or the proposed strict confirmation audit.

SIGINT can invoke the same save **during required preparation/proof**, not only
at ordinary ending (`gnat_main:298–309,335`). The accepted control result says
the handler exits or raises rather than normally resuming an interrupted Buffer
operation; a higher catch may consume its exception and continue with changed
state. It does not provide transactional rollback, faithful artifacts, complete
proof attempts or a reliable indication that every caught interruption occurred.
For example, the accepted `Trans.current` bare-`Not_found` continuation is a
specific cache-miss result, not permission to ignore arbitrary save exceptions.

An explicit external interruption is an environmental event, not a finite
representation overflow and not proof success. A `Failure`/`Sys_error`/signal
or missing result alone does not establish its cause. Conversely, reaching a
required finite representation boundary on admitted source remains a defect;
it is not excused by saving cache data or by hypothetical physical exhaustion.
No no-signal premise or new external-tool assumption is introduced. The accepted
control/caller obligations and the Oracle remain unchanged.

There is therefore **no blanket #88 observation-only exemption for save**.
The concrete unresolved path is
`SIGINT during prepare_task -> save_session -> shared representation/error`
or `ordinary ending -> timed save -> exception -> no normal result JSON`.
Even a boundary isolated to a genuinely completed post-proof save would need
its own source/phase proof and reliable detection before #88 could classify it
as observation-only. This packet provides neither that detector nor a universal
late-save success theorem. The remaining #153 joins still include actual-forest
numeric charges, all required save representations and caller/error interfaces;
later driver/printer, solver/server/result/report and complete #119 obligations
remain open.

Selected author setting: GPT-6 Astra / Extra High; serving-runtime confirmation
and token/cost measurements are unavailable. The packet records actual elapsed
and static-check time. No native/proof/solver/evaluator/capture run, predecessor
checker replay, source fetch, toolchain change, GitHub write or CLI memory update
occurred.
