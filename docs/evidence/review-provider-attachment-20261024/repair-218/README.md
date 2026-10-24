# Independent #218 repair review evidence

Target: `56fe7bbb442d191dca5ad9b0dcc5f22823713a07`, #218 under #201/#119.
The [exact repair review](../../../reviews/review-provider-attachment-repair-218-20261024.md)
accepts the native constant bridge and corrected source accounting at their
stated local scope. The original F1 report and all its evidence remain byte
identical to review `8e870ce2cc2d05165db8be3ab60b074533e57073`.

The new independent `audit.py` binds the eight-file repair, prior review and
immutable author/repair inputs. It checks source identities and guard spans,
the scalar-context/debug decision boundary, affine per-selector domination,
and corrected scalar/copy/debug arithmetic. It imports no author or prior
checker. Prior graph checks are not replayed. The finite decision table and
affine arithmetic corroborate the source argument; they do not execute GCC.

`current.json` records exact target hashes, source guard hashes, actual Linux
host, completion time and elapsed measurements. Selected reviewer: GPT-6
Astra / Extra High; runtime confirmation, tokens and cost are unavailable.
No compiler, prover, Lean, generated matcher, native target or service ran.
`manifest.json` binds these review files and the new report, excluding itself.
