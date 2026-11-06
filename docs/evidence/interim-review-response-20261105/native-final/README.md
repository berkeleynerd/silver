# Final native checkpoint — 2026-11-05

Managed run `20261105T110725-477d91dbd07d` **passed** on native Linux x86-64
at `2026-11-05T20:15:45.548860+00:00`. Complete GNATprove evidence covers
**76 units, 1,104 entities, 1,496 flow checks and 16,000 proof checks**, with
the required source/report, obligation and content-bound provenance audits
passed. See the [terminal summary](summary.json), [coverage report](gnatprove.out),
[native log](native.log.gz) and [managed events](events.jsonl.gz).

The complete audit also records 313 limitation notes, 18 imported entities,
6,236 trusted-math notes, 62 vendor-spec entities and six array-initialization
advisories under the existing audited policies. These categories are distinct
from required flow/proof checks. The terminal failure-key list is empty.

## Exact mode, installation and timings

The run used frozen commit `fb89b3653accef6c08a49f88625144c108ad2432` in
`tmp/empty-loop-repair`, with four requested and granted workers:

```sh
python3 scripts/dev.py prove --full --jobs 4 --task '#309-#320 final native' -- --subdirs=review-final
```

This is full forced all-unit analysis (`-U`, `--mode=all`, `-f`) with the
canonical level-2 CVC5/Z3/Alt-Ergo policy and 30-second timeout. The
`review-final` output/session tree had been seeded before the run; the captured
initial state records both `sessions_present: true` and
`cache_entries_present: true`. Existing sessions and the native result cache
were available for reuse. This is not a cold proof. The exact effective argv,
cache path and host selection are retained in the [summary](summary.json),
[input snapshot](proof-inputs.json.gz) and
[completed provenance manifest](proof-provenance.json.gz).

| Measurement | Seconds |
| --- | ---: |
| Preflight phase | 4.485 |
| Native-tool phase | 32,881.116 |
| Complete audit phase | 10.662 |
| Managed started-to-finished duration | 32,897.462 |

These durations come from the managed monotonic events. The native-tool phase
includes the tool invocation, and the audit phase includes both the in-process
checks/provenance completion and the separate complete-evidence auditor.
Managed duration includes runner overhead between phases. No external-wrapper
elapsed measurement is claimed. The successful managed terminal records
`returncode: null`; the native-tool phase records return code zero.

## Input identities and final integration applicability

Read-only retention verification matched all **2,586 current native input
paths and SHA256 hashes** to the prepared record, input snapshot and completed
manifest. It also checked all twelve recorded tool binaries and version-record
digests, all 78 manifest-bound report hashes, and equality between the runner's
retained successful reports and the original output directory. See
[current input verification](current-input-verification.json).

All **143 repository native inputs** match both the current integration tree
(inspection HEAD `d78329ccaf`) and governed source commit
`ddb183a918c78c8636b94961172dc923e7d88d30`: 131 Ada source files, nine Python
runner/auditor files, the native project, proof-container project and root
Alire manifest. The later Lean proof-body/budget changes and Lake CPU-default
configuration are outside this native capture. Their complete assurance is
retained separately in the [final Lean checkpoint](../lean-final/README.md).

The native result retains its actual generated configuration and installation.
Compared with integration, 2,583 captured paths match exactly. The remaining
three differences are fully retained in the
[integration input applicability record](integration-input-applicability.json):

- `silver_build.ads`: absolute installation prefixes in generated paths and
  the Alire command.
- `silver_image_config.ads`: absolute vendor-executable path prefix; the
  recorded vendor executable SHA256 is unchanged.
- Local Alire `settings.toml`: cache/toolchain directory prefixes and the
  `last_update` value.

The two generated Ada files match after only the literal installation-prefix
substitution; this comparison does not modify either file. Success remains
bound to the original native installation. Repository input correspondence
does not assert identical generated inputs or compiler binaries across these
worktrees.

## Retained artifacts and scope

The [raw successful report archive](proof-evidence.tar.gz) contains every
file retained by the runner in its successful `proof-evidence/` directory:
76 SPARK unit reports, SARIF, the coverage report, input snapshot and completed
provenance manifest. Its [member index](archive-members.json) records each
original file's size and SHA256. The
[artifact index](artifacts-index.json) records original/stored byte counts and
digests for the ten retained or derived artifacts. Gzip streams use `mtime=0`;
decompression and every tar member were checked against the original bytes.

This packet was retained after the audited terminal success. No proof, build,
test rerun or cache mutation was performed for retention. Earlier focused
failures remain retained with their original outcomes in the
[review-response record](../../../interim-review-response-20261105.md).
Regression coverage and closing integration review remain separate evidence.
PR #307 remains draft/open; merge is unauthorized.

| Retention round | Selected setting | Result and measurements |
| --- | --- | --- |
| Native monitoring and terminal retention | GPT-6.1 Sol / Extra High, as recorded for this worker; runtime model/effort confirmation unavailable | Complete audited native success retained; input/tool/report/archive identity checks passed. Native phase measurements are above; total agent elapsed time, token usage and cost are unavailable. |

This worker made no commit, publication or CLI recall update. The delivery
coordinator owns final documentation integration and publication.
