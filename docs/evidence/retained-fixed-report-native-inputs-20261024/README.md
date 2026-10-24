# Selected report-tool native configuration inputs

2026-10-24, #212 under #119. This small provider attaches the installed
GNATprove parent and spark_report version/path fields, and the selected
reporter's page-size service. It changes no tool, launcher, language or Oracle.
Independent review is pending at this author freeze. The complete common-path
domain and fixed-report composition remain open.

## Export and source relation

For the two exact installed ELF identities in [inputs.json](inputs.json), the
reported version is the ten ASCII bytes `FSF 16.1.0`, and the selected native
`__gnat_max_path_len` export is 4096. The reporter's mmap page-size operation
calls the external C service `getpagesize`; on the recorded Linux x86_64 host
that service returns 4096. These supply `version_bytes=10`, `max_path=4096`
and `page_size=4096` at these specified owners. They meet R86's native service
conditions without substituting an illustrative 258-byte version string or
an unmeasured page-size constant. No actual P is supplied here.

`spark_report.adb:1257` uses SPARK2014_Version_String in its header;
`spark_report-generate_sarif_report.adb:434` uses it for the SARIF driver
version. The retained source body returns its static version constant. The
retained source specification says `0.0w`, which is **not** the installed
build's string. This packet therefore binds the actual selected function
instead of claiming historical source identity or copying that source literal.
The existing relevant-behavior trust boundary is unchanged.

Both installed version functions are straight-line 66-byte x86_64 functions.
They request 20 bytes at alignment four from the existing secondary-stack
allocator, store a two-Integer descriptor with bounds 1 and 10, store the eight
bytes `FSF 16.1` and then the two bytes `.0`, and return the data/descriptor
pair. There is no input-dependent branch, loop or concatenation. Allocation
sufficiency retains the ordinary resource premise; failure is not successful
reporting. The static string symbol occupies 16 bytes due to padding, so its
symbol size must not be mistaken for the returned String length. The exact
instruction bytes and decoded bounds are in [result.json](result.json).

The source `gcc/ada/adaint.c:370–376` exports the selected platform's maximum
path length as a runtime scalar. The inspected source defines no setter for
that export. The already retained `s-os_lib.adb:2057–2059` imports it, and the
selected normalization code uses it for its buffer sizes and cwd query. Both
installed parent/reporter definitions contain the signed32 value 4096. This
is the ordinary fixed runtime-export relation already required by the parser
interface, not a theorem about arbitrary foreign writes or another executable.
The source-to-service behavior and valid ordinary runtime state remain trusted.
No separate inference from the host's shell PATH_MAX was made.

The retained GNATCOLL Unix mmap source's Get_Page_Size (`:272–277`) imports
`getpagesize` and converts its Integer result to File_Size. The selected native
wrapper calls that exact dynamic import, rejects a negative result, and zero
extends the ordinary nonnegative result. The checker resolves the call through
its PLT jump, GOT relocation and dynamic symbol table; it does not infer the
import solely from an objdump label. It queries the same declared C service in
the current host process and records its positive value. Selected ordinary
loader/libc/OS behavior and a stable host configuration remain the existing
service premises. This observation is not a bound for another host or runtime,
nor a proof about arbitrary interposition. No libc/OS internals proof is added.

The result is configuration-specific: changing the executable or host requires
rebinding these operands. It does not establish GNAT2Why's separate parser
owners by silently transferring these ELF identities. Paths, warning location
chains, other owners and the complete five-report join remain explicit work.

## Evidence and limits

The [new checker](check.py) passed once in 1.354635 seconds. It checks the two
complete target hashes; decodes both returned String descriptors and native
path scalars; resolves the reporter's page-size import; binds seven complete
source files and four accepted repository inputs; and makes one libc service
query. No target binary, compiler, prover, Lean, author/predecessor checker or
existing successful capacity audit was executed. It is native data/code
inspection plus a configuration observation, not a new proof run.

An exploratory extraction initially reused the old ELF reader's address lookup
unchanged. GNATprove's large debug section also covered the numeric address
range, so that lookup correctly refused ambiguity. This packet reuses the
reader's section/symbol parsing but selects mapped SHF_ALLOC sections in its
own lookup. The accepted predecessor file is unchanged. One corrected exploratory
extraction preceded the single final checker run; it was not a repeated
successful capacity validation. Earlier nm/objdump exploration and its one
libc query are retained separately in session scratch; they are not counted
as this checker's one service query.

The author is the lead; its live model/effort and token/cost telemetry are not
exposed. No additional subagent was launched for this bounded provider. The
final check's elapsed time is measured; total exploratory time is unavailable.
An independent Astra / Extra High review is requested before acceptance.
The single global e<=2/two save-entering callbacks/three saves allowance and
physical-resource premises are unchanged. #212/#119 remain unfinished,
production #88–#94 remains unstarted and PR #121 remains draft/unmerged.
