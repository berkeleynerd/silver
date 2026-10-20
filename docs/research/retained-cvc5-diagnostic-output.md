# CVC5 diagnostics: an exact missing recurrence and payload premise

2026-10-20 UTC, Linux x86_64, #119 / #153; author base
`d19f73cb3f3c2d8c32d88c1dda9b3c058090ce07`. Candidate source revision:
`86cecd83b685f59e884094693b9a4c5c90a62e03`.

**One check-sat does not bound nonterminal warning occurrences.** The selected
arithmetic implementation can warn about an integer variable's nonintegral
model value, add a branch-and-bound lemma, and return to search. Later
full-effort checks rebuild the warning's input map. Neither its cumulative
visits nor its generated term/rational payload sizes have been bounded by the
accepted task-language result. This is a precise missing premise for q, not
evidence that the warning occurs on the retained inputs or that finite bounds
are impossible. Actual `q_cvc5` and weighted O remain null.

The [offline packet](../evidence/retained-cvc5-diagnostic-output-20261020/README.md)
reuses the complete Round 45 source archive. It pins the inspected files,
retains focused source excerpts, and checks the byte arithmetic below. Following
the lead's diagnostic checkpoint, this lane stopped at the exact missing
condition rather than expanding a lexical warning-site census into an
unsupported complete-output claim. Parser/automatic-option closure and
terminal/runtime output have separate owners.

## Scope and why command counts do not close this family

The inherited [task-language result](retained-solver-task-language.md) and
[Round 46 review](../reviews/review-solver-domains-and-parallel-launch-20261020.md)
cover the selected five-input/helper/14-driver relation. Each submitted task
has at most one check-sat and one reason query, fixed logic ALL and SMT-LIB 2.6,
and no option-changing, model, echo, statistics-query, reset or find-synth
command. The prospective command remains:

```text
cvc5 --prenex-quant=none --stats-internal %f
```

That containment result supplies no solver semantic-acceptance theorem and no
solver-generated term or search-step bound. Malformed Float80 templates remain
possible. The result is not a theorem for every program in the current grammar.
The concurrent [parser/option lane](retained-cvc5-parser-options.md) reports
preserved verbosity zero, MINISAT,
nodeDepth=-1 and printArithLitToken=false; integrating that lane is required to
attach those defaults after automatic option selection. This note separately
checks the defaults and the local consumers, without replacing that join.

The returning source route is:

| Source | Control fact |
| --- | --- |
| `options/prop_options.toml:5–15`; `prop/prop_engine.cpp:87–95`; `prop/sat_solver_factory.cpp:26–30`; `prop/minisat/minisat.cpp:109–129` | The MINISAT choice constructs the MiniSat wrapper and its SimpSolver. |
| `prop/minisat/core/Solver.cc:1486–1500,1590–1620,1663–1681` | `search` has a `for (;;)` loop. A final check with `recheck` continues; absence of a decision selects CHECK_FINAL and continues. |
| `prop/minisat/core/Solver.cc:1168–1183,1276–1279`; `prop/theory_proxy.cpp:209–214,272–277` | CHECK_FINAL calls EFFORT_FULL through TheoryProxy. New lemmas set `recheck=true`; the call can return to search. |
| `theory/theory_engine.cpp:377–455`; `theory/theory.cpp:541–599` | Enabled theories receive `check(effort)`, which dispatches virtual `postCheck(level)`. |
| `theory/arith/theory_arith.cpp:268–304,493–509` | A full-effort arithmetic post-check clears both model caches, resets their validity flag, repopulates them, then calls `sanityCheckIntegerModel`. No check-model or model-dump option gates this call. |
| `theory/arith/linear/theory_arith_private.cpp:3973–4030` | For a relevant arithmetic/shared integer term, a nonintegral `mod.substituteDelta(delta)` is stored as a real Rational node in `arithModelIllTyped`. This is an explicit supported correction route in the source, not merely an assertion-failure printer. |
| `theory/arith/theory_arith.cpp:543–575`; `theory/arith/branch_and_bound.cpp:47–54,125–154` | Each map entry prints the warning, constructs a branch lemma, and submits it. If any lemma is new, the routine returns true normally; only the no-new-lemma bad-assignment branch reaches AlwaysAssert. |

Thus a fatal-path allowance of one warning is unjustified. A repeated event
need not correspond to another input command, another input token or another
distinct variable. The source control permits continued search; this argument
does **not** prove that a concrete selected input takes any particular branch,
repeats a warning, or diverges.

`EnvObj::warning()` selects `verbose(0)`, and `Env::isVerboseOn` permits it in a
nonmuzzled build at verbosity zero (`smt/env_obj.cpp:88–94`, `smt/env.cpp:183–201`).
The stream is the solver error stream. These are raw warning bytes; the command
failure printer's quote-doubling rule does not apply.

## The exact byte interface and missing condition

For one completed ordinary warning event with pair `(term,value)`, the source
prints:

```text
TheoryArithPrivate generated a bad model value for integer variable <term> : <value>\n
```

The fixed bytes, including separator and LF, total **72**. Let `R_s(x)` be the
byte length of rendering x on the actual stream s. The event length is exactly
`72 + R_s(term) + R_s(value)` under the inherited ordinary stream/service
premises. Prefixes of an interrupted event can be charged to the same full
envelope when the operand-formatting contracts hold.

The value is a nonintegral Rational. In the SMT2 printer with arithmetic-token
printing off, a positive value is `(/ numerator denominator)` and a negative
one is `(/ (- numerator) denominator)`. If a and b are the decimal digit counts
of its absolute numerator and positive denominator, its length is at most
**a+b+9** (`printer/smt2/smt2_printer.cpp:70–146,320–324`). The GMP representation
uses `mpq_class`/`mpz_class`, not int64 values (`util/rational_gmp_imp.h:151–160,319`;
`util/integer_gmp_imp.h:332,340–343`). The 20-byte statistic integer allowance
therefore does not apply. This rational formula is conditional on the named
SMT2 stream/formatting join; the exact `R_s` interface also covers another
identified printer.

For every selected task of at most N submitted bytes, and every execution
prefix to be charged to that attempt, it would suffice to establish prospective
bounds:

- `K_ar(N)`: the cumulative number of entries reaching the warning insertion,
  over all full-effort checks and every solver instance whose error stream
  reaches this attempt's output;
- `L_ar(N)`: the sum of their rendered term bytes, counting every repeated
  occurrence;
- `D_ar(N)`: the sum of their numerator and denominator decimal digit counts.

Then this family's output, including abandoned prefixes under the stated
formatting contracts, has the local allowance:

```text
W_ar <= 81*K_ar(N) + L_ar(N) + D_ar(N).
```

An alternative is a source-corresponding invariant establishing `K_ar(N)=0`
for the entire selected construction/helper relation: every relevant integer
model assignment is integral whenever this cache is populated, or this path is
otherwise excluded. An input-size theorem alone does not establish that
invariant. Likewise, bounds on the number of distinct input variables or on
the size of one live map do not bound cumulative visits across cache resets.

The current evidence exports **none** of these three functions or the zero
invariant. `nodeDepth=-1` supplies no depth cutoff. Even an independently bounded
depth would not bound a numeric leaf's digits, identifier bytes, node arity or
cumulative prints. DAG sharing may reduce a particular rendering but is not a
byte cap. A source proof relating generated arithmetic terms, numeric growth
and search recurrence to the selected tasks is the missing work.

The selected resource/time limits are zero. `ResourceManager::outOfResources`
tests only positive limits; `outOfTime` returns false for a zero per-call limit
(`util/resource_manager.cpp:288–320`). Restart conflict budgets in MiniSat are
local search budgets, and its outer solve loop restarts while status is
undefined (`Solver.cc:1748–1773`). They are not a whole-attempt output cap.
No new timeout, truncation, post-run test or language restriction is proposed.
The finite type of a statistic counter is also not an enforced loop limit:
`IntStat::operator++` performs an ordinary increment
(`util/statistics_stats.cpp:42–58`). An assumption excluding overflow would
itself need its caller arithmetic proof; it cannot silently become the missing
search bound.

## Exception payloads are a distinct rendering obligation

The accepted command, main API, main option, located-parser and file-open
wrappers remain `11+2m`, `11+m`, `67+m`, `68+F+m`, and `44+F`. They are reused,
not remeasured here. The parser lane owns their selected occurrence controls.
Those counts do not make m a fixed constant or a raw-token length.

For a concrete producer within an admitted command family,
`Solver::defineFun` checks the function body's result sort
(`api/cpp/cvc5.cpp:7432–7445`) and can build this message:

```text
invalid sort of function body '<term>', expected '<sort>', found '<actual-sort>'
```

Its fixed part is **55** bytes; its raw payload has length
`55 + R(term) + R(sort) + R(actual-sort)` on the exception's stringstream.
Consequently the ordinary command wrapper has the local bound
`121 + 2*(R(term)+R(sort)+R(actual-sort))`.
`DefineFunctionCommand::invoke` catches `exception&` and stores `what()` in
CommandFailure (`parser/commands.cpp:1207–1223`). The relevant API exception
stream stores the built string unchanged (`api/cpp/cvc5_checks.h:56–71`), and
the API exception's `what()` exposes it (`include/cvc5/cvc5.h:104–111`). This is
a producer/interface calculation, not a claim that a selected task has a sort
mismatch. Excluding the branch needs semantic acceptance; bounding it needs a
relation from the selected parsed term/sort representation to task size.

There is an important distinction for internal type exceptions:
`CVC5_API_TRY_CATCH_END` copies `e.getMessage()` from an internal Exception.
It does not call that exception's virtual `toStream`. Thus the extra duplicate
node decoration in `TypeCheckingExceptionPrivate::toStream`
(`expr/node.cpp:57–60`) is not added by this API translation. Its raw message
can already contain rendered operands, however. A proof about node-printer
depth does not bound arbitrary raw `std::string` payloads or external
`std::exception::what()` implementations. Those require their own producer
and runtime interfaces.

This packet does not claim that the arithmetic warning and the displayed
define-fun guard exhaust diagnostics. The identified returning warning alone
prevents replacing the unresolved warning term W with command-count constants.
The complete source-family account remains unfinished; stopping here answers
the authorized alternative, an exact evidenced missing size/control premise.
It does not create a new exemption for other warnings, direct output,
exceptions, cleanup, failed printers or terminal families.

## Evidence boundary and handoff

Source identity is the retained upstream archive, not native behavioral
refinement. The installed executable's embedded revision remains identification
evidence only. No solver, native target, proof suite, capture, source fetch or
network operation was run. The focused check validates identities, excerpts,
defaults and byte arithmetic; it does not execute C++ or prove reachability,
the recurrence bound, semantic acceptance, automatic discharge or source/native
correspondence. The lead owns joint integration and independent review.

The global Why3 suffix budget remains two save-entering callbacks, three saves
and e<=2, never renewed for warnings, printers or solver instances. Oracle,
tool/source pins, admission and solver commands are unchanged. #119/#153 remain
incomplete; production #88–#94 is unstarted and PR #121 remains draft/unmerged.

Selected author settings: GPT-6 Astra / Extra High, as assigned by the lead;
runtime model/effort confirmation and token/cost telemetry are unavailable.
Actual host, measured elapsed/check time and the local witness correction are
recorded in the packet. No independent review is claimed by this author.
