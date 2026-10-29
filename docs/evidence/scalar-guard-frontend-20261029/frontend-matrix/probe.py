from pathlib import Path
import json,subprocess,time,sys,shutil,os
base=Path(__file__).resolve().parent; inputs=base/'inputs'; binary=Path(sys.argv[1]); results=[]
print('gprbuild:',shutil.which('gprbuild'),flush=True)
for name in json.loads((inputs/'cases.json').read_text()):
    source=inputs/(name+'.adb')
    check=subprocess.run([str(binary),'check',str(source)],capture_output=True)
    row={'name':name,'admission_exit':check.returncode,'builds':{}}
    for mode,extra in [('baseline',[]),('no_current_value',['-cargs','-gnatdM'])]:
        work=base/'work'/mode/name;shutil.copytree(inputs/'template',work,dirs_exist_ok=True);shutil.copyfile(source,work/'main.adb')
        cmd=['gprbuild','-P',str(work/'program.gpr'),'-c','-u','main.adb','-p','-q',*extra]
        begin=time.monotonic();p=subprocess.run(cmd,cwd=work,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        (work/'build.log').write_bytes(p.stdout)
        row['builds'][mode]={'returncode':p.returncode,'seconds':time.monotonic()-begin,'command':cmd,'diagnostic':p.stdout.decode(errors='replace')}
    results.append(row);(base/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(name,'check',check.returncode,'baseline',row['builds']['baseline']['returncode'],'no-current',row['builds']['no_current_value']['returncode'],flush=True)
