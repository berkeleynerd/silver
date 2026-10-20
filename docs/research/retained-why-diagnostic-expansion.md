# Selected exception dispatch and wrapper expansion

2026-10-20 UTC, #119 / #153, Linux x86_64; author base
`cd8c3d840fc83ed7f71cf9cbabb04d15a7ebc6e9`. This source result uses the
accepted fixed-library, driver, registry and pending-client relation. It
does not extend the historical PID 97103 first-inline diagnostic estimate.

**A selected exception has at most seven recursive diagnostic wrappers.**
One outer diagnostic consequently requires at most 510 Why-registry passes,
28,050 Why callback attempts and 1,275 Printexc callback attempts, including
fallback after partially failed printers. These are useful dispatch bounds;
they do not bound the sizes of logical diagnostic payloads. Actual complete
diagnostic bytes, identifier registrations, native stack and standard-root
`B/E` remain unknown. The [packet](../evidence/retained-why-diagnostic-expansion-20261020/README.md)
checks retained source correspondence, imported inputs and the arithmetic.
The control argument below remains a review obligation, not a checker theorem.

## Selected creation paths

The [library-origin result](retained-why-path-library-origins.md) supplies the
20 automatic outer transformation names, three SMT printers, every registered
encoding/discrimination flag choice, and the four whole later WhyML libraries.
It includes repeated parsing and private memo aliases within this family;
it does not assume identifier freshness. The actual `get_model=None` result
excludes the model-parser source family. The
[registry packet](retained-why-session-exception-prefix.md) and
[converter packet](retained-why-sexplib-converter-prefix.md) supply the fixed
55-candidate conservative Why corpus, five Printexc callbacks, and converter
initialization. No new registry census is performed here.

The recursive printed-exception constructors on these creation paths are:

| Wrapper | Maximum in one exception chain | Creation/continuation argument |
| --- | ---: | --- |
| `Trans.TransFailure` | 3 | One registered outer transformation, plus the flag selector and its default selector. |
| `Loc.Located` | 2 | Coalescing location helpers, plus one noncoalescing clone-statement handler. |
| `Theory.BadInstance (BadI_rs_type (_,e))` | 1 | The protected routine-application check cannot call the clone/parser handler again. |
| `Fun.Finally_raised` | 1 | A failing selected cleanup replaces the work exception; it does not wrap that exception as its payload. |

The sum is a deliberately conservative `d<=7`. The rows need not attain their
maxima together. They bound exception **values**, including a previously
constructed value reported again; scheduling and repeated reports are charged
by the independent outer-occurrence result.

`Trans.named` catches and wraps any escaping exception when stack traces are
disabled (`trans.ml:369–372`). The ordinary registration functions introduce
one such layer (`379–393`). The two levels inside `Encoding.select_kept`
(`encoding.ml:59–69`) and `Discriminate.select_insts`
(`discriminate.ml:406–432`) are real: `on_flag_t` can select an `on_flag`
default, and each `on_flag_gen` calls `named` (`trans.ml:531–545`). The four
discrimination selectors run sequentially, as do the selected transformation
sequences. Once one raises, a later sibling is not entered and cannot add
another wrapper. The other fixed encoding callbacks return their direct
task/set transformations; they do not reenter the registry or add another
flag-selector layer. The bound covers all fixed flag choices, not only the
nominal defaults. Failure during environment-transform construction can occur
before its outer `named` exists, which only reduces the count.

`Loc.try1` through `try7` and `with_location` preserve an already outer
`Located` (`loc.ml:309–337,354–360`). `Loc.errorm` wraps a new `Message`;
ordinary explicit location errors wrap their newly selected core error.
The exceptions are the two clone-statement handlers
(`typing.ml:1715–1719,1728–1737`), which unconditionally construct another
`Located`. Their `find_module` call is **before** the protected clone block.
Consequently a nested library-read error unwinds through coalescing `try3`
handlers; it is not successively wrapped by every enclosing library clone.
Within the protected block, `type_inst` resolves symbols from already selected
modules and `clone_export'` copies declarations and clone metadata. Its `Uclone`
case copies maps; it does not parse or execute another clone statement
(`pmodule.ml:1590–1634`). Scope traversal does not add a wrapper. The lower
typing/core location plus the enclosing clone handler therefore gives two.
The selected task transformations do not add location handlers around another
parser invocation; their wrappers are the separate `TransFailure` row.

The recursive `BadI_rs_type` payload is made only around
`e_exec (c_app rs' cty.cty_args [] cty.cty_result)` in the selected module clone
(`pmodule.ml:1379–1391`). `c_app` constructs a `Capp`, using `cty_apply` and
the tuple special case (`expr.ml:841–844`). For that `Capp`, `e_exec` and
`c_cty_enrich` do not enter the `Cfun` expression-body branch
(`expr.ml:697–703,755–779`). The matching/substitution/contract reconstruction
in `ity.ml:1436–1505` has no parser or clone callback. Logical or primitive
exceptions remain possible, but another `BadI_rs_type` cannot originate inside
this protected expression. Later sequential clone declarations do not retain
an earlier failed declaration as a nested exception.

OCaml `Fun.protect` wraps a **cleanup exception**, or reraises the original work
exception unchanged after successful cleanup (`fun.ml:27–38`). The selected
cleanup bodies update timing scalars/tables (`debug.ml:158–173`) or flush/close
a private file formatter (`sysutil.ml:69–90`); neither calls another protect.
Another enclosing cleanup failure replaces the previous exception rather than
nesting it. The accepted pending save/ending clients have no protect cleanup
that supplies another such payload. This includes their possible failures;
it does not assume that cleanup, runtime services or saving always succeed.

The other recursive registry constructors have no later creation route:
Strategy's command interpreter and argument-taking transformations are absent;
`Located_by_marker` belongs to initial GNAT-JSON conversion before all cuts;
Dynlink's nested errors require loading, which has finished. The enabled
Sexplib/Parsexp recursive conversion cases require their parsing/conversion
clients, whereas the later selected reads are the four WhyML libraries and
ordinary prover-answer parsing. Session/JSON/sexp/model parsing is not restarted
by the selected continuation. These are exclusions by the accepted root and
callback relation, not by a missing native symbol or a printer returning None.
Primitive and logical **leaf** exceptions remain admitted. A new callback,
loading phase or parser root would require rechecking this closure.

## Failed printing and the dispatch recurrence

`registered_exn_printer` calls each candidate as `"@[%a@]"`. A candidate that
rejects can already have opened a box; a matching printer can output a prefix
and then fail. Except for the private successful-completion escape, failures
are swallowed and the next callback receives the **original** exception
(`exn_printer.ml:23–39`). Printer failure does not make that new exception the
next registry argument. Count every candidate shell and every attempted
matching prefix, not merely the ultimately successful printer.

If the direct Why pass fails, `anomaly_exn_printer` calls `Printexc.to_string`
on the same input. The Why Printexc adapter creates a fresh Buffer formatter,
does **one registered pass**, and returns None on complete rejection; it does
not call the anomaly handler (`43–51`). Printexc likewise suppresses callback
failure while retaining its original input (`printexc.ml:46–76`). Within one
pass, a recursive constructor has just its one matching registered branch.
The Pretty registration is outside the printer functor and is not multiplied
by the number of instantiated logical printers.

Group processing of one exception value into a *dispatch package*: one direct
Why pass when present, the same-value Printexc fallback when present, and its
possible Why adapter pass. A package has at most two recursive calls on the
strict inner exception, one per Why pass. `Finally_raised` instead has at most
one inner Printexc call. Thus, for remaining wrapper depth d,

```text
N(0) = 1;  N(d) = 1 + 2*N(d-1) = 2^(d+1)-1
Why passes <= 2*N(d); Why callback attempts <= 110*N(d)
Printexc.to_string calls <= N(d); Printexc callback attempts <= 5*N(d)
attempts of a particular terminal matching branch <= 2^(d+1).
```

At d=7 this is `N=255`, 510 passes, 28,050 Why candidates, 255 Printexc calls,
1,275 Printexc candidates and 256 terminal-branch attempts per outer call.
Total Pretty callback invocations are bounded by 510, not 256: its rejecting
and `BadI_rs_type` wrapper-level invocations count too. At most eight packages
are simultaneously nested along a branch; this is not a native-frame or
logical-payload traversal-depth bound. No old `d<=2`, eight-Pretty-attempt or
`D=25,920` estimate is used.

The accepted occurrence freeze `63a701e032bd054331613716c7a8ba56fc9c58a3`
supplies outer calls H=`392/326/200/26/14` for
put_line/put/first_or_default/is_message/input_is_valid, respectively. It
already counts controller, main, custom uncaught and the two fallback calls.
Multiplying the displayed per-call bounds by H is allowed under the union of
their named premises. It does not renew the global two-interruption allowance.
The packet retains this exact imported result and the per-case products.

## Source-owned byte interfaces and formatter destinations

The recursive wrappers have small direct transfers. Let f be the actual
location filename byte length, t the selected transformation name byte length,
and n the actual `BadI_rs_type` identifier's `id_string` length.

| Branch | Own contribution, excluding the inner diagnostic |
| --- | --- |
| `Loc.Located` | At most `f+128` direct text bytes, two boxes/closes combined, one break; all integer displays have at most 20 bytes under normal conversion. A conservative 32 direct core events covers its entire own prefix. |
| `TransFailure` | `26+t` direct text bytes, one forced newline. Fixed selected transformation/flag names have `t<=64`; invalid flag names raise a leaf before becoming a selected wrapper name. |
| `BadI_rs_type` | At most `n+52` text bytes at the supplied formatter, plus at most `n+8` at one private identifier-decoding formatter; the latter is used only by the suffix-decoding branch. At most 32 own direct core events across these owners is conservative. |
| `Finally_raised` | String result length at most `20 + length(inner Printexc result)`, with no direct Format operation. |
| Anomaly | Literal `"anomaly: "` contributes 9 text bytes and the returned Printexc string is a separate text argument. Its **rendered length** must be charged. |

These count attempted prefixes as well as completion, with failed numeric or
allocation services retained by their service/error owner. `Loc.pp_position`
prints at most four native integers and a raw filename
(`loc.ml:114–126`). Pretty's wrapper uses `print_id`, which delegates to
`Ident.print_decoded`; it does not use `id_unique` or register a fresh identifier.
`print_sn` adds at most eight bytes to a decoded notation, and `sn_decode` has
at most one private `Format.asprintf` suffix construction
(`ident.ml:93–154`). Its strings are text, not new format programs. No bound
for every later diagnostic identifier is inferred from the qualified-path
bound 116,162; the actual n remains an input here.

For the default Printexc representation define C as the actual constructor-name
length, k as the number of direct payload fields, and S as the sum of the
lengths of its direct string fields. It inspects those fields only: immediate
integers use decimal, strings use `%S`, doubles use `string_of_float`, and every
other block becomes `_`. It does not recursively traverse a logical payload.
Under the existing normal scalar-service contract, `%S` uses at most `4s+2`
bytes, native integer text at most 20 and binary64 `%.12g` plus the possible
decimal-point repair at most 64. Therefore a conservative ordinary default
bound is `C+4S+68k+2`, including separators/parentheses. The three special
location exceptions instead have bound `filename_bytes+160`; their tuple's
filename must not be mistaken for a direct string field. Out-of-memory and
stack-overflow defaults are fixed strings. These are actual field metrics,
not a bound on all service-created strings or all leaf callbacks. They do not
cover the Unix printer's separate error string and two payload strings.

The outer GNAT diagnostic calls build private `Format.asprintf`/Pp strings.
The Why Printexc adapter and identifier decoder have further private owners.
Returned strings feed the warning/abort JSON formatter, whose escaping gives a
separate standard stdout B/E contribution, or the direct Printexc fallback
channel writer. A registry shell is consequently **not** a direct standard
stdout/stderr event. The four recursive branches add no independent channel
output, seek or close: they use their supplied formatter or return strings.
Finalizer file flush/close belongs to exception creation, not printer dispatch.

In particular the sum of private text input bytes does not automatically bound
an adapter's returned string. Layout can emit spaces/newlines, repeated adapter
results can be copied by enclosing anomaly handlers, and failed candidates can
leave open boxes. Logical printers also use geometry outside the standard
core's restricted 0/1 indentation. A private diagnostic formatter transfer for
that actual token family is still required. Annotation-parser private
formatters are additional owners, not included in the direct event counts.

## Finite dispatch versus represented capacity

The candidate shells alone have at most `220*N*H=56,100*H` private direct
open/close events, or 21,991,200 for the largest H. All displayed dispatch
counts and products fit a signed 63-bit integer. As an **arithmetic probe**,
putting B=0 and E equal to this event upper bound into the standard-core guards
passes all three guards for every case. This shows that the known shell count
does not by itself force the arithmetic interface to fail. It is neither an
actual standard E input nor validation of private logical formatter geometry.

The converse matters: finite mathematical recursion does not certify a useful
represented input bound. Even a uniform allowance of 64 bytes for each matched
wrapper prefix, charged at two matching prefixes per package, gives another
`128*N*H` bytes before filenames, identifiers, leaves, rendered-layout copies,
JSON escapes or scalar failures. Their remaining allowance is finite. Any
completed standard input must satisfy `B+E+79 <= 1,000,000,010` as well as the
scan-size and counter guards. This packet does not supply that completed input;
no actual case guard is claimed to pass or fail from an illustrative probe.

## Concrete remaining joins

1. `Prove_client.read_from_client` reads chunks of at most 1024 bytes, but
   `read_lines` keeps appending to `recv_buf` until a newline. `read_answer`
   can raise `InvalidAnswer s` containing the whole assembled line, and the
   printer emits all of s (`prove_client.ml:75–90,195–258`). A server-frame
   length theorem/input is needed. The chunk size is not a line-size bound.
2. All later selected library/transformation failures need logical payload
   occurrence, arity, type, pattern, declaration and numeric-size bounds.
   The retained generated-formula interface and earlier first-inline type
   counts do not establish this whole typed-body closure. Pretty's mutable
   printable-name tables and uniqueness-suffix search history also need a
   bound; path-value size alone does not supply it.
3. Bind those leaf metrics to every attempted logical printer, including
   partial failures and repeated leaf visits. Discharge their identifier and
   private formatter/token/annotation budgets, then bound rendered results
   before applying JSON or direct-channel transfers. Native/service-created
   error strings and scalar failure paths retain their explicit owners.
4. Join native-stack and runtime-service/physical resource bounds separately.
   A depth-seven exception chain does not bound recursion through a term/type,
   default field list, formatter queue or scalar service.

No whole diagnostic byte/event, registration or stack bound is exported; no
complete R, full save/exit capacity or physical sufficiency follows. #119 and
#153 remain incomplete; production #88–#94, draft PR #121, admission and the
Oracle are unchanged. This author lane owns only this note and its new packet;
the lead owns independent review, integration, issue/memory updates and
publication.
