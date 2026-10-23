# Ordinary Main loop-write status refinement

2026-10-23 UTC. Additional bounded source question from the Main author,
following the ignored-child audit. Selected reviewer GPT-6 Astra / Extra High;
runtime confirmation, active elapsed time and token/cost measurements unavailable.
No author file/checker execution, native run, capture or predecessor replay.

**Every non-discarded mutable root collected from an ordinary Main whole-object
assignment or selected public procedure output has final status Entire_Object.**
An arbitrary accepted status-map interface may retain its broader Not_Written
row, but that row is unnecessary when deriving this grammar's roots directly
from descendant assignments and selected call effects.

Exact complete-member identities and numbered excerpts are in
[frame-status-source.json](frame-status-source.json). SPARK references below
refer to the existing retained raw source archive. This is source review before
the author freezes its implementation, not acceptance of its current fold.

`gnat2why-expr-loops-inv.adb:1462–1476` chooses the last explicit invariant or
variant as its target, otherwise the loop's `Loop_Cond`. Current Main has no
explicit invariant/variant, so the latter applies. `spark_util.adb:5244–5294`
computes all predecessors inside the local CFG. Its structural graph has:

- ordinary assignment/call normal continuation edges at5470–5512;
- each if/elsif/else arm's continuation at5587–5610, without pruning by the
  condition's value;
- a for-loop condition-to-exit edge and body-to-iteration-to-condition path
  at5612–5649;
- statement lists linked in reverse construction order at5688–5707.

By induction over the admitted sequence/if/nested-for grammar, every collected
assignment/procedure-call start vertex has a path to the enclosing loop's
condition. The local-depth filter at5873–5914 keeps that entire path. No
admitted statement is a source raise, assertion pragma, return, exit, continue,
goto or handler. `Is_Error_Signaling_Statement:3662–3711` therefore removes no
such statement's outgoing edge. The selected procedures have no No_Return
aspect: the normal edge test is specifically **No_Return**, not
`Always_Terminates`. Put and Put_Line's `Always_Terminates => False` consequently
does not invalidate this syntactic CFG path. Runtime iteration count, feasibility
of an if guard and completion of an environmental I/O operation are not used
to establish this structural path.

Assignments pass that relevance Boolean to `Write_Expr`
(`loops-inv:1710–1744`). Its wrapper at2079–2117 uses Touch_Expr/Not_Written only
when `Relevant_Path=False`; otherwise a whole-object identifier selects
Entire_Object through `Write_Trees.Write_Expr:2684–2702` and
`Update_Status:2393–2406`. Selected public call outputs use Write_Entity with
the same relevance Boolean and `Discard_Writes=False` (`:1640–1683`), hence
Entire_Object through `:2053–2073,2665–2678`.

`One_Level_Update:2293–2346` is monotone in its write-status ordering. A new
Entire_Object entry is inserted directly; Entire_Object upgrades Not_Written
or a partial status; a later Not_Written request is a no-op. Discard absorbs
subsequent updates, and an Entire_Object entry cannot be demoted by another
ordinary write. Whole-object Main targets select no partial component kind.
No overlay postprocessing changes the result, because current Main/fixed visible
globals have no overlays, volatile/asynchronous writers, protected components
or Part_Of state in this selected family.

`Process_Call:1640–1683` obtains both Read_Ids and Write_Ids, but iterates only
Write_Ids. It inserts only mutable object Direct_Mapping values and skips
Magic_String. Parameters are inserted only when mutable (`:1598–1627`), so the
selected String input actual of Put/Put_Line adds no root merely by being read.
Input_Is_Valid/First_Or_Default have Global=>null; Reject writes only opaque
File_System and adds no concrete frame root. Put/Put_Line add the four selected
concrete output globals, with opaque File_System excluded by the accepted
Magic_String source argument. No read-only root is implicitly added to the map.

The loop's own index is an explicit additional map entry. Here After_Inv starts
and remains True, so the actual Write_Entity call at1442–1456 gives it Discard;
the nearby generic comment about retaining the top index applies when its
relevant invariant configuration permits retention. Nested loop indexes are
unconditionally discarded at1940–1964. These discarded entries are not the
non-discarded root family above. Main's source declarations precede all loops;
generated bound-capture constants are not new mutable write roots. The separate
index invariant still has its existing cost and must not be removed because
this frame-map entry is Discard.

Thus the derived concrete root set is the distinct union of descendant
whole-object assignment targets and concrete output globals of descendant
selected procedure calls, after the existing mutable/opaque/discard filters.
Deduplication, entity identity and the source map's actual traversal order
remain required. This set result does not authorize sorting or merging lexical
identities by spelling, or dropping frame formulas on the basis of an empty
runtime iteration range. Final implementation review remains pending.
