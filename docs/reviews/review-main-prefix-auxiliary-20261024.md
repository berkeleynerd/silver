# Independent review: source-derived prefix auxiliary owners

Accepted within the stated C→T auxiliary-owner scope, with no material finding.
Reviewed author **`ae53fcef513b322bdc67f91aee998d1a8c356a22`** for #202/#119.
The actual serialized-input fold, its conditional producer specialization,
populated Hsattr/FileTags transport, and individual fixed/string/Connection
operands are supported by the retained source argument. This does not close
the complete parser/converter or T→builder transport. Both issues stay open;
production work remains unstarted.

The author changes only
[`prefix-auxiliary/`](../evidence/retained-main-construction-demand-20261024/prefix-auxiliary/README.md)
and the appended “Source-derived prefix auxiliary owners” section of
[`retained-main-construction-demand.md`](../research/retained-main-construction-demand.md).
The review retains the accepted source-prefix result at
`a75ca51a31e2b50357032b5d7fe0155eeda434b0`, reviewed at
`948869ace9fdc65ea8fb1ff17cda17809e502bc5`, and the previously accepted
shared-service result. It does not reopen their successful native or proof
evidence. Exact current input hashes, author change scope, and provider/source
identity checks are in the independent
[`result.json`](../evidence/review-main-prefix-auxiliary-20261024/result.json).

## Source amortization and occurrence semantics

The critical claim is the human source amortization, not the fact that a
checker enumerates 63 names. I inspected the converter helper closure and
selected declaration/expression arms against `source-caps.json`, including
the following places where a simple successful-node count would fail:

| Source case | Review conclusion |
| --- | --- |
| Names, types, binders and metadata | A qualified name has at most three components. A binder's name/type/location expands to at most seven synthetic positions, costing fourteen combined G/F events. Metadata construction by a parent can be charged there; independently charging its serialized node only increases the potential. |
| Universal/existential quantifiers | `mk_binder r.labels` is mapped over every binder. Each binder-label pair may attempt one attribute creation. The added product is necessary, and replay weights must multiply it too. Curr attributes are created before this map and then attached as values. |
| Ordinary expressions and constants | Selected recursive child conversions occur once. Call metadata and per-argument apply nodes are bounded fixed or per-cell work. Numeric operations do not call these four owners. Space-split identifiers require per-byte tickets; the fixed ticket covers the extra empty fragment. |
| Program wrappers, handlers and sequences | `requires` contributes one A and one G/F pair; `ensures` one A and four G/F pairs. Flattening sequences revisits syntax but does not repeatedly convert its leaves. Eager operands and constructed-but-discarded wrappers remain charged. |
| Loops and variants | `Variant.Expr` converts at both converter820 and859. Doubling the whole serialized subtree is correct; a nested replay doubles all its child costs, including binder products. Code_before/code_after each convert once even though their resulting Ptree values are reused. Variant wrappers, comparison, old/new variables and lets fit the stated fixed/item allowance. |
| Function declarations | Parameter conversion is performed before domain selection; `ld_loc` is likewise eager. The `???` Option default constructs an identifier even for a present parameter name. In Pterm/Pred cases the generated post uses already constructed identifiers/results; it does not convert the definition twice. The fixed declaration and per-parameter allowances cover these costs. |
| Other declarations, modules and includes | Clone substitutions use two bounded-component names; fields/effects/dependencies have per-item charges. Include deduplication happens after metadata construction, so duplicate includes receive no refund. Namespace/theory children recurse once. |

These expansions fit the author's local ceilings of at most 64 events per
fixed branch or list item and eight per splitting byte, with 128 per potential
ticket. The common Curr work and fixed wrappers have room in those ceilings.
There is no additional uncharged input-sized owner-producing loop or child
replay in the selected source closure. An exception bounds a prefix of these
attempts, not just its surviving Ptree. Argument evaluation order therefore
does not invalidate the bound. This is a reviewed source argument under the
inherited correspondence assumptions, not a machine proof or an OCaml
interpreter execution.

The independent reference fold uses recursive subtree addition; the author
uses an explicit weighted stack. Thirteen controls compare their full
plain/weighted vectors, including duplicate object keys, repeated node IDs,
literal and escaped Unicode, space splitting, both quantifier products,
nested variant replay, unknown shapes, and one/two final LFs. Fixtures are
mathematical fold controls, not new producer captures or successful decoder
examples. They support implementation correspondence and do not establish
the source amortization by testing.

The public functions accept actual serialized bytes or the explicitly
conditional producer specialization. They expose no arbitrary demand or
initial-counter certificate. Unknown/malformed node shapes do not certify
the linear shortcut; the callable is explicitly not a complete schema
validator. Its use remains attached to the accepted serialization/decoder
relation. A complete decoding failure precedes auxiliary conversion work.

## Linear specialization and body/file bytes

The source shortcut is properly narrower than arbitrary JSON. The existing
producer label bound is three. R77's ordinary Main loop source induction
preserves empty variant lists. The accepted **complete fixed occurrence
provider** has zero Variant, Variants and Loop entries; the import allowance
adds only Include/Module. The fixed component's zero Loop entry does not
claim that ordinary Main lacks loops. Thus this specialization actually has
no variant replay; the generic at-most-one-layer condition is conservative.

For the generic bounded-layer condition, weighted V/E/S are at most twice
their plain counts. Each quantifier product is at most three times its
weighted binder-list cells, which are included in weighted E. Therefore
`W <= 2V + 8E + 2S <= 12B`, and the combined event bound is
`Q <= 128*12*(2^31-2) = 3,298,534,880,256`. This uses the existing conditional
producer byte interface, not a new admission bound or R77/R79 successful
typed/VC counts. Larger labels or deeper replay still receive their full
actual-data potential; they do not inherit this numerical shortcut.

The producer's T_file body convention excludes Outputs.Close's one final LF.
The author now distinguishes body B from actual file B+1. Removing one final
LF changes no JSON value, cell or decoded string charge; a second LF remains
in the body byte count. Yojson's open consumer interface is explicitly for
B+1 file bytes. No body/file off-by-one remains in the reviewed formulas.

## Populated C state, table geometry and control interval

Hsattr starts from the accepted C **counter and allocated geometry**, including
all allocated bucket slots. The Weak transfer permits clearing/reinsertion
and does not replace the table by an empty one. The audit independently
recomputed its outer/bucket bounds and byte requests for all five roles;
the accepted transfer theorem itself was reused rather than reproved.

FileTags has private forward/reverse tables, initially size zero with backing
extent 16. Every completed counter increment follows the forward Cons
allocation. The retained native fact is four words per such cell, so the
accepted C minor-allocation history gives `N_C <= floor(M/4)`. This is an
injection into past allocations, not a current live-heap observation.
At this cut the private completed maps are inverse, each size is N_C, and
the ordinary growth invariant supplies `backing <= max(16,N_C)`.

The no-interruption premise has the required source attachment:
`Gnat_checks.init_cont` returns before the actual
`Sys.Signal_handle (save_session_and_exit c)` installation. T lies inside
initialization. The inherited runtime/service relation supplies no other
application callback that abandons and resumes a FileTags mutation in C→T.
Physical/native failures preserve their failure outcomes; they do not create
an arbitrary resumed state under the positive physical-resource premise.
The later R71 interrupted-resize/false-miss domain is not imported here.

Fresh filenames are allowed. Each new request can execute one insertion
handler, add once to each table and increment once. With ordinary completed
growth, insertion at size `2b+1` doubles b to `2b`, which is less than the
new size. At intermediate insertion/resize prefixes, the old/new backing
and tail requests still fit `max(16,N_C+Q)`. Complete/disjoint chain structure
is preserved under completed rehashing. Counter/size, doubling/threshold,
masked indexing, header and unsigned byte arithmetic are thus bounded by the
exported operands without requiring the old fixed filename set D0.

All five role guards pass independent arithmetic at the maximum attached
producer bound. Synthetic location endpoint `1+Q` fits the packed line limit;
the source-selected columns are zero. Raw source lines are checked before
FileTags use. Call-ID endpoint Q fits its represented integer. The accepted
Ident/Hsty/Hsity zero-request projection remains unchanged. No extra callback,
save or exception allowance is introduced: one global e≤2, two save-entering
callbacks and three saves remain in force.

## Individual requests and remaining consumers

The `64B+128` content-derived string bound covers raw fields, fixed affixes,
represented-integer decimal text, Curr's nonrecursive marker/filename join,
and at most B path indices. Existing filename suffix replacements shorten
the incoming name; old represented strings retain the accepted `8*S_C`
carrier bound. The maximum of these operands bounds individual strings and
concatenation/index arithmetic. It is not a Format/Buffer queue bound.

Gnat/Ptree record, tuple, list and closure requests have source-fixed arities
under inherited constructor correspondence. Sharing a Ptree child does not
enlarge an individual block or introduce an aggregate counter. Include-set
height and selected list lengths are source-bounded; Connection's variable
array receives at most B operands with midpoint numerator at most 2B+1.
This closes the stated individual/finiteness interface without a new native
fixed-byte census, cumulative local-byte price, or aggregate RAM/stack bound.

The remaining consumer obligations are correctly preserved:

- Yojson input buffers, tokens/lexbuf, JSON containers and errors for B+1
  bytes; the existing Json_base output escaper is not a parser provider.
- Number/Big_int_Z parsing and normalization intermediates. The existing d=40
  bounds serialized decimal digits, **not** a numerical exponent, shift or
  intermediate allocation. Actual Ureal denominator/exponent origins remain
  required before such bounds can be attached.
- Format/Buffer/queue storage for bounded converter/error outputs.

Full parser/converter representation and T→builder flags remain false.
Imports/clones/typing/proxy/candidate work after T remains subsequent. Oracle,
language admission and tool pins are unchanged.

## Evidence and round record

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation and token/cost telemetry are unavailable. The isolated review
worktree began clean at the exact author commit. Review started
2026-10-24 08:46:09 UTC; the acceptance checkpoint was 08:54:00 UTC, a
471-second wall-clock observation, excluding final report/commit work.
`scripts/dev.py paths` identified Linux x86-64; no other-host execution is
claimed. Harness goal was read as null; CLI memory was not updated.

The one focused independent
[`audit.py`](../evidence/review-main-prefix-auxiliary-20261024/audit.py)
passed **319 checks in 1.005205274 seconds** on
`Linux-7.0.14-x86_64-with-glibc2.43`. Its command receipt reports
0.976445478 seconds; these are separate tool/checker measurements, not
reconciled timing claims. It checks 15 exact author inputs, 108 immutable
provider/prior-packet identities, 12 complete archived sources and 48 exact
excerpts, plus fold/transport/control arithmetic. The audit ran once and
passed. An earlier ad hoc JSON shape-inspection command assumed a list was
a mapping and raised AttributeError; it wrote nothing and ran no audit.

The author's own history is retained accurately: the initial source-anchor
assertion matched Signal_ignore inside a function definition and failed;
the corrected draft passed 285 checks, and the warranted body-LF/direct
source-provider revision passed 290. These are author receipts, not new
reviewer executions. No author/predecessor checker or extractor, native
target/capture, compiler/prover/Lean, disassembler or service was run in this
review. Successful inherited evidence was reused by exact identity.

The review adds only its new evidence directory and this report, with a local
review commit for parent integration. It does not write GitHub, goals,
publication state or author files. Root owns integration/publication and
issue/session-memory updates; this review does not close #202 or #119.
