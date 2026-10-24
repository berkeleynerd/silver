# Installed reported-time Start-owner packet

This packet supports the [lifecycle note](../../research/retained-reported-time-native.md)
for #206. The selected pattern is `5c3d` (backslash-equals, Start). Native
inspection rejected the earlier `5c60` candidate: the installed Str dialect
disables its BOS interpretation and treats the backtick as a literal.

The focused check passed after review repair in0.335628 seconds: 15 fixed inputs, 84 whole native
bodies (59 reused from R72, 25 newly retained), 41 instruction witnesses,
four selected dispatch entries, 66 abstract publication states and91 possible
assignments of the one global at-most-two-event allowance to nine owners.
The semantic proof is the accompanying note. The finite model checks its
publication invariant; it neither executes nor emulates a Re implementation.

Exports for o<=9 private Start owners and q searches:

```
owned OCaml allocation/header words <= 640*o + 256*q
```

The fixed credit is128 for parsing/lazy shell plus512 for at-most-once first
force. The steady search credit is256. Maximum single owned block is129 words.
The working bitvector has one bit; hint0, positions length1, mark array length2,
StateTable128 buckets with at most two keys. Packed Hash_set stays None. A
poisoned lazy may rethrow indefinitely; isolation, not guaranteed recovery, is
the result. The shared Str result ref never exposes partial positions or regex
scratch, and the zero-unit caller does not consume it.

This is a **conditional kernel**, not complete #206 adoption. The parent still
owns exact configuration, placeholder `%\(.\)` compilation/substitution,
driver parser and timing-result allocation, reported-time origin, and total
prefix composition. Runtime/callback/backtrace/physical-stack-memory premises
remain explicit. Input-string allocation is not included merely because the
successful match's offset is zero.

Files:

* `check.py` reads retained source/native identities and the installed ELF as
  data, then checks selected bytes, dispatches, arithmetic and the abstract
  publication model. It imports only the existing pure `elf_reader` helper;
  no predecessor checker or evidence producer is replayed.
* `inputs.json` fixes reference sources and providers, selects reused native
  bodies and exact instruction lines. The reference commit is
  `f09672608781dc05172ad980a6e9a483c3b9d534`, not an installed-version claim.
* `native-supplement.json` binds25 new full named bodies and two colorize
  dispatch tables to the unchanged installed ELF. Raw `.txt` files preserve
  objdump output. The separate `new-extraction.json` retains the first anchored
  extraction. New extraction only addressed missing selected joins; R72's
  disassembler/extractor/checker were not rerun.
* `result.json` is the one successful focused result; `round.json` records
  selected settings, limitations, corrections and elapsed evidence.

ELF identity:24,561,432 bytes, SHA256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The original successful Start check at b4c00b1c04 is retained in Git history.
Independent review corrected the detailed offset-chain cost from3 to15 words;
the per-call subtotal is214 and the exported256 credit is unchanged.
The current focused rerun adds those native bodies and witnesses.

No native target, compiler, solver, prover or Re engine ran. No Oracle,
language, production-tool, configuration or GitHub change occurred here.
