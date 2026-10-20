# One-read Theory publication bound

Round 35, 2026-10-20 UTC, Refs #119, #153, #155. See the
[semantic argument](../../research/retained-why-library-publication-bound.md).

`bound.json` projects the accepted fixed four-file inventory onto byte spans,
clone expansion and complete-file read counts. `source-witness.json` records
72 exact excerpts from 15 members of the retained Why3 and OCaml source archives.
`check.py` independently regenerates these projections and checks equality:

```
python3 docs/evidence/retained-why-library-publication-bound-20261020/check.py
```

`--write` refreshes this packet's two generated JSON files. The checker reads
the existing inventory and three source archives; it does not execute the
predecessor inventory checker, a native toolchain executable, a debugger or
the proof suite. It does not prove the semantic transfer automatically.

The common base result is `C_base <= 3404503 + 8*I`, with
`K <= 2*I + 38679`. The complete writer interface is
`W <= E*(3*T_prepared + 2*C_base) + 4*128*K + 4*e*(K+1)`, with the last two
allowances charged once globally and `e <= 2`. `C_base` alone is not a
standalone `C_lib` bound. An initial registration bound
`I` is a separate required attachment, not established by this packet. The
five counter values supplied in coordination are not silently promoted to
proved initial-registration bounds here. The lead owns that attachment,
numeric composition and independent review.

Review found that an interrupted strong-memo resize could lose many cached
bindings. The final packet conservatively charges every possible later resize
as whole-cache loss, including successful resizes; it needs no recovery
invariant for an interrupted rehash's malformed bucket links.

Selected author model/effort: GPT-6 Astra / Extra High; runtime setting
unconfirmed. No token/cost measurement is available. The author worked only
in this packet and its companion note, on an isolated branch/worktree.
