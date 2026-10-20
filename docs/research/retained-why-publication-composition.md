# Selected Theory publication composition

2026-10-20 UTC, Round 35, #119 / #155; feeds #153. This composes the
[tuple-preparation bound](retained-why-tuple-preparation-bound.md),
[initial-registration bound](retained-why-initial-registration-bound.md) and
[library-publication bound](retained-why-library-publication-bound.md) with
the accepted [writer transfer](retained-why-path-writer-capacity.md).
The [packet](../evidence/retained-why-publication-composition-20261020/README.md)
retains exact inputs and five arithmetic applications.

The result supplies actual conservative publication bounds W and establishes
the writer's scalar-size guard for the five retained continuations under their
documented source/native/state/runtime relation. It does not establish complete
writer allocation, whole native stack, complete save or whole-pipeline capacity.
No production invocation, admission rule, tool or Oracle changes here.

## Whole-interval count

For each process let E be its accepted preparation-episode bound, T its prepared
physical Ddata-head family bound, and I its initial registration count. Define

```
K = 2*I + 38679
C_base = 3404503 + 8*I
W = 3*E*T + 2*E*C_base + 4*128*K + 4*e*(K+1), with e=2.
```

The first term counts direct algebraic tuple-theory publications. The second
allows two library read roots per episode and uses the larger real-root base
for either int.Int or real.Real. Failed and abandoned prefixes are included.
C_base is not a standalone C_lib: the last two terms are necessary.

The third term charges every possible resize assignment of either private
tuple-publication memo as loss of every possible key. It does not assume that
an interrupted in-place rehash preserves entries, or that a subsequent rebuild
repairs malformed old chains. The two growing tables have at most 128 resize
assignments in total under the source argument. The last term pays separately
for signal-origin misses or abandoned insertion/construction prefixes using
the accepted global escaping-signal budget e<=2.

Both allowances are charged **once per entire post-cut process continuation**.
They are not multiplied by E, the number of roots, or the global at-most-three
save budget. Conversely, neither allowance is omitted merely because each
read has a base charge. The initial Input_Is_Valid cut is within preparation;
its accepted E already conservatively charges that entire intersecting episode.

| Case | E | T | I | K | W | Margin below scalar guard threshold |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 194 | 63 | 136,844 | 312,367 | 1,908,178,454 | 239,301,723 |
| Put | 161 | 63 | 121,505 | 281,689 | 1,555,755,563 | 591,724,614 |
| First_Or_Default | 98 | 61 | 77,806 | 194,291 | 890,331,658 | 1,257,148,539 |
| Is_Message | 11 | 58 | 59,035 | 156,749 | 166,800,628 | 1,980,679,628 |
| Input_Is_Valid | 5 | 59 | 60,496 | 159,671 | 121,914,523 | 2,025,565,715 |

These are upper bounds, not observed publication counts. Each row is a separate
process; adding their counts does not give one process's representation demand.
The scope includes the accepted driver/scheduling orders and interruption
premises, rather than only the single observed first preparation.

## Writer interface evaluation

The retained table's current cell count V0 and captured scalar size s0 are
separate inputs. Their values happen to agree in each capture:
6941 / 6941 / 6901 / 6783 / 6819. The input join retains their separate fields
and process IDs; no semantic equality between arbitrary table states is assumed.

The accepted transfer yields

```
V = min(2^59, V0+W)
L = min(2^59, 7+W)
clean calls <= W
clean node visits and Cons requests <= W*V
successful array doublings <= min(W,41)
copy node visits and Cons requests <= min(W,41)*V
s0-W*V <= scalar size <= s0+W
recursive bucket own frames and returns <= 32*(L+1) bytes.
```

All five scalar intervals fit the retained tagged-integer range
[-2^62, 2^62-1]. The focused check also confirms the exact earlier threshold
and failure at threshold+1 for each independent V0/s0 pair. It reuses the
unchanged transfer, rather than modifying a guard to fit these results.

| Case | Clean visits / Cons requests upper | Copy visits / Cons requests upper | Recursive bucket own-frame bytes upper |
| --- | ---: | ---: | ---: |
| Put_Line | 3,641,158,256,976,479,330 | 78,235,601,195 | 61,061,710,784 |
| Put | 2,420,386,170,304,809,752 | 63,786,262,664 | 49,784,178,272 |
| First_Or_Default | 792,696,605,415,800,822 | 36,503,880,919 | 28,490,613,312 |
| Is_Message | 27,823,580,909,854,108 | 6,839,103,851 | 5,337,620,352 |
| Input_Is_Valid | 14,863,982,253,449,866 | 4,998,775,022 | 3,901,264,992 |

These deliberately loose request and frame envelopes are not measured resident
heap, available physical memory, or a proof that a full native call chain fits.
In particular, recursive-own-frame accounting excludes callers, callees,
pending callbacks and service frames. Cons counts omit other writer object
families. Mathematical cumulative requests need not fit one machine-size
counter because the tool does not store this cumulative accounting total.
The complete caller allocation/layout, stack and failure arguments remain
separate obligations. This packet keeps their completion flags false.

## Correspondence, review and next work

The initial I values rely on the actual debugger-controlled prefixes: the
single-continue stop policy and inspected allocation path give 5N<=B and rule
out a first counter wrap. That reasoning does not exclude later signals or
later counter wrapping. T comes from every initially live Hsdecl data-head
representative plus a selected-producer preservation argument. Library counts
come from the four-file read/clone recurrence, source-slot head accounting,
implicit tuple construction and interruption handling. Hashes and arithmetic
checks bind these inputs; they do not mechanically prove the source arguments.

The selected source/native pending-frame, serial ownership, immutable-value,
metadata/counter/result-preservation and existing runtime/OS premises of the
component packets all continue to apply. This is not a new claim that the
inspected source revision is the installed archive's exact upstream build
revision, nor evidence for arbitrary Why3 clients or plugins.

#155's numerical dependency is supplied by this composition, subject to the
recorded final review. #153 still requires complete structural allocation,
caller stack, exposed counters, channel/refcount and service/error/exit
composition, including the positive-write progress attachment. The parent
#119 additionally retains remaining driver/printer/solver/server/report paths,
fixed-library/current-grammar coverage, whole-rule decidability/correspondence,
useful-domain comparison and final independent review. Production #88–#94
remains unstarted; draft PR #121 is not merged.
