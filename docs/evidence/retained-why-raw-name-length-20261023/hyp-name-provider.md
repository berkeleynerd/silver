# Hsattr initialization and complete selected request demand

2026-10-23 UTC; #119 / #153. **Author source argument, pending independent
review.** `Ident.Hsattr`, the seventh global hashcons/counter owner, has a
source-attached starting envelope and a complete request-count input for the
five selected fixed processes. Its conditional counter and weak-backing guards
fit. This does not establish seven-owner composition or whole-process capacity.
The [packet](../evidence/retained-why-hsattr-demand-20261023/README.md) records
exact frozen inputs, complete source identities, native excerpts, new attribute
projections and finite arithmetic. No predecessor checker or native run is used.

The retained source/native/runtime relation, immutable typed ownership,
guarded mutation, selected-client closure and earliest-violating-operation
premises are those of [R63](../evidence/retained-six-owner-round63-20261023/README.md).
The selected route is the combined quiet/timeless/J12/logging, fresh automatic
Per_Check execution with CE off, one OCaml worker and three fixed provers.
Ordinary physical-resource sufficiency retains its existing trusted boundary.
There is no aggregate RAM or execution-time gate. Oracle, tool pins, current
admission and production code are unchanged; #119/#153 remain open.

## Actual owner and registration state

`ident.ml:28–39` instantiates `Hashcons.Make` with equality on `attr_string`,
string hashing and a fresh `{ a with attr_tag=n }` record. Only
`create_attribute` calls its `hashcons`. Hsattr is distinct from the strong
Hstr/Hid tables inside the private identifier printer. It is also distinct
from the other Hashcons instantiations. `Sattr.add`, union, copying, comparison
and filtering do not intern attributes.

`hashcons.ml:32–56` initializes this owner's `next_tag=0` and an empty
`Weak.Make.create 5003` table. Every external merge request first calls H.tag;
only a returned candidate increments the counter. No selected caller reaches
Hsattr.unique, resets the counter, or directly inserts into its private table.
Initial table state is derived from this initialization and the request history,
not taken from another owner's observed dimensions or from a small tag residue.

The target cuts and retained identities are:

| Process | Retained J12 PID | Historical logical/state provider | Target |
| --- | ---: | --- | --- |
| Put_Line | 22236 | PID3085, registration | Prospective combined registration |
| Put | 22524 | PID3323, registration | Prospective combined registration |
| First_Or_Default | 21865 | PID3470, registration | Prospective combined registration |
| Is_Message | 22653 | PID3568, registration | Prospective combined registration |
| Input_Is_Valid | 22222 | PID97103, first CVC5 inline entry after CE | Prospective combined registration |

The J12 evidence supplies the actual root identities and startup relation;
it is not a newly executed combined invocation. Input's later historical graph
and six-owner state retain their accepted earlier-cut envelope relation. No
Hsattr snapshot is claimed for any PID. In particular, this argument neither
renames PID74171 nor imports the fresh-save PID17869 table state.

### Request-to-allocation injection, including hits

The retained native `camlWhy3__Ident__tag_1336` at `0x56c490` subtracts24 bytes
from `%r15`, initializes a two-field record and returns. Its only slow edge is
`caml_call_gc`. This is the Hsattr tag function at `ident.ml:33`, not the
allocation-free attribute-tag accessor `tag_370`. The exact disassembly is in
prefix-gc's `observations.tar.gz`, member `success/attribute-static.txt`.
The same archive's `success/installed-constructors.txt` shows generic hashcons
calling H.tag before `Weak.merge` and incrementing only after the merge.
The packet retains both full-member identities and exact in-range excerpts.

Consequently each merge entry has a distinct preceding three-word allocation,
even when the merge hits an existing attribute, the candidate is later discarded,
or an exception interrupts the merge. Candidate hoisting or elimination cannot
remove this native allocation. A failure before H.tag returns has made no merge
request and no counter increment; it need not receive a request credit. Internal
Weak rehashing is covered by the imported transfer and is not another external
Hsattr request. No zero-allocation merge-hit path exists.

The protected prefix starts before the first Why3 module, hence before Hsattr
initialization. The [combined startup](retained-combined-parallel-startup.md)
and [logging transfer](retained-parallel-logging-prefix.md) give cumulative
minor bump bounds, including their additional allocations, of
135,521,724 / 124,243,436 / 95,519,954 / 85,358,536 / 86,344,026 words at the
five prospective registration cuts. Each includes the combined configuration's
7,582,192-word credit in addition to the earlier logging-cut envelope. The
calculation attaches the combined startup projection and reconciles its process
identities and root counts with both retained providers. These are allocation history, not live
heap sizes. Use the common loose bound `B=2^28` once per process.

There is no protected collection, minor-pointer reset, reclamation or extra
application callback. The [initial-registration argument](retained-why-initial-registration-bound.md)
supplies the actual pending-action/signal-stop exclusions: one debugger continue,
no signal-policy changes or stop/resume loop, no delivered SIGINT/native-fault
abandonment reaching the endpoint, no finalizer/alarm/Memprof/reflection clients,
and one-worker native yield without an application callback. The selected
native-service relation is retained. Thus an allocation slow path cannot roll
back this charge and then reach the observed cut with an uncharged merge.
Unlike Ident's increment-before-allocation sequence, Hsattr's merge is after
the allocation; an abandoned tag allocation cannot itself increment Hsattr.

If q is the complete initial merge-request count, `3q <= minor_bump < B`, so
the deliberately weaker `q<=B` also bounds `next_tag`. This is a first-wrap
argument from initialization, not an inference from a captured counter residue.
It includes all frontend, plugin, library, driver and module-static attribute
work before registration. That work is not added again as suffix demand.

Applying the accepted `weak_transfer(5003,0,0,B)` supplies registration
envelopes: outer length<=805,306,371, individual bucket length<=402,653,187,
live entries<=268,435,456 and next_tag<=268,435,456. Oversize and rover may be
any valid states within that transfer; no observed empty-table state is claimed
at registration. For continuation, use the **same lifetime history from empty**
with B plus all suffix requests. This avoids fabricating an initial total of
allocated slots from occupied slots, multiplying two individual upper bounds,
or restarting the request allowance at registration.

## Complete suffix constructor census

The packet scans556 complete Why3 implementation/interface/parser members for
the direct factory and every Ident factory wrapper, retaining155 textual
references including definitions, comments and interfaces. That scan supports
review of the following call/source cases; it is not a whole-program
reachability proof.

| Source origin after registration | Hsattr request treatment |
| --- | --- |
| Library parser `name_term` and ATTRIBUTE (`parser_common.mly:175–179,1173,1294–1296,1336–1344,1611`) | At most four per expanded input byte; counted below even for reparses and abandoned prefixes. |
| Typing's `"at:" ^ l` (`typing.ml:339–362`) | Requires a labeled/old program-variable use. All four complete library sources have no `old` or `at` token; no literal attribute can supply one. Absent on this selected parser/typing family. |
| `Term.v_copy_unused` (`term.ml:1675–1714`) | At most one `create_model_trace_attr` per prospective unused-copy constructor. Charged to accepted CE mapping demand, including failed prefixes. |
| Pdecl name-suffix wrappers (`pdecl.ml:343–453`) | Only the excluded range/float/record/invariant/injectivity cases call them. Selected abstract/explicit-variant types and tuple bodies do not. |
| Pmodule refinement VC (`pmodule.ml:1350–1355`), VC/eid/written/call-result/field factories and Eval_match | Selected library additions have `vc:false`, no refinement/witness interface, and no VC/evaluator call. The accepted library constructor argument supplies these family exclusions, including restored-body associations and generated Cany shape. Initial VC construction is already in B. |
| Inlining, builtin/unused removal, polymorphism, R61 preparation and generated heads | Test, copy, union, remove or add already interned module-static attributes; their only applicable dynamic factory is the separately counted CE unused-copy path. Literal/epsilon/algebraic/premise producers do not call an attribute factory. |
| `cntexmp_printer.update_info_labels` (`:104–129`) | Called even with CE off. It creates one attribute for each `at:` member of the original term/symbol union; the complete origin argument below makes that set empty. |
| SMTv2 `create_written_attr` (`smtv2.ml:726–765`) | Inside `info.info_counterexample`; the accepted preserved false-meta result excludes it. |
| Session save/checksum/shape/explanation and selected callbacks/shutdown | Copy/read/print attributes; no attribute factory. XML `load_ident` (`session_itp.ml:1063–1083`) and S-expression decoders are loading routes, absent from the fresh, nonreplay suffix. No CE/model parser, RAC, extra splitting or logical exception rendering is selected by the accepted parallel callback closure. |
| Other transformations, inference, extraction and plugins | Not reachable in the selected post-registration route. Dynamic frontend conversion belongs to B; loaded static attributes are not recreated by looking up registered closures. `expr.ml:861–874` is commented code. |

### Library requests are parser work, not publications

The accepted [library constructor argument](retained-why-library-constructors.md)
supplies a complete four-file acyclic parser/type/clone family, expanded
source slots `S_int=147480`, `S_real=807447`, two direct roots per preparation
and the already bounded no-extra-reparse episode control. For `E=3N+e`, use
`X=2E*S_real` expanded parser bytes. Charging the larger root twice covers a
prefix that fails before the second read. Clone expansion is a conservative
overcount for parsing; its copied attributes are not interned anew.

Each ATTRIBUTE grammar action consumes its token. A `name_term` call belongs
to one named assertion/contract/variant syntax item or one ensures binding.
Each binding has its own nonempty syntactic item; the relevant grammar does
not revisit a consumed item. Thus four factory calls per expanded byte cover
these actions, even with punctuation/minimal names and partial parses.
The complete fixed files have no ATTRIBUTE token at all, but the bound keeps
the allowance. All annotation keywords have `{` immediately after whitespace;
their optional names are absent. They generate only `hyp_name:Requires`,
`hyp_name:Ensures` and `hyp_name:Variant`.

`we_attr` is module-static (`parser_common.mly:100`), not a factory call on
each witness rewrite. The selected typing/cloning/declaration/tuple paths add
no other factory request by the census above. In particular every lower tuple
memo may miss on every call without creating an attribute. No successful memo
publication count, dictionary population, type request or Ident increment is
substituted for parsing requests. The export is `Q_library=4X=8E*S_real`.

### CE cleanup and all other preparation

The [CE source simulation](retained-why-preinline-prefix.md#direct-ident-charge-and-episode-composition)
counts each prospective unused-copy constructor along with fresh binder
openings. For registered root g let C_g be its retained `ce_direct_Ident_upper`.
An attribute factory precedes the unused copy's `create_vsymbol`, so this is
an injection into **prospective source constructor opportunities**, not into
successfully completed registrations. Failure after interning and before the
variable registration is still charged. The helper has at most one factory
entry, including its broad Not_found behavior. There is no inner retry loop.

The CVC5 and Alt-Ergo routes may each invoke CE cleanup; Z3 does not.
Export `Q_CE=2*sum(C_g)+e*max(C_g)` over the accepted actual registered roots.
The checker reattaches those goal IDs to their frozen certificates and checks
this value is no greater than the already composed CE/mono Ident component.
Input uses the full prospective registration suffix: no historical completed
CE call is subtracted. The later preparation route uses ordinary `~keep:false`
let simplification, while the only other keep-trace/eval/VC callers are the
excluded cases above. All other preparation Hsattr demand is zero.

## Why the unconditional printer label path creates no attributes

CE off alone does **not** prove this result. `smtv2.ml:418–424` unconditionally
updates `info_labels` for a syntax-free nullary application. The update folds
`t.t_attrs union ls.ls_name.id_attrs`; any `at:` member would call
`create_attribute`, even with CE off. Existing `cur_l` is an accumulator only:
located strings are not written back into those input term/symbol attributes.

The new finite projection examines every R51 stored/candidate term, including
hidden substitutions and initial same-key representative alternatives, every
graph variable/symbol identifier and every R56 declaration/type/signature
identifier. All five unions contain zero strings starting `at:`. It separately
checks all declaration `d_news` identifiers and signature-head identifiers
are covered, rather than using the smaller term-only attribute union. Thus
original lsymbols used as application heads and original names cloned into new
heads have the necessary base property. This reuses the accepted typed graph
coverage; it does not claim a fresh complete heap capture.

The continuing origin induction is over the accepted returned-field family,
not just alpha equality of visible formulas:

1. Driver metadata, copying, opening, substitutions, inline hits and retained
   strict-equal declarations remain inside the accepted stored-field family.
   Union/removal cannot introduce an absent attribute string. The R56 family
   and returned-field invariant already include old hidden values and saved
   replacements that can surface later.
2. CE cleanup adds only `id:unused` and `model_trace:<name>`. Inlining and
   splitting add/test fixed `introduced`, inline, split and encoding markers;
   none starts `at:`. R61's selected producers copy those fields, use fresh
   empty attributes or add those same static markers. Premise introduction
   moves existing `expl:`/`hyp_name:` attributes; it does not construct a new
   attribute string from their names.
3. The only newly parsed libraries are the four fully scanned files. Their
   parser/typing factory strings have the non-at origins above. Clone/source
   associations and tuple constructors preserve them. Their helpers cannot
   inject a foreign Hsattr value solely because it has a matching display name.
4. Saves do not modify the logical input graph. Selected callbacks do not load
   an XML/S-expression/model or create a replacement logical task. Printer
   label maps are private outputs and do not become later term/symbol inputs.

These source cases preserve absence of `at:` before each printer call and at
every inspected term/symbol union within it. The `create_attribute` arm is
therefore unreachable, although the union/fold/map work still happens. The
separate CE flag excludes only `create_written_attr`. Export
`Q_solver_request_printer=0`; neither string/label-map capacity nor output bytes
are proved by this zero constructor count.

For consumers of Introduction's `get_hyp_name`, the same projection gives
original values `{Assert,Assume,Ensures,LoopInvariant,Requires}` or subsets;
the largest is13 bytes. The library defaults add only values of length<=8.
The same origin induction gives a continuing **13-byte hyp_name value upper**
for all five. This is not a bound for arbitrary attribute strings, raw symbols
or location filenames.

## Arithmetic and boundary of the result

Use one process-global `e<=2`, two save-entering callbacks and three saves.
There is no per-owner, per-stage, per-library or per-printer renewal. Initial
B already covers all pre-registration work. The complete lifetime request and
increment envelope is

```
Q = B + 8(3N+e)*807447 + 2*sum(C_g) + e*max(C_g).
next_tag <= Q; backing = weak_transfer(5003, 0, 0, Q).
```

Every hashcons hit/miss/failed prefix is covered; increments are bounded by
requests, not equated to them. At e=2:

| Process | Library requests | CE requests | Lifetime Q | Outer-array upper |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 1,001,234,280 | 119,576 | 1,269,789,312 | 3,809,367,939 |
| Put | 826,825,728 | 97,042 | 1,095,358,226 | 3,286,074,681 |
| First_Or_Default | 439,251,168 | 27,566 | 707,714,190 | 2,123,142,573 |
| Is_Message | 51,676,608 | 2,430 | 320,114,494 | 960,343,485 |
| Input_Is_Valid | 32,297,880 | 1,888 | 300,735,224 | 902,205,675 |

The imported transfer permits later clearing, shrink and reinsertion; it does
not assume every attribute remains strongly reachable. It includes internal
rehashing and inherited rover/oversize behavior under its valid-representation
and guarded-mutation premises. For outer bound a and bucket bound b, all five
satisfy `Q<=2^62−1`, `3*max(a,b)+6<=2^62−1`, `a<=2^54−1`, and
`b+2<=2^54−3`. The native runtime limits are the same retained constants used
by R63. They guard the actual counter, array/index, bucket-growth and shrink
operands; no aggregate scan/work total is required to fit a native integer.

The earliest-violation argument remains conditional on the other retained
owner invariants and accepted source/native association premises. Hsattr can
be added to the six-owner contradiction at integration; this isolated author
packet does not claim that join has been reviewed or performed. Attribute
concatenation lengths, locations, string/formatter/Buffer limits, other private
owners and complete current-language coverage/composition/correspondence,
useful-domain comparison and final review remain separate. No successful
naming or processing semantics after caught exceptions follows from these
numerical guards alone.
