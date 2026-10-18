# Literal source to native Main constructor interface

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This attaches actual selected literal-output source bytes to the accepted
[native constructor vector](retained-native-expansion.md#composed-main-native-constructor-vector)
and its named
[gigi source-visit interface](retained-backend-gigi.md#source-visits-compose-without-an-entity-times-syntax-product).
It supplies finite computable Main counts for subsequent original-gigi analysis.
It does not attach the fixed frontend/configuration terms or complete frontend,
gigi allocation, native process or whole-toolchain capacity. Current admission,
the Oracle, tools, pins and invocation defaults are unchanged.

The [adapter](../evidence/retained-literal-native-frontend-20261018/compose.py)
reuses `source_counts` and `TOKEN` from the complete retained
`derive-literal-output.py` recognizer. The selected source has exactly one
`with Silver_IO;`, the Main/SPARK pragma shell, no declarations and a nonempty
sequence of qualified direct-literal `Put`/`Put_Line` calls or null statements,
with at least one output call. There is no grammar extension. The adapter first
enforces today's printable ASCII plus HT/CR/LF byte alphabet, including comments;
the predecessor's additional VT/FF acceptance is therefore unavailable here.
The full recognizer consumes all bytes and the complete shell. Token projection
then uses that same lexer, skipping trivia and preserving literal tokens for
doubled-quote decoding. Word tokens are counted from actual lexemes, including
keywords and repeated names; interning is charged as an upper allowance.

## Source mapping and constructor sum

Let C be output calls, N null statements, W word tokens, D the sum of decoded
literal bytes, and T the sum of word-token characters. C is at least one.
The fixed shell has eleven words: nine before the statements and two in
`end Main`. Every qualified output statement adds two words and one literal;
every null adds one word. Hence W = 11 + 2C + N. Literal contents, comments and
case do not add words or dots. Put and Put_Line have different character lengths,
so T is computed from the actual lexemes, rather than inferred from C.

The specialization uses the existing
[parser/scanner transfer](retained-value-capacity.md#main-parser-multiplicity)
and `representative_current_programs()` counter projection in the pinned model:

| Input | Specialized upper allowance |
| --- | --- |
| Scanner nodes | 2(W+C) |
| Parser ordinary allocation allowance P | 2(W+C) + C selected-name dots + C call nodes + N nulls + 7 scaffold + 1 with-name |
| Parser node identities | P, already including the promoted Main entity |
| Parser entities | 1 |
| Parser dynamic slots | 9(P+C) + 61 |
| Parser syntax lists | 4+C |
| Scanner Name entries / characters | W / T+W |
| Scanner String descriptors / characters | 2C / 2D |
| Scanner Uint entries / digits | 0 / 0 |

The two-visit scanner allowance covers discarded lookahead under the existing
valid-source parser argument; it is not a claim that every token is scanned
twice. There are no numeric tokens, literal concatenations, parser flattenings,
operators, declarations, assignments, branches, loops, input calls, Image or
other expression forms in this shell. An apparent numeral or operator inside a
literal or comment has no such effect.

The seven scaffold nodes are the compilation unit and auxiliary node, procedure
specification and body, SPARK pragma and its argument association, and handled
sequence. The with clause contributes its one node. The established parser
sites include `par-ch10.adb:216–220,823,920`,
`par-ch6.adb:521,981`, `par-ch2.adb:352,400,634`,
`par-ch11.adb:62`, and `par-ch5.adb:155,1086`; qualified-name/call construction
is covered by `par-ch4.adb:217–940` and `par-ch5.adb:506–692` in the predecessor
argument. The four fixed lists are context items, declarations, statements and
pragma arguments; each call adds its actual list.
The extra C slot-growth allowance is the procedure-call kind change, rather
than a second node identity. The Main defining-name promotion likewise retains
its scanner identity but pays the existing maximum-entity slot allowance.

All remaining `main_example_counts` fields retain the established zero defaults,
except `largest_scalar_tree=1` and `incoming_scope_depth=1`. Source literals,
nonconcat literal resolutions, source calls and output calls are each C.
Each literal has a separate bound descriptor `(low_D,high_D)=(1,1)` from
`native_string_bound_descriptor('literal')`. Thus the existing query join gives
source H=2, effective H=4 and A=19. This represents a safe query envelope;
it does not assert that a literal's decoded length equals a descriptor weight.

`main_native_construct_vector(**counts)` is called unchanged. In this selected
family, its nonzero generated rows simplify to:

| Generated row | Ordinary | Growth | Entities | Lists | Uint appends |
| --- | ---: | ---: | ---: | ---: | ---: |
| Standalone literals | 0 | 0 | C | 0 | 6C |
| Conservative output wrappers | 5C | C | C | 2C | C |
| Source calls and leaves | W+2C | 4C | 0 | W+3C | 0 |

The wrapper row is the existing conservative general transfer. The selected
literal path itself needs no transient scope or secondary-stack cleanup, as
the [literal native source argument](retained-native-expansion.md#native-expansion-composes-without-a-transient-scope)
establishes. Retaining the positive wrapper charge does not assert those
constructors actually occur. No fixed null-process lifetime result is reused.
The sum, including parser allowances, therefore gives:

```text
Main node identities       <= 41 + 19C + 4N
Main entity identities     <= 1 + 2C
Main dynamic slots         <= 430 + 329C + 36N
Main syntax-list headers   <= 15 + 8C + N
Main generated Name entries <= 2C + 2
Main generated name chars  <= 26C + 44
Main Uint appends          <= 7C
```

The executable predecessor also computes retained digit words and each row's
other named outputs. Scanner pools are separate addends, not costs already
included because the scanner-node allowance appears in P. These are component
logical counts, not physical backing or all allocations.

## Named gigi input and separate terms

The unchanged `native_to_gigi_source_interface` receives the concrete Main
constructor result and these counts. Its Main ordinary allowance is
`P + W + 7C = 41 + 17C + 4N`; entity count is `1+2C`, and Integer stores are
zero. The accepted bound/type transfer thus gives the named result:

```text
Main_source_syntax_visit_bound
    = Main_ordinary_allocation_allowance + 32 Main_entity_identities
    = 73 + 81C + 4N.
```

This counts source syntax visits. It is not a count of GENERIC nodes or all
gigi helpers. The existing two-procedure/two-return fixed Main scaffold remains
a conservative predecessor output, separately named. The actual selected
literal path's one body/return is established in the prior source argument.

`separate_fixed_frontend_allowance` contains JSON nulls (`None`) only in its
node/entity fields: accepted conditional fixed constants are available in
`native_fixed_frontend(P)`, but they are not attached by this leaf. Null means
unattached, never zero cost. All Main constructor and Main source-visit fields
are concrete. This packet does not call `native_frontend_logical_join` or pass
`retained_configuration_fixture` as a supplied invocation. Loading the unchanged
model evaluates historical examples internally; those results are not selected
as attachment outputs. The retained fixture and old defaults remain historical.
Actual configuration/map bytes and the indexed invocation delta must be joined
under the selected invocation descriptor in a subsequent integration.

The compiler/source correspondence and selected native phase/type/options
premises of the predecessor remain explicit. Each decoded literal length must
fit native `String_Length` and the selected signed 32-bit Integer
(`length <= INT_MAX`); the adapter reports that local condition. Computed
allowances use mathematical Python integers. Every actual scalar intermediate,
index, table demand and allocation product still needs its own source-derived
width/backing check. The current 4096-byte cap is not promoted to a theorem
about this unbounded offline source family. Semantic library admissibility is
also separate.

Preserve the remaining physical and virtual sources, source/line buffers,
names and table backing, common metadata, invocation/configuration storage,
late frontend heaps and Ada callbacks, annotation roots/incoming annotation
serial, fixed imported gigi type graph, per-kind/helper/folder construction,
and subsequent GCC/object/linker/producer phases. This attachment supplies no
global allocation coefficient and closes none of those obligations implicitly.

## Reproduction and evidence

The [input manifest](../evidence/retained-literal-native-frontend-20261018/inputs.json)
freezes 21 repository inputs at base `789e7ddf4cfb3112b2184433f12dd2c548ef7bfc`.
The existing `compose-null-capacity.py` loader executes the source-checked model
without changing its defaults. It validates 151 selected Ada files at GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` against the retained manifest, and its
existing macro inventory additionally checks 2,319 Ada files. These are source
identity checks, not a native compiler run. The adapter checks the predecessor
manifest before loading and records the actual input source hash and size.

```sh
python3 docs/evidence/retained-literal-native-frontend-20261018/compose.py \
  --source samples/hello_world.adb \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output docs/evidence/retained-literal-native-frontend-20261018/result.json
python3 docs/evidence/retained-literal-native-frontend-20261018/check.py \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output docs/evidence/retained-literal-native-frontend-20261018/check-results.json
```

For callable use, load `compose.py`, call `load_model(ada_root)` once, then
`compose(raw_bytes, model)`. The supplied model must be that checked, unchanged
model. The retained hello source has 118 bytes, C=1, N=0, W=13 and D=13;
its [result](../evidence/retained-literal-native-frontend-20261018/result.json)
has 60 Main node identities, three entities, 759 dynamic slots, 23 syntax
lists, and 154 Main source syntax visits. Its Main projection equals the prior
source-checked hello example; that example's fixed fixture is excluded from
this comparison and attachment.

The [focused checks](../evidence/retained-literal-native-frontend-20261018/check-results.json)
exercise case/comment/trivia equality, CR/LF/CRLF, doubled quotes, empty and
syntax-looking literals, monotone call/null/length growth, 84 finite call/null
combinations, 23 invalid inputs, and a 5,000-call source beyond today's cap.
They exercise the adapter and arithmetic, not universal correspondence. The
source mapping and accepted predecessor arguments supply the latter. No native
compiler, prover, Lean build, debugger, GitHub action or full suite was run.
