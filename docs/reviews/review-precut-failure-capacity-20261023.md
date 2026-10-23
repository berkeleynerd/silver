# Review: conditional returning pre-cut failure capacity

2026-10-23 UTC; #119 / #153. Reviewed author freeze
`07e63b97f3623b2405172433ae093ce894defd23`, specifically
[`retained-precut-failure-capacity.md`](../research/retained-precut-failure-capacity.md)
and its complete evidence packet. **Accepted at its conditional scalar/marker
scope. No critical or bound-changing finding.** Two small documentation
corrections are listed below. The supplementary reasoning and retained source
spans in this review are part of the acceptance basis.

This does not accept complete failed-prefix capacity, the actual joined P,
complete Sexp/Mlw serialization, whole-process capacity, or global #119/#153
completion. The fixed-five continuation freeze is unchanged. The review changed
only this report and its [new evidence packet](../evidence/review-precut-failure-capacity-20261023/README.md).
No Oracle, tools, pins, admission, production code, GitHub state or merge was
changed. Physical resources and the existing source/native/service relation
remain trusted; no allocator audit or upstream provenance investigation was run.

Selected reviewer settings: **GPT-6 Astra / Extra High** (`gpt-6-astra`,
`xhigh`), confirmed as selected by the delegating lead. Runtime confirmation
and isolated token/cost telemetry are unavailable. Actual host: Linux x86_64,
kernel 7.0.14, glibc 2.43. The focused check passed 269 checks in
18.12794034399849 seconds after one checker repair. The packet records the
review interval and retained failures. These are elapsed/check observations,
not a comparison of model quality. The subthread harness goal was null; the
lead supplied the owner's latest continuation authorization and retained
ownership of the paused root goal and shared bookkeeping.

## Findings and disposition

1. **Low: correct the diagnostic sequencing description.** The note's
   “Separate Ptree diagnostic interface” lists `Sexp.to_string` before opening
   the `.sexp` file. Actual `gnat_ast_to_ptree.ml:1376–1380` constructs the Sexp,
   opens the file, then evaluates `Sexp.to_string` for `output_string`, then
   closes. A serialization failure can therefore follow a successful open.
   This does not change the scalar/marker bounds or add a retry; the separate
   serializer/file owner must preserve the actual order. Correct the prose at
   integration. The author packet already retains the exact source.
2. **Low: make the original-name explanation exact.** The note says the
   library lexical projection has maximum 82; both retained author JSON files
   and this independent extraction give **69**. The conservative 82 statement
   does not invalidate 467. Also, `typing.ml:1566–1580` constructs an abstract
   `Cany` routine from a source proposition with a one-time **`'lemma`** suffix.
   That constructor should be named in the provenance explanation. Its bound
   is at most `202+6=208` for the imported Ptree string interface and `69+6=75`
   for these original library words, still below 467. This is not the later
   `'refn` routine. Correct the wording at integration; no capacity constant
   needs changing.

## Control and exception-family review

The two explicit caller abort levels are `gnat_loc.ml:100–106` inside
`gnat_expl.ml:424–438`. A handler cannot catch its own abort body. The outer
main handler (`gnat_main.ml:331–360`) contributes one attempt, and the configured
handler (`gnat_util.ml:11–22`) contributes one more. `abort_with_message`
(`gnat_util.ml:4–9`) exits after a returning write. A failed write unwinds;
the imported standard-prefix observer excludes an abort failure becoming the
registration `Not_found` continuation. Configuration, driver discovery,
singleton add-file reporting and direct connection failures have shallower
caller nesting. Thus four is conservative, including abandoned output prefixes.
The uncaught fallback (`printexc.ml:327–360`) neither retries the custom handler
nor starts a fifth abort. The disabled-backtrace premise applies from startup.

The phase partition is essential and supported:

| Phase | Maximum ordinary recursive wrapper chain |
| --- | --- |
| Initial typing | Two Located, one BadI_rs_type, one Finally |
| GNAT typing marker argument | Remove the outer Located: inner depth at most three |
| Registration transformations | Three TransFailure, one Finally |
| Configuration/Pmodule initialization/connection construction | Separate private scalar rendering and copying; these do not enclose initial typing or registration |

`typing.ml:1715–1737` performs `find_module` before entering the noncoalescing
clone trap. Imported-library recursion therefore does not stack those traps.
`pmodule.ml:1590–1634` copies existing clone metadata and does not recursively
parse another clone. `pmodule.ml:1390–1391` protects only
`e_exec(c_app ...)`; the selected Capp route does not run a parser/clone.
`fun.ml:27–38` wraps a cleanup failure, replacing the body failure. The selected
timing and private-file cleanups do not parse/clone or enter another protect.
An outer cleanup failure cannot preserve a hidden inner Located/Finally chain.
The marker handler is outside its matched expression's trap and replaces the
outer Located with Located_by_marker (`gnat_ast_to_ptree.ml:1410–1423`).

Ordinary open/read/close/connect errors remain included. `Rc.from_file`
(`rc.mll:403–411`) preserves returning service errors, including replacement
by a close error. Missing file probes can produce LibraryNotFound or the
explicit missing-driver/plugin branch. Controller.add_file catches one
Session.read_file exception and returns an Errors_list singleton
(`controller_itp.ml:271–285`); init_cont prints that element rather than nesting
another recursive wrapper. A relativization/section failure replaces the saved
error. Connection cwd restoration (`prove_client.ml:28–53`) can fail and replace
the connect error. Failed printing retains the original registry argument
(`exn_printer.ml:23–51`), so printer failure does not create a recursively
diagnosed sequence of printer exceptions.

The stable valid JSON/configuration/library/plugin and represented-operation
premises exclude malformed data and semantic type errors; they do not exclude
these service paths. The old terminal theorem alone would not justify that
exclusion or this larger prefix. The Why-only SIGINT mask and the existing
Thread/SIGVTALRM/native client relation are retained. The process-global
`e<=2`, two save-entering callbacks, three saves and two gated Format exit
flushes are never renewed by entering another failure path.

## Original-name and loader supplements

BadI reports **the original** `rs.rs_name` at `pmodule.ml:1378–1391`, before
the `'refn` construction at 1394. `clone_let_defn` (`1048–1065`) and
`Ident.id_clone` preserve the spelling. Direct Ptree binders, original library
binders, the one-time lemma construction above and the bounded tuple/notation
constructors suffice. In particular a refined concrete Capp body does not
become a newly refinable abstract routine merely because its name contains
`'refn`. The independent lexical projection checks all 21 retained library
files; conservative word candidates have maximum 69 and raw operator runs,
including comments/strings, maximum 4. This checks the symbolic-head allowance
as well as words. The raw Ptree maximum 202 is imported from exact commit
`09d9a2382f`; this review does not supply its missing native-layout,
configuration or immutable-input transport.

The author's glibc excerpts cover the principal open/read/map/protect/close
paths, but the following additional sites merit explicit closure. Their
complete selected-file Debian patch projection is retained in this review:

| Additional selected source | Returning diagnostic shape |
| --- | --- |
| `elf/dl-deps.c:201–204,425–427,465–467` | Object name plus fixed dependency-buffer/list/search-list message |
| `elf/dl-hwcaps.c:101–103,193–195` | Empty object name plus fixed allocation message |
| `elf/dl-close.c:361–363` | Fixed `dlclose` object label plus fixed scope-list message, including cleanup reached from dl-open |
| `sysdeps/x86_64/dl-cet.c:240–256` | Selected object's name plus fixed IBT/SHSTK text, including a returning feature-disable service failure |
| `sysdeps/x86_64/dl-machine.h:713–716` | Selected DSO name plus fixed PLT-protection message |
| `elf/dl-exception.c:36–52,81–102` | Copies the same object/message or substitutes empty object plus fixed OOM text |

No new dynamic service-message expansion arises. `dl-deps.c:571–573` and
`dl-open.c:920–943` rethrow the stored exception; they do not prepend another
pathname. `dlfcn/dlerror.c:70–103` supplies at most the object spelling, two
separators, the selected literal and C-locale strerror. Each added literal is
below the retained 256 allowance, so `P+512` still covers it. Version/symbol
lookup mismatch paths remain outside the fixed valid-image/binding relation.
CET/PLT **service** failures were retained here instead of being mislabeled as
malformed-image exclusions. The supplementary patch scan finds only the same
wrong-machine and ARM-conditional patches touching these selected files; neither
changes these service-message constructions.

P still needs the actual inherited client cwd, complete selected filesystem
arguments, loader object/dependency spellings, location filenames and qualified
library spellings. In particular neither the measured initial-path maximum 180
nor the later four-library path projection supplies this join. The packet
correctly leaves actual cwd and joined P null. No numerical pathname cap was
introduced or inferred from an example.

## Returned bytes and private copies

The two-child recurrence counts contributions at a particular returned/root
destination. Each strict-child attempt contributes there at most once; copying
an unquoted string is not fourfold byte expansion. Own layout is additive over
the actual events, including dirty candidate shells. The imported interrupted
formatter/Buffer invariant remains necessary. This supports
`R[d]=2*R[d-1]+C`, whereas paying child work and enclosing copies separately
supports `A[d]=4*A[d-1]+C`. Independent geometric sums give `R[4]=31C`,
`A[4]=341C`, and the distinct marker sums `15C_marker` and `85C_marker`.

Dynlink needs its special branch. Two possible Why passes call error_message;
the Dynlink Printexc callback can make one further inner scalar conversion and
quote it. Its default variant payload is opaque. The returned majorant
`2C+4C+C=7C` is conservative. For the private `32C` bound, account explicitly
for `String.escaped`, quote wrapping, Printf buffer insertion/growth/contents,
the enclosing Dynlink Printf and the outer anomaly/adapter copies. The scalar
child's tighter returned bound is

```
D = 2K + 70*(320+4) = 2K+22680
C - 3D = 2K-2504 >= 0       (K >= 6327).
```

A conservative variable-byte copy ledger is:

| Construction/copy family | Coefficient of D |
| --- | ---: |
| Two Why error_message concatenations | 2 |
| Their Format offers and destination insertions | 4 |
| Possible Why adapter contents | 1 |
| Escaped payload, quote wrapping, quoted Printf insertion/growth/contents | 24 |
| Enclosing Dynlink Printf insertion/growth/contents | 16 |
| Outer anomaly offer and insertion | 8 |
| Why destination-buffer growth copies | 12 |
| Final root contents | 5 |
| Total | 72 |

The growth entries use the ordinary doubling invariant: summed prior copied
prefixes are below twice the relevant total payload, with constant initial
capacity charged separately. Failed prefixes do not retry their constructor.
Charge `3C` for the child packages and another `5C` for root own text/layout,
fixed prefixes, helper constants and initial capacities. This gives
`8C+72D <= 32C`. The large own allowance covers the 320-event root package
and its helper endings; no child layout is omitted because it is already in D.
This is a conservative construction/offer/copy ledger for the represented
owners, not aggregate process RAM or a proof that physical allocation succeeds.
It also stays below common `341C` and 9,936-event allowances.

Marker origins are confined to the typing/library phase. Config payloads,
connection messages, Dynlink and GP_ abort strings cannot enter the suspended
typing handler. Consequently the smaller `S_marker=max(467,P+51,N_id)` is
valid, and its returned payload is `15*(8*(723+12*S_marker)+65536)+1024`.
The exact value **1,743,304** holds for `P<=416` and `N_id<=467`; the independent
check also verifies it increases at P=417. It is not an unconditional constant
or an adopted input restriction.

The four-abort JSON/event allowances, once-only initial driver diagnostic,
global exit flushes and direct fallback channel contribution reproduce the
author's arithmetic for all five retained U values. They remain conditional
on actual P and the displayed private/core/channel inequalities. The separate
Sexp/Mlw owners must receive **returned marker bytes**, not the larger private
aggregate, and must supply their complete tree expansion/file counter guards.
Those are explicit pending joins rather than adverse findings in this packet.
