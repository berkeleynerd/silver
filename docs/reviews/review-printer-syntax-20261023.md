# Fixed printer syntax and recursion review, 2026-10-23

**The selected family has at most `2S` SMTv2 term/formula printer entries
per printed formula, and its repeated template arguments cause no binder
openings.** This accepts only the bounded syntax/origin and recursion argument
below, not a complete printer-demand packet or whole #119 capacity result.
Research #119 / #153; reviewed integration input
`8ab048af2bcb654ee2ead354d8737c7279b76856`, including accepted R61 author freeze
`366beba68251ece3483193f8104c39391f8c46ef`. Selected reviewer: GPT-6 Astra /
Extra High; runtime confirmation and token/cost telemetry are unavailable.
Exact inputs, source sections and elapsed observations are in the
[new evidence packet](../evidence/retained-printer-syntax-review-20261023/).
Frozen R60/R61 review files are unchanged.

The statement retains R61's fixed-input/source-origin, valid representation,
typed ownership, freshness and guarded-mutation premises. S is **exposed**
formula mass, including triggers; P bounds its source slots. It is not a bound
obtained from a stored skeleton while ignoring saved images. The accepted
[debug control](../research/retained-why-debug-formatter-control.md) excludes
the extra `Pretty.print_term` branch at `smtv2.ml:228–235`. The accepted
[counterexample-meta result](../research/retained-why-model-meta-control.md)
supplies `info_cntexample = false`, beyond merely observing a CE-off option.

## Templates really can duplicate recursive calls

`Printer.global_substitute_fmt` invokes the replacement once per placeholder
occurrence (`core/printer.ml:196–208`). `gen_syntax_arguments_prec` invokes its
callback at every replacement, and an untyped `%i` calls `print_arg` on that
argument (`:299–343`). `Smtv2.print_term` and `print_fmla` pass `print_term` as
this callback (`printer/smtv2.ml:415–417,491–493`). There is no rendered-argument
cache. Arbitrarily nested duplicate templates could therefore give exponential
recursive printing, even when the input semantic tree is small.

The complete fourteen-driver closure contains 319 active type/logic syntax
directives. Of these, 23 repeat a term argument: the BV rotations, floating
predicates, `real.Abs.abs`, and `real.Truncate.truncate`. The last two repeat
argument 1 three times (`smt-libv2.gen:86–110`); BV rotations repeat both
arguments twice (`smt-libv2-bv.gen:183–184` for BV64). Thus the desired bound
does **not** follow from the driver closure alone.

All active type templates use each type argument at most once. There is no
active `%tN` or `%vN` logic placeholder in the fourteen files: the `%t0` const
rule is commented out, and filename `%t` is a different language. The generic
lazy `get_type_arguments` path remains a source branch, but these templates
do not select it. No claim about all printer error paths follows from that
absence.

## Exact non-affine origins

The accepted [R49 module-origin result](../research/retained-cvc5-task-acceptance.md)
provides 47 reachable definitions, with no real.Abs, real.Truncate or
ieee_float module and no BV width other than BV64. Later int.Int/real.Real
literal-helper reads add no syntax meta. Driver update uses the raw Use/Clone
histories and has no forced `use` directive. Consequently the only attachable
non-affine directives are the two BV64 rotations. This is a named-module
argument, not an inference from an unqualified function name.

The new finite census joins each non-affine R54 metadata event through its
recorded `selected_symbols.syntax_logic` pointer/old-pointer connection to the
complete R51 raw/seed/CE stored graph. There are precisely two such heads in
Put_Line and Put, and none in the other three processes:

| Process | `rotate_left_bv` old physical head | `rotate_right_bv` old physical head |
| --- | ---: | ---: |
| Put_Line | 140318021295544 | 140318021324312 |
| Put | 140306342284800 | 140306342313568 |

In both graphs the only application records are 2020 and 2029, in quantifier
roots 2018 and 2027. Bindings 145 and 146 each have two variables, no saved
entries, no triggers and no free variables. Each formula has the shape
`forall v,n. rotate_bv(v,n) = rotate(v,t'int(n))`, with mass nine. The two
duplicated arguments are the enclosing quantified variables. There is no let
ancestor, nested rotation, or binding-bearing argument. The heads are Dparam,
not eligible inline definitions. The census follows every stored edge,
including saved values and triggers, and locates every declaration containing
either application across raw, seed and candidate roots.

R54's complete raw metadata has no syntax or `encoding:lsinst` entries.
The common BV file has the same source loader/clone attachment for Z3 and
CVC5 as R57's common-directive argument; Alt-Ergo does not import that BV file.
Other CVC5-specific directives cannot add another non-affine family. R57/R61
make discrimination and encoding identities, so they cannot introduce an
`encoding:lsinst` remapping to an unrelated head. The printer's
`Discriminate.get_syntax_map` itself only copies a template through existing
meta pairs (`discriminate.ml:489–504`); it does not run `Insts.make`.

The absence of `%vN`/`%tN` is also a preserved **string-origin** invariant,
not merely a property of the fourteen files. Its initial case is the complete
raw-metadata absence checked above. Driver update copies those resolved
driver strings. The accepted R49 selected-writer argument shows that
`Theory.clone_meta`/`cl_marg` preserve MAstr while remapping symbols
(`theory.ml:861–878,999–1015`); encoding meta reconstruction preserves MAstr,
and discrimination copies an existing syntax value. R61 additionally excludes
the encoding/discrimination transformation branches. The other selected
generators do not manufacture syntax strings. Whole old task/meta returns
retain a string from this same value-origin family, rather than obtaining an
arbitrary driver-map entry. Failed prefixes only truncate these writers.
Consequently no printed logic template can force `get_type_arguments`' lazy
value at `printer.ml:330,337–338`. This removes that candidate Hsty diagnostic
path; a zero Hsty claim for the complete printer still belongs to the parent's
separate constructor-site review.

## Preservation to every printing prefix

The two rotation occurrences are confined to the original context axioms.
Neither an initial goal nor a definition body contains them. Optional inline
cannot introduce them into another formula because their Dparam heads have
no definition body to substitute, and no eligible body contains a rotation.
Inside their two axioms there is no let or nonvariable rotation argument for
inline to expand. Their quantified variables can only be renamed.

The accepted [R57 transfer](../research/retained-why-returned-storage.md)
keeps original-context saved images as variable nodes. R61's subsequent
retaining/removal passes, safe maps, literal replacements and epsilon passes
therefore cannot insert a new nonleaf value into these argument positions.
The axioms contain no case, epsilon, literal or let to select an exceptional
rewriter. Formula simplification selects/rewraps their source subtrees; right
splitting retains/recloses quantifiers and does not substitute premise bodies
into value children. Even when the axioms survive CVC5's weaker removal set,
their rotation arguments remain variables.

R61's generated algebraic, range/literal and epsilon formulas have their
separate explicit producers and no rotation head. Introduction operates on
rotation-free goals; nullary substitution does not synthesize that head.
Its outputs do not become later premise candidates. Fresh generated heads
cannot acquire a rotation template under the retained identifier premise.
Thus neither generated premises nor side axioms can create a second origin
for a non-affine application.

Successful public/private old returns select whole objects with their own
source origin and complete field bounds. They cannot merge the old rotation
argument positions with a new candidate's unrelated saved values. This is the
same chronological origin principle used by R61; strict equality alone is
insufficient. Failed prefixes allocate only a prefix of these producers, so
they add neither another template source nor another argument-origin case.
The invariant applies before each reached printer callback and does not assume
that the complete print succeeds.

## Recursion, openings and incremental mode

On the selected non-case forms, each ordinary printer branch visits every
semantic child at most once (`smtv2.ml:359–545`). Quantifier triggers are
included in S and each is printed once (`:645–652`). The retained case family
has two nullary Boolean patterns; the Boolean branch prints its subject and
each branch once (`:585–606`). It selects neither the fresh `subject` nor
`wildcard` path for general data matching.

Every affine template can only retain or omit those child visits. A rotation
adds one extra visit to each of its two variable children, with no recursive
child below either. For a semantic formula of mass m with r rotation
occurrences, term/formula printer entries are at most `m + 2r ≤ 2m ≤ 2S`.
The extra leaf visits register no identifier. This bound counts
`print_term`/`print_fmla` entries; it does not turn hidden-map substitution work,
all Format callbacks, or every helper traversal into a linear cost claim.

An ordinary print opens each source binder once. `fresh_vsymbol` registers
one variable per slot, and `t_open_*` then uses unsafe substitution without
opening the binders it traverses (`term.ml:799–831`). The image/storage
envelope still matters to that internal work, even though dead entries cause
no extra printer recursion or fresh-binder registrations.

Incremental mode may be conservatively treated as either value. The lists
start empty for each `print_task` (`smtv2.ml:1057–1058`). A quantified axiom is
**deferred instead of printed** (`:810–815`); a quantified definition body is
opened once and deferred while its parameter declaration is printed
(`:681–699`). After the unique terminal goal, `print_incremental_axiom`
iterates each deferred list once (`:805–831`). The two `check-sat` commands do
not reprint any formula. The lists are not literally cleared despite the
comment, but there is one goal and the printer state is local to this call.
Thus the complete declaration family is printed once, including deferred
members, rather than twice or once per solver response.

`has_quantification` adds at most one scan per axiom/definition expression
(`:676–679,685,812`). It returns immediately at Tquant/Teps; otherwise
`Term.t_any` uses the safe fold, which can open lets and branches
(`term.ml:1284–1299`). Charge at most S extra scan entries and P extra opened
slots. A conservative per-declaration registration interface is therefore
`2P + A`, with A covering `Decl.open_ls_defn` formals separately
(`decl.ml:60–67`). R61 already includes source formals in P, so this separate
A charge is deliberately loose. Type/free-variable folds are not assigned
this registration effect.

The false counterexample meta also makes `print_info_model` return its empty
map (`smtv2.ml:736–767`) and excludes the model command (`:777–784`). Model
collection during ordinary printing is distinct from replaying a term printer.
The parent component's proposed `8H(S+1)(P+1)` Ident allowance can dominate
these openings and direct field/case constructors with the retained P/A
limits. The parent's remaining wrapper, constructor-site and six-owner
composition argument still requires its own complete review.

The single focused census passed in **2.405027 seconds**, pinning 34 inputs
and five complete source members at Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`. No native target, solver, proof,
capture, transformation, predecessor checker or nested agent ran. No failed
or aborted census preceded this pass. Finite extraction validates the named
origins and templates; the preservation and recursion argument above is
independent source review, not machine-checked OCaml semantics.
