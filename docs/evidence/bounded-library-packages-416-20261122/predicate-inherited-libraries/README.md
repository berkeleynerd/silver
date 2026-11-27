# Inherited predicate library interpretation

Linux x86-64 focused run `20261127T120912-d976550f59a1` checked
`Silver.PredicateNativeLibraries` with Lean 4.34.1 using two workers and two
threads per process. The incremental build took 633.020 seconds and the fresh
axiom audit covered 44,682 declarations in 6.662 seconds. The managed input
digest is `af0423e92789e2885cebd8f1cbb282fe3c5e063373ce42c6c3f622b15e1afc62`.

The library links carry the checked qualified scalar reference reader and
lookup, qualified Boolean lookup and bare default specialization. The helper
interpretation derives the resulting calls' meanings on their native domains,
including the absent-qualifier span. It supplies the original expression
context of 1 for the default call. The model witnesses instantiate the links
with interpreted scalar, Boolean and composed callees.

The checked Compose prerequisites match primary commit `5c81b0b1a2`. This
focus covers the target's imported dependencies. The integration worktree
owns the enclosing Output source binding and the complete checkpoint.
