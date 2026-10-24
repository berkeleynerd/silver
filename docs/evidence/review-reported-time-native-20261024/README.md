# Independent reported-time native audit

Exact target: `6cc4c72f63`, including Start kernel `b4c00b1c04` and #208
repair `aaac68339f`. The [report](../../reviews/review-reported-time-native-20261024.md)
states the accepted scope and source/native argument.

`audit.py` checks frozen author identities, retained native bodies and selected
instruction witnesses against the unchanged ELF read as data. It also checks
an independent persistent triplet-failure model, negative controls, color
partition and corrected allocation arithmetic. `result.json` is the one
successful receipt. No author/predecessor checker or target execution occurs.

The reviewer was the lead Codex agent; model/effort identity and token/cost
telemetry are unavailable. The source review and finite audit do not adopt
the parent configuration or complete #206/#119.
