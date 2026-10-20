# Standard JSON: prospective byte, event and noncore interfaces

2026-10-20 UTC, Linux x86_64, #119 / #153. Author base
`cd8c3d840fc83ed7f71cf9cbabb04d15a7ebc6e9`.

The five selected continuations have explicit affine **JSON contributions** to
the interrupted standard formatter's B/E inputs. Ordinary reports use the
single-line serializer; abort reports use the boxed serializer. Their budgets
include abandoned prefixes and can coexist. Solver-output, other-warning and
abort-message lengths remain inputs; actual whole-JSON and whole-standard B/E
exports remain null. No resource sufficiency, successful report, complete R/U,
admission or production result follows.

The [focused packet](../evidence/retained-why-standard-json-inputs-20261020/README.md)
imports the accepted [response schema](retained-producer-response.md),
[answer/warning transfer](retained-producer-diagnostic-strings.md),
[all-byte string interface](retained-why-json-byte-escape.md),
[Round 42 entry/core join](../evidence/retained-why-standard-round42-20261020/README.md)
and the exact current input identities. It does not repeat their censuses or
checkers. The selected relevant-source/native/runtime behavior relation remains
conditional; source byte correspondence is not historical binary refinement.

## Exact scope and schema extension

The [reviewed occurrence result](https://github.com/berkeleynerd/silver/blob/63a701e032bd054331613716c7a8ba56fc9c58a3/docs/research/retained-why-diagnostic-occurrences.md),
accepted in review `bfec53b333`, supplies at most **one** normal JSON call and
**two** abort JSON calls per selected process. These count attempted invocations,
including a partial normal report followed by the main handler's abort and the
uncaught handler's abort. They do not renew e<=2, the two signal-save callbacks,
or the three-save allowance. Both serializers have no local recovery/retry;
allocation, conversion or output failure abandons a prefix. Each outer attempt
is charged prospectively before any allocation or output.

The normal source is `gnat_report.ml:220–234`, calling
`Json_base.print_json_single_line`. Its selected record shape is the accepted
Per_Check response with empty descendant transformation objects. The earlier
schema was stated for all-proved results. Its numerical envelope also covers
unsuccessful selected results under the following explicit joins:

- The accepted [model-meta attachment](retained-why-model-meta-control.md) gives
  `get_model=None`; `record_model` returns an empty model list. With the selected
  CE-off fresh session and preserved result ownership, no old model-bearing
  result is introduced. Thus `cntexmps` remains an empty array.
- All selected proof-script fields are None and remain so, under the accepted
  [attempt growth/preservation](retained-why-save-attempt-growth.md) and
  [current state join](retained-why-save-state-join.md). `manual_proof_info`
  tests that field first, so no manual-file or editor-command fields appear.
- `extra_info` still has two Int values, even when their values are nonzero.
  The unproved status is `unknown`, `gave_up` or `limit`, of length at most seven,
  with three Boolean flags. The result Boolean is unchanged in shape. A failed
  result omits stats, which decreases the conservative schema counts. This is
  not an assumption that unsuccessful results are proved or successful reports.
- Stats have at most four prover keys plus Checker per result: S<=5R.
  `add_to_stat` tests membership without a missing-key recovery that invents
  another add; the private table has no signal-save mutator. Its copies and the
  one Checker insertion preserve this bound. A failure can abandon construction.

All joins retain valid key/table and immutable typed-value semantics. Failure
of a needed lookup may prevent JSON construction; these counts do not guarantee
that partially published metadata is successfully serializable.

R counts result records; G counts reported leaf-goal occurrences; A counts
reported attempt binding visits, not distinct prover keys; N bounds answer
analysis invocations under the accepted scheduling/result ownership relation.
The [interrupted preparation](retained-why-path-writer-capacity.md) bound gives
N<=3G+2 when that ownership relation supplies one analysis per prover-call owner.
Use the current state join's conservative A upper, including duplicate bindings;
the historical normal-route A<=4G and N<=3G are not applied.

The accepted fixed-input key bounds give R<=22/18/9/1/1. Their native JSON hashes
are matched to the current capture manifest and model-meta attachment. Current
PIDs, argv, environment and cut identities match the path/backtrace attachments:
17310/17514/17631/17704 before scheduling, and 17869 at the first cvc5 inline
entry after counterexample introductions. The signal save changes attempts and
session metadata, not the registered check-key domain. `register` rejects an
existing check key before insertion; reporting never synthesizes another key.
The R bound is independent of raw forest size, G, proof outcome and completion.
No older PID's mutable state is transplanted into these cuts.

## Ordinary single-line report

Reuse the schema's counts, with K timing fields, W warning strings and L_A/L_T/L_W
the unescaped byte sums for answers, timing keys and warnings:

```text
C  = 4 + 6R + S + 3G + A
V  = C + 9R + 3S + 3A + K + W + 1
F  = 4 + 14R + 4S + 2G + 4A + K
Ns = 2R + A + W
Ni = 3R + 2S + A + 1;  Nf = S + A + K;  Nb = 4R
L  = 28 + 139R + 29S + 29G + 22A + L_A + L_T + L_W
```

C counts containers; V excludes object keys; F counts fields; L includes keys
and string values. Optional missing containers are safely overcounted. The
accepted maximum container depth is seven. No Null value is needed here.

For a concrete tree, the comma count M is its child-edge count minus the number
of nonempty containers, so M<=V-1. There are 2C bracket/brace text operations,
F colon operations, M comma operations, F+Ns quoted string invocations, and
one text operation per scalar. The string interface supplies 6n+2 bytes and
2n+2 events for every byte sequence. Therefore

```text
B_n <= 2C + (V-1) + 3F + 2Ns + 6L + 20Ni + 317Nf + 5Nb
    = 212 + 987R + 549S + 189G + 489A + 321K + 3W
      + 6(L_A+L_T+L_W)
E_n <= 2C + (V-1) + 3F + 2Ns + 2L + Ni + Nf + Nb
    = 81 + 358R + 79S + 73G + 66A + 5K + 3W
      + 2(L_A+L_T+L_W)
```

The serializer performs **no sorting, box opens/closes, breaks, newlines or
flushes**. The report builder separately sorts R results once using their
integer IDs. Its sorting/construction allocations are not silently included in
the formatter budget. The standard exit hook's at-most-two flush events retain
their global owner; they are not multiplied by JSON calls.

`Float` attempt times use bare `%g`; `StandardFloat` stats/timings use bare `%f`.
The former's accepted normal bound is 13 bytes, the latter's is 317; the formula
uses 317 for both. Their fixed No_padding/No_precision routes select the same
conversion branches described by the accepted scalar and timing extensions;
this is an explicit source-format join, not an assumption that every float
format is the timing template. Normal GNU conversions, valid C numeric locale,
valid input representation and returning string/allocation services remain
premises. Negative `vsnprintf` returns are outside the normal result bound.
Under that contract even inf/nan text fits the size bound, but **finite numbers
are separately required to claim valid JSON numeric output**. No finite timing,
duration-domain or successful-service fact is inferred from a timeout setting.

## Diagnostic payload substitution and the five inputs

To retain occurrence multiplicity, let O_A sum the originating solver-output
lengths over reported answer occurrences, and O_P sum output bytes over parser
invocations, including an abandoned parser prefix. Take O>=max(O_A,O_P).
The old unweighted captured-output total can instantiate this O only with its
one-owner/no-duplication join. This packet does not derive that stronger join.
The accepted per-answer and consecutive-warning arguments give

```text
L_A <= 4O_A + 64A
W_c <= O_P + N;  L_c <= 514O_P + 512N.
```

No new regexp, parser or scheduler census is performed. W_o/L_o count all other
warning entries and their bytes **except** the final escape-buffer copy. That
copy contributes D<=1 entry and H<=26619 bytes, from the accepted
[Debug hook](retained-why-debug-hook-capacity.md). A failed earlier hook can
leave a partial buffer which ordinary ending later copies: H is not assumed
zero. Other exception/preparation warning text belongs in W_o/L_o.
The accepted [timing table](retained-why-exit-timing-growth.md) gives K<=26 and
L_T<=1051. Substitution, retaining A separately, gives

```text
B_n <= 14864 + 3732R + 189G + 873A + 3075N
       + 3111O + 3W_o + 6L_o + 3D + 6H
E_n <= 2313 + 753R + 73G + 194A + 1027N
       + 1039O + 3W_o + 2L_o + 3D + 2H.
```

## Boxed abort report and aggregate JSON contribution

`gnat_util.ml:4–9` calls `print_json` on exactly
`error:String`, `internal:Bool`, `results:List[]`, then calls exit. The fixed
keys have 20 bytes. This tree has two containers, three fields, two commas,
four string invocations (three keys and the message), and one Boolean. Its
boxed serializer sorts the one three-field record. It makes five hv1 opens,
five closes and five width-one/offset-zero breaks: one per field and comma.
The empty list still has its bracket pair and box. Neither JSON printer flushes.
For message length x, fixed printable keys use n+2 events/bytes, giving

```text
B_abort <= 42 + 6x
E_abort <= 53 + 2x.
```

Private box-annotation formatters are distinct from the standard root. There
are five helpers per abort, each with the six-byte literal `<hv 1>` and one
final flush: private B=6/E=2. `compute_tag` strips its two delimiters before
parsing the four-byte description `hv 1`. Their allocation, parser and stack owners are
separate below. The standard core sees the five opens, not their private events.

Let X sum the two prospective abort-message lengths (zero for an absent call).
The one normal and two abort budgets add even if each fails after a prefix.
Using D=1/H=26619 and the current inputs gives:

| Case | R | G | A | N | JSON B constant | JSON E constant |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 22 | 64 | 208 | 194 | 1046999 | 316488 |
| Put | 18 | 53 | 173 | 161 | 897962 | 271992 |
| First_Or_Default | 9 | 32 | 108 | 98 | 609935 | 186371 |
| Is_Message | 1 | 3 | 12 | 11 | 223265 | 70257 |
| Input_Is_Valid | 1 | 1 | 9 | 5 | 201818 | 63367 |

Add **3111O+3W_o+6L_o+6X** to each B constant and
**1039O+3W_o+2L_o+2X** to each E constant. These are separate process budgets,
not one string or one shared formatter. The old G<=2981 source estimate and
the 161 raw forest visits are different quantities and are not used here.

## Noncore and native/caller interface

The accepted JSON-string owner contributes
`Q_strings <= 256L+72(F+Ns)` requested OCaml block bytes for the normal report.
After substitution this is

```text
278384 + 75296R + 7568G + 22376A + 131144N
+ 132680O + 72W_o + 256L_o + 72D + 256H.
```

An abort contributes at most `608+256x` for this same owner: the three fixed
ASCII keys cost `3*72+16*20`, plus the message's `72+256x`.
The all-JSON subtotal adds `1216+256X`. These are cumulative direct requests
without reclamation credit; they exclude standard core objects and callers.

For the normal report's **other** fixed format expressions, let
`H_f=2C+F+M+Nf+Nb` and `Z_f=2C+3F+M+Nf+Nb`. Literal delimiters/separators,
`%a:%a`, `%g`, `%f` and `%b` supply these invocation/node counts. Reusing the
accepted ordinary accumulator charges and the float extension gives the
separate subtotal

```text
128H_f + 192Z_f + 16(2C+F+M) + 32Ni + 464Nf.
```

The 16-byte punctuation allowance covers Char_literal temporaries; the integer
result charge covers direct pp_print_int; 464 safely covers either float
conversion (including the eager unused hexadecimal closure). It excludes the
JSON string templates already paid by Q_strings, and does not reuse the old
192-byte scalar result allowance for `%f`. Abort has eight non-string formatted
calls, 33 main nodes and five annotation nodes; its corresponding format and
punctuation subtotal is `128*8+192*38+16*9=8464`. The five private annotation
formatter/Buffer/parser/service owners must still be added, not hidden in it.

As a **reachable final-tree block subset**, `40V+24F+16Nf` safely covers one
small JSON constructor per value, one cons per child edge, one pair per field
and float boxes. It excludes string storage and preexisting shared owners.
It is not cumulative construction: get_results/get_msg folds, list concatenation,
maps, stats copies, result sorting, answer asprintf, warning construction and
temporary closures need their own direct-request account. Abort sorts only its
fixed three keys, but that caller work is still separately owned.

The normal source interface has container depth at most seven; its scalar leaf
can be one value level deeper. It has bounded three-node non-string templates
and the accepted one-byte/string scalar lanes. Abort uses at most six main nodes
per template plus fixed annotations.
These are inputs to a native caller/accumulator instance proof; no whole native
stack number is exported. Recursively nested `%a` callbacks and suspended outer
reports cannot be assigned the isolated string lane's stack bound wholesale.

## Remaining join

The minimal missing numeric inputs for the displayed JSON contribution are
O (with its stated occurrence interpretation), W_o/L_o and X. The separate
exception-text owner may refine these; arbitrary exception strings are not
assumed zero. Numeric/service and valid table/tree premises remain named.
For whole standard output, add the other writer contributions B_other/E_other
and then check the accepted interrupted-core guards with B=B_JSON+B_other,
E=E_JSON+E_other: `L=B+E`, `I=3E+2`, `T=1000000010+L+1`, `S=(3E+1)T`,
`L+79<=1000000010`, `S+L+79<=max_int`, `4I+2<=max_int`.
No guard is declared passed using unknown payloads or a maximal String bound.
The remaining noncore construction, annotation, native stack and runtime
service owners are additional to these input guards. #119/#153 remain open.

Selected author setting: GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements unavailable. The round record retains elapsed times.
Oracle, toolchain pins and admission are unchanged; production is unstarted
and draft #121 remains unmerged.
