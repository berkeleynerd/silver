# Review of the private introduction counter

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Reviewed frozen worker commit `17ca2f6e21b44641abebc3cacb217e5404e809b9`,
integrated as `ca0f3b1444`. **Accepted within its counter-value scope.**
The [argument](../research/retained-why-introduction-counter.md) establishes
irrelevance of one private value under the retained source/runtime premise;
it does not establish event, table, traversal, preparation or printer capacity.
No material defect was found.

The primary agent independently inspected the complete `Hashcons.Make`
implementation and its sealed interface, introduction's identity tag and
hash/equality closures, the sole local `Hsdecl.hashcons` use and its returned
declaration consumers, and the complete introduction interface. `next_tag`
has no exported accessor or indirect consumer through `stats`/`iter`; its only
read values are arguments to `tag _ d = d`. The declaration-tagging instance
in `Decl` is a separate functor application and still writes the real d_tag.
The local module's name does not identify shared mutable state with that
instance. Same-object cache hits can still increment, as the argument states.

The newly retained OCaml `stdlib.mli:325–327,341–342,1242–1244` explicitly
defines modular integer operations without overflow failure and `incr` as
assignment of the successor. Thus projecting away this machine-integer cell
preserves the outputs, branches and weak-table effects for every operation,
including across defined wrap. This is an observational irrelevance argument
for an unused value, not an exemption for useful identities or lengths. The
separate physical-resource trust assumption is not used to justify wrap.

The checker verifies the new six-member archive and dependencies before its
inventory/arithmetic composition. The accepted driver callable is replayed
and must equal its retained result. Its finite 153/459/6120 dispatch bounds
remain unchanged, and every larger capacity flag stays false. Textual source
checks are accurately described as corroboration of inspected semantics,
not a machine-checked source proof. The downloaded sources retain exact
revision URLs and the previously recorded complete Why3 archive join; they
make no new historical installed-binary source-identity claim.
The parent also hash-checked the retained complete archive at
`/tmp/silver-producer-response-20261018/why3-complete.zip` against the recorded
digest and independently confirmed both new Why3 interfaces byte-equal its
unique corresponding members. No additional source download was needed.

The independent replay ran once in the worker's clean frozen worktree:

```sh
python3 -B docs/evidence/retained-why-introduction-counter-20261018/check.py
```

It returned zero with empty stderr in **0.383575865 seconds** measured around
the subprocess. Output byte-equals retained `result.json`, SHA-256
`e59b5e312e143f7da727fec7c9dcbcde68549fbb62b00c83dfa87bbf525d72c8`.
The parent inspected source excerpts independently of the checker. No native
target, proof, solver, build or full suite ran.

The worker selected **GPT-6.1 Sol / Extra High** and recorded 426 seconds of
inspection/replay before handoff. The parent review used the unchanged lead
setting, whose runtime model/effort is not exposed by the available controls.
No lead setting change is claimed. Token/monetary costs and a separately
measured parent source-review interval are unavailable; replay time is above.
This bounded result required no implementation rework. The next required
work still includes generated premise/event counts, captured bucket lengths,
structural visits, weak-table/cache backing and real identity lifetimes.
