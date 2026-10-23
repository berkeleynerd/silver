#!/usr/bin/env python3
"""Author-only archive/pin preparation; validation never refreshes these pins."""
import hashlib
import io
import json
import pathlib
import tarfile

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
RUNTIME = HERE/'gnat-runtime-sources.tar.gz'
INSTALLED = pathlib.Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude')
NAMES = ['a-elchha.adb', 'a-elchha.ads', 'a-except.ads', 'a-except.adb',
         'a-exexda.adb', 'a-exextr.adb', 's-stalib.ads', 's-stalib.adb',
         's-soflin.ads', 's-soflin.adb', 's-parame.ads', 's-exctra.adb',
         'a-excach.adb', 's-trasym.adb']
C_NAMES = ['arraylist.c', 'logging.c', 'options.c', 'proc.c', 'queue.c',
           'readbuf.c', 'request.c', 'server-unix.c', 'writebuf.c']

def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def dump(name, value):
    (HERE/name).write_text(json.dumps(value, indent=2, sort_keys=True)+'\n')

runtime_inputs = []
with tarfile.open(RUNTIME, 'w:gz') as out:
    for name in NAMES:
        data = (INSTALLED/name).read_bytes()
        info = tarfile.TarInfo('adainclude/'+name)
        info.size, info.mode, info.mtime = len(data), 0o644, 0
        out.addfile(info, io.BytesIO(data))
        runtime_inputs.append({'installed_path': str(INSTALLED/name),
                               'member': info.name, 'identity': identity(data)})
dump('runtime-inputs.json', {'role': 'Installed GNAT16.1 source inputs; future binding is a refinement obligation, not an observed link.',
                            'source_members': runtime_inputs})
providers = [WHY, str(RUNTIME.relative_to(ROOT)), 'oracle.md', 'docs/trusted-boundary.md', 'silver.gpr']
providers += ['docs/research/'+n+'.md' for n in [
    'retained-current-protocol-join', 'retained-adapter-launch-output',
    'retained-adapter-outcome-interface', 'retained-solver-response-adapter',
    'retained-solver-output-relevance', 'retained-tool-source-identity',
    'retained-solver-launch-profile', 'retained-shared-server-prefix',
    'retained-adapter-protocol-storage']]
providers += ['docs/evidence/'+p+'/'+n for p, ns in {
    'retained-current-protocol-join-20261023': ['result.json'],
    'retained-adapter-launch-output-20261020': ['result.json', 'inputs.json'],
    'retained-adapter-protocol-storage-20261020': ['result.json']}.items() for n in ns]
dump('inputs.json', {p: identity((ROOT/p).read_bytes()) for p in providers})

# Find complete named bodies/sections, then freeze their exact strict spans.
# End=None means the complete actual member end; it is not clipped input.
selections = {
    'server-unix.c': [('void shutdown_with_msg(char* msg) {', 'char* get_cur_dir()'),
                     ('int open_temp_file(', 'void server_accept_client()'),
                     ('void sigterm_handler(', '/* Returns the size'),
                     ('void server_init_listening(', 'void queue_write('),
                     ('pid_t create_process(', 'void write_to_client('),
                     ('void run_request (', 'void handle_queue_remove('),
                     ('int main(', None)],
    'a-elchha.adb': [('with System.Standard_Library;', None)],
    'a-elchha.ads': [('procedure Ada.Exceptions.Last_Chance_Handler', None)],
    'a-except.ads': [('   Exception_Msg_Max_Length :', '   -- Exception_Id --'),
                     ('   Max_Tracebacks :', '   function "=" (Left, Right : Exception_Occurrence)')],
    'a-except.adb': [('   procedure To_Stderr (C : Character) is', None)],
    'a-exexda.adb': [('separate (Ada.Exceptions)', None)],
    'a-exextr.adb': [('with Ada.Unchecked_Conversion;', None)],
    's-stalib.ads': [('   type Exception_Data is record', None)],
    's-stalib.adb': [('package body System.Standard_Library is', None)],
    's-soflin.ads': [('   Task_Termination_Handler :', '   function  Get_Jmpbuf_Address_NT')],
    's-soflin.adb': [('   procedure Adafinal_NT is', '   -- Check_Abort_Status_NT --'),
                     ('   procedure Task_Termination_NT (Excep : EO) is', '   -- Task_Unlock_NT --')],
    's-parame.ads': [('   Default_Exception_Msg_Max_Length :', None)],
    's-exctra.adb': [('   procedure Set_Trace_Decorator (', None)],
    'a-excach.adb': [('separate (Ada.Exceptions)', None)],
    's-trasym.adb': [('   Exception_Tracebacks_Symbolic :', None)]}
rows = []
for ar, members in [(WHY, ['why3/src/server/'+n for n in C_NAMES]),
                    (str(RUNTIME.relative_to(ROOT)), ['adainclude/'+n for n in NAMES])]:
    with tarfile.open(ROOT/ar) as t:
        for name in members:
            data = t.extractfile(name).read()
            source = data.decode()
            lines = source.splitlines(keepends=True)
            spans = []
            for start, end in selections.get(pathlib.Path(name).name, [(None, None)]):
                if start is None:
                    lo = 1
                else:
                    assert start in source, (name, 'missing start', start)
                    lo = source[:source.index(start)].count('\n')+1
                if end is None:
                    hi = len(lines)
                else:
                    start_byte = sum(map(len, lines[:lo-1]))
                    assert end in source[start_byte+1:], (name, 'missing end', end)
                    hi = source[:source.index(end, start_byte+1)].count('\n')
                assert 1 <= lo <= hi <= len(lines), (name, lo, hi, len(lines))
                spans.append({'start': lo, 'end': hi,
                              'identity': identity(''.join(lines[lo-1:hi]).encode())})
            rows.append({'archive': ar, 'member': name, 'identity': identity(data), 'ranges': spans})
dump('source-ranges.json', rows)
print({'providers': len(providers), 'members': len(rows), 'ranges': sum(len(r['ranges']) for r in rows)})
