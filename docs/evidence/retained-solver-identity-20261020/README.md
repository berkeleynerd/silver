# Static installed-solver and retained-launch inventory

Supports the [research note](../../research/retained-solver-identity.md) for
#119 / #153. The exact main-executable identities do not establish historical
bare-name resolution, source-to-binary refinement or a solver-output bound.

`inventory.json` records current native ELF identities, embedded strings and
candidate-source confidence. `package/` retains the installed local manifests,
configuration and Z3 version header (the two manifests are losslessly gzip
encoded); the manifest's tarball origin hash is a
declaration, without a new tarball fetch/check. `paths.json` is the actual
`scripts/dev.py paths` output from the shared installation checkout.

`inputs.json` pins exact predecessor files and selected archive members.
`source-witnesses.json` preserves the applicable configuration/resolution source
excerpts. `drivers.json` inventories both 14-file selected import closures and
the corrected private six-directive deletion. `launch.json` joins exact retained
five-case client/server argv/environment and base configs to raw records/plans,
and labels the owner-intended future configuration as unadopted. No predecessor
checker replay or old-packet mutation is required.

From repository root, verify retained joins and local document links:

```sh
python3 docs/evidence/retained-solver-identity-20261020/check.py
```

Also read/hash the installed files, with no binary execution:

```sh
python3 docs/evidence/retained-solver-identity-20261020/check.py --installed-root /home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef
```

`check-results.json` retains both actual outputs and command/input scope;
`round.json` distinguishes selected worker settings from unavailable runtime
confirmation, and records measured elapsed evidence. The checksum and join pass
does not prove the semantic arguments described in the note. Whole-binary bytes
are read from the explicitly named installation, rather than copied into this
packet. No solver/task run, source fetch, install, production configuration change
or GitHub mutation is performed by this subthread.
