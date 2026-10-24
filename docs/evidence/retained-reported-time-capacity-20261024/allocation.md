# Additive startup and later constructor charges

This is a source/native derivation for the exact prospective recipe in
`recipe.json`, under R78's successful ordinary prefix, source correspondence,
physical resource and native-runtime premises. It uses the separately
reviewed native freeze `6cc4c72f63` (root review `35a5bea549`): Start construction
128 words, its later first force512, each search256, and the different fresh
placeholder construction/forced failed search4096. Words include block headers.
Those native providers exclude common runtime/collector and physical-stack
owners. This derivation retains that boundary.

## Cut, source trace and finite grammar

Place a local cut at entry to lexing each private common file, **after its
existing channel and lexbuf have been established**. R78 has the same57 initial
driver-open occurrences per fixed layout. The recipe changes no filename,
resolver candidate, opening, descriptor or channel-owner multiplicity. Do not
count a hypothetical extra open/close path and then discard its custom/native
effects. We charge the complete new common file's lexing/parser operations
three times as extra work, while retaining all old prefix credits; we do not
subtract the old parse. This handles changed refill alignment after the
one-byte edit. Existing channel and lexer backings remain their existing
owners. The new4018-byte input does not make any lexeme exceed their fixed
backing: the longest quoted source is121 bytes, decoded length no larger,
and the longest non-string lexeme is shorter. Lexlib scans quoted contents
incrementally; its128-byte Buffer never grows on this file.

The finite byte census has412 non-EOF tokens,72 string literals and comment
depth1. It implements the special `(*)` comment rule; treating it as a nested
comment would be wrong. The checker only counts this fixed file. It is not
execution of an installed lexer/parser or a universal grammar test.

The grammar branches present here are global prelude/unknown/time/valid,
theory, syntax type/function/predicate, remove prop/allprops, and metadata
with a single type/function/predicate argument. Qualified identifiers have
ordinary identifier components; rich operators use the fixed parenthesized
operator or bracket forms. There is no extraction grammar, nested type,
syntax-literal argument, integer, plugin, blacklist or imported file inside
this common file. The source `driver_parser.mly:45–194` gives this reduction
accounting:

| Fixed production family | Reductions charged, including enclosing lists |
| --- | --- |
| Global |3 per directive: global, location wrapper, outer list |
| Simple qualified identifier |5 for its last ordinary/rich component;2 for each preceding dotted component; bracket operator adds at most1 |
| Syntax rule |1 syntax flag + qualified identifier +3 for rule/location/list |
| Remove all / remove prop |3 / qualified identifier +3 |
| Metadata function/predicate |Qualified identifier +6 for argument, separated list, meta_args, rule/location/list |
| Metadata simple type |Qualified identifier +8, additionally empty type-argument list and type application |
| Theory |2 per name component, plus4 for name location, empty rule list, theory and outer list |
| File boundary |Empty outer list and file reduction, charged with the extra EOF unit |

Giving **16 reductions to every token plus EOF**, even punctuation and string
tokens, covers this forest and its boundary reductions with ample duplication.
The largest listed statement charge is13 for a simple type metadata rule,
which itself consumes at least four terminals. Qualified/operator additions
consume terminals and carry their own16 credit. The common file is an
**imported token segment in multifile's single parser stream**, not a fresh
standalone parse. `multifile` suppresses its EOF, pops its lexbuf and resumes
the parent. The insertion is between existing globals, after the second unknown
rule and before the valid rule. There the grammar expects `list0_global_theory`;
consuming another `loc(global)` leaves that same list-start control state with
one pending located-global cell. Three repetitions add three such cells. The
next old token consequently has the same control state and location as before
(up to the raw-offset relation), with only these deeper pending cells added.

Old-token LR transitions above that deeper stack suffix are unchanged.
Semantic actions inspect/pop the fixed arity of their production, not the
length of the underlying stack. At the actual root EOF, the three additional
`loc(global) list0_global_theory` reductions are charged to the inserted globals.
Each old global/theory-list reduction still allocates the same-size cons/file
record, although its f_global value now includes the new entries; it does not
traverse the longer list. Thus the remaining root stream and final unwind have
the same old-token allocation projection plus charged extra cells/reductions.
Common-file reductions delayed beyond its lexbuf EOF are charged to their
owning productions. No uncharged tail rescan or stack-array growth follows.

Let n=413:412 tokens plus a conservative **boundary credit**, not an assertion
that the common-file EOF reaches the parser. Bound reductions by16n=6608,
and successful parser transitions by
`16n+2n=7434`, adding a shift and input/offer transition for every terminal.
Reductions triggered by a following root token are charged to the production
they complete. Existing subsequent token actions have the same dimensions;
the longer heap stack does not cause an array resize or a native stack scan.

## Installed parser allocation and classification

`parser-native.json` binds complete byte intervals for Driver_parser and the
Menhir Engine, TableInterpreter, PackedIntArray, RowDisplacementDecode and
Convert modules to the same installed ELF as the native regexp provider.
The corresponding text is retained. Summing **all** immediate minor-pointer
bumps in their non-entry bodies, including mutually exclusive and unused
branches, gives1044+362+180+11+0+32=1629 words. This is deliberately much more
than one path's allocation. Module initialization is unchanged and not
repeated by these added tokens.

A successful elementary transition is one `loop_inner_1036` pass taking
input/offer or resuming a shift/reduction checkpoint. It runs Engine dispatch
and at most one semantic action. The retained call families are:

| Pass | Selected dispatch before the next loop pass |
| --- | --- |
| Input | Supplier/token conversion, `offer_541`, `discard_404`, default/action lookup, then shift or reduction announcement |
| Shift resume | `resume_inner_1012`, `run_403`, then input-needed or default/action lookup and a checkpoint |
| Reduction resume | `resume_inner_1012`, `reduce_409`, TableInterpreter `semantic_action_547` and exactly one generated action, goto lookup, then `run_403` and a checkpoint |

`announce_reduce_408` returns the reduction checkpoint; it does not execute
the next reduction recursively. Loop-back edges in `loop_inner_1036` start
the next charged pass. Error/inspection/undo/table-construction helpers in
the retained intervals are not selected; functor construction and module
entry are not repeated. Each allocating selected body has at most one entry
in the pass; the two-traversal allowance also covers splitting a boundary
pass between input/return wrappers. A following shift/reduction is another
charged transition.
Table lookup helpers can be called repeatedly, but selected packed-array get
and row decoding allocate nothing. The ordinary action/goto/default wrappers,
checkpoint loop and token conversion do not revisit an allocating body in an
unbounded local cycle. Two traversals of the entire overinclusive body set
cover the dispatch/return wrappers, not merely the largest semantic action.
The retained parser has no selected trace/error-recovery output path.

External actions for this file are `Loc.extract`/existing FileTags lookup and
operator-name construction from at most the fixed short operator spelling.
The former constructs a four-word location; existing-name lookup allocates no
cell. The latter constructs fixed-prefix strings, far below128 words even
charging their copies and application wrappers. Source grammar actions build
only short records, conses and these strings. The five-field Engine sentinel
dummy is also small; allowing it per transition only overcharges its actual
once-per-root creation. There is no call to the dynamic PackedIntArray packing
constructors on lookup. Thus `2*1629+128=3386 <4096` words bounds one transition.
The4096 coefficient follows this source/control and native-body argument; a
sum of disassembly bumps by itself would not establish it.

Native `shift_407` allocates15 words containing a **five-field linked stack
cell**, an environment and a checkpoint. `reduce_409` allocates a five-word
environment plus its semantic action. The selected TIME action at
`fun_5450:5cfdc0` allocates eight words: TimeRegexp and a replacement stack
cell. The located action constructs a location/pair/cell; the source global
list allocates cons and file record. None uses a growable parser stack array.
The full parse overcharge includes the extra TIME/STRING productions and
all such stack cells.

Separately charge lexing by

`17*(4018+1) + 128*(412+1) + 512 = 121699 words`.

The17-per-byte allowance is the retained direct-lexer upper bound of two
six-word tuples and one five-word position, charged over the whole candidate
file and EOF, rather than only the changed line. Table-generated lexing is
no larger. Per token,128 words overcharges the128-byte Buffer record/backing,
at most121-byte contents copy, token/lexeme wrappers, and keyword lookup;
non-string tokens are charged the same. The512-word per-file allowance
overcharges small control/refill position records. No extra file-open/custom
channel allocation is claimed here. Refills use the already established
buffers and input channel; crossing a different boundary adds neither a new
buffer owner nor a larger lexeme. Every named block has payload at most256
words. This is a bound on each **individual** request, not a claim that a
121699-word block is allocated.

The accepted placeholder kernel has maximum individual payload128 words;
Start construction is73 actual words inside its128 credit. Its search lazy
is unforced until a result arrives. The Call/substitution wrapper is bounded
by64 words per record: Call's native9+5+3=17 words for refs/closures/record,
global_substitute's seven-word closure, two-byte substring's two words,
two singleton list cells (six words), and both timing-list spines (six words)
total38. The empty array uses the zero-length runtime case; no unit callback
runs. The native bodies, singleton String.concat return, and empty Array.iteri
are retained for this attachment.

Consequently the added **successful-prefix** charge is

```
parser/file = 7434 * 4096                       = 30449664
lexer/file  = 17 * 4019 + 128 * 413 + 512        =   121699
three full candidate parses                    = 91714089
nine (placeholder + Call/list + Start shell)    =    38592
D_start.minor                                  = 91752681
```

Until a hypothetical first collection all added blocks are young; payloads
at most256 select the minor allocation route. Lexer/parser environments,
location values, driver accumulators, buffers, regexp shells/lazies/tables
and their mutable scratch are all created after the protected startup boundary.
No new FileTags name is inserted. The only shared regexp-result store reached
by the new placeholder search writes immediate None to Str.state. Start
construction neither forces a lazy nor publishes a Group. New young-to-young
stores add no remembered entry; existing matched stores preserve their
generation relation under no collection. There is no new ephemeron, custom
block, dependent allocation, foreign buffer/descriptor, or resource-fraction
request. Thus all remaining D_start resource components are0 on this prefix.

## First event, cut-C attachment and native stack

The largest R78 minor bound becomes
`135521724+91752681=227274405 <268435456`, leaving41161051 words. Major history,
remembered, ephemeron/custom, dependent and resource-fraction components keep
their accepted values. The8,250,999-word contiguous major remnant is unchanged
by these minor requests. Together with R78's absence of new explicit GC,
profile hook or asynchronous callback before this cut, these inequalities
exclude the first extra collection/expansion. The young-owner classification
and semantic constructor relation are established jointly by this first-event
induction, not assumed after a collection. The maximum managed/static carrier
in the cut-C extension is237,953,393 words.

`transfer.py` consumes the exact baseline entry-envelope object and the
seven-file configuration fingerprint. It adds D_start to minor/history/carrier
fields, recomputes owner request/counter/backing bounds and guards, preserves
the baseline's actually populated state interpretation, and exports the nine
new unforced timing owners. It never calls the baseline provider with the old
configuration name and silently relabels its old numeric answer. Its retained
baseline projection is the concrete output of the frozen provider function,
not a captured process state or a synthetic counter initialization. The old
provider's source restriction and review remain a separate dependency.

The native stack premise remains sufficient physical stack for the selected
runtime. The new fixed constructor chain requires
`S_Call + max(S_placeholder, S_Start_parse)` at its existing driver caller;
the source/native fixed paths define these stack owners. Menhir's linked heap
stack and tail checkpoint dispatch do not accumulate native frames with the
extra tokens. Lexlib has comment depth1 and tail string/token loops. The
regexp parser inputs are2/6 bytes and the placeholder compiled tree has14
expressions; its loop/scratch cardinalities are the accepted tiny kernel.
There is no new recursive depth depending on Main, output length or T. The
three grep_time fallback entries also tail-jump in the installed handler.
This is a fixed additional stack requirement within the retained sufficient
stack premise; it neither equates captured stack bytes nor supplies an
aggregate physical stack/RSS fit. Native providers' common-runtime exclusions
remain explicit.

An interrupted/failing constructor is a prefix of these charged operations.
New parser locations remain in the fixed source file/line/column domains;
known patterns introduce no dynamic malformed-regexp message. Physical I/O
and resource failures retain R78's terminal diagnostic and runtime providers.
The successful-prefix no-GC result is **not** applied to diagnostic/exit
processing: if those paths collect, their existing collector/physical owner
accounting must use the enlarged entry carrier. No time record turns a failed
attempt or incomplete obligation into success, and no save allowance renews.

## Later calls

Let p count entry to parsing an authentic server `Finished` record, including
abandoned or interrupted calls. The ordinary-file branch performs at most three
timing searches per entry; the empty-filename cancellation branch performs none.
Thus q<=3p. Parsing precedes construction of `ProverFinished`, and a complete
server batch is mapped before its results are buffered (`call_provers.ml:478-559`).
An interrupted parse or batch may allocate searches without delivering a result;
the previous q<=3T bound in terms of delivered results is superseded.

Independently, let f count entry to the controller `ProverFinished` arm before
`Opt.fold fuzzy_proof_time`, including queued cancellations and a body interrupted
before `Done` (`controller_itp.ml:448-486`). Each arm entry calls smoothing at most
once and can allocate at most one additional seven-word result copy. Neither
successful delivery completion nor absence of an old result is assumed. No
relation between p and f is required.

For o<=9 owners the additional post-C source-owned allocation is
`512*o + (256+10)*q + 7*f`. The first two native terms come from the reviewed
Start provider; the ten-word grep wrapper and seven-word possible fuzzy copy
are attached to their installed bodies. `transfer.py` takes independent
`parse_entries` and `finished_results` inputs. The latter means controller-arm
entry, not completion. `later-allocation-cases.json` includes a queued-only
p=1/f=1/q=0/o=0 case requiring seven words and an interrupted parsed prefix
p=1/f=0/q=3/o=0 requiring798 words. A failed/cached lazy can be retried without
another signal, but q counts that call. The nine construction and placeholder
charges were already included once in D_start.

After C, lazy/cache/table/global stores may target promoted owners. The zero
new-remembered-entry startup result is not reused there. The existing general
runtime/GC and later-call storage owners must consume this new allocation
trace, q and the native tiny-owner mutation inventory. Str.state can keep the
whole raw input reachable until replacement; its bytes belong to the existing
raw-input owner even though the match length is zero. This interface supplies
new constructor demand; it does not purport to close #201/#202 or whole-process
storage, native runtime work or collector copying by itself.
