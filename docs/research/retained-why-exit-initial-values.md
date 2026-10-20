# Retained exit timing and initial formatter values

2026-10-20 UTC, #119 / #153 Round 38, Linux x86_64. The five retained captures
already contain the complete initial timing-table entries and the Debug
formatter's 28 immediate fields. A new offline projection attaches those values
to their raw read spans. It performs no target execution or new capture.

The [packet](../evidence/retained-why-exit-initial-values-20261020/README.md)
checks the retained archive identities, selected member identities, timing
table header/backing buckets/cell chains, OCaml string and tuple layouts, boxed
binary64 payloads, and tagged counts. It retains every selected raw span with
its member and line number. This is an initial-state attachment under the
existing typed-value/source-runtime relation, not a theorem about subsequent
timing updates or formatter use.

| Case | PID | Timing entries | Backing slots | Maximum initial count | Longest key |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 17310 | 3 | 64 | 1 | 43 bytes |
| Put | 17514 | 3 | 64 | 1 | 43 bytes |
| First_Or_Default | 17631 | 3 | 64 | 1 | 43 bytes |
| Is_Message | 17704 | 3 | 64 | 1 | 43 bytes |
| Input_Is_Valid | 17869 | 4 | 64 | 1 | 57 bytes |

All five tables have seed zero and initial size 64. The first four contain
`gnatwhy3.init`, `gnatwhy3.register_vcs`, and
`gnatwhy3.transformations.split_goal_wp_conj`. The later Input_Is_Valid cut also
contains `gnatwhy3.transformations.counterexamples_dependent_intros`. Every
initial count is one. Exact floating-point bits are retained; these observations
do not bound wall-clock durations or their future sums. No execution-time
limit is inferred from the observed values.

## Debug's destination and scalar fields

`gnat_main.ml:265–268` installs a formatter over `escape_buffer`. The optional
`GNATWHY3LOG` branch would replace it with a channel formatter; that variable is
absent from all five captured environments. `Debug.set_debug_formatter` wraps
the saved newline callback with a saved flush. The current destination is
therefore a distinct global Buffer-backed formatter under the source-prefix
relation. The initial assignment to `Format.err_formatter` in Debug alone would
not identify the destination used at these cuts.

The captured record in every case has these immediate values:

| Fields | Initial values |
| --- | --- |
| margin / minimum space / maximum indentation | 78 / 10 / 68 |
| space left / current indentation | 78 / 0 |
| new-line flag | true |
| left total / right total / current box depth | 1 / 1 / 1 |
| maximum box count | 4,611,686,018,427,387,903 |
| print tags / mark tags | false / false |

These are raw-record values at the cut. They do not prove a fresh queue, valid
stack contents, empty Buffer, callback closure identities or absence of earlier
interrupted updates. In particular, matching constructor defaults is not a
history proof.

The projection scans both `memory-reads.jsonl` and
`save-state-memory-reads.jsonl` for each capture. None contains even the first
byte of any of this formatter's sixteen immediate pointer targets: its five
stacks, ellipsis string, five output callbacks, four tag callbacks and queue.
This is an exact availability result for those two logs, not a claim that every
other artifact has been exhaustively searched. It does not invent missing
queue or closure fields. Standard stdout/stderr formatter records are not
identified or reconstructed by this projection.

## Selected exit formats and remaining joins

The inherited exit-root evidence has both once-only gates true and an empty
registered-statistics list in all five cases. Their source preservation and
history argument remains [the initial-state result](retained-why-path-initial-state.md).
This packet reads those observations; it does not reprove their history.

`Debug.Stats.print` has the timing template
`"<stats>@[%s: %f, %d@]@."`. The `<stats>` text is literal, and the key passed
to `%s` is data. There are no tag/tab or custom-printer directives in this
template. The `%t` template for registered statistics is excluded only under
the accepted empty-list preservation. The timing template adds `%f` and a bare
box annotation to the private save formatter's selected format environment;
its costs require an explicit extension, not silent reuse of `%g` coverage.

The next required joins are:

- Bound post-cut `Stats.add_timing` calls, key creation and count increments
  from the selected preparation, finally and ending paths. Initial counts
  alone cannot supply that bound.
- Attach or derive the missing Debug Buffer, queue/stack and output-wrapper
  state, and the distinct standard stdout/stderr formatter state. Source
  callback-family preservation closes effects but not wrapper depth or size.
- Bound the `%f` conversion, complete formatter arithmetic, emitted bytes,
  Buffer growth and interruption/exception continuations. An exit gate permits
  at most one start of its hook; it does not ensure that an interrupted global
  formatter remains valid for a later flush.
- Preserve the separate standard Format hook and terminal `flush_all` owners;
  the Debug timing template does not describe their pending queues.

All complete-formatter, exit and save flags remain false. Oracle, tool pins,
production source and admission are unchanged. No new native run, capture,
proof, solver, dependency audit or predecessor checker was launched. This
projection identifies reusable inputs and the exact remaining attachment gap
before another capture is considered.
