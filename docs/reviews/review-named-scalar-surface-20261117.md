# Independent surface and report-capacity review — #392

Reviewed on 2026-11-17, on Linux aarch64. Selected reviewer setting: GPT-6
Astra, Max, as specified by the lead and `AGENTS.md`. Runtime model/effort,
elapsed review time, token usage and cost are not independently exposed to
this reviewer.

## Scope and disposition

**No semantic, sample-faithfulness or report-envelope defect was found in this
bounded slice.** The draft catalogue exporter mismatch was repaired in source;
the bounded test-coverage omissions were repaired in test source. Both repairs
still require their planned executable validation. One stale generated Rosetta
sentence remains for the planned final render. This review does not establish
delivery of #392 or complete compiler/actual-source assurance.

The read-only review covered the language, catalogue, sample, tests, capability
and evidence documents in `tmp/named-arguments-392`, principally:

- Tests at `ac8d6013a9b672f286249c5f7f1b101d3817e27e`.
- Surface and evidence changes at
  `bfab0f0c5d7127364a2da7299e04de2229446456`.
- Catalogue repair `eabd7127ffd3d04f0dfe1f4a9e975e20ec156eb2`.
- Test-coverage repair `fa07b1df4eb29a3fa4eefcd8f1d8f3a07b159563`.
- The uncommitted Named parameters assessment/coverage/render, limited to that
  task and its sample; unrelated generated stage changes were excluded.

The authorization was named, reordered and positional-prefix/named-suffix
arguments for existing scalar functions/procedures, with every formal supplied
once, case-insensitive selectors, no defaults/omissions or new types/effects,
unchanged incoming-state and alias rules, original-source compilation and
existing limits. Applicable Oracle, language, capability, assurance,
trusted-boundary, development and review guidance informed the review. Paths
below are relative to the integration worktree. No proof or test jobs were
started; only this scratch report was written.

## Findings and dispositions

1. **Draft catalogue exporter mismatch — repaired in source; compiled parity
   pending.** At `bfab0f0c5`, `catalogue/silver.json` described named calls while
   `src/silver_catalogue.adb` still excluded named actuals, emitted positional-only
   actual descriptions and omitted selector fields. The resulting executable
   catalogue would disagree with the committed catalogue, which
   `tests/test_silver.py:50` checks directly. This was an incomplete-draft
   integration gap, not a claim about a delivered feature. The exact four-addition,
   four-removal patch in `eabd7127f` synchronizes those descriptions and fields
   (`src/silver_catalogue.adb:1476`, `:1540`). Static comparison found no remaining
   mismatch in that patch. The native author must still establish the complete
   `Export_Constructs` contract and final executable catalogue parity.

2. **Bounded named-call test omissions — repaired in test source; execution
   pending.** The original 15 methods did not exercise a named Boolean-return
   function, named Boolean `in out`, or a named procedure call from another
   procedure. Existing positional coverage did not cover these named
   compositions. No failing behavior was demonstrated. The single complete-route
   fixture in `fa07b1df4`, `tests/test_named_scalar_arguments.py:55`, now exercises
   all three: `Both` returns Boolean through named and mixed calls, `Wrap` calls
   the earlier `Flip` with reversed named order, and Boolean copy-back is observed
   after enabled/disabled/enabled calls. Independent evaluation gives exactly
   `true\ntrue\nfalse\n`. It uses the established complete-route helper. Static
   review found no defect in the addition; its execution is planned after the next
   native rebuild. The retained 15-method success predates this sixteenth method.

3. **Stale generated sample-execution status — final render pending.** The
   original uncommitted assessment and coverage text said sample execution was
   pending despite retained successful run `20261117T030042-d612d38a0399`.
   `rosetta/assessment-named-scalar-arguments-20261117.md` and the Named parameters
   entry in `rosetta/coverage.json:43937` now record that successful focused run
   while keeping complete feature assurance pending. The generated
   `rosetta/n/named-parameters/silver.md:3` still says sample execution is pending.
   The lead has scheduled its rerender at final promotion. This is a draft
   consistency issue; the task remains intentionally absent from `supported`.

Final inspected uncommitted draft SHA256 values:

| File | SHA256 |
| --- | --- |
| `rosetta/assessment-named-scalar-arguments-20261117.md` | `1f6f2d78e6ae88620f798b15c401d6f428db4c3efec06967f932607761718c05` |
| `rosetta/coverage.json` | `0a85764333c49e990c02f8e0aa2d3b02483697f069bc5f7cf8922bad657af211` |
| `rosetta/n/named-parameters/silver.md` | `d1c8da5b0f21bfe6cf040c50e00970283df5c8754452347e767f09fdd92b2606` |
| `rosetta/assess.js` | `65ab4942f4f4f5c150a20bc44d3723adceecada2fe23f179a41db2195e669c47` |

## Language, sample and retained behavioral evidence

The language introduction identifies this extension as under implementation and
validation. The shared association rules at `language.md:673` describe the
authorized forms, exact formal coverage, contiguous `=>`, case folding,
selector-label/payload distinction and unchanged state/alias requirements.
The catalogue JSON agrees, and the repaired exporter now agrees in source.
Capability/assurance/trusted-boundary documents retain pending final native and
actual-source assurance rather than presenting the focused evidence as delivery.

`samples/rosetta_named_parameters.adb` faithfully exercises cached Rosetta task
revision 411871: a function's formal names bind independently of written order.
Defaults and omissions are optional in that task. Its noncommutative `Subtract`
function makes a binding error observable. All 40,401 pairs from
`Small = -100 .. 100` produce results in `Difference = -200 .. 200`; the four
outputs independently follow, including Integer Image spacing:

```text
Positional: 2
Named, reordered: 2
Mixed: 2
Reversed values:-2
```

The original 2026-10-15 assessment attribution is preserved, with separate
2026-11-17 review metadata. No unrelated task was reassessed in this review.

The retained behavior packet records all 15 original named methods passing in
32.099 seconds under run `20261117T025819-c85791b031d5`. Inspection of
`check_full_route` confirmed membership, fresh application proof/build, unchanged
source checks, complete five-unit report audit and exact stdout/stderr/status
checks. Cases cover noncommutative reorder, mixed types, selector/caller-name
collisions, both Integer in-out containment directions, alias exclusions,
qualified validity and nested payload reads, same-state negative controls,
branches/loops, unreachable checks and more than 100 reversed formals at the
4096-byte boundary, with 4097 bytes rejected. These are meaningful behavioral
checks, not universal assurance.

The three inspected test files matched their retained gzip snapshots before the
later Boolean fixture was added. Both retained sample source copies matched
SHA256 `ffd7f4cdb7b34b838bf1e291f012cff2901ab9e437647a3b8e2784fd868d92b4`.
The sample's exact stdout matched the derivation above. All six report-file
lengths and hashes matched `behavior/sample/summary.json`; the retained audit
reports five units, 20 flow checks, 51 proof checks, one function termination
witness and only existing advisories. The behavior native source snapshot matched
`ab1327dbb71d67448518ff965642c157062e3e12378ccb80f9911f3159297ba0`;
the sample summary identifies compiler SHA256
`f7df4eafa214b58bb583f05053c7f6646920136959868d0d0c0332ba2320034e`.
Those hashes identify the retained inputs and executable, not the final combined
source after subsequent native changes.

## Unchanged report-capacity argument

No defect was found in the named-argument extension to
`docs/scalar-procedures-report-capacity.md`. Every actual still reserves its
distinct outer `(` or `,` and at least one payload-token byte. A selector and
arrow add bytes without replacing those reserved bytes. No defaults or omitted
actuals are admitted, so declaration/call lower bounds remain unchanged. The
existing charges therefore continue to bound calls by `floor(4096/5) = 819`,
writable actuals by `floor(4096/2) = 2048`, and formals by
`floor(4096/7) = 585`. The retained-report envelope remains **49,279,744 bytes**,
against **67,108,864 bytes** allocated, with **17,829,120 bytes** of headroom.

I read and independently hash-verified the new producer raw/archive files in
`docs/evidence/named-scalar-arguments-392-20261117/producer`. Relevant paths:

- GCC baseline `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`:
  `sem_util.ads:1046–1056` specifies declaration-order payload expressions;
  `sem_util.adb:9648–9664` enters the named chain, `:22555–22569` visits each
  formal/actual pair once, and `:25685–25737` switches from the positional prefix
  to the declaration-order named chain.
- SPARK `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`:
  `spark_atree.ads:662–663` renames that iterator. The retained producer
  `gnat2why-expr.adb:4818`, `:4871` consumes it through `Compute_Param`; its SHA256
  is `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14`.
  `flow-control_flow_graph.adb:7021–7057` uses the same iterator with one output
  vertex per writable actual; its SHA256 is
  `d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7`.

These routes do not evaluate selector labels or create additional payload/output
vertices, so naming does not introduce a new report multiplicity through them.
This argument retains the existing producer and source-to-tool-binary premises;
it does not independently attest the installed external toolchain.

## Limits and remaining integration work

This is a retained-report capacity conclusion, not a bound on solver time,
process stack or peak memory. The new executable `Mark_Formal` copy/stack behavior
was outside this review and awaits the native author's final validation.
The retained compiler build was incremental and used caches; fresh application
workspaces, cached compiler/Lean dependencies and an independent clean rebuild
are distinct claims. No independent test/prover rerun was performed here.

Final native helper contracts and executable parity, source correspondence,
complete integrated native/Lean assurance, the new Boolean fixture, complete
regressions, final supported mapping/render and delivery-document consistency
remain integration work. The documented external-tool/completion, restricted
Ada-to-Lean interpretation and local Lean-cache assumptions remain applicable.
None of the reviewed sample successes or unchanged capacity calculations waives
those obligations or establishes completion of #392.
