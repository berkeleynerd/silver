# Private preparation memo container review

2026-10-23 UTC, #153 under #119. **Accepted scoped interface** at author freeze
`bb61e70086339202fd167cd4990f86106e63ebe6`: private ephemeron backing and size
counters, Driver's small registry, Introduction's content/queue/local-Hvs
containers, and the tagged dependency-map cardinality/height applications.
This does not complete #153 or the whole #119 capacity rule.

The [independent audit](../evidence/retained-preparation-private-memos-review-20261023/README.md)
passed 494 checks on its first attempt in 1.089092 seconds (wrapper 1.239876).
Selected reviewer: GPT-6 Astra / Extra High, Linux x86_64. Runtime model/effort
confirmation, token usage and cost are unavailable. No new agent was spawned.

The source induction preserves proper completed bucket chains, accurate stored
cell counts, and at most one live binding per tag. Dead bindings may coexist
with later insertions. Clean retains at most the complete lifetime key universe
M; actual growth requires both cleaned size>=L/2 and 2L<Sys.max_array_length.
With the retained array limit 2^54-1, the power-of-two backing caps at 2^53.
Thus `B=min(2^53,max(L0,4M))`, completed size<=max(2B,M), and one-add transient
size<=max(2B+1,M+1). The attempted doubling, size, threshold and array-byte
operands fit in all 25 applications. Five applications require the cap.

The [source/caller review](../evidence/retained-preparation-private-memos-review-20261023/source-review.md)
attaches Wtask/Wdecl/Wtds/Wty/Wid to their actual shared tag owners, checks
replace-only private writers and callback order, and preserves the existing
guard for published mutations. M is R65's complete endpoint+1; initial work
and the global allowance are not added again. Introduction's content hashcons
retains ordinary d_tag while discarding its private counter.

The review also reads the actual local Hvs.replace sites and their route to
ordinary Hashtbl. R61 already bounds these writes by 8m+p; the new whole-process
applications use its episode totals once. Immutable dependency maps and
on_tagged symbol sets use registered Ident keys, with R67's accepted height
argument applied to the explicit two-input envelope. The separate fixed
two-element Smeta set is bounded directly; it is not misclassified as an
Ident-key set. No material finding remains in this scope.

Evidence binds all 8 author files and 18 providers, 18 authored complete source
members and 33 strict spans, plus 13 supplemental spans that make the key and
local-Hvs connections explicit. The audit independently recomputes the new
arithmetic and imports no author or predecessor implementation. Author evidence
records one successful focused check in 1.032563 seconds and its earlier source
range-inventory corrections; no successful predecessor check was replayed.

This establishes individual container representations and native operands,
not cumulative allocation, total physical memory or runtime. Old/new list
copies and arrays, allocator/GC, stack and the faithful native boundary keep
their stated treatment. Epsilon/cache attachment, validator payloads,
pre-registration failure-prefix coverage and the complete fixed-domain
conjunction remain separate. The single global e<=2, two save-entering
callbacks and three saves are unchanged. No compiler, solver, proof, target
or capture run occurred; no GitHub, harness-state or CLI-memory write occurred.
Accepted Main evidence and the new Main review WIP remain untouched.
