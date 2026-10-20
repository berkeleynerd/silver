# CVC5 statistics registry and name domain

2026-10-20 UTC, Linux x86_64, #119 / #153; author base
`8d9cee6f09`. Candidate CVC5 revision
`86cecd83b685f59e884094693b9a4c5c90a62e03`.

**The ordinary stock-main registry has a finite static name/type superset,
plus one explicitly counted dynamic equality-engine family.** With
`stats-all=false`, the static two-registry superset has **622 records,
20,096 name bytes, 420 integral values, five averages and 125 timers**.
These are upper-domain counts, not observed output or a promise that every
record prints. They close the registry parameters of the accepted ordinary
statistics interface. Generated enum key/value printers, generated-task option
preservation, failed-output families and executable/source correspondence remain
separate joins. Actual `q_cvc5` and weighted O remain null.

The [offline packet](../evidence/retained-cvc5-registry-domain-20261020/README.md)
reuses the complete source archive from
[Round 45](retained-cvc5-output-capacity.md). It retains every expanded direct
registration site, typed names tagged by registry, source identities and checked
arithmetic. The [accepted review](../reviews/review-solver-output-and-identity-20261020.md)
supplies the ordinary formatting bounds and seven finite histogram spelling
domains. No solver, compiler, proof suite, generated task or native executable
was run here.

## Scope and the two registries

The prospective command remains:

```text
cvc5 --prenex-quant=none --stats-internal %f
```

This argument concerns the stock ordinary executable and its internal
constructors, without an external library client supplying arbitrary internal
constructor names or registering plugins. It includes all retained theory,
preprocessing, proof and SAT-backend name families as a conservative superset;
it does not exclude them merely because a default option is off. The registered
superset is independent of `stats-all`; the smaller projection explicitly
requires that option to remain false at the dump. Ordinary represented C++
objects, valid registry lifetimes and the accepted stream/locale premises are
still required. A lexical source check is not a compiler-complete call graph or
a source-to-binary refinement proof.

`StatisticsRegistry::registerStat` stores a single object per name in its
`std::map`; registration of the same name and type issues another proxy to that
object. Entries persist for the registry's lifetime. Reconstructing a component
does not multiply a fixed name, and deleting a component does not remove its
old names. Types of duplicate expanded names agree in the packet. These facts
bound records over the whole run, including late registrations, not merely
initialization or currently live components.

`Env` owns the solver registry (`src/smt/env.cpp:65–73`). TermManager owns a
different private registry (`src/api/cpp/cvc5.cpp:5312–5369`). Both constructors
pre-register public statistics. `CommandExecutor::printStatistics` exports and
prints them separately (`src/main/command_executor.cpp:81–105`), so names shared
across registries count twice. Internal subsolvers have their own Env registries;
their construction cannot add their separately owned maps to this dump. A route
that prints additional registries needs its own multiplicity, rather than
reusing this one two-registry bound.

The public initializer registers 47 names per registry: three API histograms,
`driver::filename`, `global::totalTime`, and three InferenceId histograms for each
of the 14 TheoryId values before THEORY_LAST. The theory inference managers
re-register those same 42 solver names; they do not create another 42 records.
TermManager's three API registrations likewise reuse its public entries.

For `stats-all=false`, TermManager can print only its three API histograms:
its code modifies no other public statistics, exposes an exported copy rather
than its private registry, and never starts its public timer or sets its filename.
Conversely, the solver's three public API histograms are never modified; API
construction updates TermManager's proxies. This removes 47 possible rows in
total. The source search found the public names only in these registrations and
the specific filename/solver-timer updates. This is a producer/default-value
argument, not an inference from seeing empty output. Export still visits all
registered values before filtering, so allocation/export failures are outside
this byte account.

## Constructor-prefix closure

The 354 direct member registration sites (185 literal, 169 expression) remain
an inventory, not a record count. A fresh all-`src/` scan, including non-cpp/h
suffixes, found no additional registration spellings outside the registry's
own methods. The following source chains supply the expression domains. Exact
expanded names and their original registration sites are in `expanded-sites.json`.

| Expression family | Source-derived domain and caller chain |
| --- | --- |
| Preprocessing timer | `preprocessing::` plus 36 literal constructor names. The registry has 35 `callCtor<T>` entries, each invoking `new T(ppCtx)`; BVGauss supplies its `bv-gauss` default. The unused/unregistered `Normalize` constructor is conservatively included. |
| SAT backends | Factory methods forward their name to their statistics constructor. PropEngine supplies empty prefix; BVSolverBitblast supplies `theory::bv::BVSolverBitblast::`. The superset allows both prefixes to each of CaDiCaL, CryptoMiniSat and Kissat, including backend combinations not constructed by the ordinary caller. |
| CNF stream | PropEngine passes `prop`; BVSolverBitblast passes `theory::bv::BVSolverBitblast`. Each registers two suffixes. |
| SolverEngine | The sole source construction omits its name argument; the declared default is `smt::SolverEngine::`. |
| Arithmetic | FCSimplex passes `theory::arith::FC::`; SOI passes exactly `theory::arith::SOI` (no trailing separator); TheoryArithPrivate passes `theory::arith::`. |
| Arrays / BV / finite fields | The ordinary theory factory uses constructor defaults: arrays `theory::arrays::`, forwarded also to ArrayInfo; the BV statistics constructor explicitly receives `theory::bv::`; FfStatistics explicitly receives `theory::ff::`. Field instances share the supplied FfStatistics object. |
| Theory timers | `getStatsPrefix` supplies the 14 theory prefixes. TheoryEngine's `addTheory` constructs each TheoryClass without a custom instance name. Arrays' explicit default instance adds another `theory::arrays::` in its two timer names; all other instance strings are empty. |
| Inference managers | Direct and buffered constructors supply the corresponding fixed theory prefixes; UF appends its empty default instance. The public initializer already reserves all 42 resulting names. |
| Output channels | Fourteen theory prefixes, plus `RelevanceManager::` and `PartitionGenerator::` from TheoryEngineModule constructors. PluginModule is treated separately below. |
| UF symmetry breaker | TheoryUF forwards its empty default instance; the statistics prefix is `theory::uf::symmetry_breaker::`. |
| Equality engines | Nineteen fixed constructor names, each followed by `::`, plus the dynamic family below. EeSetupInfo values are forwarded unchanged by the central/distributed manager; the model name is the literal `DefaultModel`. |

The fixed equality-engine names are:

```text
arith::ee                         central::ee
master::ee                        theory::master
shared::ee                        DefaultModel::ee
ConjectureGenerator::ee           theory::arrays::pp
theory::arrays::mayEqual          theory::arrays::ee
theory::bv::ee                    theory::datatypes::ee
theory::fp::ee                    theory::sep::ee
theory::ff::ee                    theory::sets::ee
theory::uf::ee                    theory::strings::ee
theory::bags::ee
```

The corresponding declarations, default arguments, forwarding constructors,
factory instantiations and EeSetupInfo assignments were read together. Source
anchors and full-file hashes are retained against the existing complete archive;
the checker verifies those anchors and arithmetic, not C++ reachability.

## The dynamic family and the selected zero condition

`CandidateRewriteFilter::initialize` increments a `static thread_local unsigned`
counter and formats `_dyn_rewriter_<counter>` (`candidate_rewrite_filter.cpp:30–58`).
DynamicRewriter adds `DynamicRewriter::`; EqualityEngine adds `::` and registers
four integral suffixes: `mergesCount`, `termsCount`, `functionTermsCount`, and
`constantTermsCount`. Thus for a prospective set C of counter values that can
register in the printed solver registry, let `R=|C|` and
`L_decimal=sum(c in C, |decimal(c)|)`. The additions are exactly:

```text
S += 4R; I += 4R; L_names += 189R + 4L_decimal
Q_stats += 285R + 4L_decimal.
```

The thread-local counter is shared across registry instances and wraps according
to unsigned arithmetic. It is not reset per registry. No initial-segment
assumption is made about C. With 32 unsigned value bits and ordinary decimal C
formatting, `R<=2^32`, `L_decimal<=10R`, hence the contribution is at most `325R`.
Allowing all unsigned32 values gives 17,179,869,184 records and
1,391,419,926,760 bytes for this family alone. This is a conservative type-domain
allowance, not actual output or a capacity impossibility claim. Other unsigned
widths must substitute their own finite range.

There is a useful source-based zero condition. CandidateRewriteDatabase is the
sole owner of CandidateRewriteFilter and calls its initializer only when
`d_filterPairs` is true. Its reconstruction caller in `rcons_type_info.cpp:44`
sets that flag false. The other construction is SynthFinder's REWRITE branch
(`synth_finder.cpp:148–156`), with REWRITE_INPUT normalized to REWRITE.
SynthFinder instances come from `FindSynthSolver::findSynth`, invoked through
`SolverEngine::findSynth` and the API/parser FindSynthCommand route. The
`synth-rr` preprocessing pass's `applyInternal` returns NO_CONFLICT without
running that route. Consequently **a generated-command inclusion proof excluding
find-synth/find-synth-next, with the stock executable and no external API
injection, gives R=0**. This condition does not rely on a default rewrite option.
The [generated-task argument](retained-solver-task-language.md) supplies this
premise only within its selected five-input/14-driver closure and source/runtime
relation; applying R=0 remains conditional on the joint acceptance of that
scope. No universal task-language or semantic-acceptance claim follows from
this registry packet.

PluginModule's name is `Plugin::` plus the plugin's virtual `getName()`, so the
entire C++ library API has no source-only fixed plugin-name set. The ordinary
stock main does not register plugins: Env's vector starts empty and the only
insertion chain is the external Solver::addPlugin API. If that scope changes,
P distinct plugin names with total name length L_plugin require an additional
upper allowance `S+=6P`, `I+=6P`, `L_names+=127P+6L_plugin`, and
`Q_stats+=271P+6L_plugin`. Such an API extension needs its own plugin behavior
and registration contract; it is not part of this selected command.

## Instantiating the ordinary statistics interface

All tables below exclude the explicitly separated dynamic family. They count
each registry/name pair once, irrespective of registration multiplicity.

| Static superset | S | L_names | I | D | T | String records |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Solver, all registered | 622 | 20,096 | 420 | 5 | 125 | 1 |
| TermManager, all registered | 47 | 1,353 | 0 | 0 | 1 | 1 |
| Both, all registered | 669 | 21,449 | 420 | 5 | 126 | 2 |
| Solver, stats-all=false | 619 | 20,058 | 420 | 5 | 125 | 1 |
| TermManager, stats-all=false | 3 | 38 | 0 | 0 | 0 | 0 |
| Both, stats-all=false | 622 | 20,096 | 420 | 5 | 125 | 1 |

The integral category includes all IntStat, uint32/int64/uint64 ReferenceStat
and the ArrayInfo container SizeStat sites. There are no additional string
ReferenceStat sites. Both string ValueStat sites use `driver::filename`; the
public registration and late SolverEngine::setInfo update share that name.
TermManager's value remains empty. Let M bound the effective filename's bytes:
the CLI filename and any generated `set-info :filename` value. Then
`L_strings<=M`; if that task override is excluded, M is the prospective filename
length F. The value is a raw statistic string, so its complete byte length,
including any embedded newline, must be counted. Filename observations from
one run do not establish F.

| Histogram type | Both registered | Both, stats-all=false |
| --- | ---: | ---: |
| InferenceId | 87 | 45 |
| API Kind | 2 | 1 |
| internal Kind | 4 | 4 |
| TypeConstant | 4 | 2 |
| ProofRule | 4 | 4 |
| ProofRewriteRule | 4 | 4 |
| uint32 | 4 | 4 |
| Resource / LearnedRewriteId / TrustId / bags::Rewrite / strings::Rewrite | 1 each | 1 each |
| TheoryId | 2 | 2 |

For each type X, let V_X bound one ordinary histogram value, excluding its name
and record wrapper. It must include its valid key spelling domain, multiplicity
and map-collapse argument as in Round 45. Substituting the seven accepted finite
families and the stats-all=false table gives:

```text
Q_stats <= 883991 + M
           + V_APIKind + 4V_internalKind + 2V_TypeConstant
           + 4V_ProofRule + 4V_ProofRewriteRule + 4V_uint32
           + 285R + 4L_decimal.
```

The corresponding all-registered envelope replaces the constant by 1,664,192,
V_APIKind by 2V_APIKind, and 2V_TypeConstant by 4V_TypeConstant. Its empty
TermManager string contributes zero bytes. These envelopes deliberately include
unreachable/default static families; a future tightening needs a source argument.
The generated-enum lane owns the remaining enum V_X values; no key table is
re-derived here.

The Round 45 pivot/ITE entry argument can also be joined explicitly. If every
selected task preserves collectPivots=false and doITESimp=false, alternative ITE
pass entry points are excluded, and stats-all=false, the four uint32 histograms
remain default and are omitted. Remove their four rows and 103 name bytes:
`S=618`, `L_names=19993`; the displayed constant becomes **883872** and its
`4V_uint32` term disappears. A default declaration alone does not discharge
those premises. R=0 is the separate generated-command condition above.

## Remaining boundaries

The same name domains can inform a safe-printer account, but ordinary histogram
string-map collapse does not bound its positive-vector-bucket multiplicity.
The accepted INT64_MIN-negation, nonfinite/out-of-range double conversion,
registry validity under signals and terminal-entry conditions remain. Neither
this table nor a finite unsigned name range establishes signal safety, arithmetic
validity, allocation success, solver completion or automatic proof discharge.

Even a fully instantiated Q_stats is one output family. Warnings, exception
messages, failed prefixes, terminal/runtime diagnostics, dump multiplicities and
remaining direct output still need the selected source/configuration join before
exporting q_cvc5. Embedded revision consistency is not executable attestation or
behavioral correspondence. Global Why3 suffix allowances remain two save-entering
callbacks, three saves and e<=2, never renewed per registry or dump. Oracle,
tools, pins, native commands and admission are unchanged; #119/#153 remain
incomplete and PR #121 remains draft. The lead owns integration and review.

Selected author setting: GPT-6 Astra / Extra High; runtime model/effort and
token/cost measurements are unavailable. Actual elapsed time and the focused
checker result are in `round.json` and `check-result.json` in the packet. No
independent review is claimed here.
