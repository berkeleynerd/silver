# Null-family SARIF and VSS storage

2026-10-18, Linux x86_64, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The null producer's empty diagnostic arrays do not remove SARIF generation:
`spark_report.adb:1576–1580` calls it unconditionally. This caller-specific
transfer covers the extra report's fixed descriptors, vectors, text storage
and output buffers. It does not replace the ordinary `.spark` reader and
command/configuration joins or complete whole-pipeline capacity. No compiler,
GNATprove, solver or Lean process ran.

## Source selection and external premise

The [evidence bundle](../evidence/retained-producer-sarif-capacity-20261018/README.md)
retains 33 complete source files. The SPARK caller is the existing candidate
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. Release recipe
`0334dd54a2c479faa3dfad47a911373581b11739` selects VSS text/extra tags
`v26.0.0`, currently resolving respectively to
`01c9adfef0efda9589fa544115628e28e26767b3` and
`a9d466d7d75c555676654b71a0d92e946ea4688d`.
Its SARIF source URL floats on `main`; the reviewed candidate
`4bc234ccccdd68813352c668a3c83ca82940f1b6` is the latest current-history commit
dated before the recorded release build. That date is **not** historical build
identity. The existing [external behavior premise](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
must cover these reached dependency paths too. Nothing here changes a tool pin.

## Fixed caller shape

`spark_report-generate_sarif_report.adb:63–113,169–182,288–337,409–448` builds
one run and one invocation. Each of the null report's `flow`, `proof` and
`warn_error` arrays is empty, so `Handle_Items` appends no result. The results
vector is explicitly non-null and empty. There are no locations, suppressions,
artifacts or JSON property bags. Iteration over the selected single object
directory and entity parsing retain the ordinary report reader's obligations.

The rule loop is unconditional:

| Enumeration family | Descriptors |
| --- | ---: |
| VC_Kind | 69 |
| Flow errors/checks/warnings together | 35 |
| Misc_Warning_Kind | 63 |
| Total | 167 |

The three Flow subtypes partition the nonempty tags
(`vc_kinds.ads:227–372`). Each VC/Flow descriptor has an id, short description
and full description; each Misc descriptor has only id/full description. The
source-derived maximum full-description lengths are 240, 72 and 258 bytes;
short-name maxima are 69, 77 and 39. VC/Flow ids are enumeration images of at
most 43 bytes. All are fixed ASCII text (`vc_kinds.adb:243–884,1645–1948`);
the evidence counts source enum members and string-literal branch lengths.
No source-program trivia or coordinate adds a SARIF result on this path.

Invocation fields are commandLine, endTimeUtc, exitCode and
executionSuccessful. The caller does **not** populate workingDirectory;
the directory strings in `Handle_Source_Dir` only support enumeration and
restoration. The tool descriptor additionally holds name `GNATProve`,
organization `AdaCore` and the selected build's version string.

## Vector lengths and individual record allocations

SARIF's generated vectors own positive-indexed arrays, with a Natural length.
They deep-copy their populated elements in `Adjust`; they do not share a
finite vector reference counter. The append capacity starts at
`max(2,256/Element'Size)` and subsequently becomes `floor(3*Length/2)`.
These record types each exceed 128 bits, so initial capacity is two
(`sarif-types.adb:1950–2000,2350–2405,2461–2522`).

The 167 rule appends reach capacity **211**, with largest evaluated
`3*Length=423`. Each copied rule vector has exactly 167 elements. Run and
invocation arrays each have capacity two and populated length one. The result
vector remains unallocated. Thus the length/index arithmetic fits signed32
without choosing a source-count limit.

For an independently reproducible selected-ABI byte envelope, charge **128
bytes** for each scalar, enum/optional-enum, virtual-string handle, vector
handle and empty Any_Object list. This is deliberately larger than the
selected LP64 layouts: Virtual_String contains the controlled base's four
referral pointers plus its UTF8 data record (manager, flags, size, address,
length); vector handles contain a controlled tag, access value and scalar
fields; Any_Object is an empty controlled doubly linked list. Their declarations
are retained, including `vss-implementation-referrers.ads:129–135`,
`vss-implementation-utf8_strings.ads:31–44`, `vss-strings.ads:473–480`,
`sarif-types.ads:3760–3768` and `a-cdlili.ads:282–288`. Selected field/tag
alignment is at most 16. No pointed-to array or string bytes are hidden in
this handle allowance; those allocations are charged separately.

Recursively sum every record field, including every inactive optional variant,
plus 16 bytes per record and another 16 for a discriminant. The checker expands
the reached declarations and rejects unrecognized leaf types. Because all
allowances are multiples of 16, this also overcharges inter-field padding.
With an additional 32 bytes for array bounds/alignment:

| Array | Element-size upper bound | Largest request upper bound |
| --- | ---: | ---: |
| reportingDescriptor | 4,368 bytes | 32 + 211*4,368 = **921,680 bytes** |
| invocation | 12,640 bytes | 32 + 2*12,640 = **25,312 bytes** |
| run | 44,256 bytes | 32 + 2*44,256 = **88,544 bytes** |

These are source/ABI upper bounds, not measured layouts or aggregate RAM
quotas. Simultaneous old/new arrays are separate individual requests. Default
empty nested vectors/property bags allocate no backing objects.

## Virtual strings and streaming output

Let P bound the generated project/output path lengths, C the joined command
line, V the selected version-string bytes and T the timestamp bytes. The exact
null invocation has 15 command-line elements with one variable project path;
`Build_Switches_String` adds fourteen separating spaces, giving `C<=181+P`
under that configuration (`spark_report.adb:213–226`). T is 20 for the
ordinary four-digit-year UTC picture at `:117–121`. Keep any enlarged
environment domain explicit. Set

```text
D = max(258, C, P, V, T).
```

The selected path/configuration strings must be valid UTF-8: this conversion
raises on invalid bytes, independently of length. The fixed descriptors are
ASCII. `To_Virtual_String` initializes storage for exactly the input byte
length, validates/copies it and appends one NUL; it does not repeatedly grow
these immutable values (`vss-strings-conversions.adb:300–314`;
`vss-implementation-utf8_strings-mutable_operations.adb:241–265,367–392`).

UTF8 byte counts are signed32 and character counts have maximum `2^30-1`.
Requiring `D<=2^30-1` suffices for character counting. Heap initialization
rounds capacity by
`((H+D)/A+1)*A-H`, where H is the empty shared-segment size and A the maximum
alignment. Consequently capacity is at most `D+A`, and the complete segment
request is conservatively at most `H+D+A+1`, including its terminator.
Require those intermediate additions/rounding to fit signed32, and the whole
request to fit the allocator/pointer domain
(`vss-implementation-text_storages-heap.adb:29–35,59–73,112–125`).
The selected LP64 header is at most 64 bytes; `A<=64` covers the x86
AVX/AVX512 alignment branches as well as the baseline ABI. With `V<=258`,
`T=20`, P=222 gives D=403 and a **532-byte** request bound; P=4096 gives
D=4277 and a **4406-byte** bound. These are substitutions of path/build
domains, not a new source limit.

Heap text uses the runtime unsigned32 atomic reference counter. Each heap
value is freshly initialized for one field. The only copies are constructor
results/aggregates, array growth, the tool/run assignment and Root's run copy;
output traverses constant references. The rule vector has twelve growth-copy
steps, and no copy is recursively placed under multiple populated child
fields. Charging two handles per growth step and two per each of at most
sixteen constructor/aggregate boundaries gives at most **56** references even
without taking credit for earlier finalization. This bounds this caller's
copies, not arbitrary users who retain additional SARIF trees.

The generated output visits only the above populated fields, with maximum
JSON nesting depth eight. `JSON_Simple_Push_Writer` has two stream pointers
and one punctuation Boolean, with no document buffer or growing nesting
stack (`vss-json-push_writers.ads:25–32`). Escaping traverses each immutable
string and writes one character at a time. Integer output uses a fixed
Integer_64 image and also writes characters separately
(`vss-json-push_writers.adb:206–449,552–624`).

Each file-stream character Put creates one short stream-element vector and
encodes at most four UTF-8 bytes. Even charging an optional first three-byte
BOM gives at most seven bytes, so the doubling vector reaches capacity at
most eight; this caller actually disables the BOM. Its two scalar header
fields plus eight data bytes fit a conservative 64-byte individual request
(`vss-text_streams-file_output.adb:134–181,252–271`;
`vss-strings-converters-encoders-utf8.adb:16–46`;
`vss-stream_element_vectors.adb:59–83`, `.ads:94–99`). The buffer is freed
after each Put. Number of file bytes is therefore not a contiguous memory
requirement or a stored whole-document counter. File creation separately
converts the output path to UTF-8 and appends its C terminator; that request
is bounded by `P+1` (`vss-text_streams-file_output.adb:44–70`).

This closes the selected SARIF container/text/output dimensions under the
stated input and external behavior premises. Directory enumeration, ordinary
report retention, configuration construction, libc/file-system behavior and
the other native toolchain joins remain separate. #119 is still incomplete.
