# Initial package integration — 2026-11-22

These Linux checks exercise the integrated three-unit compiler and the first
unit-context model changes. They are partial validation, not the completed
native/Lean/source assurance checkpoint for #416.

| Managed run | Result |
| --- | --- |
| `20261122T143853-025d0ed71dd2` | Failed focused Compose bounds/expression check: two recursive proofs supplied a section variable as a recursive named argument. The failure is retained as failed. |
| `20261122T144510-0135c48281ed` | Repaired `Silver.ComposeBounds` and `Silver.ComposeExpressions` passed, with a fresh axiom audit of 13,864 imported declarations and only the three documented foundations. Build 13.420 s; audit 5.477 s. Cached dependencies were reused; no clean build or kernel replay is claimed. |
| `20261122T144545-07ed354a11d8` | First complete integrated compiler build passed, including the original-source package driver and report-policy helper repair. |
| `20261122T144613-a127fa5585dc` | All 25 package regression methods passed in 46.568 s, including compilation, complete selected report audits, original-unit snapshot checks, execution and argument/array/guarded-output composition. |

Each run reserved two workers within the host's shared eight-CPU allocation.
The Lean check used two threads per process. Exact captured inputs, allocations
and logs are retained alongside this record. Source inputs were uncommitted
exact-byte snapshots; commit names alone are not their binding identity.
The integrated binary's `catalogue` output was also compared byte for byte with
`catalogue/silver.json`: both were 98,810 bytes and equal.

Remaining work includes full-domain native helper checks, the package semantic
and source-correspondence chains, the original-bundle endpoint, sample execution,
complete assurance, applicable regression coverage and independent review.

The next focused check built `Silver.ComposeNativeRecordBounds` and freshly
audited 15,431 declarations (27.434 s build; 2.922 s audit). It generalizes
index, value and concatenation bounds to an arbitrary unit-context start, with
unchanged value domains. The two-worker/two-thread input map and log are the
`native-value-context-*` files. Remaining caller/source equations are pending.
