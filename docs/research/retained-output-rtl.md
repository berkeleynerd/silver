# Retained native literal-output RTL transfer

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
continuing the [native literal-output expansion interface](retained-native-expansion.md#literal-output-through-pass_expand)
at commit `e0cffc2baa72a439cf7e33b706aa30d50e99cd5d`. This is a conditional
source argument for the selected Linux x86_64 compiler. It does not expand
Silver membership or complete the whole compiler/proof capacity rule.
The [offline evidence](../evidence/retained-output-rtl-20261018/README.md)
retains complete source files, immutable predecessor records, the arithmetic
replay and explicit limits. Source lines below count literal LF.

## Configuration and incoming interface

Use the previous selected O0, no-debug, generic x86-64, SysV, small-PIC,
default-PLT configuration, adding the stock **`-fsplit-wide-types`** option.
There is no tool modification. The default-option analysis remains historical:
it correctly permits artificial cross-call descriptor liveness. This option
is part of the proposed capacity descriptor; the native and producer argument
vectors, stored options and any exact invocation witness must account for it
before their results can be joined. The existing production commands and
admitted language are unchanged by this research packet.

Let C be the number of direct literal Put/Put_Line calls and N the number of
null statements, with C,N nonnegative and C+N at least one. Every call enters
RTL expansion as the following ordered
group, with its own descriptor d and extraction temporaries x and y:

```text
subreg:DI(d:TI,0) := local literal SYMBOL_REF
subreg:DI(d:TI,8) := local bounds SYMBOL_REF
x:DI := subreg:DI(d:TI,0)
y:DI := subreg:DI(d:TI,8)
RDI := x
RSI := y
call direct output operation
```

The two addresses are plain local SYMBOL_REFs; their selected movdi type is
LEA. There are no whole-TI references, register-address uses, source asm,
stack arguments, local EH targets, nonlocal gotos, return values, scratches,
dynamic allocation or live application values between groups. The source
argument establishing these premises belongs to the predecessor, not to an
observation of one example. The incoming lifetime ceilings are:

```text
dynamic pseudo requests P0 <= 3C; first unused number K0 <= 98+3C
chain objects I0 <= 7C+3N+12; first unused UID <= I0+1
ordinary blocks B0 <= N+4; edges E0 <= N+5; block slots <= N+6
nonchain RTL occurrences R0 <= 64C+N+16
per-instruction nonchain occurrences <= 16; operand-tree depth <= 4
initial local stack / outgoing argument payload = 0 / 0
```

These bounds preserve the distinction between live operand occurrences,
chain-constructor events and all lifetime RTX/GGC allocations.

## Wide splitting is selected and exact on this shape

`common.opt:3025–3030` declares the two splitting flags. Ordinary O0 does
not enable `flag_split_wide_types` (`opts.cc:606`), but the first pass gate
tests only that flag, then calls `decompose_multiword_subregs(false)`
(`lower-subreg.cc:1801–1805`). It runs after virtual instantiation, entry to
CFG layout and initial jump cleanup, before DF initialization
(`passes.def:460–468`). The second pass also needs the separate early flag;
the third tests the main flag (`lower-subreg.cc:1843–1849,1888–1892`).

Profitability does not depend on hoping that the option forces every split.
`compute_costs` tests wide register-move cost against word cost times word
count for both speed and size (`lower-subreg.cc:197–235,278–299`). The x86
SET-of-registers case uses `ix86_set_reg_reg_cost`; integer modes retain
8-byte units and cost four times the number of words
(`i386.cc:22001–22044,22527–22532`). TI therefore costs 8 and two DI moves
cost 2*4. The `>=` test enables TI splitting in both choices. DI itself has
word count one and is not marked as a mode to split.

Every descriptor occurrence is an aligned, one-word DI SUBREG of TI.
`find_decomposable_subregs` marks its regno decomposable and skips the inner
REG (`lower-subreg.cc:492–542`). Thus the direct-register case cannot mark
it nondecomposable; no independent whole-TI occurrence exists
(`:558–608`). Each of the six SETs has outer DI mode, so `simple_move` rejects
it as a wide move (`:350–400`). There is no full-width copy edge in the
register-copy graph, shift or zero extension. Propagation visits the initial
descriptor set once and ends with an empty queue (`:447–469`).

For each descriptor, `decompose_register` clears its old regno entry,
allocates one two-element rtvec, creates two DI pseudos and changes the old
REG node in place to CONCATN (`:618–645`). Each offset selects the appropriate
DI part; the residual offset is zero (`:650–689`). Same-mode zero-offset
`simplify_subreg` returns that part unchanged (`simplify-rtx.cc:8300–8307`).
`resolve_subreg_use` substitutes it in place and validates the change
(`lower-subreg.cc:771–804,1711–1728`). These patterns have no duplicated
operands, and DI REG is valid wherever the original DI SUBREG was accepted.
No instruction, label, edge, local slot, shift or extra move is generated.

The extra pseudo creation is exactly 2C. `gen_reg_rtx_offset` calls
`gen_reg_rtx` once then copies declaration/offset attributes; at most one
new reg_attrs record per part is needed (`emit-rtl.cc:424–443,1188–1232,
1277–1280,1306–1311`). The new pseudos have no user-variable flag.
The largest part offset is 8. The register arrays' separate doubling rule
still needs its own signed-capacity check (`:1239–1258`); a fitting logical
regno alone does not justify the doubled allocation.

The selected split pass requests three bitmap headers plus the two propagation
bitmaps, a K0-entry pointer vector with no graph edges, and a block-slot-sized
sbitmap (`lower-subreg.cc:449–469,1555–1561,1633–1639`). Only the decomposable
set and its copied queue are populated, each with at most C bits below K0.
The other sparse sets and the sub-block sbitmap stay empty. The change log
holds at most one replacement per selected instruction; its first allocation
is `5*MAX_RECOG_OPERANDS` entries and suffices (`recog.cc:224–288`).
These are logical requests, before bitmap/hash/vector/allocator rounding.
Count at most 2C REG, C two-element rtvec and 2C reg_attrs requests as the
split-specific GGC delta; the old TI REG is mutated, not newly allocated.

At this first pass DF is absent. It does not run word DCE. Once it has split
all descriptors, the cleared TI regno entries and remaining one-word DI
entries make the third pass return in its initial mode scan, before DF/DCE
or context allocation (`lower-subreg.cc:1514–1548`). No intervening selected
O0 pass introduces a multiword pseudo; the ordinary optimization gates and
target pass exclusions are the ones already checked in the
[null RTL schedule](retained-backend-gigi.md#o0-rtl-shape-through-entry-to-ira).
In particular uninitialized-register initialization requires optimization
(`init-regs.cc:155`). The active instruction splitter has no selected match
for these DI register/symbol moves or direct calls. The TI move splitter is
TI on this target, and the root-wildcard splitter requires a TLS MEM; neither
matches (`i386.md:2784–2789,23762–23766`).

There are now 5C lifetime dynamic pseudo requests, of which at most 4C remain
referenced: two descriptor parts and two extraction temporaries per call.
All definitions are whole-DI writes. Ordinary backward liveness kills each
part at its defining SET; the partial-TI read/modify rule no longer applies.
Each of those four pseudos is defined once and used once within its own group.
No pseudo is live at a call, across another group or at a basic-block boundary.
The groups are indivisible on the predecessor's straight fallthrough CFG.

## IRA assigns caller registers without spills

This claim uses the allocator's source, not merely the small liveness count.
O0 selects `ira_conflicts_p=false` and the fast allocator
(`ira.cc:5735`, `ira-color.cc:5388–5391`). The path has no natural loops or
non-root allocno regions. Each referenced DI pseudo needs one allocno object;
the dead TI entries do not become allocation candidates. No initial-value,
scratch, equivalence or region-boundary-copy route adds pseudos
(`ira.cc:3630–3657,3711,5789–5915`; `ira-emit.cc:1252–1265`).

The allocation classes retain general registers:

- For the descriptor's SYMBOL_REF definition and DI register use, the
  enabled `*movdi_internal` general-register alternatives have zero register
  class cost. The immediate alternative is `r/i`; its PIC symbol selects
  the LEA output type. For register copies, `r/rem` is available. General
  subclasses tie at zero, and their union is GENERAL_REGS. Non-integer
  alternatives either have ignored `*` constraints or positive `?`/move
  costs. Thus each descriptor part prefers GENERAL_REGS.
- Each extraction has one DI copy definition and one move to RDI or RSI.
  The latter's special hard-register cost is 2f for general classes, and
  may be -f for its dying source's singleton destination class. Here f is
  the positive block frequency. General registers remain cheaper than
  memory: the hard-register use alone contributes 6f of memory cost on the
  selected generic tune, while its general cost is 2f and its copy-definition
  general cost is zero. If best is GENERAL_REGS, O0 uses it directly. If best
  is DIREG or SIREG, the target marks that singleton likely-spilled, so the
  selected allocation class includes its alternative class, which includes
  GENERAL_REGS. It may also contain other registers; exact equality is not
  needed below.

These steps use `i386.md:2594–2598,2657–2693`,
`ira-costs.cc:765–800,863–973,1051–1080,1338–1446,2186–2277`,
`ira.cc:1635–1643`, `i386.cc:21202–21222,21618–21634,21646–21714`, and
`x86-tune-costs.h:4158–4188`. Cost-class tie unions and class translation
preserve all allocatable GPRs (`ira.cc:987–1045,1079–1132`). The x86 target
does not override the identity `ira_change_pseudo_allocno_class` hook.
Each pseudo has only two references, so this class reasoning does not
accumulate C references into one class-cost integer.
No equivalence saving changes the memory comparison: at O0 the existing
REG_EQUIV-note scan creates no new equivalence (`ira.cc:3686–3712`), and
`calculate_equiv_gains` requires the second, expensive cost pass
(`ira-costs.cc:2068–2072`). Neither applies to this entry shape.

The allocno hard-register cost vector starts null. O0 skips its detailed
per-hard-register costs and hard-move processing (`ira-costs.cc:2475–2523`).
No value crosses a call and DI needs one hard register, so call-cost and
unaligned-multiple-register adjustments allocate no vector
(`:2663–2753`). The conflict/copy pass's cost-producing traversal requires
`ira_conflicts_p` (`ira-conflicts.cc:812–843`). The special user-variable
caller-clobber exclusion does not apply to these generated pseudos
(`:855–871`). Thus the fast allocator uses its null-cost-vector branch,
which takes the first available class register (`ira-color.cc:5267–5360`).

The x86 allocation order lists caller-used general registers first, then
callee-saved general registers, then floating/vector/mask registers
(`i386.cc:23651–23698`). IRA preserves that order after filtering
(`ira.cc:466–503`). Among the first group are the nine usable SysV caller
GPRs RAX, RDX, RCX, RSI, RDI and R8–R11. SP and other fixed/eliminable
registers are not counted. DI occupies one word in each of these registers
and has no register-filter restriction (`i386.cc:21725–21900`).

For any pseudo, the union of conflicts over its complete live range can
exclude at most the other three pseudos in its group and the two explicit
argument registers. No other group's pseudo overlaps it; call clobbers
occur after its lifetime; the blockage also occurs outside those lifetimes.
At least `9-3-2=4` caller GPRs therefore remain available at each assignment,
independent of allocation order and C. The fast allocator chooses one of
them before reaching any callee-saved or non-general register. All referenced
pseudos are assigned, with no local spill slot and no new callee save.

## LRA reaches the unchanged-assignment exit

LRA still allocates its unused Pmode pseudo and terminal deleted note
(`lra.cc:2420–2439`). Its four register-copy moves per group take the
`simple_move_p` shortcut: an assigned pseudo's class is its actual hard
register's class, and integer-to-integer move cost is 2
(`lra-constraints.cc:221–238,4233–4255,4354–4362`). Each symbol definition
matches the general-register/immediate movdi alternative with no reload.
There is no invalid address, subreg, match, early clobber, secondary-memory
move or failed equivalence to repair. The direct call's symbol satisfies
its call constraint; its size operand is unconstrained
(`i386.md:20495–20500`). Nop and blockage have no constrained operands.
The zero-loser alternative route only records recognition/class metadata
(`lra-constraints.cc:4335–4570,4688–4710`).

Elimination finds no eliminable register in these instructions or symbol
addresses; frame-offset recomputation does not alter them
(`lra-eliminations.cc:1504–1563`). Inheritance has no spilled original or
reload pseudo. Its reload-pressure set remains empty; no pseudo spans a
call or is global to an EBB, so neither the pressure split nor call-save
split is selected (`lra-constraints.cc:6297–6338,7075–7520`). The optional
REG_RETURNED optimization also has no such note. No inheritance/split
pseudo or queued replacement is produced.

The first LRA live-range construction retains the IRA assignment. IRA and
LRA both scan backwards, mark outputs live, kill whole non-early-clobber
outputs, advance the live point and then mark inputs live
(`ira-lives.cc:1391–1405,1501–1524`,
`lra-lives.cc:865–967`). Both use `non_conflicting_reg_copy_p` for the same
ordinary copies (`ira-lives.cc:1392`, `lra-lives.cc:791–808`). The calls see
no live pseudo before their argument-register inputs, so their clobbers
add no pseudo conflict. These whole-DI SETs have no early clobber,
paradoxical subreg, hidden operand or new constraint. Thus LRA's compressed
point numbers can differ without changing pseudo overlap or the explicit
RDI/RSI conflicts; shared hard registers for nonoverlapping ranges remain
valid. Every pseudo definition still has its later use, so local dead-code
removal deletes none (`lra-lives.cc:726–783`). The block-boundary pseudo
sets remain empty, making the secondary live-range rebuild unnecessary
(`:1131–1158,1516–1534`).
The assignment correctness scan therefore spills none
(`lra-assigns.cc:1163–1277`). There is no new or unassigned referenced pseudo
for `assign_by_spills`; its failure and spill sets remain empty
(`:1394–1610,1624–1717`). Undo inheritance likewise has empty transform sets.

Consequently there are exactly two constraint iterations, one live-range
construction and one assignment invocation, with at most one inheritance
and undo pass. The second constraint pass has no reload and an empty work
stack; the outer spill test sees no unassigned referenced pseudo
(`lra.cc:2500–2652`, `lra-spills.cc:642–651`). This is a shape-specific
termination argument. The source's checking-only 30-iteration diagnostic is
not a general convergence bound (`lra-assigns.cc:1704–1714`).

Final rewriting replaces pseudo numbers with assigned hard-register numbers
and may delete redundant copies; it introduces no operand subreg or new
instruction (`lra-spills.cc:770–878`). The ordinary potentially throwing
calls still have no local EH/nonlocal target, so post-LRA subdivision adds
no block. The subsequent O0 reload cleanup does not create code.

## Frame, CFI and final text

The active CFG-layout exit may preserve an original edge location by splitting
at most N+4 outgoing edges, adding one note, nop, block and edge each. New
outgoing edges have unknown location and do not recursively split. Across
the earlier cleanup calls there are at most N+3 merges, already charged in
I0. The source routes are the same explicit location-handling routes checked
in the [null schedule](retained-backend-gigi.md#o0-rtl-shape-through-entry-to-ira),
`cfgrtl.cc:1854–1963,4145–4211` and `cfg.cc:278–294`.

After allocation, the function has no local/spill storage, outgoing argument
bytes or callee-saved GPR use. At O0 it retains its frame pointer. For C>0,
being nonleaf prevents use of the red zone but does not add local payload
or a save: pushing RBP aligns SP to the ordinary 16-byte call boundary. The
return-address and saved-RBP offsets total 16; local allocation is zero.
The existing [frame derivation](retained-backend-gigi.md#selected-x86-frame-and-return-construction)
therefore applies with the leaf/red-zone branch explicitly changed to
nonleaf/zero for C>0; C=0 retains the earlier leaf case. It adds push RBP,
move RSP to RBP, pop RBP and simple return,
two frame notes and one barrier. Later ordinary cleanup can merge at most
2N+7 blocks, preserving at most one nop per merge. No call changes SP
permanently, and no extra save, probe or alignment instruction is required.

The CFI transfer also retains the same frame rules. Calls neither carry
REG_ARGS_SIZE nor have landing pads/nonlocal targets, so they add no trace
edge, CFA adjustment or args-size CFI (`dwarf2cfi.cc:1047–1108,2697–2734`).
The two pointer LEAs and register copies are not frame-related. There are
at most N+5 traces (entry, N+2 labels, two frame notes), 2N+10 row objects,
and five function CFI notes plus five possible location-label notes. The
constant CIE/FDE ceilings stay 12 CFI objects, one FDE, CIE vector length 2,
FDE CFI-vector length 10, and register-save vectors of length 17. Adjacent
linear traces have equal incoming/outgoing states and need no reconciliation.

The resulting **chain shape**, including deleted objects, is:

| Boundary | Chain requests | Ordinary blocks / edges / slots |
| --- | --- | --- |
| IRA entry | 7C+5N+20 | 2N+8 / 2N+9 / 2N+10 |
| After reload | 7C+5N+21 | same ceilings |
| After frame and later cleanup | 7C+7N+35 | same ceilings |
| After CFI / final scan | 7C+7N+45 | CFG may have been freed |

Lifetime dynamic pseudo requests are at most 5C+1, so first unused pseudo
number is at most 99+5C. First unused UID is at most one more than the chain
ceiling. There are at most 4N+14 nops, 2C symbol LEAs, 4C register moves,
C direct calls and the four frame/return instructions. No final split matches
those selected shapes. The split-before-regstack and final-output checks
extend the prior MD inspection by the plain DI-symbol and direct-call cases;
neither is TI, TLS, an indirect thunk or a vector/floating operation.

The selected length attributes give 7 bytes per local-symbol LEA, 3 per DI
register copy and 5 per direct call. The latter has four immediate bytes,
no ModRM/address byte and one opcode; the LEA has a four-byte PC-relative
displacement, ModRM, REX and opcode (`i386.md:592–680,727–802,2594–2703`,
`i386.cc:17943–18037,18100–18117`). Charge 2/3/2/1 for push/move/pop/return
as in the prior conservative frame bound. Thus the nonnegative shortening
address ceiling is:

```text
Ttext = 2C*7 + 4C*3 + C*5 + (4N+14) + 8
      = 31C + 4N + 22
```

These instructions have no address-dependent length and ordinary O0 label
alignment is zero. The one O0 shortening update preserves that ceiling.
Check Ttext against signed int before the compilation; this is a local
arithmetic condition, not the complete admission predicate.

Final call output is exactly the direct `call %P0` route on this ELF/default
PLT descriptor; SEH padding and indirect-branch thunks are absent
(`i386.cc:17716–17854`). Each symbol LEA and call emits one instruction line.
No final template returns `#` to split these patterns. The native assembly
text therefore contains at most `7C+4N+18` machine-instruction lines,
excluding directives and labels. It contains at most 2C local-symbol
PC-relative references and C external call references. The assembler/linker
must still establish their encodings, relocation records and final reach;
this compiler packet does not treat the instruction-attribute ceiling as
the completed object/link proof.

## Scope of the result

The packet establishes the proposed split option's effect and the selected
RTL shape through final text. It supplies the missing finite allocator
iteration argument for this literal-output family. It does not bound all
native lifetime GGC, alias/dataflow/recognizer/allocator pool allocations,
global counters, parent/child argv storage, assembler tables, object layout,
link layout or the independent GNATprove producer. Those remain composition
obligations, even when their logical extents can now be instantiated from
these formulas. A positive native witness would check the selected path;
it would not replace this universal source transfer.

Only offline source/hash/arithmetic checks were run for this packet. No
compiler, assembler, linker, prover, solver or Lean process was launched.
