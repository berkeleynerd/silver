# Independent review of fixed initial splitting and registration

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119).
Reviewed integration: `1a8da404ae77a47abbd1b0406135f034416a4e9e`;
worker commit: `2c31b4e05530b3f56e401006fcea5d8da3877249`.
The nine reviewed files are identical between those commits. Selected reviewer:
GPT-6 Astra, Extra High; runtime model/effort confirmation, token usage and cost
are unavailable. Measured inspection/replay interval: 18:45:38–18:48:01 UTC,
143 seconds, excluding report authoring and commit. Actual review host:
Linux 7.0.14 x86_64; `scripts/dev.py paths` reports `linux-x86_64`.

**Accepted within the stated conditional scope; no unresolved material finding.**
The new argument closes the five fixed inputs from the accepted Per_Check
prefix through initial splitting and registration, ending at entry to
`camlGnat_checks__iter_2373` before its first instruction. It does not close
later check scheduling, selected driver transformations, task printing, server
or solver representations, result handling or final serialization. The accepted
[Per_Check review](../retained-producer-prefix-per-check-20261018/review.md)
and its complete-prefix dependencies were reused, not reopened as a broad
review. No Oracle, tool pin, production option or admission rule changed.

The source and evidence checks support this conclusion:

- **Endpoint and dispatch.** Archived `gnat_main.ml:291–295,332–350`,
  `gnat_checks.ml:371–379,490–509,738–754`, and the retained instructions
  identify the intended HCheck-fold/List.iter endpoint at static address
  `0x530a10`, distinct from the GoalSet iterator. The initialization and
  registration timing finalizers have completed. The schedule timer has begun,
  but the check-iteration body has not run. `Gnat_scheduler.idle` invokes the
  initial transformation callback synchronously; the one recorded
  `split_goal_wp_conj` call and graft per input therefore finish before
  registration. Ten forbidden entry guards exclude the later prover-scheduling,
  driver-preparation/printing and client-submission routes in this capture.
- **New launch and no-collection transfer.** The socket argument is a real
  launch change, and the evidence measures the entire protected interval anew.
  It does not infer that old allocation totals remain unchanged. The old
  endpoint is visited once; all five old-prefix allocation totals rise by
  27 words, while the original semantic operand streams remain exact prefixes.
  The unchanged 13 protected collection/request/settings guards, active native
  allocation pointer, unchanged collection statistics, trigger state and table
  margins support reuse of the accepted no-collection/cache argument with the
  larger totals. `W=128,847,761`; startup overcount 43,222 and loaded-image
  allowance 2,152,771 give `B=131,043,754`. This is cumulative managed allocation
  plus the stated allowances, not a claim about all foreign storage or RAM.
- **Reached arithmetic.** The four components at
  `gnat_split_conj.ml:316–325` are the selected transform. Context traversal in
  `unfold_trans` and `elim_to_of_array` is included; restricting inspection to
  the goal formula would be insufficient. The split combinators accumulate
  physical lists/trees; `M.degree` is in `{0,1,2}` and `trivial` recurs only with
  an accumulator at most one, so its addition is at most three. Unfolding starts
  at one and decrements only on the positive branch. The reachable
  `Pattern.compile_bare` helper, inspected in the accepted complete source
  archive, constructs physical maps/lists and has no additional unfolded-size
  integer accumulator. Binder/substitution/occurrence counts retain the three
  complete guarded sites: mathematical replay covers 514,906 operations,
  including 368,647 after the old endpoint, with maximum result 47. Physical
  task/context counts are not used as semantic multiplicity bounds.
- **Naming, coercion and session lifetimes.**
  `session_itp.ml:313–322,679–736,1573–1580` builds naming tables even for empty
  transform arguments, then constructs the new proof nodes, checksums and
  shapes. `args_wrapper.ml:175–205`, `Ident.find_unique/id_unique_attr` and
  `coercion.ml` support the occupied-spelling lifetime charge and physical
  nested-map/composition-record charge. Session IDs, the `List.mapi` index,
  registration goal/check counters and built-in trivial proof records retain
  allocation or physical-list charges. SV6 formatting is unchanged. The
  selected transform/helper routes do not reach reduction-engine `term_size`,
  general numerical term printing or the nonallocating Introduction hashcons
  instance. The old exclusion is extended by this dispatch inspection, not
  merely asserted from the previous endpoint.
- **Timing and conversions.** `Debug.stats` is enabled. In
  `debug.ml:162–173`, every completed `old_n+1` update constructs a new timing
  pair; replacement of a prior table value does not remove that cumulative
  allocation charge. Time arithmetic remains floating point here. Checked
  GP-label and location conversions retain the fixed-request/external-contract
  premise; the selected transformations copy attributes or add fixed
  `GP_Inlined`, not an unchecked decimal-label counter. Final timing conversion
  and serialization are expressly outside the claim.
- **Registration observer correspondence.** The retained disassembly supports
  the goal ID in `rbx`, the saved goal at `rsp+24`, and `rax` results at offsets
  56 and 91 of `register_goal`. At `add_to_check`, `rax/rbx/rdi` hold the
  toplevel flag, VC information and goal ID. The `check`/`vc_info` records,
  five-field check record, referenced ordered sets and hash-table layouts agree
  with the decoder. Global offsets `0xa0` through `0xc0` agree with the retained
  instructions and source state order. Task counting follows the option and
  six-field task-node layout with cycle checks. Both probes read inferior state
  and install breakpoints; neither calls an inferior helper, writes inferior
  data nor manufactures a result.
- **Raw tasks and reported G.** The separate diagnostic records raw goals
  1, 2 and 4 as trivial with no selected check and an actual
  `set_not_interesting` call. Goal 3 is nontrivial, selects check ID 0 of kind
  VC_PRECONDITION with `already_proved=false`, and actually enters
  `add_to_check ~toplevel:true`. Independent endpoint reads leave only goal 3
  in `goalmap`, `toplevel`, `to_be_scheduled` and `to_be_proved`, with both
  counters equal to one. `gnat_main.ml:50–73` supplies the branch predicate;
  `gnat_checks.ml:201–226` supplies registration/filtering; `check_to_json` at
  `:940–979` starts from `toplevel`. Fresh Per_Check has no successor split.
  Consequently the existing all-proved response premise uses one reported
  leaf, although the transform returns four raw tasks. The historical raw-task
  wording is explicitly superseded by the new report; preserving its pinned
  bytes requires no dependent response-constant change. Discarded raw tasks
  still contribute to the full measured allocation and count interval.
- **Next-stage identification and teardown.** The ordered driver extraction
  agrees with import expansion in `driver_lexer.mll` and the reverse-then-fold
  ordering in `driver.ml`; it accounts for nested comments and the `(*)`
  operator. The selected printers and 15/13/12 transformation lists identify
  future work, not transformations executed by this capture. External socket
  connection sends no proof request. Each server's recorded exit 1 follows
  deliberate debugger termination of its stopped client and the retained
  `close_client`/`logging_shutdown` path; it is not server/proof success.

The exact executable/source relation remains the documented relevant-behavior
premise for Why3 `9390baf120ef260547dfa14f08e11c890b203d9c` and the accepted
OCaml runtime behavior. Matching instructions and successful captures do not
recover the unknown historical SPARK revision. Fixed inputs/configuration,
successful external primitives and physical resources, no external interruption,
and the accepted first-event transfer remain required. The checker verifies
identities, observations, arithmetic and classifications; source exhaustiveness
and transfer are inspected arguments, not a machine-checked semantic proof or
a solver-dependent membership rule.

Offline validation ran the README command exactly once:

```text
python3 docs/evidence/retained-producer-fixed-tail-20261018/check.py
exit 0; stderr empty; elapsed 3.064695150 seconds
W=128847761; B=131043754; semantic_operations=514906
initial_split_registration_capacity_established=true
whole_tail_capacity_established=false
```

Without `--output`, the checker compares its entire recomputed object to retained
`result.json`; that equality passed, including maximum semantic result 47,
registration classification and ordered driver directives. It also replays the
accepted prefix dependency checker. No new native capture, solver, proof run,
GitHub write or additional reviewer was used. Author-run evidence remains
distinct: `20261018T182701-4554d278376e` took 83.367528516 managed seconds;
`20261018T183727-b79953f86b46` took 6.796294796. No issue completion, whole-tail
completion or production adoption is inferred. CLI memory was not updated.

Exact reviewed SHA-256 inputs follow. Packet paths are relative to this directory;
the report path is relative to the repository. Archive member and dependency
identities are additionally enumerated in the pinned `identity.json`.

| Input | SHA-256 |
| --- | --- |
| `docs/research/retained-producer-fixed-tail.md` | `4172429e77609c648011b4c8b72c890fbfc4ec67483e5238c806d9351622e441` |
| `README.md` | `1c17c31ff9ba033c739cee6eb8618eca510e050ce92142c194a7df63c8d64a30` |
| `check.py` | `31842e12b52bc037028e66d44a2f8f7501a920264266cdcd775ab49ddf236399` |
| `identity.json` | `f442fcb7bcff7c045283e6effbb9ae4815d1ce1cd97c477a39e021444b59d7e6` |
| `observations.tar.gz` | `d07071aec5033c5b45aeb5e6b41335da3d93a8faa20aa2d2a081038b2a69ed91` |
| `registration.tar.gz` | `4289fbcf2cbec50fb1f24d82e5b7545613556f71321f63bd8cf507cdd0779287` |
| `result.json` | `22ff269c8ed27c52db49493fbf1f1746e6e848bbff65f15c627edb1a5867a956` |
| `round.json` | `039f94c3c7dd33be3a7465292cc6a0a594b1bbbbb69f4c5dfa7b6a8b1dee31c9` |
| `sources.tar.gz` | `fa7ecddc4f24efe601a1fc81c47582d4eb4e85c13499fc5a4b50254041cff3c4` |
