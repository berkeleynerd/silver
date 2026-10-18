# Independent review: cold helper aggregate attachment

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119)
and imported-frontier finding [#131](https://github.com/berkeleynerd/silver/issues/131).

**Disposition: scoped acceptance; no material finding.** The attachment
correctly charges the two reviewed cold String helper cgraph nodes, preserves
their registration/counter effects after removal, and conservatively expands
symbol/hash populations. Their removal creates no summary IDs or call edges.
The five unresolved aggregate conditions and helper allocation unknowns remain
unresolved; no complete native capacity or emitted-stream claim follows.

## Frozen inputs and review scope

The target is `5f9641d1a09e0e4cd4841a0d87bb553e8a75517b`, compared against
`54ea75f0cb74f9a6dacd47fb3b51c35f82115a72`, in the initially
clean isolated branch `review/cold-helper-attachment-5f9641d1a0`. The reviewed
diff consists of `compose.py`, `check.py`, `inputs.json`, `result.json`,
`check-results.json` and `README.md` in the
[aggregate packet](../evidence/retained-literal-pipeline-20261018/README.md),
plus [its source argument](../research/retained-literal-pipeline.md).
The target attaches the interface independently reviewed at
`bd15740afc3453be73f176887724bfbe78da60df`; the separately confirmed XVE
description correction is preserved. This review does not redo that complete
layout argument or extend to the later warning-residual packet.

The bounded assignment follows the applicable AGENTS, Oracle and review
bookkeeping, within owner-authorized #119 research. Source semantics are the
retained GCC revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, selected
Linux x86-64/LP64 configuration and invocation. Relevant installed behavior
matching that source remains the existing premise. No production admission,
language rule or Oracle guarantee is changed.

I independently verified all 108 aggregate repository input identities. The
attached cold `interface.json` and `source-manifest.json` are byte-identical
to the reviewed leaf. The four added pins bind that interface, its manifest,
the corrected source argument and the independent review. I also checked all
21 cold source identities and seven additional pinned source files used here:
`symbol-summary.h`, `symtab.cc`, `ipa-fnsummary.cc`, `ipa-fnsummary.h`,
`ipa-prop.cc`, `hash-table.h` and `hash-table.cc`.

The context resolves Ada-relative paths against the supplied Ada root, the
match file against the selected match path, and other cold files against the
GCC root. Each file is checked by complete length and SHA-256. The existing
repository pin check binds the full interface bytes; the new runtime join
also checks the consumed helper counts, all four persistent increments,
discard boundaries and explicit null/false completion fields. No unknown
allocation total is defaulted to zero.

## Source and arithmetic assessment

`stor-layout.cc:273–291` allocates each helper function structure, gimplifies
its body and calls `cgraph_node::finalize_function`. Reusing the accepted
two-helper result, this route reaches `get_create` and the fresh node
constructor, with one `ggc_alloc<cgraph_node>` per helper
(`cgraph.cc:442–445,658–681`). The inherited source-layout ceiling of 512
bytes applies to the same structure; its constructor initializes empty
vectors/pointers and summary ID -1. This attachment adds two node requests,
not a bound for all function/tree/GIMPLE construction.

Registration consumes `cgraph_max_uid++` and `order++`
(`cgraph.h:3138–3151`). Unregistration only relinks the list, and release
decrements the live cgraph count without rewinding either counter
(`cgraph.h:3176–3196`). Thus the existing C bounds nodes, Main, dummy and at
most two imported callees, together with the two helpers, give cumulative
registrations/order at most `C+6` and next UID at most `C+7`. The stricter
next-UID inequality also covers these signed counter increments. Function
definition numbering and the private SZ sequence retain their separate +2
increments in the attached interface; their remaining consumers are not
declared closed.

Assembler-name registration excludes the hard-register dummy and may insert
each other symbol once (`symtab.cc:162–199,412–424`). Including the helpers
therefore gives at most `C+5` historical insertions. It is conservative even
when the table is initialized only after their removal. Helper removal uses
`NO_INSERT` and slot clearing, with no rename/reinsertion path
(`symtab.cc:203–244`). Historical insertion count already covers the retained
tombstones. The initial backing plus at most one growth-capable lookup per
insertion gives `C+6` backing requests. Accordingly the pool subtotal is
`C + 3C + 1 + (C+6) = 5C+7` GGC events.

Reachability and COMDAT backing use the enlarged `C+6` symbol population.
The unchanged call-related populations are appropriate because the helpers
never undergo graph analysis. These enlarged hash bounds do not claim that
all helpers survive into IPA; they safely cover their earlier presence.

The important summary distinction is source-supported. `cgraph_node::create`
registers a symbol without invoking insertion hooks. `finalize_function`
does not use the `add_new_function` queue whose processing explicitly invokes
those hooks (`cgraphunit.cc:301–365,452–515,530–590`). The accepted unreachable
helpers remain outside the analysis queue and are removed after Main's initial
lowering (`cgraphunit.cc:1176–1454`). Main's local `compute_fn_summary` creates
records only for its argument node; constructing the summary managers installs
hooks without retroactively scanning existing nodes
(`ipa-fnsummary.cc:752–760,3386–3400`; `symbol-summary.h:27–46`).

At removal, ordinary function summaries use a noninserting map lookup and
fast summaries test `exists` before removing a record
(`symbol-summary.h:214–226,298–304,408–429,488–496`). The summary-ID getter
only returns the current value; assignment belongs to `get_create`
(`cgraph.h:1378–1381`; `symbol-summary.h:389–402`). Release pushes a recycled
ID only when it is not -1. Consequently neither helper receives a summary
ID, creates a summary record on removal, or adds a released-ID-vector entry.
Its initially null call-site hash and empty edge lists also add no call-site
backing or edge events at removal (`cgraph.cc:2262–2367`).

The existing graph groups therefore gain precisely the two cgraph node
requests: `4C + 4 + (4+4C) + 4 + 7 + 14 + 2 = 8C+35`. The call-edge,
call-summary and function-summary ID bounds remain unchanged. The pool's
extra two potential assembler backing requests and the graph's two node
requests are distinct costs, not duplicate charging of the same allocation.

## Evidence and remaining scope

The retained full aggregate evidence reports 89 passing offline cases in
3.860516321 seconds and default generation in 2.996767486 seconds. I inspected
the six added negative cases and the retained result changes; I did not rerun
that successful full suite. Its 290 directly checked external source files
and overlapping nested inventories remain retained implementation evidence,
distinct from my focused identity checks above.

A focused offline audit independently reconstructed a minimal context from
the checked prime table, retained prefix population and cold interface. Both
pool and graph results exactly reproduced their stored default dictionaries.
Eight selected counts, including both sides of the new signed UID endpoint,
confirmed event sums, registrations, hash populations and false closure
fields. This audit took 0.031029152 seconds on
Linux 7.0.14 x86-64, glibc 2.43. It is a focused arithmetic/interface check,
not a full aggregate replay or native execution.

The aggregate still sets pool, graph, complete assembly, GAS/BFD storage and
link representation conditions to null, lists all five as unresolved, and
keeps whole-pipeline capacity false. It preserves null R, helper warning puts,
helper allocation requests/bytes and the complete imported frontier. Early
gimplification and later counter/name/CFI consumers still need their own
composition. Discard is not treated as zero construction cost, and these
conditional subtotals do not establish complete emitted-stream correspondence.

Selected reviewer settings: GPT-6 Astra / Extra High, assigned by parent.
Runtime confirmation and token/cost measurements are unavailable. Review ran
from 20:30:25 to 20:32:58 UTC, 153 seconds including reporting. Intended
outcome: independently check the attachment's source joins, persistent costs,
summary/removal semantics and preserved unknowns. Achieved: scoped acceptance
without rework. New native/compiler/prover/debugger/server/solver runs: zero.
Only this report is changed in the review worktree. The parent owns integration,
issue updates and durable memory; CLI memory was not updated. The child harness
goal query returned null, and no goal state was changed.
