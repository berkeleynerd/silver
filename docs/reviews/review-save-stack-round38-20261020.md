# Selected save caller-stack review, Round 38

2026-10-20 UTC; #119 / #153. **Accepted under the stated retained-input,
source/native, control and service-interface premises.** No material defect or
required repair was identified. This accepts the binder/private-formatter and
serializer components and their selected save-caller composition. It does not
establish complete save capacity, process stack or physical adequacy.

The binder/formatter author freeze is
`562b9a1d8d18da46e9017c9d49c097d1d9bf64f5`; the serializer author freeze is
`8591cb77ed5a39fda7be0a2d349ebafa1383b076`. Both were reviewed together at
`7cede604244f721e3a4070344a8ca127c5f62844`. The final review target additionally
includes the root's three-file composition at
`14ba1434a863e37cf4d346914d408b3cb2c0a57e`. The separate exit-initial-values
packet present in that ancestry is outside this review.

Selected reviewer setting: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime model/effort confirmation and individual token/cost telemetry
were unavailable. Observed review start was 14:53:47 UTC; semantic review and
the five-row join check completed at 15:00:25 UTC, an elapsed 398 seconds.
The reviewer used a separate Linux x86_64 worktree and owns only this report.
The lead retains integration, issues, durable memory and publication. The
reviewer did not author the reviewed packets.

Exact review inputs are the [binder/formatter argument](../research/retained-why-save-binder-formatter-stack.md)
and its [13-file packet](../evidence/retained-why-save-binder-formatter-stack-20261020/README.md),
the [serializer argument](../research/retained-why-save-serializer-stack.md) and
its [14-file packet](../evidence/retained-why-save-serializer-stack-20261020/README.md),
and the [composition argument](../research/retained-why-save-owned-stack-join.md)
with its [two-file packet](../evidence/retained-why-save-round38-20261020/README.md).
This includes their checkers, selection/transfer code, retained source/native
records, callback and import interfaces, per-body multiplicities, input
identities and numerical results. Accepted task-selection, dynamic opening,
attribute, table, private-printer and global protocol evidence was reused as
input; its checkers were not replayed.

The reviewed source identities remain Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84`. The installed ELF SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
the retained disassembly SHA256 is
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
The governing criteria are Oracle 7–9, 13, 21 and 25, complete caller closure,
source/native correspondence and the separation of tool callers from trusted
service interiors. The following challenges were resolved.

- **Public opening entries and selected branches.** The Term module stores
  closures at `0xb49040` / slot `0x1f0` and `0xb490a0` / slot `0x200` whose
  executed entries are `caml_tuplify3` and `caml_tuplify4`. Their 16-byte own
  bounds include the return slot; their local reservation is restored before
  transfer to the raw opening implementation. Both the explanation fold and
  Shape's three indirect opening sites use these public interfaces. The
  no-Tcase invariant, selected SV6 branch and variable-only deferred images
  justify the named exclusions. Constant identity makes the selected
  `t_attr_copy` exit before constant comparison; type equality is physical.
  `id_clone` receives empty additional attributes, so its union does not
  recursively inspect arbitrary variable-identifier attributes. The attribute
  bound A need cover only the retained term/proposition union used elsewhere.

- **Binder simultaneous instances.** Explanation search finishes an opening
  before descending into its result. The current opening has a bounded
  structural substitution ancestry and at most one terminal variable image.
  The map nests are deferred-image map → variable substitution → attribute
  union, or fold2-intersection → add-variable image → scalar map/union.
  Variable images cannot recursively enter a binder or arbitrary subtree.
  Three map contexts, each with the two-domain `2K+1` allowance, safely cover
  those routes. Argument-list and trigger-map ancestry supports the stated
  `(D+3)*(L+1)` List.map allowance; fold-left iteration uses native backedges.
  Scalar map comparators return before the next recursive descent, avoiding
  an adapter chain per map ancestor. The fold2 callback's arity-four closure
  selects its raw `add_nt_vars` entry through exact-arity apply4; its stored
  curry4 constructor is not an executed missing body. G's adapter allowance
  covers the selected structural, list and scalar contexts. G includes
  `X=32A+768` once; X is not another term in the parent join.

- **Serializer ancestry and one-instance helpers.** Preliminary folds and
  XML recursion follow strict descendants of the retained forest. Shape
  recursion follows the preserved constructor skeleton, with trigger
  iterators contributing up to two levels per ancestor. This supports the
  separate forest, `D+1`, `2D+Z+4` and `Z+1` allowances. Sort partitions shrink;
  merge and reversal bodies loop. Extmap recursion descends strict subtrees,
  and the sums distinguish global dictionary, alpha/name and prover key
  domains. The alpha-renaming A in S is not G's attribute cardinality.
  Prover folding can suspend over an insertion; both families are charged.
  Session/prover table callbacks can enter one inner table traversal, with
  no third traversal in these selected paths. XML attributes and optional
  printers finish before child serialization, so their wrappers do not
  accumulate once per forest ancestor. The remaining name, path, string,
  bucket and scalar helpers are sequential or native tail loops. A source
  helper's lack of direct recursion alone was not used to establish its
  one-instance bound.

- **Callback closure and application frames.** Source-selected hash/equality
  and comparison environments distinguish integer/string/prover/tag keys
  from ephemeron Weakhtbl keys. Resize constructs and applies only the
  selected key-index closure. The four computed switch sites remain within
  their checked bodies; they are not arbitrary closure calls. Optional
  randomized Hashtbl seeding reaches the fixed PRNG initializer, the
  recursive-force Undefined thunk or the cached failure thunk. It does not
  introduce recursive initialization in one save. The native apply2/3/4/5/7/
  10/12 entries apply excess arguments sequentially; curry constructors
  return and curry application entries tail-transfer to actual callees.
  Fixed typed-format returned closures enter F. For S's finite contexts,
  charging each of the 13 adapters `2*(M+1)` is conservative; M counts all
  allowed non-adapter instances, including many map ancestors that cannot
  retain an application chain simultaneously. This large overcharge is not
  an estimate of observed native stack use.

- **Private formatter reentry.** The selected formats and fresh default
  instances admit fixed strings, Boolean/integer/g-float conversions, `%a`,
  breaks/flushes and the four valid box annotations. They exclude dynamic
  formats, widths/precision, tabs, tags, Magic_size and mutable output hooks.
  Concrete channel and Buffer callbacks terminate at their selected wrappers
  and services; they do not reenter a formatter. XML outer printing can
  retain an inner attribute/path/argument format, while Pp.print_list calls
  its separator/printer directly rather than adding another format layer.
  Alternatively, sn_decode's `%a%s` can retain print_sn's fixed format.
  Shape/name work does not occur inside an XML printer callback. Thus two
  main formatted invocations, each charged 32 accumulator nodes plus its
  terminator, and two annotation entries support O=68. Native construction,
  queue, parser and output loops do not accumulate another recursion family.
  H=4 ordinary instances and J=64 adapter instances cover their selected
  helper/application layers. The resulting `2392*4 + 176*64 + 32*68 = 23008`
  is one bound for all simultaneous selected F instances in a save, not a
  bound that silently assumes a single root invocation.

- **Interfaces and interruption.** Every S import is supplied by the frozen
  T/G/F inventories. Conversely, S owns all 24 F printer callbacks and
  Shape.check. Shared List, Buffer and adapter symbols are charged by their
  separate invocation contexts, so an imported symbol does not erase a
  caller-owned occurrence. The reviewed private-printer contract supplies
  valid reused tables and finite abandoned resize prefixes; bucket and
  candidate scans do not add a stack frame per visited element. Exceptions
  unwind discarded frames, and returning to an accepted suffix does not
  retain them. Runtime-mediated nested saves use the same global r/e budgets.
  Each owned body's native reservation, return slot and conservative sum of
  trap pushes remains charged. Source-selected call closure and byte matching
  remain conditional correspondence evidence, not a compiler-refinement proof.

- **Composition and residual.** The join replaces the old incomplete
  projections with `P=S+T+G+F`, once per active save. Opening completes before
  subsequent Shape descent; task selection and goal computations are
  sequential, while F already covers its own selected reentry. G includes X,
  and F includes constant conversion and name decoding. Direct bridge
  high-water remains 4,104 bytes per save; the 816-byte dispatch-to-save shell
  has the 32-byte saving handler, not the setter's distinct trapped phase.
  The global `r<=3` and `e<=2` do not renew at a helper, retry or nested save.
  Independent arithmetic/identity inspection confirmed all five rows of
  `r*(P+4104)+e*816`: 669,854,112 / 578,604,216 / 243,973,488 /
  140,185,608 / 146,103,264 bytes at `(3,2)`. These remain selected save-phase
  projections. A_pre, runtime/GC/libc/OS service interiors R, setter/exit,
  global-formatter, diagnostic and other non-save phases remain outside them.
  The private F environment must not be extended to global standard/error
  formatters merely because they share native symbols.

Each new provider checker ran **once**:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-save-binder-formatter-stack-20261020/check.py
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-save-serializer-stack-20261020/check.py
```

The binder/formatter check passed 210 retained bodies / 51,430 instruction
bytes, with 97 binder and 121 formatter closure bodies. Its tool wall time
was 2.470256234 seconds. That checker regenerates its outputs unconditionally;
Git status and diff were empty afterward, so the regenerated tracked artifacts
matched the freeze exactly. The serializer check ran in comparison mode and
passed five cases, 47 source excerpts, 220 bodies / 35,960 instruction bytes,
61 application sites and 87 indirect sites. It reported 2.864876676998392
seconds. Neither provider was replayed after the composition-only fast-forward.
A separate short read-only calculation checked the three provider-result
hashes, all five S/T/G/F inputs and sums, r/e constants and null/false complete
capacity fields in save-stack-join.json.

The results close the selected save-entry caller component under its named
premises. They leave complete-save stack/capacity null/false and make no
resource-limit comparison, current-grammar generalization or admission claim.
No native target execution, capture, new disassembly, source fetch, solver,
predecessor-checker replay or duplicate successful provider check occurred.
No GitHub or CLI memory write was made. The child harness goal was null; no
goal status changed.
