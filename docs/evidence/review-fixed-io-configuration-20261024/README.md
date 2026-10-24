# Independent IO and native-configuration audit

This evidence accompanies the
[scoped review](../../reviews/review-fixed-io-configuration-20261024.md) of IO
author `0f39a36c1458f7af4f216fce3f9bcde8d8aab123` and native-configuration
author `9bb63660fd9e29c7b67b359f00acd844f19771cc`.

`audit.py` verifies the exact two original inputs and attached source manifests,
separately sums the IO constructor/emitter rows, checks report arithmetic and
the useful interval boundary, and attaches the selected native code/data using
ELF PT_LOAD mappings. It follows the reporter's PLT/GOT/dynamic relocation to
getpagesize. It imports accepted provider functions and the accepted ELF symbol
parser, without executing any author/predecessor checker or querying libc.

```
python3 docs/evidence/review-fixed-io-configuration-20261024/audit.py
```

The current retained GCC source directory and exact installed ELFs named by
the author inputs are required. `result.json` records the one successful run;
the later spelling normalization of `gnat2why_owner_attachment` changes no
calculation. Manual source/instruction review establishes the conditional
reachability and behavioral argument; arithmetic evaluations are corroboration.
This evidence does not supply actual common P, physical resources, GNAT2Why
owner attachment or complete #212/#119 composition.
