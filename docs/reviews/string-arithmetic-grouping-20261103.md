# Bounded String arithmetic grouping review

**PASS for the seven-site repair.** No blocking finding or further known source
repair remains before the complete validation checkpoints. This is a bounded
repair review, not completed feature assurance.

Reviewed `119cfa0c73389d461f8e5bd6de465ed2fee7d368` against
`58b0d6ce2babb4bb817df89ffd4392c815d4ff06`. Exactly four governed files changed;
source, proof and scripts were clean. Selected reviewer: GPT-6 Astra / Extra
High; runtime settings independently unconfirmed. Read-only review ran
2026-11-03 23:41:44–23:45:15 UTC, 211 seconds. Token/cost measurements were
unavailable. No edits, validation jobs or cache copies were performed.

## Arithmetic and semantic correspondence

The seven pairs make the existing left-associated arithmetic explicit.
Endpoint differences and increments fit the pinned native `Scalars.Wide` range,
including extreme 32-bit endpoints. Concatenation lengths are bounded by 4,096
and operand counts by 64; the grouped intermediate sums fit `Wide`. The existing
indexed-expression guard requires the operand sum below 64 before adding one.
Grouping introduces no conversion or weaker range check.

The model adds exactly seven identity `Expr.group` wrappers. The three scratch
baseline definitions exactly reproduce the reviewed prior bodies. Their
whole-body evaluation equalities quantify over arbitrary `Calls` and `Locals`,
without additional premises, and pass by `rfl`. All three rendered-body checks
match current native-body tokens. Admission rules, contracts, domains,
interfaces, generator and proof policy are unchanged.

Independent tokenization confirms both complete old/new pins match native
source: 49,304 to 49,318 tokens, only seven opening and seven closing parentheses.
Other pin contents are unchanged. All 93 changed certificate data lines match
their actual source chunks, character lists or tokens. No proof structure
changed.

## Evidence inspected

The [native packet](../evidence/bounded-string-characters-20261031/validation/parenthesis-scopes/summary.json)
contains four successful canonical scopes: 69 checks, comprising 58 proof and
11 flow checks, with no reassociation diagnostics. All retained Why3 goal nodes
are proved; all 48 indexed archive members match their hashes. The matching
build `20261103T233404-d80bccc33dbc` and all ten affected tests in
`20261103T233411-962e761487e2` passed. Setup failures remain recorded separately.

The [model packet](../evidence/bounded-string-characters-20261031/validation/parenthesis-model/index.json)
records focused run `20261103T232749-c3db83b33386`, which freshly audited
14,821 declarations in 121 modules at 4 GiB. All 121 dependency sources,
722 compiled artifacts, 1,206 adjacent metadata files and both tools independently
match the evidence and integration. Registry duration was 595.741 seconds;
runner elapsed time was 597.257 seconds. Unrestricted equivalence and rendering
diagnostics passed fresh audits. Their initial failed rendering attempt remains
failed in the packet.

Reviewed SHA-256 identities:

| File | SHA-256 |
| --- | --- |
| `proof/Silver/ComposeStringNative.lean` | `1b8c1d932eb496d6c75bc04a4be37b62c605dd946ee41ed5a1076576fe7315f4` |
| `proof/Silver/OutputBodyCertificate.lean` | `41caa18ac3460581962fd44cf36547f0ecc2cae4b5511a039bb9a2c1c22a39fe` |
| `proof/Silver/ReviewedOutputShape.lean` | `b483c104df7a18f6aa3abe48547ed29d0d491903da4efc66bf4aeccf662b577c` |
| `src/silver_output_profile.adb` | `4a02223317f89de2653d89ac152ae9e66fb089a0cfa20cd3ecb4c8765d90c485` |

Sorted compact JSON path/hash mapping SHA-256:
`2b6708165412203028889cea14f4dc6590b34c27e1191987fb0381e4d219181c`.

Complete native proof/audit, whole-project Lean/source correspondence and final
regression accounting remain mandatory on these repaired inputs. Earlier
accepted reviews remain unchanged. PR #307 must remain open for the owner.
