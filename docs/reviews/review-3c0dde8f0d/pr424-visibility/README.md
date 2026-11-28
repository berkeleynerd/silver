# Exact-source package-name admission controls

2026-11-27, Linux x86-64. These small diagnostic runs independently confirm two admission defects in draft PR #424 at `3c0dde8f0d816493024198bf65488bfa86147c94`. They are not a complete compiler proof, application proof, regression checkpoint, or final delivery review.

The lead built `inputs/admission_probe.adb` against the frozen integration checkout's actual `src/` and generated inputs, using the pinned toolchain and a separate object/executable directory. The older November 22 `silver` executable was not used. The harness calls the actual `Silver_Application_Units.Pack`, `Silver_Output_Profile.Analyze` and `Imported_Package`; no alternate parser or reimplemented admission rule is involved. The driver discovery results and complete bundle admission results are both printed.

- Managed build: `20261127T170048-cc9610a8bc18`, two workers. Source configuration and fixture bytes were captured as inputs; outputs stay under this directory.
- Managed execution/frontend comparison: `20261127T170125-bf3cfba89910`, one worker, observed affinity guest CPU 0, 16 MiB stack. The child frontend uses `-j1`; the managed affinity is inherited. Both runs respect the host's eight-CPU allocation.
- Frontend command: pinned `gnatmake -c -u -gnat2022 -gnata -gnato -gnatdM`, with the original case files and actual Silver library specifications. This checks frontend acceptance; it does not link or execute the example programs.

| Case | Actual analyzer | Pinned frontend |
| --- | --- | --- |
| Package `Put_Line`, bare runtime call under `use Silver_IO` | Accepted | Rejected at Main: `procedure or entry name expected` |
| Same package, qualified `Silver_IO.Put_Line` | Accepted | Passed |
| Package `True` | Accepted | Specification rejected: name conflicts with declaration in package Standard |
| Package `False` | Accepted | Specification rejected: name conflicts with declaration in package Standard |

The first failure is omitted Ada hiding for a legal package identity. The other two fail at the package declaration itself; treating them merely as Boolean-literal hiding would misdiagnose the repair. Other Standard names were not probed here. The repair must establish the package-identity rule, not assume the two observed names exhaust it.

[results.json](outputs/results.json) retains exact frontend commands, exit statuses and diagnostics. [cases.json](inputs/cases.json) and the adjacent case directories retain the original source bytes. The managed ledger retains commands, tool identities, input digests and logs under `.git/silver-runs/linux-x86_64/78cde64c3e47f2cb/runs/` at the IDs above. No tracked source or GitHub object was modified.
