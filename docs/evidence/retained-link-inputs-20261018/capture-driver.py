"""Capture driver-only fixed link route; no compiler/linker execution."""
from pathlib import Path
import hashlib,json,shlex,subprocess,time
root=Path(__file__).resolve().parent
capture=root/'capture';capture.mkdir()
(capture/'temp').mkdir()
case=Path('/tmp/silver-native-option-probe-20261018/null-proposed')
raw=(case/'build.stdout').read_bytes()
lines=raw.decode().split('\n')
line=next(s for s in lines if '/bin/gcc main.o b__main.o ' in s)
argv=shlex.split(line)
tool=Path(argv[0]).parent.parent
runtime=tool/'lib/gcc/x86_64-pc-linux-gnu/16.1.0'
env={'PATH':str(tool/'bin')+':/usr/bin:/bin','LC_ALL':'C','LANG':'C','TERM':'dumb','TMPDIR':str(capture/'temp'),'ADA_INCLUDE_PATH':str(runtime/'adainclude'),'ADA_OBJECTS_PATH':str(runtime/'adalib')}
commands=[]
start=time.monotonic()
for label,command in [('link-expansion',[argv[0],'-###',*argv[1:]])]+[(name,[argv[0],'-print-file-name='+name]) for name in ['Scrt1.o','crti.o','crtbeginS.o','crtendS.o','crtn.o','libgcc.a','libgcc_eh.a','libatomic.so','libdl.a','libc.so']]:
 r=subprocess.run(command,cwd=case/'obj',env=env,capture_output=True)
 (capture/(label+'.stdout')).write_bytes(r.stdout);(capture/(label+'.stderr')).write_bytes(r.stderr)
 commands.append({'label':label,'argv':command,'cwd':str(case/'obj'),'returncode':r.returncode})
 r.check_returncode()
result={'method':'GCC driver-only -### and -print-file-name queries; no frontend/as/ld','source_build_log':str(case/'build.stdout'),'source_build_log_sha256':hashlib.sha256(raw).hexdigest(),'source_link_argv':argv,'environment':env,'commands':commands,'duration_seconds':time.monotonic()-start}
(capture/'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'driver_queries':len(commands),'duration_seconds':result['duration_seconds']}))
