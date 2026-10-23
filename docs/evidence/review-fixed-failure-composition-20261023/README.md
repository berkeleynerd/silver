# Fixed failure composition: independent review evidence

Review target: `62cb8175ab11041a8f8396eac699f722cb616675`.
See the [review](../../reviews/review-fixed-failure-composition-20261023.md)
for source/control reasoning, scope, premises and disposition.

The one focused run passed **1,368 checks in 6.839709618 seconds** on Linux
x86_64. No target, native inferior, disassembler or predecessor checker ran.
Previously accepted component/native/graph results were reused, not replayed.

- `check.py`: independent recipe, source, import-graph, path, native-byte and
  scalar/serializer join checks against immutable Git inputs.
- `check-attempt-1.log`, `result.json`: first successful run, complete inputs,
  check labels and supplemental native predicate-closure bytes.
- `author-freeze.json`: all 25 files introduced by the exact author commit,
  with byte lengths and SHA256 values.
- `round.json`: selected reviewer settings, observed interval, result and
  unavailable telemetry.

The predicate closure supplement reads sixteen immutable bytes at 0xb2e6a8
from the identified ELF. The retained Sysutil entry stores that closure at
offset 0xf0, and the retained resolver passes it to List.find_all. Its code field
is the exact is_file entry 0x55f4b0. This uses ordinary ELF bytes without a
disassembler or native execution.

The review accepts the fixed-process design's technical #153 interface and
the prospective #181 configuration repair. It retains the source/native,
physical-resource and once-only global-allowance premises. Uninstantiated
deployment fields are distinct from missing capacity arguments; #88 must
implement their declared relation. Arbitrary Main and full #119 consumers/
composition are outside this review. No production configuration was changed.
