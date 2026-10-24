# Independent disposition: #219 GPR reset-event repair

2026-10-24 UTC. **Accept repair
`c7f0191bb8de07a1ebe2988c35f5a8f66ef89f58`; F1 / #219 is resolved in the
effective overlay. No new material finding.** The original
[review](review-gpr-baseline-20261024.md) at
`ad92df5c3658b7495f1747226cde54a0dadc3f20` remains unchanged. Its six-versus-seven
counterexample remains valid historical evidence about author
`17569ceaa8daf41892852cc4ab8b423b28d9091e`.

For each of datarep, phase1 and translation, the effective bounds are seven
baseline resets and singleton pushes, two additional RTS-reference events,
and nine prospective resets and singleton pushes. Peak entries remain one,
and the separate backing remains 672 bytes. The event sums do not sum peaks.

The source paths are unchanged and fully pinned. Under the archived
`gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263/gpr/src/`,
`gpr-dect.adb:889–895` parses the GCC_Prefix case selector through
Parse_Variable_Reference. The ordinary RHS identifier path at
`gpr-strt.adb:1592,1638–1643` enters the same procedure. Its `:846` resets Names;
`:856` adds the first prefix through Add_To_Names, whose `:165` increments the
scratch table. The `:858` loop exit excludes another push unless a dot follows.
Every selected prefix is a singleton. These are Reference_Prefix scratch-table
events, not global GPR.Names intern requests.

The independent audit enumerates six RHS references in each retained
configuration: GCC_No_Pie, Compiler'Leading_Required_Switches,
Binder'Required_Switches, Linker'Required_Switches, Compiler'Driver and
Clean'Artifacts_In_Object_Dir. The user project contributes none. The separate
GCC_Prefix case selector supplies the seventh baseline event even though the
case alternatives are empty. Reading only the already accepted zero-based
`db/gnat.xml` configuration[13] identifies the two additional Compiler/Binder
attribute references. Their selection and +20/+7/+7 primary effects are reused
from the accepted review, not re-established by another selector run.

The new `repair-f1/capacity.py` effective_prefix callable derives the corrected
baseline from RHS and case counts and requires the additional RTS operand
explicitly. It replaces the historical top-level reset field with seven, adds
the baseline push field, and exports baseline/RTS/prospective quantities
separately. Its outputs agree exactly with the new result and handoff for all
three phases. Applying it twice is stable, and its deep copy leaves the input
and nested backing records independent. An omitted operand is rejected;
explicit zero retains baseline seven rather than silently supplying a zero
RTS assumption. The selected prospective use passes two.

Every other original prefix coordinate is equal, including the primary and
supporting backings, retained +20/+7/+7 attachments, known partial name
contributions and incomplete-capacity flags. All 18 original baseline packet
files and all six initial review files are byte-identical to their respective
freezes, including the auxiliary backing receipt. The research change is an
append. The repair clearly designates its callable/export as the effective
replacement for the obsolete six-event field; seven must not be used for the
complete prospective parse.

One new independent narrow offline check passed first attempt in
**0.324791 seconds**. The [audit receipt](../evidence/review-gpr-reset-repair-20261024/result.json)
binds all ten changed inputs, verifies 13 provider pins and the two complete
pinned Dect/Strt sources, checks the accepted XML fragment, reproduces the exact
reference names, exercises the new callable and compares effective exports and
unchanged coordinates. It imports only the new overlay, with no author or old
checker, baseline calculation, selector, native compiler, prover, Lean, service,
capture or runtime-corpus replay. The author's 0.123714-second receipt remains
unchanged and was not rerun.

The reviewer selected **GPT-6 Astra / Extra High** as assigned. Runtime model
confirmation and token/cost telemetry are unavailable. The
[round record](../evidence/review-gpr-reset-repair-20261024/round.json) records the
review window separately from audit time. A fresh isolated worktree was created
at the exact repair author; the original review worktree was preserved. Actual
host and `scripts/dev.py paths` report Linux x86_64. Governing AGENTS, Oracle,
development and agent-workflow files are unchanged. The live goal read returned
null; no goal was written.

This disposition closes the local F1 repair obligation, not #212/#119 or whole
producer capacity. Remaining allocator-event accounting, nonparsed global
Names, XML-DOM/regexp/KB containers, separate Gprconfig and GNATprove GPR2,
and later per-unit switch/ALI/process/report joins remain open. Source admission,
tool pins, physical premises, conditional P188, e≤2, two save-entering callbacks
and three saves are unchanged; no cumulative RAM/stack gate is introduced.
This reviewer made no author, production, GitHub, push or CLI-memory write.
The review is frozen locally without publication. Parent integration and issue
closure remain separate.
