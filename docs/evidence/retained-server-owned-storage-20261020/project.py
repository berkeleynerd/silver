#!/usr/bin/env python3
"""New stock-owner projection, without running retained predecessor checks."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ARCHIVE = ROOT/'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
R53 = ROOT/'docs/evidence/retained-why-parallel-residual-transfer-20261020'
CASES = ['put_line','put','first_or_default','is_message','input_is_valid']
C_FILES = ['arraylist.c','logging.c','options.c','proc.c','queue.c','readbuf.c','request.c','server-unix.c','writebuf.c']
ALLOCATION_PATTERN = r'\b(malloc|calloc|realloc|strdup|getcwd|fopen)\s*\('
CALLER_PATTERN = r'\b(init_list|list_resize|init_queue|resize_queue|init_readbuf|resize_readbuf|init_writebuf|server_accept_client|server_init_listening|add_to_poll_list|open_temp_file|run_request|remove_from_queue|send_started_msg_to_client|send_msg_to_client|queue_write|push_write_data|free_request|free_process|close_client)\s*\('
ML_PATTERN = r'\b(set_max_running_provers|set_session_max_tasks|connect_external)\b|parallel;'

# Complete allocation-call-site classification of the selected C translation
# units. This is correspondence material; the reviewed note proves reachability
# and owner-count statements.
OWNERS = {
'arraylist.c': {22:'list control',25:'list key backing',26:'list pointer backing',72:'list key resize; unreachable under fixed owners',73:'list pointer resize; unreachable under fixed owners'},
'logging.c': {21:'server logging FILE; excluded by fixed argv (not Why --logging)'},
'proc.c': {}, 'options.c': {},
'queue.c': {21:'request/temporary/response queue control',25:'queue backing; R55 ring term',49:'queue resize; R55 ring term'},
'readbuf.c': {21:'client readbuf control',24:'receive backing; R56 term',29:'receive resize; R56 term'},
'request.c': {49:'copied field; R56 cumulative parser term',85:'interrupt record; R56 cumulative parser term',109:'run record; R56 cumulative parser term',122:'argument array; R56 cumulative parser term'},
'server-unix.c': {89:'current_dir; libc getcwd service allocation operand',95:'poll resize; unreachable under fixed owners',136:'raw output-path C+12',154:'client control',250:'socket pathname copy; libc strdup service allocation operand',251:'socket pathname copy; libc strdup service allocation operand',267:'poll array',328:'parent exec argv; R56 term once',421:'S response buffer; R55 term',450:'F response buffer; R55 term',527:'process record; ID transferred'},
'writebuf.c': {18:'client writebuf control'},
}

def read_json(p): return json.loads(p.read_bytes())
def identity(b): return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}

def queue_capacity(c,n):
    assert c > 0 and n >= 0
    while c < n: c *= 2
    return c

def source_inventory():
    out = {'allocation_sites':[], 'caller_sites':[], 'ML_MLI_files':[], 'selected_C_members':[]}
    with tarfile.open(ARCHIVE) as t:
        for f in C_FILES:
            member='why3/src/server/'+f
            raw=t.extractfile(member).read(); lines=raw.decode().splitlines()
            found={i:line for i,line in enumerate(lines,1) if re.search(ALLOCATION_PATTERN,line)}
            assert set(found) == set(OWNERS[f]), (f, found)
            out['selected_C_members'].append({'member':member,'identity':identity(raw)})
            for i,line in found.items():
                out['allocation_sites'].append({'member':member,'line':i,'text':line,'owner':OWNERS[f][i]})
            for i,line in enumerate(lines,1):
                if re.search(CALLER_PATTERN,line):out['caller_sites'].append({'member':member,'line':i,'text':line})
        for m in t.getmembers():
            if not m.isfile() or not m.name.endswith(('.ml','.mli')): continue
            raw=t.extractfile(m).read()
            hits=[{'line':i,'text':line} for i,line in enumerate(raw.decode().splitlines(),1) if re.search(ML_PATTERN,line)]
            out['ML_MLI_files'].append({'member':m.name,'identity':identity(raw),'hits':hits})
    return out

def elf_symbols(raw):
    assert raw[:6] == b'\x7fELF\x02\x01' and struct.unpack_from('<H',raw,18)[0] == 62
    off=struct.unpack_from('<Q',raw,40)[0]; size,n,_=struct.unpack_from('<HHH',raw,58)
    sections=[struct.unpack_from('<IIQQQQIIQQ',raw,off+i*size) for i in range(n)]
    out={'source_file_symbols':[], 'dynamic_imports':[]}
    for sh in sections:
        if sh[1] not in (2,11):continue
        st=sections[sh[6]];strings=raw[st[4]:st[4]+st[5]]
        for off in range(sh[4],sh[4]+sh[5],sh[9]):
            name,info,_,index,_,_=struct.unpack_from('<IBBHQQ',raw,off)
            name=strings[name:strings.find(b'\0',name)].decode()
            if sh[1]==2 and info&15==4:out['source_file_symbols'].append(name)
            if sh[1]==11 and index==0 and name:out['dynamic_imports'].append(name)
    return out

def project():
    protocol=read_json(ROOT/'docs/evidence/retained-adapter-protocol-storage-20261020/result.json')
    request=read_json(ROOT/'docs/evidence/retained-server-request-storage-20261020/result.json')
    counts={r['case']:r for r in protocol['cases']}
    assert list(counts)==CASES
    assert request['request_record_bytes']==56 and request['argv_element_bytes']==8
    historical=[]
    for case in CASES:
        with tarfile.open(R53/(case.replace('_','-')+'-capture.tar.gz')) as t:
            server=json.load(t.extractfile(case+'/capture/server.json'))
            process=json.load(t.extractfile(case+'/capture/process.json'))
        argv=server['actual_argv']
        assert argv==server['argv'] and argv[1:]==['--socket','server.sock','--single-client','-j','12']
        assert server['binary']=={'bytes':96904,'sha256':'143e182d167d3e290c974770d0b84b5f59cf70bf331de5208a36bd650b386a80'}
        socket=process['argv'][process['argv'].index('--socket')+1]
        historical.append({'domain':case,'server_pid':server['pid'],'server_argv':argv,'client_socket_argument':socket,'socket_argument_bytes':len(argv[2]),'captured_getcwd':None,'simultaneous_five_server_capture_claimed':False})
    assert len({r['server_pid'] for r in historical})==5
    assert len({r['client_socket_argument'] for r in historical})==5
    J=12
    total=sum(counts[c]['run_entries'] for c in CASES)
    sizes={'client':24,'readbuf':24,'writebuf':32,'queue':24,'list':24,'process':24,'pollfd':8,'list_key':4,'pointer':8}
    topologies={}
    for name,partition in [('prospective_shared',[CASES]),('historical_singletons',[[c] for c in CASES])]:
        servers=[]
        for domains in partition:
            n=sum(counts[c]['run_entries'] for c in domains); c=len(domains)
            assert c<=J and c+2<=J+2
            q=queue_capacity(100,n)
            controls=2*24+2*(4+8)*J+8*(J+2)+2*24
            servers.append({'domains':domains,'J':J,'attempts':n,'accepted_connections_upper':c,'poll_entries_upper':c+2,'client_list_capacity':J,'process_list_capacity':J,'poll_capacity':J+2,'list_or_poll_resize_entries':0,'request_ring_capacity':q,'fixed_controls_and_list_poll_backing_bytes':controls,'request_queue_controls_peak':2,'temporary_request_queue_constructions_upper':n+c,'process_record_cumulative_bytes':24*n,'process_record_live_bytes_upper':24*min(J,n),'output_path_cumulative_bytes':f'{n}*(C_s+12)','output_path_live_bytes_upper':f'{min(J,n)}*(C_s+12)','getcwd_service_calls':1,'current_dir_payload_bytes':'C_s+1','strdup_service_calls':2,'socket_copy_payload_bytes':'2*(S_s+1)'})
        response=[queue_capacity(J,2*counts[c]['run_entries']) for c in CASES]
        ring=2*8*(2*sum(s['request_ring_capacity'] for s in servers)+sum(response))
        fixed=sum(s['fixed_controls_and_list_poll_backing_bytes'] for s in servers)+104*len(CASES)
        topologies[name]={'partition':partition,'servers':servers,'server_count':len(servers),'client_control_bytes':104*len(CASES),'per_client_controls':{'client':24,'readbuf':24,'writebuf':32,'response_queue':24},'fixed_new_control_bytes':fixed,'response_ring_capacities':response,'ring_old_new_backing_bytes':ring,'process_record_cumulative_bytes':24*total,'process_record_live_bytes_upper':sum(s['process_record_live_bytes_upper'] for s in servers),'direct_new_control_and_process_bytes':fixed+24*total,'socket_copy_payload_for_S_11':24*len(servers),'getcwd_service_calls':len(servers),'strdup_service_calls':2*len(servers)}
    assert topologies['prospective_shared']['ring_old_new_backing_bytes']==protocol['ring_old_new_backing_bytes_J12']==41536
    assert topologies['prospective_shared']['fixed_new_control_bytes']==1016
    response_constant=sum(counts[c]['run_entries']*(2*counts[c]['positive_ID_digits']+35) for c in CASES)
    assert response_constant==18579 and protocol['backend_SF_allocated_bytes']=='459*P_b+18579'
    return {'scope':'selected direct stock C allocation/storage families under fixed intact-owner interface; library service allocations separate','native_sizes':sizes,'historical_capture_topology':historical,'topologies':topologies,'selected_parallel_control_lines':0,'total_run_entries':total,'backend_response_allocated_C_coefficient':459,'backend_response_allocated_C_constant':23628,'imported_terms_once':{'parsed_requests':request['parsed_request_bytes'],'parent_exec_argv':request['parent_exec_argv_bytes'],'receive_backing':'sum_d 2*R(M_d)','response_allocated_buffers':'sum_d N_d*(C_server(d)+11+2*d_d+35)'},'shared_direct_allocation_bound':'sum_d N_d*(L_d+8*m_d)+57714 + 8*sum_d N_d*(m_d+2) + sum_d 2*R(M_d) + 41536 + sum_d N_d*(C+11+2*d_d+35) + 1016 + 459*(C+36)','known_library_owned_payload_only':{'shared_current_dir':'C+1','shared_socket_copies':'2*(S+1)'},'remaining_library_allocation_summands':['G_getcwd(C) once per server, including returned capacity and call temporaries','2*D_strdup(S) per server, including both returned copies and call temporaries','bounded-call library/stdio formatting/error/exit/getopt/native-service storage, with selected library/source correspondence','allocator metadata, retained arenas, size-class rounding and fragmentation for all charged object families'],'remaining_distinct_owners':['stock executable/shared-library mappings, loader/runtime baseline and stack/signal-stack envelope','kernel socket buffers/FD tables/listeners/self-pipes and filesystem metadata','raw solver/output files (at most one newly created path per run, contents unbounded here)','child/fork/COW/exec/solver/adapter physical memory','proxy/control/canonical/log/history SPARK representation and refinement','Why3-side allocations and captured-single-client to prospective-shared-endpoint successful-prefix transfer'],'no_new_request_ID_copy':True,'no_new_send_buffer_copy':True,'source_semantics_machine_proved':False,'complete_q':None,'production_adopted':False}

if __name__=='__main__':print(json.dumps(project(),indent=2,sort_keys=True))
