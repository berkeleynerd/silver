# Matching native build after Body_Tail repair

Managed Linux x86-64 build `20261031T022612-eb8a9047980e` passed in **8.565982 s**
(managed run wall time)
with four workers on source commit `f5ab46cdeff361c8072e089c0ae52619e70aba2a`.
All 143 tracked native inputs matched that commit before launch. All **2,561
captured input hashes** still matched at completion.

This is the normal `scripts/dev.py build --jobs 4` command. It rebuilt
`silver_output_profile.adb`, bound and linked `silver`; the image adapter was
already current. It follows the [focused Body_Tail pass](../body-tail-native-repair/README.md)
on the same exact source SHA-256
`bb3bd71eb53e7f0637ed27ac4b5eb7c283b66dc0fb81131ebe73543c3950d01f`.

| Binary | Bytes | SHA-256 |
| --- | ---: | --- |
| `silver` | 2,588,552 | `69006d784a7fa256c3a7bd78db22a9003e9053b199c97b8c6a82e3bbe31cb506` |
| `silver_image_adapter` | 2,018,344 | `524f344475f1bb636826214b1f2113d0cf9e03839be65a05c8f389681b1ffcfc` |

The launch, terminal journal, log, source snapshot manifest and binary/input
verification are retained here. The subsequent
[complete native proof/audit](../full-native/README.md) passed on the same exact
inputs. Final source/pin/certificate and regression checkpoints remain separate.
