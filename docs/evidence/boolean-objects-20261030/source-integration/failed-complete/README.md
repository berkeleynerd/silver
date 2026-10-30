# Failed complete Boolean source checkpoint

Managed run `20261030T132736-e452c95bd00d` finished **failed** at
2026-10-30 18:38:07 UTC, after 18,628.882 s managed time and 18,621.300 s
build time. It used one Lake worker, one thread per process and a 24 GiB
per-process threshold. Its captured implementation/proof input was
`5198f2b7b5`; later regression and documentation commits did not change those
687 captured inputs. No complete axiom audit or source success is claimed.

Three modules failed:

| Module | Failure | Repair |
| --- | --- | --- |
| `OutputBodyCertificate` | `_values`' `rfl` exceeded elaborator recursion depth after the module's 11,216 s attempt. | Existing checked explicit witness for large flattened token lists; see the [controlled diagnosis](../flattened-values/README.md). |
| `ComposeSourceCandidate` | The ordinary array declaration wrapper omitted its initializer's outer parentheses, making its exact token proposition false. The module attempt took 5,381 s. | Add exactly those two rendered tokens; see the [focused check](../array-wrapper-repair/README.md). |
| `PredicateAdapterSourceCandidate` | Kernel decision could not reduce imported `Nat.repr 0`; the equality was not reported false. | Normalize zero with proved core lemmas; see the [adapter record](../../adapter-numeral-repair/README.md). |

The retained events, failed outcome and logs identify the original inputs and
results. Successfully built independent modules remain cached for ordinary Lake
reuse. An old `lean-evidence.json` from a preceding successful checkpoint is not
evidence for this failed run and is not copied here. The coordinated repairs
are integrated at `b6aeb9f978`; complete validation on those bytes remains
mandatory. No Ada source, native contract or source admission rule changed.
