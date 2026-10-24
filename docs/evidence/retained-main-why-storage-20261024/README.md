# Main Why storage kernel and candidate-gate evidence

2026-10-24 UTC; first #202 author unit under #119. Read the
[research note](../../research/retained-main-why-storage.md) for the source
argument, supported case-free family, exact cut and remaining obligations.
**Full source-to-initial-VC storage and complete #202 capacity remain open.**
Independent exact-freeze review is pending.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-main-why-storage-20261024/check.py
```

The default command is read-only. `--write` updates the author receipt.
No native/compiler/prover/solver, predecessor checker or broad validation is
called. `identity.json` pins two existing archives, 15 complete Why source
files, 23 source spans and 12 provider inputs. All source/native bytes are
reused; no new executable capture or source pin is added.

`kernel.py` models native stored binders, including dead saved keys and
nonleaf saved images, rather than only the opened formula. It exports:

- substitution/closing/opening request bounds using the accepted Extmap
  allocation lemma with actual per-operation cardinalities;
- actual occurrence-sum/product operands, map-height and Ident guards;
- a case-free `add_vc_decl` gate up to entry into `mk_vc_decl`, carrying one
  Ident counter through preconstructed candidate batches;
- ordinary record/list candidate counts and separate complete local/map
  direct-byte envelopes, with explicit zero hashcons requests for this kernel.

Its structural input check does not prove semantic cache validity, native
source derivation or full Main case-freedom. These remain stated input/caller
obligations. Raw fixture constructors create existing test inputs; their cost
is not silently counted as a complete source typing/VC account. An actual
interleaved Main construction must also transport all construction demand
between successive gate entries.

The final focused check passed **4,482 assertions in 2.100503657 seconds** on
Linux x86_64. It verifies source/provider identities and the following new
seams:

- An independent eager frame interpretation checks 360 lazy substitution
  diagrams and their free-occurrence caches, including nonleaf saved images.
- Leaf renaming's additive stored-size bound and preserved free-occurrence
  mass are checked separately from native coefficient maxima.
- Twelve successive leaf renames leave an opened three-node formula but grow
  its stored count from three to fifteen with twelve saved keys.
- Two discarded two-variable quantified candidates still require eight Ident
  increments. Ignored trigger reconstruction, annotation in a let definition,
  saved-image annotation transport and native short circuiting are checked.
- Exact-boundary arithmetic distinguishes safe successors/products from the
  next unsafe operand, without allocating large terms or maps. Cumulative
  mathematical byte totals are deliberately allowed above max_int.
- Unsupported case nodes, unattached input IDs and wrong-type substitutions
  fail the focused model's domain checks. These are model diagnostics, not
  current-language rejection rules.

The retained native allocation-site result is read and hash-bound; neither its
observer, disassembler nor predecessor checker is replayed. Finite diagrams
corroborate the source induction and cannot prove its universal statement.
`result-initial.json` preserves the earlier smaller-scope success. `round.json`
records changed-input validation and the source-manifest correction.

Selected author: GPT-6 Astra / Extra High; runtime confirmation, tokens and
cost unavailable. Live harness goal read: null. Entry-cut inquiry was supplied
by the parent's selected GPT-6 Astra / Extra High read-only subthread. The
parent owns GitHub status, integration, publication and durable session memory.
No CLI memory write was made by this author.
