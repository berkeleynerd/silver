# Original package-unit evaluator totality — 2026-11-27

Run `20261127T211342-e14fe76e1ae0` passed the focused
`ApplicationPackageUnitTotal` target and a fresh audit of 30,616 declarations.
Every captured input matches; the input-verification file records the count.
Two failed drafts and their diagnostic checkpoint remain retained. Repairs
exposed an already proved bound to arithmetic automation, normalized Boolean
control, and fixed namespace/linter errors; no domain or theorem budget changed.

The generic `body_total` theorem establishes finite typed execution for every
incoming store under the callee cursor bounds. It uses the actual strict-progress
rejection guards of the object and routine loops, and preserves partially
written metadata on rejection. `body_readers_total` derives those bounds for the
existing source-derived model readers without a successful-read assumption.
`body_readers_meaning` then proves exact observable metadata/Accepted equality
with the independently totalized `readBody`, using execution uniqueness.
The proof evaluator allowance is derived from text length; it adds no source
membership restriction. No incoming scratch value is fixed.

This closes the missing evaluator-existence direction at the model-reader
composition layer. Actual imported Unit/Completion call interpretations and
caller-domain preservation must still connect these results to the original
source; the final application endpoint and complete feature audit remain open.

The incremental check reused matching dependency objects and ran two Lake
workers, two threads per process and an 8192 MiB per-process threshold, under
the host's eight-CPU allocation. A fresh axiom audit was performed; no independent
kernel replay is claimed. Selected proof category: Astra Max; live model/effort
was not independently exposed. No native implementation source changed.
