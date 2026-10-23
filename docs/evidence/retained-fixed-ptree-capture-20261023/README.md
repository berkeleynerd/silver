# Fixed Ptree inputs for diagnostic serializers

2026-10-23 UTC, Linux x86_64; #119 / #153. **New retained raw inputs; no
serializer-capacity result yet.** Five serial read-only debugger captures stop
on entry to `Typing.type_mlw_file`, before its first instruction. The stack
identifies the caller as the native JSON plugin's `read_channel`. No inferior
function call or memory write occurs. Fork/vfork/exec and the later
`Gnat_checks.init` boundary are guarded; no typing, server connection or solver
execution follows the capture point.

The missing question is the complete immutable Ptree used by
`gnat_ast_to_ptree.ml:1401–1423` when an ordinary typing failure invokes its
`.sexp` and `.mlw` diagnostic writers. These five fixed dependency inputs are
the exhaustive retained family, not samples of arbitrary Main programs.
The prior successful prefix work did not retain this Ptree root. Replaying a
solver or prior successful check would not supply the new input.

[capture.tar.gz](capture.tar.gz) contains scripts, plans, exact input/config
copies, all reachable data blocks, process/stack/environment evidence and both
attempts. [managed-runs.tar.gz](managed-runs.tar.gz) retains the managed ledger:

- `20261023T222336-b7d60127af41`: preparation failure; scratch omitted the
  required cwd `why3.conf`. The target exited before the capture point. Its
  0.607070-second attempt, logs and diagnosis remain in `attempt-1/`.
- `20261023T222412-097c69803446`: exact pinned per-case configurations restored
  and asserted before execution; all five captures succeeded. Their measured
  target/debugger intervals sum to 15.263862 seconds. One native worker was
  reserved. No successful capture was repeated.

[check.py](check.py) verifies all archive members and retained inputs, the
actual invocation/environment, the 120-byte installed entry instruction span,
the acyclic data graph and complete expanded occurrence arithmetic. It also
checks the old declaration projection against the new native tree: modules
46/46/41/21/12 and declarations 352/352/343/199/121. Direct strings have maximum
payloads 187/184/202/199/195 bytes; no custom numeric block is reachable.
The largest graph expands to 22,005 blocks, 22,554 immediates, 47,776 direct
string bytes and depth 261. Shared subtrees are charged at every occurrence.
The [result](result.json) records all five cases and the initial successful 2.230968-second
offline check; the later field-metadata correction is recorded separately.

**New source/layout distinction.** Its first schema check expected the inspected
`ptree.ml` module pair `(ident,decls)`. Actual native entries have three fields
`(ident,1,decls)` (raw OCaml value 1) in all five inputs. The decoder now retains and checks that
extra field instead of silently applying the pair layout. The initial record
mislabelled that immediate as Boolean false; the printer author found an
optional-signature reader, so its selected meaning is None, subject to that
separate native attachment. The raw graph and all structural counts are unchanged. This does not change
the matching declaration counts, but the relevant native serializer readers
and extra flag must be attached before using the inspected printer source.
This packet makes no new blanket source-version identity claim. No target rerun
was needed to investigate the captured fields.

Every three-immediate, tag-zero record is counted as a candidate location,
including any overincluded unrelated record. The maximum multiplicity of an
identical triple is 33/33/24/18/13. These are structural inputs, not an already
proved marker-emission count. `Loc.get` consults the external FileTags map;
its expanded filename bytes are not in the direct-string total. The diagnostic
capacity argument must charge them separately.

[sources.tar.gz](sources.tar.gz) retains the inspected converter, smart
constructors, Ptree and Mlw printer from existing archives.
[archive-manifest.json](archive-manifest.json) binds every byte. Native/source
transport to the current quiet/timeless/J12/logging configuration, Ptree
preservation through failing typing, serializer event/text bounds, marker-copy
accounting and private channel/native operands remain explicit proof work.
Current Oracle, toolchain and admission are unchanged. This packet neither
completes #153/#119 nor authorizes starting production #88–#94.

Lead live model/effort, whole-work elapsed time and token/cost telemetry are
unavailable. Managed native time and offline check time have the scopes above.
