# Attach the accepted counterexample-meta exclusion to standard output

2026-10-20 UTC, #119 / #153, Linux x86_64, base
`6e8d4705b0e81f1692e78c8e67f8da338a7b184e`.

The selected tasks cannot acquire `Driver.meta_get_counterexmp` under the
already accepted fixed-input/source/runtime relation. Consequently their prover
calls carry `get_model=None`, and the model parser's stderr diagnostic is
excluded from the selected continuation. This is an attachment of an existing
reviewed source result to the standard formatter ledger, not a second transform
census or a conclusion from the CE-off option.

The [focused packet](../evidence/retained-why-model-meta-control-20261020/README.md)
checks the current five process/input identities, both retained driver-resolution
maps and their plan identities against that result. It preserves the original
packets unchanged. Whole output capacity, standard formatter initial state,
complete R/U and #119 remain open.

## Existing result and the previously missing attachment

The accepted [library-origin argument](retained-why-path-library-origins.md#selected-writer-closure)
already establishes the relevant metadata invariant. Its author freeze is
`61c325ab2b8434836ff24014bbe51e6b40beda21`; the integration input is
`f114d4fad3643e6c1bcc6f8388d19581f1eca875`. The
[Round 32 review](../reviews/review-save-capacity-round32-20261020.md), at final
review input `5a45438c03ce20ca9c8731245e03bd9cea5d4e7a`, explicitly accepts:

> Reconstructed and memoized tasks therefore retain the empty
> counterexample-meta entry. `prove_task_prepared` passes `get_model=None`,
> and `record_model` does not call the model parser in that branch, even on
> model-looking prover text.

That proof was used to exclude model parsing's additional library reads. The
same control fact also excludes its formatting effects. Its retained evidence
contains the complete 14-file driver import closure, 11 prefix library files,
five native JSON inputs, stable meta registration argument and selected
transform/helper closure. No new absence scan or old checker replay is needed.

The later [standard-control packet](retained-why-standard-formatter-control.md)
and [review](../reviews/review-standard-formatter-control-20261020.md) left
`model_diagnostic_excluded_by_task_meta=null`. Their imports attached initial
process control and the driver dispatch envelope, but did not consume the
library-origin meta-preservation result or its acceptance. Their conservative
residual correctly said that CE-off **alone** was insufficient; it did not
disprove the earlier source result. The present explicit dependency/identity
join resolves that unjoined field. It does not revise the frozen record or
claim that its checker previously established the stronger fact.

## Exact five-cut attachment

| Case | PID | Cut |
| --- | ---: | --- |
| Put_Line | 17310 | `Gnat_checks.iter`, before scheduling |
| Put | 17514 | same |
| First_Or_Default | 17631 | same |
| Is_Message | 17704 | same |
| Input_Is_Valid | 17869 | first cvc5 `inline_trivial` entry, after `counterexamples_dependent_intros` |

These are the same PIDs, argv, environments, source revisions and cuts in the
accepted initial-path attachment and the standard-control packet. The five
captured JSON byte identities match the five native inputs in the accepted
meta-input record. Both current capture plans contain the same 14 resolved
driver identities and 11 library identities. The actual retained driver
resolution edges, including import order and the private
`silver_cvc5_no_steps.gen` replacement, match the accepted closure after
relocating only the private overlay directory. The four captured overlay files
are also checked byte-for-byte against those identities. The installed library
and driver identities are those of the retained plans and accepted input
relation, not a claim that an arbitrary later filesystem replacement is safe.

The two plans identify Why3 `9390baf120ef260547dfa14f08e11c890b203d9c` and
OCaml `8eb41f72ded84df884c3671734c947f612091f84`; the executable identity remains
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The dispatch join retains exactly the same 20 outer transforms and three
printers. The accepted initialization/loading relation supplies the fixed
plugins, immutable registries, selected pending clients and typed/table behavior.
The accepted source/native and normal-service premises are retained at their
original scope; this is neither a binary refinement proof nor a claim about
corrupt or out-of-contract service results.

The raw-task observer does **not** decode meta objects, names or task-meta maps.
At `session_observer.py:220–245` it reads each tdecl node and follows logical
declarations only for node tag 0; Meta tag 3's object is not traversed for its
name. Thus task-chain completeness and `complete=true` are not a direct
observation of an empty `get_counterexmp` map. The attachment uses the accepted
construction/preservation theorem and the exact input identities, rather than
inventing an unread field. No new native capture or observer replay occurred.

## The reused invariant and final result transport

The accepted proof is stronger than string absence:

- Initial input parsing and driver loading use the exact input/library/import
  closure. The three raw driver mentions are comments. The JSON converter and
  parser do not synthesize this zero-argument meta from unrelated data.
- Meta objects have private representation and stable, distinct tags from a
  separate finite initialization counter. Identifier or task-tag collisions
  therefore do not turn another meta into the `Mmeta` key for this one.
- Task constructors preserve the existing meta object or insert a displayed
  encoding, algebraic, introduction or definition meta. Generic cloning maps
  the arguments while retaining its meta object. Selected reconstruction,
  flag-dispatched helpers and memoized Tasks stay within this same family;
  hash-consing compares the tdecl and previous task instead of inventing a
  meta-map binding from a hash match. The proof includes `Driver.update_task`
  and its generic theory/meta insertion, not merely the outer directive list.
- The selected scheduling envelope supplies only these raw tasks and drivers.
  Other solver answers, preparation failures, saves and exit callbacks do not
  install another preparation/model-producing client. Input_Is_Valid's already
  completed introduction transform is covered by that same invariant; its
  different cut is not treated as a registration cut.

`Driver.get_counterexmp` tests whether `Task.find_meta_tds` is nonempty
(`driver.ml:27–33`). `prove_task_prepared` computes the option from the prepared
task at line 466. `call_on_buffer` passes that option to `call_on_file`, which
stores it in immutable `save_data.get_model`; `handle_answer` passes the stored
value to `parse_prover_run`. The table starts empty, and the selected dispatch
uses `prove_task`, not an external `prove_buffer_prepared` call supplying its
own Some option. A result ID collision can at most select another
saved entry from the same all-None domain under the accepted table relation;
it cannot create a Some. No successful return from a failing lookup is assumed.

`Call_provers.record_model` invokes `prp_model_parser` only in the Some branch
(`call_provers.ml:329–336`). Even model-looking solver output in the None branch
continues ordinary answer analysis without that callback. Therefore its
`Smtv2_model_parser` malformed-expression diagnostic at `:457–474` has **zero
selected callback invocations**, under the named relation. Ordinary answer
parsing still runs and keeps its separate resource/failure obligations.

Only this residual is retired. Printer's broad `int_of_string` diagnostic,
GNAT abort/error JSON, other source-owned reporting, all channel/runtime
services, and global B/E composition remain with their existing owners.
There is no standard queue-freshness claim, output-capacity bound, pre-cut
signal-budget inference, new admission condition or Oracle amendment.

Selected author setting: GPT-6 Astra / Extra High; runtime confirmation and
token/cost telemetry unavailable. The packet records measured elapsed time.
Production remains unstarted and #119 / #153 remain incomplete.
