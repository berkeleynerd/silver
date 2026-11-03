# Bounded String and Character development evidence

This packet retains successful focused Linux observations for
[#296](https://github.com/berkeleynerd/silver/issues/296). Complete native compiler
proof/audit, complete Lean/source assurance, final regression coverage and
independent delivery review are still outstanding. The
[capability record](../../bounded-string-characters.md) governs the current scope.

| Packet | Exact scope |
| --- | --- |
| [Discovery archive](string-discovery.tar.gz), [index](string-discovery.json) | Run `20261031T162539-96d0ba9159be`: 14 pinned frontend/prover cases, nine build/proof successes and five expected frontend rejections. Includes all printable Character literals, actual/noncanonical/null bounds and dead-code acceptance boundaries. |
| [Stress/driver archive](string-stress.tar.gz), [index](string-stress.json) | Run `20261031T165409-9c2dd4f813bc` at native implementation `9c4afd3c5b`: eight exact cases with admission, application/runtime proof, strict Python/native report audits, build, exact execution and unchanged author-source hashes. Includes the three prepared Rosetta drivers, 4,096-byte dense inputs and 64-leaf boundaries. |

Each gzip-compressed tar contains its original summary and every input/artifact
named in that summary, retaining the original relative paths. The JSON indexes
bind all original bytes and each archive by SHA-256; all original file hashes
were rechecked when exported. No validation was rerun to make these archives.
The summaries preserve expected failures and the earlier stress wrapper's
preanalysis failure reference. Native run logs and the managed history remain
under the repository's shared Git run registry.

These results apply to their recorded inputs and native host. They are neither
universal assurance nor a completed final compiler/feature checkpoint. The
[producer account](../../bounded-string-characters-report-capacity.md) keeps the
source-derived reasoning separate from these finite observations.
