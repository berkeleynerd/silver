# Literal MEM attributes, counter chronology and ordinary pools

Research #119; retained Linux x86-64/LP64 GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. This is a candidate for independent
review, not a production admission predicate or complete native capacity proof.

The [source argument](../../research/retained-literal-mem-counter-lifetime.md)
owns the selected reachability and reset/reuse claims. `inputs.json` pins 56 GCC
files and 19 repository inputs. The frozen shared-query result at `054b25c`
and the accepted actual-source pipeline result are consumed without replay.
Only the accepted pure recognizer and RTL-backing arithmetic are imported;
no predecessor Context, checker or aggregate evaluator is called.

`derive.py` checks the input bytes/counts and each consumed operation,
SSA/helper, RTL/DF/LRA and emission owner before exporting the new interface.
Its general entry is `evaluate_source(raw, pipeline, query, context)`; callers
must supply matching accepted results for those exact source bytes. The CLI
uses the retained Hello fixture. `endpoints(C,N,context)` exposes only the
source-count arithmetic for boundary checks; it is not a source validator.

The selected results are:

- `mem_attrs`:5C variable 40-byte records remain with the existing operation
  owner; copies, ordinary frame, CFI and later setters add zero. Fixed setup
  retains its 437-event owner.
- Register arrays: complete Main growth uses K=99+5C; the additional budget
  beyond the pre-split owner is q(K)-q(98+3C), where 198*2^q covers the extent.
  Each additional growth is one GGC pointer backing and one ordinary array.
  Hello adds zero; C=20 adds one.
- Alias: the selected IRA call starts with cold known/base/old-base vectors;
  its two GGC requests were already owned.
- DF: ref_order starts 0 once and spans both scan generations. Previously
  unpriced base/regular/artificial/instruction pools receive separate
  conservative retained-slot and lifetime-block ceilings. Hello needs at
  most 60 newly priced blocks per generation, 120 lifetime block requests,
  each 65536 bytes; the generations do not coexist. Existing register-pool
  ownership is retained.
- DF collection uses: inline 32 transitions through heap capacities 33,49,73,
  109, with largest request 880 bytes. The definition, note-use and multiword
  vectors remain inline on the selected shapes.
- LRA: last_reg_value resets 0 and ends<=floor(3K/2)+1; ordinary pool counter
  fields count retained slots, with release at finish. Global SSA creation/
  reuse counters are unsigned statistics, not capacity controls. Actual later
  SSA allocation events remain unclosed.
- cfun and sequence stacks: the existing four-slot 40-byte cfun backing
  covers the selected nesting; preserve cold sequence events because its
  GGC cache is deletable. Global label counters keep their accepted prefixes.

Focused validation:

```sh
python3 docs/evidence/retained-literal-mem-counter-lifetime-20261019/derive.py
python3 docs/evidence/retained-literal-mem-counter-lifetime-20261019/check.py
```

The recorded run passed 49 checks, 27 count-transfer cases, 48 register-boundary
cases and 42 pool-boundary cases in 0.06509972499770811 seconds. Mutations cover
mismatched same-count source bytes, erased owner counts, reset global labels,
changed actual RTL endpoints and stale shared UID counters. These checks
validate interface/arithmetic behavior, not the handwritten source proof.
No native tool, compiler, solver, accepted suite, aggregate or corpus checker
was run.

`round.json` records the selected model/effort and exact candidate input hashes.
All-GGC totals, full global counters, later SSA allocations, complete ordinary
shared pools/bitmap obstacks, typed-array finalizers and collector capacity
remain open. There is no aggregate RAM gate or admission change.
