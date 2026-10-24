#!/usr/bin/env python3
"""Narrow R1 counterexample. This intentionally exercises the rejected premise."""
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'docs/evidence/retained-main-construction-demand-20261024'))
import bridge as b
from check import canonical, semantics
k = b.k
it = b.Ty('int')
x, v = k.Var(1, it), k.Var(2, it)
d = b.Demand(k.Ledger(100))
t = k.close('forall', (v,), k.node('app', k.var(x), k.var(v), symbol='R'), d.kernel)
raw_mapper = getattr(b, '_gen_map', b.gen_map)
m = raw_mapper(t, {x:v}, lambda ty:ty, lambda s:s, d)
result = {
    'input': repr(canonical(semantics(t))),
    'output': repr(canonical(semantics(m))),
    'stored_support_check_accepts': b.stored_closed(m),
    'outer_map_injective_and_type_compatible': True,
    'output_cache_retains_v': v in m.binding.free,
    'output_body_has_two_bound_occurrences': canonical(semantics(m))[-1][-1][0][0] == 'bound' and canonical(semantics(m))[-1][-1][1][0] == 'bound',
}
assert result['output_body_has_two_bound_occurrences']
assert result['stored_support_check_accepts'] and result['output_cache_retains_v']
print(json.dumps(result, indent=2))
