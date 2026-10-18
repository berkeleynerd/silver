# Retained GNATprove source identity

**2026-10-18, Linux x86_64 — focused source-identity investigation for
[#119](https://github.com/berkeleynerd/silver/issues/119).** Base integration
commit: `4b30b466d6b913c6bcc3bb1c63b9bc5e53595caf`.

The surviving records establish the selected release archive, recipe commit and
matching Linux build/upload job. **They do not establish the exact SPARK source
revision consumed by that build.** The inspected revision remains a concrete
candidate; the producer capacity derivations retain their source-to-installed-tool
premise. This investigation does not select another tool, modify a pin, rebuild
the distribution or amend admission.

## Established release and build route

The [retained responses and verifier](../evidence/retained-tool-source-identity-20261018/README.md)
extend the earlier [toolchain research](frontend-toolchain-feasibility.md#gnatprove-has-its-own-frontend).
The repository owner is **`alire-project`**, verified both in the previous raw
evidence and current release/build records.

| Record | Identity and result |
| --- | --- |
| Alire selection | Installed `alire.toml` selects `gnatprove-x86_64-linux-16.1.0-1.tar.gz`, SHA-256 `82528bef29857e239373fcc36732837d743f5a00805d502c70455422ffc97191`. |
| Release | [`gnatprove-16.1.0-1`](https://github.com/alire-project/GNAT-FSF-builds/releases/tag/gnatprove-16.1.0-1), release ID `345417954`; Linux x86_64 asset ID `458798534`, 472,919,963 bytes. Its GitHub asset digest equals the Alire manifest's expected digest. |
| Recipe | The release tag resolves to `0334dd54a2c479faa3dfad47a911373581b11739`, matching the earlier retained tag. |
| Build | [Run `28247767502`](https://github.com/alire-project/GNAT-FSF-builds/actions/runs/28247767502), `workflow_dispatch`, at that recipe commit. |
| Linux job | [`84010188140`, SPARK (ubuntu-22.04)](https://github.com/alire-project/GNAT-FSF-builds/actions/runs/28247767502/job/84010188140), successful. SPARK build: 2026-06-26 15:45:48–16:30:33 UTC; packaging: 16:30:33–16:34:55; release step: 16:34:55–16:35:15. |
| Upload reconciliation | Asset creation/update at 16:34:58/16:35:14 both fall inside that successful release step. This corroborates the matching upload route; it is not an embedded source manifest. |
| Current SPARK candidate | `AdaCore/spark2014` branch `fsf-16` still resolves to inspected `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. The commit date is 2026-01-05, before the June build. |

The fixed recipe's source blob identities were checked against its Git tree.
`specs/spark2014.anod` retrieves GCC's named 16.1.0 release, but retrieves SPARK
and sparklib through `https://github.com/adacore/{spark2014,sparklib}/tarball/fsf-16`.
Those two inputs are branch URLs, with no selected commit or expected source
archive digest in the recipe.

`Common.HTTPSSourceBuilder` is an unmanaged HTTPS source builder with no VCS
checkout. `FSFBuildDownloadSource` downloads into its cache and maintains a local
SHA-1 sidecar; the source installation removes the archive's root directory while
unpacking. The inspected download helper does not promote the resolved branch
revision into a shipped source manifest. The fingerprint branch that records
`new_commit` applies to VCS checkout actions, not this unmanaged download.

The recipe copies the GCC Ada tree into `gnat2why/gnat_src`, changes `comperr.adb`'s
bug-report text, replaces `SPARK2014_Static_Version_String` with `FSF 16.1.0`, and
runs `all-nightly`. Packaging merges the installation and emits a binary tarball
and its SHA-256 file. The release helper uploads those two files. The release's
ten listed assets are the five platform binaries and their checksums; GitHub's
automatically generated source archive is the **recipe repository**, not a record
of the downloaded SPARK tree.

## Records that do not close the remaining link

The Linux job-log endpoint returned **HTTP 410** on 2026-10-18. The run's artifact
listing returned **zero artifacts**. Its workflow uploads the binary release
packages with a five-day retention period; it does not select the source cache
or source fingerprints for that upload. These are the observed available records,
not a claim that no upstream copy could exist elsewhere.

The installed `gnatprove` and `gnat2why` binaries contain DWARF5 line tables:
395 and 510 respectively. Every inspected file-entry format contains a path and
directory index; none contains a source checksum, timestamp or source-size field.
A bounded byte scan found no standalone 40-hex-character ASCII sequence in either
binary. This rules out those particular metadata routes, not every possible
encoding or a source-level relation obtainable by a different investigation.
The evidence records their hashes to identify the inspected files; it does not
claim a binary attestation or a reconstructed build.

The original 472 MB binary archive was not downloaded or independently unpacked
in this pass. The release/manifest equality above concerns the selected archive
identity, and the metadata inspection concerns the existing installation. No
claim of fresh archive-to-installation verification is made.

The candidate commit predating the build and today's branch still naming it are
consistent with that candidate having been used. They do not record the branch's
resolved target or tarball bytes at the build's download time. Current branch
protection likewise does not establish historical branch resolution. Treating
these dates as an exact build input would reintroduce the unsupported identity
claim this task was intended to resolve.

## Exact residual obligation

The missing link is the **SPARK tarball bytes or resolved revision actually
consumed by the matching June 26 Linux build**, together with the applicable
post-download modifications. A retained build input manifest, the downloaded
source archive/cache digest with a trustworthy association to that job, or
equivalent upstream release records could establish it. The recipe and binary
asset hash alone cannot supply the missing value. The same floating selection
also leaves sparklib's build revision unidentified; its relevance must be assessed
where those library sources enter the capacity/assurance argument.

Until that link is established, the inspected SPARK source can support explicitly
conditional producer bounds, not an assertion that those bounds have been tied
to this installed producer. Keep this obligation visible in #119 before using the
new rule to enlarge admission. This focused investigation does not prescribe a
tool change or authorize maintainer contact, a new pin, or a rebuilding project.

Validation comprised read-only upstream GET requests, retained-record and Git-blob
reconciliation, the narrow installed metadata inspection, local links and authored
whitespace. No compiler, GNATprove proof run, Lean build or test suite ran. No tool
installation, production file, issue, board entry, harness goal or GitHub state
was changed.
