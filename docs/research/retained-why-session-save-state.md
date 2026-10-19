# Retained session-save binder charge for PID 97103

Research [#119](https://github.com/berkeleynerd/silver/issues/119), Linux x86_64,
2026-10-19. The new retained instance has **`B_binders(S) = 966`** under the
[accepted charging definition](retained-why-callback-launch.md). The same
process's input/counter/Hsdecl checks re-establish the **1,145 accounted inline
registrations**, starting from **60,496**, and hence the accounted-source
endpoint **61,641**. **`R` and the composed callback endpoint remain open.**
These are source-bound conditional counts, not observed executions of save or
inlining, and not machine-checked OCaml semantics.

The [packet](../evidence/retained-why-session-save-state-20261019/README.md)
retains this instance's complete capture, process and managed-run identities,
exact replay result, current task/formula certificate, source files and selected
native helper bodies. It does not supply missing bytes for historical PID 74171.
No historical addresses or session XML are used as this instance's state.

## Capture and same-process joins

Parent-coordinated run `20261019T000304-fcb988ec2c03` succeeded in
**35.824959949 seconds**; its debugger interval was **33.606329286998516 seconds**.
PID **97103** stopped at the first Input_Is_Valid/cvc5 inline entry and was
terminated by the capture harness. No inline, printer, save or prover execution
was admitted. This packet's subsequent work was entirely offline.

The 60-member `capture.tar.gz` is 12,297,103 bytes, SHA-256
`583b69d7acc87323f6c6c69e525825da29b1c2ea3141130f7d2bc065f7ea632c`.
The frozen preparation's 24 file identities match. Exact sequential replay of
all **49,728 session-observer reads** reproduced all 11 projection files byte
for byte. The separate counter/auxiliary replay scans the **835,579 core raw-read
records**, then reconstructs the private counter and auxiliary state from those
retained spans; it does not claim to consume every core read sequentially.

The current driver input task is `139793592778832`, attached to goal 3. The
inline-entry task is `139793588013848`. The load bias is `94173092061184`.
The runtime SIGINT closure retains controller `139794218856968`, whose session
is `139794218857680`. `session-observer.json.core_join` binds the process,
identifier state, inline graph and Hsdecl table by exact identities.

Changed-input validation establishes a **14,477-block exact rooted sharing
isomorphism** from the accepted input to this process's 244 input declaration
roots. It also validates all 326,456 current graph blocks and all 5,003 Hsdecl
buckets, retaining 6,704 distinct old objects. The new representative projection
again leaves 142 input-root representatives and excludes three additional
same-key objects by strict opened shape. The source envelope remains
`E=8, V=6, T=3, A=80`, so the existing 1,145-registration argument applies to
this process. This reuses the established source result after checking its new
inputs; it does not assume that matching counter values imply matching heaps.

## Finite visits and fully opened formulas

The captured forest has 1 file binding, 5 proof-node bindings, 1 transformation,
5 raw-task bindings/values and 4 proof-attempt bindings. Its source-order fold
has five APn visits, all attached. Each selected chain has 434 tdecl occurrences,
244 logical declarations and 62 proposition occurrences. Across all chains
there are 248 distinct logical declarations, 66 distinct proposition formulas
and 16,106 logical graph blocks.

The session projection ended at **17,955 blocks / 511,712 bytes**. Including the
later helper projection, `session-blocks.jsonl` contains **17,985 distinct blocks /
513,248 bytes** (both byte counts include headers). These are different capture
stages, not discrepant counts.

`binder-certificate.json` records the exact ordered chain positions, proposition
kinds/symbols/formulas, top-level goal formula and every forest occurrence.
`Task.find_goal`/`task_goal_fmla` (`task.ml:121–132`) select the head declaration;
the checker verifies that it is `Dprop(Pgoal,_,formula)`. It preserves repeated
visits and repeated proposition occurrences rather than deduplicating charges.

| Goal | Root | Explanation upper | All-propositions shape upper | Charge |
| --- | --- | ---: | ---: | ---: |
| 1 | false | 0 | 160 | 160 |
| 2 | false | 7 | 167 | 174 |
| 3 | false | 15 | 175 | 190 |
| 4 | false | 16 | 176 | 192 |
| 0 | true | 45 | 205 | 250 |
| Total | | 83 | 883 | **966** |

For a fully opened term occurrence, `O` sums child counts and adds one for a
let/epsilon binding, the quantifier variable-list length for a quantifier, or
the distinct `pat_vars` cardinality for each case branch. Quantifier triggers
are children with their actual multiplicities. Constants/free or freshly
renamed variables add zero. Shared children contribute once for each occurrence.

`binders.py` interprets `term.ml:739–781,799–832`: a binder's fresh abstract
variables override its saved substitution; when a saved value replaces a
variable, it is interpreted under the older frames, not substituted through
its own simultaneous map again. Thus nested outer substitutions compose while
fresh bound identities avoid capture. Attributes/types do not add binders.
This uses the existing source correspondence, well-formedness, valid-cache and
noncolliding freshness premises. It does not treat a raw unique-node count as
the opened term size or independently prove all producer caches valid.

The computation finishes with **1,651 distinct memoized opened states**, including
four distinct nonempty delayed-substitution records. Every recursive child is
counted before its state is cached; cycles and malformed layouts fail rather
than producing a charge. A separate existing explicit-alpha `Refiner.open`
checks both opened term and binder counts for all 66 formulas. Eight focused
regressions cover shared occurrences, triggers, delayed-value multiplication,
simultaneous and nested substitutions, fresh-variable shadowing, repeated case
branches and cycle rejection. The two decoders share the source interpretation;
agreement is a check, not an independent semantic proof.

`goal_expl_task` (`termcode.ml:64–99`) opens a subset of the goal occurrence tree.
`t_bound_shape_task` (`termcode.ml:599–627`) visits proposition declarations in
`Task.local_decls`, a subset of the charged all-proposition chain. Its shape
walk (`termcode.ml:430–506`) opens the corresponding binders. Early explanation
termination and `ShapeTooLong` reduce work; no identifier bound is inferred from
the 1,024-byte shape limit. The sum therefore charges both traversals and all
their potential binder openings. In this state it equals `5*160 + 2*83 = 966`.

## Actual helpers, preservation and the remaining R obligation

The captured exit chain is exactly two `new_exit` links, each with its once-only
gate initially true, followed by the terminal closure:

| Position | Callback/terminal symbol |
| --- | --- |
| 1 | `camlWhy3__Debug__fun_3069` |
| 2 | `camlStdlib__Format__flush_standard_formatters_1825` |
| 3 | `camlStdlib__flush_all_236` |

These addresses resolve at symbol offset zero using the current load bias and
pinned executable. Nine selected bodies, **1,008 instruction/continuation bytes**,
were extracted from existing retained disassembly and byte-matched to that ELF.
No objdump was run. The retained bodies support these interface identifications;
they are not a transitive binary call-graph proof.

`Debug.Stats.registered_stats` is **empty**, so the outer hook's `%t` printer
iteration (`debug.ml:174–202`) invokes no registered statistic printer in the
captured state. The timing map has four string/float/integer entries. Direct
inlining and save source do not register statistics. The old possibility of an
unobserved arbitrary registered statistic is therefore removed for this state.

The formatter is not assumed to be `err_formatter`: GNAT creates a buffer
formatter at `gnat_main.ml:265–268`, with a channel-formatter override at
322–330 if `GNATWHY3LOG` is set. The captured exact environment has no such
variable. `Debug.set_debug_formatter` wraps the output-newline function to flush
(`debug.ml:65–75`). The live formatter record `139794218869840` is retained
shallowly; its output-closure environments, standard formatter globals and
pending queues are not fully traversed. The retained OCaml source set does not
include the pinned `Format`/`CamlinternalFormat` implementation. Source
initialization narrows the intended route but does not by itself discharge
all indirect output/tag/queue and global-state obligations.

Direct Why serialization (`session_itp.ml:1933–2245`) formats primitive data,
existing identifier strings/paths, checksums and shapes. Its local prover
numbering modifies the separate prover-ID table, not `Ident.id_register`.
`save_ident` performs `Theory.restore_path` lookup with the existing name as
fallback. These inspected bodies introduce no additional identifier constructor.
This observation is not a complete zero charge for their transitive formatting,
compression, I/O, exceptional and exit paths; those remain part of `R`.

The direct preservation argument remains: inlining builds persistent replacement
tasks without grafting the session forest, and `save_session` clears/recomputes
shape data and serializes the existing forest. Neither direct route changes the
charged proof-node/raw-task membership or the immutable term formulas. The
statistics list is unchanged by these direct routes; exit-link gates can only
turn false. Full preservation across all helper/global callback routes remains
an obligation with `R`.

If that remaining helper work and preservation are closed, the reviewed
successful-POSIX/single-dispatcher/no-independent-producer/no-reinstallation/
no-unmask two-save premises would give
`counter_end <= 61,641 + 2*(966 + R) = 63,573 + 2*R` for this retained instance.
**63,573 is only the unevaluated formula's constant term, not an established
endpoint.** No numeric `R`, complete callback capacity, history/family guarantee,
auxiliary allocation capacity, full-transform capacity or whole-pipeline claim
is made. No additional native run was authorized or performed by this subthread.
