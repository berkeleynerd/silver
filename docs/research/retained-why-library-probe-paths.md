# Raw library-probe pathname construction

2026-10-23 UTC, #119 / #153; Linux x86_64; author base `f795674a1c`.
This closes the raw probe-path operand left separate by the accepted
[report pathname theorem](retained-why-report-path-inputs.md). For every
selected `Env.locate_library` call, the immutable loadpath has **four**
directories and the extension registry has **five** keys. There are at most
**20 candidates**, each at most **167 bytes**, including unsuccessful probes.
The [packet](../evidence/retained-why-library-probe-paths-20261023/README.md)
attaches the actual configuration, generated native value, complete selected
registration closure and source-derived construction bounds. Independent
review is separate from this author result.

## Actual immutable directory provider

All five current J12 captures supply the same executable-name provider.
Their `process.json` field is recorded by the retained collector as
`str((proc/'exe').resolve())`; it is not inferred from argv[0]. The field and
the actual absolute argv[0] both equal the pinned installed gnatwhy3 path.
OCaml `startup_nat.c:147–154` first calls `caml_executable_name`: on Linux
that reads `/proc/self/exe` and checks its regular-file target
(`unix.c:356–385`). This supplies that recorded executable under the existing
unchanged installation/process/source/native relation. If the service returns
NULL, the fallback searches argv[0]; `caml_search_in_path` sees its slash and
copies the same absolute bytes unchanged (`unix.c:130–149,199–216`). Both
branches therefore attach the same value. A startup exception does not create
another successful registration continuation.

The generated Config implementation is absent from the retained source
archive. The packet supplies a **narrow target-free native witness**, without
executing gnatwhy3:

* `camlWhy3__Config__entry` computes twice dirname of Sys.executable_name,
  concatenates static `"share"`, then `"why3"`, and stores the result in its
  module field at offset 0x18. The static OCaml string headers, padding and
  exact bytes are decoded, not guessed from an ASCII substring.
* The selected Unix `Filename` module transfers its dirname closure to
  offset 0x68. Its wrapper `fun_1129` enters `generic_dirname`; the Config
  entry calls that closure twice. The complete initialization witness
  includes the Unix/Win32 dispatch, so a field index alone is not the proof.
* `Whyconf.empty_main`'s native initialization reads Config field 0x18 into
  the datadir field. This joins the generated value to the source-level
  `default_loadpath`, which appends `stdlib`.

For compact display let **I** be the actual fixed prefix
`/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef`.
This is notation for retained bytes, not a proposed relocation/deployment root.
The resulting complete `Env.get_loadpath` set is:

| Actual directory | Bytes |
| --- | ---: |
| I/libexec/spark/share/why3/theories | 147 |
| I/libexec/spark/share/why3/modules | 146 |
| I/share/spark/theories | 134 |
| I/libexec/spark/share/why3/stdlib | 145 |

`Gnat_util.spark_loadpath` constructs the first three from the executable's
directories (`gnat_util.ml:41–60`). The fourth is
Config.datadir/stdlib. Each retained base `why3.conf` has no datadir/loadpath/
stdlib override, and the controlled environment has no WHY3DATA or
WHY3LOADPATH. The `--why3-conf` overlay is read separately, but Gnat_config
merges provers, editors and shortcuts into the base configuration; it does
not substitute that overlay's main record (`gnat_config.ml:346–380`).
The prospective quiet/timeless changes preserve those main fields. No
proof-directory argument prepends `_theories`. This is the selected
`build_env_from_config` route, not generic Whyconf CLI `read_env` or
`add_extra_config` semantics. `Env.create_env` stores `Sstr.of_list`; the
four distinct directories become an immutable sorted set. No selected
post-cut action changes it.

## Complete initialized extension registry

The extension set is **{adb, gnat-json, mlw, sexp, why}**. The prior R69
undischarged P_stat display omitted sexp; this new complete provider explicitly
corrects that displayed domain. R69's diagnostic theorem is unchanged.

The retained source census identifies every format-registration call.
In the linked Why3 library, Lexer registers mlw/why and Sexp_parser registers
sexp. The native startup body calls both module entries; the retained
Sexp_parser entry calls Env.register_format. The selected built-in-prover
configuration takes `load_plugins=false`; `Gnat_util.build_env_from_config`
loads exactly gnat_json and ada_terms, whose registrations add gnat-json and
adb. Their complete mapped identities and source bodies are retained providers.
The generic automatic plugin scan and configured extra-plugin path are not
entered. Other registration sites belong to unselected parser plugins (cfg,
coma, dimacs, equlin, micro-C, Python and TPTP); their entry modules are not
in the linked initialization closure or current mapped-plugin set. The
internal recursive language-registration helper propagates an existing
format to parent languages and adds no extra extension. There are no selected
later format registrations.

Registration does not imply execution of a parser. In particular, the sexp
suffix adds raw stat candidates while the fixed unique-file/library relation
still selects the retained .mlw source family. This is why the extension
correction changes raw candidate counts without admitting S-expression
location constructors into diagnostic provenance.

The accepted library-publication owner supplies the post-cut logical file
bases int, real, algebra and relations, each a singleton pathname. Their
lengths are 3, 4, 7, 9. There is no substitution of the much larger qualified
logical identifier bound. The 80 complete potential spellings (four bases ×
four directories × five extensions) are exported, including paths absent on
disk. Successful-open observations are not used as a substitute for that
candidate domain.

## Local construction and representation guards

For a base of length b<=9, write k=5, d=4 and n=dk=20. All directories are
nonempty and have no trailing slash. The logical path has one component;
`check_qualifier` calls `Filename.basename`, which copies at most b bytes.
The subsequent `List.fold_left Filename.concat "" path` creates a second
at-most-b-byte string. It does not prepend cwd.

OCaml `^` associates right: `file ^ "." ^ ext` constructs `"." ^ ext`
and then the full suffix filename. Their maximum lengths are 10 and 19.
`Filename.concat dir suffix` constructs `"/" ^ suffix` (at most 20) and then
the full pathname (at most 147+1+19=167). The source implementation of `^`
creates a Bytes block, blits both arguments and returns the same block as a
string; it does not allocate another copy for unsafe_to_string. The packet
retains the native add_ext body to confirm both concatenation calls.

There are at most **52 new string blocks** per locate invocation:
2 for basename/base folding, 2k for extension construction and 2dk for directory
construction. Their exact conservative totals, counting every prospective
intermediate allocation without subtracting reclaimed or abandoned values,
are:

| Base | Maximum pathname | String payload bytes summed | String allocation words | C-copy bytes summed |
| --- | ---: | ---: | ---: | ---: |
| int | 161 | 3,311 | 500 | 3,068 |
| real | 162 | 3,358 | 505 | 3,088 |
| algebra | 165 | 3,499 | 515 | 3,148 |
| relations | 167 | 3,593 | 525 | 3,188 |

String words include each header and use
`1+ceil((length+1)/8)` for this 64-bit runtime. The largest single string
occupies 22 words. Byte/substring operands are nonnegative and at most 167;
all concat sums, offsets and endpoints fit the selected native integer and
string/block limits. Basename's index moves from b−1 down to −1, and accesses
only when nonnegative; the resulting substring length is at most b. No
array growth or encoded filename index is used in this owner.

List construction must be charged separately from the final 20-element list:

| Owner | New cons cells, upper bound |
| --- | ---: |
| Mstr.keys(extension_table) | 5 |
| map add_ext | 5 |
| Sstr.elements(env_path), implemented by M.keys | 4 |
| outer map add_dir | 4 |
| inner maps, five candidates per directory | 20 |
| List.concat/flatten copies the inner lists with append | 20 |
| filter's successful-test accumulator plus final reverse | 40 |
| **Total** | **98** |

Every list spine is at most 20, and the outer nested list is at most 4 with
inner lengths 5. Filtering has at most 20 predicate calls, including failed
stat results; it does not duplicate pathname strings. Each cons block is
three words. AVL key traversals read at most five/four existing nodes and
create only the charged cons cells; no map rebalance is performed here.
Each recursion consumes a strict list/tree/input-index suffix, so all local
traversals are finite independently of stat success.

The narrow native allocation witnesses account for the fixed closure work:
two Env captures use 4 words each, four add_dir partial applications use 5
each, basename's mutual-closure block uses 9 and List.find_all's two closures
use 10: **47 words**. The zero/ambiguous result branches allocate at most one
four-word exception record; the single match returns the existing string.
Thus the pathname routine's **direct** prospective managed allocation requests
total at most **870 words per invocation** (525+98×3+47+4). This excludes
GC/runtime-service internals and independently charged signal/save callbacks;
it is not the demand of every nested runtime call. This is a local accounting
interface, not process peak RAM, physical-stack sufficiency or a resource
admission gate. Global locate-call multiplicity remains with the producer
owner; multiplying a final live-list size would not establish cumulative
allocation demand.

## Native probes and failed prefixes

`caml_sys_file_exists` first checks C safety, duplicates the pathname,
performs stat and frees the duplicate. On this Linux runtime the OS conversion
macro is plain `caml_stat_strdup`: the request is strlen+1, at most **168
bytes** including NUL. All constructed spellings are ASCII and contain no
embedded NUL. No locale expansion or second pathname is concatenated. The
per-invocation sum of prospective C duplicate requests is at most 3,188 bytes;
it does not assert that all copies are simultaneously live.

A failed stat returns false and the filter continues. A C-safe rejection
returns false before duplication. Allocation, signal and other escaping
service failures remain permitted: a prefix allocates no more than the
complete charged sequence, and a suspended/abandoned copy is not credited
as reclaimed. In particular, an exception escaping the blocking-section
return can bypass the source free; the cumulative request bound still
charges that copy. There is no local recovery loop restarting the twenty
candidates. Any later producer invocation consumes another invocation of
this same interface, not a renewed interruption allowance.

The source does not promise a successful stat, a unique existing file, or
successful opening after stat. Zero matches can construct LibraryNotFound;
multiple matches can construct AmbiguousPath; selected opening/parsing remains
the existing library owner. Error/location byte ownership remains with
P_diag and the terminal theorem. Stat-only candidate strings never become
Sys_error(candidate), as already established there.

The unchanged global allowances are e<=2, two save-entering callbacks and
three saves. Physical allocator/GC, kernel/I/O and stack sufficiency and the
selected source/native relation remain trusted. This packet does not close
FileTags counters/tables, logging, raw solver q, startup capacity or whole
#119 assurance. It changes no Oracle, tool pin, admission or production code.

The author selected GPT-6 Astra / Extra High; runtime setting confirmation
and token/cost telemetry are unavailable. Preparation began 19:22:02 UTC.
New target-free disassembly and focused-check timing are recorded in the
packet; no compiler, solver, proof, target execution, capture or predecessor
checker was run. No GitHub or shared-record write was made.
