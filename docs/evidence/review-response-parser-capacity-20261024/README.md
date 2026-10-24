# Independent response-parser capacity review packet

Review of exact author `6fa482f6266d60256300849adf0a657d1df521bc`, including
the #188 merged stdout/stderr repair to original freeze
`e87701a25b2c1a953c9313a4f0e35505c6ba57a7`. See the
[review report](../../reviews/review-response-parser-capacity-20261024.md)
for the source argument, #187 disposition, conditions and scope.

- `author-freeze.json` pins the complete 12-file author contribution and both
  commits. Git history is an explicit reproduction input.
- `check.py` performs a new focused source/transfer audit. It checks the 49
  complete source members, author source ranges, 27 provider pins, merged-file
  transport and nine repaired ranges, independent byte arithmetic, selected
  capacity discontinuities and global allowance preservation.
- `result.json` and `check-attempt-1.log` retain the first and only frozen
  execution: pass, 374 checks, 1.611748152 seconds, Linux x86_64/kernel 7.0.14.
  The `--origins` run also compared all24 GNATCOLL members against the complete
  candidate ZIP and 25 runtime-source files against their recorded installed
  origins. Those are source checks; executable correspondence is not inferred.
- `round.json` records selected model/effort, available timing and material
  findings. Runtime setting confirmation and token/cost measurements are absent.

On the original host, reproduce the full recorded audit with:

```sh
python3 docs/evidence/review-response-parser-capacity-20261024/check.py --origins
```

This additionally reads `/tmp/silver-producer-auxiliary-20261018/gnatcoll-source.zip`
and the 25 source origins named in the author's source manifest. The ZIP must
have SHA-256 `945ec0ba0af2f33361ed80de7aabafa6aa8f4d4a6149896e70f2fb1c6c2ef676`.
Omitting `--origins` checks the retained immutable packet/source/provider bytes
without claiming a fresh comparison with those host paths. A rerun overwrites
only this review packet's result; preserve the recorded result before rerunning.

No compiler, prover, native target, disassembler, source fetch, capture, author
checker or predecessor checker runs. The original stdout-only file result is
superseded, not silently accepted. #186's interface ends at Read_File return
or existing failure propagation; the later collector and complete #119 remain
separate, as do production #88–#94. No admission or aggregate RAM gate is added.
