# Fixed-domain solver request byte bounds

2026-10-20 UTC, R56 research for #119 / #153; selected Linux x86_64 route.

The fixed drivers give a source-derived request-line bound without changing
configuration or abbreviating goal names. For the R53 wrapper, let A be the
adapter executable argument's byte length and tau_d the client's actual
nonempty TMPDIR byte length, with no trailing slash. The following bounds
include the final LF. The quiet column uses the already retained R52 candidate
CVC5 command; the other commands are unchanged.

| Domain | N_d | ID digits d | Original L_d | Quiet L_d | m_d |
| --- | ---: | ---: | --- | --- | ---: |
| Put_Line | 192 | 3 | A+tau_d+150 | A+tau_d+273 | 14 |
| Put | 159 | 3 | A+tau_d+150 | A+tau_d+273 | 14 |
| First_Or_Default | 96 | 2 | A+tau_d+155 | A+tau_d+278 | 14 |
| Is_Message | 9 | 1 | A+tau_d+153 | A+tau_d+276 | 14 |
| Input_Is_Valid | 3 | 1 | A+tau_d+153 | A+tau_d+276 | 14 |

Here m excludes the executable. These are conservative maxima over the three
provers; the largest line and largest m need not belong to the same prover.
Interrupt lines have 11+d bytes, so M_d=L_d also bounds either intact request
kind. Require M_d+1023 <= INT_MAX at the parser/receive interface.

The [packet](../evidence/retained-solver-request-bytes-20261020/README.md)
exports per-prover argc, field and semicolon counts, symbolic lengths, exact
source JSON locations and a finite serialization check. It reuses accepted
R53/R54/R55 evidence rather than replaying its successful captures or checkers.
This is a reviewed source argument under those source/native/runtime and
normal-service interfaces, not a machine proof of OCaml semantics or complete
q. No adapter or production capability is implemented.

The attachment scope matters. R55 establishes original J12 startup with its
prospective logging option. It does not itself establish the combined
quiet+timeless+J12+logging startup. The quiet column is a conditional byte
projection for that separately required join. Covering both serialized time
values 0. and 1. does not discharge the timeless configuration's startup
argument. The global two save-entering callbacks, three saves and e<=2 budgets
are unchanged.

## Goal header and filesystem filename

R54's retained raw labels have one exact proposition identifier per domain,
with the name `def'vc`. The native location words encode file tag 50 and the
following source line at column zero. The FileTags lookup strings were not
captured; the filename column is established by the following source-origin
argument, not by treating tag 50 as a filename.

| Domain | Unique JSON program function `def` location | Sanitized file stem |
| --- | --- | --- |
| Put_Line | silver_io.ads:18 | silver_io |
| Put | silver_io.ads:29 | silver_io |
| First_Or_Default | silver_arguments.ads:13 | silver_arguments |
| Is_Message | silver_arguments.adb:5 | silver_arguments |
| Input_Is_Valid | silver_arguments.ads:9 | silver_arguments |

The new projection finds the unique `W_FUNCTION_DECL` named `def` in each
exact R53 JSON input, verifies domain 4 and its unqualified `W_NAME`, and
compares all retained raw labels with its encoded line and `def'vc` name.
`gnat_ast.ml:1351–1355,1962–1978` decodes field 11 as that source location.
`gnat_ast_to_ptree.ml:60–64,1011–1019,1091–1124` builds the zero-column
`Loc.user_position`, appends its ATpos to the function identifier and passes
the identifier to the program let. The initial dummy position in the parse
identifier is replaced: `typing.ml:188–192` selects ATpos before `id_user`.
Its Dlet branch (`1702–1705`) passes this preidentifier to `Dexpr.let_defn`.
`dexpr.ml:1801–1816`, `expr.ml:46–58,112–123,727–730` and
`Ident.id_register` retain the name/location in the routine identifier.
`vc.ml:1675–1689,1713–1731` copies that location and appends `'vc` to its name.
The accepted registration/splitting argument and `split_goal.ml:489–491`
retain this header in the registered goals. No native filename-table read is
claimed. This source-origin join depends on the same selected input and
source-to-native correspondence as the accepted prefix, rather than on a
coincidental equality of line numbers.

Location lookup also needs persistence. `loc.ml:43–89` keeps two private
strong maps, assigns a fresh tag once, and never removes or replaces entries.
`loc.mli` does not expose those maps; `Wstdlib.Hstr/Hint` use strong
`Hashtbl.Make` tables. Apply the successful, non-unwinding mutation guard to
**the entire** insertion sequence: Hstr.add, Hint.add, increment. An exception
that escapes between these steps and is caught for continued service is not
covered merely by calling the maps private. Retain immutable string keys,
intact map state, valid runtime representation and the selected 64-bit native
addressing premises. Every different retained filename requires a different
string object with at least one eight-byte header and one data word
(`runtime/alloc.c:79–95`). Therefore at most 2^60 such live keys fit even in
the full 2^64-byte address space, below the 2^62 signed tag-counter wrap.
Under those premises the stored mapping cannot be overwritten by tag reuse.
This argument permits later lazy location producers; it does not assume their
absence, prove other counters safe or supply a whole-heap bound.

## Driver preparation preserves the header

For every successful selected preparation, the terminal Pgoal's
`(pr_name.id_string, pr_name.id_loc)` is unchanged. Physical proposition
identity is unnecessary. `Driver.update_task:329–369` removes the goal while
adding driver context/metas, then reattaches the exact goal tdecl.
`prepare_task:372–391` applies the retained ordered transformation list.
The projection checks those lists against all five native metadata captures
and the selected driver bytes/import closure. The following cases cover their
union; all line references are to pinned source excerpts.

| Selected transformation(s) | Header-preserving source case |
| --- | --- |
| counterexamples_dependent_intros | CE off chooses `Introduction.remove_unused_from_context` (`prepare_for_counterexmp:17–34`); its Dprop branch retains pr (`introduction:513–528`). |
| inline_trivial | `inlining:58–92` rewrites formula through `Decl.decl_map`, retaining kind/pr. |
| eliminate_builtin | `eliminate_definition:28–50` only removes a proposition through the Paxiom case; Pgoal is retained. |
| remove_unused | `remove_unused:143–175,260–284` keeps original selected tdecls; it introduces no proposition. If no goal survives, no successful filename/send follows. |
| detect_polymorphism | `detect_polymorphism:109–127` adds metadata and retains logical declarations. |
| eliminate_definition_conditionally, eliminate_recursion | `eliminate_definition:111–207` rewrites Dlogic; other declaration heads survive. Both conditional branches preserve goal headers. |
| monomorphise_goal | `libencoding:267–278` passes the original pr to the new goal. |
| eliminate_inductive | `eliminate_inductive:47–61` replaces only Dind; generated propositions are axioms. |
| eliminate_gnatprove_guard_epsilon | `eliminate_gnatprove_guard_epsilon:110–114` uses declaration mapping with the original goal pr. |
| eliminate_epsilon, eliminate_literal | Their declaration map-folds (`eliminate_epsilon:216`, `eliminate_literal:171`) retain kind/pr; fresh auxiliary proposition names are axioms. |
| simplify_formula | The selected registration is formula rewriting through `Trans.rewriteTF` (`simplify_formula:37`), not the separate task-removal transform. |
| eliminate_projections_sums, eliminate_algebraic, eliminate_algebraic_if_poly | `eliminate_algebraic:67,466,491,540,585,637,665–670` composes declaration formula maps or identity; every surviving goal keeps its pr. |
| introduce_premises | `introduction:195–244` constructs the final Pgoal with the supplied pr. |
| split_premise_right | `split_goal:519–523,585` splits Paxiom only; the Pgoal tdecl is retained. |
| discriminate_if_poly | Identity, or `discriminate:237–254,453–471`; a translated Dprop uses the original pr or `id_clone pr.pr_name` with no location override. |
| encoding_smt_if_poly | Identity, or the composition in `encoding:117–145`: monomorphise_goal, metadata selection/addition, kept-type and polymorphism encoding. The source inventory finds twin plus guards, tags, guards_full and tags_full dispatch registrations. Each Dprop path retains kind/pr (`encoding_twin:108–109`, guards/tags:133–136, guards_full:262–264, tags_full:75–76); their monomorphise_task suffix retains pr (`libencoding:182–213`). |

`Decl.decl_map`, `DeclTF` and `decl_map_fold` (`decl.ml:621–678`)
retain kind/pr; `Ident.id_clone:209–216` preserves name and the default
location. No selected rule turns fresh auxiliary axioms into goals.
Transform composition therefore preserves the header of any successfully
returned goal, irrespective of formula growth or the number of new symbols.
This covers CVC5's polymorphic fallback; the accepted R54 monomorphic identity
evidence was specific to Z3 and is not silently extended to CVC5.

Cache hits do not introduce another header: `Trans.store:51–53` bypasses its
whole-task cache for terminal goals; other task memoization is keyed by the
input task under the existing valid-cache interface. Generic declaration
hashcons equality requires pr identity (`decl.ml:365–366`), and the special
Introduction declaration cache explicitly compares name, attributes and
`Option.equal Loc.equal` (`introduction:33–54`). The immutable task header is
unchanged by subsequent printing. These are header statements, not bounds on
transformed formula size, allocations, runtime or solver output.

## Filename and argv arithmetic

The packet retains 14 driver/import files and verifies their exact bytes
against R53's recorded resolution. Each selected closure has one filename
directive: `%f-%t-%g.smt2` for CVC5/Z3 and `%f-%t-%g.psmt2` for Alt-Ergo.
The native capture retained the driver record but not its nested filename
option string. An attempted retained-memory lookup therefore failed; the
source-driver closure is the explicit alternative witness, with no new target
capture.

`Driver.file_name_of_task:415–454` on the fresh branch uses the location's
filename basename with its extension removed, theory `T`, and the goal name.
The selected noninteractive scheduling path supplies no old script filename
(`gnat_checks:1037–1047`, `controller_itp:412–431`). `Driver.get_filename:
295–308` applies `Ident.sanitizer char_to_alnumus char_to_alnumus` separately
to these values. Thus `def'vc` becomes `defqtvc`; the resulting filenames are:

| Stem | SMT2 bytes | PSMT2 bytes |
| --- | ---: | ---: |
| silver_io | 24 | 25 |
| silver_arguments | 31 | 32 |

These filesystem names have no connection to the 116,162-byte Why qualified
identifier-path bound. Neither the printer's identifier table nor fresh
formula names are filename operands.

`Call_provers.call_on_buffer:604–617` calls
`Filename.open_temp_file "why_" ("_" ^ filename)`. The selected OCaml
`filename.ml:331–361` masks the random value to 24 bits and formats exactly
six hexadecimal digits. Every retry keeps the same width. Linux concat adds
one slash for the selected nonempty TMPDIR with no trailing slash; consequently
F=tau+12+driver_filename_bytes: tau+36/37 for IO and tau+43/44 for Arguments.
TMPDIR is initialized from the environment (fallback `/tmp`); the complete
retained ML/MLI inventory contains no Why3 `set_temp_dir_name` reference.
The selected runtime and route exclude an independent setter. The projection
retains the five actual TMPDIR strings and checks their path grammar, without
requiring a new filename/template/configuration choice.

Zero steps selects the ordinary command (`controller_itp:416–419`);
`Whyconf.get_complete_command:247–255` appends extra options, empty in these
fixed configurations. `Call_provers.actualcommand:404–429` tokenizes before
substituting `%f`; substitution cannot create more argv entries. Each selected
command has exactly one placeholder, the final `%f`, and therefore uses `run`,
not `runstdin`. Original mem=0 and ordinary time=0; warnings can use the default
1. `adapt_limits:448–458` leaves these unchanged because steps=0 and there is
no time placeholder. With LC_ALL=C, OCaml `string_of_float` formats them as
`0.`/`1.` (stdlib:279–289). The prospective timeless configuration has the
same two-byte time width.

`Prove_client.send_request:161–184` serializes
`run;ID;time;mem;exec;args...\n`. With original argc a and total argv payload S,
its byte length is 10+d+a+S. The original CVC5/Z3/Alt-Ergo lengths are F+d+53,
F+d+43 and F+d+50. The retained quiet CVC5 command has an absolute executable
and gives F+d+176. R53's wrapper adds ten argv entries and A+55+d bytes,
including the second occurrence of the request ID. Hence:

| Prover | Original argc | Wrapped argc | Parser m | Total fields | Semicolons |
| --- | ---: | ---: | ---: | ---: | ---: |
| CVC5 | 4 | 14 | 13 | 18 | 17 |
| Z3 | 5 | 15 | 14 | 19 | 18 |
| Alt-Ergo | 5 | 15 | 14 | 19 | 18 |

The wrapper's control name `.slv-a0` has seven bytes; domain and prover
numbers have one digit. A, tau and all serialized operands must satisfy the
selected delimiter grammar (no semicolon, LF, CR or NUL). The source serializer
does not escape these bytes. Arbitrary configuration strings or malformed
concatenations are not assigned this intact-request bound. The separate
failure-aware stream/ingress ownership interface remains required.

## Output paths and storage attachment

For raw backend output, `server-unix.c:132–142,517–524` appends `/why3` and
six mkstemp characters to `current_dir`, obtained from actual `getcwd(NULL,0)`.
Therefore **P_b=C+11**, where C is the byte length of that actual returned
string, and the temporary pathname allocation is C+12 including NUL. The
retained server JSON does not capture getcwd. A launch path is not silently
substituted: configuration must establish its canonical-directory relation to
that value (or provide a sound upper bound). This is still an explicit
configuration operand, not a fabricated historical measurement.

R53's canonical result route gives **P_c=len(R)+24**. The directory R and
adapter executable A are prospective fixed configuration inputs, not selected
numerically by this research. With their actual byte lengths attached, these
operands instantiate R55's response/storage formulas. The parent R56 parser
component can use `sum_d N_d*(L_d+8*m_d)+57714`, charging m_d=14 conservatively.
The parser, backend P_b+d+31 and canonical serializer arithmetic guards remain
necessary; ring/object/allocator/raw-output/logging/storage owners and complete
q remain separate. Source correspondence and complete obligation discharge
remain required. Oracle, tool pins, admission and production #88–#94 are
unchanged.
