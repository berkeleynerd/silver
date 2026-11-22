# PR #412 focused review I4 — producer sources

The November 22 source inspection resolved both I4 questions for review
target `5a4b0ad8ac`. Every admitted pair involving an array input exits the
anti-aliasing check before a flow record is emitted. For the selected array
declarations, both the default-check and non-predefined-equality conditions
are false. These routes contribute zero additional retained bytes.
[Capacity argument and producer line references](../../../../../named-array-parameters-report-capacity.md#aliasing-and-named-type-records-i4)

All three files were retrieved at SPARK revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`.
`flow-analysis-antialiasing.adb` comes from `src/flow/`. Both
`spark_util-types` files come from `src/spark/`. The archives were produced
with `gzip -n -9`. Each SHA-256 entry covers the bytes obtained with
`gzip -dc`. [Pinned upstream tree](https://github.com/AdaCore/spark2014/tree/42554fc241fcd1fdf08d3a2feccb3f86912acbc0) ·
[Uncompressed source hashes](SHA256SUMS)
