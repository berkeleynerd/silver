# Independent review: adapter configuration and parallel prefix

2026-10-20 UTC, Round 52; bounded continuation of #119 / #153.

**Accepted:** warning exclusion, actual queued/server zero limits, the private
time-parser removal with its source prefix transfer, and composition with the
accepted quiet command, for the five retained **serial** domains under their
named premises. The parallel packet is accepted as a reduction to **13
unresolved physical keys in four formula families**. Intended parallel
stored-representative transfer remains open. These results do not complete
#119 / #153 or adopt a production adapter.

## Review setting and inputs

Reviewer `/root/quiet_output_review` was selected as GPT-6 Astra / Extra High.
Runtime model/effort confirmation and token/cost telemetry are unavailable.
The actual host is Linux x86_64. The reviewer authored none of the components
and spawned no agents. No native, compiler, solver, proof, capture, broad
predecessor replay, GitHub, memory or harness write is authorized or performed.
Parent integration and publication remain separate.

The isolated worktree is `tmp/quiet-output-review`, branch
`review/quiet-output-20261020`. Its starting point was the accepted R51 review
`90e7f87b10aad55406387b4b4c87d07967b76196`; root integrated that review as
`0e637cf186`. The first retained R52 review clock is 20:50:41 UTC. R51 evidence
is reused without replay. Source/runtime and mutable-table ownership premises
remain those of the accepted bounded brief; this review adds no binary
attestation requirement and changes no Oracle or admission rule.
Acceptance was recorded at 21:11:41 UTC, 1,260.136 seconds after the first
retained R52 clock. This is an observed review interval, not full team time.

| Component | Author freeze | Reviewer import |
| --- | --- | --- |
| Warning exclusion | `29e253ba8d4d7905336f137801e4ef6c39718d43` | `d03a5d3e89e193d7f8b7a09342620e6a835d688b` |
| Parallel first-fill reduction | `ef27c85901b7fb7da6283c502c5ad08531db9a47` | `c803c1784739f92af1e32246818a109aa2229e65` |
| Response timing configuration | `b6c0128c1f0669d9a9977eda16f489ee31b4353b` | `5d36c03a3a31e70f3c27a6549c3cd9d42335a223` |
| Quiet/timeless composition | `37f1d971eba10a948f924e77aab8f478a7fa9da6` | `e9c85eeadc24d4fa1e16b74f304e52417575d17b` |

The main review's combined input is
`5d36c03a3a31e70f3c27a6549c3cd9d42335a223`; the incremental composition review
adds the final import shown above. The two input manifests retain these exact
boundaries and hash 157 distinct input files. All 67 new author files match
their exact author commits. The
composition's seven compressed quiet payloads also match author freeze
`e1059f9d97edf6a278c3efab813e196a84f1dbe3` exactly. Earlier accepted quiet/R51
checkers were not replayed.

The warning author was selected as GPT-6.1 Sol / Extra High; the parallel and
configuration/composition authors as GPT-6 Astra / Extra High. These are
selected settings, not runtime-confirmed telemetry or a causal performance
comparison. The review packet records observed check times and unavailable
token/cost fields explicitly.

## Warning-attempt classification

The distinction is between the `Gnat_expl.is_warning_kind` value controlling
proof-attempt selection/resource limits and diagnostics emitted by
`Loc.warning` while parsing solver responses. The former can be excluded in
the fixed domains without excluding the latter. In particular, consecutive
answer diagnostics remain part of the R51 adapter's warning projection and
strict-policy join.

The packet provides a source argument beyond a label-string census:

1. Registration extracts the raw task goal formula and calls
   `search_labels`. A trivial unlabeled goal is dropped, and a nontrivial
   unlabeled goal aborts; neither branch invents a check kind.
2. The accepted typed atom coverage includes every stored term and deferred
   substitution image of each imported formula. Safe opening constructs fresh
   variable terms with empty term attributes. Substitution and reconstruction
   retain or union existing attributes. The visited attribute domain is thus
   a subset of the captured union, including the hidden substitution case.
3. `read_label` obtains a `Gp_Check` kind through `check_kind_from_string`.
   Every captured recognized kind maps to the nonwarning arm. Parser failure
   does not produce a warning constructor.
4. A fresh mutable extraction accumulator starts with `check_kind=None`.
   Its only subsequent assignments are the parsed kind and the two
   `VC_Loop_Invariant_Init`/`VC_Loop_Invariant_Preserv` refinements. Both
   refinements are nonwarning. Multiple labels, attribute iteration order and
   the loop rewrite therefore preserve the nonwarning invariant.
5. `extract_check`/`mk_check` store the resulting kind in an immutable check,
   then `add_to_check` stores its `vc_info` in the goal map. Under the accepted
   registered-metadata lookup/ownership relation, later classification reads
   this same check. Exceptions can abort a path without manufacturing a
   warning kind.

The reviewer inspected the complete extraction function and all assignments
to `check_kind`, all `default_expl` uses, and the goal-map mutation sites.
The only five source warning kinds are `VC_Inconsistent_Pre`,
`VC_Inconsistent_Post`, `VC_Inconsistent_Assume`, `VC_Unreachable_Branch` and
`VC_Dead_Code`. None appears in the captured recognized label set or loop
refinements. The only observed label kinds are range, index, overflow, loop
invariant, postcondition, precondition and length checks.

The checker independently binds raw attribute records, string bytes and
term-set memberships to the accepted typed coverage and old/fresh graph
correspondence. It does not reestablish those accepted graph/coverage theorems.
The pointer bijection preserves the read-only attribute predicate across the
matched immutable logical graphs; it does not identify old and fresh PIDs or
transfer mutable backing. The forest has 161 visits, while the registered-goal
upper bound is 153. An overapproximation by the whole forest suffices; the
distinct attribute counts 18/14/9/1/1 are not goal counts.

The continuation claim imports the selected fresh automatic serial Per_Check,
CE-off, non-replay route and registered-metadata ownership. It is not a theorem
for arbitrary future runs or grammars. New driver preparation does not
register a new GNAT check. The warning timeout default remains one second,
but the warning arm is unreachable for these named domains under those
premises. Actual queued limits, configuration changes and prospective parallel
transfer require their separate source joins.

The focused frozen warning checker passed in 3.831 seconds, with five domains,
22 source slices and warning-attempt bound zero; no predecessor checker,
logical opening or graph comparison was run.

## Configuration and queued limits

The exact recipe preserves the invocation, serial Per_Check/CE-off/non-replay
selection, cwd, socket, source input, private-overlay pathname and
`OCAMLRUNPARAM=s=256M,h=16M,M=1000`. It changes two 32-byte time-directive
lines to the equal-length comment `(* time measurement removed  *)` plus LF.
Five private driver files include a new local `smt-libv2.gen`; the selected
roots find it locally before the installed directory. Selected loaded time
rules change from 1/1/2 to zero, preserving all non-time response directives
and task-preparation rules. The recipe leaves the other configured roots on
their installed paths. It is a prospective private overlay, not a changed
installed tool or an observed run.

Configured limits are exactly `(time=+0., mem=0, steps=0)`: `set_steps 0`
leaves the raw option unset, so the configured `command_steps` entries do not
activate step-conversion offsets. The warning result excludes the independent
one-second warning limit. `schedule_proof_attempt` queues the adapted value
in `spa_limits`, separately from the requested limits stored on the proof
attempt. The source adaptation preserves zero in every old-result branch.
In particular, the comparison-based OCaml expression
`max 0. (min (1. +. 2. *. old_time) (2. *. 0.))` returns positive zero even
for NaN, infinities, negative values and signed zero. `use_steps=false` avoids
the old-step increment. This is a source case argument, with finite numeric
examples as checks rather than its universal justification.

The queue's value reaches driver execution unchanged. Eager time-placeholder
conversions receive finite zero. The second adaptation returns before its
`2*t+1`/`4*t+1` branches, and the server receives zero time/memory fields.
Its positive-limit guards do not install the corresponding CPU/address-space
limits. Positive-limit answer postprocessing is unreachable. Direct Timeout
or StepLimitExceeded answer rules remain possible, and ambient native limits
are not excluded by this configured-limit result.

Empty time-regexp lists select server time. That is accounting for the
immediate child the server launches/reaps; composing an adapter changes the
attribution and does not establish raw solver wall or CPU time. Time can
change fastest-prover credit among already Valid results, while success
selection uses the answer kind. The `pr_steps=-1` sentinel back-converts to a
reported cost of 1, which is not an observed solver step. The result does not
establish the enclosing cost/attempt-record policy.

The warning-policy boundary is substantive: retained SPARK
`gnat2why-error_messages.adb:1301–1312` prints Why3's top-level `warnings`
strings and does not insert them into final `warn_error`. Existing Silver
`warn_error` predicates therefore do not establish rejection of raw or
canonical consecutive-answer diagnostics. The final configuration note states
this explicitly; warning presence and warning-kind exclusion do not discharge
the future consumer/report/attempt binding.

The changed prefix receives an explicit simulation. The two edits preserve
remaining token offsets/lines. The physical import substitution introduces at
most one additional `Loc.FileTags` name. Non-driver locations retain order
and equality under that insertion; driver diagnostic locations use an
occurrence/path relation. Identifier tags and successful lookup keys do not
depend on the changed diagnostic location. This is a projection of semantic
objects, task/check topology and sharing, not identity of complete heaps.

The extra Re source establishes per-compilation state on the selected
Str/Emacs path. The separate `Ast.mark`/`Pmark.gen` path is unreachable there.
Deleted time-regexp compilations cannot remove a shared warmup needed by a
later regexp; selected last-match consumers do their own match first. This
extends the explicitly required relevant-source behavior relation to
per-regexp state/allocation. It does not attest the historically installed Re
version or establish a general purity claim for every public constructor.

FileTags allocation is charged in full, including both bucket tables and
geometric data/tail arrays. The bound on baseline names comes from their two
backing arrays and retained major allocation, rather than an assumed observed
name count. With at most 945,214 candidate names, the credits are 7,578,096
minor words, 7,578,096 major words and 18,920,664 remembered references.
The independent audit computes 4,194,240 array payload words, 8,256 words of
small-array/closure/header/lexer allowance and 1,048,559 moved entries per
table, within the stated credits.

The maximum candidate minor count is 135,517,827 (<2^28), current major count
8,523,309 (<2^28), and remembered references 18,989,625 (<2^25). Including
each process's prior major allocation gives maximum arena use 8,526,220
(<2^24). The 2,911 prior words in that maximum belong to Put_Line; other
processes have different prior values and are checked separately. The retained
zero-major-collection, single-chunk startup history and allocator source
establish a contiguous unallocated remnant; aggregate free space alone would
not suffice for an arbitrary fragmented heap. Ephemeron/custom resources
receive no added requests. A first-collection contradiction therefore
preserves the weak-cache requests and sharing, and unchanged identifier
registrations preserve initial I = 136,844 / 121,505 / 77,806 / 59,035 / 60,496.
This closes the stated serial source-prefix argument under its explicit
source/runtime and ordinary-service premises. It does not transfer parallel
scheduling, add adapter startup, or bound complete output q.

Before freezing, the author reconciled the exact comment edit with the lexer
argument, added prior major allocation to arena occupancy, and made the
startup/allocator and selected Pmark exclusions explicit. The final focused
configuration checker passed in 8.201 seconds without native execution.

## Parallel first-fill family

The packet establishes an order-independent protected subset before CE's
first successful memo fill. For 660 of 675 context Paxiom keys, the CE candidate
is strict-equal to a strongly live raw declaration, and the retained complete
same-key Hsdecl projection initially contains exactly that raw object. There
are 659 physically identical root pairs and one rebuilt strict-equal pair,
First_Or_Default's `input_is_valid__post_axiom`. All protected raw/candidate
closures have no saved-map entries.

The author comparator follows the metadata-before-descent rule, bound-variable
shadowing, outer-frame substitution, trigger grouping, literal representation
kind and physical symbol/type identity. It is a sufficient positive test;
rejections need not decide source inequality. The reviewer additionally uses
an independent structural normalization of all 660 map-free pairs, importing
no author comparator. This verifies the actual positive subset without
claiming generic delayed-frame coverage from samples.

While raw d stays live, successful strict-equal same-key weak merges select d.
An equality exception aborts the merge and does not manufacture a miss. A
transformation memo's false Not_found can recompute without removing that live
root. Candidate tagging occurs before every merge; only the tag counter's
advance depends on the returned candidate identity. The author corrected the
draft wording on this point before freezing. The valid-cache/hash/runtime,
freshness and immutable raw-ownership premises remain explicit.

Two further First_Or_Default keys reduce to `Ttrue`. A strict-equal closed root
must itself be Ttrue, with no children, binders or saved-map edges. That gives
their one-term envelope without a producer-identity argument. The remaining
13 keys are **unclosed**:

| Family | Process occurrences | Candidate stored terms / binders / saved entries |
| --- | ---: | ---: |
| `concat_singleton_left_def` | 5 | 78 / 2 / 6 |
| `bool_eq_rev` | 5 | 52 / 2 / 0 |
| `argument_count__post_axiom` | 2 | 16 / 2 / 0 |
| `argument__post_axiom` | 1 | 35 / 3 / 0 |

Those sizes describe CE candidates, not all possible returned representatives.
The exact failure route remains: CVC5 preparation may fail before filling a
key; the parallel queue proceeds through Z3 before Alt-Ergo's first CE fill.
Z3 simplifiers can produce matching logical rewrites. The thirteen-stage
inventory does not prove every nested producer's actual input/metadata branch
or stored output. Introduction also has a separate name/content Hsdecl and
can reuse `introduced_prsymbol` metadata, so fresh-head exclusion alone is
insufficient. These are explicit missing source obligations, not a request
for another native capture. The synthetic unused-map control illustrates
equality's insufficient structural guarantee and claims no reachable Z3 run.

The independent audit confirms 241/241/69/51/58 raw-protected keys,
0/0/2/0/0 Ttrue keys and 2/2/4/2/3 unresolved keys. The focused frozen checker
passed in 7.746 seconds. Intended parallel stored-family closure and fixed
raw/shared-state attachment both remain false in the result.

The separate prospective direct charge is `2*sum C_g + sum B_g = 309,197`,
conditional on the same fixed raw input and three driver prefixes together
with the accepted once-per-pair parallel owner theorem. It excludes an
additional warning prover, adds no e allowance, and subtracts no completed
Input_Is_Valid call. It is not R51's 317,465 serial post-cut charge. Direct
candidate work can be bounded while the stored-family obligation remains
open; complete inline/Ident capacity does not follow from this arithmetic.

## Incremental quiet/timeless composition

The addendum changes disjoint bytes: the ordinary CVC5 command in cwd's base
config and the two private driver lines. The exact 2,069-byte base config
uses the accepted 167-byte absolute CVC5 command with
`--prenex-quant=none --quiet %f`; other prover records and `command_steps`
remain unchanged. The extra config is still 18 bytes. This recipe introduces
neither an adapter command nor a proxy dependency.

The source interaction argument is sufficient for additive credits. The
command payload is opaque to driver loading and semantic registration, and
Rc values retain no parser locations. `Rc.buf` is separate from the driver's
Lexlib scanner. Removing time directives changes no RC quoted field or buffer
growth. The quiet change is entirely minor allocation and adds no filename,
identifier, driver or pre-cut command queue element; it cannot enlarge the
major-derived FileTags bound. Input_Is_Valid's single pre-cut command copy is
already included in the quiet allowance. Shared allocation counters and
remembered references receive the sum of the two credits.

The composition binds the same full start/end snapshots, PIDs, invocations,
cuts and initial counts, with six identical raw archive hashes. This avoids
using an older fixed-tail cut for Input_Is_Valid. Seven retained quiet payloads
were independently checked byte-for-byte against their exact author commit.
The author checker and independent incremental audit passed in 0.082 and
0.067 seconds respectively, without executing any preceding checker.

Combined credits are **7,582,192 minor words**, **7,578,096 major words** and
**18,924,760 remembered references**. Their maxima are 135,521,923 minor words,
8,526,220 total major-arena words and 18,993,721 remembered entries, below
2^28, 2^24 and 2^25 respectively. The two source simulations share a first-event
argument; they do not assume that two independently safe heap margins compose
without accounting for both perturbations. Initial I and zero queued/server
limits remain unchanged. This composed serial source-prefix result is accepted
under the same named source/runtime and ordinary-service premises.

## Focused validation and review corrections

| Check | Measured elapsed | Result |
| --- | ---: | --- |
| Frozen warning-exclusion checker | 3.831 s | Pass; five domains, 22 source slices |
| Frozen parallel first-fill checker | 7.746 s | Pass; 660 live-raw keys, two Ttrue keys, 13 unresolved |
| Frozen timing-configuration checker | 8.201 s | Pass; 14 deterministic outputs |
| Independent main reviewer audit | 0.718 s | Pass; 133 input hashes, finite kind closure, 660 independent map-free comparisons, allocation geometry |
| Frozen composition checker | 0.082 s | Pass; five identical raw attachments |
| Independent incremental composition audit | 0.067 s | Pass; 38 input hashes, snapshot joins and additive arithmetic |

The source arguments are reviewed reasoning; finite checks are not an OCaml
semantic proof. The reviewer scripts import no author comparator/decoder.
The main audit selects eleven source members and preserves the distinctions
between warnings, configured limits, parallel family closure and conditional
direct charge. The composition audit preserves the successful earlier inputs
and results rather than rerunning them.

Two initial reviewer-only audit attempts failed because the reviewer treated
Put_Line's 2,911 prior-major words first as every process's value, then as a
maximum over that separate field. The corrected audit compares each captured
value and its own combined arena total, then the maximum combined total.
Both failed records and the correction are retained; the author values were
already correct and no author file changed. The earlier source review also
prompted the pre-freeze comment/lexer, startup-allocation and H.tag wording
clarifications described above. No native, compiler, solver, proof, capture,
old/fresh graph-correspondence replay or broad predecessor replay was added.

The [evidence packet](../evidence/retained-adapter-config-parallel-review-20261020/README.md)
retains exact inputs, outputs, selected settings and elapsed-time scope.

## Final disposition

The exact accepted scope is the retained serial configuration/prefix result
and the parallel protected-subset reduction. The latter leaves a named source
producer/metadata/stored-family lemma for 13 keys, plus the intended launch's
raw/shared-state attachment. Complete inline/Ident and whole q/O capacity,
adapter startup/pre-exec effects and outcome/report/attempt-record binding
remain open. A later supervisor/proxy design is outside these frozen inputs.

Keep one global `e<=2` escaping signal-save allowance per process, at most two
save-entering callbacks and three reached saves. No component renews that
budget. Full #119 design justification remains prerequisite to future #88
executable refinement; neither substitutes for the other. R51's accepted
source adapter algorithm remains unchanged, and no production-before-design
cycle is introduced. Parent integration, publication and issue/memory updates
remain separate; #119 / #153 are incomplete.
