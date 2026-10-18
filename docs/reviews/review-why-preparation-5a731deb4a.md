# Review: conditional Why3 preparation transfer

2026-10-18, Linux x86_64,
[#119](https://github.com/berkeleynerd/silver/issues/119).

**Accepted within the stated conditional scope.** No material finding requiring
repair was identified. This closes the reviewed `inline_trivial` term-kernel
transfer and declaration event bounds; it does not establish preparation
capacity for the five fixed inputs or complete #119.

## Exact inputs and review method

Reviewed commit: `5a731deb4a2e4ef6fee59821d85edc20149696f1`.
The review covered the complete changed
[source argument](../research/retained-why-preparation-bound.md) and
[evidence packet](../evidence/retained-why-preparation-bound-20261018/README.md):
`compose.py`, `check.py`, `inputs.json`, `fixtures.json`, `result.json`,
`check-result.json`, `round.json`, `README.md` and `sources.tar.gz`.
The governing Oracle, current capacity authorization, assurance/trusted-boundary
scope, and review/workflow requirements were read. The live harness goal query
returned no goal for this reviewer thread.

The accepted driver envelope (at most 153 registered tasks, 459 task/driver
pairs and 6,120 outer directives) and the accepted private
`Introduction.Hsdecl` irrelevance result were reused, not reopened. No source
history search or historical binary/source identity claim was added.

Independent source reading used the packet's complete Why3 files at revision
`9390baf120ef260547dfa14f08e11c890b203d9c`. All fourteen archive members,
including the license, were independently compared byte-for-byte with the
already downloaded full archive
`/tmp/silver-producer-response-20261018/why3-complete.zip`.
Its verified identity was 9,976,591 bytes, SHA-256
`8d4a8dcdcdf965ce3cc6935bdd60c1378a5ec47b4a0bdedae6651ee50ed03f8c`.
The packet archive identity and its accepted-source joins were also checked
by the replay. These checks preserve the existing relevant-source/runtime
premise; they do not independently attest the installed executable.

## Reasons for acceptance

1. **The recurrence follows the actual recursion boundary.**
   `inlining.ml:24–40` transforms children first and substitutes a saved body
   once. It does not recursively inline the returned replacement. At an
   application hit, substitution has mass at most
   `M * max(1, max_i rewritten_argument_mass_i)`. Inductively, each argument
   contributes at most its input mass times its own application factors;
   `M >= 1` lets the product over all children dominate each factor. Charging
   one further factor at the hit gives `m(t) * M^a(t)`. At other nodes the
   additive constructor, binder and pattern weights obey the same inequality.
   Including triggers, repeated subtree occurrences and pattern/binder weights
   is necessary. The argument does not use the name “trivial” as a size bound.

2. **Relocation clears the substitutions that would invalidate the later
   visit counts.** `term.ml:648` constructs a new attributed record on each
   relocation entry. The child-result identity tests at `:1247–1277` therefore
   force binding closure after traversal. I also checked the less obvious
   `t_attr_copy` route: `t_similar` at `:404–418` requires physical equality of
   binder tuples, so it cannot restore an old binder in place of the newly
   closed tuple. Closure at `:785–795` installs empty `bv_subst` maps.
   Consequently `t_gen_map` has no saved substitution values to traverse and
   `gen_bnd_rename` has no extra saved-substitution keys to rename. The final
   substitution at `:1171–1173` stops descending each binder and does not
   traverse replacement terms at variable leaves (`:739–778`). Each of those
   two passes is therefore bounded by the relocated body's opened node count.

3. **The identifier charge counts allocations, including discarded fresh
   variables.** Input opening allocates one variable per input binder slot.
   Each hit's relocation allocates at most `B`, and type mapping allocates at
   most another `B + F`, before the arguments are substituted. Pattern opening
   uses distinct `pat_vars` keys, including `Por` patterns, rather than one
   fresh identifier per pattern-variable occurrence. `create_vsymbol` reaches
   `id_register` once (`term.ml:36–39`, `ident.ml:187–215`); cloning a
   pre-identifier alone does not increment that counter. Type matching and
   instantiation use existing named symbols. These facts support
   `b(t) + H*(2*B + F)` independently of duplication in the resulting term.

4. **Context composition respects definition availability and closure.**
   `Decl.decl_map` processes every body of a logical declaration with the
   preceding environment. `Inlining.fold` adds a singleton definition only
   after mapping and checking the declaration. The callable's extra singleton
   candidates only increase coordinate maxima; it does not expose a definition
   inside its own batch. `make_ls_defn` checks that free term variables are
   among the formals, justifying the arity bound on `F`. Its head, equality/iff
   and outer quantifier contribute exactly the stated upper allowance
   `2 + 2*k + (1 if k>0 else 0)`. Reuse through `open_ls_defn_cb` or declaration
   hashconsing compares strict terms, including triggers, and preserves the
   opened dimensions (`decl.ml:69–74,350–366`; `term.ml:283–402,536–539`).

5. **The declaration and fold counts are event bounds.**
   `trans.ml:75–99` makes at most one lookup and one callback per input chain
   node and at most one cache set per visited non-goal. A cached prefix skips
   work under the existing unique-tag invariant. `Task.add_tdecl` adds at most
   one node and does not recursively export a `Use` (`task.ml:148–196`).
   `decl_map` calls one constructor for each mapped logical, inductive or
   proposition declaration; the inspected validators do not create additional
   declarations. Each constructor reaches `mk_decl` once, and each resulting
   `Hsdecl.hashcons`/`unique` call increments at most once. The actual
   `Decl.Hsdecl` tag is stored in `d_tag`; the accepted result for the different
   private introduction counter does not dispose of this counter.

The mathematical domain is the ordinary well-formed Why3 constructor domain,
with type-correct applications, valid binding metadata, finite opened trees,
and noncolliding tags. In particular, ordinary `t_quant`/`t_quant_close`
eliminate empty binder lists at construction (`term.ml:959–960,1000–1001`),
and the mapper preserves nonempty binder lists. The review does not extend the
recursion-count argument to externally fabricated malformed term records or
to executions after a representation invariant has already failed.

## Retained boundaries and verification

The source confirms the missing entry interface: `prepare_task` invokes
`update_task` before the selected transforms; exports can flatten additional
theories and cloned metas can instantiate types. With counterexamples off,
the relevant prefix removes unused CE declarations, and altergo additionally
monomorphises. Registration dimensions therefore do not instantiate this
transfer. The callable correctly retains false completion flags.

Opened dimensions do not bound every stored substitution value visited while
opening a binder. The fresh-variable result does not cover `open_ls_defn`,
termination/inductive validators or other declaration work. Types, attributes,
semantic-count arithmetic, task/theory/type tags, initial counter states and
other process callers remain separate. Fold lookup/set counts do not establish
ephemeron backing-array or collision-chain capacity. These exclusions are
explicit in the reviewed argument and are not findings against its scoped
claim. They remain required before a fixed-input or whole-pipeline conclusion.

One offline replay was run with assertions enabled:

```sh
python3 -B docs/evidence/retained-why-preparation-bound-20261018/check.py
```

It passed: complete retained-result equality, 600 synthetic tree expansions,
four bad-dimension rejections, altered-archive rejection and standalone CLI
replay. Measured subprocess elapsed time was 0.518 seconds, return code zero,
with zero stderr bytes. The tree fixtures support the size recurrence; their
identifier assertion repeats the arithmetic formula, so the identifier result
rests on the independent source analysis above. This was not an OCaml execution
or a machine-checked source proof. No compiler, prover, native target, Lean,
full suite, network fetch, GitHub write or CLI-memory update was performed.

Reviewer selection: **GPT-6 Astra, Extra High**. Independent runtime confirmation
of that selection and token/cost measurements were unavailable. Review elapsed
time is recorded below; it includes source reading, archive joins, offline
replay and report preparation, and excludes parent integration/publication.

Review interval: `2026-10-18 19:44:36 UTC` to `2026-10-18 19:47:50 UTC`; `194`
seconds. Intended result: independently challenge the conditional transfer.
Achieved result: scoped acceptance, with no material repair requested and all
fixed-input/shared-lifetime obligations retained.
