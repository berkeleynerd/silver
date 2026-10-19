#!/usr/bin/env python3
"""Focused #140 correspondence repair; no accepted suite/aggregate execution."""
import ast
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import runpy
import time

HERE=Path(__file__).resolve().parent
m=runpy.run_path(str(HERE/'derive.py'))
start=time.perf_counter(); started=datetime.now(timezone.utc).isoformat()
manifest=m['read'](HERE/'inputs.json')
path=m['E']/'retained-literal-pipeline-20261018/compose.py'
raw=path.read_bytes(); checked=[]


def reject(name,source,fragment):
    try:
        m['validated_core_module'](source,manifest)
    except ValueError as error:
        assert fragment in str(error),(name,str(error))
        checked.append(name)
    else:
        raise AssertionError('accepted '+name)


selected=m['validated_core_module'](raw,manifest)
assert [n.name for n in selected.body[1:]]==list(manifest['accepted_function_ASTs'])
for node in selected.body[1:]:
    assert m['identity'](ast.dump(node,include_attributes=False).encode())==manifest['accepted_function_ASTs'][node.name]
checked.append('compiled module contains exact validated function nodes')
scope={}; exec(compile(selected,str(path),'exec'),scope)
assert (scope['I32'],scope['I64'])==(2**31-1,2**63-1)
checked.append('exact validated width node executed')
for name in manifest['accepted_function_ASTs']:
    duplicate=('\ndef '+name+'(*args, **kwargs):\n    return {"unreviewed": True}\n').encode()
    reject(name+' appended duplicate',raw+duplicate,'unique accepted function')
    reject(name+' prepended duplicate',duplicate+raw,'unique accepted function')
    tree=ast.parse(raw)
    node=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name==name)
    node.body=[ast.Return(value=ast.Constant(value=None))]
    reject(name+' changed sole definition',ast.unparse(tree),'changed accepted function')
    duplicate=('\nasync def '+name+'(*args, **kwargs):\n    return None\n').encode()
    reject(name+' async shadow',raw+duplicate,'unique accepted function')
reject('ambiguous width assignment',raw+b'\nI32, I64 = 1, 2\n','unique accepted native widths')
tree=ast.parse(raw);tree.body=[n for n in tree.body if not (isinstance(n,ast.FunctionDef) and n.name=='native_graph_lifetime')]
reject('missing accepted function',ast.unparse(tree),'unique accepted function')
context=m['Context']('/tmp/silver-backend-compose-20261018/full-source')
result=m['evaluate_source']((m['REPO']/'samples/hello_world.adb').read_bytes(),
    context.default_shared,context.default_correction,context)
assert result==m['read'](HERE/'result.json')
checked.append('current source-bound Hello result unchanged')
out=dict(checks=len(checked),passed=checked,started_utc=started,
    completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-start,
    implementation_inputs={n:m['identity']((HERE/n).read_bytes()) for n in
        ['derive.py','check-ast-repair.py','inputs.json','result.json']},
    original_40_check_record='Historical result at 1fc7ee7bcf; unchanged and not rerun.',
    native_tool_executions=0,aggregate_Context_instantiations=0,accepted_suites_rerun=False,
    model_effort='Lead live setting unavailable; no switch claimed',token_cost_measurements=None)
(HERE/'ast-repair-results.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:out[k] for k in ['checks','elapsed_seconds','native_tool_executions']}))
