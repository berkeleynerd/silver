# Qualified path payloads: useful source bounds and remaining joins

2026-10-20 UTC, owner-resumed #119 / #153 Round 31, integration base
`87874f41b44f7abb2d3c4848405b3474a09f51b4`. This is an offline source result for
the five retained Linux x86_64 processes. It continues the accepted
[restored-path frontier](retained-why-restored-path-continuation.md), without
replaying native, compiler, solver, proof or capture work.

The tuple route contributes at most **25 bytes in one qualified component**.
The retained encoding flag helpers contribute **no path registrations**.
For the fixed int/real library closure, the source-origin lemma below gives the
deliberately loose bound **116,162 bytes per qualified path**. These results do
not assume that newly registered identifiers have different numeric tags from
the serialized identifiers.

The library lemma is not yet an unconditional bound for every path selectable
by `save_ident` in those processes. Its module-origin premise, other selected
callers, and the initial suspended-resize question remain explicit below. The
packet therefore retains actual whole-process `R` and `U` as **unknown**.
The old small U candidates 4,275 / 3,571 / 2,317 / 419 / 384 remain conditional.

The useful headroom question is now quantitative: a uniform bound
`R <= 2,162,382` on every selectable qualified path is sufficient for all five
cases' existing Format sentinel arithmetic. The library lemma is comfortably
inside this ceiling; the former native-string bound was not.

## A bound that allows aliases and table mutation

Only the third component of `Theory.restore_path` is printed
(`session_itp.ml:2099–2107`). `store_theory` installs `[]`, which selects the
serialized identifier's own fallback. `store_path` installs
`List.rev (id.id_string :: path @ uc.uc_prefix)` (`theory.ml:472–492`).

For a finite component list `p`, define

```
J(p) = sum(byte_length(s) for s in p) + max(length(p)-1, 0).
```

The sufficient invariant is a bound on **payload values**, not map preservation:
every nonempty path value initially selectable for a serialized tag, and every
later value that can become selectable for that tag, has `J(p) <= R`.
It permits collection, loss to fallback, replacement, repeated parsing and
tag aliases. Resizing copies existing cells; replacement can expose absence or
an installed value. Under the existing valid-value/runtime behavior relation,
these operations cannot invent a new component string. Old arrays retained by
an active resize must be included; an array left unreachable by an unwound
resize cannot later reappear merely because its bytes remain in the heap.

For each case let N be serialized identifier occurrences, C the other raw
string bytes, and F the maximum immutable identifier fallback length. Then

```
U <= C + N * max(F, R).
```

This slightly enlarges some captured sums on purpose. It avoids proving that
the first observed binding remains the selected one. The accepted occurrence
and forest/attempt-growth premises still apply, and the whole post-cut budget
still allows at most three saves; it is not restarted at ordinary-save entry.

## Tuple theories: 25 bytes without freshness

`Theory.tuple_theory` (`theory.ml:1047–1055`) starts with `empty_theory`, whose
`uc_prefix=[]` (`:307–321`), then adds exactly the type `ts_tuple n` and its
constructor `fs_tuple n`, with no projections. Their names are respectively
`"tuple" ^ string_of_int n` and `"Tuple" ^ string_of_int n`
(`ty.ml:278–286`, `term.ml:1037–1048`). `add_data_decl` reaches `store_path`
through `add_symbol` with `path=[]`. No namespace is opened in this route.

On the retained 63-bit integer representation, `-2^62 <= n <= 2^62-1`.
`string_of_int` uses `format_int "%d"`; the signed decimal output has at most
19 digits and one sign (`stdlib.ml:267–268`, `ints.c:119–185`). Thus each
installed component is at most `5+20=25` bytes. The negative case is included;
the proof does not require a successful source `List.length` result to be
nonnegative. Tuple arity traversal/allocation remains a separate resource issue.

The memo tables retain only results of these constructor closures. A lost entry
can rerun the same constructor. Type and logic symbol constructors retain their
supplied name; declaration hash-consing's data equality compares physical type
and logic symbols (`decl.ml:340–370`), so a numeric tag collision does not
substitute an unrelated declaration name. Alias-driven validation failure can
prevent a registration; a reached registration still has the bounded name.
This argument bounds the supplied payload regardless of which captured tag it
can overwrite. It is not a tag-disjointness theorem.

## Encoding dispatch: no path writer in the retained helper family

The full retained ML/interface reference census for `ft_select_kept`,
`ft_enco_kept` and `ft_enco_poly` resolves the following source registrations.
`Trans.on_flag_find` selects a stored helper or raises `UnknownFlagTrans`; it
does not load a helper named by the flag (`trans.ml:521–545`). All registered
choices are included, rather than assuming that default flags remain selected.

| Table/choices | Source effect relevant to paths |
| --- | --- |
| `ft_select_kept`: none, goal, local, all | `encoding_select.ml:21–74` traverses types/terms and returns a type set. The wrapper creates metas and uses `Trans.add_tdecls`. |
| `ft_enco_kept`: twin | `encoding_twin.ml:18–118` constructs conversion symbols/axioms and returns declarations to `Trans.decl`. |
| `ft_enco_poly`: guards, tags | The two helpers create symbols/declarations, call the query helpers `Eliminate_algebraic.get_material_args` / `is_infinite_ty`, and compose with `Libencoding.monomorphise_task`. Those algebraic query helpers do not call tuple construction. |
| `ft_enco_poly`: guards_full, tags_full | These construct declarations and use `Trans.decl` / `Task.add_decl`. `encoding_guards_full.empty_th` is a task: its unqualified `use_export` resolves to `Task.use_export`. |
| Shared `Libencoding` and the outer encoder | Symbol creation, term rewriting, meta construction, and task reconstruction. Names such as `const_…`, `…_sort`, `…'def` and `select_…` are not passed to a Theory declaration insertion. |

This is an effect argument over the helper bodies and their explicit callbacks,
not an inference from a missing `create_theory` token. `Trans.decl` and `goal`
select `Task.add_decl`; `add_tdecls` selects task insertion
(`trans.ml:119–138,199–226`). Task insertion and export do not register Theory
paths (`task.ml:148–200`). The called core symbol/term/declaration constructors
do not take a theory-under-construction value. `Printer.unsupportedDecl` raises
an exception (`printer.ml:595–609`). Debug printing and the already classified
native/pending/error effects retain their separate contracts.

The tables are exported, so this source result is conditional on the retained
fixed-loading/client relation. The archive census is not a proof against an
unclassified plugin, arbitrary reflection or a foreign table setter. Within
that relation, table loss or aliases in private memo tables select a value or
callback from the same no-path-writer family, or an error. This source argument
adds no claim about whole encoding allocation, termination or identifier counts.

## Fixed-library source-origin lemma

The companion [input inventory](retained-why-path-input-inventory.md) retains
the exact installed int.mlw, real.mlw, algebra.mlw and relations.mlw bytes
(inventory author commit `d35f7809e5366bbdb4012315de00d7089130233b`):
18,687 + 11,048 + 4,910 + 4,033 = **S = 38,678 bytes**. Whole-file parsing matters:
requesting `int.Int` does not restrict the parser to that one module. The files
contain 69 module heads and 102 use/clone declarations. Their dependency graph
is acyclic; same-file dependencies reference earlier modules. The only external
target is the source-built `why3.WellFounded.WellFounded` module.

Let `G_library` require the following concrete input/selection conditions:

- The parser/typing callbacks are the retained WhyML implementations, and a
  file read consumes exactly the named four files under their nonempty library
  paths; builtin reads select the displayed retained constructors.
- Each module lookup, including a memo hit, returns the module produced by the
  **corresponding named definition** and its declared dependencies in this DAG.
  Repeated parses may supply different physical copies. Merely belonging to
  the same set of module names is insufficient if an alias redirects an edge.
- Parser/clone symbol maps contain the participating modules' source-derived
  symbols, substitutions and locally constructed symbols. A cache hit does
  not import an unrelated symbol or namespace origin from another client.

The source graph and byte inventory check which definitions these conditions
name; they do not prove stopped memo contents or preservation by every later
client. The body argument below establishes bounded name lineage for those
inputs, rather than assuming a numerical output bound. Under these conditions
and the existing valid-value/source behavior relation, every Theory path payload
installed by this parse has

```
J(p) <= R_library = 3*S + 128 = 116,162.
```

The source argument has four parts:

1. **Names retain a lexical stem.** `Typing.create_user_id` preserves the parsed
   identifier string (`typing.ml:185–198`). Operator encoding prepends at most
   11 bytes (`ident.ml:76–90`). Type, logic, constructor, projection and
   inductive-case names are these stems or copies. `id_clone` / `id_attr`
   preserve `id_string`; they do not append numeric uniqueness suffixes.
   `Expr.create_rsymbol` retains the supplied name for the logical symbol or
   routine (`expr.ml:115–153`). Local variables named from expressions are not
   top-level Theory declaration names.
2. **Pure-declaration generation adds bounded suffixes.** `Pdecl.create_let_decl`
   derives `…'spec`, `…'def`, or a lemma routine's original name; `post_axioms`
   may additionally append one apostrophe and a native decimal counter
   (`pdecl.ml:530–638`). The counter can be signed/wrapped; its formatted value
   is still at most 20 bytes. `Typing.create_val` can add `…'lemma`
   (`typing.ml:1566–1581`). Type-derived names use the fixed suffixes displayed
   at `pdecl.ml:378–507`, the longest being `…'invariant`. A conservative **64
   bytes beyond the lexical stem** covers operator encoding and these
   compositions. Repeated cloning does not repeatedly suffix the generated
   proposition: `clone_decl` copies a `PDpure` name, while `clone_let_defn`
   copies the original routine name and `create_let_decl` regenerates its pure
   declarations (`pmodule.ml:730–834,1051–1082,1445–1467`). Thus a registered
   symbol name is at most `S+64`, independently of the number of parses/clones.
3. **The selected program paths do not introduce another name generator.** The
   actual files include `val`, `let`, recursive functions and lemmas; they are
   not treated as pure theories. Their nonempty library `uc_path` makes the
   ordinary `Dlet`/`Drec` `vc` flag false (`typing.ml:1675–1708`). `add_types`
   does use `vc:true` (`:1469–1473`), but the retained type declarations have no
   witness/invariant: `Vc.vc`'s `(None,[])` branch returns no VC declarations
   (`vc.ml:1740–end`). Clone substitutions contain no `val` or `exception`
   substitution, so the `mi_rs`-dependent refinement/`mk_vc` branch is not
   selected. `constant` is a logical `CSfsym`, not `CSvsym`
   (`parser_common.mly:403–418`, `typing.ml:1593–1654`). There are no module
   interfaces; the interface implementation-copy route is excluded by the
   plain module heads, not by searching for an `interface` keyword.
4. **Namespace construction has a bounded origin trace.** There are no explicit
   scopes or nested modules. The parser's use/clone import wrappers supply
   lexical namespace names (`typing.ml:1720–1745`). `Pmodule.clone_export'`
   traverses the source module's `Uscope` nodes; `Uuse` merges a module and
   `Uclone` adds clone metadata (`pmodule.ml:1591–1635`). Following any one
   component path follows an acyclic module dependency ancestry. It cannot
   revisit a source scope occurrence; merging branches selects a component
   path, rather than concatenating the two ancestry paths. Thus the sum of
   namespace label bytes is at most S, and their count, hence inserted dots,
   is at most S. The temporary `"dummy"` scopes used for expression/type/pattern
   lookup are local query contexts, not contexts passed to top-level
   declaration insertion. The source-built WellFounded names and the tuple
   names are covered by the 128-byte slack.

These estimates yield `(S+64)+S+S <= 3*S+128`. They intentionally avoid turning
the inventory's maximum identifier token into a semantic maximum. Numeric tag
aliases in local symbol maps can select another participating symbol; the name
bound is uniform over that set. A lookup that imports a foreign module/value
origin or redirects the named dependency graph is outside `G_library`; it must
not be dismissed as harmless freshness.
This lemma does not establish that all later selected `store_path` calls come
from this parser family.

## Conditional application and exact remaining guards

With the existing `B=1024*Q+6*U+32*Q*d` and `E=128*Q+U`, the sentinel expression is

```
B+E+79 = 1152*Q + 32*Q*d + 7*U + 79.
```

The following rows use the accepted Q and candidate `d=20`. They do not discharge
the other Format premises. The last two columns are conditional on **all**
selectable paths, including initial ones, satisfying `R_library`.

| Case / PID | N | C | F | Largest uniform R passing sentinel | Conditional U at R=116,162 | Conditional B+E+79 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line / 17310 | 66 | 3,668 | 35 | 2,162,382 | 7,670,360 | 54,645,943 |
| Put / 17514 | 55 | 3,068 | 30 | 2,595,247 | 6,391,978 | 45,552,117 |
| First_Or_Default / 17631 | 34 | 1,983 | 50 | 4,199,400 | 3,951,491 | 28,189,156 |
| Is_Message / 17704 | 5 | 345 | 44 | 28,569,053 | 581,155 | 4,148,804 |
| Input_Is_Valid / 17869 | 6 | 298 | 48 | 23,807,381 | 697,270 | 4,968,777 |

Three joins remain before these conditional U values become actual inputs:

- **Initial selectable values.** The companion inventory bounds every matching
  cached-hash row in the current table, including possible duplicate candidates;
  the full current-row cached hashes are unique. It does not capture old arrays
  or an endpoint backtrace. A sufficient additional guard is no suspended
  `Theory` table resize at the cut; alternatively bound the resumable old
  arrays. A direct proof must cover the resize's tag-only hash/equality calls,
  native/pending callbacks and any other worker through the **pre-cut** interval.
  The [native-effect result](retained-why-native-effect-completeness.md) derives
  initialization selectors, but its complete no-new-Why-root application is
  stated for the first-fold/serial-save interval and its original PID. It is
  not silently extended backwards to these five cuts. Unobserved abandoned
  arrays need not be preserved if source reachability excludes their return.
- **Library origin and selected caller coverage.** Join `G_library` to the
  actual environment/library selection, and classify the remaining selected
  preparation, printer, result/error and callback routes that can call Theory
  declaration insertion or `Theory.clone_export`. This round removes the
  tuple and encoding subquestions. It does not infer complete helper closure
  from the driver directive list or a lexical absence of writers.
- **Native construction and the remaining save contracts.** Bound path-list
  traversal and `String.concat` construction using the actual finite lists,
  not just successfully supplied strings. Once the invariant bounds finite
  paths by R, `length(p)<=R+1` for nonempty p, so component visits and desired
  joined length have useful bounds. Checking source/native construction,
  allocation and formatter contracts remains separate from this arithmetic.

The [packet](../evidence/retained-why-path-payload-bound-20261020/README.md)
checks retained source bytes, the entire encoding registry-reference census,
five exact arithmetic thresholds and their rejecting successors, and explicit
unknown propagation. Semantic source effects and the library-origin induction
require review; the Python checker is not a proof of them. Oracle, language
admission, tool pins and production code are unchanged. Aggregate independent
review and publication are lead-owned; no complete-save or whole-pipeline
capacity claim is made.
