# Independent review of the selected literal invocation join

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accepted within its stated design-time scope; no material finding.** The
selected four-job native graph binds the actual Main compilation to GAS,
direct binding, binder compilation and the no-plugin link. It selects a fixed
Silver source/object/ALI bundle and excludes a fixed-child regeneration job.
This accepts the invocation and fixed-input join, not whole-pipeline capacity
or a production implementation.

The frozen review target is
`f3bc1d023b0459c78c1fb70a33ffb93b8b9fa6ba`, on
`research/119-literal-invocation-join`. The independent review checkout was
`/tmp/silver-review-literal-invocation-f3bc1d023b`, branched from that exact
commit. Review ownership was limited to this report and its narrow probe
output; the candidate and predecessor packets were not edited.

Selected reviewer: **GPT-6 Astra, Extra High**, as assigned by the lead.
Runtime confirmation of the model/effort and token/cost measurements were
unavailable. The recorded review interval was 22:59:06–23:01:31 UTC, about
2 minutes 25 seconds through completion of source inspection and the probe;
report preparation followed. This is reviewer wall time, not a whole-team or
native-tool measurement. The live harness goal returned no active goal for
this bounded review; authority came from the lead's explicit #119 brief.

## Inputs and governing requirements

The complete changed-file target comprises
[the source argument](../research/retained-literal-invocation-join.md) and
`docs/evidence/retained-literal-invocation-join-20261018/`:
`README.md`, `compose.py`, `check.py`, `inputs.json`, `sources.json`,
`result.json`, `checks.json` and `round.json`. The frozen commit identifies
their exact bytes. `inputs.json` identifies 37 predecessor/repository inputs;
`sources.json` identifies 16 complete retained GCC/GPR source files.

I read `AGENTS.md`, the Oracle, the relevant pre-1.0 and review-bookkeeping
sections of `development.md`, and the consolidated trusted-computing-base
table in `docs/trusted-boundary.md`. The controlling duties are automatic
source-derived assurance, the same admitted/proved/compiled source, explicit
configuration assumptions, universal composition arguments rather than sample
success, actual implementation correspondence, and unchanged Bronze/Silver
verification of Silver-owned code. The review introduces no Oracle amendment,
new tool or admission rule.

The source argument's dependencies were checked against the retained null
launch/path argument, indexed assembler invocation, fixed-link-input argument,
output-link delta, literal binder ALI census, binder split-option transfer,
and accepted checksum-lifetime review. I inspected the complete new callable
and focused-check script, the emitted result, retained argv/environment and
object/source/ALI records, and the relevant retained source for:

- Ada GCC spec expansion and `asm_options`/`invoke_as`, including the target
  `--64` selector;
- mapping triplets and object-path-file lookup;
- the direct binder's ALI read, dependency walk, consistency/error handling,
  elaboration order and output generation;
- `Gen_Versions`, timestamp/checksum consistency handling, and collect2's
  no-LTO parsing, argument removal and single-link early return.

The GCC source revision remains
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, GPR remains
`bdfb879cf03643ec8e48a09ce07b08c4a6ff0263`, and the link argument retains
its existing Binutils source/installed-behavior premise. This review does not
turn those premises into a historical binary-build attestation.

## Critical conclusions

1. **The job set excludes regeneration.** Both GCC compile commands have one
   source operand. The first compiles the supplied Main; the second compiles
   the binder body with its companion spec. The direct `gnatbind` path reads
   Main's actual output ALI, reads the selected closure, checks consistency,
   computes elaboration order and generates output. Its unsuccessful
   consistency branch does not invoke a compiler. Neither GPRbuild nor
   Gprbind is launched. The no-plugin/no-LTO collect2 path launches one linker
   and exits before generated-C compilation or relinking. Importing source
   declarations is not a hidden compilation job. Missing fixed inputs cause
   the configuration check to fail; there is no rebuild fallback in this graph.

2. **The fixed bundle has the necessary source and metadata join.** The
   current three Silver source byte strings equal the indexed and literal
   captures. The selected objects equal the reviewed indexed and all four
   options-workspace copies. The two closure ALIs equal the literal-proposed
   ALIs, with Silver D timestamps `20261018061955`; the indexed ALIs instead
   say `20261018085527`. The packet correctly does not identify those ALI
   bytes. Its materialization contract assigns the selected closure timestamps
   to the copied source bytes. The 82-file fixed closure has 163 coherent
   dependency records, and the 80 runtime ALIs are checked against installed
   bytes. Main's newly generated ALI is the consumer edge, not a captured
   replacement. The runtime source/ALI coherence premise and successful
   materialization contract remain necessary alongside these checks.

3. **The binder interface is a family.** The fixed W/Z closure and elaboration
   read projection preserve the generated semantic body. `Gen_Versions`
   takes the Main U/version field from the actual ALI and emits an eight-digit
   `Version_32` initializer. `binder_source_from_ali` witnesses that transfer;
   it is explicitly not a validator for arbitrary ALIs or a replacement
   binder. Same-width object-path substitutions and the shorter installed
   runtime spelling affect trailing comments only. The spec remains 19,920
   bytes and the exhibited body is 10,316, below the retained 10,343.
   The accepted checksum proof covers every uint32 value, including zero and
   cache-sensitive values, with the retained split-option projection. The
   exposed family has no generated-object hash equality. Its bound of
   5,167,732 rounded GGC bytes, 56,378 events and 262,144 bytes per largest
   rounded request retains the checksum proof's conditional scope.

4. **Executable routing and link lookup agree.** The Main GAS vector is
   `AS --64 -o main~1.o ASSEMBLY`; its nine-byte NUL-inclusive object spelling
   matches the accepted assembler transfer. The actual raw relocated AS and
   ld paths are retained, including `bin/../`, rather than shortened for the
   path calculation. Both raw paths occupy 193 bytes including NUL and resolve
   to the expected installed tools. The direct fixed objects follow Main and
   binder before libgnat in all link vectors. Both local `-L` operands are
   rebound, the literal `$ORIGIN` bytes are preserved, and collect2/ld have
   47/46 positions respectively. The fresh-directory inventory supplies no
   candidate for any of the 24 early local library probes. The 15 selected
   fixed-file paths and resolved paths match the retained inventory.

5. **The decision remains source/configuration based.** `build` recognizes
   the supplied bytes and recalculates emission/link interfaces from those
   bytes. Its environments are complete selected environments, not additions
   to arbitrary inherited state. Fixed input identities, path widths,
   timestamps and directory contents are configuration requirements. No
   compiler, program or prover success is used to decide this graph. Files
   must remain stable from checking through materialization and use; coherent
   filesystem behavior, selected tool/source correspondence and sufficient
   external services/resources remain the documented premises. The Python
   callable is research evidence under the existing evidence-script trust
   boundary, not verified Silver runtime code.

## Verification and integration limits

The existing **135 focused checks** passed in **0.781134 seconds** on the
candidate's exact inputs. I reused that result and inspected what the checks
assert; I did not repeat the full suite. A
[narrow independent probe](review-literal-invocation-f3bc1d023b-probe.json)
on Linux x86-64 took **0.737653 seconds**. It rechecked the 109 installed
configuration identities through `Context`, reproduced the retained Hello
result exactly, compared raw/resolved frontend and AS identities and the
selected ld hash, checked the four executable path extents, all 15 resolved
fixed-link paths and 24 local early-search exclusions, and independently read
the two different Silver ALI timestamp families. The probe also records the
current collect2 identity; that observation is not a new build-attestation
claim. No source timestamp or installed file was changed.

There were **zero native compiler, assembler, binder, linker, build, proof or
solver executions**, no full-suite run and no macOS validation. No GitHub or
production changes were made. The successful probes corroborate the retained
source argument and configuration, not a universal proof by examples.

Aggregate integration must use the same actual Main bytes and bind its native
paths to these roles, retaining every emission, object/storage, linker and
other component guard conjunctively. It may close the selected design
invocation/input residual while retaining `production_launcher_adopted=False`.
This does not close complete materializing-parent storage, the producer/proof
launch graph, remaining native capacity obligations, or a different graph
which regenerates fixed Silver children. In particular, native object reuse
does not waive fixed-library verification. Production adoption remains the
separate #88–#94 work; absence of that adoption is not itself a missing source
argument for the explicitly selected fixed-bundle design configuration.
