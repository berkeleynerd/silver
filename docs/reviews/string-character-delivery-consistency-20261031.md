# String and Character delivery consistency review — 2026-10-31

Reviewed the lead drafts at `5c2238abf63f01f02f4e52a448217831ba60e6b7`.
Two discrepancies were found; no additional mismatch was found in the reviewed
type, bounds, null-slice, leaf/operator or sample-output claims. All four
expected outputs agree with the sample sources.

## D1 — Concatenation catalogue omits slices

**P2; [#305](https://github.com/berkeleynerd/silver/issues/305); correction queued.**
`string_concatenation.conditions.operand_kinds` lists literals, names and Image
but omits `string_slice`. The native exporter repeats the omission. The general
`string_expression` entry includes slices, `string_slice.positions` includes
`concatenation_operand`, and language/native admission permit slice operands.
Both entries must be corrected together after the active captured proof runs
finish, followed by matching native proof/audit/build and catalogue regression.
No admission change is needed.

## D2 — Rosetta entries claim output without a terminator

**P3; corrected in the lead draft.** The three changed task entries included
`put`, which `assess.js` defines as output without a line terminator. All three
drivers call only `Put_Line`. The lead removed `put` from these three surface
arrays; baseline line output needs no additional progression identifier.
Final rendering and regression coverage remain pending.

## Scope and evidence

Static extraction matched 56 constructs, 3 compositions, 12 static rule fields
and 45 static token fields between exporter and JSON. Native output `.ads/.adb`
bytes match `79b350912a`. Prepared/pending wording and absence of the new
identifier from `supported` were accurate at review time; final delivery must
refresh them.

Selected setting: GPT-6.1 Sol / Extra High; runtime identity unconfirmed.
Observed review window: 21:22:12–21:26:42 UTC, 270 seconds. Token/cost measurements
are unavailable. The reviewer made no edits and ran no builds, tests or compiler
commands. This was a delivery-consistency check, not a repeat of the critical
semantic or capacity reviews. The lead transcribed the findings and recorded
D2's subsequent correction.

Exact SHA-256 review inputs, relative to the lead worktree:

```text
41c4dfbf21797c258bdec2754f04e5d9740fd449aeab78d8d987f78a9c50f18b  AGENTS.md
ef1e182ab8eedd8d259f5a7cff49a597e8b7ccfe207bdf11d7456003e0b6603a  oracle.md
7ec789c2c3527a33b8d8aed9c4be6ffeac1246247f17e713140f8c286d84561b  language.md
5ce00eca983a4fd591b95e8cc5727d164d1c636609650b9087b30aa0e0c66f85  catalogue/silver.json
9cc332cb6d42a9406421b122a84729f082cd3ba6437abdfe14d819cc5287f32d  src/silver_catalogue.adb
799959ca7d49229dbe8bd748fc11c109839b3e77d95fdf3210ea422365754d6d  src/silver_output_profile.ads
bcd6d9b3ebb814d13cbf9e9651bf10f5e25102030c9d42d879b022411415ed1b  src/silver_output_profile.adb
15f2b737ff4e29e191583b4ae57ad9f5661fa1322fa6cd113080f201539b79c6  src/silver_profile.ads
0a4173d5e37f7561e21c89e1e15f931728c721b4fb6f8fb3b667c5334798cff4  src/silver_profile.adb
5062e5d3616d7bf3f0df9f544c34a203ca6a32e2acf9e05c0bf9719dfd317e7e  samples/manifest.json
5057bccfd30ec4f68ff4029c06ca1fad9e74de797b63dff640b2b67f82c7a531  samples/rosetta_reverse_a_string.adb
63c73cb9267cc1d96798a74914d8d8d82d0338d97f3c3fca014975d66a46c31f  samples/rosetta_palindrome_detection.adb
56558886a3ddbe5421dd2ee45e1ec342148094e86861722a2c07256b408098c6  samples/rosetta_selective_character_replacement.adb
21673b77b5ed086c6e15a34dbd9089dc8543fa58ba98a97c5c4080ff3cf3bf72  samples/string_character_bounds.adb
f0bd43bc0e1dfc876768461c5957d07928405edcfb6b38ccf18711522b5ef71a  rosetta/assessment-bounded-string-characters-20261031.md
5840d86a2255745f0f8fd83f408eac480567388bb700f1a258750fc024236a91  rosetta/coverage.json
d93951b9734fe594552af9cc6a166da9e7088503e5d2c6c624c0667bd6c8f5b0  rosetta/assess.js
3c2bb34e5df3fb3b4fc101440a510f42b300fd43ed0e4f1c116b9c259fa2caff  rosetta/refresh.py
460505b0a504b6d27b79888f9d4c7ab5f3daa904ec543359a197bfb4392586dc  rosetta/r/reverse-a-string/task.wiki
d02f39c75a8763084362969d5b97d48be0d76f8568afab28399adf0d6436750e  rosetta/p/palindrome-detection/task.wiki
f968d30841bb65421ac719071be072148cd6f97d93fa7a91514c57a93b1ec924  rosetta/s/selectively-replace-multiple-instances-of-a-character-within-a-string/task.wiki
f22b2b41a2f664c62cb59171e9cc4bc73d5938b38d87614320b54f49a0743173  tests/test_samples.py
```
