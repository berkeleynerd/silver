# Retained restored-path input inventory

2026-10-20, #119 / #153 Round 31. The
[retained inventory packet](../evidence/retained-why-path-input-inventory-20261020/README.md)
supplies two finite inputs to the restored-path continuation proof without
executing a native process or replaying an observer.

The captured current restored-path tables contain **6,941 / 6,941 / 6,901 /
6,783 / 6,819** cells, with globally distinct cached hashes. Lookup first requires
the queried numeric tag to match that cached hash. Therefore the complete
current-table candidate census for serialized identifiers contains no hidden
second equal-tag binding: **64 / 53 / 32 / 3 / 4** tags have no matching row and
two tags per case have exactly one. All matching rows have decoded key tags and
complete third-component paths. Their identifier-weighted fallback/current-path
totals reproduce **607 / 503 / 334 / 74 / 86** bytes from Round 29. This conclusion
depends on the source lookup/hash premises; it does not require physical-key
freshness or preservation of the first weak lookup.

The literal use/clone source-dependency closure for `int.Int`,
`int.ComputerDivision`, `real.Real` and `real.Truncate` comprises the retained
complete `int`, `real`, `algebra` and
`relations` files, totaling **38,678 bytes**, and the source-defined builtin
`why3.WellFounded.WellFounded`. The four files declare 69 modules and 102
use/clone dependencies. The graph is acyclic and has a longest chain of 13
modules; same-file dependencies refer to earlier module heads. There are no
nested module, interface or explicit namespace/scope declarations. Complete
clone-declaration candidates contain no `val` or exception substitutions.
The typed-source exclusion keyword counts are zero, including `invariant`,
`by`, `witness`, `mutable` and `private`.

Maximum lexical identifier, declared-symbol-head and namespace candidates are
29, 26 and 12 bytes. The three nonexport clone aliases are `MulAssoc`, `MulComm`
and `TO`, and their graph ancestry contains at most one alias edge. These
checkable source facts support a separate semantic bound; the inventory does
not turn its regular-expression candidate census into a parser or generated-name
proof. Program `val`/`let` declarations, operator encodings, type constructors
and inductive cases are included among the candidates. Exact retained source
witnesses identify Pdecl/Pmodule/typing name-generation sites for review.

The source-name DAG does not establish a corresponding bound on arbitrary
tag-alias module lookup results. That semantic obligation remains separate.

The global current-table payload maximum, saved old-array roots, active resize
frames and whole-continuation identifier bound remain null. Only 47 / 47 / 42 /
13 / 22 current payloads are completely available in the selected raw block
files. The retained endpoint summaries supply stopped-phase PCs and preparation
directives; their backtraces all concern startup guards. They supply no endpoint
call-stack frames from which this inventory could exclude a suspended resize.
The companion proof must discharge that reachability premise and the bound on
future installed paths. Samples and finite inventories do not establish the
universal source/native assurance obligations.
