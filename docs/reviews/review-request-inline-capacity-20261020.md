# R56 review: startup, request storage, filenames and first-inline capacity

2026-10-20 UTC; independent bounded #119 / #153 review on Linux x86_64.
Selected reviewer model/effort: **GPT-6 Astra / Extra High**; runtime confirmation
and isolated token/cost telemetry unavailable. No subagents were used.

Base: R55 reviewed integration `d2bab81f4e`. The reviewer owns only this report
and its [evidence packet](../evidence/retained-request-inline-capacity-review-20261020/README.md)
in the isolated `review/request-inline-capacity-20261020` worktree. Predecessor
evidence is reused without replay. No native target, capture, compiler, solver
or proof run is part of this review.

All four components are accepted at their stated conditional interfaces:

| Component | Exact author freeze | First focused reviewer check |
| --- | --- | --- |
| Request allocation / receive backing | `a4a4bd821d36db91c7ee7e7a8403eb85dd500026` | pass, 0.133 s |
| Combined startup | `92e0cd50acd9ff21f5350dcda89ac99584defecb` | pass, 0.519 s |
| Filename / request bytes | `99b8d71c4d80afb12006237b49a4f6c9c9ad8f53` | pass, 2.659 s |
| Fixed first-inline family | `240b1ca101ec63a332b416469e721d940b527c3b` | pass, 10.963 s |

Times are subprocess wall times, not native target timings. The evidence packet
retains commands, outputs, internal timings and author-packet identities. Every
packet was unchanged by its check. No successful check was replayed. Exact
inputs and local imports are recorded in `inputs.json`.

## Stock request allocation and receive backing

Accepted author freeze `a4a4bd821d36db91c7ee7e7a8403eb85dd500026` after the
data-backing and per-entry ownership wording repairs. The first focused check
passed ten source excerpts, 1,792 installed instruction bytes and 61 receive
growth boundaries in 0.133 s subprocess / 0.094 s internal time, without changing
author files. Four supplemental source excerpts retain the constant/initial
capacity, control-record and free-request details independently inspected here.

The valid-stream premise is essential: exact `run`/`runstdin` or interrupt
headers, intact represented IDs, fixed zero numeric fields, and no delimiter,
LF or NUL inside a field. `runstdin` includes its last input filename in m>=1
arguments. A write may fail partway, but its connection must then close before
another line is appended; an already delivered owner cannot be retried as new.
These are prospective proxy obligations, not properties established by this
source packet. Malformed front-side input remains outside its bounds.

For a run line of L bytes including LF, the parser makes m+5 copied strings.
Its m+4 semicolons and final LF are replaced by exactly m+5 NUL terminators,
so the cumulative copied-string requests sum to L, including freed temporaries.
The installed run/interrupt request allocation is 56 bytes, and the argument
array uses eight bytes per element. Thus a run contributes L+56+8m requested
bytes in m+7 calls; an interrupt contributes 11+d+56 bytes in three calls.
The R55 count join gives 57,714 fixed bytes and 4,590 fixed calls in the stated
aggregate formulas. This charges all created payloads, so cancellation or
disconnect leaks cannot invalidate it. Normal run ID ownership transfers to
the process record without another string copy.

Each run reaches `create_process` at most once. Native code computes the signed
count+2 before multiplying by eight; m<=INT_MAX-2 and the size-product guard are
therefore relevant. The selected stdin path decrements m only when m>=1.
The cumulative parent argv bound is conservative. Child copy-on-write pages,
fork/exec stack, allocation overhead and other structures remain separate.

I independently checked READ_ONCE=1024 and client initialization with that
capacity in the pinned source. After complete-line removal, the pending prefix
has at most M-1 bytes; one read adds at most 1024. Actual growth follows the
sequence c=1024, c'=2(c+1024). If a growth occurs, its previous capacity is below
M+1023; consequently the first sequence element reaching M+1023 bounds every
selected capacity. Charging twice that element covers old and new data backing
during a moving realloc. The t_readbuf control record needs a separate charge,
and the sum must use the actual number of backend connection owners.

M+1023<=INT_MAX keeps the size_t-to-int conversion and message scans in range.
A final LF advances cur only to max, and a final copied field requests at most
the line length, so no hidden INT_MAX+1 endpoint is needed. Valid field/count
relations bound the semicolon and argument loops. The additional conservative
next-growth and argv-product guards cover size_t arithmetic. These are checked
natural-number preconditions before native conversion, not justification for
parsing arbitrary oversized or concatenated malformed lines.

Receive-byte preservation still depends on the existing exact-native overlap
bridge for `have_taken`'s memcpy; capacity arithmetic does not repair its generic
C contract. Read/allocation services, container preservation and fixed owner
counts remain conditional. The formulas cover allocation requests and data
backing, not all physical memory or q. No filesystem pathname bound is inferred
from the unrelated qualified Why3 identifier-path bound.

## Combined quiet/timeless, J12 and logging startup

Accepted the corrected startup freeze after replacing the inaccurate
"historical serial maximum 2911" wording with the specific earlier Put_Line
arena history. This repair changes no calculation. The first focused check
passed 212 checks, 15 source witnesses and 27 accepted input-freeze joins in
0.519 s subprocess / 0.479 s internal time.

This component attaches the exact 2,069-byte quiet base and six-file timeless
overlay to R53's ordered J12 input roles, preserving path spellings and adding
only R55's single logging option. Local import paths are shorter than their
installed counterparts. The prospective proxy wraps commands after Why
serialization; this startup configuration does not insert the adapter into the
Why command. The claim retains the inherited Re behavior and source-to-native
correspondence premises; it does not newly identify a historical Re build.

The quiet/time edits follow the same forced Re startup collection. Logging's
four extra argv words leave precollection demand at most 3,312 words, far below
the 2^28-word nursery, so they cannot cause an earlier collection. The actual
J12 startup promotions are 2,904 / 2,920 / 2,908 / 2,923 / 2,908 words; these
replace the earlier serial history in the arena accounting. The captured
startup relation `stat_major_words == stat_promoted_words` excludes an omitted
pre-counter direct-major contribution. The largest original current-major
allocation is 945,213 words; the possible extra FileTags name uses N'<=945,214.
Adding the R52 construction credits and R55 logging credit yields at most
8,526,217 total major words against an initial 2^24-word arena. The minor,
remembered-table and FileTags-table margins are checked separately.

The source correction matters: phase 0 is mark, not idle. The forced minor
collection reaches a major slice from idle, starts the cycle with p=0, and
returns without executing `mark_slice`. No later selected slice can sweep or
reclaim free-list blocks under the inherited service exclusions. Initialization
starts with one contiguous free block; each of the three allocation policies
splits that remnant. The total bound leaves at least 8,250,999 contiguous words,
excluding both tiny-remnant handling and a first arena expansion. Allocation
color is chosen after block selection. `Obj.truncate` makes a black Abstract
remainder inside an allocated block, without returning it to the free set.

I also checked the runtime's oversized-unmarshal exception: `intern.c` creates
an additional heap/free-block region only when `wosize > Max_wosize`. The
bounded successful-prefix demand is below the initial arena, itself below that
runtime maximum, so this path is excluded too. Supplemental excerpts retain
that condition and its accounting. Candidate FileTags tables/buckets remain
young with no subsequent collection; the logger's overwritten stdout value is
non-scannable custom storage. Thus these stores introduce no extra old-major
darkening service. The actual comparison cut is registration, and reusing the
larger earlier post-CE credit is conservative.

This establishes the bounded conditional source attachment for the combined
startup. It is not an executed configuration, a launcher implementation, or a
complete allocation/stack/counter guarantee for subsequent processing.

## Goal filenames and serialized request operands

Accepted the filename successor after its D/P indices were aligned with the
actual zero-based protocol design (0..4 / 0..2). All spellings remain one byte;
the retained projection and numeric bounds are unchanged. The first focused
check passed 161 raw-label joins, 14 driver/import files, 97 source slices, the
535-member ML/MLI inventory and 11,016 wrapped serializations in 2.659 s
subprocess / 2.609 s internal time. The author's earlier check remains recorded
as historical; this is the first reviewer run on the corrected freeze.

The source-origin chain supplies the filename that the native location table
did not capture. Each exact JSON input has one program-domain function `def`
with its documented source filename and line. The conversion appends ATpos;
typing uses that position in preference to the dummy parse location. The
routine identifier retains it and VC generation appends `'vc` to `def`.
All native labels agree on `def'vc`, line and column. File tag 50 alone is not
used as evidence of the filename string.

The whole FileTags insertion must complete without unwinding: Hstr insertion,
Hint insertion and counter increment. Otherwise a caught intermediate failure
could reuse a tag. Under that guard, immutable strong-map keys and valid 64-bit
representation, each distinct retained filename requires at least 16 bytes.
Even the full byte address space holds at most 2^60 such keys, below the 2^62
signed-counter wrap. This is a local persistence argument, not a bound on all
shared counters or heap demand.

I checked goal-header preservation across the selected transform union,
including CVC5's possible polymorphic encoding branch. Declaration maps retain
kind/pr; discrimination may clone pr but preserves its name and default
location. Auxiliary propositions remain axioms. Goal-aware task memoization
and Introduction's special declaration equality preserve this same header.
No Z3-specific monomorphic identity is assumed for CVC5. The filename uses
the retained source basename, theory `T`, and `defqtvc` after sanitizing the
apostrophe. Its fixed suffix is 24/25 bytes for IO and 31/32 for Arguments.

The fresh noninteractive path calls `open_temp_file "why_" ("_" ^ filename)`.
Its six-hex-digit random component has fixed width on every retry. With the
selected nonempty TMPDIR and no trailing slash, F=tau+12+filename bytes.
The complete Why source inventory has no independent temp-directory setter;
the fixed environment/runtime-route premise remains necessary. Tokenization
precedes `%f` substitution, so it cannot increase argc. Each selected ordinary
command contains a final `%f` and uses `run`. Time values `0.` and `1.` have the
same two-byte width with LC_ALL=C.

The original run length is 10+d+argc+argv payload. The wrapper adds ten entries
and A+55+d bytes, counting the ID twice. Wrapped argc is 14/15/15 and parser m
is 13/14/14 for CVC5/Z3/Alt-Ergo. Domain maxima for the original route are
A+tau+[150,150,155,153,153], and for quiet CVC5 are
A+tau+[273,273,278,276,276]. Interrupts fit these maxima. Actual operands must
satisfy the delimiter grammar and natural-number parser guards; the source
serializer provides no escaping.

Raw backend P_b=C+11 depends on the actual server `getcwd` string, with C+12
bytes allocated including NUL. That historical C was not captured. Canonical
P_c=len(R)+24 and adapter A remain prospective configuration operands. None is
derived from the unrelated qualified Why identifier-path bound. These results
can instantiate request/response storage formulas once those operands and
stream-owner requirements are attached.

## Fixed-family first inlining

Accepted at the semantic-shape, direct-Ident, binder-free hit-kernel and
candidate-only storage interfaces. The first focused check passed 60 pins,
32 source files / 43 excerpts, 118 registered-root joins, 236 route
calculations, 1,242 CE seed shape checks, 563 initial Dlogic/Dind keys and four
small arithmetic controls in 10.963 s subprocess / 9.588 s internal time.
The imported byte reader and weighted algebra are used as libraries; their
predecessor checker entry points are not invoked.

The registration map supplies 51 / 42 / 22 / 2 / 1 roots, including the two
trivial roots. Each gets raw Z3 and CE CVC5/Alt-Ergo routes. Alt-Ergo's ground
monomorphisation is an identity before inline; its separate pre-inline
validation charge is not included here. Adding twice the per-process maximum
episode to ordinary demand gives at most 364 episodes and 792,911 direct
Ident registrations, with process totals 375,917 / 308,026 / 95,281 / 7,896 /
5,791. The global escape allowance is shared with all other stages.

The weighted algebra uses coordinatewise maxima over optional hits/misses and
retains each formal's multiplicity. Uniform may/must eligibility holds under
all preceding choices. The selected eligible counts are 89 / 89 / 57 / 38 /
45; every eligible body is binder- and pattern-free and all formal coefficients
are at most one. Additional hidden used-symbol exclusions can only suppress
insertion, already covered by optional misses. Ordered declaration kinds,
heads/formals and strict-equal opened typed shape, with valid free-variable
caches, preserve the next eligibility decision.

Crucially, strict equality alone does not preserve attributes or hidden maps.
The complete initial necessary-key projection finds only the raw object for
each of the 563 Dlogic/Dind keys; Input uses the accepted subset transfer from
its later capture. Raw/CE stored closures, including unused saved images and
variable attributes, lack `inline:trivial`. The selected producer closure
copies/unions existing attributes or adds named disjoint attributes. Fresh
symbols cannot acquire an original physical key. I reviewed the additional
encoding branches and dynamic Ident helper prefixes as well as the census;
the literal scan is supplementary evidence. Valid cache and mutation guards
remain essential to this producer induction.

An actually eligible opened returned body contains no binder container, hence
no hidden binder map for relocation or type substitution. Opening the outer
definition can still traverse arbitrary hidden maps, but its fresh registrations
are bounded by its fixed formals. The direct formula uses output binder
ceilings for constructor and Task validation openings. The extra Dind term
2 B_ind_out conservatively covers clause-prefix opening and positivity walks;
the captured nullary patterns create no compiler variables. These observations
support the direct-registration result without bounding all validator work.

The typed projection checks normalized signatures and generated model types.
Put's range literals include 0, 1 and 2^64-1, so the old builtin-integer-only
restriction cannot be reused. Charging at most two comparisons per type-map
term, each on at most 64-bit operands, covers this path. The other inherited
restriction also changes: Put CE saved values can have three free occurrences.
The new disjointness check excludes every nonleaf saved key from every
composable seed value's free variables; subsequent fresh renamings preserve
fixed V<=6. Thus the repaired candidate K=E+2P and R=M(1+KV) arguments do not
assume unary saved values.

The result's 1,049,980,883,720 candidate hidden-substitution entries and
3,119,029,510,765,673 candidate free-variable scans are conservative source
counts. They do not bound physical time/memory or initial-plus-later counters.
In particular they do not apply to arbitrary old returned unused maps, hidden
types, complete validators or unsuccessful collision comparisons. The existing
unused-map counterexample remains valid. Later transformations/printers and
the aggregate q interface remain open.

## Common attachment boundary

R55's startup result covers the original fixed R53 J12 invocation plus its
single logging option. The new combined component supplies the separate
conditional quiet/timeless startup source attachment. The filename and inline
notes' references to that join as separate describe their own component scope;
they do not independently establish or replace the combined argument.
The Why-only SIGINT mask remains a prospective design, with explicit successful
mask/default-SIGTERM setup, mutation resource/counter guards and separate
supervisor PID/group cleanup/fallback/reaping obligations. No new launcher
attachment or native execution is established here.

All components share the same per-process two save-entering callbacks, three
saves and e<=2 allowance. No budget is reset per prover, component or stage.
Source correspondence and complete obligation discharge remain required;
bounded samples or arithmetic checks do not establish universal assurance.
Oracle, production tools/configuration, admission and draft-PR status remain
unchanged. No component establishes the complete q bound or closes #119/#153.
