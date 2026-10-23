# Independent fresh name-table review

This packet supports the [review report](../../reviews/review-printer-name-tables-20261023.md)
for #119 / #153. Accepted author freeze:
`6c8af79092bb7ec63b876582f10b94da95a9072b`, following initial
`0fb01402da7293749de0a9cc51332348177d356e`.

Review corrected the nullary value-application census: two head-name calls,
with no type-rendering call under the retained ground-signature family, still
fit T+1. The author added the source witness and strict source-range guards.
The exported numeric result is unchanged; L remains null.

`audit.py` imports no author or predecessor code. It verifies exact target
bytes, retained provider/archive/member identities, all 22 source ranges,
blacklist counts, independent five-case arithmetic and focused numerical
boundaries. `audit-result.json` contains exact hashes, source line counts and
results. `round.json` distinguishes selected settings, unavailable runtime
confirmation and measured timing. The companion report supplies the reviewed
source argument; finite checks do not prove source semantics.

The one independent audit passed in 1.568308377 seconds:

```sh
python3 -B docs/evidence/retained-printer-name-tables-review-20261023/audit.py \
  6c8af79092bb7ec63b876582f10b94da95a9072b
```

Only this review directory is written by the audit. No native, solver, proof,
capture, author/predecessor checker or small-model replay occurred. An identical
successful rerun is unnecessary without a changed input or unresolved concern.
Raw name bytes, successful naming semantics, other printer/output owners and
whole #119 capacity remain open.
