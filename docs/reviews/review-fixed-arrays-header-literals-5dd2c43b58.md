# Complete-header literal repair review

2026-10-27. Independent reviewer selected GPT-6 Astra / Extra High;
runtime-confirmed settings and token/cost measurements unavailable. Read-only
review of the four-line `ComposeSourceCandidate.lean` patch in
`tmp/fixed-arrays-core-proof`, based on
`726465447c11d8826164fdca343d71178dc53fdf`. The original candidate is byte-equal
at integration references `899a15a5a0` and `fb36`. No native, Lean, build or test
execution, repository edits, subagents or GitHub writes were performed. Only
this scratch report was written. First recorded clock sample was 14:30:28 UTC
after initial reads; report completed 2026-10-27 14:32:09 UTC. These times do not measure the
whole inspection. The earlier regression conclusion for `899a15a5a0` is unchanged.

No blocking semantic or downstream-interface finding. The repair preserves the
complete header conditions; successful kernel validation and complete assurance
remain required before claiming delivery.

The exact four replacements are lines 447/488 (`expression_at`, 214 tokens
each), 675 (`array_values_model`, 231) and 679 (`array_values_at`, 265).
I independently compared the old expected strings with the literal lists using
ASCII-space splitting; every token and its order matches. Replacing only those
four expected-token expressions makes each old line identical to its new line.
All other candidate bytes are unchanged. This comparison did not invoke the
project generator or use its token-equivalence result as an oracle.

I read `expectedTokens`, `Source.lexLine` and the lexer branches. These specific
old strings contain single-space-separated lowercase ASCII words/digits,
recognized two-character operators, and single punctuation. They contain no
string literals, comments, character literals, forbidden characters or fuel
problem. Consequently whitespace splitting agrees with the unchanged Lean
lexer on these strings; the fallback empty list in `expectedTokens` is not
relevant. Both occurrences of the expression header use the identical list.

An independent, bounded token scanner over the actual Ada header slices also
found exactly one semicolon-terminated prototype for each name and matched its
entire tokens to the replacement list. The reviewed output-shape list gives the
same unique headers. Inspection retained:

- Expression parameters/defaults, array metadata domain, cursor conditions,
  complete initialized scan record and Static equality to `Expression_Tail`.
- Both aggregate states' full `Valid_State` conditions, cursor/capacity/count
  relations, successful-result record preservation and all prior-value slots.
- Model `Ghost => Static` and decreasing `Length - Parsed` variant; executable
  Runtime/Static postcondition split, model-result equality and
  `Same_Parser_State` equality.

`functionHeader` still requires exactly one complete header through its
top-level semicolon, preserving nested groups and contracts. No condition is
replaced by a prefix, digest, subset or weaker domain. Literal list data removes
repeated expected-string lexing from these decisions; it does not bypass the
existing `decide +kernel` checks. This review makes no measured memory claim.

Consumer search found the unchanged `ComposeSourceChecks` aliases and actual
checked-source fields. Its `actual_checked` still rewrites through
`Output.SourceBridge.actual_complete_shape` before consuming `candidate_checked`;
`ComposeSourceBridge` still consumes `actual_refinement` and
`actual_array_helpers`. Definitions are extensionally unchanged for every body
token list, and no consumer needs a changed contract or proof assumption. No
lexer, extractor, source pin, native source, generator, runner, axiom or limits
change is part of the patch.

The retained failed run `20261027T113255-5e15169d81f4` reports kernel excessive
memory at `refinement_fact_11` and twice in `candidate_array_helpers`, ending
build with exit 1 and no fresh audit. It remains failed. The diagnostic probe
contains the three literal-header propositions, uses `decide +kernel`, and
imports only SourceDeclarations and ReviewedOutputShape. Its result was not
available to this review. A probe success would establish these isolated checked
header equalities; it would not establish the whole candidate, authoritative
source correspondence or the complete module/axiom checkpoint. The pending
certificate and complete-shape bridge are still mandatory. The independent
Python comparisons above are review evidence, not substitutes for those proofs.

Exact inspected primary inputs (whole-file SHA-256):

| Input | SHA-256 |
| --- | --- |
| Original candidate at base | `9cb5bca89a24913d84e0b85884db360c5593357ae5f72c2d3bd88cec7e5f9626` |
| `proof/Silver/ComposeSourceCandidate.lean` | `5dd2c43b5862451f07023e7e621cfd1757bb76ff205b1f3943ceb3a27ae9bce0` |
| `proof/Silver/SourceDeclarations.lean` | `8fa7137ece364ade168a57abb4532e4f108eb9794f287c8d7bc69e9e12cb4dee` |
| `proof/Silver/SourceLexer.lean` | `6c2824f4ed5b303b3a3f3ec94d8cdb650ffbd86103eef842a32a3c6f3755a8eb` |
| `proof/Silver/ReviewedOutputShape.lean` | `7badab32e1ce4149c8301bd1abb5421782d8b11d3e233ebc92c371b68b07c5f5` |
| `src/silver_output_profile.adb` | `446ac3f3e668096e5cdda361bfa21bbc7dac747ea637659de2cae951d767d794` |
| `proof/Silver/ComposeSourceChecks.lean` | `abb431c4039b406bc8473f43851fe64b6d64f11e89f2ad813731297e69598137` |
| `proof/Silver/ComposeSourceBridge.lean` | `dfe78e84d10e0972b851f05716b5f3585020ff4e31610d7164efa1c52effc181` |
| `proof/Silver/ComposeHeaderLiteralProbe.lean` | `695ce3277e0e2cc32656394a2abdc61fddd071064c2f1224afe6a23afad6c6c9` |

Supporting reviewed artifacts under
`.silver/linux-x86_64/candidate-preparation/header-literal-repair/`:
`candidate.patch` SHA-256
`7d985b6da842ca7de146d1811b6b378320bc30ce8f846dc3a2d6458ba3178c82`,
`token-equivalence.json` SHA-256
`9bc9c3562f92d7e830d052b454581adeeb722d7defa589c328bce1e403259579`.
The retained original matches the base candidate hash above. The failed run's
checkpoint and log supplied diagnostic context, not proof success.
