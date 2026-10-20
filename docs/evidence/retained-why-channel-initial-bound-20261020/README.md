# Initial channel headroom evidence

The [argument](../../research/retained-why-channel-initial-bound.md) reuses the
accepted debugger-controlled prefix charge and adds the channel/custom-wrapper
source/native attachment. It bounds initial managed-channel cardinalities and
reference counts, without reading the channel-list globals or executing a target.

Run the focused check from the repository root:

```sh
python3 -B docs/evidence/retained-why-channel-initial-bound-20261020/check.py
```

`inputs.json` binds inherited records and new source/native witnesses.
`source-witnesses.json` retains exact slices from the existing OCaml archive.
`native-bodies.json` projects existing disassembly; the checker compares every
retained instruction byte to the installed ELF. `result.json` supplies five
conditional initial bounds; all complete-channel/save/pipeline flags remain
false. The checker binds the reviewed source argument and checks arithmetic;
it is not a machine proof of the runtime or its source/native interpretation.

No predecessor checker, memory replay, native capture, new disassembler,
compiler/solver/proof/full-suite or source fetch is run. Parent Round 36 records
integration, independent review and available cost evidence. Initial unmanaged
channels, post-cut wrapper attempts and flush/global-list behavior remain open.
