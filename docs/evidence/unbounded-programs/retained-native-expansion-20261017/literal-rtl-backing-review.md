# Literal-output helper source review

Research #119, 2026-10-18, Linux x86_64. No native tool execution.

The native-expansion lane derived direct split/alias/LRA helper bounds from
the independently reviewed `80471c09e6` RTL contract. A separate read-only
subthread traced DF scan generations, call-reference creation, hard-register
refresh rescans and note construction. The implementing lane then checked
that derivation against the call collector/rescan, canonical-register setup,
reload reset and note-constructor sources before integration.

The subthread separately reviewed the direct helper section and arithmetic.
It verified the four static recognition patterns and88-byte request ceiling,
10C live24-byte instruction-register records, the register growth
`floor(3K/2)+1`, recognition growth `max(floor(3(U-1)/2),U)`, pool reuse and
release order, alias-vector reuse, operand arrays and constraint-stack sizing.

One defect was found: `vec_prefix::m_alloc` has31 bits, although its sizing
temporary is unsigned32. The split-graph, alias rounded-capacity and
constraint-stack checks/prose were corrected. A focused boundary check
now exercises the rounded GC vector's stored-capacity transition. The
combined stronger LRA-register condition already excluded the problematic
range; the correction makes each local representation claim accurate.
No other material finding remained in that direct-helper review scope.

During DF integration the implementing lane also checked the unsigned32
product `new_size*block_info_elt_size` in `df_grow_bb_info`, adding the
explicit `128*block_slots<=UINT_MAX` check before the allocator's size_t
product. The retained result passes eight focused offline arithmetic checks.

This review does not certify complete native capacity, all source constructs,
all lifetime allocations or the independent GNATprove producer. It performed
no compiler, prover, Lean, debugger, full-suite or runtime-capture work.
