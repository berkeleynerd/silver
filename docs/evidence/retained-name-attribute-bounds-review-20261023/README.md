# Joint name and attribute review evidence

The [review report](../../reviews/review-name-attribute-bounds-20261023.md)
accepts the conditional selected-name/Hsattr results and seven-owner join for
#119 / #153 at these exact targets:

- Hsattr: `62f686fe7331c2faf74c3c9f66df93f2626f1fa0`.
- Root mapping/source: `badd4304991e055d957d0965d004e3d207ecc8fa`.
- Raw-name attachment: `39afb9db41c4052a7b68c2663f2bcc72d72a27ac`.

M1 identified the missing combined-startup minor credit in the initial Hsattr
attachment. The repaired provider/values still fit B=2^28; Q and all owner
transfers remain unchanged. The report records the source argument and limits.

`targets.json` lists 32 exact target paths. `audit.py` independently checks those
bytes, 88 retained providers, complete source identities/ranges, attribute and
raw-name origins, and arithmetic joins. It follows original captured fields
without importing the author extractor. `audit-result.json` retains hashes,
range line counts, five-case results and measured elapsed time. `round.json`
records selected settings, unavailable runtime confirmation and disposition.

The one final audit passed in 21.877214313 seconds:

```sh
python3 -B docs/evidence/retained-name-attribute-bounds-review-20261023/audit.py
```

Only this review directory is written. No author/predecessor checker or model,
native target, compiler, solver, proof, capture or disassembly replay occurs.
Identical successful repetition is unnecessary without changed inputs or an
unresolved concern. Finite extraction/arithmetic is not a source simulation
proof. Whole-process/printer capacity, successful naming semantics and the
complete #119 rule remain open.
