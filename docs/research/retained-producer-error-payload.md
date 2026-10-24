# Fixed-process terminal error payloads

2026-10-24 UTC, #119/#193. Candidate source refinement for the five selected
Why processes, pending independent review. This supplies a useful bound on
**every decoded string in a pre-normal failure response**, including a response
whose quote context changes after interrupted output. It does not assume that
an accepted `error` field is one intact abort operand. No tool, wrapper,
admission rule, native replay or historical-build recovery is introduced.

The [packet](../evidence/retained-producer-error-payload-20261024/README.md)
checks the exact source/input identities, the fixed input's character
projection, and the arithmetic. The source/control arguments below remain
review obligations; the checker is not a universal OCaml execution proof.

## Imported scope

Use the accepted [fixed-failure composition](retained-fixed-failure-composition.md),
[pre-cut failure census](retained-precut-failure-capacity.md),
[terminal scalar census](retained-why-terminal-diagnostic-bytes.md),
[formatter core](retained-why-standard-formatter-core.md), and
[response publication relation](retained-response-provenance.md).
Their fixed valid native JSON/Ptree, configuration/library/plugin bytes,
source/native correspondence, fresh processes, ordinary returning service
failures, one OCaml worker and sufficient physical resources are retained.
SIGINT is masked **from exec**; the classified returning Thread/SIGVTALRM
clients do not raise application exceptions. One global `e<=2` is unchanged.
The actual launcher/source/configuration refinement remains future work.

The earlier broad `R4`, aggregate/private bounds, dirty formatter guards,
diagnostic-file serializer bounds and generic response/parser bounds remain
valid and required at their original interfaces. In particular, this note
does not replace the failed-printer theorem by an assumption that registration
rejectors all succeed. It sharpens a different quantity under the full selected
resource/control relation: the bytes that can survive into a returned message
and then the response file.

For the pre-cut alternative let `P=PrecutP=max(180, |initial_cwd|+10)`.
All recorded fixed path operands have bound180; the actual cwd is still an
unbound deployment operand. Stable correct files do not require stat/open/
read/write/connect to succeed. False probes may suppress the unique valid
candidate; ordinary read errors remain failures, rather than supplying
different malformed source bytes. Fixed libraries/native Ptree use
`N_id<=467`; labels have `U<=189`. Their complete `.sexp`/`.mlw` diagnostic
files are separate private/file owners and are **not appended to the error
string**. A failed diagnostic-file service supplies a new scalar exception.

## Private buffer completion and dispatch

The distinction here is between a private diagnostic formatter and the public
channel formatter. `formatter_of_buffer` installs `Buffer.add_substring` and
an ignored flush (`format.ml:1012–1015`). Under the already required arithmetic,
slice/Buffer invariants and sufficient allocation/stack resources, these
operations have no file service whose returning I/O error can interrupt the
core. The selected pending clients neither mutate this private owner nor raise
into it. Queue/Stack operations use their safe optional-pop branches; fixed
format programs and the accepted representation guards retain their ordinary
behavior. Allocation exhaustion is not silently reclassified as successful
formatting: this refinement applies under the same physical-resource premise.

Registry rejection still occurs. `registered_exn_printer` opens the candidate
shell **before** calling the candidate and keeps that shell on rejection.
The 55-candidate corpus and these dirty boxes remain. A rejected callback gets
the original exception; it cannot introduce a different recursive argument.
The complete retained 55-entry callback corpus rejects nonmatching constructors
at its match fallback, without preceding text or breaks; the packet retains
that exact corpus and source correspondence for this inspection. Shell begins
are not output-free and are accounted for in the next section.
In the selected scalar family a matching leaf uses raw bounded strings,
integer/primitive conversions or the bounded library/plugin lists. It has no
file operation. Default Printexc inspects only direct fields, and its fixed
callback chain has no same-value recursion.
This does not require a newly guessed callback order. On an ordinary scalar,
the Why adapter rejects, Unix/Fun handle only their own constructor, Dynlink
handles only Dynlink.Error, and the accepted Sexplib automatic-default
exclusion applies. For a Why wrapper the adapter either returns its one
registered rendering or rejects before its child. For Dynlink itself the
direct Why Plugin match completes, so no outer Printexc fallback/quoted
Dynlink callback follows it. These cases use the retained complete callback
frontier, not just the visible four recursive wrapper branches.

For recursive wrappers, the precise placement of possible rejection matters:

- `Loc.Located` obtains its filename/position before invoking the child.
  A failed table lookup rejects before that child; it does not render the
  child and then retry it through the adapter.
- `BadI_rs_type` decodes/prints the original routine name before the child.
  Its optional notation helper is another private Buffer formatter. A name
  failure similarly precedes the child.
- `TransFailure` and `Located_by_marker` print their bounded prefix and a
  forced newline, then the child. Finally concatenates one inner Printexc
  result. The selected Dynlink branch constructs one inner Printexc result
  before supplying its string to the Why printer.
- After a child has returned, these matching branches do only the fixed
  close/flush/string operations covered above. They cannot fail at a later
  file service and cause that child to be rendered a second time.

Consequently a returned message contains at most one surviving child chain.
A pre-child failure can leave that branch's own prefix followed by the opaque
default of the original wrapper; the default does not traverse its child.
An unsuccessful Why-to-Printexc adapter's buffer is discarded. This argument
does not apply to channel-output failures, exhausted physical resources,
unmasked application signals or newly registered foreign printers.

Initial typing has at most two location wrappers (one can be replaced by
Located_by_marker), one BadI wrapper and one Finally. Registration instead
has at most three TransFailure layers and one Finally. Startup/config/plugin
construction is a separate alternative. These phase alternatives are not
added together. The existing scalar origin proof, rather than input validity
alone, excludes term/type/tree printers from the surviving service-error chain.

## A sharper private layout charge

Rejecting shells must not each be charged a fresh 69-byte indentation in a
returned-message bound. In the selected Format core, a processed begin can
force a newline only when `margin-space_left>max_indent` (`format.ml:320–336`).
A completed newline sets that insertion point to an indentation at most68
(`:267–279`). Further begin/end tokens do not increase it. Thus, between two
text/break events, **at most one** begin-induced newline can occur. A fits/hbox
which suppresses the break adds no bytes. Unbalanced rejecting shells do not
invalidate this argument. A raw LF inside text only makes the physical byte
bound smaller; it is not assumed to update Format's layout counters.

Charge one 70-byte layout allowance per text token, explicit break/newline,
and private-owner entry/finishing credit. Same-line breaks have width at most
one: that byte plus a following begin-induced LF/indent costs at most 70;
if the break itself starts a new line it restores the insertion point and
precludes that extra begin-induced newline. Thus two separate 69-byte breaks
are not charged to one credit. Count a copied private result once at its destination, retaining the
layout already inside that result; separately charge only new outer layout.
The following ceilings include helper-owned credits:

| Selected phase component | Layout credits |
| --- | ---: |
| Each ordinary location prefix, at most two | 16 |
| BadI prefix and optional identifier-decoder helper | 12 |
| Finally/anomaly transport and its extra successful adapter owner | 4 |
| Typing scalar leaf | 8 |
| Outer main/custom/singleton-add-file message and finishing | 8 |

Their sum is 64; another two entry credits give 66. For example,
`pp_position` has at most 12 text pieces, and its enclosing Located adds two
text pieces and one break. The identifier helper has at most six text pieces;
its returned-word branch plus BadI punctuation/newline and helper credits fit 12.
The add-file list is a singleton, so `Pp.print_list` adds no separator.
For the leaf 8 ceiling, primitive/anomaly output has two text pieces. Env's
at-most-two-component library path has three pieces including its dot;
ModuleNotFound adds three more. Sysutil.FailedResolve has at most two selected
driver candidates, two surrounding literals and a semicolon/break separator,
six credits. Plugin_Not_Found has its one selected plugin directory and four
text pieces. The full source witnesses retain Env/Pmodule/Sysutil/Plugin
printers, and callback indices19/34/54/51 identify them in the checked corpus.
In the BadI suffix-decoder case, Ident.print_sn supplies at most five pieces
and the appended suffix one; the outer word/punctuation/newline adds four,
and two helper-owner credits give 12. Without the helper that branch is smaller
(`ident.ml:93–154`, `pretty.ml:1015–1018`).
Registration's three small transformation prefixes need fewer credits.
Connection/config/plugin construction likewise has fewer than 66; it is not
nested inside the typing/registration maximum. No 55-fold layout term remains
at an unchanged insertion point.

## Text, alphabet and primary/secondary messages

Let

```
L(P) = max(4096, 4P+3072).
```

This bounds a surviving scalar leaf, including its own anomaly/transport text:

| Origin | Text bound before the common L ceiling |
| --- | --- |
| Sys_error | `4(P+51)+32`, allowing `%S`, constructor and anomaly |
| Unix_error | `4(P+467)+96`, for its one path and fixed function name; its symbolic errno is bounded separately |
| Fixed primitive/default | `467+4*467+3*68+32`; at most one direct fixed string, with spare scalar-field credits |
| Loader Failure through selected Why Dynlink branch | `4(P+512)+128`; no outer Dynlink `%S` callback follows a successful Why match |
| Other fixed initializer scalar through Dynlink | maximum of the primitive/Unix rows plus128 |
| Generic connection | accepted `4P+2048`, plus its 18-byte Why prefix |
| Direct connection/config/driver/library/plugin/label | accepted scalar transports, bounded fixed lists, `U<=189`; all below L |

Constructor names/static primitive text use the accepted fixed ASCII resident
bound467. A primitive failure is not an arbitrary constructor with three
independently large string fields. Unix's distinct registered printer and
Dynlink's distinct selected branch are accounted for explicitly. A primitive
fallback for an opaque failed wrapper remains below L. The one-level
ConfigFailure/Pmodule message construction is a separate startup case.

Returned messages contain only printable ASCII plus the ordinary LF/CR/TAB/
backspace/form-feed escapes. The packet checks every string in all five exact
native inputs and every recorded pathname operand. The selected library/name
and literal origins retain their ASCII source relation. The sole unrecorded
cwd can contain arbitrary non-NUL bytes: its reached error transport is the
Sys.chdir Sys_error inside the **generic** connection handler, whose Printexc
`%S` converts nonprintable bytes to ASCII escapes. It is not printed as a raw
location filename or socket name. This is an origin argument, not an ASCII
restriction on cwd. Therefore JSON contributes at most **two bytes per message
byte** on this selected family. No analogous claim is made for arbitrary Main.

Allowing both location prefixes, BadI, Finally, outer filename/context and
the 66 layout credits gives the conservative primary-message ceiling

```
Q(P) = L(P) + 2(P+128) + (467+52) + 29 + (P+128) + 70*66
     = L(P) + 3P + 5552.
```

For failure before entry to main's protected body there are no typing or
registration wrappers. Config conversion and the three sequential built-in
Pmodule initializers do not nest each other. Their fixed extra text, private
layout and uncaught-handler ending fit the smaller

```
Qearly(P) = L(P) + 1536.
```

After the first abort starts publication, a channel-output failure is a new
`Sys_error(strerror(errno))` with **NO_ARG**, or Sys_blocked_io. It does not
include the previous JSON or original exception. Its selected libc text is
at most 49 bytes and contains no quote/backslash/control characters. The main
or custom private message, including its final punctuation/backtrace heading,
is below 512 bytes. A retained outer label Failure handler can instead supply
`U+256<=445`, also below 512. Pure message construction cannot restart the
primary chain under the completion argument above. Exit-time private file
flush/close errors are likewise NO_ARG channel errors. The existing no-resume
proof prevents abandoned abort output from returning to successful registration.

Retain **four** abort attempts as the conservative pre-cut maximum and both
once-gated standard exit flushes. There is at most one Q-sized original
message; the other at most three payloads have ceiling 512. Main's handler is
outside its own try, so a failure of its abort goes to the uncaught handler as
a secondary error. Inside-main original errors therefore cannot reach the raw
fallback unchanged after their primary publication attempt.

There is one important alternative: an original exception before main can
reach the custom uncaught handler directly. If that handler's output fails,
the raw fallback prints the **original** exception once more. Charge this
using Qearly, not512. Its second conversion is the handler's secondary error.
The fallback cannot restart the custom handler. This distinction is necessary
even though every intact main/custom message ends with LF.

## Malformed publication and the consumer

Import the parser packet's already established merged-byte lemma

```
Ymerged(T,a,q,D) = T + 69*(10a+q+4) + q+2 + D.
```

It permits failed text-token suffixes, dirty standard formatters, arbitrary
channel interleaving under the descriptor relation and incomplete roots.
Use `a=4`, conservatively retain the initial driver's `q=1` and 64 text bytes,
and 42 syntax bytes per abort. The accepted quiet-entry/continuation result
can reduce q to zero, but is not needed for the displayed pre-cut bound.
For inside-main originals, `D<=2*512+253`; for before-main originals,
`D<=Qearly+512+253`. The 253 retains both fixed fallback lines, selected empty/
unavailable-debug backtrace allowances and the OOM fallback allowance.

```
Hinside(P) = 2*(Q(P)+3*512) + 4*42 + 64
             + 69*(40+1+4) + 3 + 2*512 + 253
           = 2*Q(P) + 7689
Hearly(P)  = 2*(Qearly(P)+3*512) + 4*42 + 64
             + 69*(40+1+4) + 3 + Qearly(P)+512+253
           = 3*Qearly(P) + 7177
H(P)       = max(Hinside(P), Hearly(P)).
```

These are prospective offered-byte bounds, hence also bounds on the newly
created merged response file under the accepted write-prefix service relation.
Every tokenizer-accepted decoded string has at most its encoded input bytes,
including UTF-8 output from Unicode escapes. Consequently **any** decoded
error string, altered value, duplicate/reassembled key or other accepted
string is at most H(P), regardless of changed quote/escape context. The proof
does not bound token-loss count, presume a trailing LF survives, or pretend
arbitrary JSON is reachable. The older broad parser bound still covers
allocations before parsing/extraction fails.

| Actual supplied P | Q | Qearly | H |
| ---: | ---: | ---: | ---: |
| 180 | 10,188 | 5,632 | 28,065 |
| 416 | 11,536 | 6,272 | 30,761 |
| 558 | 12,530 | 6,840 | 32,749 |
| 559 | 12,537 | 6,844 | 32,763 |

Thus `P<=558` is a nonempty sufficient region for `H<=32760`. This is an
evaluated configuration function, not a claim to know the historical cwd or
permission to relocate it. Preserve the successful-prefix invocation relation
and all earlier guards. It is materially different from conjoining the
coarse minimum `Xpre>=33,227,168` with a 32KiB buffer cap.

## Post-cut scalar alternative

To include failure after registration but before normal publication, supply
`P=max(PrecutP,Ppost)` from the actual two pathname providers and the accepted
canonical proxy-line relation `M<=P+48`. In particular the result directory,
temporary requests, save/backup paths and FileTags inputs remain explicit;
they are not inferred from the fixed pre-cut path projection. Import R63's
preparation trap, which drops InternalFailure's payload, and the accepted
quiet-continuation proof: valid driver indices, mask-from-exec, fresh nonreplay
and actual get_model=None eliminate the relevant standard diagnostic/warning
writers. Thus `q=0`, two aborts and their once-gated exits cover this phase.

Here the terminal chain has at most one Located and one Finally. Its text and
at most 32 layout credits fit

```
Qpost(P) = L(P) + P + 3072.
```

The earlier ASCII argument is not imposed on new proxy paths or unknown
FileTags. Conservatively retain InvalidAnswer's complete canonical line,
although the valid response grammar can make that branch unnecessary. Its
raw byte operand is at most M. The failed file-contents helper's raw path is
an alternative leaf of length at most P, covered by M because the bound can
be enlarged to `M=P+48`; the optional Located filename adds at most P.
Thus take the line ceiling `M=P+48` for arithmetic and allow at most `M+P`
raw bytes requiring sixfold JSON escaping. Other native path errors pass
through Printexc `%S`; primitive/static strings retain their ASCII origin.
Above the ordinary twofold payload charge, add `4*(M+P)`.

An inside-main primary abort is followed only by the secondary 512-byte
family. There is no before-main Qearly fallback in this phase. Substitution
into the same merged-file lemma gives

```
Hpost(P,M) = 2*(Qpost(P)+512) + 4*(M+P) + 2*42
             + 69*(20+0+4) + 2 + 2*512+253
           = 2*Qpost(P) + 4*(M+P) + 4043.
```

At P=416 and M=464 this is 24,011. More generally, using M=P+48,
`Hinside-Hpost = 8414-4P`, nonnegative throughout the displayed P<=558 region.
The same H therefore covers both pre-cut and post-cut pre-normal alternatives.
They spend one process lifetime's budget and are alternatives, **not** two
successive allowances. No fixed-label/filename envelope is transferred to
arbitrary Main, and no unvalidated server stream is given the canonical M.

## Interrupted normal publication

A mixed normal prefix and abort suffix is a different phase. The whole file
can exceed H. Import the response-provenance proof's exact normal-prefix/FIFO
property: the serializer has no boxes/breaks, its initial queued prefix is
less than395 bytes and fits the fresh channel, and after it drains every text
token drains immediately. A failed active write pops its token and stops
further normal serializer calls. Remaining channel debt is a prefix of that
token and precedes any later stdout bytes. There is no later normal token
behind the aborts.

The active-write exception is the NO_ARG primitive family above. Its main and
custom abort messages are each at most512, and direct fallback is at most
`2*512+253`. The same dirty-standard layout lemma with two aborts and no
diagnostic writer gives a bound on **all later suffix bytes**:

```
Hsuffix = 2*(2*512) + 2*42 + 69*(20+0+4) + 2 + 2*512+253
        = 5067.
```

The immutable normal root has no `error` key: its fields are results, timings,
entity and optional warnings. JSON tokenization/parsing is sequential, and
future suffix bytes cannot retroactively change a completed prefix token or
container context. If a root error value had begun in the normal prefix, its
complete key and colon would already be there, contradicting that normal
root shape. A hybrid key can start before the cut (for example an unfinished
`e...` spelling), but any resulting root error **value begins in the suffix**.
Its decoded string is therefore at most 5067. This does not assert that such
a hybrid key is reachable, or bound earlier normal warning/result strings by
5067. The raw fallback is terminal: no later stdout debt is flushed after it.

After normal serialization completes, a failing ending/putenv can instead
produce Unix_error, which is not assigned the active-write alphabet. At that
point the whole normal document is already FIFO/channel-ordered. Any committed
suffix violates the parser's end-of-document check; with no suffix there is
only the original document or an incomplete prefix. The accepted provenance
argument owns that separate phase. Together these alternatives cover the
selected response's terminal error operand without renewing any lifetime
allowance. Since 5067 is below H on the displayed region, H remains a valid
common error-tail bound; it does not become a bound on every normal response.

GCC Output.Write_Char prechecks its 32767-byte buffer, and LF calls Write_Eol
after that precheck (`output.adb:423–436`). Compiler_Abort's first error slice
has at most 70 bytes. Its remaining suffix begins after the five bytes `|    `;
End_Line appends `|` then directly calls Write_Eol. H<=32760 leaves space
for all seven bytes even in the conservative case of no surviving LF. LF only
resets the buffer earlier. Therefore the report helper may retain the broad
total error allocation bound while attaching `error_tail_bytes=H(P)`; the
same H also bounds the actual decoded total on these phases. Source-name dumps,
version/target strings and other bugbox operands remain their own owners.

This establishes a conditional selected fixed-process attachment. Concrete
post-cut path/server-line bindings, arbitrary Main failure payloads, actual invocation
refinement, native compiler/report capacities and complete #119 assurance
remain separate unless their exact providers are joined. Failure while
reporting failure is still failure, not successful proof or successful output.

Selected author setting: GPT-6 Astra / Extra High. Runtime model confirmation
and token/cost telemetry are unavailable. No native/proof run was performed.
