# Independent review: solver domains and parallel launch

2026-10-20 UTC, authorized research #119 / #153.

**The four frozen packets are accepted at their stated conditional scopes.**
No material finding requires author repair. Together they supply a fixed-input
command envelope, ordinary CVC5 statistics components and a prospective parallel
launch/record interface. They do not establish complete per-attempt q, weighted
O, native/source refinement, automatic discharge or completion of #119/#153.

## Exact inputs and review setting

Review worktree: `tmp/solver-round46-review`, branch
`review/solver-round46-20261020`; base
`8d9cee6f09ff1e00010c9189314b230a870f52c1`; combined reviewed target
`c0039b09feb91ac3d63b44e837eddd8cd2bacdec`.

| Component | Author freeze | Review-worktree commit |
| --- | --- | --- |
| CVC5 enums | `a78d4322487a47c724afcd4b8669fac364680df8` | `60401303e8cee7a7c82c787285e1265839be27b6` |
| CVC5 registries | `3240054ca08926260dfd1dd2260b76c99cdcbb3c` | `13f6f7dae5a39446c3b1f304a7035bac36924856` |
| Task language | `52196b5f033180e33549cf8ce753c41e65dede1e` | `c0039b09feb91ac3d63b44e837eddd8cd2bacdec` |
| Parallel launch | `4d13ff1e1dc62d396d7588222ec06d9e51455455` | `afc0b2d7b121bd60cb7b4ba83672f10644ca194d` |

Reviewed the four research notes and complete packets:
[enums](../research/retained-cvc5-enum-output.md),
[registries](../research/retained-cvc5-registry-domain.md),
[task language](../research/retained-solver-task-language.md) and
[parallel launch](../research/retained-solver-launch-profile.md).
The reviewer-owned [manifest](../evidence/retained-solver-round46-review-20261020/inputs.json)
hashes every frozen note/packet file. Governing inputs were AGENTS.md, Oracle,
development reporting requirements and the parent's bounded authorization.
The accepted Round 45 output/identity review, task/helper/meta construction,
registered-goal envelope and server-record argument were reused at their stated
scopes; no predecessor checker or capture was replayed.

Reviewer `/root/solver_round46_review` was selected as **GPT-6 Astra / Extra
High**, confirmed by the parent's spawn-selection record. Runtime model/effort
confirmation and token/cost telemetry are unavailable. The child harness goal
returned null; the parent reports its #119 goal active. Actual host:
Linux 7.0.14 x86_64; `scripts/dev.py paths` confirmed isolated worktree routing.
The reviewer did not author or repair any component and spawned no other agent.

## Source-review dispositions

**Enum domains accepted.** Source inspection confirms ordinary
`StatisticHistogramValue::getViewer` renders each positive bucket into a fresh
stringstream, then inserts the spelling into a string-keyed map. Duplicate
spellings collapse there. `printSafe` instead directly traverses each positive
vector bucket; its repeated fallback spellings do not collapse. Thus the seven
ordinary domains and their `4+L+24K` allowances do not export a safe bucket count.
The API Kind route has `std::to_string` and a deprecated `kindToString`, but no
matching unqualified/ADL `toString` overload; safe printing uses the disclosed
`<unsupported>` fallback. The separate internal Kind language dispatch and
generated safe route agree with the note.

The 14 TOML inputs, complete generated Kind outputs, API maps, defaults and
supported-language union agree. Both normal and expert rewrite input lists are
passed to `mkrewrites.py`; expert selection changes rule level rather than
removing the name from the generated switch. The parser transfers the rule name
to `Rule`, and the generator inserts it literally. The 434 generated IDs plus
93 fixed cases match the archived C++ header, with the fallback added separately.
The balanced header scan is not a DSL typecheck. The disclosed missing
`pyparsing`/full rewrite-generator execution remains a build-evidence limitation,
not a fabricated successful build or an installed-source attachment.

**Registry domain accepted.** `registerStat` retains one object per name in
each map; a repeated registration returns another proxy. The dump independently
exports the solver and TermManager maps, so cross-registry duplicate names must
count twice. The source constructor/name chains support the finite superset,
including the conservative unused Normalize timer, the two SAT prefixes,
theory/output-channel prefixes, arrays' doubled timer prefix and SOI's missing
trailing separator. The public-statistic initializer and TermManager's three
actual update proxies support the stated default-row removals; export allocation
can still fail before filtering and is not covered by the byte allowance.

The dynamic equality-engine chain was checked from CandidateRewriteFilter
through CandidateRewriteDatabase, its reconstruction caller and SynthFinder.
The reconstruction caller sets `filterPairs=false`; the REWRITE finder enables
it. The synthesized-rewrite preprocessing pass returns without entering this
route. The four dynamic suffixes give `285R+4L_decimal`, with the counter shared
across registry instances rather than renewed per dump. Plugin names remain
outside the stock-main fixed domain. The R=0 condition requires the generated
command exclusion and its parser/execution preservation, together with the
stock-main/no-external-API premise; it is not a consequence of default options.

**Task-language envelope accepted for the fixed family.** Review read the
complete selected SMT printer and substitution/identifier/task constructors,
with the inherited transform/helper/meta relation. Fixed templates and preludes
cannot inject a command outside the stated family. All recursive substitutions
remain enclosed; sanitized identifiers and quoted string constants supply no
closing-command escape. The two Float80 templates have a positive depth surplus,
so they can make text malformed without closing the enclosing command. Their
reachability and solver semantic acceptance remain open.

The raw filename route is a real distinct surface: `smtv2.ml:822` calls
`Loc.pp_position`, which uses raw `%s`. An LF-bearing filename could leave the
comment and inject text. The packet's complete decoded-input/path census and
location-origin preservation close this route only for the selected five-input
relation. They impose no new Silver path restriction and prove no universal
filename-sanitization property. Task constructors reject additions after a goal;
with counterexample/incremental/minimize metas absent and the debug bypass off,
the printer offers at most one check and one reason query. The common envelope
correctly allows that reason query for Z3 and Alt-Ergo too, because the retained
memo relation does not prove cross-driver freshness. Printing, flushing, buffer
copy and close precede request submission; exceptions there cannot submit the
abandoned partial file under the stated storage/client relation.

This excludes explicit task `set-option`, `set-info :filename`, find-synth,
model, reset and extra-query channels. It does not prove automatic solver option
preservation or parser recovery behavior. In particular, lexical containment
alone cannot become an attached native R=0 or default-option theorem.

**Parallel launch and record bounds accepted.** The candidate GNATprove source
forwards the same worker count to gnatwhy3 and why3server. PATH places GNSA before
the SPARK libexec directory; non-shadowing, exact resolution and descendant
preservation remain required. The exact installed SPARK revision is unattached.
Historical `-j 1` captures remain serial evidence.

For the fresh selected forest, `next` removes the goal before returning it;
parallel result handling does not requeue it, full splitting excludes new split
owners, and counterexamples are off. Scheduling iterates the three immutable
keys; queue pop precedes building and failure handlers do not retry an owner.
The synchronous GNAT idle handler drains before the timeout loop can deliver
Done callbacks. This supports E<=3G without substituting the serial suffix's
`3G+e`. The blocking disjunction also short-circuits the heuristic multiplier
product. Fresh positive call-ID arithmetic still needs `3G<=2^62-1`.

Cancellation does not need an assumption that `remaining:=0` always executes.
The timeout handler removes a completed live call before invoking Done.
Successive distinct completions of k<=3 owners can therefore offer at most
`(k-1)+(k-2)+...+0<=3` peer interrupts, including abandoned send prefixes.
Queue-removal notifications are Interrupted, and a duplicate result finds no
removed owner. An escaping callback exception does not restart the loop.
This uses the stated valid-container, unique-owner and selected-root premises;
it does not cover arbitrary Controller clients or rescheduling.

The raw-ID bound survives partial sends: a later header's first semicolon ends
the current ID before its operands can enter it. The possible stems have width
8 for run/runstdin and 9 for interrupt; combined with <=3G of each,
`I<=20+51G` and `M<=C+60+51G` follow from the accepted response constructor.
Interrupt removal echoes an existing run ID, and this header alphabet cannot
form a parallel frame. These length bounds retain the received-byte-preservation
premise and do not prove the C receive-buffer bridge, caller validity or
successful response construction. SIGKILL racing excludes a solver handler for
that delivered signal only; soft launcher cleanup and ambient signals remain.

## Joint arithmetic and unresolved obligations

The proposed ordinary statistics join checks arithmetically:

```text
883872 + 10892 + 4*23453 + 2*557 + 4*6022 + 4*22527
  = 1,103,886.
```

Thus `Q_stats<=1,103,886+F` per ordinary two-registry dump is available **if**
R=0, stats-all=false, inactive uint32 histograms, no task filename override and
all original object/stream/formatting premises are established. The internal
Kind term uses the supported-language union; no narrower SMT-only route is
assumed. Without the inactive-uint32 premise, the stats-all=false/R=0 expression
is `1,104,005+F+4V_uint32`. The task packet does not discharge automatic
collectPivots/doITESimp/stats-all preservation. Neither expression is a complete
solver output file, and an overlarge conservative allowance is not evidence of
infeasibility.

The filename guard for an SMT location comment and the LF-free protocol/path
guard have different producer chains. Neither can silently replace the other.
Likewise, the fixed-family task theorem and fresh parallel ownership theorem
need an explicit shared launch/input relation before their numeric instances
describe an intended parallel execution. No retained serial backing/formatter
state is transferred by these counts.

The highest-value next deliverable is one complete CVC5 per-attempt output
account over this command envelope: attach parser/error recovery and automatic
option behavior, then bind nonstatistics diagnostic occurrences and payloads
to source-derived generated-task/filename sizes. It should produce a usable q
or identify the precise remaining size/control premise. The current-grammar
attachment and executable/source relation must remain explicit throughout.
This is a recommendation, not new implementation or native-run authorization.

## Verification and handoff

Each new frozen checker ran once; exact commands, outputs and measured
subprocess times are in
[checks.json](../evidence/retained-solver-round46-review-20261020/checks.json).

| Focused offline check | Result | Wall seconds |
| --- | --- | ---: |
| Enum domains | Pass: 55 complete sources, generated domains and arithmetic | 0.897814 |
| Registry domains | Pass: 137 sources, 354 sites, record/name arithmetic | 1.206861 |
| Parallel launch | Pass: 11 source members, seven inputs, five conditional rows | 0.262506 |
| Task language | Pass: five products, exact inputs, lexer/structure controls | 0.917219 |

These checks verify byte identities, retained source anchors, lexical supports
and arithmetic. The source review assesses the conditional arguments; neither
kind of evidence supplies missing native refinement or universal assurance.

Review began **18:22:28 UTC**; source review and report checks finished **18:28:53 UTC**,
**385 seconds** later, including freeze waits and report preparation. Final
record edits and commit follow that interval. Checker subprocess times total **3.284400 seconds**;
the first three ran concurrently. Intended result: challenge the four component
exports and their joins. Achieved: conditional acceptance, no required author
rework, with parser/automatic-option/grammar/native joins preserved. Token/cost
measurements are unavailable. The parent's disclosed pre-freeze registry
over-approximation and launch keyed-case-join correction require no further
repair in the reviewed versions.

All complete q/O exports remain null. The global two save-entering callbacks,
three saves and e<=2 budget is unchanged and never reset per solver, registry,
root, dump or channel. Normal allocator/GC/OS/runtime service behavior for valid
requests does not establish caller arithmetic, ownership or resource bounds.
Oracle, admission and tool/source pins are unchanged; #119/#153 remain incomplete,
production #88–#94 unstarted and PR #121 draft/unmerged. This lane ran no native
target, solver, compiler, proof suite, capture or broad replay; made no GitHub or
CLI-memory write; and edited only this review and its evidence directory.
The lead owns integration, issue state and publication.
