# Independent review: saved artifacts and current results

2026-10-20 UTC, owner-authorized #119 / #153 research.

**Accept the conditional dependency argument at
`75bc4013626acf4c4e734d1dfe66a571e8da6d80`. No material defect found.**
For the specified fresh Per_Check, CE-off, automatic, non-replay continuation,
faithful saved XML/shapes/prover-number correspondence is not an additional
premise for the current proof-result projection. This acceptance does not
remove save execution, valid live representations, counter/frame/error or
report obligations, and does not classify save as observation-only.

## Target and independence

The exact target is the twelve-file addition against
`b1c0d89f7b652a1c12e957caa986887be890786e`: the
[source argument](../research/retained-why-save-artifact-dependency.md) and
[its packet](../evidence/retained-why-save-artifact-dependency-20261020/README.md).
All twelve review inputs match the target commit byte for byte; the
[review manifest](../evidence/review-why-save-artifact-dependency-20261020/inputs.json)
retains their hashes. Review used the isolated checkout
`tmp/why-save-artifact-dependency-review-20261020`, branch
`review/why-save-artifact-dependency-20261020`, created directly at the target.
Author files were not edited.

Selected independent reviewer: **GPT-6 Astra / Extra High**, assigned by the
lead. Runtime model/effort confirmation and token/monetary measurements are
unavailable. The reviewer did not author this target. The reviewer separately
authored the J/L shape-transfer packet; none of its numeric conclusions is
needed to accept this dependency argument. No subdelegation occurred. The
child's live harness goal is null; the lead supplied the active bounded
authorization, and owns integration/publication.

The source input is the retained Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`, SPARK
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, and three exact current Silver
files. The existing relevant-behavior correspondence and accepted
ordinary-ending control/native-frame/callback premises remain conditional
inputs. This review establishes no new installed-binary correspondence,
native capacity, source admission or Oracle amendment.

## Challenged dependencies

Freshness is indispensable. `Gnat_checks.init_cont` at `gnat_checks.ml:380–453`
loads an existing session when `not force` and its directory exists. The
fresh branch constructs an empty session, adds the source and returns at
line 416 before `reload_files`. `replay=false` does not choose that branch.
The packet correctly retains actual freshness as an input instead of
generalizing from the replay flag. Initialization precedes installation of
the save-on-SIGINT handler (`gnat_main.ml:331–355`).

The selected proof path takes the task from live `session_raw_tasks`
(`controller_itp.ml:412–440`). It does not reconstruct proof input from a
newly saved file. The automatic/CE-off/non-replay restrictions exclude
interactive scripts, reload/pairing clients and CE successors. This is a
selected-caller argument, not a conclusion for arbitrary controller clients.

The report dependency chain is explicit. `session_proved_status` uses
registered checks, live proof-node validity, attempts and transformations
(`gnat_checks.ml:1110–1127`). Successful statistics use live, nonobsolete
valid attempts or proved transformations (`:767–861`). Check JSON traverses
live attempt/transformation records and prints prover record **names**
(`:899–979`), without reading serialized numeric IDs. `Gnat_report.register`
and `print_messages` copy and print this state (`gnat_report.ml:59–85,185–234`).
The private session record/interface and field-use census support navigation;
token absence alone is not treated as the transitive dependency proof.

The downstream consumer is the captured result protocol. GNAT2Why spawns
gnatwhy3 with stdout/stderr directed to a temporary file, waits, and parses
that JSON (`gnat2why-driver.adb:243–255,1219–1300`). It does not use the wait
success Boolean as proof success. Result/error/check-tree fields are consumed
by `Parse_Why3_Results`, and the `.spark` report is constructed from that
bookkeeping (`gnat2why-error_messages.adb:632–649,1226–1336`;
`gnat2why-driver.adb:351–382`). The current Silver adapter invokes native
gnatwhy3; Silver's gate reads Main and the four selected library reports
before build (`silver_image_adapter.adb:57–120`; `silver.adb:75–95,162–215,
348–386`; `silver_libraries.adb:42–79`). These operations do not read Why3
session XML or shapes as proof evidence. The current mandatory report gate
is not confused with #88's proposed optional-confirmation workflow.

Save writes are broader than artifact bytes, and the packet correctly keeps
that distinction. `save_session` resets/recomputes shapes and updates
`shape_version`; serialization mutates a separate prover-ID table. It also
calls `th_proved`/`file_proved`, which may insert missing status-cache defaults
(`session_itp.ml:752–764,1939–2244`). Inspection of upward status propagation
(`:798–858`) confirms these are distinct from `pn_state`/`tn_state`, which
the current checks consume. This is not an all-state preservation claim.
`clear_only_shape` leaves `session_sum_table` intact (`:198–201`), as the
packet states. Fresh identifiers, allocations, callbacks, timings and
diagnostics remain live effects; no whole-JSON equality or capacity result
is inferred from artifact nondependence.

The strong inverse shape/reference invariant is not tested by output:
`write_shape_to_file` iterates reverse-map values, while `string_of_shape`
prints the integer list (`termcode.ml:265–269,587–590`). Partial nested saves
may therefore produce inconsistent artifacts without this specific
serialization step detecting the inconsistency. Current reporting does not
then use that pair. Operational container validity, finite values, termination,
source/frame behavior and bounded output still require proof; weaker
operational invariants cannot simply be assumed in place of the stronger
artifact invariant.

Later reuse genuinely depends on the saved artifacts. The XML header maps
integers to provers; proof entries resolve through that map and stored
`valid` results become `Call_provers.Valid` (`session_itp.ml:1009–1049,
1103–1132,1222–1240`). The loader pairs shape lines with XML goals and copies
the dictionary (`:1260–1442`). `Goal_Bound_Shape` dereferences saved indices;
reload merges using checksums, names and shape pairing before attaching old
attempts (`:1462–1479,1610–1620,1644–1657,1701–1740`;
`controller_itp.ml:246–269`). Warning/fallback arms are not a general repair
or soundness theorem. The fresh-run conclusion does not authorize trusting
corrupted caches in those later clients.

## Control and policy boundaries

Save is synchronous before `report_messages` (`gnat_main.ml:270–279`). An
escaping save/timing exception prevents the normal report continuation; the
outer handler reports/aborts or reraises. Error JSON contains `error`,
`internal` and empty `results` (`gnat_util.ml:4–22`), and the downstream error
handler is fatal. The scheduler handler does not retry ordinary ending.
The packet correctly separates this control dependence from dependence on
the completed files' meaning.

SIGINT can save during preparation/proof. Under the accepted callback result,
its handler exits or raises rather than normally resuming an interrupted
Buffer operation. A higher catch may continue after that exception, retaining
partial writes. Neither transactional rollback nor reliable detection of
every caught interruption is available here. The packet preserves these
limits and does not add a no-signal premise. A finite representation failure
on admitted source is not reclassified as physical exhaustion or proof
success because it occurred while saving cache data.

The retained #88 criterion requires both noninterference with required proof
work and a reliable detection path. This packet supplies no such blanket
classification for save; the named paths through SIGINT/preparation and
ordinary-ending exceptions remain open operational obligations. That is
consistent with the current Oracle and with the preceding ordinary-ending
review's requirement either to establish a needed artifact invariant or to
prove its dependency unnecessary. The accepted result discharges only the
latter dependency question for this current projection.

## Verification and disposition

One focused author checker ran without write mode and passed in
**0.437933144 seconds**. It checked 22 retained source members against their
origins, 16 input identities, 47 exact anchored excerpts, 16 dependency rows,
12 census tokens/76 occurrences and selected caller ordering. The complete
[output](../evidence/review-why-save-artifact-dependency-20261020/check-output.json)
is retained. This checker is a static retention/interface check; the source
reasoning above is the independent semantic assessment.

The measured checkpoint interval was 08:13:41–08:18:10 UTC, **269 seconds**,
including a brief interleaved repair of the separate shape-transfer interface;
it is not exclusive artifact-review CPU time or whole-team cost. Preliminary
target-note reading and final report authoring are outside that interval.
Actual host is Linux x86_64. No native target, debugger, compiler, solver,
proof/public evaluator, capture, broad predecessor replay, source fetch,
GitHub write or CLI-memory update occurred. Required target rework: none.

The bounded result is accepted for integration. It does not complete #153,
save capacity, later-cache assurance, identifier-counter safety or #119.
