# Private memo source review

Exact author target `bb61e70086339202fd167cd4990f86106e63ebe6`. Source paths
below are retained archive members. The independent packet binds whole source
members and strict spans; lexical anchors only identify reviewed statements,
not proofs of their semantics.

## Ephemeron induction

For each private table, keep the invariants that its completed bucket graph is
proper, h.size counts its physical stored cells, and at most one live binding
has each tag. Weakhtbl's scalar hash/equality use the immutable tag; its set is
H.replace. There is no mutation callback in those operations. A hit changes
the ephemeron key/data without changing table size. A failed search adds one
cell and increments once. Dead cells can coexist with a later insertion of
the same tag; the argument does not assume historical physical-key uniqueness.

Clean makes no application insertion. A cell retained by check_key was live
when cleaning began, because keys cannot become live in this table without a
writer. Consequently the retained set has at most M members, even if some die
later during the pass. Each removed cell is decremented once, so no underflow
occurs. Partial rebuilding and rehash do not count old/new list copies twice
in h.size. The existing guarded-mutation premise handles interrupted or failed
publication; this is not an invariant for arbitrarily resumed partial state.

An actual growth L -> 2L requires cleaned size >= L/2, hence 2L <= 4M, and
2L < Amax. Actual backing lengths are powers of two, so Amax=2^54-1 gives
L<=2^53, including at the native stop. The multiplication 2L is evaluated
before that test but is still <=2^54. Initialization starts at 16 and rounds
requests <=63 to at most64. Induction gives
`L <= min(2^53,max(L0,4M))`.

At a completed insertion, either size never exceeded 2L, or cleanup restored
size <= M. Thus completed size<=max(2B,M), with the next increment bounded by
max(2B+1,M+1). A rejected growth still cleans. This is essential when M or4M
exceeds the power-of-two backing cap. Hash masking by L-1 gives a valid bucket
index. The checked M, size, doubling, threshold and array-byte operands fit
signed63. List-recursion depth, allocation success and total physical memory
remain in the existing resource boundary.

Rehash can retain old and new arrays, bounded by 2B slots. Its list copies and
uncollected garbage are not a cumulative-allocation claim. The result does
not require a native integer bound on the cumulative number of cache misses.

## Caller and key attachment

- `weakhtbl.ml:65–122` chooses K1, hashes/compares S.tag and uses replace.
  Producer callbacks in memoize/memoize_rec finish before set begins; recursive
  producer work is not reentrancy inside the replacement search.
- `trans.ml:46–99` uses task_tag for Wtask, create 63, and writes only through
  set. `task.ml:88–106` attaches that tag to Hstask. Goal storage is bypassed.
  Driver's retained update closure calls Trans.store. The selected three
  driver identities and existing mutation boundary are reused by identity;
  Hint.create 5 starts at 16 and three inserts cannot trigger growth.
- `trans.ml:114–116` uses Wdecl.memoize 63. `decl.ml:391–419` connects Wdecl
  to d_tag and ordinary Hsdecl constructors. Introduction's separate content
  Hsdecl has `tag _ d=d`; its Wdecl queue therefore still uses an ordinary
  declaration tag, not the discarded private content counter.
- `task.ml:19–30` keys Wtds with Stdecl.id. `hcpt.ml:131–158,505–525`
  connects the history identity to its shared Hcpt allocation domain, including
  Empty 0. The metadata wrappers use memoize 17, not the tdecl tag as key.
- `term.ml:1153` installs a fresh Wty.memoize 17 around each t_gen_map type
  mapper. `ty.ml:90–122` connects Wty to ty_tag/Hsty. The actual input is an
  already tagged type.
- Introduction's Wid.create 7 uses Ident.id_tag through
  `ident.ml:165–173` and its registration source at 187–192. These tables expose
  closures rather than raw tables; none of the selected callers exposes add,
  reset/copy, or a mutating iteration callback.

These are per-table bounds over the complete R65 key universe F+1. They include
work before a closure's registration and do not assume a newly registered
closure has never been called. They do not independently close every producer
failure prefix or the remaining complete fixed-domain conjunction.

## Introduction and immutable maps

R61's retained source argument explicitly bounds local Hvs writes, substitution
and known-map writes by 8m+p per episode. The new attachment is checked against
the actual Hvs.replace sites in `introduction.ml:89,98,102,302,306`, and the
fresh create 7 sites at 205 and 313. A binder opening contributes one replacement
per opened variable; repeated keys cannot create more cells than writes.
`term.ml:22–31`, `wstdlib.ml:93–99` and `exthtbl.ml:40–43` connect Hvs to
the ordinary Hashtbl functor. Its growth threshold is size>2L, so the next
power of two above max(16,requests) is conservative for these fresh tables.

The content and queue calls at `introduction.ml:119–131,175–186` match R61's
8m and8m+p request families. Queue.iter's callbacks only test known-map
membership and may raise Found; they do not append. Queue.add increments once.
The already charged episode totals 155/128/68/8/5 are multiplied once. The
private Weak.Make table receives the new input (5003,0,0,E*8m) to the previously
accepted pure transfer; the reviewer independently specializes the arithmetic
without importing or rerunning that provider.

`remove_unused.ml:30–36,102–129,177–258` retains dependency maps with prsymbol
or identifier keys and Sid values. Prsymbol, type-symbol and logic-symbol
ordering keys are their registered identifier tags (`decl.ml:289–303`,
`ty.ml:65–79`, `term.ml:51–61`). Detect_polymorphism's on_tagged_ts/ls/pr
sets use those symbol families. Thus each completed map/set has at most
Ident_F+1 keys; each Sid payload has the same key-cardinality bound, without
bounding arbitrary payload computation. R67's accepted immutable-tree height
transfer is reused with the explicit two-input envelope.

The separate `remove_unused.ml:135–141` Smeta set contains the fixed two
metadata descriptors range/float. Its keys are meta_tag (`theory.ml:117–125`),
not Ident tags. It is covered directly by cardinality 2; the review does not
misidentify that set with the on_tagged_ts/ls/pr result sets. The unchanged
Ident-domain bounds are much larger than 2.

No material finding remains for this bounded interface. Universal source
correspondence still relies on the accepted source/native/key premises; the
new audit does not replace them with finite numeric examples.
