# Retained restored-path inputs

Round 31, 2026-10-20, owner-authorized #119 / #153 continuation. This packet
extracts finite inputs for the restored-path proof from existing retained
Linux x86-64 captures and pinned Why3/library source archives. It performs no
native run, solver request, new capture, observer replay, binder/alpha analysis,
source fetch or GitHub mutation. Earlier packets are unchanged.

`extract.py` binds the actual archives, manifests and selected members in
`inputs.json`, then writes:

- `library-inventory.json`: the complete retained `int`, `real`, `algebra` and
  `relations` files, totaling **38,678 bytes**; 69 module heads; 102 use/clone
  declarations; a dependency-before-importer topological certificate; declared
  symbol, identifier, operator and namespace **candidates**, with byte maxima.
  The only external target is the source-defined builtin
  `why3.WellFounded.WellFounded`. Exact source excerpts bind its constructor.
- `capture-inventory.json`: direct current-table cell/ephemeron comparison
  with retained raw blocks, hash multiplicities, every current hash-matching
  candidate for each serialized identifier, and available decoded payloads.
- `cut-evidence.json`: exact selected stopped-phase PCs, preparation directive
  sequence, and summary backtrace locations. All retained summary backtraces
  are startup guard traces. Endpoint call-stack frames remain unknown.
- `source-witnesses.json`: exact source ranges for tuple/name construction,
  parser encodings, namespace construction and private path writers, plus
  candidate name-generation/scope sites in typing/Pdecl/Pmodule. The accepted
  Round 30 complete private-writer census is reused and checked against its
  same source archive.
- `result.json`: compact numeric results and explicit unresolved bounds.

Every captured current table has distinct cached hash values: **6,941 / 6,941 /
6,901 / 6,783 / 6,819** rows, each with maximum multiplicity one. Under the
source premise that `Ident.hash` is the numeric tag and lookup tests cached hash
before tag equality, each serialized identifier has either no current candidate
(**64 / 53 / 32 / 3 / 4**) or one current candidate (**2 in every case**).
All those matching candidates have decoded key tags and full third-component
paths: one is 6 bytes in one component and the other is empty in every case.
Their identifier-weighted fallback/current-path byte totals are
**607 / 503 / 334 / 74 / 86**, the accepted Round 29 values.

The source files contain no nested module heads, interface keywords, explicit
scope/namespace heads, type-invariant/witness keywords, or clone `val`/exception
substitutions. All 69 module heads are plain names with no interface colon.
All 52 complete clone spans, including multiline substitutions, are retained
and were inspected. All same-file dependency targets are earlier module heads.
The complete declaration graph is acyclic, with a longest chain of 13 nodes.
The clone-nonexport namespace-candidate ancestry has at most one edge. These
are syntax/graph observations; generated-name and registration semantics are
the companion proof thread's responsibility. Keyword counts include `by`,
`invariant`, `witness`, `exception`, `mutable` and `private`, after comments and
strings are masked. Program `val` and `let` declarations are included in the
symbol-head candidates.

This is the literal source-dependency graph. Arbitrary tag-alias module lookup
results require a semantic argument; acyclicity of these source names alone
does not establish that argument.

The current table's complete payload maximum remains **null**: the selected
retained raw block file decodes only **47 / 47 / 42 / 13 / 22** full payloads.
The collector selects the current bucket array; it does not select a saved old
array or an active-resize-frame root. Those roots and their exclusion remain
unknown here. No observed absence is converted into a future fallback claim.
The lexical maxima are **29** identifier bytes, **26** declared-symbol bytes
and **12** namespace-candidate bytes; none is claimed as a semantic path bound.

Run the bounded offline recheck from the repository root:

```sh
python3 -B docs/evidence/retained-why-path-input-inventory-20261020/check.py
```

`verification.json` records actual check timing. `round.json` records selected
GPT-6.1 Sol / Extra High; runtime setting confirmation, token and monetary
measurements are unavailable. No complete continuation/capacity claim, language
admission or #153 completion is established by this inventory.
