# Server consume-copy native attachment

Supports the [bounded native bridge](../../research/retained-why-server-buffer-copy.md)
for #119 / #153. The installed server calls memcpy@GLIBC_2.14. For the exact
retained libc identity, its complete IFUNC resolver is equivalent to memmove's
resolver after checking PC-relative targets. The conditional interface uses
the existing trusted memmove service, with exact noninterposed library binding
and stable resolver data as explicit premises. Historical server library/GOT
observations remain null; generic C memcpy overlap remains unjustified.

`inputs.json` binds installed files and retained providers. `queries.json`
records eight successful read-only objdump/readelf commands, tool hashes and
retained output hashes. Symbol/dynamic/relocation outputs retain the stated
matching lines; their original complete stdout hashes are also recorded.
The four disassembly outputs retain complete queried bodies/PLT bytes.
`source-witnesses.json`, `normalized-resolvers.json` and `result.json` contain
the source join, exact comparison and explicit conditional scope.

```sh
python3 -B docs/evidence/retained-why-server-buffer-copy-20261020/check.py
```

The checker reads the exact installed server/libc files and retained packet.
On another host, `--server PATH --libc PATH` may name byte-identical copies.
It does not invoke objdump/readelf again or execute any target/resolver. It
checks ELF load bytes, symbol types, the native call and PLT branch, relocation
symbol index, and complete resolver instruction correspondence. The source
argument and external service assumptions remain subjects for review.

No target execution, new capture, debugger, source fetch, libc implementation
audit, solver or proof suite was used. `generation.json`, `check-run.json` and
`round.json` record focused validation and selected settings. Source/Oracle/
tools/admission were not modified; frozen predecessor packets remain intact.
