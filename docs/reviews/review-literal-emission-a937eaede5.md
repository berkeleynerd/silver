# Independent literal emission closure review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted at **`a937eaede5b01b438b2b2fb4dccc49cb3a8469d5`**, under its exact
selected descriptor, inherited source-shape/fixed-prefix arguments and relevant
installed-behavior premise. No material defect was found in the label-source
closure or complete selected compiler-stream partition. This does not establish
production invocation/materialization, fixed linker inputs, complete non-label
counters, shared backing, collector or whole-pipeline capacity.

The exact inputs are [the source note](../research/retained-literal-emission-closure.md)
and its [evidence packet](../evidence/retained-literal-emission-closure-20261018/README.md),
including derive.py, check.py, source-manifest.json, both recorded results and
the supplemental compressed generator. Relevant inherited inputs include the
accepted literal final-RTL, null emission outline, original String/Main/helper,
counter/emission, pool and assembler interfaces. The Oracle and applicable
assurance/trusted-boundary and workflow requirements remain unchanged. This
review does not repeat the earlier IRA/LRA or full fixed-prefix proof.

Selected reviewer: GPT-6 Astra / Extra High, explicitly assigned by the lead.
Runtime-setting confirmation and token/cost measurements are unavailable.
Review started at 22:23:32 UTC; source inspection and focused checks completed
at 22:27:00 UTC (208 seconds, excluding final report authoring), on Linux
x86_64. Work used an isolated checkout of the freeze and retained sources.
Compiler, debugger, capture, build, proof/prover, solver, network and broad
suite runs are zero. No predecessors, aggregate, Oracle, tools, admission,
GitHub, durable/CLI memory or harness state were changed by this reviewer.

The ordinary label endpoint has a valid allocation witness, rather than an
assumption that the prefix label counter starts empty. `emit-rtl.cc` declares
file-local label_num=1, increments it in gen_label_rtx, and otherwise raises it
only through maybe_set_max_label_num's excluded RTL-loader route. init_emit
records a per-function starting value and does not reset that global sequence.
The generated CODE_LABEL constructor is neither excluded nor one of the
special cached/wrapped RTX constructors (`gengenrtl.cc:145–175,212–243,275–298`).
It calls rtx_alloc, whose path performs a positive GGC request
(`rtl.cc:223–245`). Thus each possible prefix label increment has a distinct
event in the retained 39,257-event allowance.

The transfer of that fixed allowance remains conditional on the established
source projection at the pre-Compilation_Unit_to_gnu cut. Variable filename,
line-map, association-array and related metadata work does not create ordinary
RTL labels or invoke the alternate loader. This is the required semantic
reason the old fixed event allowance applies; the numeric witness alone would
not prove a universal prefix statement. The note keeps this distinction and
does not substitute the witness's byte total for a variable storage bound.

The post-prefix exclusions are consistent with the accepted original-constructor
frontier. Original gigi creates source-null LABEL_DECLs but does not expand
them into CODE_LABELs. Imported String/profile/type/fold and empty-elaboration
work adds no label source. The two size helpers do initial gimplification,
including tree/GIMPLE control flow and nonzero allocation, but do not reach
ordinary expansion. Scalar return-convention queries can allocate hard-register
RTL; that fact does not supply a label or aggregate-return-static-space route.

The first target-cost setup was checked separately from those helper exclusions.
backend_init_target brackets init_expmed, init_lower_subreg, init_set_costs,
init_expr_target and IRA setup with the dummy function. The first two construct
or mutate arithmetic/REG/CONST_INT cost graphs, not expanded conditional code.
init_expr_target performs recognition on SET/REG/MEM(REG) probes. init_set_costs
performs two sets of three actual SI moves with REG/REG and REG/MEM(REG)
operands. These moves allocate SET/INSN objects, but the selected valid-address,
nonconstant move path does not create labels or force constants to a pool.
The inherited target-cost call-graph projection excludes the vector-broadcast
MEM(SYMBOL_REF) case and the unselected target extensions. Dummy
prepare_function_start is not expand_function_start and does not allocate its
return label. No zero-allocation claim is inferred from these zero-label facts.

For Main, **I=7C+7N+45** is explicitly a lifetime chain-constructor allowance,
including deleted objects, in the accepted final-RTL argument. It is not merely
a final live-chain count. Main expansion already owns the N+2 possible ordinary
labels, including the return label. The selected later straight-fallthrough
schedule has no uncounted nonfallthrough split, jump table, EH target, thunk or
template-generated label. Charging all I chain constructors as labels therefore
conservatively gives **next ordinary label <=39258+I**. Checking that next value
against INT_MAX protects the last increment, not just the largest printed name.
The per-Main label alignment span is <=I+1; the separate UID/span guard is
retained, and vector storage remains outside this endpoint claim.

The constant-label inventory is complete at the four increment sites in
varasm.cc: tree descriptor, RTL descriptor, static return space and function
partition. Its initial value is zero and its teardown reset creates no further
increment. Prefix tree/RTL descriptors allocate before incrementing, while the
prefix has no emitted-function/static-return/partition route. Post-prefix tree
descriptors retain the reviewed whole-lifetime **2C** upper bound for actual
literal/bounds addresses, including repeat lookups and collection behavior.
Original imports/helpers supply no additional addressed aggregate or static
temporary. Target probes and selected Main instructions add no RTL-pool
descriptor. Main returns void, helper bodies never reach expand_function_start,
and no body is partitioned. Therefore **next constant label <=39257+2C** has a
complete selected source argument. It does not establish the separate hash
backing, replacement or collector bounds.

The other exposed endpoint consumers are appropriately separate. CFI's
unsigned-long counter supplies at most five calls, so its signed temporary is
0..4 and next value <=5; the actual 20-byte local buffer is sufficient.
Main's saved function number remains 1 while the already reviewed next
function-definition number is 4. Property notes use fixed numeric labels.
The signed final-scan counter is charged against I. In the ordinary final pass,
final_start_function_1 advances the shared first pointer past any initially
scanned notes before final_1 consumes the remaining chain
(`final.cc:1695–1705,4269–4272`); those visits are not duplicated. The selected
templates have no recursive SEQUENCE, split/reinsertion or user-asm path, and
no other body reaches final scanning. The existing text/CFI-location guard
31C+4N+22 <= INT_MAX is preserved.

The complete compiler writer partition is supported. Only Main and registered
bounds declarations can reach the unit's definition writers; discarded helpers,
undefined functions and the hard-register dummy add no definitions. A bounds
entry already written by RTL is skipped, preventing a second definition. The
114-line/7,410-byte fixed outline conservatively retains all file/function,
alignment, CFI, identification, GNU-stack and possible property output. The
nonleaf literal Main still has the accepted no-local/no-spill four-instruction
frame and five CFI rules. The I-line/65I-byte chain row and W+8C-line/
13W+512C-byte constant row preserve the predecessor's deliberate overlaps;
they do not subtract fixed labels or instructions based on an observation.

The pending-external tail is correctly distinguished from null Main. Operand
walking reaches assemble_external for the used Put/Put_Line declarations, and
the pending set deduplicates them. Fresh external FUNCTION_DECLs have default
visibility; the selected profile attributes and IPA route do not change it.
assemble_external_real reaches the selected ELF macro, whose implementation
only conditionally calls maybe_assemble_visibility. That function returns
without output for VISIBILITY_DEFAULT, even if the preceding binds_local_p
condition is true (`varasm.cc:2749–2787,6897–6909,8615–8625`). The pending
list/set objects remain real storage demands; no empty-list premise is used.
No selected generated libcall populates the other pending list.

The late toplev writer list was checked against the source. Sanitizer, offload,
transaction, weak, LTO, plugin and saved-switch alternatives are excluded by
the descriptor and source frontier. There is no remaining shared RTL pool,
anchored object block, personality/LSDA or indirect DWARF pool. GAS CFI returns
before raw frame-section output. The x86 code_end hook cannot create PIC or
indirect/return thunks from direct PLT calls, RIP-relative local addresses and
the selected ordinary return; split-stack/thunk modes are absent. Target file
end adds only the already charged GNU-stack/property routes. This accounts for
output, without claiming these callbacks perform no allocations.

Consequently the selected compiler stream retains exactly the existing
interface bounds: **114+I+W+8C lines**, **7410+65I+13W+512C bytes**, longest
line 512 bytes excluding LF, and `.rodata` payload <=W+22C with zero data
relocations. Literal bytes are handled by the existing ASCII/base64 writer,
not inserted into instructions. The default-visible external tail adds no
extra directive or name family. All selected labels fit the inherited
25-byte emitted/26-byte NUL-inclusive envelope after the endpoint guards.
GAS's own optional notes, representation guards and allocations remain owned
by its separate packet.

The [independent focused checker](check-literal-emission-a937eaede5.py) and
[result](check-literal-emission-a937eaede5.json) passed in 0.105 seconds. They
verify nine critical source identities and four historical shape/interface
inputs, check the supplemental gengenrtl bytes against both their retained
compressed copy and the existing full-source fetch manifest at the exact GCC
revision/URL, and challenge the constructor/counter/external-writer landmarks.
They independently solve last-fitting/first-failing ordinary, constant and
text endpoints, compare three unchanged assembler-interface compositions,
and exercise accepted quoted/empty source plus a rejected declaration route.
The worker's 302-check/44-source/33-repository-input success remains retained
evidence, not a new broad replay. Textual landmarks and finite arithmetic tests
support the reviewed source argument; they are not a C++ semantic proof.

The parent may remove the selected compiler-stream and RTL/constant-label
source-family residuals only when joining these guards and descriptor premises.
The production option/argv/object routing and fixed link-input materialization
residuals must remain. In particular this review does not install
`-fsplit-wide-types`, turn the three aggregate assembler/GAS/linker conditions
unconditionally true, or close any non-label counter/shared-backing/collector
obligation. Integration is outside this bounded review.
