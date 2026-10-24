#!/usr/bin/env python3
"""Check only final excerpt additions, imported limits and frozen-prefix scope."""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile
import time
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]


def main():
    start=time.perf_counter();checks=[]
    def check(ok,name):
        if not ok:raise AssertionError(name)
        checks.append(name)
    sources=json.loads((HERE/'source-witnesses.json').read_text())
    for a in sources:
        with tarfile.open(ROOT/a['path']) as t:
            for f in a['files']:
                if not any(f['path']==n or f['path'].endswith('/'+n) for n in ('stdlib/list.ml','src/mlw/expr.ml')):continue
                raw=t.extractfile(f['path']).read();lines=raw.decode().splitlines()
                check(hashlib.sha256(raw).hexdigest()==f['sha256'],'supplemented complete source identity: '+f['path'])
                for s in f['spans']:
                    text='\n'.join(lines[s['first']-1:s['last']])+'\n'
                    check(text==s['source'] and hashlib.sha256(text.encode()).hexdigest()==s['sha256'],'supplemented source excerpt: '+f['path']+':'+str(s['first']))
    limits=json.loads((ROOT/'docs/evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json').read_text())
    witness=json.loads((HERE/'native-witnesses.json').read_text())
    check(limits['elf_identity']==witness['executable']['identity'],'same accepted native limit executable')
    code=bytes.fromhex(next(w['hex'] for w in limits['windows'] if w['meaning'].startswith('caml_sys_const_max_wosize')))
    check(code[:6]==bytes.fromhex('f30f1efa48b8') and code[-1:]==b'\xc3','accepted max-wosize instruction decoding')
    check((int.from_bytes(code[6:14],'little')-1)//2==limits['max_wosize']==2**54-1,'imported ordinary-header maximum')
    note='docs/research/retained-main-construction-demand.md'
    old=subprocess.check_output(['git','show','0d64f5f7d18b77632146174f1777be238cc43f60:'+note],cwd=ROOT)
    check((ROOT/note).read_bytes().startswith(old),'research continuation preserves accepted prefix')
    changed=subprocess.check_output(['git','diff','--name-only','0d64f5f7d18b77632146174f1777be238cc43f60'],cwd=ROOT).decode().splitlines()
    owned='docs/evidence/retained-main-construction-demand-20261024/shared-services/'
    check(all(n==note or n.startswith(owned) for n in changed),'earlier tracked packets unchanged')
    result={'status':'passed','checks':checks,'assertions':len(checks),'elapsed_seconds':time.perf_counter()-start,
            'source_native_previous_success_reused':True,'native_target_disassembler_compiler_prover_Lean_runs':0}
    (HERE/'final-checks.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__=='__main__':main()
