# Independent review of literal Main context visits

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted under the stated selected source/behavior and fixed-unit premises:
**I <= 114 = 36 runtime + 39 new elaboration + 39 old elaboration**.
No material bound or composition defect was found. One additional excluded
context-transfer site is documented below for traceability. This acceptance
supplies the original Main ledger's context input; it does not close complete
frontend storage, original-gigi shared backing, collector or toolchain capacity.

The exact review freeze is
`684ec8ab64c0c97a4d5cb9f84c0e4ea7ba964a6c`, specifically
[the source argument](../research/retained-literal-context-visit-bound.md) and
its [evidence packet](../evidence/retained-literal-context-visits-20261018/README.md).
The original Main callable is the unchanged `d528110ba9` input pinned by the
packet. The inherited fixed closure, governing Oracle, assurance/trusted-boundary
claims, project workflow and focused #119 memory are premises/context; this is
not a fresh review of every earlier fixed-closure derivation. The preceding
original-String/Main review is retained separately at review commit `911cc98f7e`.

Selected reviewer: GPT-6 Astra / Extra High, explicitly selected by the lead.
Runtime-setting confirmation and token/cost measurements are unavailable.
Review began at 22:04:46 UTC; source inspection, focused checks and draft
completed at 22:09:40 UTC (294 seconds, excluding final polish). Actual host:
Linux 7.0.14 x86_64. The work used retained source and offline Python only;
compiler, debugger, prover, solver, build, full-suite and network executions
are zero. No GitHub write or delegation was performed by this reviewer.

The source-domain argument at `retained-native-expansion.md:4341–4370`
explicitly derives the 36 runtime specifications, two Silver specifications
and Main from the wider source-selected input/Image/concat closure. It excludes
external body loading and new compilation-unit instances, and distinguishes
the source inclusion argument from capture reconciliation. The selected direct
literal-output family is a subset. Internal generic instances do not themselves
multiply the semantic-compilation-unit key domain. The conditional use of 36/39
is therefore consistent with the inherited interface.

The runtime guard at `rtsfind.adb:1266–1327` keys each RTU chain by the parent
compilation unit, before constructing or appending a clause. Repeated RTE and
record-component callers use that same guard. `Frontend` invokes
`Rtsfind.Initialize` before parsing/semantic work (`frontend.adb:81`), and
the other two chain resets are protected by an empty runtime Entity
(`rtsfind.adb:1104–1121,1832–1843`). A successful load supplies that Entity
before the caller's `Maybe_Add_With`; subsequent loaded lookups cannot reset
the retained chain. The selected Main has a stable compilation-unit context
parent. `Append_To` delegates to `Append`, which records the list membership
(`nlists.adb:137–184,281–284`). Thus one Main clause per admitted runtime unit
is a valid bound even with repeated callers.

The new elaboration route searches Main's actual context for the same
nonlimited, non-error name Entity, writes the created occurrence with exactly
that Unit_Id, and saves the clause in the attribute cache
(`sem_elab.adb:8330–8501`). Existing-clause upgrades only alter flags. All seven
call sites pass either `Unit(Target_Rep)` (directly or through a constant local)
or `Find_Top_Unit(Constit_Id)`. The representation's sole Unit assignment is
`Find_Top_Unit(Id)` at line 10935, and its getter simply returns the field at
11508–11512. The dispatcher preserves the key. `Find_Top_Unit` uses
`Unit(Cunit(Get_Top_Level_Code_Unit(...)))`; `Find_Unit_Entity` normalizes the
instance/subunit cases (`9117–9171`). The excluded external bodies,
compilation-unit instances and concurrent subunits cannot supply extra keys.
The selected unit entities are stable through this post-analysis phase.
The 39-key bound does not rely on a claim that output calls never trigger
elaboration processing.

The old route first scans the selected code-unit context with the exact key
`Cunit_Entity(Get_Cunit_Unit_Number(Withed_Lib_Unit(...)))`. Its append helper
can run only after the same-key search succeeds in a spec or ancestor context;
it preserves Withed_Lib_Unit, and returns immediately after appending
(`sem_elab.adb:16369–16525`). Repetition consequently finds the prior clause.
An arbitrary nonunit U cannot create a new successful key. The stored clause
preserves its withed Cunit, and both searches recompute that unit's current
Entity. This matters because generic-spec analysis can reconstruct an entity
(`sem_ch12.adb:4570,4782`): changing that Entity alone cannot reopen the slot,
since the earlier clause's lookup changes with it. Compilation-unit instance,
generic-body and child-spec replacements are excluded by the selected closure.
Paying all 39 underlying unit keys is conservative without
depending on old/new mode exclusivity, cross-route deduplication, or proving
the old path zero for a Main with no separate spec or child ancestry.

Exhaustion was independently challenged with a multiline-aware lexical scan
of the manifest's 2319 Ada files, hiding comments and strings. It confirms
the ten implicit-flag setters and eleven named/direct with constructors,
including the parser and child-parent-renaming constructor; no literal
Set_Nkind/Mutate_Nkind route to N_With_Clause was found. Unlike the packet's
line-oriented constructor regex, this scan also recognizes a New_Node call
split across lines. No additional constructor was discovered. This census
supports the control-flow review; it is not an Ada parser or a universal proof.

The seven other setters require self-with, explicit child-with ancestry,
Main child status, limited-with expansion, a context use clause, a source
System with/System extension, or generic inheritance. None is selected by
the sole explicit nonchild Silver_IO with and the declaration-free ordinary
Main. The child-spec transfer, instance spec/body copy and generic-subunit
copy are likewise excluded (`sem_ch10.adb:1009–1058`;
`sem_ch12.adb:7642–7687,9885–9903,11290–11355`).

One additional transfer deserves an explicit citation in future descriptions:
`sem.adb:2163–2173` moves an instance body's context onto its specification
using Append_List in Walk_Library_Items. Its guard requires N_Package_Body
and Is_Generic_Instance, so it cannot move or multiply this Main's context.
The note's generic/compilation-unit-instance exclusion already rules it out;
the missing citation is a traceability improvement, not a material revision
to I. This review records its disposition without changing the reviewed freeze.

Parser configuration-pragmas prepend the existing list before semantic
creation; successful parsing excludes error-recovery extra withs. Suppress_All
adds a pragma. Private-with replacement requires Private_Present, absent for
these generated clauses; self-with cleanup removes use clauses. Error/name
repair and child-spec retargeting do not select successful ordinary Main.
Runtime creation clears ghost mode; ghost clause processing does not provide
an uncharged with creator. No selected list move, generic copy, reclassification
or key mutation was found that defeats the three guards.

`Compilation_Unit_to_gnu` traverses the context once (`trans.cc:6018–6025`)
under the accepted Main/body frontier. At `8333–8339`, the implicit-with arm
returns one empty alloc_stmt_list before namespace/name/entity construction.
The allocation may reuse a cached node, so charging one 32-byte request per
visit is conservative. Empty-list splicing returns the header to stmt_list_cache
and creates no link (`tree-iterator.cc:34–58,118–133`). No constant-pool
insertion, lookup or replacement is reached by this branch. Consequently
the addendum supplies at most 114 requests, 3648 caller/rounded bytes and
114 cache pushes, with H <= 2V+5C+4N+119. Its example totals and preservation
of the remaining exclusions are consistent with the frozen Main callable.

The [independent checker](check-literal-context-visits-684ec8ab64.py) and
[recorded result](check-literal-context-visits-684ec8ab64.json) verify eight
repository attachments and 15 focused retained-source identities, perform
the strengthened inventory, and check three mixed-length compositions including
0, 999/1000 and INT_MAX. They independently check the simplified event formula
`609C+24N+54D+284+114`, sum the byte rows with the added context charge, and
check H and incomplete-capacity flags. All passed in 2.132 seconds. The packet's
existing 2319-file full correspondence and 300-case arithmetic success are
retained evidence, not claimed as a new independent replay. Source inspection
supplies the general deduplication/key argument; these finite checks supply
correspondence and arithmetic evidence. Later attachment/integration requires
its own review of the composed interfaces and remaining obligations.
