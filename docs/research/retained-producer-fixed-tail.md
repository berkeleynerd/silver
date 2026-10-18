# Fixed Why3 initial splitting and registration

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119).
The five fixed-library inputs now have a **conditional capacity argument through
initial `split_goal_wp_conj` and goal registration**, ending at the first entry
to `Gnat_checks.iter`, before its body schedules any check. This extends the
[accepted Per_Check/private-driver prefix](retained-producer-prefix-per-check.md).
It does not close later driver transformations, backend task printing, solver
representations, response/session serialization or whole-pipeline capacity.

**Scope correction to historical task wording.** The byte-pinned
[first two task bounds](retained-producer-fixed-check-spines.md#matcher-and-splitting-on-these-two-formulas)
and [five-input table](retained-producer-fixed-paths.md) call `G` terminal backend
or Why3 tasks. The applicable quantity is the
[reported check-tree leaf count](retained-producer-response.md#selected-session-and-success-shape),
after registration filters. Input_Is_Valid produces **four raw split tasks**;
three are unlabelled trivial goals discarded by registration, leaving **one
registered goal**. Thus its reported `G <= 1` remains valid, while reading that
bound as covering every raw split task is incorrect. The historical files and
their evidence identities are preserved; this record supersedes that broader
wording. The concrete classification and source predicate are below.

The [offline evidence packet](../evidence/retained-producer-fixed-tail-20261018/README.md)
retains the five-case capture, the separate one-input classification diagnostic,
their managed-run records, complete relevant sources, instruction bytes,
arithmetic operands and replay checker. No installed tool, production
configuration, source-admission rule or proof pin changed.

## Exact launch and endpoint

The starting point is the accepted prefix implementation `94a60ed280`, its
correction `5e5970478d`, and independent review `e136c52790`. The private drivers,
fresh `--proof per_check`, `--steps 0 --timeout 0 --counterexample off`, selected
cvc5/z3/altergo provers, five native JSON inputs, imported source closure,
executable/plugins and `OCAMLRUNPARAM=s=256M,h=16M,M=1000` are unchanged.

The earlier launch omitted `--socket`; `stand_alone` defaults to false and
`socket_name` to the empty string (`gnat_config.ml:51–52,242,681–683`). That was
sufficient only because its endpoint preceded `Gnat_checks.init`'s body.
Continuing it unchanged would not establish a server connection. This capture
adds `--socket /tmp/silver-producer-fixed-tail-20261018/<case>/server.sock`, with
a real, separate idle server in each fresh case directory:

```text
why3server --socket server.sock --single-client -j 1
```

The server uses the installed sibling binary, 96,904 bytes, SHA-256
`143e182d167d3e290c974770d0b84b5f59cf70bf331de5208a36bd650b386a80`,
and environment `PATH=/usr/bin:/bin`, `LC_ALL=C`. The client changes to the
socket's parent directory and connects using the 11-byte basename
(`prove_client.ml:20–51`); no request is sent by `connect_external` (`:110–113`).
Successful OS/socket operations remain external contracts, not a theorem about
the entire server's capacity.

This is a new launch, including pathname lengths. The complete protected
allocation interval was measured again from the first Why3 module; no assertion
that the old prefix allocation is unchanged is used. Every case's allocation
before the old endpoint increases by 27 words. The exact earlier semantic
operand streams are prefixes of the new streams; the checker verifies this
equality after capture rather than assuming it during transfer.

The new endpoint is `camlGnat_checks__iter_2373`, static address `0x530a10`,
corresponding to `gnat_checks.ml:507–509`, the HCheck fold followed by List.iter.
It is not the separate GoalSet iterator. Its first instruction has not executed
at the snapshot. The old endpoint remains an intermediate allocation/count
checkpoint. The new endpoint is reached once, after all registration and the
`gnatwhy3.register_vcs` timing finalizer, before any scheduling-loop body.

The debugger observes memory/registers and places guarded breakpoints; it calls
no inferior function, writes no inferior data, and fabricates no return value or
solver response. It retains the thirteen collection/request/settings guards,
three complete semantic-count observers, actual-open observer and thread/fork/
exec guards. Ten additional forbidden entry points cover scheduling, driver
preparation/printing, `call_on_buffer` and client request submission. Every
five-case capture reaches the endpoint with zero protected guard hits, zero
forbidden calls and zero new threads.

After the endpoint, the debugger deliberately kills the stopped client. Each
single-client server then exits **1**, naturally, with no forced cleanup and
an empty log. This is the retained teardown result, not an asserted server
exit-zero success: `close_client` calls `shutdown_server`
(`server-unix.c:593–625`), which reaches `logging_shutdown` and its unconditional
`exit(1)` (`logging.c:38–44`). No prover job was submitted.

## Source dispatch covered by the interval

All source references below use Why3 revision
`9390baf120ef260547dfa14f08e11c890b203d9c`. Twenty-five complete Why3 source files
join byte-for-byte to the accepted prefix's source archive; two additional
server sources explain teardown. Relevant installed-source behavior remains
the same explicitly trusted premise as in the accepted prefix.

`gnat_main.ml:332–350` returns from `init_cont`, completes the initialization
timer, installs the signal handler, and registers VCs before calling the
endpoint iterator. `normal_handle_one_subp` first calls `init_subp_vcs`, then
`iter_leaf_goals(register_goal)` (`:291–295`). The fresh Per_Check strategy has
only `split_goal_wp_conj`; `apply_split_goal_if_needed` schedules it once when
the fresh proof node has no existing transformation (`gnat_checks.ml:738–754`).
`Gnat_scheduler.idle` calls its callback synchronously until false. Consequently
this initial transformation completes before registration, rather than being
deferred until the later event loop.

The controller applies the transformation, grafts its returned tasks, updates
the transformation's proof state and returns (`controller_itp.ml:780–817`). The
graft creates a transformation ID and maps indexed proof-node construction over
the physical result list (`session_itp.ml:728–736`). Every new proof node stores
its task, SV6 checksum and shape (`:679–694`). Captured dispatch is exactly one
`split_goal_wp_conj` call with no arguments and one graft per input.

The compound transform is concrete (`gnat_split_conj.ml:316–325`):

```text
Split_goal.split_goal_right
  → unfold_trans
  → Gnat_rewrite.elim_to_of_array
  → split_conj
```

This work traverses more than the goal formula. `unfold_trans` scans the task's
declaration context for marked definitions, then calls `unfold_right 1` on the
goal. `elim_to_of_array` is a `Trans.decl` traversal rewriting proposition
declarations throughout the context (`gnat_rewrite.ml:141–149`). Before dispatch,
`get_task_name_table` builds naming tables (`session_itp.ml:313–322`):
`Args_wrapper.build_naming_tables` folds all declarations/meta arguments, assigns
unique names and builds a coercion map (`args_wrapper.ml:175–205`). Its name
suffixes use the existing occupied-spelling lifetime charge; `Coercion.add`
constructs physical nested maps and composition records without a new semantic
integer accumulator. Empty transform arguments do not bypass this table build.

## Allocation and arithmetic composition

The same fixed-input, relevant-source-behavior, runtime/library, allocator/OS,
no-external-interruption and no-collection/cache premises from the
[complete prefix](retained-producer-prefix-composition.md#one-context-and-one-conditional-predicate)
apply to the extended interval, with this explicit socket launch and successful
connection. They remain conditional contracts, not binary attestation or an
unconditional physical-memory guarantee. The five rows are separate processes.

| Input | Words through old endpoint | Additional words | Complete protected words | Raw split tasks | Maximum task-context declarations |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 86,627,724 | 42,220,037 | 128,847,761 | 64 | 1,044 |
| Put | 85,930,292 | 31,583,408 | 117,513,700 | 53 | 1,044 |
| First_Or_Default | 82,025,353 | 6,639,265 | 88,664,618 | 32 | 536 |
| Input_Is_Valid | 78,586,342 | 768,548 | 79,354,890 | 4 | 434 |
| Is_Message | 77,781,957 | 580,241 | 78,362,198 | 3 | 368 |

Task-context lengths count physical `task_prev` chains, not expanded formula
occurrences or printer bytes. The read-only observer checks the OCaml list,
option and six-field task-node layouts and rejects cycles. These counts give
context for the selected transformation; neither these dimensions nor `G/R`
replace the complete lifetime account.

The maximum protected allocation is **`W = 128,847,761` words**. With the largest
startup overcount 43,222 and unchanged static-image allowance 2,152,771,
**`B = 131,043,754` words**. The minor heap is `2^28` words; all three protected
snapshots retain the trigger state, unchanged collection statistics and table
margins required by the accepted no-collection argument. The same identity,
synthetic-line, physical-container, dependency-rank, projection-height and
byte-length inequalities are re-evaluated with this larger W/B. In particular
`W+1 < 2^47-1`, `B < 2^27`, and `16B+2 = 2,096,700,066 < 2^62-1`.

The additional reachable-operation partition is as follows:

- Fresh transform/proof-node/proof-attempt IDs, names, hashcons tags, shape
  identifiers, maps/sets, checksum state, naming/coercion tables and transient
  reconstruction all use the prior allocation/physical-container charges.
  `List.mapi`'s index follows its physical task list. Registration's
  `total_nb_goals` and `nb_checks` increments correspond to fresh goal/check
  entries (`gnat_checks.ml:184–226`), not unfolded term multiplicity.
- `Split_goal.M.degree` takes only 0, 1 or 2. Its `trivial n` recurs only when
  the preceding result is at most 1, so `n + degree x <= 3`
  (`split_goal.ml:49–50,183–184`). `unfold_right` starts at 1 and decrements only
  when positive; its depth counter stays in `{0,1}`. Other split accumulators
  are represented lists/trees, not unchecked numerical formula-size totals.
- Binder opening, substitutions, triviality checks and explanation searches
  exercise the same three semantic occurrence-count sites. The retained
  streams contain **514,906** operations, **368,647** after the old endpoint;
  mathematical replay of every addition/product has maximum **47**. Physical
  W/B does not justify this bound; the count-origin argument and complete
  guarded operand coverage do.
- GP_Check/GP_Pretty_Ada identifiers and location line/column strings pass
  checked integer conversions (`gnat_expl.ml:424–451`, `gnat_loc.ml:82–118`).
  The selected transforms copy attributes and add fixed `GP_Inlined`; they
  create no unchecked decimal label counter. The same successful fixed
  conversion requests transfer under the source and earlier-counter premises.
- `Debug.stats` is enabled. Initialization, initial transformation and
  registration timing finalizers now execute. Each `old_n+1` allocates a fresh
  timing pair (`debug.ml:162–173`) and is charged to W. Clock values remain
  floats here; no conversion into an integer size or count occurs in this
  segment. Later timer conversion/serialization obligations remain separate.
- Checksum/shape encoding remains SV6 `const_v2`, including newly grafted nodes.
  Backend/general numerical term printers are not selected. The four selected
  transform components and registration do not call reduction-engine
  normalization; the accepted complete-source caller argument still excludes
  `term_size` and its normalization growth arithmetic. Name generation does
  not invoke those term printers. The nonallocating Introduction hashcons
  instance remains outside this segment.

Together with the unchanged prefix partition, use the same simultaneous
first-event argument: before a hypothetical first collection/request, unchecked
counter wrap or bad checked representation request, the selected fixed source
execution has the retained control flow and requests, modulo consistent
addresses and the specified layout. The guards/trigger margins exclude a first
collection; allocation/structure charges and replayed operands exclude first
counter wrap; exact successful checked requests exclude a first failed
representation conversion. This is an inspected source argument supported by
the retained observations. The checker validates its identities, numeric
premises and classifications; it is not a machine proof of source semantics.

## Four raw goals, one reported goal

The additional Input_Is_Valid diagnostic uses a fresh scratch directory and
the same fixed input, private driver bytes, source/executable identities,
runtime options and ten no-scheduling guards. It stops at the same endpoint.
It observes `register_goal`, the returned triviality and label-search values,
every full string passed to `Gnat_expl.read_label` during registration, and the
actual `add_to_check`/`set_not_interesting` choice. Endpoint reads independently
check the goal map and each check's toplevel sets. Instruction bytes and source
record layouts justify all decoded registers, stack slots and fields.

| Proof-node ID | `is_trivial` | Selected check | Actual registration |
| --- | --- | --- | --- |
| 1 | true | None | not interesting |
| 2 | true | None | not interesting |
| 3 | false | ID 0, VC_PRECONDITION | added to check, toplevel |
| 4 | true | None | not interesting |

All four label searches read `vc:annotation`, `expl:precondition` and
`hyp_name:Requires`, with `rac:call_id:54`, `55`, `56`, `57` respectively. Only
goal 3 additionally reads:

```text
GP_Shape:if__return__call_is_message__call_argument
GP_Check:0:VC_PRECONDITION:silver_arguments.adb:14:43
```

The selected check has `already_proved=false`. At the endpoint, `goalmap` and
the check's `toplevel`, `to_be_scheduled` and `to_be_proved` sets contain only
goal 3; `not_interesting={1,2,4}`, `total_nb_goals=nb_checks=1`.

The source bridge is exact: `register_goal` first creates the built-in trivial
proof record when applicable, discards `(true,None)` and already-proved labels,
and calls `add_to_check` for the remaining labelled goal
(`gnat_main.ml:50–73`). These built-in trivial records are source behavior, not
responses manufactured by the observer. `add_to_check` applies line/region
filters and adds the survivors to `check_rec.toplevel`
(`gnat_checks.ml:201–226`). `Save_VCs.check_to_json` starts only from that set
(`:940–979`); it does not start from all grafted tasks. Fresh Per_Check has no
successor split after `split_goal_wp_conj`. Under the existing normal all-proved
response premises, the single registered leaf therefore supplies `G <= 1`.
No response, solver output or task-printer execution was needed to classify it.

This repairs the historical wording; it changes no reported-G, R or dependent
response-byte constant. It supplies no general inference that unlabelled leaves
can always be ignored for capacity: their transformations, checksums, trivial
proof records and registration work are included in W/B above.

## Actual next dispatch and remaining joins

The packet expands the selected driver's imports in place, strips nested
comments while preserving strings and the lexer-special `(*)` operator, and
retains the exact ordered transform directives with file/line provenance.
`driver_lexer.mll:115–148` and `driver.ml:125–153,250–270` justify this order.
The selected records are:

| Prover | Configured printer | Ordered transformations |
| --- | --- | --- |
| cvc5 | `smtv2.6` | 15, retained in `result.json.driver_dispatch.cvc5` |
| z3 | `smtv2` | 13, retained in `result.json.driver_dispatch.z3` |
| altergo | `smtv2.6par` | 12, retained in `result.json.driver_dispatch.altergo` |

These are the private no-step-parser drivers actually opened, not a generic
installed driver guess. Their transform lists have not executed at this
endpoint. `Driver.prepare_task` first adds driver-requested theory/meta context,
then folds these transforms in order (`driver.ml:330–393`).
`print_task_prepared` dispatches the configured printer, builds printing info
and formats the prepared task (`:395–408`). `prove_task_prepared` allocates its
buffer, prints/flushes, derives the filename, and calls `call_on_buffer`
(`:449–470`). These source-selected stages identify the next joins; the current
capture makes no allocation or formula-size claim for them.

The remaining obligations include the scheduler state and all selected driver
transform lifetimes/counts, formula/context expansion, printer byte and numeric
formatting domains, server/process representations, solver internals, captured
solver-output bytes O, result handling, final timing conversions, session and
response serialization, and production-launch adoption. G/R bounds alone close
none of the transformed-context or printer-size obligations. This packet is a
completed initial-split/registration segment, not a completed fixed tail.

Selected worker model/effort: GPT-6 Astra, Extra High; runtime confirmation and
token/cost measurements are unavailable. The five-case managed run
`20261018T182701-4554d278376e` took 83.367528516 seconds; the single-input
classification run `20261018T183727-b79953f86b46` took 6.796294796 seconds. Both
reserved one worker, ran serially, and executed zero solvers. No successful
five-case run was repeated; the diagnostic answered the separate raw/reported
goal question. Independent review remains the integration step.
