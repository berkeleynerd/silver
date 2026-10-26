# Feature-local guard parser frame account — 2026-10-26

The guard parser uses active-count vectors, fixed forwarding frames for pure
Boolean grouping, two condition buffers per active chain, and explicit retained
loop/choice state. The Linux observations below pass at an 8 MiB process stack.
They establish the measured feature-local behavior and allocation shape, with
conditional source-budget calculations; they do not establish a universal 8 MiB
certificate. Sufficient stack and memory remain environmental premises under
[trusted-boundary.md](../../trusted-boundary.md#trusted-computing-base).
The [active-flow design](active-flow-design-20261026.md#feature-local-stack-argument-and-implementation-checkpoint)
likewise distinguishes candidate payload inequalities from a total bound.

## Exact snapshot and observed behavior

The [retained evidence](shared-reader-frames-20261026/README.md) corresponds to
source `042998ad3a`, including executable shared `Reading_Names` (native change
`a201d7e6f7`). Parser SHA-256 is
`0b4c95feb685491236c4880597f557eac2283d22420e5a54f39995238de03ccb`.
All 129 tracked source files match that commit, and all 183 hashes in the shape
run input manifest were checked against the retained scratch snapshot. The
older pre-helper `inputs.json` is explicitly historical. Probe switches are
`-gnat2022 -gnata -gnato -g`, with `-fstack-usage -save-temps`.

| Existing native run | Result |
| --- | --- |
| `20261026T033412-b6260b5bebde` | Shared-reader build succeeded; 8.258 s managed duration |
| `20261026T033529-091e794133d5` | Admission: 105 cases, 18 tests, zero failures/errors; 26.238 s managed duration |
| `20261026T033623-4e2ff8b1bc60` | All 20 parser shapes matched expected status at 8192 KiB; 28.675 s managed duration |

The ten admitted 4096-byte shapes cover scalar counts 1/32/128/224 with deep
parentheses, `not`, `and then`, `or else`, nested choices, nested loops and a
mixed shape. Their ten 4097-byte companions reject with status 2. These are
recognizer observations, not application proof/build execution or an exhaustive
capacity theorem. No native runner was repeated for this record.

## Primary frames and source charges

Emitted `.su` sums include the public contract wrapper and its wrapped body.
Dynamic objects are additional unless included as bounded outgoing argument
areas in `.su`.

| Recursive routine | Fixed bytes |
| --- | ---: |
| Read_Primary_Into | 336 |
| Read_Relation_Into | 576 |
| Read_Condition_Into | 304 |
| Read_Chain_Into | 464 |
| Read_Body | 304 |
| Body_Tail | 416 |
| Statement_Body | 256 |
| Loop_Body | 29184 |
| Conditional_Body | 416 |
| Alternative_Body | 368 |

These recursive sums are unchanged from the earlier reviewed frame build.
`Read_Scalar_In_Flow` now has `.su` entries 10992+256, and
`Read_String_In_Flow` 10992+240 (each formerly began with 11008).
`Reading_Names` adds transient fixed entries 10992+11136. This helper is called
while preparing an expression's environment; it does not add an Environment to
each predicate forwarding frame. Neither emitted Reading_Names function body
calls secondary-stack allocation, marking or release; its fixed-size result uses
caller-provided storage. The old review's 13952-byte body-leaf estimate
must not be reused unchanged after this new call route. The retained source diff
and full assembly/stack records expose the change.

For active scalar count B, padded primary-object upper sizes from the emitted
layout are `S(B)=8B+48` (Body_Scan), `F(B)=8B+32` (Scalar_Flow), and
`C(B)=16B+48` (Condition_Result). They depend on active counts, not maximum
binding capacity. `Read_Chain_Into` retains both Right and the runtime
`Result'Loop_Entry` capture: **two** C(B), totaling `32B+96`. Erasing the Static
invariant does not erase the runtime cursor invariant's whole-record capture.
Pure Boolean grouping retains `304+576+336=1216` fixed bytes per level and
forwards flow/result buffers without per-group vector allocation.

The scalar-expression recursive maximum is **1456**, corrected from the draft's
1440: Read_Expression 448 + Read_Group 480 + Read_Compound 528. The unary route
is 1440 and pure nested groups 928. Sibling left-expression and compound
computations are not simultaneously live. Thus the enlarged 1600 grouping
charge covers these individual routes.

Loop state includes two parent-route S(B) objects plus local S(B), S(B+1),
the fixed Body_Context/Append copies and wrapper frames. The reviewed bundle
is at most `30360+32B`, covered by `31000+32B`. The choice bundle includes the
conditional, terminal alternative and parent body route: at most `2112+80B`,
covered by `3500+96B`. Terminal Alternative_Body allocates its three local
vectors even for else/end. The chain bundle, including forwarding and both
buffers, is `1776+32B`, covered by `2000+32B`.

For successfully admitted sources, let D be scalar declarations, L complete
loops, I if/elsif owners, C short-circuit links and P grouping pairs. Conservative
token charges give `12D+22L+12I+6C+2P <= 4096` and active `B <= D+L <= 341`.
A plain if uses at least 15 token bytes and an elsif 12; complete loop tokens
use 22; separators only increase cost. The six-byte link charge is deliberately
weaker than the design's seven-byte estimate. Charges require distinct token
occurrences, including distinct minimal relation cores.

The retained arithmetic enumeration maximizes the candidate expression
`524288+(31000+32B)L+(3500+96B)I+(2000+32B)C+1600P` at **7,400,560 bytes**
for D=0,L=B=186,I=C=0,P=2. This corrects the draft's 7,404,479. It is a
conditional arithmetic envelope only: complete assignment of mixed live frames
to unique syntactic owners and the 524288-byte nonrecursive/runtime allowance
have not been universally certified. The shared helper also requires updating
any exploratory acyclic-route extraction. This number is not a proved bound.

## Secondary results and actual lifetimes

The current parser assembly maps calls in
`shared-reader-frames-20261026/secondary-call-sites.json.gz`. Body_Tail marks at
line 26346 immediately before Statement_Body, copies the result into its primary
local, and releases through the finalizer at 26135. Completed sibling iterations
therefore do not accumulate their subtrees. Conditional_Body marks at 29226 and
releases through 28992 around the Then_Keyword Body_Token assignment only; that
mark does not reclaim the conditional's first statement and subsequent results.
Read_Body, Loop_Body and Alternative_Body have no local secondary mark/release.
Read_Body's first Statement_Body result survives through Body_Tail; elsif arm
results may accumulate until a caller releases them. Read_Statements marks at
30565 and releases through 30520; Read_Form has scan-step/scope marks/releases.

Initial_Flow returns secondary F(B); Body_Of, Body_Token and Invalid_Body return
secondary S(B). Procedure condition parsing adds no secondary vector return.
Counting all successful-body allocations, including already released ones,
gives the conservative payload expression
`S(B)*(4N+6L+9J+4E+3)`: at most four per basic statement N, six per loop L,
nine per if J, four per elsif E and three root allocations. The root count
covers Body_Of, Initial_Flow (overcharged as S) and the top Body_Tail.

With `12D+22L+15J+12E+5N <= 4096` and conservative B=D+L, the count factor is
at most `0.8*(4096-12B)+3`. Its padded object-payload maximum is **2,320,464
bytes at B=168**, conditional on this successful-parse allocation-site count
and at most 16-byte rounding. Retaining every result overbounds actual early
releases. This concerns secondary object payload separately from primary stack;
adding it to the primary estimate or comparing the sum with the process stack
limit would require the external runtime's allocation model.

The generated binder selects the runtime default secondary-stack pool/size.
Assembly calls external GNAT allocation/mark/release functions; it does not
establish chunk growth, allocator metadata, available heap or failure behavior.
No runtime implementation was inspected for this account.

## Review applicability and limits

The retained read-only review selected GPT-6 Astra, Extra High; its runtime
settings, separate elapsed time and token/cost measurements were unavailable.
It reviewed the earlier parser hash `1558f210...` and frame run
`20261026T024531-a4f281e0e8cc`. Its findings and limitations are retained verbatim.
The source comparison to this snapshot shows the shared-helper refactor plus a
Body_Tail variant annotation change; emitted recursive frame sums still agree.
The old review supports those unchanged local bundles and lifetime analysis;
its exploratory whole-call-graph estimates are not automatically current.

This records the required feature-local layout/allocation/source-budget analysis
and boundary observations under the existing sufficient-resource premise.
Universal 8 MiB sufficiency, malformed-prefix total capacity and external
allocator sufficiency are outside this claim. Complete semantic discharge,
native validation and actual-source correspondence remain separate required
capability obligations; the measurements do not replace them. Later Static-only
proof drafts are outside this snapshot and require a source/applicability check
before reusing this evidence. Deferred report-capacity work is not resumed.

Retention/accounting round: selected GPT-6.1 Sol, High; runtime settings and
the live lead setting were not independently exposed. The result is hashed
retention plus the scoped account and arithmetic corrections above. No proof,
native, test, build or render runner was launched; token/cost and separate
round elapsed measurements are unavailable.
