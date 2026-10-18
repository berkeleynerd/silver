# Independent checksum-transfer review

2026-10-18, #119. Reviewer: GPT-6 Astra, Extra High. Approximately ten
minutes of read-only source, retained-counter and installed-ELF inspection,
followed by this review record. No compiler, prover, Lean, assembler, linker or
native validation run; no repository or candidate-packet edits. Token/cost
measurements were unavailable.

**Accepted within the stated conditional scope. No material finding.** The
candidate justifies, for every uint32 Main checksum in the selected output
binder, cumulative rounded GGC allocation at most **5,167,732 bytes**, at most
**56,378 positive allocation events**, and a largest rounded request at most
**262,144 bytes**. The total is **75,148 bytes below 5 MiB**. The Ada Uint
correction is separately at most one ordinary 16-byte cache wrapper; the
baseline literal's two rows and six stored digits dominate the varying
literal's contribution.

This accepts the checksum extension under the predecessor's fixed
source/options/dependency/path projection and documented relevant-source to
installed-behavior, ABI, allocator and physical-resource assumptions. It does
not establish whole-tool capacity, discharge the Main/link/producer conjunction,
change admission, supply macOS evidence, or prove correspondence for all
historical compiler build inputs. The already reviewed 5 MiB collection
threshold is an accepted premise here.

Reviewed frozen directory:
`/tmp/silver-binder-checksum-closure-20261018/`.

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| derivation.md | 17732 | def401cc2f015d477117f777db938b6cd2ba03f0ec55917a85540d63f38c42a8 |
| check.py | 7522 | 747ea51d83c455d7ec0a3bd41e9ef1ada7121b6eeb62fc9107971bb4e35e2a7a |
| result.json | 1479 | 9390d644e4423182c5ecd339ad1c7ac1503e5173ebd4e375543f7ceb7965e2b3 |
| manifest.json | 8235 | 94dc2b96e07d565744feaa58214340dc1ee62556bd63bce9d9f028734c2ed77b |

The manifest identifies the 31 retained source files and complete counter
inputs. Source commit is `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`;
installed gnat1 SHA-256 is
`5bf9b821ec0388ca6a6962dbc4bcb5773799926445fede6356069357c48dd58e`.
The original checker was replayed with its sole `Path.write_text` intercepted:
the generated result had to equal the frozen result byte for byte. All
identity, counter, finite-prime and arithmetic checks passed; no candidate
file was rewritten. Passing replay was corroboration, not the source proof.

The critical source conclusions were independently checked:

- The literal's semantic paths perform static validity/range comparisons in
  the fixed modular type, with no value-dependent constraint/finalization
  expansion. Gigi translates its initializer once, retains a deferred
  initializer if needed, and uses existing fixed unsigned-32 types. The
  constant folds fit that precision. The allowance of ten constructor
  requests per run and 32 old/new-key misses is conservative.
- Global integer-cache equality includes the type pointer. The only explicit
  non-GC removals in `type_hash_canon` concern min/max constants of the rejected
  candidate type, and cannot remove constants of the already retained
  Version_32 type or its existing main variant. No-GC is discharged by the
  first-collection contradiction, rather than inferred from the witness's
  marker count. Temporary-type deletion and reinsertion do not invalidate the
  finite persistent-key coupling.
- The table lemma uses occupied-or-deleted count, handles tombstone reuse,
  same-size compaction and shrinking, and charges each suffix array except
  the last to subsequent empty-slot insertions before the next expansion.
  Its intervals are disjoint. The finite prime checks justify the factor 33,
  maximum capacity 32,749, and 616,300-byte suffix-array bound. It does not
  assume lookup counts equal miss counts or bound only the immediate changed
  lookups.
- `tree_vec` has a 24-byte header before its elements on the selected ABI:
  251 slots request 2,032 bytes, bounded by the 2,048-byte class. The source
  default share limit is 251. The two-vector allowance and 24-byte one-limb
  integer allowance are valid.
- Zero remains in readonly storage and bypasses numeric RTL emission. Other
  checksums introduce at most one final CONST_INT key. The separate RTL
  integer table has no non-GC deletion; its monotone capacity sequence can
  gain at most one final step. The 65,536-byte array and two 16-byte nodes
  are conservative corrections.
- Scanner prefixes through seven hexadecimal digits remain direct; only the
  last multiplication/addition can append rows. The fourteen exceptional
  final sums 1,073,676,290 through 1,073,676,303 can add one UI_Ints key. That
  table has fixed headers and a 16-byte wrapper. The baseline inserts no
  checksum-dependent key, so later changed cache outcomes can only remove
  allocations and minimum advances. No parser/scanner Uint mark predates and
  encloses the token; subsequent marks are above it. Thus the exceptional
  minimum advance cannot pin additional later scratch rows.

To check the parser/mark assertion and excluded integer-cache callers, I also
consulted the existing complete source corpora, matching inspected files to
the candidate's retained corpus manifests. Ada files were `par*.ad?`,
`scn*.ad?`, `frontend.adb`, `gnat1drv.adb`, `eval_fat.adb`, `exp_dbug.adb`
and `urealp.adb` under
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada/`.
Supplemental GCC files were `fold-const.cc`, `tree.h`, `params.opt`,
`lto/lto-common.cc` and `cp/module.cc` under
`/tmp/silver-backend-compose-20261018/full-source/gcc/`. No compiler was run.

I independently read the installed ELF, checked its full SHA-256 and mapped
virtual addresses through its load segments. All retained binary windows
match: make_int_cst at 0x1694ab0, make_tree_vec at 0x1694b00,
gen_rtx_CONST_INT at 0xedcd80, rtx_alloc at 0x12ea780, and the CONST_INT
size byte at 0x2cdf201. They support the stated allocation layouts under the
same existing behavior-correspondence premise.
