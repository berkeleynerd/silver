# Native driver container evidence

Offline source/configuration/arithmetic checks for #119. The
[source argument](../../research/retained-native-driver.md) specifies the exact
command class and excluded routes. The source archive contains nine complete
GCC files; gcc.cc is reused from the environment bundle. The pinned configure.ac
was retrieved from the same GCC revision; the other eight hashes match the
retained full-source manifest. No compiler/prover/build was executed.

`installed-configuration.json` retains a static ELF string reading, including
its file offset and executable digest. It corroborates the selected build
configuration under the existing source/tool premise; it is not binary
attestation or complete correspondence. The checker uses previously captured
driver-only specs and actual frontend exec arguments, rather than recapturing
them. Its optional `--gcc PATH` verifies the static string against the executable.

```sh
python3 docs/evidence/retained-native-driver-20261018/check.py
```

The calculations check individual requests and actual field widths, with no
aggregate RAM/address-span membership gate. Remaining joins are explicit in
the report. These checks support the handwritten argument, not a formal proof
of GCC or a complete capacity result.
