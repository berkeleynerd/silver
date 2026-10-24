# Independent review: parsed GPR baseline

2026-10-24 UTC. Reviewed author
`17569ceaa8daf41892852cc4ab8b423b28d9091e` for #212 under #119.
**The enumerated primary and auxiliary backing bounds are supported in the
declared Phase 2 scope. One low-severity reset-event export defect requires a
narrow correction: [F1 / #219](https://github.com/berkeleynerd/silver/issues/219).**
The defect does not invalidate the peak Reference_Prefix backing or the three
primary table bounds. Complete GPR/producer capacity remains open.

## F1: the case selector performs a seventh reference-prefix reset

[capacity.py:188](../evidence/retained-fixed-report-composition-20261024/gpr-baseline/capacity.py#L188)
sets `reference_prefix_reset_events_upper=refs`, where `refs` counts only
declaration RHS references. Every selected configuration has six such references
and also contains `case GCC_Prefix is`. The case selector is parsed even though
its alternative bodies are empty.

In the pinned archive, under
`gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263/gpr/src/`,
`gpr-dect.adb:889–895` calls `Parse_Variable_Reference` for that selector.
`gpr-strt.adb:846` unconditionally performs `Names.Init`, and `:856` adds its
single prefix name. This is the scratch table exported as Reference_Prefix,
not the separate global GPR.Names vector. Thus each baseline has **seven**
selected reset calls and singleton pushes, while
[result.json](../evidence/retained-fixed-report-composition-20261024/gpr-baseline/result.json)
exports six at lines 1284, 1622 and 1960. User project contribution is zero.

The independent audit reproduced all three counterexamples without executing
author code. Correct the event allowance to include the case-selector call and
provide a focused receipt/overlay which supersedes that field while preserving
the successful original evidence. The current peak remains one: each call
resets the scratch table before its one selected prefix is added. Therefore its
672-byte backing and the primary capacity guards remain valid. Severity is low
because the complete allocator-event join is explicitly open, but the value
must not be reused as a valid gross-event upper bound. These counts concern
the baseline inputs before the two additional RTS clauses; the accepted RTS
delta and its separate scratch work are not silently included in seven.

## Traversal, syntax and shared storage

The explicit target disables configuration fallback. No import, extension or
aggregate makes the other retry/recursive parse paths reachable. Each GPRbuild
process performs one user parse/evaluation and one configuration
parse/evaluation, followed by one Apply_Config and naming traversal. The
configuration Phase 1 retains the user's tables; Apply_Config skips the
configuration project itself. Runtime-directory discovery reads metadata rather
than parsing another project, and the generated naming .TMP is compiler input.
Gprconfig and GNATprove GPR2 remain separate process/service obligations.

Main initialization and Parse_Project_And_Apply_Config each call GPR.Initialize
and hence GPR.Reset, producing two Dot_String_List cells. A potential third
reset was checked and excluded: `gpr-proc.adb:2761–2766` implements Phase 1's
`Reset_Tree=True` by freeing the project list only. It does not call GPR.Reset
or append another Dot_String_List. Reset/pop events are distinct from peak
individual backing sizes.

The independent token/RHS inventory reproduces the user/configuration counts
and L=182/186/188. The complete source contains 11/10/13 construction sites in
Part/Dect/Strt. The sufficient `34 × (T+2)` bound charges executions, including
eager candidates, rather than only retained nodes. On the selected successful
grammar, another execution at a site requires another consumed token or a new
top-level input. List recursion consumes `(` before descending; concatenation,
list, declaration and choice loops consume their separators. Identifier
lookahead saves/restores scanner state without allocating a syntax node in
that lookahead. Comments are disabled, and recovery, imported/virtual-project
construction and programmatic GPR.Tree construction are not selected.

Every RHS has at most one reference. Its temporal dependency is therefore a
chain, with self-attribute references reading the previous value. Charging all
literal origins plus a conservative singleton per reference bounds each value
by L. No split, external list, loop or nonempty case branch expands that value.
Literal/list and reference evaluation charge obsolete copies as well as final
ones, so Q×L suffices. Apply_Config's copying paths visit configuration entries
once, copy their list and link the user tail; missing/default entries use
shallow copies. D×L suffices for those additional cells. The user has no
configuration references, preventing duplicated shared literal origins in the
selected user/configuration concatenations. Naming's single source directory
and the two reset cells yield `3 + (Q+D)×L`.

The D×L Name_Lists allowance also has a caller argument. The complete archive's
Name_List allocators occur in GPR.Nmsc and GPR.Util. Nmsc has 31 named Put
conversion sites within Check_Configuration's project/package attribute and
array walks. The attribute-name branches are mutually exclusive; the selected
user project and Ada language are visited once. Final nonempty entries are
supplied by declarations, while default lists are nil. Distinct entries may
share literal origins, but each is charged to its own declaration, and each
contains at most L cells. Put allocates once per copied cell. Duplicate has no
selected caller. The absent runtime pathfiles add the two separately charged
directory cells. The configuration project is not a second naming traversal.

The accepted RTS +20/+7/+7 is reused only for its established clauses and
shallow-copy Apply_Config branches; its completed review was not replayed.
Independent arithmetic confirms the resulting translation objects:

| Object | Demand | Separate backing bytes |
| --- | ---: | ---: |
| Project_Nodes | 29,124 | 20,503,648 |
| String_Elements | 48,890 | 7,822,480 |
| Name_Lists | 17,493 | 1,119,584 |

The datarep and phase1 results and the supporting Variable_Elements, Arrays,
Array_Elements, Packages, Number_Lists, Case_Choices and Case_Stack coordinates
also match the independent calculation. None of this converts F1's incorrect
reset-event export into a valid value.

## Auxiliary objects and the boundary of acceptance

Withs, Project_Stack, Extended_Projects and Next_End_Nodes use low 1, initial
10 and growth 100 in the pinned sources. No import/extension selects the Withs
or Extended_Projects append paths, but both still require initial backing.
The two top-level Part.Parse calls initialize Project_Stack and push/pop one
entry each. The project/package/case end stack receives two project, seven
package and one case push, including with comments disabled. Gross demands
0/2/0/10 give separate backings 1,680/1,344/672/336 bytes. Pops and resets do
not erase events; the ten-push allowance safely dominates nesting depth.

Startup counts independently agree: 216 attribute and 19 package initializers,
300 literal Snames requests plus the reserved allowance, and 104 targetsets
across the 65-input/9,492-element structural XML inventory. That union inventory
is not a claim that each process loads both phase additions. Known name
contributions 2,405/2,443/2,467 remain incomplete. All four attach_names operands
are mandatory, and successful arithmetic leaves the missing provider unattached.

The callable prefix ends at Phase 2. Later per-unit switch, ALI and process
operations are outside this export and explicitly retained as joins in the
README and handoff; they are not assigned zero demand. Nonparsed global Names,
prior capacity and later requests/entry widths, KB XML-DOM/regexp and other
containers, remaining parser/startup/reset/growth events, separate Gprconfig
and GPR2, and later producer/report joins remain owned by #212 under #119.
The enumerated closed flags do not claim every parser or process allocation.
No cumulative RAM/stack gate or historical exact-AST prerequisite is introduced.

## Evidence and disposition

One focused independent offline audit completed on its first attempt in
**0.552185 seconds**, reproducing F1 and confirming the remaining checked
coordinates. Its [receipt](../evidence/review-gpr-baseline-20261024/result.json)
binds all 19 changed files, 11 provider files and 26 complete selected GPR
members. It independently reconstructs the selected project and prospective
baseline configurations, checks complete-archive source correspondence and
inventory lines, counts syntax and changed structural XML inputs, recomputes
table arithmetic, and checks the explicit unresolved boundaries. Source
snippets are receipts for the manual control-flow arguments above; they do not
alone prove those arguments.

The author’s original 0.177625-second baseline and distinct 0.125175-second
boundary receipts are preserved, not replayed. No author code was imported and
no author/predecessor checker, compiler, prover, Lean, capture, runtime-corpus
rescan, native target or service execution occurred. The review uses a separate
worktree at the exact author. Actual host is Linux x86_64; the earlier paths
read confirms linux-x86_64. Governing AGENTS/Oracle/development/agent-workflow
are unchanged from the preceding bounded reviews. The live harness goal read
returned null; no goal was written.

Reviewer selected **GPT-6 Astra / Extra High** as assigned. Runtime model
confirmation and token/cost telemetry are unavailable. The
[round record](../evidence/review-gpr-baseline-20261024/round.json) records the
measured review window separately from audit time. No author, production,
Oracle, admission, tool-pin or physical-premise change was made. Global e≤2,
two save-entering callbacks and three saves remain unchanged. No GitHub or CLI
memory write was made by this reviewer.

No other material finding was identified within this bounded review. #219
requires the narrow reset-event correction before that coordinate is reused;
the supported individual backings can be retained. The review is frozen in a
local unpublished commit. Parent integration, issue disposition and publication
are separate; #212/#119 and complete producer capacity remain incomplete.
