# PR #403: retained assurance applicability

**Recovery update, 2026-11-20:** the [recovery addendum](assurance-applicability-recovery-addendum.md)
supersedes the missing-artifact/input findings below. All 2,622 native inputs,
1,037 Lean workspace inputs and 6,202 Lean artifacts now have matching locally
verified bytes. C9's retained-assurance applicability requirement is satisfied;
no proof rerun is justified for the sample-only PR. The original assessment is
preserved below as the record before recovery.

Independent read-only assessment, 2026-11-20. Reviewed PR head
`001c50dce1bcf3ad2d174b4426f684fe78cb2e64`, compared with main
`a03c7987bbba29569db2709820bd26ced20bed40`. Selected reviewer setting:
GPT-6 Astra / Max; independent runtime telemetry is unavailable. Actual review
host: Linux x86-64. This report covers #400 C8/C9 assurance applicability,
not the separate regression inventory, whole closing review, or merge decision.

**The complete #392 native and Lean results apply to the unchanged repository
compiler/proof inputs at PR #403. No source-certificate rebuild, clean run, or
independent kernel replay is required merely because this PR adds samples.**
The retained results remain Linux ARM64 results. They are not a complete proof
of the newly generated x86-64 installation. A new Lean invocation is not an
unconditional sample-batch requirement; if invoked, its fresh actual-import
and axiom audit remains mandatory.

The remaining evidence distinction is concrete: packet review can establish
the retained result and exact source applicability, but cannot freshly rehash
the original absent tools/objects or validate an absent Image overlay. If the
closing record claims current integrity of the preserved ARM installation,
obtain the read-only checks below on that installation. If it claims complete
native verification of the new x86 installation, that installation has changed
generated/tool inputs and needs its own applicable native evidence. Neither
claim should be silently substituted for retained source assurance.

## Policy and the delivered precedent

I read AGENTS.md, the Oracle, development.md's proof-loop/checkpoint sections,
docs/proof-iteration.md's invalidation matrix, the assurance/trust-boundary
descriptions, #400's captured body, and PR #403's captured criteria review.
Required obligations, source correspondence, provenance and allowed axioms
are preserved. The run ledger is not used as proof.

The phrase “every required fresh audit” in the sample-batch plan is conditional;
it does not independently require running Lean again for unchanged proof inputs:

- `docs/scalar-function-rosetta-batch.md:316–331` records accepted combined
  #345 delivery using #339 complete native/Lean assurance and expressly says
  no new complete compiler or Lean run was performed.
- `docs/reviews/review-scalar-function-rosetta-delivery-20261108.md:134–150`
  accepts this reuse after considering all 2,588 native inputs, 12 native tools,
  927 Lean inputs and 2 Lean tools; the review did not perform another proof
  or import audit. Its preceding exact checks remained applicable.
- The current-main integration at batch-record lines 370–388 likewise reuses
  a retained fresh declaration audit without a new Lean invocation.
- The current invalidation matrix separately requires affected sample/tests
  and does not invalidate unchanged source proofs solely for samples.
  Every actual `check_lean.py` invocation, including a cache hit, still runs
  its selected actual-import/axiom audit.

Thus the missing packets noted in PR #403 were a real review gap; retrieving
and checking those packets is useful work. It does not by itself imply that
the original successful proof computations must be repeated. There is no
documented evidence-age limit or perpetual archive of all third-party tool
executables. Historical recorded tool checks must be identified as historical,
rather than described as newly repeated.

## Checks completed on the exact PR inputs

Reproduce the cheap checks from the main checkout with:

```sh
python3 tmp/pr403-delivery-20261120/assurance_applicability_audit.py
```

The helper writes only its adjacent scratch outputs. It uses the unchanged
production auditor and generator functions from the delivery worktree. It
does not launch GNATprove, Lean, Lake or a build and does not change caches.
The detailed result is `assurance-applicability-results.json`; the concise
captured output is `assurance-applicability-audit.log`.

| Check | Observed result |
| --- | --- |
| Exact governed repository input set and bytes | All 147 native and 1,142 Lean inputs match both PR Git blobs and delivery-worktree bytes; 1,145 unique repository paths |
| Native packet integrity | Complete 19-file payload inventory matches SHA256SUMS.json |
| Lean packet integrity | Complete 54-file payload inventory matches packet-manifest.json |
| Native original snapshot/result consistency | Completed schema-1 full manifest agrees with initial proof-input snapshot, canonical all-unit proof options, ARM host and captured command |
| Native report archive | All 80 names and content hashes match the manifest; 54,448,685 uncompressed bytes |
| Fresh native report/source-policy audit | 78 units, 1,252 entities, 1,751 flow checks and 17,975 proof checks; all recorded classifications match the original result |
| Native generated Ada | All three original files independently reconstructed to their recorded hashes; the runtime binding derives from current exact source bytes |
| Lean archived repository inputs | All 1,142 members rehashed and compared byte for byte with PR files; 13,656,931 uncompressed bytes |
| Lean archived workspace inputs | All 1,037 members rehashed; all protected handwritten/configuration bytes equal PR inputs; 41,248,100 uncompressed bytes |
| Generated candidate parity | All 40 candidate modules freshly generated in memory from current source and unchanged generator; exact equality with archived and checked-in candidate bytes |
| Lean source policy | Current workspace sources pass the existing direct-kernel-bypass source check |
| Retained Lean log and coverage | Log hash matches; actual-import records cover exactly all 1,035 project modules; retained audit reports 166,332 declarations and only propext, Classical.choice, Quot.sound |

Native accepted classifications are also exact: 357 limitation notes, 18
imported entities, 6,268 trusted-math notes, 62 vendor-spec entities, 6
array-initialization advisories and 27 operator-reassociation advisories.
These are classifications, not additional proved checks.

The fresh native operation calls `audit_reports` with expected units/trusted
imports and source-derived generic-instance arguments, after current source
policy/import-spec checking. It deliberately does not fabricate a current
`validate_provenance` success. `audit_sources`' timestamp guard was not run on
reconstructed copies; timestamps were not backdated to imitate original files.
Exact content hashes provide the source comparison claimed here.

The retained Lean success is run `20261117T064945-d458c99ae977` on native Linux
ARM64, complete scope, cached build plus fresh audit, without clean build or
`leanchecker --fresh`. Both recorded phases exited zero. The original failed
complete run remains failed history; no successful status is inferred from it.
The current helper's log parsing is a recheck of that retained result, not a
new Lean execution or kernel audit.

## Complete input classification and scope

| Input class | Count | Treatment |
| --- | ---: | --- |
| Native repository sources, scripts, projects/manifests | 147 | Exact current-worktree and Git-byte matches; unchanged input inventory |
| Native generated Ada specifications | 3 | Exact old bytes reconstructed and hashes matched; generated paths/tool binding retain original ARM installation identity |
| Native Alire context | 3 | alire.toml, alire/alire.lock, alire/settings.toml; recorded hashes and original collector validation retained |
| Native Alire settings/index TOMLs | 2,469 | Every name/hash retained and classified; not exempted as irrelevant merely because most describe index state |
| Native tool identities | 12 | Original executable/path/version hashes retained; all recorded version-string hashes checked anew |
| Native final reports | 80 | Original bytes rehashed and fresh complete report audit passed |
| Lean repository inputs | 1,142 | Exact current inventory and bytes, including all 135 root Ada sources, 9 scripts, noncandidate Lean and build/toolchain/generator files |
| Lean workspace inputs | 1,037 | 1,035 modules plus Lake configuration/toolchain; includes 40 explicitly regenerated candidates, not omitted proof inputs |
| Lean tool identities | 2 | Recorded original ARM lean/lake hashes retained; not replaced by local x86 hashes |
| Lean compiled artifacts | 6,202 | Full recorded hash map retained; object bytes are not inside the committed packet and were not rehashed here |
| Paths | — | Relative paths select inventory members; recorded native absolute installation/tool paths also occur in commands and generated source and are not normalized away |

The 12 native identities are gnatprove, gnatls, gcc, gprbuild, cvc5, z3,
alt-ergo, gnat2why, gnatwhy3, why3server, python and alr. Eleven original
executable paths are absent here. `/usr/bin/python3.14` exists locally but its
hash differs from the recorded ARM Python; it is not a match.

The old `.tools/linux-aarch64` and `.silver/linux-aarch64` directories in this
Linux x86 checkout are historical remnants, not recovered #392 state. Among
the 2,469 Alire settings/index entries, 2,337 local historical copies match,
121 are missing and 11 differ. Of the three context entries, two match and one
differs. Of the generated files, two old local copies differ and one is absent.
Those observations do not invalidate the recorded historical invocation; they
do rule out presenting these local directories as its current installation.

For the newly built root x86 installation, `silver_library_sources.ads` matches
the old exact runtime binding, while `silver_build.ads` and
`silver_image_config.ads` differ. They contain different host/root/vendor data.
This is expected after bootstrap at another installation, but they are SPARK
proof inputs. No hash exception, host relabeling, binary attestation, or
cross-installation complete-native claim is made.

No repository compiler/runtime, contract, source-shape pin, Lean theorem,
candidate generator, proof auditor, project or catalogue bytes changed in
this PR. The changed Rosetta renderer is outside the native/Lean proof input
enumerators; it and affected sample/test metadata require their own regression
checks. Their coverage is owned by the separate regression/closing review.

## Smallest remaining checks and recovery paths

For a retained-source-assurance claim, the successful original full provenance
and audit records plus the exact repository/candidate comparisons above support
reuse. Do not describe that as a new Linux x86 compiler proof or newly executed
Lean audit. This report does not independently sign off C8's regression coverage
or all of C9's installation-specific claims.

To resolve current integrity of the preserved original installation using the
strongest delivered precedent, first perform these **read-only** checks there:

1. At the original native checkout below, run `python3 -B scripts/check_evidence.py`.
   This performs current complete provenance, tool-byte, generated/configuration,
   Image-overlay and source/report auditing. It does not launch GNATprove or
   require compiler object/Why3-session/solver-cache contents. Retain its actual
   exit/log and current input/tool inventories. Do not mutate a failed manifest
   or substitute a new host label.
2. At the original Lean checkout, compare all 1,142 source inputs, 1,037 workspace
   inputs, 2 tool hashes and 6,202 artifact hashes with final-run/evidence.json.
   Run the existing `verify_run_inputs`, `check_cached_kernel_policy` and
   `compiled_artifacts` read-only checks with the recorded maps; verify the
   authoritative sibling source link. This is fresh artifact/provenance/trace
   inspection, not an imported-declaration audit. No proof rebuild is implied.
3. Review any mismatch before selecting work. Input changes can invalidate
   evidence; a filename or historical directory's existence does not establish
   reuse. Conversely, mere absence of a local raw copy is not a failed theorem.

Original native checkout:

```text
/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/named-native-392
```

Original Lean checkout:

```text
/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/named-source-392
```

For raw Lean recovery, preserve that checkout's complete
`.silver/linux-aarch64/proof` **merged mounted view**, including
`.silver-cache-tools.json`, all `.lake` traces/dependency/IR metadata, ordinary,
private and server objects, candidate/protected sources and configuration.
Record the sibling `.silver/linux-aarch64/src` link's actual resolved target.
The 6,202 inventoried files consist of 1,035 ordinary objects and their 1,035
hash files, plus 1,033 each private objects/private hash files/server
objects/server hash files. Recovering `.olean` alone is insufficient.

The overlay's old lower layer is
`/home/agent/silver-worktrees/procedures-lean-370/.silver/linux-aarch64/proof`;
its private upper is
`/home/agent/silver-workspaces/recovery-volume/named-392-lean-overlays/named-source-392/upper`.
An upper-only archive omits valid lower objects. Final artifact sizes are not in
the successful manifest; measure them at recovery. The mid-run disk record
measured 1,849,128,456 lower bytes and 919,341,438 upper bytes across broader
artifact families, including duplicates. Those are not final archive sizes.

For native current-input recovery, all three generated Ada files, the three
context files and all 2,469 indexed settings files are selected by the manifest.
The Image overlay's topology/links/copied vendor executable and original tool
path/hash checks are additional validation, not implied by generated-file
hashes. A collector's exact read-only verification result is useful; transferring
an entire ARM toolchain is not necessary just to inspect the retained result.

If a genuinely new complete Lean validation is needed after recovery, use the
existing managed runner on the recovered **same ARM installation**, after
reading its run summary and checking inputs/resources:

```sh
python3 scripts/dev.py runs status --task '#400'
python3 scripts/check_lean.py --provenance --task '#400' \
  --reason 'Complete cached validation on matching recovered ARM inputs; retain successful objects'
```

Default worker/thread allocation should be reconsidered from live resources;
the old one-worker/one-thread setting is historical, not a default to inherit.
That command regenerates candidate text cheaply, lets Lake retain valid objects
and freshly imports/audits the full environment. No `--clean` or `--replay` is
needed. It should not be started merely to obtain a newer timestamp.

Do not install the ARM cache into the x86 runner and rewrite its tool marker.
`check_lean.py:218–237` intentionally invalidates `.lake` when builder path/hash
identities differ; both differ across these host installations. A source-only
comparison cannot waive that behavior. A transferred archive can be inspected
and preserved without being declared a valid x86 build cache.

## Review disposition

No changed-proof, source-correspondence, obligation or axiom defect was found in
the PR's repository delta or the retained successful packets. The smallest next
step is original-installation evidence collection/checking if a current integrity
claim is wanted; no expensive proof rerun follows from the samples-only diff.
The final C8/C9 record should state retained ARM assurance, the fresh Python
report audit and exact source/candidate applicability separately from any later
raw-artifact check or new native run. Closing review should judge that concrete
scope instead of treating “fresh” as a blanket new-proof requirement.

No tracked source, proof, configuration or policy file was edited. No GitHub
write, commit, push or merge occurred. CLI recall was not updated.
