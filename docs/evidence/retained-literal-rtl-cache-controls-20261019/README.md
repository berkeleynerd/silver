# Selected literal RTL cache/control lifetimes

Offline source join for #119, based on `ab12e2db37`. The
[source argument](../../research/retained-literal-rtl-cache-controls.md)
closes two complete selected cache lifetimes and five fixed control
registrations, with the remaining type/alias family stated separately.

For C>=1 literal calls:

- CONST_INT historical insertions <=`39257+120+C`; new backbones <=C.
- reg_attrs actual insertion-capable lookups <=4C: C adjacent same-key pairs
  plus2C split-part calls. Historical insertions <=`39257+3C`; new backbones
  <=3C, using the explicit no-collection and paired-growth argument.
- Both post-prefix non-lookup backing demands are zero on the selected route.
- Five scalar registrations belong to dummy/Main pools, temporary addresses
  and frame recording. Their direct objects retain existing owners.

The new GGC backing allowance is 4C. The setup's 121 events remain inside its existing 437;
direct CONST_INT/reg_attrs records are not added again. Each cache's slots
are bounded by the first retained prime >=`max(61,2*history)`, with explicit
native arithmetic and individual allocation checks. No aggregate RAM bound
or production admission change is introduced.

From the repository root:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-literal-rtl-cache-controls-20261019/derive.py --gcc-root /tmp/silver-backend-compose-20261018/full-source
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-literal-rtl-cache-controls-20261019/check.py --gcc-root /tmp/silver-backend-compose-20261018/full-source
```

The derivation accepts `--source` and `--output`; its default is the actual
Hello sample. `inputs.json` pins 38 complete compiler files and 18 repository
inputs. The fixed native witness/results and accepted argument are reused;
no witness, accepted component suite, aggregate or corpus checker runs.
Focused checks exercise source recognition/identity, disjoint ownership,
prime/width endpoints, concrete hit/removal/reinsertion histories and a
changed complete compiler source. Their arithmetic success is distinct from
the source argument's multiplicity and reachability proof.

The next family is reachable tree-type/alias construction, including
`alias.cc:1219` child-map creation. Its registration count is not zeroed.
The complete scalar-finalizer/global-counter/collector/native claims remain
false and total GGC events null. Independent review and attachment belong
to the parent. See `round.json` and `check-results.json` for actual available
execution evidence and selected settings.

The original `check-results.json` retains the39-check historical run at
`8e4a84cfa3`; it is not a replay on the repaired inputs. Review
[#141](https://github.com/berkeleynerd/silver/issues/141) found the duplicate
descriptor setter. `check-paired-setter.py` and `repair-check-results.json`
record only the focused correction checks. They cover first-lookup expansion,
second-hit expansion after crossing the old threshold, hit/miss pairs,
tombstones/compaction/shrinking, unchanged3C record/backbone ceilings and the
new complete `tree.h` pin. The existing full checker expectations are updated
for a future replay; that whole checker was not rerun for this repair.
