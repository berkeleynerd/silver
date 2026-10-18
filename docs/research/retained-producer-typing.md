# Main typing: handler, proxy and contract transfers

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119) research.
These source-reviewed transfers connect generated Ptree shapes to inputs of
the [kode/SP/WP account](retained-producer-kode.md). Four complete Why3 files,
including the previously unarchived `dexpr.ml`, are retained with
[identities](../evidence/retained-producer-typing-20261018/identity.json).
The [checker](../evidence/retained-producer-typing-20261018/check.py) verifies
those bytes and cited branches; it runs no native compiler, prover or Lean.
The broader SPARK source identity is the same archive checked by the kode record.

## Exception elaboration does not introduce a Main Kcase

Ptree shape alone is insufficient. `Dexpr.try_expr` groups exception branches
by exception symbol and has a fallback that creates an ordinary pattern match
(`dexpr.ml:1638–1683`). Multiple handlers for the same exception could reach
that fallback even if each original pattern were simple.

The ordinary Main producer has exactly the required narrower shape. Its
[enclosing wrapper](retained-producer-capacity.md#enclosing-main-theories-and-vc-wrapper)
adds only a singleton return-exception handler; selected public calls have
no exceptional/program-exit contracts, and Main has no source handlers.
`Wrap_Loop` adds two **separate** singleton handlers, one around the loop body
for continue and one around the complete loop for exit
(`gnat2why-expr-loops.adb:2244–2247,2302–2304`). The return wrapper is at
`gnat2why-subprograms.adb:5416–5419`. Unrolling is disabled.

The converter supplies no ordinary branches and an optional single variable
pattern (`gnat_ast_to_ptree.ml:930–940`). With no payload it supplies None;
typing changes that to the unit pattern (`typing.ml:1093–1111`). Dexpr's
singleton variable branch returns `[v],body`; its singleton unit/wildcard
branch for a unit exception returns `[],body`. Neither constructs a nested
ordinary match. `Expr.e_match` retains the empty ordinary-branch list and
does not add one (`expr.ml:1038–1102`). Thus `k_expr`'s handler branch sees
at most one carried variable and its no-ordinary-branches case; it cannot
construct Kcase. This supplies the explicit earlier restriction requested
by the independent SP/WP review. Fixed library bodies are outside this claim.

## Generated abstract functions keep their bodies but return unit

Abstract_expr becomes `Efun []` with body `let _ = converted_expr in ()`
and its explicit postcondition. Typing preserves this zero-argument function;
`Dexpr.lambda` uses its body's actual result type (`:1773–1789`), so the
generated Cfun returns unit. Any_expr becomes a local let whose definition
is a zero-argument Cany and whose body reads its result. It introduces no
additional Cfun body.

These forms still take the internal function and contract paths in the kode
record. However, if a generated unit Cfun reaches `cty_enrich_post`, its
`term_of_expr` path returns unit immediately when its effect is pure
(`expr.ml:584–585`); if impure it returns None. `post_of_expr` also returns
None for a unit result (`:705–710`). It cannot translate the large hidden
body into a second implicit formula. The only successful new equality is
the constant-size result-equals-unit postcondition. This reduction does not
remove the explicit postcondition or the separate `k_fun` check of the body.
Nor does it assume that all internal functions are absent.

## Application proxies preserve child occurrence multiplicity

`Dexpr.try_cexp` collects actual arguments, evaluates each once, and changes
each nontrivial actual into a proxy variable (`:1405–1436`). The final c_app
or c_pur receives program variables, not arbitrary expression trees. The
proxy's let definition retains the argument expression once. A simple
unannotated variable can omit its proxy. The cexp proxy path for an applied
local function binds that function once; it does not inline its body at each
actual parameter.

For an already resolved application with `a` actuals whose typed expression
counts are `e_i`, a conservative retained expression-node bound is

```text
2 + 2*a + sum_i e_i.
```

This pays one Eexec, one optional result ghost wrapper, and a let plus
optional ghost wrapper for every actual. Function-body/let headers, if
present in the callee expression, retain their own separate occurrence count.
The claim is a local application transfer, not a count for resolving arbitrary
overloads or the whole expression tree. `Expr.e_app` and `e_assign` use the
same one-proxy-per-supplied-child pattern (`expr.ml:902–932`).

Some useful direct typed-expression transfers are therefore:

| Already typed children / direct constructor | Retained expression nodes |
| --- | ---: |
| If | `1+e_condition+e_then+e_else` |
| And/or | `2+e_left+e_right` |
| Not | `3+e_child` |
| While | `1+e_test+e_body` |
| One-field assignment, excluding any separately requested ghost wrapper | `3+e_left+e_value` |
| Variable let/sequence | `1+e_definition+e_body` |
| Try with the simple distinct handlers above | `1+e_body+sum e_handler` |

These follow the actual constructors, including the Boolean constants added
by `e_and`, `e_or`, `e_not`. Attributes may rebuild a proxy-let spine but do
not increase its retained shape (`expr.ml:386–395`). Specifications, effects,
types, names and finite creation counters are distinct components.

## Contract instantiation substitutes variables

`Ity.cty_apply` instantiates actuals and old-value names by first mapping formal
variables to program variables, then mapping those values to `t_var` terms
(`ity.ml:1436–1489`, retained by the Main-type archive). Remaining formal
parameters may be fresh program variables. Type substitution changes type
metadata, not the term-node skeleton. Thus each individual instantiated
pre/post/exceptional-post formula has the same occurrence shape as its source
contract, modulo renaming and simplification. Its occurrence charge is paid
per use, and its formal-use multiplicities must be preserved.

This is **not** a claim that an actual expression is free: its proxy definition
is retained once, and the later lexical SP/WP envelope charges reuse at every
formal occurrence. It rules out duplicating the whole argument expression
inside every typed contract before that lexical accounting even starts.

The `term_of_post` split used by Klet also has a direct bound. For input lexical
cost `H>=1`, the returned definition has cost at most `H+3` and its residual
predicate at most `H` (`expr.ml:550–582`). The ordinary path finds a result
equality/Boolean equivalence down a left conjunction spine, returns its RHS
with at most a Boolean conversion, and replaces that conjunct by true in the
residual. The function-type alternative adds an epsilon around its original
universal postcondition; the same `H+3` allowance covers it. No RHS is recursively
unfolded here. Consequently those two Klet inputs can be charged separately
without an arbitrary function of the whole program size.

The remaining quantitative join must count every generated Ptree expression,
the fixed/generated contract bodies it refers to, declaration typing, actual
type-instantiation metadata and finite creation counters. The local transfers
above plus the linear reflow bound and weighted matcher/unfold composition
provide components of that join; they do not yet establish a complete producer
predicate or a whole-tool useful-domain comparison.
