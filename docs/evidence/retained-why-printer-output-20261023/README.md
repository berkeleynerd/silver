# Selected printer output and Format/Buffer interface

Author packet for #119 / #153, 2026-10-23. **Pending independent review.**
The [source argument](../../research/retained-why-printer-output.md) supplies
per-request text/events, individual Buffer/file bounds, name and annotation
helpers, and a reached shared-stderr diagnostic fragment. Every claim retains
the fixed-input/source-native and first-error premises of its providers.

Exact base: `8b651049e46c8800df92e9efed4832ddfcbad8ab`.
Raw-name provider: `39afb9db41c4052a7b68c2663f2bcc72d72a27ac`.
Hsattr at-free/hyp_name provider: `62f686fe7331c2faf74c3c9f66df93f2626f1fa0`.
Their independent joint review is a separate integration input. This packet
does not certify its own source argument or provider arguments mechanically.

| Process | Largest individual request/file byte bound | Buffer temporary doubling |
| --- | ---: | ---: |
| Put_Line | 96,048,951,340,887,500 | 144,115,188,075,855,872 |
| Put | 78,317,489,650,720,766 | 144,115,188,075,855,872 |
| First_Or_Default | 23,316,870,060,998,624 | 36,028,797,018,963,968 |
| Is_Message | 2,037,762,596,793,055 | 2,251,799,813,685,248 |
| Input_Is_Valid | 2,394,812,689,662,705 | 4,503,599,627,370,496 |

CVC5 supplies each maximum above. All fifteen driver/case compositions satisfy
the arithmetic guards, including `offered≤2^57-9`. The first two temporary
doublings equal `2^57`, nine bytes above that maximum string extent; the
source clamps the eventual allocation after doubling. Requiring that temporary
operand to fit `max_string_length` would impose the wrong condition.

The new drain lemma is restricted: every break must remain under a user box
until flush, or the helper must have no breaks. Driver's enclosing user box
and the producer's final-flush lifecycle establish this restriction for the
selected route. `drain-counterexample.json` preserves the review-discovered
counterexample to a generic fresh-large-stream theorem. The historical
short-stream formatter theorem is unchanged.

Files:

- `project.py`: new driver/source/constant projection from exact Git blobs.
- `inputs.json`, `source-witnesses.json`, `census.json`: frozen identities,
  strict source excerpts and resulting finite census.
- `transfer.py`: callable conditional equations, with each actual owner kept
  separate and no aggregate allocation gate.
- `compose.py`, `result.json`: five cases times three drivers, explicit
  premises and unclosed ownership domains.
- `check.py`, `check-result.json`: focused author integrity, provider-join and
  arithmetic check; it imports only the new local composition/transfer code.
- `round.json`: selected settings, elapsed observations and material rework.

The focused check is:

```
python3 docs/evidence/retained-why-printer-output-20261023/check.py
```

It does not run a compiler, solver, proof, capture, native formatter,
disassembler, predecessor checker or provider checker. Source reasoning still
requires independent review. Native layout/stack, complete private maps,
shared-stderr whole-interval integration, whole-printer and whole-process
capacity remain open. The single global `e≤2`, two save-entering callbacks,
three saves and `E=3N+e` remain unchanged.
