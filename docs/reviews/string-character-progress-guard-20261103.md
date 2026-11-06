# Independent Character progress-guard repair review

**PASS for this bounded repair. No blocking findings.** Complete native
proof/audit, repaired whole-project Lean/source correspondence and final suite
accounting remain required.

Reviewed `58b0d6ce2babb4bb817df89ffd4392c815d4ff06` against
`d3f8e099edfda6153b7aa1a1d16c8fc09804ec53`: the native source, five model
files, reviewed token pin and generated certificate. The selected reviewer was
GPT-6 Astra / Extra High; runtime settings were not independently confirmed.
Read-only review ran 2026-11-03 20:31:22–20:34:24 UTC, 182 seconds. Token/cost
measurements are unavailable. No edits, tests or cache copies were performed.

## Semantic and source review

The guard-equivalence lemma preserves the unchanged admission rule for every
existing `ValidState`. It adds no history, store or accepted-program premise.
The nonprogress case contradicts the unchanged
`model_character_declaration_advances`, whose proof derives progress from model
reading and lexical progress independently of the native postcondition.

The typed body and generic equation both use `following ≤ state.position`.
Their denotation theorem remains unconditional for arbitrary `Calls`, proved
by `rfl`. The concrete model denotation's state-validity premise comes from the
existing `NativeState.valid` and `context.valid`; raw-helper and source-interface
domains remain unchanged.

The native edit changes only `Following = 0` to
`Following <= State.Position`. Independent tokenization matches both complete
reviewed pins, 49,302 and 49,304 tokens respectively. All other pin contents are
unchanged. All 27 changed certificate lines contain the corresponding source,
tokens or reconstruction-character data. The generator and proof policy are
unchanged.

## Evidence checked

- Focused Lean run `20261103T202419-5f35a847709a` passed both helper targets and
  freshly audited 14,821 declarations in 121 modules. All 121 sources match
  integrated lead bytes and captured inputs; the retained workspace matches
  722 artifact hashes and 1,206 adjacent metadata hashes. Its actual import
  closure matches the audit and contains no embedded-source modules. The
  [focused evidence packet](../evidence/bounded-string-characters-20261031/validation/character-progress-equivalence/index.json)
  preserves exact successful evidence and failed development attempts.
- Scoped native run `20261103T200910-01915a66a688` uses the repaired source hash.
  Actual reports show 22 proof checks and two flow checks, all 137 nested Why3
  goal nodes proved, and all 11 postcondition subgoals CVC5 Valid. The maximum
  postcondition subgoal time is 1.673218 seconds; goal nodes are not GNAT
  obligation totals.
- Matching build `20261103T201517-fafe2b35ed13` passed. The actual log for
  `20261103T201554-0768c4b64c4a` records all ten StringCharacter tests passing.

The scoped native packet is retained in the native lane at
`tmp/native-resume-20261103/character-progress-guard-30s/`; its archive SHA-256 is
`8b7da62388d70fb503e2cb886c5a293c63f7b256683c8ba3bd53a4961f8476f4`.
These focused results do not establish complete feature or source assurance.
Earlier failed and interrupted attempts retain their actual outcomes.

## Exact reviewed identities

The first seven paths are under `proof/Silver/`.

| Path | SHA-256 |
| --- | --- |
| `ComposeHelperEquations.lean` | `0c5a866fb5d4a0510c280a5dd906867ec3e5a1bf485976249740010c63c46256` |
| `ComposeModelHelperEquations.lean` | `8e7072f5ad234f64053af710acff122fca8f40b89718f36c26ffc4052ab91d9c` |
| `ComposeStringDenotations.lean` | `54a648b3a19003c8f7581ceb683a230378c386b7fabe81dada829ca93cae5613` |
| `ComposeStringEquations.lean` | `dd687545fe32397555c8a2cdab35a3b408b6ba03934b2205262896d18bb373ed` |
| `ComposeStringNative.lean` | `86c058ed691aab33f07020fc15b6a5ccf4adb12c7c9d95db42f80f08e16f6f6a` |
| `OutputBodyCertificate.lean` | `5d73f0a725a8dda382e2b14bb66cc7a033328d07a21639ab0213fc20365f2311` |
| `ReviewedOutputShape.lean` | `8c1a150ccff5de0f853f569d4213ccbd812c37c82b79f8bc621e8403806869ea` |
| `src/silver_output_profile.adb` | `757d2ae81671cb54839908cd8139cb3fdd0996be4876d2555f592e93c775e95f` |

The eight-path/hash mapping, serialized as sorted compact JSON, has SHA-256
`90d710abe52265d509716766b29d877aac4a94486daaffad456d401117579453`.
