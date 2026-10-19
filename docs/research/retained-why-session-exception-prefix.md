# Session exception prefix: dispatch and remaining closure

2026-10-19, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). This is a separate
source-analysis packet after formatter repair
`72096d190945da9e9697627b81e3631387574b8a`; it does not amend any frozen formatter
or binder evidence. **The inspected Why printer callbacks reject ordinary
runtime exceptions without opening logical binders. Complete exceptional
handling is not yet closed.** A linked Sexplib0 converter registry and the
interrupted computation's handlers are concrete remaining obligations.

The [evidence packet](../evidence/retained-why-session-exception-prefix-20261019/README.md)
retains 40 matching source excerpts, all 55 lexical Why printer-registration
snippets, and 22 existing-disassembly bodies / **5,619 byte-checked bytes**.
It uses the already retained matching Why/OCaml sources and executable. No new
source version, native execution, capture or disassembly was introduced.

## Exceptions can leave the direct save path

`Gnat_main.save_session_and_exit` (`gnat_main.ml:298–309`) ignores the three
signals under the already reviewed successful-POSIX premises, invokes
`Gnat_checks.save_session`, then calls `exit`. The GNAT helper at
`gnat_checks.ml:752–753` directly invokes `Session_itp.save_session`; it adds no
exception wrapper. Therefore a save exception prevents that particular
`exit` call and propagates into the interrupted OCaml computation. This is not
evidence that this capture actually failed or that arbitrary exceptions can
occur at arbitrary points.

The direct save body (`session_itp.ml:2212–2244`) has no outer retry handler.
It recomputes explanations and shapes, backs up files and serializes. Partial
binder work before an exception is a prefix of the already charged traversal;
the existing `B_binders = 966` is not a success-only count of completed saves.
The separate two-save callback interface is unchanged. Whether an escaping
exception can be consumed by an interrupted local handler is a different
control-flow question discussed below.

The inspected origin categories are:

| Origin | Source result and scope |
| --- | --- |
| File backup/open/write/close; allocation; primitive formatting | Runtime/I/O/string exceptions remain possible; this work assumes neither success nor unlimited resources |
| Session lookup | `BadID` has no payload; `get_task` can raise `Not_found`; current membership and the detached guard retain their accepted meaning |
| Goal extraction | `Task.GoalNotFound` has a constant-message Why printer; current retained goal heads are already checked |
| Explanation and shape traversal | Local `Exit`, `Not_found` and `ShapeTooLong` are normally consumed by their shown local handlers; no observed escaping instance is asserted |
| Binder opening and substitution | `t_open_bound`, `t_open_quant` and the substitution traversal use type-unsafe reconstruction rather than the `t_type`/`t_prop` term-error checks; this removes a direct route to `TermExpected`/`FmlaExpected` from those bodies |
| Pattern renaming within `t_open_branch` | Uses pattern constructors and type checks; valid pattern caches, well-formedness and noncolliding freshness remain applicable premises, rather than consequences of the unsafe term substitution observation |

This table is **not an exhaustive exception-effect analysis** of all transitive
runtime, library and interrupted-context operations. In particular the
well-formedness and cache premises must not be replaced by a blanket assertion
that all logical exceptions are impossible. No additional zero charge is
assigned to unclassified type/pattern diagnostics merely because their payloads
look smaller than terms.

## What the Why registry establishes

Take the ordinary primitive family consisting of `Sys_error`, `Failure`,
`Invalid_argument`, `Not_found`, `Exit`, `End_of_file`, `Division_by_zero`,
`Out_of_memory`, `Stack_overflow`, `Match_failure`, `Assert_failure`,
`Undefined_recursive_module`, and `Unix.Unix_error`, with their usual primitive
payloads. This is a useful family to test, not a declaration that it exhausts
the save path.

Every one of the **55 registration snippets** in the fixed Why `src/` and
`plugins/` projection matches its own listed constructors and re-raises the
unmatched argument. None matches a member of that primitive family. This
includes conservative extra tools/plugins that are not necessarily loaded.
The only lexical exception aliases in that corpus are C/Java extraction's
`Unsupported = Printer.Unsupported`; neither aliases a primitive constructor.
The source inspection, with constructor identity/type abstraction, establishes
rejection for this family. The lexical extractor and alias census make the
inputs reviewable; they are not an OCaml pattern-match theorem or a runtime
observation of the registry order.

`registered_exn_printer` (`exn_printer.ml:23–32`) formats the candidate printer
synchronously. A successful printer is signaled by private `Exit_loop`; other
printer exceptions are swallowed and the next printer is tried with the
**original** input exception. For a primitive-family input the matched fallback
branches add no logical printer work. Format boxes and rejection-side formatting
use the separately repaired formatter family. Failing printers in general can
do work before failing, so this observation must not be generalized to a
logical exception without examining its matching branch.

If every Why printer rejects, `anomaly_exn_printer` calls
`Printexc.to_string` (`exn_printer.ml:18–19`). Why also registers a Printexc
callback that invokes `registered_exn_printer`, **not** `exn_printer`
(`43–51`). Its all-rejected result is `None`; it does not itself recurse back
into the anomaly fallback. This explains the possible repeated Why-registry
pass without inventing infinite fallback recursion.

The inspected recursive wrapper branches include:

- `Trans.TransFailure (name,e)` (`trans.ml:561–563`);
- `Loc.Located (position,e)` (`loc.ml:347–348`);
- `Strategy.StratFailure`, `Args_wrapper.Arg_parse_type_error`, and the GNAT
  plugin's `Located_by_marker` (all retained in the inventory);
- OCaml `Fun.Finally_raised e` (`fun.ml:21–38`), whose Printexc printer calls
  `Printexc.to_string e`.

Their direct prefixes format names, positions or fixed text, then delegate to
the inner exception's printer. Such wrappers preserve a zero-charge conclusion
**only after that inner dispatch is closed**. They do not erase its obligation.
`Pretty` also has `BadInstance (BadI_rs_type (id,e))`, which delegates after
printing an existing identifier. It is retained in the complete inventory; no
claim is made that this wrapper is created by the save route.

Logical payload branches remain distinct. `Pretty` prints terms for
`TermExpected`/`FmlaExpected` (`pretty.ml:850–853`); `Printer` prints terms or
declarations for `UnsupportedTerm`/`UnsupportedDecl` (`printer.ml:647–655`).
These may open binders. The fact that unrelated primitive inputs are rejected
does not supply a bound if such an input can actually reach dispatch.

## Printexc adds another registry

`Printexc.to_string` tries every registered printer before its default scalar
representation (`printexc.ml:46–76`). A printer exception is suppressed and
dispatch continues. The default handler renders scalar fields and uses `_`
for other blocks (`24–44`); it does not call methods on an arbitrary exception
payload or traverse that payload as a Why term.

The raw installed direct-reference diagnostic finds **five** calls to
`Printexc.register_printer`: Why Exn_printer, Unix, Dynlink_types, Stdlib.Fun,
and **Sexplib0.Sexp_conv**. The first four have corresponding exact pinned
source here. Unix formats its error code and two strings; Fun delegates the
wrapped exception; Dynlink_types formats its own error variants, including
delegation to Printexc for its two nested-exception variants. These are bounded
dispatch rules, not a proof that a dynamic-loading error is reachable here.
Source-known registration/setter calls can be inlined: for example the raw
scan has no direct call to `set_uncaught_exception_handler`, despite GNAT's
explicit source installation. A missing raw call is therefore not used as
evidence that a registry or handler was never changed.

The fifth callback prevents closing the whole registry from the Why-source
argument alone. The installed evidence is exact:

| Evidence | Meaning |
| --- | --- |
| `Sexp_conv.entry`, `0x8702c5` loads static closure `0xe61e98`, then `0x8702cc` calls `register_printer` | Installed Sexplib0 initialization registers an additional printer |
| First word of closure `camlSexplib0__Sexp_conv__153` is `0x86e6b0` | Its code is `camlSexplib0__Sexp_conv__fun_2060` |
| That body calls `find_auto_1320` with tagged true; a successful result goes to `Sexp.to_string_hum` | The printer queries another exception-converter registry |
| `find_auto_1320`, `0x86e551` calls ephemeron `find_opt`; `0x86e592` calls the retrieved function indirectly | Matching a converter can execute a callback, before S-expression rendering |
| `add_inner_2040` stores a converter/flag pair in the ephemeron table | Initialization and later registrations matter to its callable family |

The native code also shows that `find_auto` returns `None` for an absent entry,
or for a false auto-printer flag when called by the Printexc callback. The
built-in registration iterator `fun_2098` passes tagged false; the later
`fun_2135` iterator passes tagged true. This is a useful discriminant for the
next prefix proof. **It is not an observation of the live table**, nor proof
that no relevant entry was replaced during initialization.

The expanded raw reference inventory records **21** calls to the Sexplib0
registration/query targets in addition to the five Printexc registration calls.
They include Sexplib.Pre_sexp initialization, Sexplib.Exn_magic's generic
registration adapters, Parsexp initialization, and the Sexplib0 internal
adapters. `Parsexp.Of_sexp_error.report` calls `printexc_prefer_sexp`, a query
that bypasses the auto flag, not itself a table mutator. The existing Why source
census has no `Exn_converter`, `sexp_of_exn`, or matching Sexp_conv registration
reference; the two retained plugins have no Sexp_conv symbol references in the
static inspection. Neither absence proves indirect-call closure.

The next precise registry obligation is to reconcile the installed initialization
and registration clients with the converter family for the reachable exception
constructors, including replacement and callback preservation. Exact matching
external source or a sufficient installed-code prefix argument can answer it.
This packet does not substitute a guessed Sexplib/Parsexp version or assign zero
to an uninspected indirect converter. A native capture has not been justified
by this static gap alone.

## Unwinding is not always immediately fatal

The GNAT outer handler (`gnat_main.ml:356–360`) rethrows in stack-trace mode
and for `Out_of_memory`; otherwise it formats with Exn_printer and aborts using
primitive JSON. GNAT's registered uncaught handler also uses Exn_printer and
aborts (`gnat_util.ml:12–22`). If it raises, OCaml's uncaught-handler wrapper
formats both the original and secondary exceptions with `Printexc.to_string`
(`printexc.ml:327–360`). Before invoking that handler, it attempts `do_at_exit`
and suppresses a hook exception. The previously captured once-only exit links
therefore remain relevant on exceptional routes as well as normal `exit`.

There are also intervening source handlers:

- `Trans.named` wraps exceptions in `TransFailure` unless stack-trace mode is on
  (`trans.ml:369–372`).
- `Debug.Stats.record_timing` uses `Fun.protect`; its finalizer updates primitive
  timing data and can replace an exception with `Finally_raised` if that finalizer
  fails (`debug.ml:158–172`, `fun.ml:27–38`).
- Controller `build_prover_call` catches `Sys_error` and invokes the scheduled
  callback with `InternalFailure`; `idle_handler` catches a broader exception
  when stack-trace mode is off (`controller_itp.ml:412–440,517–536`). GNAT's
  `interpret_result` prints that exception into a warning, then returns
  (`gnat_main.ml:110–114`).
- Local lookup handlers can consume `Not_found` before an outer handler is
  reached. For example, `Trans.fold` maps a failed `Wtask.find` to a cache miss;
  the weak memoizers have similar branches. A callback failure raised while such
  a handler is active must be analyzed at that handler, not assumed to skip it.

These are source routes, not a reconstructed native exception-handler stack.
The retained capture has no such stack certificate. The next control-flow
obligation is to show that the exceptions which actually escape save or exit
helpers, at eligible interruption points of this first continuing invocation,
either terminate within the accounting boundary or enter a continuation already
covered by the identifier and state-preservation argument. The handled
`InternalFailure` route must not silently extend this first-invocation result
to subsequent scheduled tasks. The missing-raw-task scenario remains excluded
by the accepted detached guard; it is not revived as a witness here.

## Disposition

The primitive rejection lemma and explicit dispatch/wrapper map reduce the
uncertainty. They do not establish an exhaustive exception family, the Sexplib
converter prefix, or preservation across every interrupted catch/continuation.
No nonzero identifier counterexample has been observed or claimed.

Accordingly **exceptional identifier charge and complete `R` both remain null**.
`B_binders = 966` and the conditional `63,573 + 2R` interface are unchanged;
63,573 is not an established endpoint. Source work can proceed on the two named
obligations without a native rerun. Full-grammar capacity, auxiliary allocation,
later invocations and whole-pipeline guarantees remain outside this packet.
