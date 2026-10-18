# Literal function/symbol counter and emission review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Frozen source/interface target:
`bc69773b786a6fbc47050a084ff3f5aa72807075`.
Reviewed [argument](../research/retained-literal-counter-emission.md) and
[evidence packet](../evidence/retained-literal-counter-emission-20261018/README.md),
including its callable, interface, source/history manifest and retained results.
The selected registration, function-number and counter-to-emission interface
is accepted. Two nonblocking source-description clarifications are recorded
below; neither changes the exported arithmetic or requires native validation.
This report does not yet review a subsequent aggregate attachment.

## Governing scope and reused evidence

The review follows the Oracle's complete-chain, same-source and universal
composition requirements. It assesses the existing research family: one
`with Silver_IO;`, the Main/SPARK shell, C >= 1 direct qualified literal
Put/Put_Line calls, N >= 0 nulls, no declarations/use clauses, and each literal
length <= INT_MAX. It retains the selected GCC/configuration, no-debug,
non-LTO, O0 Linux x86-64 SysV descriptor and original final-RTL/data/invocation
premises. Source-to-installed-behavior correspondence remains an external
dependency premise. No language, tool option, Oracle or physical-resource
boundary change is authorized or inferred.

I reused the accepted [String-layout review](review-literal-string-layout-bd15740afc.md)
and [warning/body-frontier review](review-literal-warning-residual-6f3a5af341.md).
Their two cold helpers, constant scalar profiles, no executable helper references,
empty elaboration and subsequent discard conclusions are inputs here. The
historical XVE explanation correction remains resolved. I did not repeat that
folding proof, native capture or successful broad validation.

## Registration and function construction

The empty elaboration constructor is a declaration construction, not a graph
definition. `create_subprog_decl` and `finish_subprog_decl` set its declaration,
result, attributes and names; `gnat_pushdecl` selects translation-unit context
and its global `add_decl_expr` does not enqueue executable code
(`utils.cc:3703–3818,889–997`; `trans.cc:9103–9136`). The selected declaration
has no alias, hard-register, linkonce, versioning or function-specific attribute.
`rest_of_decl_compilation` explicitly excludes FUNCTION_DECL from variable
finalization (`passes.cc:176–250`). Global finishing does not finalize this
nonexternal function (`utils.cc:6490–6545`).

The empty-BIND guard skips the sole body-finalization arm
(`trans.cc:698–723`); that arm is the gigi route to `finalize_function` or
`get_create` (`utils.cc:3874–3892`). Main is not nested in the elaboration,
and neither Main's actual statements nor constant bounds initializers contain
an elaboration reference. Thus neither explicit finalization nor later graph
discovery registers it. Its declaration, result, function/EH/machine state and
saved BIND still require their own storage accounting.

I inspected the entire selected `allocate_struct_function` continuation
(`function.cc:4848–4915`), including the direct invocation of the target hook
after installing `cfun`. EH initialization creates only state and sentinel
vectors; machine initialization sets fields; ABI override selects SysV.
`ix86_set_func_type` and `ix86_set_indirect_branch_type` do not introduce a
body on the selected no-attribute path. In the full current-function hook,
the default target/optimization nodes and FP flags agree, SI is already
call-used for SysV, and the normal/default call-saved state makes both
register-reinitialization branches false (`i386-options.cc:3265–3580`).
Null alignment strings return before the alignment cache. The target relayout
hook is the default no-op; the selected implementation and thirteen target
headers provide no override. Result/parameter relayout has only constant
scalar/void sizes, so it introduces no further size function.

The scalar return-convention inquiry also matters: void returns stop immediately
in `aggregate_value_p`, but the helpers' u64/u128 returns reach the x86
return-in-memory and return-register queries. Their scalar SysV classification
and `hard_function_value` continuation construct/read register RTX, not a
function, symbol, constant-pool entry or label (`function.cc:2055–2148`;
`i386.cc:2254–2790,2792–2946,4268–4409,4451–4490`;
`explow.cc:2332–2361`). The default function-ABI query does not register a
callee (`function-abi.cc:193–200`; `target.def:5470–5476`). This verifies the
counter projection without assigning those storage requests zero cost.

Empty elaboration allocates before context/Main translation. Main allocates
in its body translation before compilation-unit finalization. Only then does
`finalize_size_functions` allocate the bit-size and byte-size helpers in
creation order. Initial gimplification reuses each existing function structure
(`trans.cc:5994,4024`; `cgraphunit.cc:2562–2594`;
`stor-layout.cc:275–292`; `gimplify.cc:21965–21977`). The accepted fixed-prefix
null-declaration allocation consumes no definition number. The selected
sequence is therefore 0/1/2/3, next 4, four nonnull allocations, three
finalized/initially gimplified definitions and one ordinary-lowered/emitted body.

## Indirect graph routes and monotone counters

The registration inventory is Main + two helpers + D distinct called output
declarations + one hard-register dummy + B distinct registered bounds-pool
declarations. Main's graph walk discovers actual calls/address/load/store
references, static locals and EH dependencies; the retained body excludes
additional statics, personality, OpenMP children and executable size-helper
references (`cgraphbuild.cc:142–154,218–393`). Raw strings retain their accepted
direct constant-emission route. Repeated `get_create` calls reuse existing
nodes (`cgraph.cc:658–712`; `varpool.cc:136–166`). The dummy is unconditional
for this unit because gigi establishes `first_global_object_name` before
translation (`trans.cc:367–370`; `utils.cc:6459–6488`).

I challenged both recursive registration continuations. Nested-function
registration requires a FUNCTION_DECL context, absent here
(`tree-nested.cc:129–146`). Assembler-name insertion may invoke the language
name hook, but GNAT uses the default identifier-only naming path. The x86
mangler reads the existing graph node with `get`, not `get_create`, and its
version/dispatcher/resolver branches are absent. The selected headers contain
no PE subtarget mangler (`symtab.cc:161–195,412–423`;
`langhooks.cc:140–182`; `i386-features.cc:5511–5534`). Ordinary frontend
finalization does not enqueue the middle-end new-function insertion path;
the accepted schedule adds no generated body through that queue.

UIDs start at 1 and order at 0, each registration advances both once, and the
selected unit has no top-level-asm order increment. Removal unlinks/releases
nodes without rewinding these counters (`cgraph.h:2558–2575,3138–3196`). Hence
registrations are exactly B+D+4, next UID B+D+5, next order B+D+4. B<=C and
D<=min(2,C) imply the exported C+6/C+7/C+6 ceilings. The post-removal live
bound C+4 is not substituted for the cumulative maximum or initial-lowering
population. The sufficient signed endpoint C+7<=INT_MAX protects next values
as well as assigned values. It is an implementation representation check,
not a new admission rule.

## Emission consumers and precision clarifications

Main's boundary-label writers read `cfun->funcdef_no`, and the FDE saves that
same value. They do not read the next global definition number
(`function.h:547`; `dwarf2out.cc:1044–1053,1094–1097,1268–1270`). The actual
names are therefore `.LFB1` and `.LFE1`, five bytes each. I checked the other
definition-number consumers against the selected exclusions: debug locations,
hot/cold boundaries, LSDA/personality, profiling, ASAN, patchable entries and
hard-CFR do not introduce an enabled label family. Symbol UID/order are not
inputs to these selected writers.

Ordinary RTL labels, constant labels and CFI labels use separate sequences.
Neither helper expands RTL or reaches the CFI pass, and empty elaboration does
neither. The retained ordinary-label and constant-label endpoint guards remain
required. Main's at-most-five CFI labels also avoid the internal unsigned-to-int
temporary in `dwarf2out_cfi_label` (`dwarf2cfi.cc:475–480`); a generic decimal
width ceiling alone would not prove that conversion or a buffer safe.
The selected ELF internal-label macro's leading `*`, where present, is an
internal name marker, not an additional emitted name byte. The conservative
25-byte emitted-name/26-byte NUL-inclusive envelope remains sufficient.
Fixed public/callee names are unchanged; helper private names never reach
the stream; the dummy is skipped by the hard-register guard before variable
assembly (`varpool.cc:585–586`).

Two source-description clarifications should accompany integration:

1. The table groups condition UIDs with persistent declaration and temporary-name
   sequences. `nextconduid` is reset to 1 at every `gimplify_function_tree`,
   including Main (`gimplify.cc:82–105,21979`). Helper condition increments
   therefore do not persist into Main. DECL_UID and temporary-name increments
   still require their separate lifetime accounting. This strengthens the
   no-emission-effect conclusion and changes no exported field.
2. The scope phrase saying the helpers have no "RTL" should say no **RTL
   expansion or emission**. The scalar return-convention setup described above
   can construct register RTX before ordinary expansion. No function/symbol/
   label counter is advanced by that route, but zero emission must not be read
   as zero RTL allocation. Storage remains explicitly unclosed.

Under the inherited final-RTL/data/descriptor premises, the correction adds no
emitted bodies, names, lines, sections, symbol definitions or relocations.
Thus the existing 64-byte instruction-line and 512-byte complete-line envelopes,
and `114+(7C+7N+45)+W+8C` lines and
`7410+65(7C+7N+45)+13W+512C` bytes, remain valid under this counter join.
I have not promoted this preservation result into an unconditional stream proof.

## What this closes for #119

This result closes the previously unknown empty-elaboration registration and
the selected synthetic function/symbol-counter-to-emitted-name join. It
supplies exact function numbering and cumulative graph maxima while preserving
the existing stream envelopes. It does not supply original imported-constructor
allocation events/bytes, a complete initial-gimplifier allocation lifetime,
shared identifier/declaration/temporary/global RTL-label lifetimes, or complete
allocator/pool/collector backing composition. Invocation/materialization and
the original final-RTL/data premises remain requirements. The helper storage
packet and two helper symbol registrations must not be charged twice.

Consequently this is a completed local obligation useful for later composition,
not completion of #119 or evidence that all five aggregate conditions may be
enabled. The frozen interface correctly retains null imported-allocation totals
and false complete-global-counter, collector and whole-pipeline capacity flags.

## Evidence and round record

The retained packet reports 134 successful offline checks over 48 complete
GCC/Ada sources, including thirteen selected target headers, and 29 historical
Silver inputs at `28697404fa1971ed310d19a7ab434e593ca2b075`. Its checker runtime
is 0.190464949 seconds; its implementation-round interval is 451.227522 seconds.
Those are reused implementation measurements, not reviewer execution times.

I independently checked all 48 complete source length/SHA-256/Git-blob
identities, all 29 historical input identities, and exact path/length/SHA-256
matches in each retained origin manifest: 0.169530474 seconds. I additionally
confirmed the supplemental `function-abi.cc` and `explow.cc` lengths/hashes
against the retained `real-function-start-source-identity.json` and
`rtl-constructors-source-identity.json` respectively. These sources have the
same GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` identity premise.

A focused callable audit reproduced the frozen interface and entire C=1,N=0
result, checked 135 selected B/D combinations and endpoint cases including
the last passing/first failing signed check and arbitrary-precision large
counts, and checked the emitted-name width arithmetic: 0.005313969 seconds.
These offline Python checks support source review; they do not simulate GCC
or mechanically prove C++ control flow. The successful 134-check suite was
not rerun. New native compiler/prover/debugger/solver workloads: zero.

Actual host: Linux 7.0.14 x86-64, LP64. Selected reviewer settings: GPT-6 Astra /
Extra High, assigned by parent. Runtime model/effort confirmation and token/cost
measurements are unavailable. Review ran from 20:53:38 to 20:57:54 UTC,
256 seconds through assessment and report preparation. Intended outcome: challenge hidden
registration/function constructors and their emission consumers. Achieved:
bounded acceptance with the two nonblocking precision clarifications above.
Only this report is owned/edited; the parent owns implementation corrections,
aggregate integration, GitHub tracking, publication and durable memory.
CLI memory was not updated. The child harness goal query returned null;
no goal state was changed.
