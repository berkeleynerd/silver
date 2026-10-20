# Independent review: prospective standard JSON inputs

2026-10-20 UTC; research #119 / #153.

**Accepted under the named selected source/native/runtime, ownership and
normal numeric-service premises. No material repair is required.** The packet
provides conditional prospective JSON contributions and partial noncore
interfaces. It does not establish actual complete JSON/standard B/E, complete
allocation or native stack, successful reporting, or physical sufficiency.

## Exact target and review record

- Author freeze: `d87bc345d35b506a3cedf48d4dc73d769a92bc91`, on author base
  `cd8c3d840fc83ed7f71cf9cbabb04d15a7ebc6e9`.
- Reviewed the [research argument](../research/retained-why-standard-json-inputs.md)
  and all eight files in the [packet](../evidence/retained-why-standard-json-inputs-20261020/README.md):
  README, check.py, transfer.py, inputs.json, source-witnesses.json, transfer.json,
  result.json and round.json. The [input manifest](../evidence/retained-why-standard-json-inputs-20261020/inputs.json)
  pins the 45 local inputs and three late-provider records.
- Late occurrence author `63a701e032bd054331613716c7a8ba56fc9c58a3` and accepted
  review `bfec53b3332485407867d4be2f3317fc1bffdb6c` were read through their local
  Git objects. Their integration at `c947f496ad` does not change the author
  freeze reviewed here. Accepted response, byte-escape, diagnostic-string,
  scalar/timing, attempt-preservation and standard-core results were reused
  only at their stated scopes; no predecessor checker was replayed.
- Read AGENTS.md, the Oracle, review bookkeeping, agent reporting guidance and
  relevant assurance/trusted-boundary sections. The lead supplied the current
  authorization and milestone boundary: retained-tool research and isolated
  commits are authorized; production #88–#94 remain unstarted and PR #121
  remains draft/unmerged. Only this review report is owned and committed.
- Review worktree: `tmp/review-standard-json-inputs`, branch
  `review/standard-json-inputs-20261020`, created directly at the author freeze.
  No recursive reviewer, native worker or GitHub write was used. Live harness
  goal lookup returned null; no goal was changed.
- Selected reviewer setting: **GPT-6 Astra / Extra High**. Runtime-confirmed
  model/effort and token/cost telemetry are unavailable; no lead setting change
  is claimed. The measured review interval is recorded below.

## Findings and accepted interface

**The unsuccessful-result extension has the required source joins.**
`gnat_main.ml:213–266` constructs Not_Proved with models, manual information,
extra information and unproved status. The accepted all-None get_model domain,
fresh CE-off session and preserved result ownership keep the model list empty:
`record_model` starts with an empty accumulator and only its Some arm prepends
a model. The retained all-None proof-script invariant makes
`manual_proof_info` return None before filename/editor construction. These are
necessary restrictions, rather than consequences of the old all-proved schema.

The unsuccessful record retains two Int extra-info fields, a Boolean result,
three Boolean limit flags and one of `unknown`, `gave_up`, `limit` (at most
seven bytes). Its stats field is absent. Thus the old successful schema is a
numerical upper envelope for these selected unsuccessful records, with no
new Null, model, filename or editor field. Failures while building such a
record may prevent serialization; successful construction is not inferred.

The S<=5R argument survives duplicate attempt bindings. `add_to_stat` tests
membership before insertion and does not recover a failed lookup by inserting
again. The stats table is private to the extraction, its copy adds each
binding once, and `get_stats` adds Checker once per result during the single
normal construction. The signal-save callback is not a stats-table mutator.
This uses the valid dictionary/typed-value premise; it does not prove arbitrary
partially corrupted tables serializable.

**The five domains and interruption counts remain separate.** The fixed-key
R bounds 22/18/9/1/1 are joined by native-input hashes to PIDs
17310/17514/17631/17704/17869 and the current capture/cut records. The last cut
is the first cvc5 inline entry after introductions; it is not replaced by a
registration cut. `register` rejects an existing check key and signal saves
do not add check keys. This preserves the valid HCheck dictionary premise and
does not require R<=G. The supplied independent fixed-key reconciliation and
the packet's byte/identity checks are reused without a fresh key census.

G=64/53/32/3/1, A=208/173/108/12/9 and N=194/161/98/11/5 have distinct roles:
reported leaf occurrences, attempt binding visits and bounded analysis owners.
The last is 3G+2 under the accepted ownership relation. Historical A<=4G,
N<=3G, raw forest visits and older source-level G estimates are not substituted.
All-None scripts and the empty descendant-transformation shape retain their
accepted continuation premises.

O>=max(O_A,O_P) is essential. O_A weights solver-output lengths by reported
answer occurrences; O_P weights them by parser invocations, including an
abandoned parser prefix. This correctly permits the same underlying output
to be charged more than once. The earlier raw captured-output total alone
does not instantiate this O without the explicitly unproved no-duplication
join. Consecutive-warning bounds therefore compose as
L_A<=4O_A+64A, W_c<=O_P+N and L_c<=514O_P+512N.

**Normal and abort serializer counts agree with the source.**
The normal printer is single-line: no sorting, boxes, breaks, newline or flush.
Sorting R results belongs to its builder. Counting tree edges gives M<=V-1,
with 2C delimiter operations, F colons, M commas, F+Ns quoted strings and
one operation per non-string scalar. The accepted string interface gives
6n+2 bytes and 2n+2 events. Re-expansion gives the displayed normal B/E
coefficients, including 317 per float byte allowance and one event per float.

The abort record has two containers, three fields, two commas, three fixed
keys totalling 20 bytes, a message string and one Boolean. Its five boxes,
five closes and five width-one/offset-zero breaks give
B_abort<=42+6x and E_abort<=53+2x. The five breaks are formatter events;
their eventual spaces/indentation belong to the core transfer. Each box's
private annotation stream receives the **six-byte** literal `<hv 1>`, then
one flush (B=6/E=2); compute_tag strips the delimiters to the four-byte
description. Those private events are not standard-root events.

The accepted occurrence proof supplies one normal and two abort attempts,
including a partial normal output followed by both error roots. Charging
the prospective complete bound before each call covers abandoned prefixes,
even before the first emitted token. None of these serializers catches and
retries itself. The global two signal callbacks, e<=2 and r<=3 allowances
are never renewed per root. The standard exit hook's flush bound retains
its separate global owner.

Direct primitive arithmetic independently reproduces all five aggregate
constants:

| Case | B constant | E constant | JSON-string direct-request constant |
| --- | ---: | ---: | ---: |
| Put_Line | 1046999 | 316488 | 39331144 |
| Put | 897962 | 271992 | 33835800 |
| First_Or_Default | 609935 | 186371 | 23282696 |
| Is_Message | 223265 | 70257 | 8903232 |
| Input_Is_Valid | 201818 | 63367 | 8034104 |

The added symbolic terms are respectively
3111O+3W_o+6L_o+6X, 1039O+3W_o+2L_o+2X and
132680O+72W_o+256L_o+256X. D=1/H=26619 conservatively retains a partial
earlier Debug hook buffer that ending can later copy. Other warning text is
not assumed absent. Exn registry events belong to private formatter owners;
returned abort strings enter JSON through X and other warnings through L_o.
Direct Printf fallback
writes are a separate channel contribution and are not JSON or standard
Format events.

**The noncore interfaces keep their exclusions.**
Normal JSON strings cost at most 256L+72(F+Ns). The abort's printable fixed
keys cost 3*72+16*20 and its message 72+256x, yielding 608+256x.
This replaces the corresponding generic string/scalar charges rather than
duplicating them. The other normal format expressions have
H_f=2C+F+M+Nf+Nb and Z_f=2C+3F+M+Nf+Nb; the punctuation allowance counts
the Char_literal temporaries. Direct integers use their separate 32-byte
result allowance. The 464Nf term is the accepted conversion subtotal,
including the eagerly allocated unused hexadecimal closure; it is not the
older small-scalar allowance.

For abort, the root and empty list have five main nodes each, three bindings
have six each, two comma/break templates have two each, and the Boolean has
one: 33 main nodes in eight calls. Adding five annotation nodes and nine
punctuation temporaries gives 128*8+192*38+16*9=8464. This deliberately
leaves annotation formatter/Buffer/parser/services unclosed. The final-tree
subset 40V+24F+16Nf covers small constructors, child conses, field pairs and
float boxes, but it does not account for cumulative builder temporaries,
sorting, maps, warning construction or answer asprintf.

The maximum container depth is seven; a scalar can occupy value level eight.
That is not a native stack theorem. Nested serializer callbacks and suspended
outer reports prevent wholesale reuse of the isolated byte-string lane's
stack bound. The packet correctly exports no complete caller-stack number.

**Numeric and integration premises remain live.** Bare `%g` and `%f` use
the accepted No_padding/No_precision branches, with conservative normal
output allowance 317. Inf/nan can satisfy the byte bound while failing valid
JSON numeric syntax. Normal returning GNU conversion, valid effective C
numeric locale and represented typed inputs remain premises; a negative
vsnprintf return is excluded by that normal-service lemma. The packet does
not infer finite durations, conversion success or allocation success from
timeouts. Actual payloads, whole-standard writers, core guards and remaining
noncore/runtime/native owners must be joined before exporting actual bounds.

## Verification and disposition

On **Linux 7.0.14 x86_64**, ran the new packet checker exactly once in comparison
mode, without --write: **pass**, five cases, nine source excerpts and three
affine interfaces, **0.100639530 seconds internal elapsed**. It matched all
generated products and local/pinned-Git input identities without changing the
author packet. Host paths were queried using `scripts/dev.py paths`.

Independent review also counted a directly constructed schema tree, including
unknown/gave_up/limit unsuccessful variants, and recomputed each case's B/E
and string subtotal from primitive counts without importing transfer.py. The
tree check is a consistency check, not a universal proof; the source argument
above supplies the structural reasoning. Additional retained-source reading
checked adapt_stats, the empty-model mapping and record_model's None branch.
No target, capture, disassembler, source fetch, solver, proof, broad validation
or predecessor replay ran; target/native execution time was zero.

The measured review interval was **17:02:55–17:07:04 UTC, 249 seconds**, at
one-second resolution, through initial report/link validation and excluding
the final record correction/commit. Task-receipt timing, token usage and cost are
unavailable. Intended result: independently challenge the JSON source scope,
failed-prefix accounting and arithmetic. Achieved result: conditional
acceptance with no author rework requested and the unresolved owners preserved.

Retain all null actual B/E/noncore exports and false completeness flags.
Oracle, tools, pins and admission are unchanged. #119/#153 remain incomplete;
production #88–#94 are unstarted and PR #121 is draft/unmerged. This report
changes no issue, memory or goal state.
