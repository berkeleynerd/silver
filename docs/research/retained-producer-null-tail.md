# Null-family producer metadata and report

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119),
Linux x86_64. This narrows the
[zero-backend result](retained-producer-zero-check-sources.md) to the initial
null token class, with its permitted case spellings, whitespace and comments.
It supplies the third symbol-pool and final `.spark` shape/serialization join.
It does not complete frontend/flow working-storage, native compilation or
the downstream report-consumer account. No native or proof tool ran.

## The domain is a token class

The 15 tokens are those in `Silver_Profile.Required_Tokens`: `procedure Main
is pragma SPARK_Mode (On); begin null; end Main;`. Between them, and before
and after them, the only additions are the recognizer's ASCII whitespace and
line comments. Word boundaries and case-insensitive recognition remain as
specified by `Token_At`; a comment cannot swallow a required later token.

The recognizer's current 4096-byte limit is still in force. For capacity
research, apply the same token/trivia predicate independently of that limit,
and retain the source-buffer, source-position, line and column conditions
from the frontend analysis. This defines a candidate family, not an admission
change. The native analysis uses the same declaration-free token class.

Trivia and spelling do not introduce an Ada declaration, expression, contract,
call, handler or executable statement. The GNAT token/tree correspondence
already used by the [Main semantic analysis](retained-main-semantics.md)
therefore preserves every branch exclusion in the zero-backend argument.
Source locations, checksums, line maps and filename data can change; their
representations remain charged separately. In particular, source comments
can affect GNAT's license classification and are not asserted to be invisible
to every native consumer.

The Silver null recognizer is tried first. Every currently admitted member of
this token class selects `Output_Mode=False`, a Main-only project, zero
registered Why3 checks, no `.gnat-json` serialization and no `gnatwhy3`
process. The same producer selection holds for the candidate family if the
source-size implementation is updated without changing those dispatch rules.
There is no Why3 startup context or solver representation to charge on this
path. The native Why tree is still constructed before the launch guard;
the [existing composition](retained-producer-composition.md) pays that work.
Its generic JSON byte envelope is not a file produced on this path.

## Main is the only reported entity

`Get_SPARK_JSON` visits the marked entity list but emits a row only for an
analyzed subprogram/package or an analyzed type needing a type check
(`spark_definition.adb:2308–2391`). Imported predefined entities fail
`Analysis_Requested`; this source has no declared type or nested entity.
The only row is therefore Main with status `all`. Main has no instantiation
chain, and `Entity_To_Subp_Assumption` creates one location component
(`spark_util.adb:1917–1951`). Its name is four ASCII bytes; let `P` bound the
actual source filename bytes, and keep the frontend's positive line/column
domains. Their decimal images need at most ten digits each.

There are no skip annotations or Assume pragmas. The two skip arrays and
`pragma_assume` array are empty. `Generate_Assumptions` calls its registration
helper only for generated calls of an analyzed entity; Main's call set is
empty (`gnat2why-driver.adb:1087–1115`). Thus no claim has a call assumption.
Successful flow may establish `Claim_Effects`. Proof registration can establish
`Claim_AoRTE`, but no `Claim_Post` because Main has no postcondition
(`gnat2why-assumptions.adb:171–197`). Use the conservative upper bound of
**two claims, both about Main, each with an empty assumption set**.

Do not infer that both claims are emitted. In these sources the helper which
marks empty VC sets proved is called from `Parse_Why3_Results`
(`gnat2why-error_messages.adb:1273`), and the null path does not call that parser.
The two-claim bound deliberately covers the larger possible metadata shape;
it is not an observed report inventory or an extra proof claim.

## No flow or proof messages on the selected successful path

Null and ignored-pragma flow handling introduces only auxiliary/null vertices.
The source null vertex uses `Make_Aux_Vertex_Attributes`, whose variable and
call sets and original-program-node flag remain empty/False
(`flow-control_flow_graph.adb:4381–4408,5710–5769`;
`flow-control_flow_graph-utility.adb:277–287`; `flow_types.ads:803–857`).
There are no formals, globals, owned variables, expressions, branches, loops,
exceptions, contracts, access handlers or subprogram calls. The synthetic null
export is not a source variable. The selected analysis dispatch is
`flow.adb:1708–1784`; its message families specialize as follows:

| Message family | Null exclusion |
| --- | --- |
| Sanity, initialization, imports/exports, Depends/Global and object-use checks | No source object, variable read/write, explicit data contract or formal exists; the generated global sets are empty. |
| Ineffective statements | The no-effects branch returns after `Warn_On_Subprogram_With_No_Effect`; that helper suppresses the warning for `FA.Is_Main` (`flow-analysis.adb:337–366,1831–1835`). |
| Stable conditions, dead source code | No condition or original program-node vertex is present. Null uses the auxiliary constructor, not a basic source-statement constructor (`:2068–2100`). |
| Termination | `Get_Termination_Condition(Main)` is Unspecified: Main is a procedure with no annotation or enclosing annotated package. Implicit termination applies to functions, packages and annotated lemmas, not this procedure (`spark_util-subprograms.adb:786–859,938–942`). The positive flow message requires `(Static, True)` (`flow-analysis.adb:6460,6712–6721`). |
| Ghost, volatile, protected/task and constant-after-elaboration checks | Main has none of these attributes, objects or calls; call/variable loops have empty domains. |
| Aliasing, Old-prefix and precondition-expression checks | No actual, formal, attribute or precondition expression exists. |
| Generated-global presentation | The selected invocation does not enable `Flow_Show_GG` or debug output. Its optional JSON object is a separate `Flow_GGs`, not a new source proof check. |

`warn_error` is also an array (`errout_wrapper.ads:129`), not a Boolean.
The selected successful marking/analysis path has no wrapper warning/error;
the required SPARK_Mode pragma is present and no unsupported construct or
annotation exists. No static or dynamic VC is registered for this source. There is no response
to parse, no static-result message, and no unused user Annotate pragma to
warn about. Consequently the successful selected path has empty `flow` and
`proof` arrays. These exclusions are a source specialization, not a claim
that arbitrary frontend errors or environmental failures produce an empty
report. Such failures cannot be accepted as success.

## Third symbol pool and timings

The complete `Entity_To_Subp_Assumption` call frontier is retained by the
[offline evidence](../evidence/retained-producer-null-tail-20261018/README.md).
On this path its calls are bounded as follows:

| Caller | Calls |
| --- | ---: |
| `Get_SPARK_JSON` | 1 |
| Main VC-generation timing | 1 |
| `Claim_To_Token` for established claims | at most 2 |
| Skip, Assume, flow/proof message and response timing callers | 0 |
| Sum | at most 4 |

Each request calls `Mk_Base_Sloc` once and `Mk_Subp` once, each doing one Find
in `Assumption_Types.Symbol_Table`. There is no allocated Null_Subp record:
`Null_Subp` is a null access value. Therefore this process performs at most
**8 nonempty Find calls, interns at most two distinct strings, and hash-conses
one distinct subprogram record**. Repeated requests are charged even though
the returned entity is shared. `To_JSON`, `To_Key` and `Entity_Table` do not
call Find; their deduplicating vector/map has one element. Phase 1 does not
write `.spark`, generate these proof timings or serialize claims.

The driver records seven global timing names in phase 2 and one Main timing
name (`gnat2why-driver.adb:867–1009,565–568`). Its separate global-generation
debug timer is not the driver's `Timing`; no solver response adds timings.
`Timing_History` therefore contains at most two objects with respectively
seven and one Float values (`debug-timing.adb:120–137`). Null_Subp is rendered
as the literal key `global`, not entered in the entity table. Timing values
come from Ada Duration and are converted through Float to Long_Float; on this
host 32 characters conservatively cover each finite numeric image. This is
a representation bound, not a proof-time or runtime budget. The existing
environmental clock assumptions still apply to measuring elapsed Duration.

## Final serialized report

`Create_JSON_File` constructs 12 root fields and invokes the pretty writer
once (`gnat2why-driver.adb:351–383`). The checker builds the maximal two-claim
schema directly from the source constructors, and follows the writer's
punctuation, indentation and newline rules (`gnatcoll-json.adb:727–879`).
It charges ten digits for each source coordinate, 32 for each timing number,
and `2+6P` for the quoted filename. Six encoded bytes per input byte covers
the utility's ASCII escapes, invalid-byte replacement and UTF-8 surrogate
escapes (`gnatcoll-json-utility.adb:87–146`). All other strings are fixed ASCII
or the four-byte Main spelling.

The returned String has **`B_string <= 1246 + 6P` bytes**. Closing the Text_IO
file terminates its last line, adding one LF on Linux
(`a-textio.adb:168–184,2048–2059`; default page length is zero). Hence the
actual report has **`B_spark <= 1247 + 6P` bytes**: 2579 bytes at `P=222`, or
2783 at `P=256`. Text_IO's bulk String Put does not reset its column on
embedded LF; its column is bounded by `B_string+1`, which also fits these
descriptor examples. The maximal schema has 41 value occurrences,
12 objects, 10 arrays, 37 object fields and depth 5; each object has at most
12 fields and each array at most two elements. The source coordinates account
for two of the twelve numeric leaves; eight are timings and two are entity
references. [result.json](../evidence/retained-producer-null-tail-20261018/result.json)
retains these counts and the complete caller frontier.
This is an actual final-report envelope, independent of source trivia length
once its coordinates fit. Every array/object, serializing recursion depth,
source-location list and entity/claim container is separately small. These
counts also give the schema/size inputs for downstream `.spark` readers.
They do not by themselves bound all aliases of a refcounted JSON value or
all flow algorithm working data, so those caller/storage joins remain explicit.

No new aggregate RAM admission gate is inferred. The final contiguous String,
its backing-growth arithmetic, each individual path/string, each typed counter
and each container capacity require their own representability conditions.
The null family is a focused whole-pipeline composition test; closing it alone
would not close #119 for output, integer, branch or loop programs.

A focused independent source review confirmed the caller/schema and zero-flow
exclusions and found the closing LF omission in the first byte calculation.
The String and emitted-file bounds above include that correction. The review
ran no native tool and did not establish the still-open storage/orchestration
joins.
