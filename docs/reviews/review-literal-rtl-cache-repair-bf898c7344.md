# Adjacent register-attribute setter repair review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accepted. R1/[#141](https://github.com/berkeleynerd/silver/issues/141) is
resolved; no further material finding was identified in this bounded repair.**
The transfer now counts **4C insertion-capable lookups** while correctly
retaining **3C records, 3C register-cache backbones and 4C combined new cache
backbones** through an explicit paired-call argument.

## Frozen target and reviewer record

Repair target `bf898c7344d4e5f4c6f3ec2c99c2da7c38f974e3`, base
`8e4a84cfa3b513b6a0d4e02ede7e910ab12697ad`. Review inputs are the nine-file
repair diff, the [original C review](review-literal-rtl-cache-controls-8e4a84cfa3.md),
the exact compiler source paths involved in R1 and the retained focused repair
result. The original review supplies the unchanged cache/control source
closure; this review does not repeat that investigation. The original review's
non-SSA setter citation is corrected to `cfgexpand.cc:305`, replacing 308;
this citation correction does not change the finding.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime confirmation of
model/effort and token/cost measurements are unavailable. Inspection and the
completed evidence checkpoint ran **00:30:43–00:31:49 UTC**, **66 seconds**
at one-second resolution, excluding report preparation and commit. The actual
host is Linux x86-64. The existing bounded lead authorization and governing
Oracle/project review requirements remain applicable. Only this new review
report and the original review's citation correction are reviewer-owned
changes, in isolated worktrees under repository `tmp`.

## Source argument and transfer

The revised note follows both fresh-descriptor setter calls through
`cfgexpand.cc:264,305`, `tree.h:3121` and `emit-rtl.cc:1463–1469`.
`init_raw_REG` clears attributes; `leader_merge(null,decl)` selects the same
declaration used by the second setter. Register and declaration modes do not
change between calls, so their cache keys coincide. The non-SSA path, cache
lookup/expansion and GGC allocation source support the no-interposed-collection
premise; allocation itself does not invoke collection.

The note now handles growth before a hit. If the first call expands, its
resulting live count L and prime size S satisfy `2L <= S`, `S >= 7`, and no
tombstones remain. At most one insertion leaves
`4(L+1) <= 2S+4 < 3S`, excluding expansion on the second call. If the first
does not expand, only the second can. The second hit may expand after the
first insertion crosses the old threshold; the proof and checks explicitly
include that case. Same-size compaction and shrinking satisfy the same bound.

The transfer distinguishes **2C descriptor calls in C pairs**, **2C split-part
calls**, **at most C descriptor records/backbones** and the combined **3C
records/backbones**. The history remains `39257+3C`; `CONST_INT` remains
`39257+120+C` with C additional backbones. The new combined backing allowance
therefore remains 4C, with no duplicate direct-object charge. The five scalar
controls and complete-scope residual flags are unchanged.

The only added manifest input is complete `gcc/tree.h`; all previous 55 inputs
are retained. All **38 compiler and 18 repository identities** and the three
repair implementation identities match the target. The local transfer's seven
other top-level function/class ASTs are unchanged. Independent result comparison
found exactly the expected lookup/pair metadata changes and source identity
count 37→38; all other result values agree with the original frozen output.

## Evidence and disposition

The repaired callable is 9,158 bytes, SHA-256
`9e485e84418ae0e3ed7cb48d2a92955bba0d6447de890f539c34b650e6699a0b`.
The focused checker is 5,918 bytes, SHA-256
`c633280efc6d8d67de6de4e509b05149c022e465c79f16d579ae51caa6c506e8`.
The revised source argument is 18,234 bytes, SHA-256
`cbfe35688bee3f687f38c6e4aa01d3a96d8ee0da243e0c23756ee758e5750147`.

The author retained **17 repair checks over 21,029 finite paired-table states
in 0.05146142599915038 seconds**, covering first-call growth, second-hit growth,
compaction, shrinking, larger source counts, changed complete macro-source
rejection and unchanged global residuals. This is reused evidence. The original
39-check record is byte-identical and explicitly labelled historical; it is
not presented as a run on the repaired inputs. Neither checker was rerun here.

A narrow independent diagnostic verified identities, AST/output preservation,
four source-count transfers including a failed large-capacity guard, and four
targeted paired-growth examples in **0.243213959998684 seconds**. No Context,
native tool, aggregate, predecessor suite, corpus inventory, GitHub write or
delegation ran. CLI memory was not updated. Scratch script
`tmp/review-cache-repair.py`, SHA-256
`9e321e475c751369fe19708148c4763294cbb0b5fd793b7de20ba630498d494e`,
and its result remain in the isolated review worktree. The previous independent
41,585-state diagnostic is reused, rather than repeated.

**Disposition: accept this frozen repair and the original cache/control packet
as repaired.** The selected type/alias family, full scalar-finalizer endpoint,
global counters, collector/native capacity and full-current-grammar #119 rule
remain open. Total GGC is still null. No production admission, trusted-tool or
Oracle change is established, and production #88–#94 remain unstarted.
