# Two-header capacity recovery — 2026-11-15

This follows the independently reviewed loop proof repair. The exact final
integration inputs are `8a03ab122`, adopted in the existing native-filesystem
worktree on `recovery/procedures-header-capacity-20261115`; tools, prior branches,
evidence and cached proof objects were preserved. Native `src/` and `scripts/`
remain byte-identical. Only two failing header proof bodies and one directly
required expected-token helper change.

The selected targets are `DeclarationHeaderFunctionLocalsModelSpec` (maximum
retained earlier header time, 728 s) and `DeclarationHeaderFunctionBodyAtSpec`
(maximum expected header length, 839 characters; earlier 715 s). Earlier times
were on another host with unbounded process memory, not a current capacity
claim. This focused gate avoids a blind retry of all function-source leaves.

## Baseline failure

The unchanged final-source targets both fail at the 8,192 MiB kernel threshold:
54 s for the body header and 52 s for the locals-model header. The initial run
also rebuilt `ReviewedOutputShape` in 42 s; it did not audit. Build elapsed was
150.398 s. Sampled largest process RSS was 8,392,016 KiB; summed RSS was
9,444,256 KiB; host available memory stayed above 7,461,632 KiB. No host OOM or
monitor guard occurred. Both exact original leaves and the log/resources are
retained. This is a proof memory failure, not permission to omit any contract.

## Selected proof and focused success

The established checked normalization proves the complete expected headers:
834 characters / 156 tokens for `function_locals_model`, and 839 characters /
167 tokens for `function_body_at`. `String.toList_ofList` establishes each exact
candidate character list; the unchanged alphabet, lexer fuel and complete
lexer result are checked by the kernel. Each leaf rewrites the proved token
result, then checks its original complete-source `functionHeader` equality
using `kernel_exact` and a direct equality witness. All source tokens, duplicate
checks, specification terminators, contracts and theorem domains remain intact.
Both exported theorem statements are byte-identical to `8a03ab122`.

Both targets and the new helper passed a fresh **15,611-declaration** imported
module audit, with only `propext`, `Classical.choice` and `Quot.sound`. The run
uses one Lake worker, default 12 Lean threads and the original 8,192 MiB recovery
allowance. Largest sampled process RSS is 4,217,760 KiB; summed RSS is 5,269,488
KiB; minimum available host memory is 11,059,808 KiB. No 10 GiB process-tree or
1.5 GiB host-headroom guard fired. Successful unchanged dependencies are reused;
this is not a clean build, independent replay or complete source checkpoint.

The `*-runner.log.gz` is the exact log named by the detailed evidence SHA-256;
`*-launcher.log.gz` additionally includes outer runner announcements. Exact
input/workspace/tool/artifact identities and monitored resources are retained.
`input-review.json` verifies the unchanged theorem statements and proof hashes.

Independent read-only review and small corruption controls follow on these
frozen production bytes. No broader leaf rewrite, source/extractor change,
relaxed obligation, larger global memory setting or complete project retry has
been selected. The next bounded caller boundary is `FunctionSourceCandidate`,
with a controlled stop at its first new memory-pattern failure for diagnosis.
