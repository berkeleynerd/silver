# CR-comment GPR2 diagnostic evidence

2026-10-18, [#123](https://github.com/berkeleynerd/silver/issues/123), discovered
while closing [#119](https://github.com/berkeleynerd/silver/issues/119).
See the [source argument and disposition](../../research/cr-comment-gpr2.md).

Run `python3 docs/evidence/cr-comment-gpr2-20261018/check.py` to verify all
retained bytes, the one-byte LF/CR difference, observed exit statuses and the
indexed candidate's report/source identity. It performs no native execution.

`probe/` retains exact source/project bytes, diagnostic scripts, native outputs
and selected generated reports/ALI files. `ledger/` retains the five managed run
records and logs. These are tiny diagnostic runs, not a full native audit or
universal proof. The actual `silver run` failure created one retained directory,
`.silver/linux-x86_64/program-wf2RPe`, in the original installed checkout.
All other native outputs stayed under `/tmp/silver-gpr2-cr-comment-20261018`.

The GPR2 source archive is immutable revision
`96e4283834e3c56d51f986c059770be48efaf22a`, resolved from the branch selected by
the retained GNATprove dependency recipe. Its SHA256 is
`7fd2540c0303082490c74963f9b6752a092fdc61421cf53654a0ad785e9de4e5`.
The historical installed build revision is not established. The recipe forces
parser generation with Langkit v26.0.0, so the checked-in generated source's
relevant-behavior correspondence remains an explicit premise. The installed
failure and candidate results are direct observations independent of that
historical identification. No toolchain installation or production source was
changed by these diagnostics.
