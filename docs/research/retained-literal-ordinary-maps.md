# Selected ordinary source-map preallocation

Research #119, Linux x86_64, 2026-10-18. The selected gigi source preallocation
requires at most **three GGC backing requests**, each at most **131,072 bytes**,
for the frontend's upper bound of 1,589 permanent source entries. It adds no
finalizer. This closes the preallocation slice under the existing logical-line
and ABI premises; it does not establish that no later consumer adds an ordinary
map, and is not yet attached to the aggregate.

The [offline packet](../evidence/retained-literal-ordinary-maps-20261018/README.md)
retains exact source identities and the arithmetic. No native target, build,
solver or proof run is used. Complete capacity remains unestablished.

`back_end.adb:124–131` gives gigi the logical last-line number, through
`Physical_To_Logical`, for each permanent source entry. The accepted frontend
physical-source checks exclude Source_Reference and logical-line tables; the
virtual copies share their template's line arrays. Thus the attachment must
bind **logical** last-line bounds to the accepted physical/template bounds,
including the fixed runtime census. A physical line count alone is insufficient
for an arbitrary source containing Source_Reference. Required per-file bounds
are `1 <= L <= 2^24`; at most 1,589 files is the selected frontend interface,
not a new source-language restriction.

`misc.cc:377` sets `default_range_bits` to zero. `linemap_init` initially has
zero ordinary maps, depth zero and highest location one. Each gigi iteration
(`trans.cc:346–363`) enters a file at logical line one, calls
`linemap_line_start(L,252)`, encodes column 251, and leaves the outermost file.
At entry the map has one line and no allocated column bits. `linemap_line_start`
selects eight column bits for hint 252. Its reuse test succeeds: line delta is
nonnegative, the last line is the starting line, source column is zero, and
`L-1 < 2^(32-8)`. Range bits remain zero. It therefore modifies that same map
instead of allocating an LC_RENAME map. Column 251 is below the resulting
256-column hint, so the column call allocates nothing. LC_LEAVE of the outermost
file returns before map allocation and restores depth zero. Induction gives
exactly one ordinary map per source entry and preserves the file/map order
isomorphism that gigi checks. No imported/source filename allocation is counted
again here.

After a file with L lines the highest location increases by `256L-4`.
The conservative endpoint `1+256*1589*2^24 = 6,824,703,033,345` is below
`LINE_MAP_MAX_LOCATION_WITH_PACKED_RANGES = 0x50000000 << 31`, and hence below
the later column/ordinary-map limits. This validates the nonoverflow and
eight-column-bit branches throughout the selected preallocation. The bound
does not rely on diagnostics silently dropping locations after overflow.

For the selected 64-bit ABI, `line_map_ordinary` has size 32: an eight-byte
base, four bytes of flags/bitfields, a four-byte line number, an eight-byte
included-from location and an eight-byte pointer. The pinned header records
the same size. `line_map_new_raw` (`line-map.cc:471–520`) starts at 128 slots,
raises the candidate to at least used+1, doubles it, rounds the byte request
through `ggc_round_alloc_size`, then divides by the map size. The selected
rounding inputs are all at least 8,192; `ggc-page.cc:1292–1326,1884–1886`
therefore uses the ordinary power-of-two orders, not the small-size lookup.

| Maps already used | Before rounding | Caller/rounded bytes | Resulting slots |
| --- | --- | --- | --- |
| 0 | 8,192 | 8,192 | 256 |
| 256 | 16,448 | 32,768 | 1,024 |
| 1,024 | 65,600 | 131,072 | 4,096 |

The next growth is beyond 1,589 entries. All size/index products fit the
selected size_t and uint64 interfaces. `toplev.cc:1145–1149` installs the GGC
reallocator; `ggc-common.cc:163–203` issues at most one `ggc_internal_alloc`
per call, with no finalizer. The global line-table control, its ordinary
ad-hoc hash, source filenames, combined-location backing and later warning
backing retain their existing owners. Old backing deallocation earns no
negative event credit.

Remaining integration must bind the same frontend populations, no-logical-map
premises, actual Main and virtual-template line bounds; preserve inherited
guards; and keep this three-event slice disjoint from the shared partial
ledger. Whole-lifetime ordinary-map writer closure and collector accounting
remain explicit. This note supplies no complete native total or admission rule.
