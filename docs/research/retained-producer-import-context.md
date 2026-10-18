# Fixed producer startup imports and clone warnings

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The fixed library producer starts with **all nine configured drivers**, even
when only CVC5, Z3 and Alt-Ergo execute. Their complete explicit import closure
has 26 driver files and 21 library files. This closes the file-selection and
clone-warning components below; typed formula/allocation bounds remain open.
No compiler, Why3, solver or Lean process ran.

The [archive and checker](../evidence/retained-producer-import-context-20261018/README.md)
retain the installed bytes and the same candidate source revisions as the
[response analysis](retained-producer-response.md). This is source analysis,
not a historical installed-binary/source identity claim or admission change.

## What is loaded

GNATprove's configuration writer iterates every entry in the installed
`gnatprove.conf` prover array (`gnatprove.adb:1253–1273`). Why3 selects the
execution list separately and keeps the complete configuration map
(`gnat_config.ml:343–410`). `Controller_itp.load_drivers` loads that entire map
(`controller_itp.ml:114–124`), and each driver's `theory`/`use` rule immediately
reads its referenced theory (`driver.ml:233–248`). Selecting three provers
therefore does not reduce startup to their driver files.

Each imported `.mlw`/`.why` file is parsed and typed through its final EOF,
including modules not used by the selected task (`lexer.mll:257–279`,
`parser.mly:62–100`). GNAT JSON separately uses the whole-file Ptree typing
entry. `Pmodule.read_module` selects one module only after the file map exists
(`pmodule.ml:1699–1702`). `Env.read_library` memoizes a complete file by path
and environment (`env.ml:191–218`). Registering the WhyML language pushes
each result into both its own cache and the parent theory cache (`:80–117`,
`pmodule.ml:1661–1671`), so a driver theory read followed by a program-module
read does not type the same file a second time.

Under the pinned loadpath/configuration, this gives:

| Source input domain, per backend process | Bound/count |
| --- | ---: |
| Configured root drivers | 9 |
| Driver/import files and raw bytes | 26; 66,992 bytes |
| WhyML/Why library files and raw bytes | 21; 419,906 bytes |
| Modules/theories in those files | 352 |
| Explicit use/clone directives | 728 |
| Explicit clone directives | 205 |
| Largest library file | 104,227 bytes |
| Largest library line | 5,148 bytes |
| Most lines in one library file | 3,021 |

The files are `_gnatprove_standard`, `_gnatprove_standard_th`, `ada__model`,
`ada__model_th`, `algebra`, `bool`, `bv`, `floating_point`, `for_drivers`,
`ieee_float`, `int`, `list`, `mach.int`, `map`, `number`, `option`, `real`,
`ref`, `relations`, `set`, and `string`. The explicit builtin references are
also recorded. Implicit builtin tuple/reference/type construction keeps its
own typed-cost term; it does not read another source file.

All five retained native files refer externally only to `int`,
`_gnatprove_standard` and `ada__model`; their direct clone counts are
8, 7, 10, 13 and 13. The smaller **11-file native-input closure** is a proper
subset of the 21-file startup closure. It cannot serve as the complete fixed
startup charge. These source sizes bound individual input lexical/location
domains, not allocated typed term counts or an aggregate RAM admission limit.
The largest line is below the 64-bit Why3 location encoding's 65,535 column
limit; its line count is below the corresponding 47-bit line domain
(`loc.ml:27–40`). Native synthetic positions have their separate bound.

This closure covers the configured driver and native explicit imports. A
runtime transformation that reads a theory by a hardcoded name still needs
its source dependency joined; it is not automatically covered by scanning
imports. Effective environment/loadpath selection remains part of the
invocation premise, as in the response and native-environment records.

## Six additional startup VC constructions

Imported program declarations use `vc=false` because their module path is
nonempty (`typing.ml:1676–1705`). Type declarations nevertheless call
`add_pdecl ~vc:true` (`:1471`). The 21-file frontier contains three type
invariants that reach that branch:

- `set.SetAppInt.Iter.t` and `set.SetAppString.Iter.t` each provide the fixed
  two-field witness made with `empty ()` (`set.mlw:623–631,667–675`).
- `string.Char.char` has the invariant `length contents = 1` and no witness
  (`string.mlw:395–399`).

`Vc.vc` creates one formula for each witness or nonempty invariant and none
for a type with neither (`vc.ml:1740–1784`). No module introducing these
three invariant types is itself cloned. The two `map.MapPermutation` invariant tokens
are loop invariants in an imported program body, whose ordinary program VC
generation is disabled; they do not introduce two more type VCs.

There is another path independent of the import's `vc` flag:
`clone_pdecl` builds a refinement function and calls `mk_vc` for a substituted
program `val` (`pmodule.ml:1382–1455`). The exact file closure has three such
substitutions, all `val eq = ...` in `set.mlw:607,663,781`. Each constructs
one nonrecursive function and therefore one VC formula. Native GNAT JSON
clones support only type/function/predicate substitutions, so they do not
add a program-value refinement (`gnat_ast_to_ptree.ml:1241–1282`, retained
in the earlier fixed-check source archive).

These **six startup formula constructions** belong to the producer's
allocation/lifetime account. Their size and the typed declarations around
them still need bounds. They are imported library declarations, not extra
registered `GP_Check` leaves in the five supplied native theories; the
[fixed-body G/R account](retained-producer-fixed-paths.md) counts those
registered response leaves separately. No obligation is suppressed here.

## Clones give a concrete warning bound

`Typing.add_decl` calls `warn_clone_not_abstract` at most once per parsed
clone (`typing.ml:1717,1732`). The helper emits at most one warning
(`theory.ml:880–895`). A cloned module's existing `Uclone` records become
metadata via `add_clone`; they do not call the parser's warning helper again
(`pmodule.ml:1590–1622`). Cache sharing above therefore bounds the library
part by 205 warning calls, independent of task size or solver output.

For the five native processes, respectively:

```text
W_clone <= 213, 212, 215, 218, 218
sum W_clone <= 1076.
```

Let P bound bytes in any source filename used by a warning location.
The displayed target theory names have at most 42 bytes. The fixed warning
text, four signed63 coordinate fields and location punctuation fit together
with the target name in 256 bytes. Thus:

```text
L_clone <= (P + 256) W_clone.
```

P remains the invocation's path-domain term, not an assumed new source cap.
This is a conservative bound even when every clone is wrongly pessimistically
charged a warning. The imported files have no `use import`/`clone import`
syntax, so their parser's redundant-import warning is absent. The native
converter builds Ptree include/clone declarations directly, bypassing that
parser warning. Other typing, session and preparation warnings remain
explicit; this record does not set them to zero.

Writing `W_rest,L_rest` for the other warning terms, substitute into the
[diagnostic-string transfer](retained-producer-diagnostic-strings.md):

```text
sum B_raw       <= 40,395,307 + 6456P + 3111O
                   + 3 sum W_rest + 6 sum L_rest
sum B_projected <= 37,100,662 + 6456P + 3087O
                   + 3 sum W_rest + 6 sum L_rest.
```

O still counts captured solver-output bytes across the five processes. The
second formula still requires the proposed verified response projection.

## What the clone recurrence supplies

The checker computes a source dependency vector for every module:
`C(m) = unit(m) + sum C(t)` over its direct clone targets. Uses remain
references. Summing over the 352 original modules gives maximum coefficient
68 (for `relations.EndoRelation`), 183,140 clone-weighted lexical pieces and
961,599 clone-weighted raw source bytes. These are reproducible source
multiplicities, **not typed-node or allocation bounds**. Why3 additionally
creates callable lemmas, type projections/axioms, contract formulas, builtin
imports and refinement VCs. Merely replacing each lexical piece by one typed
node would omit that work.

`Theory.clone_theory` and `Pmodule.clone_export'` visit existing declaration
lists once; their Use/Uuse branches retain references and merge environments
(`theory.ml:868–912`, `pmodule.ml:1590–1634`). The next quantitative join can
therefore use the concrete source dependency coefficients and per-declaration
constructor costs. It must also pay for namespace/known-map operations and
temporary creation counters, with per-object/index/counter constraints
separate from general memory estimates.

The offline source/closure/arithmetic checks pass. Full typed context/formula,
solver output/internal representation, lifetime-counter and final native
report bounds remain open. #119 is not complete.
