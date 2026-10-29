from pathlib import Path
import json,subprocess,time,shutil,sys
base=Path(__file__).resolve().parent; inputs=base/'inputs'; binary=Path(sys.argv[1]); results=[]
for name,kind,diagnostic in [('runtime_range_error','VC_RANGE_CHECK',b'range check failed'),('runtime_overflow','VC_OVERFLOW_CHECK',b'overflow check failed')]:
    work=base/'work'/name;shutil.copytree(inputs/'template',work,dirs_exist_ok=True);shutil.copyfile(inputs/(name+'.adb'),work/'main.adb')
    project=work/'program.gpr';project.write_text(project.read_text().replace('"-gnato"','"-gnato", "-gnatdM"'))
    row={'name':name,'commands':[]}
    def run(label,cmd):
        start=time.monotonic();p=subprocess.run(cmd,cwd=work,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180)
        (work/(label+'.log')).write_bytes(p.stdout)
        row['commands'].append({'label':label,'command':cmd,'exit':p.returncode,'seconds':time.monotonic()-start,'output':p.stdout.decode(errors='replace')})
        return p
    admission=run('admission',[str(binary),'check',str((work/'main.adb').resolve())]);assert admission.returncode==2,admission.stdout
    build=run('build',['gprbuild','-P','program.gpr','-p','-q']);assert build.returncode==0,build.stdout
    execute=run('execute',[str((work/'bin/main').resolve())]);assert execute.returncode!=0 and b'CONSTRAINT_ERROR' in execute.stdout and diagnostic in execute.stdout,execute.stdout
    prove=run('prove',['gnatprove','-P','program.gpr','-U','--mode=all','--report=all','--warnings=continue','--checks-as-errors=on','--level=2','--prover=cvc5,z3,altergo','--steps=100000','--timeout=0','--memlimit=1000','-j0','--no-loop-unrolling'])
    reports=list((work/'obj/gnatprove').glob('main*.spark'));assert len(reports)==1,reports
    proof=json.loads(reports[0].read_text())['proof'];bad=[p for p in proof if p.get('rule')==kind and p.get('severity')!='info'];assert bad,proof
    row['unproved_checks']=bad;results.append(row);(base/'results.json').write_text(json.dumps(results,indent=2)+'\n');print(name,'Silver rejects; native runtime check retained; proof obligation unproved',flush=True)
