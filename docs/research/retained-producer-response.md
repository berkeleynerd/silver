# Retained producer response-schema transfer

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119). This supplies a
conditional transfer from backend goal counts to response shape and bytes,
following [the producer tail](retained-producer-tail.md). It changes no
admission rule or installed configuration and executes no native tool. It does
not close the source-to-goal, backend allocation, diagnostic-string or final
`.spark` joins.

The [source identity](../evidence/retained-producer-response-20261018/identity.json)
and archive retain the selected Why3, GNATCOLL and driver files. SPARK references
use the same complete archive as the producer-tail record. The complete Why3
source search has a retained
[timing callsite inventory](../evidence/retained-producer-response-20261018/timing-callsites.json).
The [offline checker](../evidence/retained-producer-response-20261018/schema_check.py)
checks source identities, the fixed timing-name set and every coefficient in
the affine byte formula. It does not prove the semantic premises below by
running synthetic programs.

## Selected session and success shape

GNATprove's absent `--proof` option selects **Per_Check** and forwards that mode
explicitly (`configuration.adb:2672–2679,3196–3197`). Why3's standalone default
does not override it. The selected strategy is only `split_goal_wp_conj`
(`gnat_checks.ml:283–290`); its resulting leaves are already fully split
(`:346–355`). Registration visits these leaves, finds one check label and
inserts each in that check's top-level set (`gnat_main.ml:50–73`,
`gnat_checks.ml:191–235`). A fresh session, or a session retained solely under
this exact strategy/configuration, therefore reports empty transformation
objects below its registered leaves. Arbitrarily edited or imported sessions
are excluded from this shape argument.

Let `R` count response result records and `G` count the leaf-goal occurrences
in all their reported check trees. `G` must come from the source/VC/split
transfer. It is **not** the number of registered VC IDs: the splitter may
produce multiple leaves per ID. In particular, its local list-length test is
not a global fixed leaf bound. Distinct result keys are `(id, kind)` and
duplicate insertion is forbidden; the 65-kind domain gives only
`R <= 65 * registered_VCs` after label/ID correspondence is established. The
[final-split transfer](retained-producer-splitting.md) proves
`G <= sum L(h_j) <= sum term_occurrences(h_j)` for goals after the first split,
marked unfolding and conversion rewrite. Its preceding source-to-`h_j` join
remains open.

With the three selected real provers and the synthetic Trivial attempt, the
proof-attempt map has at most four entries per leaf: `A <= 4G`. Final statistics
can additionally contain Checker, so their total entry count satisfies
`S <= 5R`. Controlled sessions must not retain attempts from other prover
identities. A proved result has empty counterexamples, no manual-proof fields,
zero extra-info positions and the Unknown unproved-status record
(`gnat_report.ml:59–81`). This follows from the Proved constructor, not from an
assumption about whether an old failed attempt had models. Failed-result and
manual/counterexample paths require their own extension.

## Exact schema accounting

Let `K` be the number of timing fields and `W` the number of warning strings.
Let `L_A`, `L_T` and `L_W` be the sums of **Why3 string bytes**, before JSON
escaping, in attempt answers, timing keys and warnings. The distinction from
decoded UTF-8 bytes matters: Why3 emits each non-ASCII byte as `\u00xx`, which
can occupy two UTF-8 bytes after decoding. Fixed schema keys and kind/prover
names are ASCII. Count an empty warnings array conservatively when absent.

The response constructors in `gnat_report.ml:137–231` and
`gnat_checks.ml:940–979` give these upper bounds. Only the byte-name rows use
maximum name lengths; the structural rows are direct schema counts.

```text
C  = 4 + 6R + S + 3G + A                 containers
V  = C + 9R + 3S + 3A + K + W + 1        values, excluding object keys
F  = 4 + 14R + 4S + 2G + 4A + K          object fields
Ns = 2R + A + W                           string values
Ni = 3R + 2S + A + 1                      integer values
Nf = S + A + K                            floating-point values
Nb = 4R                                  Boolean values
L  = 28 + 139R + 29S + 29G + 22A
       + L_A + L_T + L_W                  key and string-value bytes
```

The kind-name maximum is 35 bytes; selected prover names including Trivial and
Checker have maximum 7. The deepest container path is root object, results
array, result object, check-tree array, goal object, attempts object, attempt
object: depth 7. No nested transformation descendants occur under this premise.

The compact Why3 serializer uses at most six escaped bytes per source string
byte, signed63 integers need at most 20 bytes, and finite double `%f`/`%g`
output needs at most 317 bytes (sign, 309 integer digits, decimal point and six
fractional digits cover the larger form). Brackets cost `2C`; commas cost at
most `V-1`; field quotes/colons cost `3F`. Therefore:

```text
B <= 2C + (V-1) + 3F + 2Ns + 6L + 20Ni + 317Nf + 5Nb
   = 212 + 987R + 549S + 189G + 489A + 321K + 3W
       + 6(L_A + L_T + L_W).
```

This bounds the compact response, not an OCaml allocation total, the persisted
session, GNATCOLL's pretty output or a successful report. Finite numeric values
and successful serializer operations remain premises, not conclusions from
the byte calculation.

## Timing names close; timing values are environmental

The complete Why3 source has five fixed phase names, two transformation-timing
call sites using names selected by the session/driver configuration, and the
fixed `rac_prover` name. The union of the selected 14 driver files contributes
20 transformation names; the Per_Check session adds `split_goal_wp_conj`.
Including `introduce_premises` and `rac_prover` conservatively even when unused
gives **`K <= 27`, `L_T <= 1061`, maximum key length 59**. Driver comments and
imports are accounted for by the checker. With `A <= 4G` and `S <= 5R`:

```text
B <= 15245 + 3732R + 2145G + 3W + 6(L_A + L_W).
```

`gnat_main.ml:319` enables statistics unconditionally. Why3 obtains wall-clock
differences from `Unix.gettimeofday` and accumulates them as float
(`debug.ml:162–174`), so absence of debug mode does not suppress timings.
GNAT2Why reads each backend value as Float, converts it to Duration and sums
it (`gnat2why-error_messages.adb:1143–1164`, `debug-timing.adb:53–57`). It also
subtracts its own Ada.Calendar samples into Duration (`:102–112`).

These values are not bounded by source size. A clock jump can affect the
smallest program. The exact required environment premise is that the observed
clock samples and differences, converted backend timings, and accumulated
per-entity/per-name durations remain finite and within their selected Float
and Duration domains; externally registered timings must also be nonnegative
as the API requires. No finite prover timeout, wall-time cap or source cap is
derived here. The current [trusted boundary](../trusted-boundary.md#trusted-computing-base)
says stable files, sufficient resources and functioning services; it does not
explicitly state this clock/duration interface. Adoption must name it and
define its failure outcome. A timing exception inside GNAT2Why may interrupt
required work and must not be classified as successful or automatically
observation-only.

## Diagnostic bytes and proposed downstream projection

An all-proved result can contain unsuccessful attempts. Their answer strings
are not all `Valid`: the selected SMT driver captures arbitrary reason text,
and Why3 can concatenate adjacent Unknown answers (`call_provers.ml:206–214,
286–300`). Warning sources include the general warning hook, preparation
errors and accumulated escaped output (`gnat_main.ml:104–114,272–280`). No
source/configuration bound for `L_A`, `W` or `L_W` is established here.

A narrow verified #88 response projection can reduce two downstream domains:

- Omit top-level `timings`, which the parser explicitly treats as optional
  (`gnat2why-error_messages.adb:1290–1292`). Retain original timings in the raw
  diagnostic artifact. This removes the backend Float-to-Duration conversion;
  it does not remove GNAT2Why's own Calendar-based timing.
- Canonicalize each check-tree attempt's answer to its **same outcome class**,
  retaining all eight distinctions: Valid, Invalid, Timeout, OutOfMemory,
  StepLimitExceeded, Unknown, Failure and HighFailure. Keep the existing
  formatted names and empty the explanatory suffix for the final three; the
  longest result is then `Step limit exceeded`, 19 bytes. Retain the original
  detail in raw diagnostics. The implementation must prove classification from
  the producer's exact formatting; it may not turn an unrecognized string into
  Valid or discard an error.

GNAT2Why does not interpret those answer strings: it copies `check_tree` into
the report (`gnat2why-error_messages.adb:1260–1263`, `errout_wrapper.adb:140`).
Proof bookkeeping instead uses the result identity and Boolean proof outcome.
The proposed projection preserves those fields, unproved status, every leaf,
prover identity, steps/time, counterexamples, errors, warnings and all other
fields. It must preserve the exact native status and fail closed on unsupported
or ambiguous JSON. An audit still receives the unchanged raw response and the
complete required evidence. Do not discard warnings or replace the check tree
with an empty object at this boundary.

If the projection is implemented and verified, take `K = L_T = 0` and
`L_A <= 19A`. Keeping the absent timing object in the conservative schema count
gives the downstream bound:

```text
B_projected <= 212 + 3732R + 2601G + 3W + 6L_W.
```

This complements the private driver configuration that prevents step-count
parsing. It is **a proposed design**, not an implemented adapter. Why3 creates
and persists the original answers and constructs its response before the
adapter receives it. The projection therefore does not close upstream Why3
string/session capacities, or remove the remaining warning bounds. Fresh
configuration-scoped sessions remain required for the step-parser change;
the adapter must validate every response even on later compatible-session reuse.

## GNATCOLL implementation domains

The retained GNATCOLL source gives useful transfers, with explicit remaining
joins rather than a claim that any JSON of size `B` is safe:

| Representation | Transfer or remaining obligation |
| --- | --- |
| Parser and value-builder stacks | Both start with 32 entries; schema depth 7 plus the parser sentinel uses at most 8. Neither doubling path is reached (`gnatcoll-json.adb:149–164,371–374,576,665–680`). |
| Arrays | Positive-index Ada vectors, each with at most `max(R,G,W)` elements. The previously derived `<= 2^30-1` vector condition covers geometric growth; container element storage is separate. |
| Objects | Ordered maps, at most `max(8,K,5,4)` fields each. Total value/field allocations still use `V`/`F`. |
| JSON integer values | Long_Long_Integer parsing accommodates signed63 producer integers; later Natural field conversions retain their own bounds. |
| File input | `Open(Path)` streams above Integer'Last and uses a 64 KiB initial buffer; smaller files use an ordinary read or mmap. The entire raw response need not fit one String (`gnatcoll-buffer.adb:299–338`). |
| Stream window | If `H` bounds the held encoded token plus lookahead, peak capacity is at most `max(65536, next_power_of_two(2H))`. A doubling occurs only when held bytes exceed half the old capacity; its new read endpoint is at most the new capacity (`:166–199`). Capacity, endpoint increments and signed64 offsets still require their domains. This is a sufficient token transfer, not a bound on `H`. |
| Decoded strings | A producer byte escaped as `\u00xx` can become two UTF-8 bytes. XString uses modular unsigned32 String_Size and evaluates `Current*3/2` before page/even rounding (`gnatcoll-strings_impl.ads:240`, `.adb:43–61`). Require the multiplication and rounding to remain representable; merely fitting the final Ada String is insufficient. Caller-specific capacities are not yet joined. |
| References | JSON strings, arrays and objects use atomic reference counters. Their live alias/temporary multiplicities must be bounded from callers; the number of JSON values alone is not a demonstrated refcount bound. |
| Final serialization | The pretty writer recursively emits a complete Unbounded_String and then a complete String, with indentation `2*depth` (`gnatcoll-json.adb:727–879`). This needs the final `.spark` schema, field strings and container counts, not just the response formula. |

The required next join is a source-derived `G` and diagnostic-byte account,
upstream Why3 representation closure, then successful proof-message/metadata
construction and the complete `.spark` serializer. This component supplies no
whole-#119 completion claim.

Reproduce the offline identity and arithmetic checks:

```sh
python3 docs/evidence/retained-producer-response-20261018/check.py
python3 docs/evidence/retained-producer-response-20261018/schema_check.py
```
