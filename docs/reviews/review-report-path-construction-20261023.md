# Report construction and pathname composition review

2026-10-23 UTC, #119 / #153. Independent source review of the R69 report
construction and diagnostic-path providers, plus the lead's prospective
numerical join. The [packet](../evidence/retained-report-path-construction-review-20261023/README.md)
records exact final inputs and the final audit. Selected reviewer setting:
GPT-6 Astra / Extra High; runtime confirmation and token/cost telemetry are
unavailable. This review adds no compiler, solver, native execution, capture,
disassembler, source fetch or predecessor-checker replay.

The final audit passed **1,282 checks in 6.742398 seconds**, on its first
run: 32 frozen author files, 58 provider identities, 107 strict source ranges
across 43 complete source members, 21 libraries and five current inputs.
No unresolved material finding remains within these conditional interfaces.
The successful audit was not repeated.

| Interface | Accepted freeze |
| --- | --- |
| Path and alias-robust warning providers | `e352087713d306fb37bfe9dc39a7664a7cd01ce4` |
| Report/private construction, including amendment | `7b93e26d5c3cebde6789fd3f3ac90689fbf7f4e0` |
| Prospective numerical/provider join | `326a1c57ad03c660d26576e8395d28ca10937b58` |

Construction amendment 7b93e26 builds on its original freeze
`41a3f42678ef7f6d2ba75ea5aa8741aed4174a43`. Accepted R68 integration
`0934a69b14971b39a819582191feec532bb860c4` was imported solely to make the
new join's already accepted provider available. The reviewer commit contains
only this report and its evidence packet.

## Findings and disposition

**RC1 — medium: the narrower warning filename bound lacked the new
failed-publication origin guarantee. Resolved by an explicit R69 replacement.**
R68 used warning filename 166 and per-warning 422. R69 deliberately tolerates a
FileTags insertion interrupted between the forward map, reverse map and counter
write. A later lookup may return another stored filename. The warning's own
syntactic origin does not alone bound that returned filename; a complete
counter/fresh-tag/association theorem was not supplied for this use. This is a
missing proof attachment, not a demonstrated bad execution.

The accepted correction proves **all stored filename origins<=180** from the
complete initial input spellings, exact native Source_ptr/marker domain and
absence of raw location attributes/virtual filename directives. It then uses
**436=180+256** per ordinary warning, hence **L_o=436 W_o**. This proof survives
aliases and lost associations without needing a new counter theorem. The
opportunity counts W_o and global budgets are unchanged. The construction
amendment uses private-copy 436, still within Buffer512 and 32 events. Root's
new join uses the replacement L_o; it does not silently reuse 422 or edit the
historical R68 acceptance. FileTags storage, counter representation and the
remaining path-construction capacity owners are not discharged by this change.

**RC2 — low: private-owner continuation wording admitted a returning save.
Resolved before the first construction freeze.** The selected SIGINT
save-and-exit does not resume normally. The final argument instead separates
escaping failures, which abandon these lexical private owners, from classified
returning Thread/native clients, which do not mutate them. Terminal registry
continuation remains different and uses R68's dirty-owner theorem.

## Construction argument

This result supplies representation and finite progress, not a cumulative
allocation total. Report messages remain within a 32-bucket table and local
stats within 16 buckets; R<=22 and at most five prover keys cannot cross the
source's size>2*capacity resize condition. Report registration is a single
traversal and no save callback inserts into these private owners. Physical
attempt visits use the accepted A, including interrupted-publication duplicates.
Warnings are copied into cons cells/String variants, never one W-element array.
Immutable child construction and list traversal give proper finite trees and
lists; OCaml stable_sort splits decreasing sizes and consumes one head per
merge. Its sort/rev_sort mutually recursive group has two members. Native
integer comparisons do not subtract keys.

Fixed non-string construction blocks stay below 128 payload words; format
nodes and closure sizes do not grow with list lengths or string contents.
The new overlapping-quote census covers actual double-quoted literals in
selected report/terminal regions and complete warning-reference members. Its
character/comment false candidates are deliberate overcount. It supplies a
new fixed-format ceiling, not the old printer-only 90-byte limit. Source
selection, not the lexical count alone, excludes dynamic format substitution.
Format.sprintf uses Format.strput_acc and its own formatter; this is distinct
from CamlinternalFormat.strput_acc in the annotation-error route.

No selected driver has StepRegexp. Parsed results use -1, cancellation 0 and
initial Trivial 1; selected stats only select/max these values. With
0<=add<=450000 and1<=mult<=800, the actual subtraction stays between -450001
and 1 and the converted result is 1 or 2. A generic signed-native input premise
would not have proved these arithmetic endpoints. The existing scalar owners
retain decimal 20, %g 13 and %f 317 byte ceilings. Finite floating values remain
an independent JSON semantic requirement.

Private answer 368/32 events fits Buffer512; amended located-copy 436/32 also
fits Buffer512. Abort annotation raw 6/description 4/digit 1 uses Buffer16;
annotation-error 46 uses Buffer256. The accepted default-margin guard is used
only for these small owners. The imported symbolic terminal specialization
continues to own dirty registry continuation and its larger copies.

Loc.warning allocates Buffer100 and a formatter before checking its flag;
disabled warnings still construct those objects. make_iprintf consumes the
fixed format without building an output accumulator or invoking %a callbacks.
Their invocation count is not inferred from W_o publications. The new argument
supplies a per-owner representation bound under the existing producer
termination premises.

For enabled warnings the complete selected formats have at most 1024 offered
bytes and 128 events. Margin 1,000,000,000 preserves max_indent 68. Before a
flush, each segment remains queued behind its fresh unknown system box because
its input is smaller than the margin. The first flush sizes/closes the sole
zero-indent user box; later segments have only text and unit breaks. Every
break except the last is sized by its successor. After q bytes of known flat
output, left_total=1+q and space_left=margin-q, so the final unknown break's
drain slack is identically

```
1,000,000,010 - (1+q) - (1,000,000,000-q) = 9.
```

It can emit one newline at indent 0. Remaining text has known sizes; there is
no later unknown break or user open to stall it. @. then emits its extra
newline and resets; raw payload newlines are text bytes. Queue pops therefore
terminate, small totals/indices remain represented and Buffer growth is at
most 100→200→400→800→1600. This is a source specialization, not an application
of the default-margin sufficient inequality at margin 1e9.

## Path and frame argument

The previous terminal theorem's P covered any selected path argument or
location filename. The new theorem explicitly replaces that operand with
P_diag: only filenames whose bytes can enter a reached terminal leaf/wrapper.
The reviewed uses are Sys_error, Unix_error's one argument, file-content error
text and Loc.Located's prefix. Static resident literals retain H467; complete
frontend response lines retain M. No terminal recurrence step needs the
excluded raw stat-only paths.

Source_ptr copies a raw decoded input string. Curr.mk_attrs combines a raw
marker and raw source filename once and does not publish the combined string
back to loc_ref. A failed pop therefore cannot cause iterative concatenation.
Ident's location-attribute encode/decode preserves the filename suffix;
selected copy/cutoff/join/clone routes do not add filename bytes. Exact absent
raw attributes and bounded actual marker/source fields supply the stronger
180-byte all-origin warning result. The retained coarser request envelope
L=2U+4 remains valid and intentionally conservative.

Request basename/chop-extension cannot increase length; the selected sanitizer
emits at most two bytes per byte and uses the five-byte zilch fallback. T and
def'vc remain the fixed header providers, independently of FileTags aliases.
Driver-template overhead is at most 16 and open_temp_file adds 12. Thus
F=tau+max(5,2L)+28 gives 775/802/841/853/829. Configured session/save/backup,
log and fixed environment error arguments are all smaller. Relative filesystem
resolution does not append cwd to the reported operand. Unix.putenv reports
GMON_OUT_PREFIX, Sys.rename uses NO_ARG, Unix.rename reports its first path;
post-cut socket services report no pathname. Connection succeeds before the
cut and no selected reconnect occurs.

For actual canonical result-directory byte length R, Pc=R+24,
P_diag=max(F,R+24), and M=R+72. M includes the entire S/F response line and LF;
the 1024-byte read chunk is not a complete-frame bound. A positive native ID
uses at most 19 decimal bytes. Rejoining semicolon-separated filename pieces
cannot exceed its source frame. These remain conditional on the intact
prospective canonical protocol and normal scalar services; failed startup,
malformed streams and raw-backend filenames are not included.

Raw library probes retain the explicit P_stat residual. Env.locate_library
constructs all configured loadpath/extension candidates before testing them;
the actual complete generated datadir/loadpath is not extracted. Runtime
Sys.file_exists returns false for an invalid C-safe name or failed stat and
does not construct Sys_error(candidate). Allocation/asynchronous failure has
its scalar/save origin. AmbiguousPath/LibraryNotFound payloads are dropped at
the accepted preparation boundary. This excludes those raw bytes from the
terminal formula without claiming their construction/storage discharged.

## Prospective composition and evidence

The accepted root join adjusts the R68 constants by 6*14W_o for B and
2*14W_o for E. With S=max(467,F+51,R+95), the independent reconstruction
confirms X=4032S+2,997,488, B=b1+6X and E=e1+2X. The once-per-process stderr
fragment, two total exit flushes and summed terminal X retain their accepted
coefficients. No driver multiplies these shared charges.

All relevant expressions are nonnegative and nondecreasing in nonnegative R:
max, positive affine expressions and products of nonnegative nondecreasing
terms preserve order. The first standard-core guard is an affine constraint
on S. Integer division gives its exact upper endpoint; evaluating the remaining
standard-core, terminal-private, Buffer/string and zero-offset channel guards
at that endpoint proves the same interval for all of them. This source/algebra
argument, not the finite examples alone, supplies the universal interval claim.
The selected channel offer remains B+70(E+2)+2Y+371, tested against 2^63-1.

| Case | Sufficient R upper endpoint |
| --- | ---: |
| Put_Line | 2,264 |
| Put | 5,273 |
| First_Or_Default | 8,731 |
| Is_Message | 24,388 |
| Input_Is_Valid | 22,329 |

The common sufficient region is R<=2,264. Put_Line's sentinel margin there
is 9,285; the next byte fails this sufficient predicate by 22,971. This is
not an actual-overflow claim. The illustrative R=64 point has minimum margin
49,457,733; it is not a selected directory either. Actual R and actual runtime
guard claims remain null until the configuration is supplied. These intervals
are consequences of existing guards, not deployment caps or admission changes.

The final packet retains exact freezes, provider identities, strict source
ranges and independent finite reconstruction. Its separate character-by-character
quote-start traversal reproduced 9,089 conservative format candidates and the
102,076-node fixed-format ceiling. It independently decodes current native
inputs, checks absent raw location attributes, inventories Source_ptr/marker
maxima and reconstructs configured paths and all numerical join exports. Accepted R68 source/provider
results are reused without replaying its checker or installed-ELF scan. A
finite audit establishes identities and displayed arithmetic; the source
arguments above carry the semantic coverage and prefix reasoning.

One shared e<=2, two save-entering callbacks and three saves remain unchanged.
Ordinary physical runtime/allocator/GC, stack, I/O and kernel sufficiency remain
trusted; no aggregate RAM/stack gate is introduced. Oracle, tools/pins,
admission and production remain unchanged. This review makes no GitHub,
publication, harness-state or CLI-memory write; the live goal read was null.
Canonical deployment/refinement, raw solver storage/parser construction,
logging capacity, startup/full grammar, complete FileTags/path representation
and whole #119/#153 completion remain outside this acceptance.
