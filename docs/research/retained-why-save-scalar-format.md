# Selected save scalar conversions and their temporary sizes

2026-10-20 UTC, Linux x86_64, research #119 / #153, Round 29.

The selected serializer's normal scalar conversions have a conditional output
bound **d = 20 bytes**: signed integers need at most 20, plain `%g` at most 13,
and Booleans at most five. This discharges the arithmetic of these particular
normal conversions under the source/runtime and libc contracts below. It does
not establish continued service success, complete Format storage capacity or
whole-save capacity. The exported actual bound remains null until those named
conversion premises are joined.

The [packet](../evidence/retained-why-save-scalar-format-20261020/README.md)
retains source excerpts, 17 installed native bodies (3,408 bytes), three native
data constants, the published GNU libc conversion contract and a fail-closed
interface. It reuses the retained OCaml/Why sources and installed disassembly;
there is no new target execution, capture, solver, native proof or Lean run.

## Selected formats and derivation

`session_itp.ml:2021–2210` uses unpadded `%i`, `%d`, `%g`, `%b` and
`pp_print_int` for these scalar fields. Variable strings, restored identifier
paths, fixed labels and shape strings belong to their separate owners. There
is no caller-selected field width, precision, alternate form or grouping flag
in these scalar formats.

`CamlinternalFormat.default_float_precision` supplies -6 for `Float_g`;
`format_of_fconv` takes its absolute value and constructs **`%.6g`**, four
bytes, in a fresh buffer of capacity 16. Its index grows from zero to four and
never takes the resizing branch. This uses the explicit precision, irrespective
of how a libc implementation documents an omitted precision. The selected
`Float_g` branch does not take OCaml's `%F` conversion or append a decimal
point. `Int.to_string` uses `%d`; `Format.pp_print_int` delegates to it.

For a valid 64-bit OCaml tagged integer, the mathematical value lies in
`[-2^62, 2^62-1]`. Since `10^18 <= 2^62 < 10^19`, at most 19 decimal digits
and one minus sign are required. The installed integer formatter supplies the
signed value to libc with the native `l` length modifier, producing `%ld` or
`%li`; it does not compute the absolute value in the OCaml integer domain.
The minimum integer therefore has the same 20-byte bound.

For a finite nonzero binary64 number, the exact inequalities
`2^1024 < 10^309` and `2^1074 < 10^324` bound its decimal magnitude. After
six-significant-digit rounding, the decimal exponent remains within the loose
interval `[-325,309]`, including a one-place allowance for a rounding carry.
It therefore needs at most three exponent digits. The GNU `%g` contract selects
exponential form when that exponent is below -4 or at least six. Its length is
at most

```text
sign + first digit + decimal point + five remaining digits + e + sign + exponent
  1  +     1       +       1       +          5            + 1 +  1   +    3 = 13.
```

In fixed form the exponent is between -4 and five. The longest allowance is
one sign, `0.`, three leading fractional zeros and six significant digits:
12 bytes. Removal of trailing zeros can only shorten either form. Signed zero
also fits. The GNU libc contract renders infinity and NaN with `inf`/`nan`
and an optional sign, at most four bytes; this is a contract for the selected
GNU service, not the unrestricted ISO permission for payload-bearing NaN text
on other implementations. Thus 13 covers all binary64 bit patterns under that
service contract. Boolean literals are `true` or `false`, at most five bytes.

The unified `max(20,13,5) = 20` may be used in the previously reviewed
`1024*Q + 6*U + 32*Q*d` **formatter-input** expression only when its conversion
premises and the separate U, occurrence and continuation premises are supplied.
It is not a bound on final channel bytes, indentation or queue allocation.

## Installed route and normal temporary representations

The source versions remain OCaml `8eb41f72ded84df884c3671734c947f612091f84`
and Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`. The executable is the
already retained `gnatwhy3` with SHA256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
Every projected native instruction byte is checked against that ELF. Native
data checks also establish the `"C"`, `"l"` and `"%d"` constants at the selected
call sites. Source transfer uses the existing
[scoped external behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary);
these byte checks corroborate the route without claiming full binary refinement.

The installed `caml_format_float` calls `uselocale(caml_locale)`, then
`caml_alloc_sprintf`, then restores the prior locale. It has no
`HAS_BROKEN_PRINTF` special-value branch. The source initializes `caml_locale`
with `newlocale(LC_NUMERIC_MASK,"C",0)` at runtime startup and frees it during
runtime shutdown. A successful initialization and preserved locale object,
with successful selection for the conversion, supply the required single-byte
decimal point. The source definition alone does not prove those service outcomes
at every later call.

`parse_format` has a 32-byte local buffer. The two-character integer format
plus one-character suffix and terminator needs only four bytes, and passes its
strict length guard. `caml_alloc_sprintf` has a 128-byte local buffer; the
installed path calls fortified `__vsnprintf_chk` with that size. A successful
conversion returns `0 <= n <= 20`, fitting the first pass including its NUL.
The long branch, format duplication and second formatting call are then absent.
The OCaml result allocation uses `(n+8)/8` payload words on this platform:
at most three words, or 32 bytes including its header. This is a bound on one
returned string, not an aggregate allocator or stack-resource bound. The
four-byte floating format string and its 16-byte construction buffer are
separate small objects; closure and accumulator allocation are not counted here.

## Premises and remaining work

The interface requires four explicit premises: the selected typed formats and
source/native behavior relation; effective C numeric locale with a preserved
locale object; the GNU numeric conversion contract; and successful numeric
service/runtime allocation. The existing
[trusted boundary](../trusted-boundary.md#trusted-computing-base) covers ordinary
libc numerical and runtime service semantics. This packet derives the selected
representation extents; it does not replace them with a sufficient-memory claim.
The retained GNU manual documents are service specifications, not proof of an
exact historical libc build manifest.

An unsuccessful conversion must not be silently treated as a short successful
one. In the C source, the comparison `n < sizeof(buf)` converts a negative `n`
to unsigned; the installed branch also compares unsigned. A negative return
therefore enters the long branch, rather than satisfying the bound above.
Locale failure, a conversion error, allocation failure, pending callbacks,
exceptional unwinding and any repeated caller attempts retain their existing
error/continuation owners. This note neither certifies those paths nor assumes
that their names establish external resource exhaustion.

The packet deliberately leaves actual continued service/locale joins false.
Dropping any premise gives a null actual `scalar_bytes_upper`; complete
formatter/save/pipeline flags remain false even when all four are supplied.
Format counters, queues, breaks and indentation, aggregate allocation, libc
internal representations, channel offsets and error/exit effects remain separate.
No Oracle, installed tool/pin, admitted-language or production change is made.
