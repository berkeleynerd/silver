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
[result](result.json) passed in17.278216seconds. The 4,073,437 checks are mostly
raw graph-field assertions, not distinct proof obligations. Worst offered-byte
bound is3,157,819 with4,194,304-byte maximum backing; these are representation
envelopes, not measured output or aggregate RAM requirements.

The previous successful raw Ptree capture is reused. Its earlier failed
configuration preparation stays in that provider's packet. This new boundary
answers a different missing question: the complete derived converter output,
including FileTags filenames and the installed extra module field. No native
compiler/proof/solver audit or successful predecessor checker was replayed.
Physical resources remain trusted, no production implementation or new
admission limit is delivered, and #119/#153 are incomplete.
