# R83: accepted native type and Main storage kernels

2026-10-24 UTC, #119/#201/#202/#207. Two bounded kernels and the #207
String-layout correction are independently accepted. **#201 and #202 remain
In progress; #207 is repaired and In review pending delivery.**

| Component | Original author freeze | Original review |
| --- | --- | --- |
| Native type kernel and String-layout repair | `1604467b0f2892d3f92f4f40caaabcc05be52271`, including kernel `36d478da0cb3261920fd595ba4a9bdcde54b0cb5` | `ebeca8fcc8e7e0300620b74a2df2c136632e9ce5` |
| Main stored-term kernel and candidate gate | `3a9be892c22061dddac367eb2d5d636405207525` | `e3604dcd8af17cb03c13b89ddcb1b6c6f93bf48b` |

The [native kernel](../../research/retained-general-native-capacity.md) supplies
natural-layout/padding arguments, direct type and constant constructor counts,
temporary declarations, RM/lang vectors, SAVE and alloca requests, annotation
roots and the constrained two-field descriptor kernel. It leaves symbolic
helper costs, weighted annotations, fixed import states, descriptor caller
joins, executable expression lowering and later compilation phases open.

The [#207 repair](../retained-general-native-capacity-20261024/string-pack-repair.md)
corrects an earlier zero-Uint claim: Standard.String's internal Pack flag can
reach final size rounding. The mandatory current overlay reserves seven Uint
entries and `7*(K+1)` digits per Main entity, with once-only layout, retained
descriptor and transient arithmetic accounting. Historical generator/export
bytes are preserved; current consumers select the repaired export. The
[independent review](../../reviews/review-general-native-capacity-20261024.md)
accepted the correction and bounded kernel. No production overflow or invalid
admitted program was demonstrated.

The [Main kernel](../../research/retained-main-why-storage.md) accounts for
case-free closing/substitution/opening, delayed images and saved-key history,
and the candidate triviality/annotation gate before `mk_vc_decl`. Ordinary term
records are not a native term hashcons pool. Twelve leaf renames can leave
opened size three while stored occurrences grow to fifteen; two discarded
quantified candidates still consume eight Ident increments. The
[review](../../reviews/review-main-why-storage-20261024.md) accepted the exact
freeze without a material finding. Complete source caller counts/domain
attachment, typing/kode/SPWP demand, shared owner entry state, preparation,
printing and failure lifetimes remain #202 duties.

The source-independent entry cut is after controller/driver construction and
before Main JSON parsing. No accepted populated owner vector at that cut was
found. A source initialization ledger or a proved restriction of a matching
cumulative prefix can supply it; subtracting Main from a final heap cannot.
Selected driver configuration is an explicit input to that provider.

The native review reused the historical kernel result and ran one focused
repair check: 16 sources, 29 witnesses, three inputs and 3,600 arithmetic pairs.
Combined audit time was 1.202257 seconds, including a 0.563919-second checker
invocation. The Main review ran one new independent audit: 1,272 assertions,
two archives, 15 sources, 23 spans and 12 providers in 0.895582477 seconds.
Its measured source-review/audit interval was 316 seconds, excluding report and
commit work. [Integration](integration-result.json) reconciled exact freezes,
historical inputs, repaired exports, providers and 94 unchanged native pins in
0.403469 seconds. It did not replay a component checker, native/compiler/prover
run or Lean validation.

Authors and independent reviewers selected GPT-6 Astra / Extra High. Runtime
confirmation and isolated token/cost measurements are unavailable; the lead
setting is not confirmed through this interface. #207 was repaired before its
final audit; the Main unit needed no review repair. These observations do not
establish a causal model-quality comparison.

#206 continues the reported-time representation derivation without a finite
proof timeout. Three independent zero-unit search-start timing patterns per
selected driver are an unadopted candidate. Native reuse/isolation, complete
time origins and additive startup/configuration accounting require acceptance
before that candidate can supply capacity inputs. Whole-rule composition,
correspondence, useful-domain comparison and final review remain #119 duties.
Approximately 85% is still a low-confidence planning estimate, not an ETA.

Oracle, tools/pins, current admission, physical-resource premises and the single
process-wide e<=2/two-callback/three-save allowance remain unchanged. Production
#88–#94 is unstarted. PR #121 stays draft/unmerged; merging is unauthorized.
Owner continuation remains recorded through PR #160 despite the paused harness
display. Original author/reviewer branches accompany publication so exact Git
evidence is retrievable. CLI memory is unavailable.
