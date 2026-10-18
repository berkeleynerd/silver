# Retained Why session-save input and observer specification

Research [#119](https://github.com/berkeleynerd/silver/issues/119), Linux x86_64,
2026-10-18. **The retained capture cannot yet supply a concrete session-save
charge.** Its runtime signal-handler root, exit-hook root and registered-statistics
root are unobserved. The fixed initialization path is now narrower: this capture
started with a **fresh session**, not the five-goal historical XML session.
No numeric `B_binders(S)` or `R` is established. The accepted accounted endpoint
remains **61,641**, and the accepted conditional two-save bound is unchanged.

The [packet](../evidence/retained-why-session-save-capacity-20261018/README.md)
freezes exact missing-input evidence and a restricted observer specification for
parent coordination **before execution**. No target, debugger, objdump, compiler,
solver, build or proof run was performed. This is a bounded fallback deliverable,
not closure of session-save or complete callback capacity.

## What the retained bytes establish

The capture is the accepted PID **74171** first Input_Is_Valid/cvc5
`inline_trivial` entry, using executable SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368` and the
121,828-byte JSON with SHA-256
`d146b75d28832260c49de3d8eb5f816c8481595127dc56dfaf3512cbdb6a4b2d`.
Its private counter is 60,496. The accepted 1,145-registration input contribution
is reused without rerunning its successful graph/counter proof.

[`capture-coverage.json`](../evidence/retained-why-session-save-capacity-20261018/capture-coverage.json)
records a scan of **all 785,851 persisted raw reads**. None overlaps these
eight-byte runtime words:

| Root | Runtime address in PID 74171 | Needed join |
| --- | --- | --- |
| `caml_signal_handlers` | `0x560382547ef0` | SIGINT closure → controller → session |
| `camlStdlib + 0x338` | `0x5603824e98d0` | Exit-function ref → installed exit-hook chain |
| `camlWhy3__Debug + 0x128` | `0x5603820c51c0` | Registered-statistics ref → printer closures |

The load bias is joined through the observed Ident module and the pinned ELF
symbol table. `caml_signal_handlers` is in BSS: its ELF storage does **not**
provide its later runtime value. The other two initialized module fields also
require runtime observations. The absence claim concerns these exact root
words; it does not claim every descendant byte is absent from all other graphs.

The retained complete logical graph contains **326,456 blocks**, rooted in
244 inline-input declarations and 6,704 Hsdecl objects. It has no session-root
contract. Hsdecl residency does not identify the session's file roots, task
membership, proof-node lookups or traversal multiplicity. The driver's original
input task is `140564273535504`, with a 434-node task chain; the selected
inline-entry task is `140564268770520`, with 512 ordered tdecls. The recorded
driver prefix is `counterexamples_dependent_intros`, then `inline_trivial`.
Neither task address supplies the other proof nodes' raw-task mapping.

## Fixed fresh-session prefix

The archived `prepare-snapshot.py` creates a new working directory. Before
starting the target, archived `run.py` asserts that it contains exactly the
JSON input, `why3.conf`, and an empty `temp` directory. The selected session
directory is therefore absent at launch. This follows the pinned source:

1. `gnat_config.ml:714–740` derives the session directory by chopping the
   `.gnat-json` extension; the selected invocation has no `--proof-dir` override.
2. `gnat_checks.ml:380–420` takes the new-session branch, creates an empty session,
   creates the controller, and adds this one input file. It returns the fresh
   controller without the existing-session reload/merge branch at 421–450.
3. `controller_itp.ml:271–290` reads and adds the file. The exact reader/typing/VC
   prefix is already described in the [fixed-context packet](retained-producer-fixed-context.md).
   `session_itp.ml:1843–1865` obtains the current theories from that reader.
4. `session_itp.ml:1752–1801` calls `Task.split_theory`, creates theory goal lists,
   and registers tasks through `mk_proof_node` at 678–690. That function inserts
   into `proofNode_table` and `session_raw_tasks` and computes initial checksum
   and shape. The raw-task table is initially empty at 631.
5. `gnat_main.ml:332–347` installs the controller-capturing SIGINT handler, then
   registers subprogram VCs. `normal_handle_one_subp` at 292–295 calls
   `init_subp_vcs`; the Per_Check strategy is `split_goal_wp_conj`
   (`gnat_checks.ml:284–302,734–750`). The scheduled transformation route
   (`controller_itp.ml:780–817`) grafts returned subtasks through
   `session_itp.ml:728–735`, adding their raw tasks through the same constructor.
6. `controller_itp.ml:413–438` looks up a raw session task for the prover call.
   `Driver.prepare_task` at 372–390 updates and transforms its task argument.
   The capture pins the first cvc5 preparation and first inlining entry.

This is a fixed construction route, not an arbitrary-session hypothesis. It
still does not calculate the current theory/goal/subtask formulas or the final
forest after the registration/splitting prefix. No such numeric reconstruction
is claimed. The historical fixed-context `why3session.xml` has five goal
occurrences, but **was not this capture's input**. No XML/shapes member or
observed XML/shapes open exists in the retained capture. Reusing five as the
current proof-node count would be unsound.

## Exact missing projection and preservation boundary

The primary missing input is the actual handler-rooted session projection:

- The handler array's SIGINT slot, closure, controller and session identity.
- Complete `session_files`, file/theory lists, `proofNode_table`, `trans_table`,
  transformation/subtask lists, proof-parent variants and detachment fields.
- Complete `session_raw_tasks` lookup structure and every selected task chain,
  proposition formula and goal formula, with binder variable lists, pattern
  variables, triggers, delayed substitutions and source well-formedness data.
- A finite visit/expansion certificate preserving repeated forest visits,
  duplicate table bindings and repeated term occurrences. A raw unique-block
  count or the old inline-input envelope cannot substitute for it.

The [accepted charging interface](retained-why-callback-launch.md) then applies:

```text
B_binders(S) = sum over successful APn visits g of
                [ O(goal_formula(t_g))
                  + sum over proposition declarations d in t_g of O(formula(d)) ]
counter_end <= 61,641 + 2 * (B_binders(S) + R)
```

`O` must count the fully opened occurrence tree with semantic delayed
substitution, including quantifier lists and case-pattern variable sets.
Both explanation and shape traversal are charged. The shape buffer's 1,024-byte
limit is not an identifier bound. Stable missing raw tasks are skipped by the
actual detachment guard; the previously refuted exception witness stays refuted.

The source gives a useful preservation reduction. `Driver.prepare_task` and
`inlining.ml:21–100,138–146` build replacement tasks from their task argument;
they do not graft them into the session forest or replace its raw-task table.
`Task.task_hd` has immutable chain/declaration fields. The direct session-save
route (`session_itp.ml:2212–2245`) clears/rebuilds shape tables, changes the shape
version, and serializes the existing forest. It does not add proof nodes,
transformations, raw tasks or term binders to that projection. Thus these
**direct routes** do not require a larger forest for a second save.

This is not yet preservation across all callbacks. Exit helpers or other
reachable callbacks must also preserve the charged projection, or receive a
separate larger bound. Their identifier work remains in `R`; the source-prefix
registrations that created transformed proof-node names before entry must not
be mistaken for additional save-time naming.

The live exit-function chain is a concrete remaining input. OCaml
`stdlib.ml:552–570` installs an atomic, once-per-hook chain and invokes it before
`sys_exit`. GNAT enables statistics (`gnat_main.ml:319`); the Debug exit hook
calls `Stats.print`, which traverses registered printer callbacks
(`debug.ml:174–202`). Therefore observing only the outer hook would not by
itself close `R`. Source analysis of serialization helpers, hook bodies and
their actual callback/global inputs is still required. No arbitrary alias or
unestablished escaping-exception route is introduced here.

## Restricted observer, retained evidence and success conditions

[`observer-plan.json`](../evidence/retained-why-session-save-capacity-20261018/observer-plan.json)
specifies the roots, field layouts, typed projection, outputs, fixtures, resource
limits, unchanged stop guards and offline obligations. It is **not executed**.
The parent must coordinate a native attempt after reviewing the plan; current
authorization in this subthread is static inspection and retention only.

Ten named bodies, **2,414 instruction/continuation bytes**, were extracted from
the existing disassembly and checked against the pinned ELF. They establish
the prospective root layouts: SIGINT closure field 2 captures the controller;
controller field 0 contains its session; the standard exit-link closure has
callback/gate/previous fields 2/3/4; Debug's statistics wrappers retain their
three-field statistic record. Session/table/term layouts are source-validated
decoder requirements and must be checked on the raw capture, not assumed.
This remains scoped source/native interface evidence, not a universal binary
refinement theorem.

The prospective observer stops at the same first-inline entry and never runs
the transformation, printer, save callback or prover request. It preserves all
original counter/input/Hsdecl components before optional session/exit work,
flushes raw reads before decoding, and retains partial failures. One worker,
6 GiB address-space limit, 120-second timeout and diagnostic graph limits are
specified, with repository-filesystem storage and parent resource coordination.
Offline fixtures must cover table collisions/duplicates, sharing, cycles,
detached tasks and partial persistence. Limits are diagnostic aborts and cannot
become language restrictions or capacity conclusions.

The expected newly supplied obligation is a **same-process session membership,
visit and raw-formula input certificate**, enabling an actual `B_binders` bound.
The exit/statistics roots supply inputs for `R`; their observation alone is not
the helper proof. Composition additionally requires fully opened finite-term
analysis, callback/helper preservation, a complete `R`, and the unchanged
successful-POSIX/single-dispatcher/producer/no-reinstallation/no-unmask premises
of the reviewed two-save bound.

PID 74171 was terminated by its original capture harness. A new capture is a
new instance: it must retain its own counter/input/Hsdecl/session join and
re-establish the accepted source bound's input assumptions. It cannot supply
missing historical bytes retroactively. A claim specifically about the old
instance still needs fixed-prefix invariance of the relevant session projection;
otherwise the new result must be labelled as the new retained instance. There
is no family, history, auxiliary-allocation, other-callback, full-transform or
whole-pipeline capacity upgrade here.
