# Round 56: request operands, combined startup and fixed-family inlining

2026-10-20 UTC, Linux x86_64. The
[independent review](../../reviews/review-request-inline-capacity-20261020.md)
accepts all four components at their conditional interfaces. #119 and its
scoped child #153 remain active and incomplete.

| Component | Final author freeze | Integration |
| --- | --- | --- |
| Request parser/receive storage | `a4a4bd821d36db91c7ee7e7a8403eb85dd500026` | `84217f0d46`, `44b28e4ac2` |
| Quiet/timeless/J12/logging startup | `92e0cd50acd9ff21f5350dcda89ac99584defecb` | `11c3a88f3a`, `e21b9d8dbd` |
| Request filename/argv/byte operands | `99b8d71c4d80afb12006237b49a4f6c9c9ad8f53` | `bcca6cfff5`, `fdb5ca7862` |
| Fixed-family first-inline bounds | `240b1ca101ec63a332b416469e721d940b527c3b` | `d25dc141aa` |
| Independent review | `81ea653027b17ad954a0268e381d2be62ab03a9a` | `df2140c2e5` |

The [request parser](../../research/retained-server-request-storage.md) covers
intact validated backend streams, cumulative parser allocations and receive
data backing, retaining cancellation leaks and the native overlapping-copy
premise. The [filename/argv attachment](../../research/retained-solver-request-bytes.md)
joins source-origin goal headers through selected transformations to actual
temporary filenames. For the quiet profile, L_d=A+tau_d+c_d, with c_d equal
273/273/278/276/276 in Put_Line/Put/First/Is_Message/Input order; m_d=14 is
a conservative maximum excluding the executable. A is adapter executable
length and tau_d is actual client TMPDIR length, subject to delimiter/path
and native arithmetic guards. These are explicit configuration operands.

Substitution into the parser formula gives the computable component bound

```
parsed request bytes <= 459*A + sum_d N_d*tau_d + 234945
parsed allocation calls <= 11016
parent exec argv bytes <= 58752.
```

This counts all run/interrupt allocations; it does not duplicate the transferred
ID pointer or subtract cancellation retention. Receive backing remains
sum_d 2*R(L_d), with the checked growth function in the parser note. Its control
records, native process/path/send owners, allocator overhead, child address
spaces and raw output are distinct. The raw backend filename uses **actual
server getcwd**, P_b=C+11; no launch-directory string is silently substituted.
Canonical path length is P_c=len(R)+24. Proxy wrapping happens after Why3
serializes its original request; it adds no wrapper text to Why's RC command.
Actual proxy/launcher refinement remains required. R55's 41,536-byte ring
figure belongs to the prospective shared-server design; the five separate
historical single-client captures are not an attachment of that topology.

The [combined startup argument](../../research/retained-combined-parallel-startup.md)
attaches R52's exact quiet/timeless files to R53's actual J12 roles and R55's
logging delta. It preserves registration and the 118-root/47-check map under
the controlled successful-prefix/source/runtime guards. It corrects the old
idle-phase arena reasoning: phase0 is mark, the same explicit startup collection
starts a cycle without a mark slice, and bounded subsequent allocation leaves
a single contiguous free remnant without sweep. Actual per-domain J12 startup
histories are charged. Maximum all-major allocation is 8,526,217 words, leaving
at least 8,250,999 words in the initial arena. Arbitrary relocation, failed
startup services and later callbacks are not covered by that prefix result.

The [first-inline family](../../research/retained-why-fixed-inline-family.md)
extends the weighted model to all 118 registered roots and three drivers,
including raw and CE entries, typed/range-literal checks and the no-force-inline
producer argument. It bounds 792,911 direct Ident registrations over the five
processes, using the same global e<=2 per process. Its candidate stored-field
envelope is explicitly separate from old returned hidden maps/types and full
validators. Those producer envelopes, collision costs and later stages remain
required; source equality of opened terms alone does not close them.

The reconciliation checks frozen author/reviewer files, direct retained input
identities, unchanged native source pins and installed Why executable, Python
syntax, links and the new formula substitution. It does not replay component
checkers, native targets, solver/proof runs or captures. Individual author and
review checks retain their own exact scopes and timings. The
[round ledger](../retained-tool-rounds.md#round-56--request-operands-combined-startup-and-fixed-family-inlining)
records final review and integration measurements.

The retained [reconciliation](integration-result.json) passed in 0.802820 seconds:
79 frozen files, 147 direct retained repository identities, 94 unchanged native
source pins, unchanged Why plus two request-native inputs, ten Python parses
and fourteen frozen-record links. The four first reviewer checks consumed
14.273737 seconds of subprocess time within a 1,765.993712-second retained
review interval that includes waiting and coordination. No check was replayed.

Next: close returned stored-map/type/validator producer envelopes and remaining
stock-server owners, then preparation/printing/counters, startup/failure/raw
output, complete original pipeline/fixed-dependency/current-grammar coverage,
checked accounting, source correspondence, whole-rule composition, useful-domain
comparison and final review. The global two-callback/three-save/e<=2 budget,
Oracle, installed tools/pins and admission are unchanged. #88–#94 remains
unstarted; PR #121 stays draft/unmerged. This checkpoint does not complete #119.
