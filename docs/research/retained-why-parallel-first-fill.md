# Parallel first-fill reduced to four formula families

2026-10-20 UTC, Linux x86_64, Round 52; #119 / #153.
The intended parallel stored-representative gap remains open, but its fixed
input obligation is now reduced from 675 context axiom keys to **13 keys in
four formula families**. A live raw declaration protects 660 keys independently
of whether CE has ever completed. Two further keys produce `Ttrue`, whose
strict-equal representations have no hidden term or binder state. This packet
does not claim that Z3's remaining same-key stored forms are bounded.

The new [packet](../evidence/retained-why-parallel-first-fill-20261020/README.md)
pins and reads the exact [R51](retained-why-preinline-prefix.md) exports at
`486754009921aaf6bd6d2ca15bccd92b218e3789`, without replaying that checker or
changing any R51 byte. It adds a sufficient strict-equality test, per-key
certificates, raw prsymbol-name joins, source witnesses and a stage inventory.
The source/runtime and faithful-capture relation remains explicit; the finite
checks are not a machine-checked source theorem.

## What is protected before any successful CE fill

Let d be a raw `Dprop(Paxiom,pr,f)` kept strongly reachable by the immutable
session task, and let c be the source CE candidate for this same declaration.
The retained complete `Decl.Hsdecl` projection supplies the initial table
objects with this physical prsymbol. For every protected row below, the
projection contains **exactly d**, and the new sufficient comparison proves
`t_equal_strict f c`.

| Fixed raw domain | Paxiom keys | Live raw protected | `Ttrue` protected | Remaining keys |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 243 | 241 | 0 | 2 |
| Put | 243 | 241 | 0 | 2 |
| First_Or_Default | 75 | 69 | 2 | 4 |
| Is_Message | 53 | 51 | 0 | 2 |
| Input_Is_Valid | 61 | 58 | 0 | 3 |
| Sum over distinct processes | **675** | **660** | **2** | **13** |

For 659 protected rows, candidate and raw formula are the **same stored
object**. The remaining row is First_Or_Default's rebuilt
`input_is_valid__post_axiom`, which passes the full sufficient strict test.
All 660 protected raw/candidate closures have zero saved-map entries. Their
proof does not infer equality from matching n/b/p/a coordinates.

`Decl.Hsdecl.equal` compares proposition kind and prsymbol before
`t_equal_strict` (`decl.ml:340–419`). While d remains strongly live, an ordinary
weak merge encountering any new strict-equal declaration with that key must
return d. `Weak.merge` has no catch around its equality callback
(`weak.ml:272–294`); an exception aborts the attempt rather than inserting a
second equal representation. Hashcons assigns the candidate tag **before**
the weak merge on every attempt; its tag counter advances only when the
candidate itself is returned (`hashcons.ml:34–55`). Induction over all
successful same-key merges therefore
keeps d as the sole selectable strict-equal representative, regardless of
which prover transforms ran first. Weak collection cannot remove this live
seed under the inherited runtime relation.

This argument uses valid tags/hashes, ordinary table semantics, source
freshness, immutable raw ownership and absence of foreign table corruption.
It is not an assertion that all interruptions are mutation-atomic. In
particular, a false `Not_found` at a transformation memo may recompute a
candidate but does not remove the raw root or turn a failed `Weak.merge`
comparison into a successful insertion. The proof does not wait for a first
successful CE memo fill, so the serial-order restriction is unnecessary for
this subset. It also covers same-key candidates produced and inserted before
a later `Task.add_decl` failure.

The two remaining protected rows are First_Or_Default's
`temp___String_Literal_251__def_axiom` and
`temp___String_Literal_268__def_axiom`. CE maps their quantified true formulas
to a `Ttrue` term. A strict-equal closed root must itself have constructor
`Ttrue`: at the empty frame stack, a variable cannot descend to it. That term
has no children, binder record, triggers or delayed substitution map. Its
stored envelope is exactly one term, with zero binders and saved entries.
Strict metadata checks further restrict attributes/type/location; they
cannot introduce hidden term edges. This conclusion does not require knowing
which earlier transform inserted the representative.

Input_Is_Valid's actual retained cut is already after a successful first CE
prefix. R51's observed seed covers its local continuation. Its three rows here
describe the prospective **before-first-fill** question if this raw domain is
used with parallel scheduling; they do not reopen the observed local seed.

## Exact comparison and its limits

The comparator follows `Term.t_compare` (`term.ml:266–395,535–542`). It checks
type, attributes and location **before** descending a saved substitution,
maps bound variables to paired indices, lets a bound key shadow a saved key,
and interprets a saved image in the remaining outer frames. Triggers and
their grouping are compared. Existing application symbols and types must
have the same physical references; free variables must have the same
reference. Integer constants compare both representation kind and value,
as `Constant.compare_const ~structural:true` does
(`constant.ml:22–31`, `number.ml:21–30`). The decoded proposition routes are
case-free.

Equal type/location pointers are sufficient checks, not a complete decision
procedure for separately allocated but structurally equal locations. Attribute
name sets rely on the inherited valid attribute-interning relation. Thus a
positive result supplies the required source equality; this packet makes no
claim that every rejection distinguishes source terms. In fact all rejected
raw/CE pairs also have different opened constructor/binder coordinates.

Each certificate retains the physical declaration/prsymbol, raw and candidate
root indices, metadata, stored and opened dimensions, comparison events, and
every initial same-key table row. The input graph retains full binder/maps and
symbols for independent inspection. All protected comparisons follow zero
saved-value edges; this is reported rather than presented as empirical
coverage of arbitrary delayed frames.

Controls reject changes to attributes, type/location references, trigger
lists and integer-literal kind. A separate synthetic representation adds
three unused saved keys to a candidate binder: strict comparison still
succeeds, while the stored-entry count increases by three. The graph supplies
the added variable records and compatible types. This is a demonstration of
what equality alone fails to bound, **not a reachable Z3 execution** or a
counterexample to the inherited runtime/source invariant.

## The four remaining formula families

| Family | Appears in | Raw n / b | CE n / b | Candidate stored terms / binders / saved entries |
| --- | --- | ---: | ---: | ---: |
| `concat_singleton_left_def` | All five domains | 72 / 8 | 72 / 7 | 78 / 2 / 6 |
| `bool_eq_rev` | All five domains | 53 / 7 | 52 / 7 | 52 / 2 / 0 |
| `argument_count__post_axiom` | First_Or_Default, Input_Is_Valid | 17 / 2 | 16 / 2 | 16 / 2 / 0 |
| `argument__post_axiom` | First_Or_Default | 36 / 3 | 35 / 3 | 35 / 3 / 0 |

The first family prunes one unused quantified variable. The other families
replace a formula conditional with true else-branch by implication; the last
also retains an epsilon in its antecedent. All have zero pattern occurrences.
The concat candidate's largest saved map has six entries. These numbers
describe the **source candidates**, not all representatives a prior Z3
history could leave under the same key.

The precise permitted interleaving remains the one found in R51 review.
For `parallel > 1`, `gnat_checks.ml:1049–1083` queues the selected provers.
`controller_itp.ml:518–540` may catch a CVC5 preparation exception, notify
InternalFailure, and later pop the queued Z3 owner. The parallel callback
does not requeue on that notification. Z3 can run downstream transforms before
Alt-Ergo's first successful CE mapping of a key that CVC5 did not fill. This
does not require classifying that ordinary preparation failure as one of the
two escaping signal-save exceptions.

Before a key's first successful CE fill, partial CVC5/Alt-Ergo CE computations
can insert only their deterministic candidate for that raw key. Their later
transforms cannot run until the complete CE prefix returns. The additional
predecessor transformations that matter are therefore Z3's. Lookup/library
initialization and reused declarations retain R51's separate fresh-head and
initial-table premises. Pending save/report callbacks do not become new
logical transformation owners under the existing ownership relation.

The [stage inventory](../evidence/retained-why-parallel-first-fill-20261020/producer-inventory.json)
is checked against all thirteen directives in both retained Z3 overlays.
`eliminate_builtin`, the removal walk and polymorphism detection do not
reconstruct existing Paxiom formulas. The other relevant stages include
inlining, algebraic/projection rewriting, literal abstraction, both epsilon
passes, formula simplification and the conditional discrimination/encoding
passes. Their existing-key constructors can be called before later validation
fails; completed final Z3 output alone would not cover those insertions.

`simplify_formula` is a concrete reason not to assume Z3 cannot equal CE: its
quantifier and propositional simplifiers can make the same logical pruning
and if-true rewrites (`simplify_formula.ml:15–44`,
`term.ml:1745–1765,1794–1814`). Earlier changes to a symbol do not prove every
later candidate unequal. The actual metadata branch for
`eliminate_algebraic_if_poly`, `discriminate_if_poly` and
`encoding_smt_if_poly` is not derived here; this packet does not silently
choose their identity paths.

Premise introduction also needs an explicit return-key argument. It preserves
the existing context, but may use `introduced_prsymbol` metadata for a new
axiom (`introduction.ml:214–218`), and its **separate** Hsdecl compares
proposition names/attributes/locations and formulas rather than physical
prsymbols (`:24–54,173–185`). Accordingly its generated heads cannot simply
be declared fresh without inspecting that metadata and representative path.
The inventory retains this obligation and does not claim a complete nested
producer/call-graph transfer.

## Next missing lemma and the unaffected direct charge

For each of the thirteen residual physical keys k, let F_k be the exported CE
candidate and let Q_k range over stored formula roots returned by a successful
`Decl.Hsdecl` lookup for `(Paxiom,k,F_k)` before the first successful CE memo
installation. The next lemma must prove one of:

- Every noncandidate same-key Z3 insertion is excluded by strict inequality,
  leaving the existing CE candidate family; or
- All possible strict-equal returns lie in a finite stored family/envelope
  that bounds every binder, unused saved entry/image, relevant attribute/type
  and symbol-sharing dimension needed by the subsequent inline transfer.

Its induction must cover each Z3 stage's actual inputs, returned old
representatives and successful insertion prefixes of failed calls. The
parallel owner theorem limits Z3 preparation entries to at most G, but a
finite call count alone supplies no useful stored-size ceiling. Successful
CE installation can then resume R51's live-result/forced-miss induction;
the missing part is initialization for these residual keys. No new native
capture is required by the present result: the outstanding work is a source
transfer/metadata-and-producer closure, not an absent raw graph.

The next concrete operation is to derive the fixed updated task's
`inline:no`, monomorphic-only and `introduced_prsymbol` decisions, then
carry only these residual keys through the ordered producers. In particular:

| Residual family | Next source lemma |
| --- | --- |
| concat | Bound the stored form produced by `t_quant_simp` pruning and its nested `bv_subst_unsafe` compositions, including any earlier inlining/representative selection. |
| bool equality reversal | Transfer `TermTF.t_map_simp`'s if-true-to-implication rewrite through the two quantifiers while retaining actual attributes and old representative choices. |
| argument count postcondition | Transfer that rewrite beneath its retained let, including `lift_q`'s unconditional let reopening and closing even when no epsilon is present. |
| argument postcondition | Prove epsilon-count exclusion after the guard/epsilon passes together with absence of a matching earlier insertion, or bound those earlier stored candidates explicitly. |

The selected Extra High round has established the finite reduction and
identified these producer paths. It has not simulated or proved the ordered
metadata/stored-form transfer. More effort cannot substitute for that missing
evidence; no runtime setting change or Max escalation is claimed at this
checkpoint. These checked inputs are retained for the continuing work.

R51's local direct Ident charge remains usable separately. CE maps the fixed
raw d; a valid returned representative is strict-equal to its candidate and
has the same opened validator binder charge. Traversing unused substitution
maps itself adds no Ident registrations. Thus local C_g and B_g do not depend
on closing the residual stored envelope.

Under the **additional prospective attachment** that the parallel launch
receives these same raw inputs and each selected `(goal, driver)` owner uses
the same three driver prefixes, the accepted
[parallel owner theorem](retained-solver-launch-profile.md) gives at most one
entry per pair. Its conditional direct component is then
`2*sum C_g + sum B_g`, without a repeated-pair addend:

| Domain | Prospective fixed-input direct prefix allowance |
| --- | ---: |
| Put_Line | 147,526 |
| Put | 119,991 |
| First_Or_Default | 38,233 |
| Is_Message | 2,498 |
| Input_Is_Valid | 949 |
| Sum over separate processes | **309,197** |

This conditional calculation does not prove the intended launch's raw/shared
state attachment or cover an additional warning prover with another driver.
It is not the serial post-cut charge 317,465, and no completed Input call is
subtracted from a prospective fresh run. The global **two callbacks / three
saves / e <= 2 per process** remains shared and unchanged; the calculation
adds no escape allowance. Update, initialization, callbacks, inlining and
later direct charges remain separate. Complete compositional capacity and
Ident no-wrap remain unproved; #119 and production #88–#94 are not completed.
