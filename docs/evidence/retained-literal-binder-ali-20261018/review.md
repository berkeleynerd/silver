# Literal ALI consumer integration review

2026-10-18, Linux x86_64, research [#119](https://github.com/berkeleynerd/silver/issues/119).

Accepted within the stated local-consumer scope, with no unresolved material
finding. This is an independent parent review of worker implementations
`f57e42a53ab911ccbd497359af58af30536e3fef` and
`9295f3fbba5f5d0cd0212d5a7b4b775f598d380b`, integrated as `6685a96df1` and
`6de8f8608d`. It is not acceptance of complete binder or pipeline capacity.

## Inputs and checks

Reviewed the [argument](../../research/retained-literal-binder-ali.md), callable,
fourteen-case checker, fixed-closure census and retained consumer sources.
The reviewed callable SHA-256 is
`c58355d3a1184627cbe3fd5ed38ca594f1df0f633b544031241b21ead9c8c2ed`;
the input manifest is
`425589a21d7741e9f188367d61861e18c56b9f1c82675ba5569e72a02526821b`.
The callable checked twelve dependency identities and all 151 members of the
consumer source capsule. The five local native source files inspected directly
also matched their archived counterparts byte-for-byte.

- Native `Get_Name`/`Get_File_Name`, unit/dependency parsing and invocation
  parsing support the additive event counts. A signature reads three names;
  a relation reads its extra name plus two signatures, hence seven events.
  The case-sensitive filename premise excludes a second casing lookup.
- The accepted writer frontier and fixed closure give at most 180 units,
  2,220 with records, 833 argument strings, 1,048 dependencies, 1,290 distinct
  signatures and 367 relations. Signature deduplication is separate from the
  name-lookup event count. Fixed table allocations are retained even for empty
  native auxiliary tables.
- `Sig_Map` uses expansion threshold 1.5 and factor 2. Its 500 buckets grow
  after insertion 751, and 1,290 nodes do not reach the next threshold. Rehash
  moves data nodes while old and new dummy-head arrays coexist. The conservative
  64-byte component bound covers the five-field signature, value and two links.
- `gnatbind` and `Read_Withed_ALIs` free each raw ALI buffer before dependency
  recursion. The no-alias and coherent-input premises therefore justify the
  maximum individual-buffer bound; the cumulative 2,807,946 bytes is separately
  labelled and is not an aggregate RAM gate.
- Gprbind's `Read_Lines => "A"` still reads U and V. The retained GPR parser
  maps `GNAT Lib v16` to the seven-byte `GNAT 16` name, and uses lazy dynamic
  tables. Its 84 name events and 24,381 Value bytes are separate from native
  Namet's 16,611 events and 10,229,999 character slots. Neither exports a
  completed incoming-pool/backing calculation.

The focused replay passed all fourteen cases in 0.580123283 seconds and
byte-matched retained `check-results.json`, SHA-256
`6037207a0903baed3fa81f0c9b0767a1f781dcc5c3a1d8b1c9142a0dc4ba0743`.
A default-Hello replay took 0.417722177 seconds and byte-matched `result.json`,
SHA-256 `16f58c7dc6aaf9f047af5d67e6d56c375bda11f8a54e402cf0da67c8c305ec2b`.
No native tool, solver, proof audit or full test suite ran.

## Disposition and limits

Parent review requested explicit separation of Gprbind's A/U-only read from
native parent GPRbuild's D/W parser. The second worker commit makes that existing
scope boundary explicit in prose, output fields and checks; it changes no bound.
The D/W reader, complete name pools, graph backing, driver and output launch
remain open. The separate 5,000-call linker sufficient-bound failure is preserved.

The first parent replay correctly rejected an uncommitted, review-link-only
addition to its pinned predecessor argument. That addition was removed, keeping
the historical dependency byte-identical; no pin or mathematical condition was
weakened. The successful replays above used the frozen implementation inputs.

Reviewer: parent agent, independent of the implementation worker. Its live
model/effort is not exposed and no model switch is claimed; the implementation
worker was selected as GPT-6 Astra / Extra High. Source/replay inspection was
approximately 18:47–18:51 UTC (four minutes), excluding report writing. Token
and monetary measurements are unavailable. These observations do not establish
a model-quality comparison.
