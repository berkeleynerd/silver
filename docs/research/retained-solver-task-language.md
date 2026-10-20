# Selected generated solver command language

2026-10-20 UTC, Linux x86_64, #119 / #153; author base
`8d9cee6f09ff1e00010c9189314b230a870f52c1`.

**Each submitted task in the selected fixed-input family contains at most one
`check-sat` and one `get-info :reason-unknown`, and no `set-option`, model,
echo, all-statistics, proof or reset command.** This is a source inclusion
argument for the actual printer, fixed driver closure and task construction,
under the already accepted source/runtime relation. It is stronger than counting
the printer's visible query sites, but supplies neither solver semantic
acceptance nor a complete output bound q. All q/O exports remain null.

The [offline packet](../evidence/retained-solver-task-language-20261020/README.md)
joins the same five native JSON inputs, 11 loaded library files and corrected
14-file driver closure to Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`. It records every fixed prelude and
syntax directive, their lexical structure, relevant source bodies, and exact
input identities. No generated SMT sample, solver execution or production
configuration change is used to establish membership in this family.

## Scope and imported construction result

The five processes are Put_Line/17310, Put/17514,
First_Or_Default/17631, Is_Message/17704 and Input_Is_Valid/17869.
The first four cuts precede scheduling; the last precedes the first CVC5
`inline_trivial` after `counterexamples_dependent_intros`. The
[model-meta attachment](retained-why-model-meta-control.md) already joins their
inputs, plugins, driver resolution and pending clients to the accepted
[Round 32 construction/helper result](retained-why-path-library-origins.md#selected-writer-closure).
That result covers actual transform helpers, `Driver.update_task`, cloning,
meta registration, hash-consing and task memoization. It is not inferred anew
from an absent input string or `--counterexample off`.

This note strengthens that same invariant, without requiring fresh identifier,
term or task tags:

1. `get_counterexmp`, `meta_incremental` and `supports_smtlib_minimize` are absent
   from every task in the selected construction family.
2. A syntax-meta string is one of the fixed strings in the selected driver
   closure; the syntax map may additionally contain `""` from `remove_prop`.
3. Every location filename that can enter the goal's printed location comment
   has no CR or LF.

The first item reuses the accepted counterexample result for its first key.
For the other two keys and the syntax strings, the new finite input checks
cover all decoded JSON strings and all library meta names. None introduces
these keys or a syntax meta. Driver loading supplies exactly the checked
syntax directives and no incremental/minimize meta. `Gnat_ast_to_ptree`'s
generic meta case takes its name from the input; its additional synthesized
meta is `remove_unused:dependency` (`:1226–1239,1285–1298`).

The accepted selected transform/helper cases insert their displayed encoding,
algebraic, introduction and definition metas, not these new forbidden keys or
new syntax strings. Generic reconstruction preserves the meta object.
`Theory.cl_marg` and `clone_meta` remap type/symbol arguments and leave `MAstr`
unchanged (`theory.ml:861–878,999–1016`); encoding's meta reconstruction also
passes `MAstr` through (`encoding_sort.ml:225–247`). `Discriminate.get_syntax_map`
copies an existing syntax-map entry to an instantiated symbol; it does not
construct another template (`discriminate.ml:488–504`). `Printer.change_override`
selects an existing/new fixed entry or raises. Tag aliases can select the wrong
symbol/template and cause a malformed task or an exception; they cannot create
a string outside this family. The empty removal entry is harmless for command
inclusion even if an alias selects it for a term or type.

Stable, distinct registered meta objects and their separate initialization
counter are part of the accepted result. Task reconstruction preserves the
meta map; task hash-consing checks the tdecl and predecessor. A transformation
memo hit may return another task from the same invariant family. These facts
prove the strengthened induction over the selected continuation, rather than
equating a meta-map hash hit with semantic freshness.

`force_incremental` is also false. `Debug` initially consults `WHY3DEBUG`, which
is absent from the exact retained environments; the argv has no `--debug-why3`.
`Gnat_util.set_debug_flags_gnatprove` sets `vc_sp`, not this flag
(`debug.ml:23–38`, `gnat_config.ml:226–233`, `gnat_util.ml:125–152`). The accepted
fixed initialization/client relation excludes a later flag-setting client.
Thus neither task metadata nor the debug bypass selects incremental printing.

## Complete fixed insertion surfaces

The recursive import order is checked against the corrected inventory and the
accepted meta attachment. The old ambiguous private `cvc5.gen` is not used;
the private import is `silver_cvc5_no_steps.gen`. The
[Per_Check record](retained-producer-prefix-per-check.md) retains the correction.

| Selected root | Printer | Syntax directives in expanded closure | Global noncomment prelude commands | Theory-prelude commands, at most |
| --- | --- | ---: | --- | ---: |
| CVC5 | `smtv2.6` | 316 | `set-logic ALL`; `set-info :smt-lib-version 2.6` | 8 `define-fun` |
| Z3 | `smtv2` | 311 | Four `set-info` commands below | 8 `define-fun` |
| Alt-Ergo | `smtv2.6par` | 44 | `set-logic ALL`; `set-info :smt-lib-version 2.6` | 0 |

There are 336 distinct syntax source sites across the 14 files. The counts
include directives for unused theories; no unproved reachability restriction
is needed. Z3's four fields are `:smt-lib-version 2.5`,
`:source |VC generated by SPARK 2014|`, `:category industrial` and
`:status unknown`. The apparent `set-logic AUFNIRA` in `smt-libv2.gen` is inside
a comment. No prelude sets `:filename`, emits a query or changes an option.
The eight theory definitions are the six Float32/64/80 finite/integral helpers
and two computer-division helpers. Other theory preludes are comments.

`Driver` retains immutable prelude strings; `print_prelude` writes their bytes
directly. `print_th_prelude` walks Use/Clone declarations and uses a fresh local
identifier table to emit each map key at most once
(`printer.ml:411–429`). Even a key alias selects only an existing prelude list
and can suppress another list; the number of fixed definition directives is
still bounded by eight. Theory paths and names are not interpolated into a
prelude string. Driver-loading `Ruse`/meta insertion remains within the imported
construction closure.

Why3's syntax validation checks argument indices and kinds, not SMT command
safety (`printer.ml:238–280`). The stronger fact here comes from the complete
fixed strings. Each template has no quote, quoted-symbol delimiter, semicolon,
CR or LF. Each parenthesis prefix has nonnegative depth. Its final depth is
zero, with **two exceptions**: `ieee_float.Float80.in_range` and `no_overflow`
in `smt-libv2-floats.gen:158,166` each retain one unmatched opening parenthesis.
Their decoded strings and symbolic hole substitutions are in the census.

Those exceptions prevent a claim that every retained template is a well-formed
SMT expression. They do not permit a template to close its surrounding command:
their surplus only raises nesting depth. No selected reachability or successful
solver handling of Float80 is asserted. The source bytes are unchanged; this
is an explicit semantic-acceptance obligation if either template can be used.

`syntax_arguments[_typed]` writes the fixed slices directly and replaces holes
only with recursive term/type printers. It does not interpret inserted bytes as
another format string. Range/float literal holes use numeric base printers;
the selected forms contain no custom `%c` callback
(`printer.ml:195–206,299–408`). On the returning normal numeric-service domain,
these substitutions add digits/signs, or recursively nested terms/types; they
cannot introduce a closing delimiter at a lower nesting level. An empty syntax
entry can delete an operand and cause a syntax error, but cannot escape a
command. Composition therefore preserves the command enclosure even with the
two positive-surplus templates. This lexical property does not prove typing,
SMT validity, arithmetic capacity or resource sufficiency.

## Identifiers, strings and the raw location-comment case

Ordinary identifiers use a fresh SMT identifier printer with
`sanitizer char_to_alpha char_to_alnumus` (`smtv2.ml:191–193`). Every character
becomes letters/digits/underscore, with an alphabetic first character and the
fixed `zilch` fallback for an empty name. Normal unique-name suffixing adds
decimal digits. Cache aliases select strings produced by this same sanitizer;
they do not reintroduce the original identifier spelling
(`ident.ml:225–351`). Model-field names used with `%s` are obtained from that
printer too. Comments containing original symbol/goal names use `%S`, whose
normal escaped-string service does not emit a raw CR/LF from an operand.

String constants are wrapped in quotes by `Constant.print_string_constant`.
The SMT escape callback replaces quote, backslash and every nonprinting byte
with `\xHH`, and leaves the other printable bytes inside the quotes
(`constant.ml:65–78`, `smtv2.ml:336–341`). This establishes lexical containment,
not a theorem about each solver's string-escape semantics. Ordinary integer/
real printing uses the displayed numeric format; normal numeric printers add
no command delimiters beyond its fixed nested arithmetic forms.

Goal location comments are different. `smtv2.ml:822` uses `Loc.pp_position`,
which prints the filename through raw `%s` (`loc.ml:122–126`). Merely pointing
to the identifier sanitizer would miss this route. For example, a hypothetical
filename containing LF followed by `(set-option :print-success true)` could
leave the `;; File` comment. No universal escaping theorem is claimed for
arbitrary Why3 inputs or arbitrary future Silver source paths.

The selected domain closes this route:

- Every decoded string occurrence in all five fixed JSON files is CR/LF-free:
  respectively 14,543 / 13,569 / 14,199 / 4,261 / 6,106 for
  Put_Line / Put / First_Or_Default / Is_Message / Input_Is_Valid. This includes
  filenames, markers, symbol strings and attribute inputs. `mk_location` copies
  the supplied filename; the marker route concatenates only `"'@"`, a supplied
  string, `"@'"` and that filename (`gnat_ast_to_ptree.ml:60–64,248–256`).
- The complete retained library paths, invocation paths and private overlay
  locations have no CR/LF. The prefix library bytes have no explicit location
  directive. The accepted prefix relation includes initialization of the other
  configured driver objects; their fixed filesystem paths have the same
  property. Later named-library reads are the already accepted fixed DAG.
  The Why3 lexer itself excludes CR/LF inside explicit location filenames
  (`lexer.mll:56–68`); path resolution concatenates existing safe components.
- Generated ptree locations use `<dummy>`; other builtin/dummy locations use
  fixed safe strings. Typing's `loc_cutoff` retains the original filename.
  Location joining, identifier/term cloning and selected transformations copy
  locations. `Ident`'s location-attribute round trip retains the filename suffix;
  selected generated attributes add only fixed prefixes and decimal fields to
  existing safe locations. Model-parser location producers are excluded by the
  imported model-meta result. S-expression file parsing and interactive argument
  parsing are not selected roots.
- `Loc.FileTags` stores the supplied filename, and `Loc.get` returns a stored
  value. Even a numerical alias can choose only another inserted safe value;
  this argument does not require that file-tag counter to stay fresh forever.

These are source origin/preservation facts over the retained input relation,
not an observation of every future task. They preserve the single-line comment
invariant; ordinary formatter layout adds no break inside `pp_position`'s raw
filename. Changes to inputs, paths, plugins or location-producing clients need
the corresponding join before this result can be reused.

In particular, a prospective theorem for the owner's intended current-grammar
configuration must derive or explicitly specify the CR/LF-free filename
condition before admission, together with template provenance. This packet
does not impose that condition on Silver or establish it for arbitrary source
paths. The current fixed family and that future grammar/configuration join are
distinct obligations.

## Command census and incomplete writes

The printer requires a terminal goal. Task constructors reject adding another
declaration after a goal (`task.ml:137–177`); the accepted reconstruction and
hash-consing relation preserves that shape. At most one goal reaches
`print_prop_decl`. Its nonincremental body calls `add_check_sat` once
(`smtv2.ml:777–784,809–831`). A syntax/removal alias or earlier failure can
omit that call; this is an upper count, not a proof that every file solves a
required obligation.

| Command family per submitted file | Upper count / allowed operands |
| --- | --- |
| `check-sat` | 1 |
| `get-info` | 1, only `:reason-unknown` |
| `set-option`, `get-model`, `get-value`, `get-proof`, `get-option`, `echo` | 0 |
| `get-info :all-statistics`, `push`, `pop`, `reset`, `reset-assertions`, `minimize` | 0 |
| `find-synth`, `find-synth-next` | 0 |
| `set-logic`, `set-info` | Only the fixed global preludes above |
| Declarations/assertions | `declare-sort`, `declare-const`, `declare-fun`, `declare-datatypes`, `define-fun`, `define-fun-rec`, `define-funs-rec`, `assert` |

Only the CVC5 driver inserts the reason-support meta initially. The common
upper envelope deliberately permits one reason query for **each** solver:
the accepted task-memo relation does not give a cross-driver freshness theorem.
Shared transform memo domains may select a task with the CVC5 meta. Conversely,
the same relation does not guarantee that CVC5 retains it. No stronger per-solver
absence or exact J=1 is exported. The incremental fallback query is excluded
by the strengthened invariant, so the earlier skeleton-only `C <= 2` becomes
`C <= 1` for this family.

The displayed declaration families exhaust `print_decl`; recursive bodies use
the containment rules above. `Dlogic` can print several definitions, so counting
Task nodes alone would not bound the total command count. That total and
generated term/declaration sizes remain separate prospective obligations.
Unsupported constructs or malformed templates may still cause diagnostics.

`Driver.prove_task_prepared` prints into a newly created private Buffer and
flushes before calling `call_on_buffer` (`driver.ml:456–474`). The latter writes
the buffer and successfully closes the file **before** calling `call_on_file`,
which sends the request (`call_provers.ml:604–618,507–533`). An escaping printing,
buffer-copy or close exception therefore does not submit that partial file.
The fixed callback relation provides no other client that submits its abandoned
buffer/file. A partial request write, after this point, still refers to the
completed file. These claims use the accepted normal storage/runtime interface;
they do not assume that a truncated or externally modified file equals its
requested contents. Solver read errors and prefixes of solver output still
belong in q, including interruption while the solver prints.

## Effect on solver output obligations

This closes the generated-task channels that could explicitly enable
print-success, statistics-per-query, statistics-all, model/proof dumping,
profiling, arbitrary echo, all-statistics queries or resets through `set-option`
or additional commands. It excludes `set-info :filename`, so that task command
cannot overwrite CVC5's filename statistic. It preserves the selected CLI
commands and flags; the no-step-parser driver edit never suppressed statistics.

It does **not** establish that all solver option values stay at their CLI
defaults. The fixed `set-logic` and version/info commands are present and solver
automatic option selection still needs its candidate-source analysis. Likewise,
the normal parser must preserve lexical command containment; a source-to-native
and launch-resolution attachment remains necessary. Z3/Alt-Ergo output accounts
must allow the common one-reason-query envelope until a sharper separation is
proved. Parser/type errors, warnings, solver-generated terms, statistics,
termination/runtime output, declarations' multiplicity and concurrency remain
with their existing owners.

No finite q or O is inferred from this census. The global suffix budget remains
two save-entering callbacks, three save attempts and `e <= 2`; it never restarts
for a printer, solver or error path. This result is not attached to every program
in the current Silver grammar. #119/#153 remain incomplete, production #88–#94
unstarted and draft PR #121 unmerged. Oracle, tool/source pins, admission and
solver commands are unchanged.

Selected author settings: GPT-6 Astra / Extra High; runtime confirmation and
token/cost telemetry unavailable. The packet records actual elapsed/check time.
Independent review is pending at the author freeze.
