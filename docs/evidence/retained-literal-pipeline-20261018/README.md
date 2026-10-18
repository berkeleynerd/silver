# Literal-output aggregate checkpoint

Offline research for #119, 2026-10-18, Linux x86-64. One actual source scan
drives the retained native lowering/data, RTL/helper and Why equations, with
checked common naming/System/library bytes and selected launch roles. The
accepted output-binder checksum checker is replayed once per context.

The [source argument](../../research/retained-literal-pipeline.md) identifies
the closed bounds-pool/shared-symbol join and the next call-edge/IPA lifetime consumer. Passing the instantiated
conditions does not establish whole-pipeline capacity: the result always
preserves its named open joins and changes no production admission.

```sh
python3 docs/evidence/retained-literal-pipeline-20261018/compose.py \
  --gcc-root /path/to/retained-gcc \
  --ada-root /path/to/retained-gcc/gcc/ada \
  --plugin-include /path/to/selected/plugin/include \
  --output /tmp/literal-pipeline.json
```

`--source FILE` substitutes the same bytes into every source-counted component.
`--descriptor FILE` selects the checked shared inputs and partial launch record;
the default is `fixture.json`. `check.py` accepts the same three source-root
arguments and `--output`, and runs 21 interface checks. It reuses one context's
successful retained checks across source variations.

`inputs.json` pins formulas, predecessor results and source arguments.
The existing source manifests and `source-join-inputs.json` check complete
source/header files against their hashes; the RTL and checksum checkers retain
their own archive verification. `result.json` records the Hello World
substitution, and `check-results.json` records successful checks, including the
two deliberate Why-envelope failures at P=512. Source paths in regenerated
results identify the actual workspace; compare conditions and identities
rather than expecting those attribution paths to match across worktrees.

Implementation basis: integrated `e7226cdca1`, including the reviewed checksum
closure; null composition is retained as a scope reference, not executed on
literal source. No compiler/prover/native validation was run for this packet.

`native_pool_lifetime` returns bounded incoming tree state, symbol counters,
initializer/reference lifetimes, individual request groups and a `5C+5` GGC
event delta, plus one possible singleton-finalizer registration. The fixed
prefix bounds incoming pool entries by 39,257 and capacity by 131,071; those
are conservative transfer bounds, not observed occupancies. This does not reuse
null's 40,098-event lifetime. The remaining collector and pipeline joins stay
open. The source manifest includes all files used by the transferred fixed
prefix/symbol ingress and the new lifecycle argument.
