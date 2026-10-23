# Initial and continuing GNAT warning strings

2026-10-23 UTC; owner-authorized #119 / #153. Author source argument, pending
independent review. This supplies numeric **W_o/L_o** for the combined
quiet/timeless/J12/logging, fresh automatic Per_Check route, CE off, one OCaml
worker, and the five fixed inputs. It includes warning strings already stored
at registration. The [packet](../evidence/retained-why-diagnostic-warnings-20261023/README.md)
retains the source witnesses, complete warning-reference census, initial and
later syntax projections, input identities and per-process arithmetic.

The bound is over one process's **whole selected interval**, not one save,
driver or callback. It uses one global `e<=2`, two save-entering callbacks and
three saves. It neither restarts these allowances nor assumes warnings are
cleared after a save. The existing source/native/runtime, typed ownership,
selected-client and ordinary physical-resource premises remain in force.
There is no aggregate RAM/stack gate. Production, language, Oracle and proof
pins are unchanged; #119/#153 remain open.

## Exported bound and its interfaces

For a case, let V be the scalar-leaf count of its exact retained GNAT JSON,
C its direct native clone count, and E its accepted preparation-episode bound.
The packet maps these values **by input filename/hash**, not by a historical
table's row order:

| Case | V | C | E |
| --- | ---: | ---: | ---: |
| Put_Line | 38,670 | 13 | 155 |
| Put | 36,130 | 13 | 128 |
| First_Or_Default | 37,886 | 10 | 68 |
| Is_Message | 11,645 | 7 | 8 |
| Input_Is_Valid | 16,835 | 8 | 5 |

The sufficient bound is

```
W_initial <= 1140 + 4V + 205 + C + 19 + 38
W_library_suffix <= 554E
W_shared_global <= (1+e) + e <= 5
W_o <= W_initial + W_library_suffix + W_shared_global
L_o <= 422 W_o.
```

The initial term deliberately overcounts attribute warnings; it is a source
opportunity count, not an observation that those warnings occurred. Likewise
the later bound charges all potential attribute/exists/match sites, even when
their warning condition is false. `bounds.json` gives actual integer upper
bounds, `warning_B=3W_o+6L_o`, `warning_E=3W_o+2L_o`, and their sum separately
for each process. No warning lifetime multiplication by three saves is needed:
the existing JSON interface already supplies its complete output multiplicity.

These exclusions from W_o/L_o are intentional and remain separate inputs:

- Incompatible-answer warnings retain the existing `W_c<=O+N` and
  `L_c<=514O+512N` amortized interface. O includes interrupted occurrence
  multiplicity; no raw-output quota follows from this note.
- The final escape-buffer copy retains **D<=1, H<=26619**. It is not counted
  as a fresh fixed-text warning or included in the 422-byte bound.
- Terminal exception text **X**, server/service diagnostics, and raw solver
  storage **q** are outside this author lane.

The packet's canonical-O arithmetic is only a **partial join at X=0**, using
the existing conditional canonical-input interface. It checks useful scale
and remaining credit, not the complete standard-formatter guard. A complete
join must still add actual terminal and other selected standard writers.
It does not establish deployment/refinement of canonical solver output.

## Owner, initial list, hook and flags

`Gnat_report.warning_list` starts at `[]`; `add_warning` prepends and does not
reset it (`gnat_report.ml:34–46`). With a location it first makes
`"%s:(%d:%d)-(%d:%d): %s"`; without one it stores the supplied string.
`get_warnings` later maps the entire retained list. Thus neither empty standard
output nor registration's lack of prover requests proves this list empty.

The accepted [standard initial-state argument](retained-why-standard-initial-state.md)
excludes all pre-hook config/default-hook warnings by complete required fields,
absent optional section families and failure nonresumption. It explicitly
leaves post-hook private warning storage. Gnat_report installs its hook after
config and before controller/task work. The actual environment lacks
`GNATWHY3LOG`; `--logging` is a different option and does not replace this hook.
The combined startup and logging transfers preserve the same source/parser
inputs. Their added option/channel work supplies no new warning producer.

`set_debug_flags_gnatprove` disables `useless_at`, `unused_expression`,
`reduction_aborted`, `axiom_abstract`, `missing_shapes`, `unused_variable`,
the SMTv2 model-parser warning and the concrete-term warning before task work
(`gnat_util.ml:125–152`). `register_warning` returns an existing flag without
reenabling it; the later dynamic names are distinct. `without_warning` runs
directly when already false. No selected generic CLI setter enables these
flags. A failed lookup raises; it does not select a different enabled flag.

This is an output bound. `Loc.warning` constructs a private Buffer and formatter
**before** testing the flag, and sets its margin to **1,000,000,000**
(`loc.ml:187–195`). Disabled publication therefore does not prove zero private
construction. This note does not apply the default-margin-78 formatter theorem
to those owners or claim their native construction capacity closed.

## Initial warning opportunities

The [startup import account](retained-producer-import-context.md) supplies all
**21** initial library files, 419,906 bytes, and 205 explicit clones, including
all nine configured drivers' imports. The smaller eleven-file native-input
closure is insufficient. The packet matches all 21 complete source identities
to each retained ordered-input projection and the combined startup provider.
Each is opened once. The selected incremental reader parses once to EOF, then
publishes its complete file map; child/parent language caches share it.
The protected prefix has no collection, signal save/rollback or parser retry
reaching the cut, by the [registration](retained-why-initial-registration-bound.md)
and standard-initial-state arguments. We reuse their actual control premises,
not a general no-signal assumption for the suffix.

The initial sources have 19 `exists` tokens and 38 `match` tokens, counting
comments as spare capacity. A parsed existential invokes
`check_exists_implies` once when Dterm converts its body (`dterm.ml:669–681`).
A program match's ordinary-branch conversion invokes its warning test once
(`dexpr.ml:1617–1639`); pure matches are harmless overcount. Generated callable
lemma bodies and cloned units use already typed terms/Expr values, not another
Dterm/Dexpr syntax conversion. Native JSON has no existential node; its
ordinary match list is empty (`gnat_ast_to_ptree.ml:930–940`). Grouped exception
handlers are converted once each before any typed `Expr.e_match` fallback
(`dexpr.ml:1641–1683`); that fallback does not call the ordinary Dexpr warning.

For higher-order attribute warnings, charge every possible nonempty syntax
wrapper, rather than trying to prove its expression first-order:

1. An explicit attribute consumes its `[` token; a generated function-literal
   attribute consumes that literal's `[` token. Counting **all 343 `[` bytes**
   in the 21 files also includes triggers, comments and unrelated brackets.
2. The parser's contract-expression rewrite introduces one `wb_attr` wrapper
   for a nonempty specification (`parser_common.mly:951–957`). Charge its first
   annotation keyword. Counting every occurrence of `requires`, `ensures`,
   `returns`, `raises`, `reads`, `writes`, `alias`, `variant`, `diverges`,
   `partial`, `invariant`, `assert`, `check`, and `assume` gives **797**.
   This also overcounts logical named-annotation wrappers that do not enter
   Dexpr. Thus initial library wrapper opportunities are **J=343+797=1140**.
3. Typing's nonempty `DEattr` cases come from `Eattr/Tattr(ATstr,...)`
   (`typing.ml:920–921,1197–1198`). ATpos becomes `DEuloc`; scope/asref cases
   carry the empty set. The `at:` dynamic label writer makes **DTattr**, not
   DEattr (`typing.ml:344–364`). Foreign restored body/contract objects do not
   become new Ptree attribute syntax. Identifier/field/declaration attributes
   do not become expression wrappers merely because they are read or copied.

The native GNAT bound adds **4V** wrapper opportunities. V counts every scalar
leaf, including tags, IDs, domains, strings, numbers, Booleans and nulls, in
the complete nested JSON, so it overcounts the native expression domain.
Each tagged node has separate tag/ID/domain leaves. The complete converter
sites are: call-ID wrappers in `process_call`, `Any_expr` and `Abstract_expr`;
`Comment`; explicit Label/Assignment label strings; three fixed loop-comment
wrappers; and the Prog function's `vc:divergent` body wrapper
(`gnat_ast_to_ptree.ml:337–384,539–542,703–707,731–765,786–905,1115–1122`).
Arbitrary label-list lengths are charged to their own scalar string leaves,
not a fixed per-list allowance. `Curr.mk_attrs` constructs position attributes;
identifier and logical-term attributes do not introduce another program body.
Two local opportunities per scalar leaf are a loose allowance for these sites.

All five inputs have at most one **nonnested** native loop. Its pre-invariant
program occurs before and inside the generated loop, and each variant
expression is converted for old/new values (`:819–876`). Allowing two visits
to every local opportunity covers these repetitions, even where the Ptree
object itself is shared. Other converter child lists are mapped once; the
Expr/Pred declaration alternatives build logical definitions/contract terms
and parameter wrappers, not a second copy of a Prog body. Hence `2*2V=4V`.
This argument is about unfolded conversion opportunities, not physical JSON
node count or the amount of allocation observed at registration.

### Why one wrapper opportunity pays at most one warning

`strip` removes the whole attribute/cast/location prefix before `expr` or
`cexp` proceeds (`dexpr.ml:1343–1347,1389–1404`). A `cexp` call can warn once
for that prefix. `try_expr` calls **try_cexp**, not `cexp`, for its already
stripped application/function cases (`:1568–1571`), so it does not warn again
on the same prefix. Application-spine traversal saves each argument once and
`eval_args` converts each saved argument once (`:1409–1417,1510–1511`).
Ghost/let/recursive/exn/label continuations consume their child once. Ordinary
and exceptional match branches are converted once before the typed fallback.
No receiving type-error handler repeats a body conversion.

The parser's parallel-assignment rewrite moves collected attributes onto the
assignment rather than copying them (`parser_common.mly:963–982`); its loop
attribute helper likewise preserves a wrapper once. Comparison-chain typing
only reuses a bare variable/symbol; nontrivial attributed children get a proxy
(`typing.ml:861–870,1005–1025`). Record/witness lowering preserves the selected
children's single evaluation. `rec_defn` first creates routine signatures,
then calls `lambda` once per body, and only then runs `let_rec` and effect
repair on **typed Expr** values (`dexpr.ml:1738–1789`). Its alias-error handlers
inspect and rethrow; they do not reenter lambda. The outer declaration
dispatcher invokes the Dexpr entry once (`typing.ml:1702–1708`). These local
facts, initial one-parse control and the explicitly charged native loop copy
justify the opportunity injection. Hashes and token counts alone would not.

Clones add at most `205+C` initial warnings, by the accepted initial clone
argument. It counts a parser clone once, before `clone_export`. The Uclone
metadata copied by typed cloning does not call that helper again. Initial
target raw qualified names have at most 42 bytes. This is not a claim that
arbitrary pretty-printed identifiers have that bound.

## Later library warnings, including reparses

The accepted [library-origin](retained-why-path-library-origins.md) and
[constructor](retained-why-library-constructors.md) arguments restrict later
reads to `int`, `real`, `algebra`, `relations`. They include foreign restored
bodies, interrupted prefixes and missing memo publications. They do not allow
an arbitrary named module/declaration list to replace a fixed parsed module.
Use the already accepted whole-file parse counts, rather than expanded source
bytes, to charge these **syntactic** warning opportunities:

| File | `[` + annotation keywords | exists | match | Total |
| --- | ---: | ---: | ---: | ---: |
| int | 48 | 1 | 5 | 54 |
| real | 7 | 0 | 0 | 7 |
| algebra | 0 | 0 | 0 | 0 |
| relations | 0 | 0 | 0 | 0 |

A pessimistic direct real read parses int/real/algebra/relations at most
5/1/11/43 times; a direct int read is componentwise smaller. Thus one larger
root pays `5*54+7=277` opportunities and two roots in E episodes pay **554E**.
No cache persistence is assumed for this suffix calculation. The five int
matches are real program `let function`/`let predicate` bodies. We need not
assert exhaustive matching under foreign associations, nor that the lone
exists body's syntax can never simplify to an implication. Attribute warning
opportunities are retained even though the files have no literal attributes
or function literals; ordinary top-level specifications are also overcounted.

The clone warning is zero for this four-file family. The packet records each
actual clone target and an abstract witness. Every target has an abstract
type/parameter/axiom directly, or preserves such a witness through its first
clone without type substitution and with axioms retained. Examples of the
latter are AC, CommutativeMonoid, CommutativeGroup, CommutativeRing, PreOrder
and the order wrappers. `warn_clone_not_abstract` scans the target's immutable
declarations and raises its local Exit upon that witness before printing
(`theory.ml:880–896`). The source-selected module/clone provenance preserves
these declaration shapes even if permitted restoration hits supply foreign
contract bodies. A partially constructed module cannot be published as a
successful module map. No path-name printer needs to be bounded on this lane.

## Complete remaining warning partition

The packet scans complete retained implementation/interface/grammar files for
Loc.warning, warning hooks and Gnat_report.add_warning, **including unqualified
calls inside Loc**. It also checks module alias/open/include references. This
is a source-review census, joined with the accepted selected-client closure;
lexical absence alone is not the reachability proof.
The sole `open Loc` outside that module is in `ptree_helpers.mli:13`, for
interface position types; it defines no executable warning alias.

| Producer family | Disposition |
| --- | --- |
| Dterm exists, Dexpr higher-order attrs/nonexhaustive match, Theory clone | Initial and later opportunity bounds above. Dexpr's old-variable warning at1330 is commented code. |
| Pmodule constructor mismatch | Sole call at1292 follows `List.iter2 eq_cons` on the same immutable constructor lists. `eq_cons` raises when either raw constructor name differs (1285–1291). The warning helper tests that same inequality (1143–1152), so its body is unreachable, even with foreign associations. Unwinding cannot resume at the following statement. No `print_rs` output bound is silently assumed. |
| VC missing-diverges | Imported ordinary program VCs are disabled. The six exceptional startup witness/refinement constructions have the fixed terminating shapes proved in the startup-VC account. Native Prog bodies carry `vc:divergent`, including their generated loop/abstract code. Later four-file declarations have no witness/refinement VC route. This covers construction prefixes reaching registration, not just retained successful output formulas. |
| Redundant imports, four grammar sites | All21 initial files and the four-file subset have no import token. GNAT JSON constructs Ptree declarations directly. |
| Lexlib missing source file | Requires a `[#` source-location directive. Complete initial/later sources contain none. Native locations use the converter's Source_ptr route. |
| Loc unknown warning | Generic warning CLI handler absent; no selected call of set_flags_selected with an unknown flag. |
| Loc start/end column overflow | One shared `warning_emitted` gate, initially false, set after the warning call (loc.ml:252–277). At most one ordinary completed publication plus e interrupted publications before the flag write. After the private-buffer hook publishes, the remaining return/flag path has no source allocation or I/O retry; only the already classified escaping callback can abandon it. Thus at most **1+e**, across both branches and the whole process. No location wrapper; fixed text and one native integer. |
| Session missing-parent | Reuse the accepted diagnostic-occurrence getter/catch argument: ordinary missing lookup is converted to BadID before this catch. Only a signal-origin Not_found placement can enter the warning receiver. Thus at most **e**, followed by the separately accounted backtrace/assertion. No e renewal per save or producer. |
| Other session load/shape/merge/replay warnings | Fresh nonreplay route excludes session loading/merging; missing-prover direct warning is replay-only. Relevant selected transform application and status propagation are covered by callback/library closure, not the merge warning handlers. |
| Direct prover-output warning | Requires immutable Gnat_config.debug_prover_errors. Actual combined argv has no --debug-prover-errors; source default false and only option writer are retained. |
| InternalFailure logical exception warning | Accepted J12 callback logs/drops the InternalFailure payload and does not forward it to Gnat_main's warning arm. This does not erase in-body warnings already charged above. |
| GNAT RAC, model/check_ce, interpreter, inference, extraction, IDE/other tools/plugins | CE/debug/model/RAC routes and those frontend clients are unselected; explicitly disabled flags also cover the listed model families. Fixed loaded plugins initialize registrations, not these frontend warning clients. |
| Compute/args_wrapper/reduction and other transforms | Not in the fixed selected transform closure; reduction warning is additionally disabled. Existing bodies are not invoked merely by registering their transforms. |
| Config/autodetection warnings | Initial pre-hook exclusion is supplied above; no later config/autodetection read is selected. |
| Incompatible answers and final Debug copy | Separate W_c/L_c and D/H inputs, as stated above. |

## Warning bytes and transport

All warning-producing locations in this lane originate in the fixed parser
or native converter. The maximum initial library path is **166 bytes**, checked
against every exact ordered-input projection. Later files are the four-file
subset with the same installed path. Complete sources contain no `[#` virtual
filename directives. For native positions, the check inventories every possible
two-element Source_ptr representation, and every Loc_label marker; the bound
on `filename + marker + four delimiter bytes` is below166. Other selected
converter location construction copies those fields. Ordinary foreign term
locations are not used as the Dexpr match/attribute syntax location; the only
remaining global warnings have no location. Thus a filesystem-path maximum
is not being substituted for an unchecked virtual filename domain.

The largest fixed text plus four signed native integers, location punctuation,
and the initial raw clone target of at most42 bytes fits **256 bytes** beyond
the filename. Fixed warning printers use zero-indent local boxes, raw strings,
integers and the clone path's dot-separated raw components. Constructor mismatch
and logical exception warning printers are excluded as above. There is no
Pretty name-sanitizer or arbitrary numerical-term expansion in this bound.
Consequently **422=166+256** bounds each published warning string, including
newlines and the location wrapper, before JSON escaping. The imported JSON
interface supplies the subsequent escaping coefficients.

The episode values E155/128/68/8/5 refer to current J12 registration roots
51/42/22/2/1. Their corresponding older JSON suffix bounds N194/161/98/11/5
are larger, and the old raw graph envelopes G64/53/32/3/1 dominate those roots.
The input hashes agree. Source changes here affect scheduling/logging/options,
not the selected checks or their original group envelope; this is conservative
transport, not equality of the counters. Input_Is_Valid's historical first
inline cut is **not** relabeled registration or used to subtract initial work.
The initial source count starts before parsing; the suffix charge covers its
full prospective registration continuation.

The focused source/identity/arithmetic check and its earlier interface-census
assertion failure are recorded in the packet. The changed check explicitly
classifies that interface-only open. Existing successful evidence is reused; no previous checker/model,
compiler, solver, proof, target capture or source fetch was run. Review and the
complete root-owned reporting composition remain separate acceptance steps.
