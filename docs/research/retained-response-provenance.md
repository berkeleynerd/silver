# Response identifiers after interrupted publication

2026-10-24, #119/#193. Candidate source argument, pending frozen independent
review. This closes a different question from the accepted
[parser capacity bound](retained-response-parser-capacity.md): whether an
accepted response can supply fabricated native node identifiers after failed
output. The parser's arbitrary-byte envelope alone does not establish that.
No production code, admission rule or toolchain changes here.

## Scope and source premises

Retain the selected single Why process, fresh session, no replay/manual proof,
counterexample off with the actual `get_model=None` relation, fixed registered
code, ordinary native services and sufficient physical resources. All earlier
representation guards remain necessary. The Why-only **SIGINT mask from exec**
is the explicit selected design in
[the fixed-process composition](retained-fixed-failure-composition.md); it is
not inferred from a historical capture or from the global `e<=2` allowance.
The classified returning Thread/SIGVTALRM clients do not raise an application
exception. No process allowance is renewed here.

Use the accepted source/installed-code correspondence status. In particular,
this note does not recover a missing historical tool-build manifest. Actual
launcher/source/configuration refinement remains required in #88/#89.
The response tempfile has the existing sole-writer/descriptor relation for
the Why process; its stdout/stderr are merged by the retained caller.
The external proof server's inherited destination remains distinct. Selected
external-server connection is established before scheduling and remains set;
`Prove_client.connect_internal` is not reached on this path. This condition
must not be dropped merely because its raw-file byte bound is known.

The [evidence packet](../evidence/retained-response-provenance-20261024/README.md)
retains eleven complete-file identities and exact source excerpts. It reuses
the already checked libc error-message extraction and the existing complete
exception-printer/standard-writer inventories. Its finite automaton proves
only the named lexical lemma; the source/control argument below is separate.

## Why arbitrary malformed JSON is insufficient

The driver ignores `Wait_Process`'s success flag and parses the tempfile
(`gnat2why-driver.adb:243–255`). The consumer first gets `results`, then tests
`error`, then converts `entity`, before iterating result rows. Its parser
requires the end-of-document token. Thus a purported generic implication from
bounded parsed JSON to valid native identifiers is false: a record with an
arbitrary representable but unallocated entity can reach an unchecked native
node accessor. That is a counterexample to the implication, **not evidence of
a reachable producer execution or a current production defect**.

The producer constructs the entire immutable normal record before calling
`print_json_single_line` (`gnat_report.ml:204–239`). Its root fields are ordered
`results`, `timings`, `entity`, then optional `warnings`. All native identifiers
in the result rows and the command-line entity therefore have their existing
source/registration provenance in an intact record. This note transports that
provenance across publication; it does not replace the earlier provenance
theorems for intact rows.

## Quiet entry and normal-prefix property

Both standard formatters/channels are fresh at entry to ordinary publication,
under the selected source/configuration relation. Reuse the accepted
[initial state](retained-why-standard-initial-state.md),
[writer partition](retained-why-standard-formatter-control.md) and
[diagnostic occurrence argument](retained-why-diagnostic-occurrences.md).
The extension from registration to normal reporting uses these concrete facts:

- Driver syntax-index substrings are valid numerals of at most two bytes, so
  `Printer.int_of_string` does not take its diagnostic/assertion branch.
- Masked save delivery excludes the injected `Not_found` recipient that can
  print a missing-parent backtrace; ordinary lookup maps it to `BadID` first.
- Fresh nonreplay excludes the transformation-merge backtrace; the actual
  `get_model=None` attachment excludes model-parser stderr.
- Location warnings enter a private list and debug/statistics output stays in
  private buffers. Blocking scheduling starts no editor. The external socket
  branch neither forks nor installs the internal-server exit hook.

The normal serializer has no box or break tokens. It initially waits behind
the system box only until the 78-column threshold; the largest primitive
token is at most 317 bytes. That initial queued prefix is less than 395 bytes
and fits the fresh 65,536-byte stdout channel. Once the system box drains,
every normal token is immediately drained. An active output exception pops
the current token and stops further normal serializer calls. Channel debt
retains only a prefix of that token. Consequently all normal stdout bytes,
including any debt later flushed, form one prefix of the intact normal JSON.
This does not assert the analogous property for boxed abort JSON.

During this immutable serialization the synchronous write path is
`runtime/unix.c:88–108` to `caml_sys_io_error(NO_ARG)` in `sys.c:95–102`:
ordinary errors become `Sys_error(strerror(errno))`; EAGAIN/EWOULDBLOCK become
the constant `Sys_blocked_io`. There is no pathname argument. Retained printer
dispatch rejects these primitive exceptions, falling back to the standard
representation and Why's `anomaly: ` prefix. The selected C-locale libc gives
132 nonnull fixed messages, plus `Unknown error` and the signed-int32 fallback.
The fixed messages contain no quote, backslash, JSON brace/bracket or LF/CR/TAB.
All start uppercase except `.lib section in a.out corrupted`; no blanket
uppercase claim is used. The constructor `Sys_blocked_io` is included even
though the selected blocking service normally avoids that errno case.

## At most three additional token losses

An ordinary write error can be followed by these source continuations:

1. The main handler invokes `abort_with_message` once, outside its own trap
   (`gnat_main.ml:356–360`). A failure stops that invocation.
2. OCaml attempts `do_at_exit`. The standard-formatter callback is once-gated:
   `Stdlib.at_exit` flips its flag **before** invoking it. A failure during
   its one stdout queue drain loses at most one popped text token.
3. The configured uncaught handler invokes `abort_with_message` once
   (`gnat_util.ml:12–22`). A failure stops it and goes to raw stderr fallback;
   it cannot restart either abort.

Thus, after the normal failure, there are at most **three** additional text
tokens whose uncopied suffix may be lost: one per abort invocation and one
per standard-formatter flush. A failure while an invocation drains an earlier
queued token still consumes that invocation's one loss. Repeated base
`flush_all` attempts drain existing channel debt; they neither enqueue nor
discard Format tokens. The bound is independent of `e<=2`.

Queue order is preserved. A successful reset follows a completed queue drain;
it cannot delete arbitrary material. Unexecuted serializer calls may be
abandoned. Each abort therefore contributes a token prefix, with up to three
suffix-token losses across the two aborts. Whitespace from layout can be
erased for the word-exclusion lemma below. This is a conservative language,
not an assertion that every allowed token-loss pattern is reachable.

## Finite lexical lemma and native lookup

The main abort payload is the primitive anomaly string followed by `.\n`.
The uncaught payload adds `\nBacktrace is the following:\n`, the selected
empty backtrace (or the conservatively included fixed unavailable-debug text),
and its final newline. `Json_base.print_json` sorts the three root keys:
`error`, `internal`, `results`. String characters become one-character text
tokens or two-character quote/backslash/newline escapes. Scalar `true` remains
one token. There are no Unicode escape forms in this family.

The finite automaton checks every retained errno message and abstracts every
signed-int32 unknown-error suffix by one to eleven target-neutral characters.
It checks two abort prefixes, at most three token-suffix losses, and all six
unfinished prefixes of the word `entity` at the normal/suffix seam. **None
can produce the raw word `entity`, including the two terminal raw fallback
lines and their possible byte prefixes.** Erasing optional layout whitespace makes
this exclusion stronger. The checker is a complete finite calculation over
that stated language, not a sample of native failures or a complete model of
OCaml. Its eleven source identities are checked separately.

The first nonwhitespace suffix byte, when any stdout suffix is committed,
is one of `{`, `"`, `e`, `r`: three losses cannot erase the whole eight-token
`{"error"` prefix. In particular it cannot be a digit, minus sign, comma,
colon or closing brace/bracket. A quote from that prefix cannot be immediately
followed by a colon with only three losses. These facts cover the seams:

- Before the normal root entity field, previously read JSON structure cannot
  be reinterpreted retroactively. The suffix cannot introduce the missing key
  or complete its unfinished spelling. The consumer fails before node lookup.
- If its spelling is complete but a quote/colon/value is unfinished, the
  prefix discriminator prevents a valid newly completed numeric field. A
  substituted string/object value fails the consumer's integer conversion.
- If an entity numeral is cut, the suffix cannot delimit a shortened numeral
  with a comma/closing brace. With no suffix, end-of-document rejects the
  unfinished root. If the original numeral and delimiter are complete, their
  value and all preceding results/timings remain the original values.
- After that field, any parsed result reaching native lookup retains the
  original entity and the complete preceding result rows. Altered warning
  suffixes retain the separate parser/string/schema capacity owners.

The direct fallback stderr path is terminal: no stdout enqueue/flush follows
it. Its fresh channel receives the fixed `Fatal error: exception ` prefix
before variable text. An ordinary write failure stops the fallback; otherwise
its first committed nonwhitespace byte is `F`. It cannot repair an unfinished
entity key or numeral. If it occurs inside a string after a complete entity,
that earlier entity/result provenance is already fixed. This does not claim
all stderr text is harmless under arbitrary interleaving or a different mask.

## Other phase alternatives

A failure before normal serialization takes the abort path from fresh stdout.
The root `error` key is copied before the channel can fill; it therefore
survives every later truncation that reaches that far. If the entire file
parses, either `results` extraction fails or the consumer observes `error`
before converting an entity. Changed escape context cannot remove an already
parsed root key. A partial error string is not assumed to remain valid JSON.

After normal serialization returns, `ending` computes the fixed basename and
calls `Unix.putenv`. This can raise a different exception (`Unix_error`), so
it must not be put in the active-write primitive alphabet. At that point all
normal tokens are already in FIFO/channel order. The only possible deferred
initial queue is less than 395 bytes and fits the fresh channel before any
later abort output. A committed suffix therefore follows the full original
document and is rejected by the parser's end-of-document requirement. Without
a suffix, only the original document or its prefix is committed. The same
argument covers an exit-time channel-flush failure after normal completion.

## Composition and remaining work

Subject to the explicit source/control/descriptor premises, any response that
reaches native entity/result handling preserves the intact response's native
identifier provenance; other paths fail parsing, extraction or the existing
error branch first. This justifies using the intact-row provenance in #193
without demanding an arbitrary-byte-to-live-node theorem or a new publication
wrapper. The accepted broad parser envelope remains necessary for malformed
input allocation before failure.

This does not prove automatic discharge, convert external failure into success,
or complete #119. The complete producer/report capacity guards, fixed frontend
diagnostic attachment, #194 consumers, general native compilation, variable
Why representation lifetimes and final whole-rule review remain separately
required. The actual selected invocation/mask/descriptor refinement is a future
implementation obligation, not a fact asserted about the present launcher.
