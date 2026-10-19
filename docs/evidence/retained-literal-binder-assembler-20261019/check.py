"""Focused checksum boundaries and retained-evidence rejection checks."""
import copy
import json
from pathlib import Path
import runpy
import time

HERE=Path(__file__).resolve().parent
api=runpy.run_path(str(HERE/'derive.py'))
start=time.perf_counter()
context=api['Context']('/tmp/silver-backend-compose-20261018/full-source',
                       '/tmp/silver-backend-compose-20261018/gas-source')
checks=0
def check(condition):
    global checks
    assert condition
    checks+=1
def rejected(call):
    try:call()
    except ValueError:check(True)
    else:raise AssertionError('invalid evidence accepted')

for value in [0,1,9,10,99,100,2**31-1,2**31,2**31+1,2**32-2,2**32-1]:
    result=api['numeric'](value)
    check(result['output_bytes']==4 and result['decimal_digits']<=10)
    check(len(result['directive'])<=19 and result['operand_recursion_depth']<=2)
for value in [-1,2**32,False,0.0,'0']:
    rejected(lambda value=value:api['numeric'](value))
for mutate in [lambda run:run['cases'][0]['commands'][0].update(exit=1),
               lambda run:run['cases'][1].update(checksum=1),
               lambda run:run['cases'][0]['commands'][0]['argv'].append('-g'),
               lambda run:run['cases'][0]['environment'].update(GCC_EXEC_PREFIX='/wrong')]:
    run=copy.deepcopy(context.run);mutate(run)
    rejected(lambda:api['replay'](context.artifacts,run))
check(context.result['assembly_bytes_upper']==31743)
check(context.result['conditional_binder_assembler_capacity'] is True)
check(context.result['complete_native_capacity'] is False)
result=dict(checks=checks,elapsed_seconds=time.perf_counter()-start,native_tool_executions=0)
(HERE/'checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
