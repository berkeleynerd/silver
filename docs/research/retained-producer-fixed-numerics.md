# Retained producer fixed numeric fields

Research for #119, measured on Linux x86-64 on 2026-10-18. This supplies the
fixed-state numeric width used by the producer serializer argument. Under the
source-reviewed fixed-dependency premise in
[retained-producer-fixed.md](retained-producer-fixed.md), the fixed contribution
can use **`d_fixed = 40` characters** for each decimal Uint image, including its
sign. Main's varying numeric values require the separate source argument in
[retained-producer-numerics.md](retained-producer-numerics.md).

This is a measurement of the retained installation with a conditional transfer
to the complete fixed dependency set. The six examples alone do not establish a
bound for arbitrary Main source or a source-to-binary correspondence theorem.
The source-identity assumptions remain those of the surrounding capacity record.

## What was read

The existing graph snapshots omitted scalar numeric fields, so six additional
small producer invocations read those missing values: the retained null Main and
the five isolated roots `put`, `put_line`, `first_or_default`, `input_is_valid`
and `reject`. They reused byte-identical phase-1 ALIs and library source in a new
scratch directory; no toolchain was installed or changed.

Before running an inferior, DWARF inspection established all eight numeric
positions in the Why node record: range `First`/`Last`, four Uint constant
`Value` positions, and two Ureal constant `Value` positions. At the existing
before-Standard, after-Standard and before-symbol-free boundaries, the reader
walked every allocated Why node and retained its numeric field codes. For each
indirect Uint it retained the raw eight-byte `(Length, Loc)` entry and the raw
base-32768 digit bytes; the first digit carries the sign. For each Ureal it
retained the raw sixteen-byte `(Num, Den, Rbase, Negative)` entry and the
referenced Uint representations. No inferior function was called and no inferior
variable was changed.

The source representation is described by GCC Ada `uintp.ads:449–586`,
`types.ads:352–363` and `urealp.adb:32–58`. The reviewed serializer at SPARK
`src/why/xgen/why-atree-to_json.adb-tmpl:26–44` writes a Uint as its quoted
`UI_Image (..., Decimal)` and a Ureal as its numerator, denominator, base and
sign. `urealp.adb:259–262,450–453` returns the stored numerator and denominator
unchanged. **For a nonzero base, the stored denominator is an exponent.** It is
not expanded into a potentially huge rational denominator for serialization.
The exact source-reading hashes are in the evidence summary.

## Results

All six runs reached all three boundaries. Before Standard, each had 1,445
allocated nodes and zero numeric fields. After Standard, each had 6,481 nodes,
80 numeric fields and maximum decimal image length 40. The final states were:

| Isolated input | Allocated nodes | Numeric fields | Referenced Uint codes | Referenced Ureal codes | Maximum decimal image length |
| --- | ---: | ---: | ---: | ---: | ---: |
| null | 7,136 | 94 | 35 | 8 | 40 |
| put | 9,082 | 122 | 39 | 8 | 40 |
| put_line | 9,115 | 124 | 40 | 8 | 40 |
| first_or_default | 8,420 | 123 | 40 | 8 | 40 |
| input_is_valid | 7,243 | 94 | 36 | 8 | 40 |
| reject | 7,413 | 94 | 36 | 8 | 40 |

The maximum is already present in Standard:
`-170141183460469231731687303715884105728` (`-2^127`), a 40-character signed
decimal image. Its indirect representation has nine base-32768 digits,
`[-128, 0, 0, 0, 0, 0, 0, 0, 0]`. The longest positive integer has 39 decimal
digits. The observed Ureal numerator maximum is `18446744073709551615`, while
its stored denominator is `-4080` and base is 16. The serializer uses those
compact components. All numeric fields, including duplicate values under
different Uint codes, are retained in the archive.

The offline checker decodes the raw little-endian entries and digits again,
reconciles every numeric-field reference, checks the logs and managed input
hashes, and verifies all 18 snapshots / 1,131 numeric-field observations. It
launches no native tool:

```sh
python3 docs/evidence/retained-producer-numerics-20261018/check.py
```

## Evidence and cost

The [evidence directory](../evidence/retained-producer-numerics-20261018/)
contains the checker, a per-member manifest, a concise summary and
`inputs-fields-and-runs.tar.gz` (90,954 bytes, 102 members). The archive retains
the actual source/ALI inputs, options, argv/environment records, raw numeric
snapshots, GDB scripts/logs and the six managed-run event logs. Its SHA-256 is
`fd99dafb4b5d552ede975cbd0fadc68fa6b9d2bb2571a42123f63301bdfd1ba3`.

The measured producer SHA-256 is
`343682de485bb151e1817615acebab5b185504efdf2b082f1647cd41a14241f1`.
The six runs used one reserved worker sequentially. GDB subprocess time totaled
3.1801 seconds; managed wrapper durations totaled 16.5620 seconds. All succeeded
on the first inferior run, with zero backend calls, zero solver/proof runs and no
result-collection entry. The false backend and collection guard remained active.
The managed ledger reported zero reserved workers and no required diagnostic
checkpoint afterward. No full validation or proof evidence was rerun.

For the fixed closure, the usable conclusion is therefore `d_fixed = 40`,
**conditional on the existing source-reviewed dependency closure and the
retained tool/source behavior premise**. Combining that with Main's varying
numeric bound is required before claiming a bound for every admitted program.
