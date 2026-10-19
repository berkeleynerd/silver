# Shared bitmap and selected ordinary pool lifetimes

Research #119; retained Linux x86-64/LP64 GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Candidate for independent review;
no production admission change or complete native capacity claim.

The [source argument](../../research/retained-literal-shared-bitmap-pools.md)
closes selected ordinary bitmap allocator representation and supplies shared
ET-pool and LRA live-range-pool bounds. `inputs.json` pins 38 GCC files and
19 repository inputs. Accepted actual-source pipeline, shared-query and
MEM/counter results are consumed without replay. Only the pure literal source
recognizer and RTL-backing arithmetic are imported; no predecessor Context,
suite, aggregate evaluator or corpus checker runs.

The public entry is `evaluate_source(raw, pipeline, query, mem, context)`.
It requires the accepted owners for those exact bytes/counts and checks the
consumed UID, register, DF, initial CFG/SSA, ranger, out-of-SSA and callback
interfaces. `endpoints(C,N,decl_uid,context)` is count arithmetic only; it
does not recognize a source or establish its accepted premises.

- Ordinary bitmap headers/elements are completed 32/40-byte objects. Initial
  and later chunks each request 65,536 bytes. Neither bitmap obstacks nor the
  common returned-block cache stores a cumulative object/chunk/block count.
  Shared incoming history therefore requires index, request and nesting
  checks, without a total allocation or RAM bound. The default depth is at
  most nine. The common cache can retain returned blocks after owner release.
- DF scan/LR and shared DF scratch domains, initial CFG/SSA and helper bitmap
  owners, and selected register/UID/block/program-point sets are joined.
  Old allocation owners remain separate and are not charged again.
- `P=2M+B` bounds IRA/LRA program points. Point-frequency capacity is at most
  `max(2U,2P)`; the initial reserve need not suffice. Assignment header arrays,
  compression bitmaps/maps and register sparse sets keep individual checks.
- LRA live ranges are at most 10C 32-byte objects. Copy and invariant pools
  have zero selected objects; their initialization controls remain owned.
- The shared dominance pools hold at most 2B nodes and 4B occurrences across
  both directions. Exact selected 64/48-byte layouts yield 1023/1365 slots per
  block; all free slots count toward the actual retained `size_t` fields.
  Prior conservative initial-ET block owners remain unchanged.
- Every new family is ordinary: zero new GGC events or finalizer registrations.
  Callback zero-effect and the accepted scalar-finalizer history are retained.
  All-GGC total, complete ordinary helpers and collector capacity stay null/false.

Focused validation:

```sh
python3 docs/evidence/retained-literal-shared-bitmap-pools-20261019/derive.py
python3 docs/evidence/retained-literal-shared-bitmap-pools-20261019/check.py
```

The recorded run passed **52 checks**, 21 count-transfer cases, 11 bitmap
boundary cases and 18 pool-boundary cases in **0.0565760589997808 seconds**.
For retained Hello, P=64, point-frequency capacity upper=128, each assignment
header array<=2048 bytes, live-range pool slots<=2047, ET node slots<=1023 and
occurrence slots<=1365. Each of those three typed pools needs at most one block.
These are separate capacity bounds, not summed process RAM.

Checks reject changed source bytes, stale incoming UIDs, erased bitmap owners,
changed scan chronology and nonzero callback effects. Boundary checks cover
bitmap rounding, point/vector and ET-depth guards, retained pool free slots,
and repeated reuse versus cumulative allocation history. They do not validate
the handwritten reachability or ET arithmetic invariant.

`round.json` records selected model/effort, actual offline host, elapsed evidence,
bounded rework and exact review inputs. No native execution/capture/build,
solver, old suite, aggregate or corpus checker was run. No governing document,
predecessor, GitHub state or publication was changed. Other IRA typed pools and
ordinary pass helpers, full GGC ownership and collector composition remain
separate. The parent's later-SSA and finalizer packets are not replayed here.
