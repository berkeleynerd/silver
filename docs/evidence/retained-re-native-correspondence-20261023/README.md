# Installed Re numerical correspondence packet

This packet supports the [research note](../../research/retained-re-native-correspondence.md)
for #119 / #153. It reads the installed Linux x86-64 `gnatwhy3` ELF as data.
It never executes that program or a Re engine.

The focused check passed once: 109 retained function bodies, eight static data
records, 84 instruction witnesses (50 direct call/jump edges), 24 bodies checked
for absence of local OCaml trap installation, and 21 immutable source/provider
inputs. Its recorded elapsed time is0.376620 seconds. R71's successful census
and source proof are reused without replay. This evidence confirms identities,
selected native operands and arithmetic; the accompanying argument and independent
review establish their intended semantic relation.

The new native Hash_set has eight-byte packed keys, a historical insertion
counter which is **not reset during resize**, and reset-before-reuse scratch
ownership. The conservative arithmetic is:

| Owner | Ceiling |
| --- | ---: |
| Compiler ID allocations | 10,705,984 |
| Hash_set key domain, including epsilon0 | 10,705,985 |
| Historical size per clear epoch | 114,618,125,526,210 |
| Packed table slots | 458,472,502,104,840 |
| Packed backing bytes | 3,667,780,016,838,720 |
| Selected OCaml max_string_length | 144,115,188,075,855,863 |
| Working bitvector | 512 bits /64 bytes |
| Positions / transition / mark arrays | 2048 /257 /8 words |
| Union / individual state-table buckets | 256 /128 |

The packed ceiling is deliberately loose. It proves integer/allocation-operand
representation, not available physical RAM. Physical memory/stack sufficiency
and the existing runtime/callback assumptions remain explicit premises. The
one global e<=2 is never renewed by phase, owner, search or scratch reset.

Files:

* `native.json` records exact ELF identity, symbol address/size/code bytes and
  hashes, named disassemblies and static data. Each `.txt` is a full named body.
  Raw objdump whitespace is retained exactly; authored-file whitespace checks
  exclude those raw `.txt` outputs.
* `inspect.py` extracts only requested named functions using objdump; it skips
  existing identities and records each successful extraction. It is an evidence
  producer, not the check, and was not replayed for validation.
* `inputs.json` fixes the reused R71 providers and exact reference-source files.
  The reference commit is f09672608781dc05172ad980a6e9a483c3b9d534. No installed
  upstream version is inferred from that reference or from ELF symbol names.
* `witnesses.json` gives selected exact instruction bytes, addresses and assembly.
* `check.py` performs the new static check; `result.json` and `run.json` retain
  its successful result and inputs. `round.json` records scope, settings and
  review/rework, with unavailable token/cost information left unavailable.

Target identity: 24,561,432 bytes, SHA256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The recorded per-function disassembler times total16.737371 seconds for104
functions. Five more successful disassemblies preceded a failed guessed symbol
lookup; their original output files were retained and recovered against the
ELF without rerunning objdump. That entire failed batch took1.190197 seconds;
individual times for those five functions are unavailable. The extractor was
fixed to persist each success immediately. The recovery is recorded explicitly
in `native.json`, not silently assigned synthetic timings.

No target, compiler, solver, Re engine, native capture or predecessor checker/model
was run. Static function/data reading does not prove startup, raw-file ownership,
the symbolic canonical-directory guard or the whole #119 capacity objective.
The branch is based on R71 freeze7bea4f8e828d11a4c3ecb554059964902092b41f;
only this new packet and its note belong to this lane.
