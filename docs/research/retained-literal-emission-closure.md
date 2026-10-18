# Selected literal Main: global labels and complete assembly stream

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
Under the retained compiler descriptor, the complete selected compiler assembly
stream consists of Main, its literal/bounds constants, and the already counted
file/function/CFI/property output. The previously open ordinary and constant
label endpoints have sufficient guards

```text
I = 7C + 7N + 45
next ordinary RTL label <= 39258 + I <= INT_MAX
next constant label    <= 39257 + 2C <= INT_MAX.
```

The first guard deliberately charges every Main lifetime chain constructor as
a label; it is not a claim that all I objects are labels. These are next-value
checks, protecting the final increment as well as every printed number.
The existing complete stream allowances remain
`114 + I + W + 8C` lines and `7410 + 65I + 13W + 512C` bytes.

This closes the **selected source-family emission route**, including the
external-declaration tail that differs from null Main. It does not establish
that Silver's production commands materialize the selected descriptor. In
particular, the stock `-fsplit-wide-types` option is still a proposed descriptor
input, not an option installed by this work. Actual compiler/assembler/linker
argv, source/object routing and fixed link inputs remain separate. Complete
non-label global counters, shared backing and collector capacity also remain
open. The [evidence packet](../evidence/retained-literal-emission-closure-20261018/README.md)
exports these distinctions explicitly. Independent review is pending.

## Inputs and the meaning of this closure

Use exactly the existing complete source recognizer: one `with Silver_IO;`,
the Main/SPARK shell, C >= 1 qualified direct-literal Put/Put_Line calls,
N >= 0 null statements, no declarations/use clauses, printable ASCII plus
HT/CR/LF, and decoded lengths 0 <= L_i <= INT_MAX. W = sum L_i.
The [frontend attachment](retained-literal-native-frontend.md) supplies that
source/count mapping. The selected source identity is GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

Keep the exact non-LTO O0 Linux x86-64 generic/SysV small-PIC, ordinary-PLT
descriptor, split-wide-types, no debug/verbose assembly/saved-switch output,
no profiling, instrumentation, sanitizers, stack protector/checking, function
attributes, user asm, offload, function/data sections, section anchors or
hot/cold partitioning. Retain the configured GAS CFI and base64 support,
`main.adb` basename, fixed 29-byte GCC identification string, selected target
headers and relevant installed/source behavior premise. This note does not
weaken any predecessor representation, path-size or external-service premise.

The accepted [counter review](../reviews/review-literal-counter-emission-bc69773b78.md)
supplies exactly one emitted body and Main's saved function number 1. Empty
elaboration and both String helpers consume function/declaration/storage
resources; only Main reaches ordinary lowering, RTL expansion and emission.
The [cold-layout](retained-literal-string-layout.md),
[original Main](retained-literal-original-main-storage.md) and
[complete String layout](retained-literal-string-layout-storage.md) arguments
supply their concrete constructor frontiers. In particular scalar helper return
convention queries can construct REG RTX before ordinary expansion. Their lack
of emitted bodies never implies that those constructors are allocation-free.

This joins the existing [final RTL](retained-output-rtl.md),
[constant writer](retained-native-expansion.md#literal-and-bounds-data-emission),
[null file/function outline](retained-backend-gigi.md#null-compilation-unit-assembly-emission)
and [assembler interface](retained-literal-assembler.md). It does not reprove
IRA/LRA, enlarge the source family or infer the missing whole compiler allocation
sum from those shape arguments. The conditional transfer describes the complete
output on the selected successful compiler route; proving the entire route has
sufficient capacity remains an additional obligation.

## Every ordinary-label increment has an owner

`label_num` is a file-local signed int initially 1 (`emit-rtl.cc:96`). Its
ordinary constructor increment is `label_num++` in `gen_label_rtx`
(`:2873–2878`). The generated CODE_LABEL constructor calls `rtx_alloc`, which
performs a positive GGC allocation (`gengenrtl.cc:212–243,275–298`;
`rtl.cc:223–245`). It is not a cache hit or an in-place relabeling operation.
The only other assignment that can raise the sequence is
`maybe_set_max_label_num`, used by the RTL function loader
(`emit-rtl.cc:1553–1560`; `read-rtl-function.cc:821`). That loader is absent in
this Ada source invocation; GCC selftests and PCH/LTO input are excluded.
`init_emit` records the current value as `first_label_num` and does not reset
the global sequence (`emit-rtl.cc:5979–5990`).

The retained fixed-prefix witness has 39,257 positive GGC allocation events,
without counter wrap/reset or collection. Its existing source projection
places the boundary before `Compilation_Unit_to_gnu`, and keeps source/path
metadata separate. Every possible fixed-prefix `gen_label_rtx` consumes one
of these events, hence its next label is at most 39,258. This is deliberately
not an assertion that the witness measured that label counter or that its
actual value was 39,258. The variable prefix metadata routes construct
filename identifiers, line maps and association arrays; they neither call the
RTL loader nor construct CODE_LABEL. The accepted fixed semantic-root projection
and its installed/source/configuration correspondence remain premises. The
39,257 allowance is reused solely for this conservative fixed-prefix label
projection, not for the unfinished output-family GGC lifetime sum.

The post-prefix owners are exhaustive for these label constructors:

| Interval | Ordinary-label contribution and reason |
| --- | --- |
| Original gigi, imported String/profile construction and empty elaboration | Zero. Their selected trees include LABEL_DECL for each source null, but do not materialize its RTL until Main expansion. Literal STRING_CST, bounds CONSTRUCTOR, type/layout/fold/name and annotation work do not call the RTL label constructor. |
| Two helper initial gimplifications and their allocation hooks | Zero. Conditional helper control flow constructs tree/GIMPLE labels, not RTL labels; no helper reaches `pass_expand`. The scalar return-convention inquiry only constructs/reads hard-register RTX. |
| First target-cost setup | Zero labels, with nonzero other RTL allocation. The fixed probes contain REG, CONST_INT, arithmetic operators and MEM(REG); the six actual SI move probes create SET/INSN pairs. The established [setup call graph](retained-native-expansion.md#isolation-of-the-synthetic-setup) never expands a conditional or function body. Dummy `prepare_function_start` is not `expand_function_start`; it does not create the return label. |
| Main RTL preparation | `init_emit` snapshots the sequence and creates register backing; `init_varasm_status` creates an empty pool. Neither creates a label. The unchanged default target hooks introduce no second setup/body. |
| Main expansion through final emission | At most I labels, by the accepted lifetime **chain-constructor** ceiling I, including subsequently deleted objects. This is stronger evidence than a final live-chain count. |
| Unit finishing | No further ordinary label. The selected late callbacks below emit no generated body; CFI/function/property labels use distinct sequences or fixed numeric spellings. |

The [Main expansion](retained-native-expansion.md#literal-output-through-pass_expand)
has at most N+2 CODE_LABEL requests: N+1 body labels and one return label.
The later selected schedule preserves straight fallthrough control flow.
For example, location-preserving `rtl_split_edge` creates a block note and nop;
its nonfallthrough redirection and cross-partition branches are false
(`cfgrtl.cc:1854–1963,4145–4211`). No final splitter, jump table, EH target,
thunk or instruction template adds an uncounted label. Nevertheless the
exported guard uses the larger I, so it depends only on the established
whole-schedule lifetime chain envelope, without requiring a consumer to
identify a deleted label with a surviving one.

Thus next <= 39258+I suffices for every signed increment. Assigned ordinary
label numbers are nonnegative and below that next value. Main starts with
`first_label_num >= 1`; its `max_label_num-first_label_num+1` allocation span
is at most I+1 (`final.cc:620–622,737–744`). The ordinary endpoint guard and
the existing signed UID/span check cover the subtraction and final +1.
The byte size/backing of that vector stays in its storage owner.

## Constant, CFI and final-scan endpoints

`const_labelno` starts at zero. Its four increment sites are tree descriptors,
RTL descriptors, static return space and hot/cold function partitions
(`varasm.cc:84,2085,2984,3733,4252`). `varasm_cc_finalize` resets it at teardown
and is not a mid-compilation increment (`:9070–9078`). The retained prefix has
no emitted function, static-return-space or partition route. Each prefix tree
or RTL descriptor has its own positive GGC allocation before the increment,
so the same 39,257 event allowance bounds its next constant label. As with
ordinary labels, this is a bound, not an observed value or empty-table premise.

After the prefix the four sites have these complete selected cases:

1. **Tree descriptors:** at most 2C fresh entries from the actual Main literal
   and bounds addresses. Original imported types/profiles, the ignored external
   variables/Boolean constants and empty elaboration introduce no static data
   reference. The cold helper expressions are scalar parameter arithmetic;
   their initial gimplification has no addressable aggregate/static temporary.
   Main's gigi materialization site is `tree_output_constant_def` for its
   bounds argument (`trans.cc:9351`); direct literal address expansion supplies
   the other entry. The two-field bounds initializer and string contents
   contain no further addressed constant. The retained rooted-pool argument
   counts fresh entries across the whole selected lifetime, including repeated
   requests and collection; it does not merely count final live entries.
2. **RTL descriptors:** zero new entries. The target-cost arithmetic only
   creates CONST_INT, not memory-pool descriptors; recognition probes do not
   emit instructions, and the six SI moves have REG/MEM(REG) operands. Main's
   local SYMBOL_REF addresses, ordinary DI register moves, direct void calls,
   small frame immediates and integer `.long` emission do not force a constant
   to memory. The no-spill final RTL argument excludes a later reload pool.
   `CONST_INT` caching is separate nonzero storage, not this pool.
3. **Static space:** zero. Its sole ordinary call is the PCC aggregate-return
   branch of `expand_function_start` (`function.cc:5124–5139`); Main returns
   void and the helpers never reach this function. Scalar return-convention
   queries cannot take that branch.
4. **Partitions:** zero. Main has no `has_bb_partition`, and no other body
   calls `assemble_start_function` (`varasm.cc:2075–2085`).

Consequently the previous `39257+2C <= INT_MAX` condition now has a complete
selected label-source derivation. This does not by itself complete shared
tree-pool hash backing, insertion-capable lookup counts, replacement lifetime
or collector accounting. Those are different consumers; the aggregate must
not enable its full pool-capacity predicate merely from this endpoint.

CFI uses its own zero-initialized unsigned-long sequence. Only Main reaches
the CFI pass, with at most five label calls. `dwarf2out_cfi_label` converts the
post-increment result to int before formatting into a 20-byte buffer
(`dwarf2cfi.cc:208,473–482`). Its temporary is 0..4 and next value <=5, so
both conversion and the actual buffer are protected. The function-definition
sequence is already closed at next 4, while Main's labels read its saved 1:
`.LFB1` and `.LFE1`. Property notes use the fixed numeric labels 0..4.

The global signed `insn_counter` starts at zero and increments only in
`final_scan_insn_1` (`final.cc:162,2165`). Main alone is scanned. The selected
templates have no recursive SEQUENCE, `#` split, peephole reinsertion or
user asm; one visit per final chain object bounds the counter by I.
Checking I <= INT_MAX suffices; the inherited I+1 UID check is stronger.
The selected ELF macros' decimal spelling and internal `*` marker are distinct
from emitted name bytes (`elfos.h:121–130`; `att.h:76–91`). All selected
local labels fit the existing 25-byte emitted-name/26-byte NUL-inclusive
envelope. A printed-width bound alone would not establish any of these
increment/conversion facts.

## Exhaustive emission partition

The accepted registration inventory is Main, the two discarded helpers,
at most two external procedures, the hard-register dummy and B<=C registered
bounds declarations. The raw strings follow the direct constant writer.
There are no other aliases, variables, asm nodes or generated bodies.
`output_in_order` and its dispatcher can therefore process only Main and
bounds variables; undefined functions are not variable output records
(`cgraphunit.cc:2139–2167,2190–2227`). The dummy returns before emission
(`varpool.cc:585–586`). A bounds entry already written by RTL is skipped;
otherwise variable assembly delegates to the same guarded constant writer
(`varpool.cc:573–575,590–599`; `varasm.cc:2575–2601`). It cannot create a
second definition. Helper removal before this phase is already established.

| Writer class | Complete charge or exclusion |
| --- | --- |
| File start, Main section/outline/alignment, function boundaries, CFI wrappers/rules, ident, GNU-stack and GNU properties | Reuse all 114 lines / 7,410 bytes from the null outline. Main still has the two-byte alignment, same no-argument void public name and same frame/CFI state. Literal calls change leafness but the proved no-local/no-spill frame retains the same four instructions and five CFI rules. |
| Final Main chain | Add I lines / 65I bytes, charging even nonprinting/deleted objects and again charging fixed instructions/labels already in 114. Selected instruction templates, ordinary labels and CFI-label notes each add at most one line. Normal O0 code-label alignment is zero; no extra alignment line is hidden in this row. |
| Literal/bounds definitions | Add W+8C lines / 13W+512C bytes. This includes every section switch, alignment, LC label and both integer lines; all payload bytes pass through the existing ASCII/base64 writer. |
| Pending external declarations | Populated by calls, but zero emitted lines under the selected default visibility, as proved below. Their list/set objects are still storage demands. |
| Other direct unit callbacks | No additional output beyond the fixed outline; the changed call/data cases are audited below. |

The selected final instructions are at most 2C local-address LEAs, 4C DI
register moves, C direct calls, 4N+14 nops and the four frame/return operations.
The fixed external names and `@PLT` syntax, register spellings and bounded
local names give the existing 64-byte instruction ceiling. Literals never
enter instruction operands as raw text. `output_asm_insn` supplies exactly
one LF for each nonempty selected template (`final.cc:3428–3607`); templates
contain no statement separator/embedded LF. Empty blockage outputs nothing.
CFI rules are the five scalar directives, not raw DWARF or escape records.

**Pending externals are not the null empty-list case.** Final operand walking
calls `assemble_external` for the used Put/Put_Line declarations
(`final.cc:3625–3643,3692–3702`). The set coalesces repeat declarations, so
there are at most D<=2 pending entries (`varasm.cc:2808–2854`). Gigi creates
fresh FUNCTION_DECLs and applies no visibility/weak attribute for these
profiles (`utils.cc:3703–3774` and the accepted profile frontier).
Fresh tree storage is cleared and `VISIBILITY_DEFAULT` is enum value zero
(`tree.cc:1330–1335`; `coretypes.h:447–453`). The selected IPA route has no
alias/clone/visibility-changing replacement for either external declaration.
`default_elf_asm_output_external` can only call `maybe_assemble_visibility`,
which returns without output at default visibility
(`elfos.h:482–485`; `varasm.cc:6897–6909,8615–8625`). Even a true
`binds_local_p` guard does not change that final zero-output result. The
libcall list remains empty because no compiler-generated libcall is present.

At `toplev.cc:498–591`, sanitizer/offload/transaction/weak hooks retain the
null exclusions. The shared RTL constant pool has no selected entries to
emit; the additional tree constants are handled by their own writer.
Object blocks still require excluded section anchors; merely adding `.rodata`
does not enable that route. The unit has no personality/LSDA, so the indirect
DWARF pool remains empty. GAS-CFI finishing returns before raw frame-section
output (`dwarf2out.cc:750–780`; `dwarf2asm.cc:1066–1071`). No-debug hooks,
saved switches, LTO metadata and plugins supply no additional text.

The x86 `code_end` hook remains without a thunk: new calls are direct PLT
calls, local data addresses are RIP-relative, return is ordinary, and there
is no indirect call/jump, split stack or nondefault return/branch thunk mode
(`i386.cc:6149–6159,6414,6435–6548,6587,17405,17489,17656,17694–17695`).
It cannot introduce a second function or late ordinary label. Target file end
emits only the charged GNU-stack/properties; each possible property-note
branch is already included. These are output exclusions, not exclusions of
all allocations made by the called routines.

Every selected nonempty statement or label occupies one charged physical
line. There is no include/macro/line marker, user asm, source-comment output
or literal LF. The longest data line remains <=512 bytes, and `.rodata`
contains at most W+22C bytes with zero data relocations. Thus the prior
assembler stream, sections, symbols and relocation interface consumes the
**complete** selected stream once the local guards and descriptor premises
hold. GAS's own counters, allocations and optional generated notes remain
owned by its existing packet; they are not extra GCC-emission rows here.

## Integration and evidence boundary

`derive.evaluate_source(raw)` uses the unchanged pinned recognizer and current
byte alphabet. `derive.evaluate(C,N,W,Lmax)` is the arithmetic join for a parent
that already has those recognized counts; it also supports mathematical
endpoint tests. Both expose source-family closure, explicit local guards,
the unchanged assembly interface and separate false production-materialization,
non-label-counter, backing/collector and whole-pipeline flags.

The parent may remove the complete-stream and RTL/constant-label *source-family*
residual from `Main_assembler_object_interface`, `Main_GAS_BFD_storage` and the
Main-object side of the linker assessment, subject to the exported guards.
It must retain their actual production invocation/materialization residuals,
the linker's fixed-object frontier and every independent capacity check.
This packet does not authorize turning those aggregate predicates true while
those inputs are absent. No imported allocation source is assigned zero by
this emission result.

The manifest freezes 44 complete GCC/Ada source identities and 33 historical
Silver inputs at `13daeca1e97eef2d0894f6f5175789677df54ce9`. The additional
generator source is retained compressed from the same upstream source tree;
the other files match existing checked-in manifests. Focused offline checks
verify identities, counter/writer landmarks, interface equality, boundary
arithmetic and complete-source recognition cases. They support the handwritten
case argument; they are neither a GCC simulation nor machine-checked C++
semantics. No native compiler, capture, build, proof or solver run was made.

Selected settings: GPT-6 Astra / Extra High, assigned by parent. Runtime
confirmation and token/cost measurements are unavailable. Round start:
2026-10-18 22:13:53 UTC; the check record gives completion and elapsed wall
time separately from checker runtime. Scope owned: this note and its evidence
directory. Oracle, tools, production pins/admission, aggregate, GitHub, durable
memory and harness state are unchanged.
