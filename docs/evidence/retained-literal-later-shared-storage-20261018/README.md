# Named later shared-storage transfer

Offline #119 research on the retained Linux x86-64/LP64 compiler snapshot.
The [source argument](../../research/retained-literal-later-shared-storage.md)
joins five disjoint named consumers to the corrected original shared state.
It does not establish a complete later lifetime or change admission.

For C literal calls and N null statements, the named rows add `2C+1`
identifier insertions, `3C+2` declaration UIDs, zero type UIDs and six scalar
finalizer registrations. Direct objects retain their existing owners. These
shared demands add no GGC event: identifier/finalizer arrays use ordinary heap
backing. The corresponding byte projections exclude unjoined interleaving.

From the repository root:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-literal-later-shared-storage-20261018/derive.py --gcc-root /tmp/silver-backend-compose-20261018/full-source
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-literal-later-shared-storage-20261018/check.py --gcc-root /tmp/silver-backend-compose-20261018/full-source
```

`inputs.json` pins 31 complete compiler files, 21 unchanged repository inputs,
seven accepted pure function ASTs and their native-width assignment. Only the
pinned aggregate functions are compiled into an isolated namespace; no
aggregate module or Context is executed. Accepted component suites are not
rerun. The retained source revision is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

`derive.py` accepts `--source`, `--shared-input`, `--corrected-input`,
`--residuals` and `--output`. An alternate source requires its source-bound
original shared result and exact indexed identifier correction; equal C/N
counts alone do not identify the source. The default inputs are retained
Hello evidence. The residual JSON may supply any of these nonnegative
integer ceilings:

```json
{
  "identifier_insertions": null,
  "DECL_UID_increments": null,
  "type_UID_increments": null,
  "scalar_finalizer_registrations": null
}
```

Omitted or null values keep their full endpoints unresolved. Explicit values,
including zero, calculate conditional arithmetic without establishing their
source bounds. Complete later/global-counter/gimplifier/collector/native
flags remain false; total GGC events remain null.

The exported `rtl_hash_transfer` is separately conditional: it needs complete
incoming history/capacity and source-bounded lookup/new-entry counts. Its
request result covers lookup-driven backbones only; constructors, `empty()`,
resizing `traverse()` and explicit resizes need their own source owners.
Its non-lookup count remains null and complete-cache flag false. Default
native output does not call it with invented inputs.

`remaining-families.json` records the remaining selected native shared/counter
families and next source join, including ordinary source line maps separately.
`check.py` tests actual-source identity, ownership, residual null semantics,
neighboring arithmetic endpoints, retained capacities and independent small
weak-cache histories. Its extra recognized sources use explicitly labelled
narrow incoming-field fixtures; they are not full predecessor reruns.
`check-results.json` records the executed checks, exact code/argument
identities and elapsed time. `round.json` records selected settings and
available execution evidence. Independent review and aggregate attachment
belong to the parent task.
