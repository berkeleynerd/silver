# Complete affected Lean module tests — passed

On native Linux ARM64 (`silver-m4pro`), managed run
`20261115T222916-4123afb6a6ad` passed the complete `tests/test_lean_modules.py`
file: **three tests, no failures or skips**. Original launcher session **87322**
returned **0**. Its monitored child returned 0; the managed outcome is success
with its recorded overall returncode null. No restart, duplicate, interruption,
resource guard or attachment was needed.

The archived original full-suite traceback confirms that the chunk-reuse test
failed at its initial `self.assert_success(build())`, line 217, because
`Silver/CertificateJoinWitness.lean` was missing and the generated aggregate had
a bad import. It had not reached the edit/reuse loop. The original full-suite
run `20261115T220916-99f1eaeea331` remains failed; this packet supplies successful
focused results after the reviewed fixture repair. It makes no claim about the
separate scalar source-limit stack failures.

The repaired test now reaches all **eleven** original edit variants:
`replace`, `append`, `insert`, `delete_unique`, `reorder`, `repeat`,
`delete_repeated_occurrence`, `crlf`, `remove_final_newline`, `add_empty_line`,
and `empty_source`. Every original assertion executes: initial fresh build and
axiom audit, identical-regeneration retention, stale-source rejection despite
restored mtime, exact affected chunk identities, unchanged independent and
unaffected object bytes/timestamps, required changed objects, fresh audits and
restoration builds. All emitted `OUTPUT_BODY_CONTENT_REUSE` observations,
including the three object-variant hashes for every chunk, are retained in
[mutation-observations.json](mutation-observations.json).

The other two tests also passed: rejection of a private axiom behind a module
import, and proof reuse/public-source invalidation. The exact three IDs and
terminal summary are in [test-results.json](test-results.json).

Launch HEAD was `441bc44bca4981e1431d3fbbab95f4ad150f0f3a`; terminal verification
HEAD was `0ffe531e486ecd3089cf8a9d4f3202367b2d17e5`. All **1,316 regression
inputs and 2,606 native inputs** match their launch snapshots; native inputs
also match the accepted complete native audit, with all 80 report hashes valid.
Native and Lean tools and both compiler binary identities match launch. Compared
with the original failed full-suite snapshot, exactly **one** regression input
changed: `tests/test_lean_modules.py`, from `e1b5c221...` to `ad57b660...`.
The complete hashes and 1,315 unchanged inputs are accounted for by
[full-suite-input-delta.json](full-suite-input-delta.json) and the retained
snapshots. No production, proof, generator, runner or other test input changed.

Automatic managed allocation reserved **12 workers**. The original fixture
settings stayed at **one Lean thread and 2,048 MiB**, with the existing
watchdogs and application policy unchanged. The monitor used **1.5 GiB minimum
host headroom and no process-tree cap**. Fourteen samples had a maximum interval
of 5.0111 seconds. Peak sampled tree/process RSS was 1,646,944 / 937,968 KiB;
minimum host available memory was 15,088,272 KiB. Managed elapsed time was
62.708 seconds; wrapper elapsed time was 65.050 seconds.

[verification.json](verification.json) records exact scope and identities.
`run-packet.tar.gz` retains 29 preparation, inventory, monitor, resource,
terminal, input/tool/binary, result, observation and managed-log members. Every
member's size and SHA-256 were read back from the archive and checked against
[retained-files.json](retained-files.json), as
[retention-verification.json](retention-verification.json) records. The
[original session result](original-session-terminal.json) was collected directly.

Selected monitoring/evidence role: GPT-6.1 Sol, High. Runtime telemetry and
token/cost measurements are unavailable. No full regression suite, native proof,
whole-project Lean checkpoint or compiler build was repeated; no production or
test source was edited by this validation owner.
