# Retained Why3 fixed-session atoms and attributes

Date: 2026-10-20. Tracking: #119, #153. This is a finite input projection for the
separate functional shape-buffer and identifier-request bounds. The Oracle,
language, tools and admission policy are unchanged.

The [packet](../evidence/retained-why-fixed-session-atoms-20261020/README.md)
reads exactly five retained session-block members, covers all saved certificate
formula roots and deferred-substitution values with typed term/pattern traversal,
and adds every proposition's identifier. It preserves names and attribute strings
as bytes/hex, integer literal kinds, immediate versus heap representation, exact
integer values and used-limb/bit/decimal bounds. Typed coverage and numeric
coverage succeed for all five forests; there are no missing-layout diagnostics.

| Forest | Stored terms | Identifiers | Integer objects | Max name bytes | Max decimal bytes | Shape attr union count / bytes | J per save |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 22,477 | 5,721 | 279 | 40 | 20 | 195 / 4,102 | 15,925 |
| Put | 17,790 | 4,520 | 272 | 40 | 20 | 171 / 3,394 | 13,230 |
| First_Or_Default | 7,744 | 1,795 | 44 | 60 | 4 | 193 / 3,470 | 2,541 |
| Is_Message | 1,337 | 332 | 9 | 28 | 4 | 42 / 679 | 220 |
| Input_Is_Valid | 1,545 | 371 | 10 | 47 | 4 | 44 / 700 | 315 |

Each forest has only integer constants: no real/string constants, patterns or
Tcase nodes. Consequently its `max_case_pattern_occurrences` is zero. The
extractor nevertheless handles and preserves all typed constant/pattern layouts,
including the full recursive structural pattern-occurrence sum over each Tcase's
branches. The zero result describes these stored forests.

`saved_occurrence_certificate` copies every task/proposition/goal formula, APn
visit and detachment flag, per-formula opened term/binder count and aggregate B.
It is checked for exact equality with the previously accepted certificate. The
new extraction does not rederive these counts. For a single save of a forest,
`J = sum(len(task.propositions) + 1)` over its non-detached APn visits. The extra
one is the goal explanation request. Summing one save per forest gives 32,231
requests over 161 APn visits; repeated save invocation multiplicity belongs to
the separate continuation argument. The APn domain differs from scheduler
registered-task envelope 153.

## Integer layout and bounds

Put_Line and Put each have three heap integer components; their remaining
components are immediate OCaml integers. The heap values are 2^62, 2^63 and 2^64.
The largest uses two 64-bit limbs. Each of these forests ranges from -1 through
2^64, with maximum decimal output length 20 bytes including any sign. The other
three forests use immediate values between zero and 4,096, with maximum decimal
output length four bytes.

Retained OCaml `mlvalues.h:365–366` identifies custom tag 255 and data at payload
word one. Retained Zarith `caml_z.c:116–175` gives the same-word-size limb
assumption, the high sign bit/remaining size bits, and the used limbs after that
header. Thus the raw custom payload is an operations pointer, sign/size word,
then used 64-bit little-endian limbs. Allocation can have unused words beyond
the used limbs; they are retained rather than included in the numeric value.
The extractor validates tag, payload size, used-limb bounds and nonzero top limb.
It exports the complete raw payload, operations pointer, limbs, unused words,
sign, exact value and the coarse bounds `bit_length <= 64 * used_limbs` and
`decimal_bytes <= 64 * used_limbs + 1`.

`BigInt.to_string` delegates through `Big_int_Z.string_of_big_int` to
`Z.to_string = format "%d"`. Under the accepted faithful numeric and ordinary
allocation contracts, `caml_z.c:989–1086` uses at most `5 + 64 * used_limbs`
native buffer bytes and `8 * used_limbs` limb-copy bytes here. Their maxima are
133/16 bytes in Put_Line and Put and 69/8 in the other three forests. These are
reached argument bounds, not proofs of GMP or allocator internals. The source
revisions and full file hashes are pinned in the packet. Existing
[source-family correspondence limits](../evidence/retained-why-native-effect-completeness-20261019/source-family.json)
remain in force: this does not infer historical source identity from a version
string or matching data layout.

## Attributes and explanations

The typed projection decodes term `t_attrs` and identifier `id_attrs` as the
retained `MakeMSH`/`MakeOfMap` unit-map set layout, with exact attribute-string
bytes and attribute IDs/tags. Every task has its goal identifier recorded; each
goal identifier has one attribute of 15 bytes. A stored term has at most eight
attributes. Maximum byte sums per stored term are 223, 214, 231, 190 and 183,
respectively in the table's order.

Those individual-node maxima are insufficient for opened nodes:
`term.ml:654–659` copies attributes by set union. The packet therefore exports
the union of all reachable term attributes, including deferred substitutions,
plus all proposition identifier attributes, with its IDs, count and total byte
length. The union sizes in the table are conservative inputs to the separate
opening/explanation argument. Attributes from other reachable identifiers are
also preserved but do not inflate that specifically named union.

`termcode.ml:20` initializes `expl_prefixes` with both `expl:` and `infer:`;
the mutable option can add prefixes. This extraction does not establish the
actual configured list. Its actual count stays unknown, allowing the separate
proof to parameterize direct explanation dictionary entries by that count. This
uncertainty does not alter the imported J arithmetic.

## Validation and limits

The checker validates frozen input/output hashes, source excerpt correspondence,
direct identifier/integer/attribute bytes and memberships, complete certificate
copies and count arithmetic. It does not repeat logical opening or term-edge
coverage traversal. Independent review must inspect the new typed traversal and
its pinned imported `Atoms` class. The new projection preserves all applicable
diagnostics; unsupported records would make the corresponding complete flag
false rather than silently narrowing the domain.

Four forests are pre-scheduling registration cuts. Input_Is_Valid reuses its
accepted earlier first cvc5 inline-entry forest at the established logical-forest
preservation scope, and compares its term atoms with the prior accepted atom
certificate. It does not assert equal registration counters, addresses or
auxiliary state across phases. No native process, capture, session replay,
binder/alpha replay, prover, public evaluator or source fetch ran for this work.
This packet does not establish whole-ending capacity or future deterministic
graph closure. The remaining functional bounds and continuation evidence are
owned by their separate workstreams.

Selected extraction settings were GPT-6.1 Sol / Extra High; runtime confirmation
and token/cost measurements were unavailable. Five final extraction timings sum
to 4.583121386 seconds on Linux x86_64. An initial 1.466295833-second Put_Line
projection retained three unsupported heap numeric components; a targeted
follow-up used already-retained Zarith source and closed those diagnostics. The
final byte-correspondence result is retained in `check-result.json`. Independent
review is pending integration; no independent review outcome is claimed here.
