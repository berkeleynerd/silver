# Shared package native expression core

Focused run `20261122T164920-04e862caf4b3` passed on Linux x86-64 with
2 Lake workers and 2 Lean threads per process under the shared eight-CPU
allocation. The fresh audit checked 13,734 declarations using only the standard
Lean foundations. The managed duration was 16.881 seconds. Both complete modules
are imported by the focused target `Silver.ApplicationNativeGuards`.

Every field, selection, aggregate, operator and callee application has a typed
meaning. Constructor checks reject the negated-disjunction precedence collision,
unparenthesized mixed logical operators and right-nested subtraction, invalid
selected prefixes, malformed nested conditional children, incorrectly scoped
quantifier bodies/bounds, and duplicate record updates. Numeric identifier tests
ensure normalized ASCII identifiers are checked directly by the kernel.

The source frontend and actual callee equations remain required. Active-prefix
setters cover positive in-prefix writes and count reductions; they do not establish
inactive-storage or count-growth correspondence. No actual package reader or
complete application assurance endpoint is claimed by this helper check.

Initial focused attempts failed at declaration naming/mutual-type setup and
identifier-reduction issues. The managed ledger retains those failures and their
diagnostic; the files here retain only the successful complete focused result.
The manifest hashes the compressed artifacts and their original contents.
