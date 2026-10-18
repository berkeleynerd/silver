# Review: original Standard.String helper storage

2026-10-18, authorized research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accepted for the stated local interval; no material findings.** The two
`self_referential_size` constructors are bounded by 94 direct GGC requests,
6,832 + 2P caller bytes, 7,912 + 2 rho(P+33) separately rounded slot bytes,
and two ordinary requests totaling 80 caller bytes, under the packet's
explicit source/behavior, configuration, incoming-state and shape premises.
This is a source review of an allocation-request envelope, not a native
measurement or a machine-checked C++ semantics proof.

## Frozen inputs and review scope

Reviewed implementation/evidence commit:
`db777735c45ccf7a070a1d7eeae5a1afdd4dc8fc`.
The exact new inputs are the
[source argument](../research/retained-literal-original-string-storage.md)
and the complete
[evidence packet](../evidence/retained-literal-original-string-storage-20261018/README.md):
`derive.py`, `interface.json`, `fold-audit.json`, `source-manifest.json`,
`check.py`, `check-results.json` and its README.
The historical join is
`316f40e7b2c0b7ffc57eca81c7aff39784cdd35a`, including the corrected
173-event [synthetic interval](../research/retained-literal-synthetic-function-storage.md).
The GCC source revision is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

The review used an isolated worktree created directly from the frozen target.
It read the applicable AGENTS, Oracle, development/review requirements,
2026-10-18/17 authorization entries and
[capacity contract](../research/retained-tool-capacity.md#inputs-and-required-conclusion).
It changed only this report. The selected reviewer setting was GPT-6 Astra /
Extra High; the runtime model and effort are not independently confirmed.
The reviewer-local live goal query returned no goal; the lead retains the
owner's #119 objective and its status.

## Source checks supporting acceptance

The review challenged the allocation-producing paths, including allocations
that would be discarded, rather than accepting the final expression size as
the request count.

- **Original shape and private copying.** The retained layout constructs
  `1+(H-L)`, with `H = Q ? U : L-1`; distribution and constant normalization
  give the stated conditional extent. The constructor starts after that
  folding. Its walker stops at the outer self-referential COMPONENT_REF and
  at types, declarations and constants. With a null visited-set argument it
  copies expression occurrences, without hash backing. The two shapes have
  5 unary, 7 binary and 2 ternary occurrences in total: 14 requests and
  536 bytes. `find_placeholder_in_expr` retains exactly the two distinct
  outer bound fields, so the constructor loop performs two substitutions
  per helper. The nonmatching reference chain returns unchanged.
- **All four substitutions and recursive folding.** Each changed ancestor
  goes through `fold_build1/2/3`. The bound charges all ancestors in both
  passes, including unchanged ones, then adds four possible reassociation
  binaries and four possible inversion binaries. Commutative/comparison
  reversal recurses before constructing its result; it does not allocate a
  discarded outer candidate. For `(U-L)+1`, `split_tree` keeps the two-variable
  subtraction intact, so the association gate sees only two pieces. For
  `(U+1)-L` and `U+(1-L)`, the only nontrivial reconstructions are U-L and
  the final plus-one; null-part combinations reuse their input. The origin
  test succeeds, and the final association uses the plain builder because
  an operand is already PLUS/MINUS. These paths preserve the finite family.
  Commuting a plus, reversing the comparison and swapping conditional arms
  do not require additional expression occurrences. The excluded
  `U-(L-1)` form must remain excluded from this interface.
- **Matcher candidates and predicate work.** Reviewed the arithmetic
  identity, negation, repeated-capture, two-constant, conversion, comparison
  and conditional groups against `match.pd` and the generated-code scheme
  in `genmatch.cc`. At every partial substitution stage the bound/parameter
  leaves remain distinct. There is only one extent constant, no inner
  product, and no SSA, address, Boolean-valued extent, nested conditional,
  bitwise, floating or vector operand. The widening rule's precision test
  fails at 64 versus 32; the outer u128 conversion fails the arithmetic
  narrowing/type-compatibility guards before `unsigned_type_for`. Eight
  fails the Boolean-product predicate. The zero/one predicate's scalar
  bit analysis stays in fixed-width inline wide integers. The selected
  rules fail before replacement construction, recursive replacement folds
  or capture unsharing. GIMPLE-only transformations do not apply here.
- **Legacy widening, multiplication and conditional paths.** The widening
  operands are leaves or u64 arithmetic, so the conditional/compound,
  comparison, nested-conversion and narrowing-multiply paths are absent.
  In the multiplication path, `extract_muldiv_1` rejects widening wrapping
  u64 arithmetic to u128 before converting the constant or recursing.
  A conditional arm swap produces one plain inverted comparison and then
  one ternary; it cannot swap back. Integer truth inversion adds no unary
  root or scalar constant. Each rebuilt comparison has UNKNOWN_LOCATION,
  so copying warning state to its reserved destination creates no map entry.
  Thus the four traversals fit **10 unary + 22 binary + 4 ternary = 36
  requests / 1,392 bytes**, with no additional fold-created constant, type,
  declaration, call or ordinary allocation.
- **Constructor shell and shared caches.** The source explicitly supplies
  four parameters, two results, two function declarations, six lists, two
  blocks and the two MODIFY/RETURN pairs. Positive and the size/void types
  are self-canonical on this path; function-type canonicalization and
  pointer construction do not recurse. Candidate type requests remain
  charged even on a cache hit. Function/pointer layout uses aligned scalar
  sizes and existing size-type cache vectors; ten scalar lookups need at
  most three new INTEGER_CSTs. The returned call adds one address and one
  five-operand CALL_EXPR per helper. The fresh declaration is not builtin,
  and call flag processing does not construct objects or query the return
  ABI. The vectors fit the stated initial capacities. Identifier/type-hash
  backing remains a shared demand, not a pair of private table allocations.

Relevant direct source reads include `stor-layout.cc:109–265`,
`tree.cc:4490–4750,7198–7264,7671–7788,11020–11151,11719–11990`,
`fold-const.cc:488–638,901–1063,6647–6675,9204–9525,9774–10406,
11000–11140,11441–11848,12899–13240,13886–14085`, and the matcher groups
recorded in the packet. `tree-inline.cc:5735–5788`'s `copy_tree_r` was also
checked against the retained
[backend-capacity source manifest](../evidence/retained-backend-capacity-20261018/source-manifest.json);
its SHA-256 is
`fd7e55d826abce9e7e8ffd47a52fd11befec98346c9a73982620d322e232f903`.

## Names, arithmetic and composition

`get_file_function_name` contributes `_GLOBAL__`, SZ plus at most 20 decimal
digits, one separator and NUL, giving the local helper-string ceiling P+33.
The fallback filename suffix occupies at most 28 characters before NUL.
Consequently the required local condition **P >= max(G,F+28)** is sound;
cleaning does not lengthen the component. P is this component bound, not
automatically a similarly named aggregate input-path bound. An aggregate
consumer must derive it explicitly. The local upper guard keeps identifier
length arithmetic finite, and the fnno/DECL/type UID guards conservatively
cover the stated increments without taking refunds.

Independent arithmetic recomputed the request rows, the 1,392-byte fold
subtotal, the 80 ordinary bytes, the 33-byte helper-name overhead and each
individual power-of-two rounding. The results agree with the frozen
interface. Freed candidates are not subtracted. The 58 shell requests plus
36 substitution requests give 94; the rounded sum is not obtained by
rounding the aggregate caller-byte sum.

This interval owns the original helper declarations, types, bodies, names,
private/substitution copies, vectors and returned calls. The corrected
synthetic interval begins with those objects already present and owns later
function structures and initial gimplification. Their allocation rows are
disjoint. The two helper-name increments and helper count are the same
identities already described by the String-layout packet, not new increments
to add a second time. Cgraph registration remains separately owned. Shared
identifier/type-hash backing must consume the exported demands once.

## Evidence and limits

The retained successful worker check is reused: 36 offline checks, 27 source
pins, 13 historical inputs and 192 shape-arity fixtures, PASS at
2026-10-18 21:18:46 UTC in 0.108 seconds. It was not rerun. The reviewer
separately verified that the external files actually read still match all
27 manifest byte counts/SHA-256/Git blob IDs, that the 13 historical inputs
match their frozen hashes, and that the supplemental `tree-inline.cc` source
matches its retained hash. A separate small arithmetic check passed. These
checks establish input identity and arithmetic; the fixtures and landmark
searches do not prove matcher/control-flow closure. That closure was reviewed
as the source case argument above.

No compiler capture, GCC build, Silver build, GNATprove run, Lean run, full
suite, macOS run or CI result is claimed. The broader original Standard.String
conversion, Main construction, original empty-elaboration construction,
shared backing, collector/page composition and complete literal/full-grammar
conjunction remain open. Stack and system-library implementation costs are
outside this request interval. Installed/source relevant-behavior and the
historical SPARK source-identity limitation remain unchanged. Acceptance of
this leaf does not close #119 or authorize a larger admitted language.

Report checks passed: all five local links resolve, with no trailing
whitespace and a final newline. Review ran from 2026-10-18 21:20:17 UTC to
21:25:21 UTC, approximately 5 minutes 4 seconds including source inspection,
offline checks and reporting. Token/cost and runtime-setting measurements
are unavailable. Native
validation runs: zero. Oracle, admission, tool pins, production code,
proof-provenance inputs, GitHub and CLI memory were unchanged.
