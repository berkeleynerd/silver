# Proof-report storage and process stack

This record addresses [B1 and L4](reviews/review-343c2f8.md) for the current
4096-byte String language. The application audit buffer holds **16,777,216
bytes of retained report data**. Selected runtime reports retain their
262,144-byte domain. Neither number bounds the original report file: the
streaming reader consumes its complete JSON, replacing only immediate
`check_tree` values in records of the top-level `flow` and `proof` arrays with
`{}`. Every other byte, including whitespace, stays in the audit input. The
original `.spark` file stays unchanged on disk.

The separate null-program recognizer still receives the original report bytes
through `Silver_Platform.Read_File`. Its recognizer retains a 262,144-byte
raw-policy limit, even though the shared read buffer can hold 16,777,216 bytes.
The streaming projection applies to the output-application and runtime policies;
it does not alter the null recognizer's substring-based policy.

The reader validates discarded values too, using the existing byte-oriented
JSON token grammar: string escapes and control bytes are checked, while raw
non-ASCII string bytes rely on the trusted producer's encoding. This does not
add an independent UTF-8 validator. Invalid tokens, premature EOF,
excessive nesting, read/close errors and retained-data overflow prevent build
and publication. Exact unescaped key matching follows the existing auditor;
an escaped spelling such as `check_\u0074ree` is retained. All records,
duplicate members, severity/status fields, suppressed/justified markers,
entity coverage and dependency evidence remain available to the existing
policy. No proof obligation or rejecting diagnostic is removed.

The 64-level JSON nesting bound is the existing auditor's traversal bound.
Current automatic `per_check` reports have a bounded producer structure:
top-level report, section array, record, proof-tree array, primitive goal,
prover map and attempt fields. The normal String length and range schemas
have at most three and two primitive goals, respectively. Failed reports may
add counterexample structures; they do not establish successful proof. The
projection does not turn a previously excessive-depth input into accepted
evidence. A future producer or language change must revisit this bound.

## Why a larger raw buffer was insufficient

The review's dense source has 771 length checks, 63 range checks and 771
unused-assignment advisories. Its retained native reports were just below the
old 2 MiB raw-buffer limit. Several winning prover credits and interrupted
losers can push that construction over the limit. The review's 2,370,822-byte
calculation bounds that construction's described result variants; it is not
a bound for all admitted programs.

Source inspection found a further issue: a successful report may contain an
unsuccessful competing prover's `Unknown` reason. Why3's SMT-LIB driver captures
reason text, and its report writer retains it inside `check_tree`. There is
no format-level fixed bound on that string. All report modes preserve
`check_tree`; changing `--report` does not solve the problem. The projection
therefore removes the dependency on that string's size, rather than assuming
a guessed bound for it. Solver soundness and faithful complete evidence remain
the documented [trusted premises](trusted-boundary.md).

The inspected upstream producer revision is
[`spark2014` fsf-16, `42554fc241fc`](https://github.com/AdaCore/spark2014/tree/42554fc241fcd1fdf08d3a2feccb3f86912acbc0),
whose Why3 submodule is
[`9390baf120ef`](https://github.com/AdaCore/why3/tree/9390baf120ef260547dfa14f08e11c890b203d9c).
The GNAT-FSF 16.1 build recipe selects `fsf-16`. This source inspection is not
a binary-source attestation of the installed release. Relevant definitions are
`gnat_checks.ml` (`check_to_json`, `proof_result_to_json`), `gnat_report.ml`
(`get_msg`, `get_stats`), `call_provers.ml` (`print_prover_answer`),
`smt-libv2.gen`, `errout_wrapper.adb` (`Add_Json_Msg`) and
`flow_error_messages.adb` (`Error_Msg_Proof`, `Fresh_Trace_File`).

## Retained-data envelope

For source length `S <= 4096`, charge:

| Retained component | Count/size allowance |
| --- | --- |
| Main proof records | `floor(S/5) + floor(S/3) + 63`, at 2048 bytes each |
| Main flow records | `2*S`, at 1024 bytes each |
| User-identifier payload in initializer advisories | `2*S` bytes total |
| Entities, coverage, dependencies, timings and fixed report structure | 65,536 bytes |

An assignment needs at least the five bytes of `A:=B;`; declarations consume
more. Independently charging comparisons at three bytes per occurrence
overcounts their two operands and operator. The source-wide concatenation
budget permits at most 63 range-check sites. Parentheses, comments, spelling,
literal contents and whitespace only consume more source capacity. The
independent charges deliberately overcount shared source bytes.

Flow analysis has mutually exclusive unused-assignment, initializer and
ineffective-statement branches at a source vertex, plus the unreachable-code
diagnostic. Path-copy vertices do not multiply unreachable messages, and
messages are deduplicated by source position, message and severity. Output
calls can add four named ghost-output advisories. Charging at most six messages
against the three bytes of `Put`, and two against every other source byte,
gives the loose `2*S` bound. The only accepted advisory with a user-defined
name is initialization; declaration uniqueness and message deduplication bound
its aggregate identifier text by source bytes. The additional `2*S` charge
overcounts that text; legal identifiers require no JSON escaping.

`tests/test_capacity.py` serializes the retained producer record schemas with
32-bit Natural-width positions, entity/message identifiers and trace counters,
all four statistics keys (`CVC5`, `Z3`, `altergo`, `Checker`), the longest
accepted fixed advisory, and all fixed `unproved_status` alternatives. It
charges 64 bytes per statistics time, exceeding the decimal width needed by
the producer's finite Ada `Float` statistics. Tab-expanded columns are charged
at Natural width, not at the four-digit source-length width. A trace filename
is `main__flow__<Natural>.trace`; no absolute path is included. The current
successful-check and accepted-advisory producer paths do not attach secondary
locations, counterexamples, manual-proof commands or source excerpts.

Including record indentation and comma/newline separators, these deliberately
maximal baseline schemas occupy 1318 proof-record bytes and 555 flow-record bytes before
the separately charged initializer name. Their 2048/1024-byte allowances leave
room for the fixed producer formatting. These are bounds on the current
producer's fields, not arbitrary unknown JSON members supplied by a different
producer.

The runtime guard separately charges the longer `silver_arguments.adb` and
`.ads` names and trace prefix, the `VC_LOOP_INVARIANT_PRESERV` rule, the longer
initialization-proof text, and the complete `Always_Terminates` message naming
`First_Or_Default`. Combining these independent maxima occupies 1369 proof and
622 flow bytes, also within the 2048/1024-byte allowances.

The fixed 64 KiB allowance has the following separate cardinality ledger:

| Metadata | Source-derived ceiling | Bytes |
| --- | --- | ---: |
| Entities | 8 entries, each at most 256 bytes including its key | 2,048 |
| Coverage | 5 entries at 32 bytes | 160 |
| Assumptions/dependencies | 10 rules, each with 24 dependency tokens at 96 bytes and 192 bytes of structure | 24,960 |
| Timings | 5 owned entities with 32 keys each, plus 12 global keys, at 160 bytes per entry | 27,520 |
| Remaining outer structure | Fixed allowance | 1,024 |
| **Total** | | **55,712** |

There are no source instantiations in the admitted language or selected runtime,
so each entity has one source location and a fixed package/subprogram name and
filename. A maximal-width entity encoding occupies 229 bytes including its key.
`gnat2why-assumptions` uses sets of `CLAIM_EFFECTS`, `CLAIM_POST` and
`CLAIM_AORTE` tokens. The selected sources give at most ten claims: Arguments
has five AoRTE, four effects and one postcondition claim; IO has seven and Main
two. Each claim can depend on at most three token kinds for eight entities.
The maximal-indentation token and rule-structure encodings occupy 89 and 133
bytes, within the 96/192 allowances.

Timing keys form maps, so repeated phases aggregate rather than adding keys.
The import closure of the three selected prover drivers and both counterexample
drivers contains 24 transformation names (the longest full key has 59 bytes).
Five `gnatwhy3` phases and `vc_generation` give at most 30 keys per entity,
rounded to 32. The global producer has eight literal keys and three debug keys,
rounded to 12. `driver.adb` calls `Do_Generate_VCs` only for entities marked
`Analyzed`; imported entities marked `Not_In_Analyzed_Files` do not add timing
maps. Main has one owned scope, IO three and Arguments five. The GNATCOLL JSON
writer uses `Long_Float'Img`, whose exponential spelling fits the 64-byte numeric
allowance within each 160-byte entry. This is a bound on that spelling, not on
arbitrary fixed-point decimal renderings of binary64 numbers.

The resulting Main bound is:

```text
(4096/5 floor + 4096/3 floor + 63)*2048
  + 2*4096*1024 + 2*4096 + 65536
= 13,064,192 < 16,777,216 bytes.
```

For the selected, unchanged runtime sources, the fixed check-site ledger is:

| Runtime subprogram | Registered check sites | Proof records |
| --- | ---: | ---: |
| Silver_IO.Put | 14, including 2 loop invariants | 16 |
| Silver_IO.Put_Line | 18, including 2 loop invariants | 20 |
| Silver_Arguments.First_Or_Default | 9 | 9 |
| Silver_Arguments.Input_Is_Valid | 1 | 1 |
| Silver_Arguments.Is_Message | 1 | 1 |

`why-gen-expr.adb`'s `New_VC_Labels` registers each static ID. The retained
pre-prover `.gnat-json` inventory has contiguous IDs 0 through 31 for IO and
0 through 10 for Arguments. `gnat_expl.ml` keys a check by `(id, kind)` and
splits each loop invariant into initialization and preservation kinds.
`gnat_report.ml` rejects duplicate keys and serializes that finite map, yielding
36 IO records and 11 Arguments records. The inventory is a registration ledger,
not a bound inferred from the eventual `.spark` totals.

The separate `Emit_Static_Proof_Result` routes do not add records for these
sources: both callers of `Emit_Always_True_Range_Check` are explicitly
floating-point paths; the other routes concern structural loop/subprogram
variants, unchecked unions and unchecked conversions, address overlays, accessibility/resource
checks, empty aggregates or trivially true pragma Check/Assert. None occurs
in the fixed runtime. Loop_Invariant takes the registered VC path above.

The flow ledger has 12 IO records: each of its two procedures contributes
four output-ghost messages, one uninitialized-Status success and one explicit
Global-contract success. Arguments contributes seven: four Always_Terminates
messages and three explicit Global-contract successes. The positive-variable
paths in `flow-analysis.adb` emit at most one message per unique variable and
skip explicit initializers, internal variables and Result. `flow.adb` emits
one success per explicit Global contract; `flow-analysis.adb` emits one per
termination obligation. These sources have no Depends or Initializes contracts.

Applying the same record allowances and 64 KiB fixed component gives 151,552
IO bytes and 95,232 Arguments bytes. Imported interfaces have no proof/flow
records. All fit the retained 262,144-byte runtime domain. These source/producer
shape premises must be reviewed when the runtime changes; retained sample
totals alone do not establish them.

Re-derive the counts and field allowances before admitting a capability that
adds checks per source byte, changes diagnostics, or selects a new runtime.

## For loops and integers extension

The delivered For loops and integers fragment uses the extended envelope
below, with the token-boundary repair described here. The source review in
[the detailed capacity evidence](for-loops-report-capacity.md) extends the
String-language baseline above. It uses the same `spark2014`/Why3 revisions,
the GNAT-FSF `gnatprove-16.1.0-1` recipe at
`0334dd54a2c479faa3dfad47a911373581b11739`, and its selected GCC 16.1.0 frontend
at `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. This is a producer/frontend
source-shape argument, with the same binary/tool trust boundary as the baseline;
it is not a result inferred from passing sample programs.

Add the following independent charges to the baseline:

| Added retained component | Allowance |
| --- | --- |
| Scalar unary/binary arithmetic | 63 proof records at 2048 bytes |
| Integer declaration root conversions | `floor(S/22)` proof records at 2048 bytes |
| Two loop-bound roots | `2*floor(S/18)` proof records at 2048 bytes |
| Image warnings | `2*floor(S/16)` warning records at 1024 bytes |

The lexical work budget charges every `&`, unary/binary `+`/`-`, and `*` against
one shared total of 63. Both `Work_Tail` and `Within_Work_Budget` consume
whole identifiers with `Name_After` before their numeric-token branch. Thus
`N1E+1` contributes a binary `+`; the identifier suffix cannot be rescanned
as the numeral `1E+1`. Genuine numeric exponent signs remain literal syntax,
while signs outside numeric tokens are charged. The producer
registers at most one overflow check per arithmetic operator; its operand
translations target mathematical Integer and add no scalar range checks.
Charging 63 again deliberately overcounts the shared concatenation/arithmetic
budget. In the original constant-only fragment, the shortest Integer declaration
was `A:constant Integer:=0;` (22 bytes);
its initializer has at most one final scalar range check. The shortest loop
prefix is `for I in 0..0 loop` (18 bytes), and the prefixes are disjoint source
spans. The two-record loop allowance is conservative: base-type bounds,
unchecked index initialization/update and assumed implicit invariants introduce
no additional registered checks on the selected path. Body checks occur at
source sites, not once per iteration. Unrolling reuses the already translated
Why program; the selected application command also disables it.

Image warning JSON is appended without deduplication. Each source occurrence
is transformed at most twice: once as an executable initializer and potentially
once more in an immutable declaration's defining axiom. All other admitted
placements translate it once per enclosing traversal. The reviewed frontend
uses light SPARK expansion, rewrites String `/=` without copying either operand,
and skips implicit String subtype-from-expression construction for nonstatic
Image initializers. Generated actions and later identifier uses do not
retranslate those initializers. These routes close the possible extra-warning
paths; the detailed evidence records the functions and exact source lines.
The shortest `Integer'Image(0)` occupies 16 bytes.

The complete fixed Image warning schema, with maximal-width positions and
pretty-print separators, occupies 535 bytes under the test serializer. It has
an empty proof tree and no entity, statistics, trace or user-name payload;
the 1024-byte allowance applies directly without projection. The longest
accepted Main proof rule/message now includes `VC_OVERFLOW_CHECK` and
`overflow check proved`, occupying 1322 bytes under the same serializer and
still below the 2048-byte allowance. The unchanged
flow categories retain the `2*S` charge: loop graphs reuse their bodies,
constant Integer initialization adds no initializer advisory, and ordinary
counted loops add no termination-success report. Intrinsic scalar/Image
operations add no Ada callee, entity scope or metadata cardinality. The selected
runtime envelopes remain unchanged.

The extended Main bound is:

```text
13,064,192
  + (63 + floor(4096/22) + 2*floor(4096/18))*2048
  + 2*floor(4096/16)*1024
= 15,028,224 < 16,777,216 bytes.
```

This leaves 1,748,992 bytes of headroom without changing the buffer.

The original delivered scanner at `b8f1d0b9a8` did not consume identifiers
whole. It could treat a digit-`E` suffix followed by `+` as numeral exponent
syntax and miss a binary operator. The original assertion that every operator
was charged, and therefore the 15,028,224-byte derivation for that scanner,
was not established. The [review disposition](reviews/review-b8f1d0b9a8.md#appended-disposition--2026-10-16)
adds a conservative `floor(4096/6)*2048 = 1,396,736` bytes, giving
16,424,960 bytes and 352,256 bytes of buffer headroom. That retrospective
allowance supports buffer sufficiency without validating the smaller original
bound. The [L1/#51 repair](review-b8f1d0b9a8-repairs.md) restores the shared
63-operator premise through corresponding native and Lean token scans. Its
source certificate, semantic equations and focused regressions are recorded
separately from this original source-review argument.

`tests/test_capacity.py` guarded this extended formula and maximal fixed
record schemas before the bounded-mutable extension below. The formula does not by itself establish automatic proof
discharge. Both original focused capacity tests passed on Linux x86_64 in
managed run `20261016T163411-7b14b45862de`, including the existing dense-source admission
regression. No unchanged compiler or Lean proof was repeated for this
source-review and test-fixture update. Those tests did not detect the later
confirmed token-boundary defect and do not establish the repaired scanner
premise by themselves.

## Bounded mutable Integer extension

The [producer/frontend review](bounded-mutable-report-capacity.md) extends the
same retained-record envelope to the selected bounded mutable Integer grammar.
It keeps the inherited tool premises and record field sizes. The declaration
root allowance changes from `floor(S/22)` to `floor(S/13)` because
`A:Integer:=0;` is now the shortest scalar declaration. Scalar and String
assignments jointly remain in the existing `floor(S/5)` root bucket; each
selected scalar assignment adds at most one final range check. The new static
object-local constraint route adds no constraint-root records.

The frontend creates an explicit generated static subtype, relocating its
constraint without copying the object initializer. The producer adds neither
type VCs, vacuous type claims, coverage, dependencies nor per-type timings for
these subtypes. Therefore generated names do not enlarge the fixed metadata
ledger. Mutable initializer warnings reuse the existing exact advisory policy
and source-bounded name charge; the `2*S` flow allowance still covers the union
of both object kinds. Mutable values in `Integer'Image` do not change its
predefined prefix type or the maximum two source traversals. The detailed
review records the call chains and exclusions, separately from native probes.

The combined Main bound is:

```text
13,064,192
  + (63 + floor(4096/13) + 2*floor(4096/18))*2048
  + 2*floor(4096/16)*1024
= 15,292,416 < 16,777,216 bytes.
```

This leaves **1,484,800 bytes** of headroom; no storage increase is needed.
The runtime envelopes remain unchanged. `tests/test_capacity.py` guards the
combined formula, maximal fixed schemas and a dense 4,096-byte source with
static constrained declarations and mutable assignments. The source-review
bound is separate from complete obligation discharge and actual-source
correspondence. The [original integrated checkpoint](bounded-mutable-integers.md#integrated-validation-and-review)
records their 2026-10-17 validation; the subsequent
[B1/M1 review repairs](review-b79b986403-repairs.md) passed their separate
checkpoint. Those findings do not increase this capacity envelope.

## Storage placement and validation

`Silver_Report_Storage.Bytes` is library-level storage. `Compile` renames it;
the report auditor directly traverses one-based inputs. Its compatibility
rebasing copy lives in a separate helper used only for other lower bounds.
Neither the full report nor a normalization copy stays on the ordinary process
stack while `Run_Application` calls the trusted GNAT spawning code.

Focused Linux x86-64 tests exercise exact retained capacity and one extra byte,
runtime-domain preservation, non-one-based audit callers, a 2,557,622-byte
synthetic dense report with competing prover results, and 17-million-byte
opaque values in Main, Silver_IO and Silver_Arguments. They check original-file
byte equality and rejection of malformed discarded data. The actual driver
forwards 190,000 empty arguments correctly under an explicit 8 MiB stack limit.
External proof/build tools are controlled fixtures in these driver regressions;
they do not replace native SPARK verification or establish universal discharge.

The SPARK argument follows the actual reader observations. `Complete`,
`Model.Refines` and `Model.Matches` connect the complete raw byte sequence,
streaming state, emitted sequence and returned buffer prefix. The composition
theorem derives `Audit_Projection_Observations` from the complete raw sequence:
ordered member/item scans preserve duplicates and keys, retain non-tree content,
and replace precisely the selected tree values with `{}`. The composition
theorem derives the projected scanner endpoints from the complete raw input;
it takes no target-endpoint or acceptance premise.

The representation lemma identifies the emitted sequence with `From_String`
of the actual returned prefix. The policy correspondence layer connects the
uncapped raw policy to the bounded policy on that prefix. Driver contracts save
Main's raw report separately, and runtime contracts save each selected report
before the next read. Successful build and publication require those saved
raw-policy facts as well as the executable audit results and completed reads.

Transition, reader, representation, record/list/root composition, caller and
policy-correspondence checks passed, followed by the complete Linux
[integration checkpoint](review-343c2f8-repairs.md#integrated-checkpoint).
B1 is complete for the currently admitted language. The separate null route
retains its raw reader and recognizer and is outside this structural
correspondence argument.

## Interval-checked integer division extension

The selected [division increment](integer-division.md) extends the retained
Main envelope to **15,421,440 bytes**, within the unchanged 16,777,216-byte
allocation. The [producer source review](integer-division-report-capacity.md)
adds at most 63 division-check records to the existing mutable-Integer formula,
retaining the prior overflow/root/flow/Image/metadata allowances. This is a
feature-local derivation; capability support still requires its complete native
and Lean/source checkpoint. Deferred #119 research remains untouched.
