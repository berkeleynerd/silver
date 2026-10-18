Retained source-only checksum ingress checkpoint for research #119. This packet
does not establish a lifetime bound for arbitrary checksums. No native tool ran.

Replay with `python3 docs/evidence/retained-binder-checksum-20261018/check.py`.
The checker verifies the complete retained source files against both corpus
manifests, the predecessor artifact identities, and the local arithmetic. Source
markers guard correspondence; the reviewed argument is in
`docs/research/retained-binder-checksum.md`. No markers alone prove the argument.
