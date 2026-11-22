from pathlib import Path
import hashlib,json,re,subprocess,sys
root=Path(sys.argv[1]).resolve()
base=Path(__file__).resolve().parent
sys.path.insert(0,str(root))
from scripts.platforms import native_layout
from scripts.check_evidence import audit_reports
host=native_layout(root)
compiler=host.compiler/'bin/silver'
records=[]
for package in ['Standard','GNAT']:
    folder=base/package.lower()
    folder.mkdir(exist_ok=True)
    originals={}
    for old,new in [('counter.ads',package.lower()+'.ads'),('counter.adb',package.lower()+'.adb'),('main.adb','main.adb')]:
        data=(root/'samples/package_counter'/old).read_bytes().replace(b'Counter',package.encode())
        (folder/new).write_bytes(data)
        originals[new]=data
    record={'package':package,'source_sha256':{name:hashlib.sha256(data).hexdigest() for name,data in originals.items()},'phases':[]}
    for phase in ['check','compile']:
        command=[str(compiler),phase,str(folder/'main.adb')]
        result=subprocess.run(command,cwd=root,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=360)
        record['phases'].append({'phase':phase,'command':command,'returncode':result.returncode,'output':result.stdout})
        if result.returncode==0 and phase=='compile':
            matched=re.search(r'^Executable: (.+)$',result.stdout,re.M)
            assert matched,result.stdout
            executable=Path(matched.group(1))
            if not executable.is_absolute(): executable=root/executable
            workspace=executable.parent.parent
            record['workspace']=str(workspace)
            for name,data in originals.items(): assert (workspace/name).read_bytes()==data,name
            reports=list(workspace.rglob('gnatprove.sarif'))
            assert len(reports)==1,reports
            metadata={'name':package,'functions':('Read',),'procedures':{'Reset':(),'Increment':()},'formals':{'Reset':(),'Increment':(),'Read':()},'states':('Value',),'writes':{'Reset':('Value',),'Increment':('Value',)},'assigned':True}
            record['audit']=audit_reports(reports[0].parent,{'main',package.lower(),'silver_io','silver_output_libc','silver_arguments','silver_runtime'},{'silver_output_libc','silver_runtime'},application_kind='assigned',indexed_main=True,application_package=metadata,indexed_packages=True)
            execution=subprocess.run([str(executable)],capture_output=True,timeout=10)
            record['execution']={'returncode':execution.returncode,'stdout':execution.stdout.decode(),'stderr':execution.stderr.decode()}
            assert execution.returncode==0 and execution.stdout==b' 9\n' and execution.stderr==b''
        print(json.dumps({'package':package,**record['phases'][-1]}),flush=True)
    assert all((folder/name).read_bytes()==data for name,data in originals.items())
    records.append(record)
    (base/'result.json').write_text(json.dumps(records,indent=2)+'\n')
print(json.dumps(records,indent=2))
