# Independent review: pre-inline prefix and solver-response adapter

2026-10-20 UTC, Round 51; authorized continuation of #119 / #153.

**Accepted at the exact freezes below:** the pre-inline direct identifier
charge for the retained serial route, under its named premises; and the
source-level solver-response adapter algorithm under the named Re/runtime
premise. The parallel first-fill finding was resolved by narrowing the prefix
claim. Intended parallel transfer and the remaining whole-rule design joins
are open; this review does not complete #119 or #153.

## Review setting and boundary

Reviewer `/root/quiet_output_review` was selected as GPT-6 Astra / Extra High;
runtime model/effort confirmation and token/cost telemetry are unavailable.
The actual host is Linux x86_64. The child goal query returned null; the parent
reports #119 active and incomplete. The reviewer authored neither component,
spawned no agents, and made no native, compiler, solver, proof, capture, broad
predecessor replay, GitHub, memory or harness write. Parent integration and
publication are separate from this review.

| Component | Author freeze | Reviewer import |
| --- | --- | --- |
| Response adapter | `57901cea8ad2c62f1ad9205cc048b8a994e362b2` | `490f2432811fb7193e4e7c1417245a24c52b6a17` |
| Pre-inline prefix | `486754009921aaf6bd6d2ca15bccd92b218e3789` | `8e8001c670468df7de49cc1ea5b95fcafcb5c147` |

The combined review input is
`8e8001c670468df7de49cc1ea5b95fcafcb5c147`.
The [input manifest](../evidence/retained-prefix-adapter-review-20261020/inputs.json)
binds all 35 component files to those freezes and hashes 60 input files in
total. Both final author checks left all tracked files unchanged.

The review worktree is `tmp/quiet-output-review`, branch
`review/quiet-output-20261020`, initially at the accepted R50 review
`a06771ee42938c1da476e199c17d696476b54760`. Earlier frozen files remain unchanged.
The first retained review clock is 20:10:25 UTC. Full-subthread/team costs are
unavailable. The packet retains final elapsed time and exact check outputs.
Acceptance was recorded at 20:49:15 UTC, 2,330.270 seconds after that first
retained clock; this interval is not full-subthread or team time.

Read AGENTS.md/Oracle and the bounded parent brief, the response-adapter design
question, both new author components and the relevant Why3/Re source. The
existing source/runtime trust premise remains explicit. This review adds no
historical binary attestation gate and changes no Oracle, pin or admission rule.

## Pre-inline source obligations

The fixed Alt-Ergo order is CE-off `counterexamples_dependent_intros`, then
`monomorphise_goal`, then `inline_trivial`. CE-off uses
`remove_unused_from_context`; it is not a no-op. In particular, polarity-sensitive
Tiff and proposition Tif branches may duplicate structure. Tlet opens a binder,
maps the opened body's immediate children through the recursive reducer and
may retain an unused-copy binder. Assuming universal shrinkage would miss both
structure and identifier work.

The model/source review checks delayed substitution maps, free-variable
multiplicities, physical closing shortcuts, t_attr_copy, alpha equality,
single-use let substitution and quantifier pruning. Default t_equal ignores
attributes, locations, triggers and literal spelling; stored representative
identity and metadata cannot consequently be inferred from alpha equality.
No-cache mapped candidates and actual cache representatives retain separate
obligations.

The cache analysis must allow a signal-origin Not_found to be consumed by
Wdecl.memoize's find handler, forcing recomputation despite a live key. Mere
key liveness does not exclude later misses. A narrower representative-family
argument can use the old memo value's continued liveness: OCaml Weak.merge
does not catch an exception from equality and turn it into a miss. Its validity
still requires the candidate's strict equality to a live family member, the
existing tag/hash/runtime premises and exclusion of foreign mutations. Failed
first fills do not install a memo value and retain their separate episode
charges. The four initial tables are retained in the registration capture
archives; their projection and prefix attachment are evidence work, not a
reason to request new captures.

The final packet projects complete Hsdecl tables for all five cases. Each
matching Paxiom key in the four registration tables has only its raw
declaration; the model conservatively retains compatible raw and candidate
forms. Input_Is_Valid starts from the already observed CE family. Library
parse/core/program clones use fresh proposition symbols under the retained
freshness premise. These are stronger premises than alpha equality alone:
the family argument also depends on raw-key liveness, freshness/no-wrap up to
the first invalid state, valid caches/runtime and no foreign mutation.

**Material finding and scope correction.** The draft first-fill argument could
not transfer to the intended parallel route. `gnat_checks.ml:1055–1079` queues
CVC5, Z3 and Alt-Ergo, while `controller_itp.ml:528–534` catches a failed CVC5
preparation and can continue to Z3. Z3 can consequently populate Hsdecl before
Alt-Ergo's first CE fill for an unseeded key. The live-seed argument applies
after installation and does not repair that initial gap. The author and parent
confirmed this finding and narrowed the final component to the **retained
serial route**, whose episode theorem was used for its numerical composition.
Prospective J>1 seed closure remains an explicit #119 obligation.

The serial route has the required exclusion: has_been_tried_by requires a
nonempty proof_state and returns false on Not_found; InternalFailure leaves
that state unset; the serial Gnat_main callback only warns and does not advance
to the next prover. Any other goal that has advanced beyond CVC5 has already
completed CE on the physically shared common context. Under the retained
fresh/non-replay ownership and valid-cache premises, first successful context
fills therefore precede downstream transformations. The report does not infer
the intended parallel transfer from this serial fact.

The final result explicitly sets `intended_parallel_seed_closure=false` and
`intended_parallel_episode_composition_claimed=false`, while setting
`retained_serial_seed_closure_under_named_premises=true`.

The independent checker traverses each raw task proposition directly from its
block archive, including hidden saved images and binder-variable types.
Together with CE's type-preserving constructors, substitutions and fresh-variable
types, a zero-type-variable result can select monomorphise_goal's empty branch.
That branch still constructs a proposition declaration; it does not erase its
validation/wrapper cost or the preceding CE work.

The retained serial prefix component uses `2*S_CE + S_mono + 2*M_Alt` per process:
the first CVC5 and Alt-Ergo episodes each perform CE, only Alt-Ergo performs
the empty monomorphisation goal validation, and at most two extra episodes
are charged at the largest Alt-Ergo prefix. Z3 reaches inline directly. The
same existing e<=2 allowance is used; it is not renewed for this component.

| Case | Sum of CE charges | Sum of mono goal charges | Maximum Alt prefix | Post-cut prefix charge |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 72,593 | 2,340 | 1,335 | 150,196 |
| Put | 59,124 | 1,743 | 1,271 | 122,533 |
| First_Or_Default | 18,743 | 747 | 847 | 39,927 |
| Is_Message | 1,246 | 6 | 440 | 3,378 |
| Input_Is_Valid | 472 | 5 | 477 | 1,431 |
| Sum over five separate processes | | | | **317,465** |

The full charge is 317,937. Input_Is_Valid's completed first CVC5 CE allowance
472 is removed from the suffix; this is not a claim of an observed counter
delta of 472. The component excludes R50 update, transform lookup/initialization,
pending callbacks and inline execution. It is not a complete Ident no-wrap
argument or complete inline-capacity envelope.

For Input_Is_Valid the completed 472 allowance consists of 181 mapping and
291 validation charges (168 mapped binders and 123 formal openings). The
source-model/observed join compares 244 logical declarations, 143 mapped roots,
1,933 stored terms, 157 binders and three nonempty maps containing eight
entries (maximum map size six). Its alpha/trigger equality and stored counts
do not claim complete stored-graph isomorphism; the accepted R50 old/fresh
graph isomorphism remains a separate result. The BuiltIn equality pointer is
attached to the physical fourth logical declaration after three Dtypes and
checked by name/signature. Its enclosing Use payload was not captured, so the
stated source/native attachment premise remains explicit.

## Response semantics challenged

The finite answer reducer is downstream of exact full_split and ordered grep.
Why3 first splits by the loaded union regex, then runs the ordered individual
regexes again on each isolated Delim. The originating union alternative alone
does not identify the answer. All bytes remain relevant until a justified
quotient has been extracted.

Concrete source cases raised during review:

- `(:reason-unknown \nunsat\n)\n` admits a whole multiline reason delimiter;
  removing its closing parenthesis makes that candidate fail and exposes the
  inner Valid line. A line scanner that commits the inner Valid is unsound.
- A CVC5 reason delimiter containing the anchored not-unknown error line can
  be reclassified as `(not unknown!)` by the earlier rule. Earlier CVC5 OOM
  literals likewise take precedence when grep scans the isolated delimiter.
- `unknown\n\n(:reason-unknown resourceout)\n` has a maximal two-LF Text token,
  which separates its Unknown answers. Only a Text token exactly equal to one
  LF is discarded; independently discarding every LF changes U to StepLimit.
- Fixed literal delimiters can cross a proposed wildcard splice boundary.
  Earliest-start and greedy-end handling must retain the pending literal state,
  not just a previously committed reducer snapshot.
- The interrupted canonical prefix `unsat` already matches `^unsat$` at EOF;
  Valid dominates the terminal signaled HighFailure. A bound on partial output
  is insufficient to establish completion/cancellation correctness.

The adapter requires authoritative attempt-bound completion, child status and
resource/defect evidence. Missing or truncated evidence cannot establish
confirmation. SIGKILL is not an OOM attribution. Existing Why3-server process
groups are a useful source fact, but making the adapter the immediate child
changes wait-status and CPU attribution and requires the stated supervision
contract. Success, unsuccessful-report inspection and interruption must retain
the #88 distinction, including successful alternatives with interrupted losers.

Canonical warning compression is acceptable only at the demonstrated audit
projection: warning presence, answer kind and separately required outcome
evidence. It is not equality of raw diagnostics. Similarly, dropping TimeRegexp
requires the explicit private configuration/source/consumer join; timeout zero
does not disable the independent default warning-time threshold.

The reviewed design separates 110 reducer states and three pending Text states,
uses finite transform summaries on their 330-state product, and retains relative
position ranks instead of a growing byte offset. Fixed literal overlap facts
support the wildcard gap cuts; the reason candidate retains a fallback parser
until its first closing parenthesis is decided. Under the explicit selected
Re API/runtime premise, the final construction justifies a source-level
recognizer algorithm contract. The remaining design joins are configuration,
strict-warning/cost/attempt-record policy and startup-output bounds, rather
than an unidentified additional byte-parser lemma. They remain #119
prerequisites. Future #88 implementation/refinement cannot substitute for them.
The proposed 76-byte completed response does not bound Why3-server pre-exec
diagnostics or adapter startup failures.

The API source is ocaml-re 1.12.0 at
`f09672608781dc05172ad980a6e9a483c3b9d534`. It supplies the stated behavior
contract; the review does not attest an installed Re version. The constructive
argument covers positive-length full_split, ordered isolated-Delim grep,
multiline reason fallback, Alt-Ergo's anchored greedy suffix and a persistent
Text gap. The main and fallback banks reuse storage and track finite relative
ranks, so the proposed layout does not store a whole line or cumulative input
offset. Its 2,048 transform rows of 330 two-byte entries plus 65,536 reserved
bytes total **1,417,216 bytes**, below 2 MiB. No additional missing
source-algorithm lemma was identified after the review challenges above.

The final-only emission contract requires a complete attempt-bound decision
record before canonical emission and reconciliation of child status with
adapter completion/interruption. It does not preserve the classification of
every cancelled raw prefix. Missing, truncated or conflicting records cannot
confirm success. SIGKILL/exit 137 alone cannot establish OOM, and the selected
OOM regex labels also cover segmentation faults and configured allocation
caps. Those are named diagnostic-rule facts, not interchangeable causal
resource evidence.

## Final validation and disposition

All focused checks passed on Linux x86_64 at the exact combined input:

| Check | Measured elapsed | Result |
| --- | ---: | --- |
| Frozen adapter checker | 1.389 s | 354,312 token cases; 106 reachable of 110 states; 31 canonical rows, maximum 76 bytes |
| Frozen pre-inline checker | 34.112 s | Five cases pass; no native run or predecessor replay |
| Independent reviewer checker, initial artifact generation | 5.354 s | 60 input hashes, five raw proposition audits, overlap audit and prefix composition pass |

The adapter check also regenerates the byte-construction packet identically,
including 1,555 CVC5 and 11,111 Z3 finite endpoint fixtures. These finite checks
corroborate the reviewed source argument; they are not themselves a universal
Re.Str proof. The reviewer checker imports no author decoder or transformation
model. Its raw proposition results are:

| Case | Propositions | Stored terms | Stored binders | Hidden image roots |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 308 | 22,477 | 5,931 | 387 |
| Put | 297 | 17,790 | 4,715 | 310 |
| First_Or_Default | 108 | 7,744 | 1,731 | 44 |
| Is_Message | 57 | 1,337 | 143 | 0 |
| Input_Is_Valid | 66 | 1,545 | 156 | 4 |

Every case has zero Tcase nodes and zero free type variables, including hidden
images, binder variables and free-map keys. These raw-input audit counts are
distinct from the transformed Input_Is_Valid join above. The independent
literal audit checks 402 CVC5 and 252 Z3 relative offsets, including containment
cases, with no compatible crossing and no simple-delimiter containment. It
independently confirms the 317,937 full / 317,465 post-cut arithmetic and the
shared per-process e<=2 budget, and rejects a claimed parallel seed closure.
Fifteen source members are retained as selected review excerpts.

The [review packet](../evidence/retained-prefix-adapter-review-20261020/README.md)
retains exact commands, outputs, measured intervals and selected reviewer
settings. Earlier accepted R50 checks were reused without replay. No compiler,
solver, proof, capture or broad predecessor run was added.

The accepted results are the **serial retained prefix component** and the
**source-level response-adapter algorithm** under their explicit premises.
Remaining #119 design obligations include intended-parallel first-fill/episode
transfer; the private no-TimeRegexp configuration and changed-prefix transfer;
warning-attempt timeout routing; strict warning/cost/attempt-record policy;
server pre-exec and adapter startup/fatal-output bounds; and completion of the
whole rule, including the unresolved native full-file q route. Warning-attempt
kind is separate from answer-parser `Loc.warning` diagnostics. R52 work on
these joins is outside this frozen review.

Future verified SPARK Bronze/Silver implementation and Lean/source refinement
belong to #88 after the design is justified. They neither block acceptance of
the present source algorithm nor discharge the remaining #119 design joins.
No production-before-design dependency is introduced. #119 remains active and
incomplete; parent integration, issue/memory updates and publication are separate.
