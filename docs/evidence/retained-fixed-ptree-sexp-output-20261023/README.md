# Fixed diagnostic Sexp output evidence

Author packet for #119/#153,2026-10-23 UTC,Linux x86_64; independent review pending.
The [derivation](../../research/retained-fixed-ptree-sexp-output.md) explains the
fixed immutable-input/configuration transfer, actual native module adjustment,
complete Sexp capture, byte/Buffer/channel bounds and scope.

[capture.tar.gz](capture.tar.gz) retains five complete raw Sexp graphs at the
machine serializer entry, process argv/environment/stacks, debugger scripts,
byte-identical input/configuration files and the new boundary's plan. Only
`--debug-why3 gnat_ast` is added to the prior per-check argv, with fresh cwd and
TMPDIR. The caller is the actual diagnostic helper. No inferior calls/writes,
solver execution or serializer byte output follows the cut. The native interval
sums to27.334876seconds; one managed worker, five serial captures, no reruns.

[managed-run.tar.gz](managed-run.tar.gz) retains run
`20261023T224957-d4e38ab6623a`. [sources.tar.gz](sources.tar.gz) retains the
inspected Why/Sexplib/OCaml source; [native-bodies.json](native-bodies.json)
retains11 complete installed functions,2,912 instruction bytes.
[archive-manifest.json](archive-manifest.json) hashes every retained member;
[inputs.json](inputs.json) binds reused providers without replaying them.

[check.py](check.py) checks capture identity/calling context, native instruction
bytes, complete typed Sexp graph/acyclicity, expanded occurrences and each
Buffer/string/native-integer/file-offset guard. Its first
[graph result](result-before-filetag-repair.json) passed in17.278216seconds. The 4,073,437 checks are mostly
raw graph-field assertions, not distinct proof obligations. The repaired worst offered-byte
bound is7,104,139 with8,388,608-byte maximum backing; these are representation
envelopes, not measured output or aggregate RAM requirements.

The previous successful raw Ptree capture is reused. Its earlier failed
configuration preparation stays in that provider's packet. This new boundary
answers a different missing question: the complete derived converter output,
including FileTags filenames and the installed extra module field. No native
compiler/proof/solver audit or successful predecessor checker was replayed.
Physical resources remain trusted, no production implementation or new
admission limit is delivered, and #119/#153 are incomplete.

Independent review found an omitted Curr filename encoding and an unsupported
persistent FileTags association in the initial transfer prose. The amendment
imports the exact R69 alias-robust all-filename180-byte result and adds
4*180*Lloc to the byte bound. [check-filetag-repair.py](check-filetag-repair.py)
checks only that provider and changed operands;16 checks passed in0.001427s.
[filetag-repair-result.json](filetag-repair-result.json) and the updated
[result](result.json) distinguish that correction from the retained full graph
check. No successful graph/capture/provider replay. The original origin result
is also retained;189 describes raw JSON strings and is not a filename proof.
[source-origins.json](source-origins.json), [check-origins.py](check-origins.py)
and [origin-result.json](origin-result.json) bind every copied source to existing
archives and the module-converter closure;49 checks took4.544118s before the
pure metadata correction. [filetag-provider.json](filetag-provider.json) binds
the R69 source/receipts. Review of the amended exact freeze remains pending.
