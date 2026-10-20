#!/usr/bin/env python3
"""New selected-library owner projection; no target or predecessor execution."""
from pathlib import Path
import json
import struct

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
INT_MAX=2**31-1
PTRDIFF_MAX=2**63-1
DIR_MAX=1048576+48
C_MAX=INT_MAX-45
SERVER=Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/why3server')

class ELF:
    def __init__(self,raw):
        self.raw=raw
        h=struct.unpack_from('<16sHHIQQQIHHHHHH',raw)
        assert h[0][:6]==b'\x7fELF\x02\x01' and h[2]==62
        self.segments=[struct.unpack_from('<IIQQQQQQ',raw,h[5]+i*h[9]) for i in range(h[10])]
        self.section_list=[struct.unpack_from('<IIQQQQIIQQ',raw,h[6]+i*h[11]) for i in range(h[12])]
        names=self.slice(self.section_list[h[13]])
        self.sections={self.string(names,s[0]):s for s in self.section_list}
    @staticmethod
    def string(raw,off):return raw[off:raw.index(b'\0',off)].decode()
    def slice(self,s):return self.raw[s[4]:s[4]+s[5]]
    def read(self,va,n):
        s=next(s for s in self.segments if s[0]==1 and s[3]<=va and va+n<=s[3]+s[5])
        off=s[2]+va-s[3];return self.raw[off:off+n]
    def symbols(self):
        s=self.sections['.dynsym'];names=self.slice(self.section_list[s[6]]);raw=self.slice(s);out=[]
        for i in range(s[5]//s[9]):
            name,info,_,section,va,size=struct.unpack_from('<IBBHQQ',raw,i*s[9])
            out.append({'index':i,'name':self.string(names,name),'type':info&15,'section':section,'va':va,'size':size})
        return out
    def needed_versions(self):
        s=self.sections['.gnu.version_r'];raw=self.slice(s);names=self.slice(self.section_list[s[6]]);off=0;out={}
        while True:
            version,count,file,aux,nxt=struct.unpack_from('<HHIII',raw,off)
            assert version==1
            pos=off+aux
            for _ in range(count):
                _,_,other,name,anext=struct.unpack_from('<IHHII',raw,pos)
                out[other&0x7fff]={'library':self.string(names,file),'version':self.string(names,name)}
                pos+=anext
            if not nxt:break
            off+=nxt
        return out

def server_chains(raw):
    e=ELF(raw);out=[];syms=e.symbols();versions=e.needed_versions()
    for site,expected,target in [(0x3a88,'getcwd',0x2500),(0x3fde,'strdup',0x2700),(0x3fe9,'strdup',0x2700)]:
        call=e.read(site,5);assert call[0]==0xe8
        plt=site+5+int.from_bytes(call[1:],'little',signed=True);assert plt==target
        b=e.read(plt+4,6);assert b[:2]==b'\xff\x25'
        got=plt+10+int.from_bytes(b[2:],'little',signed=True)
        rel=e.slice(e.sections['.rela.plt'])
        matches=[struct.unpack_from('<QQq',rel,i) for i in range(0,len(rel),24) if struct.unpack_from('<Q',rel,i)[0]==got]
        assert len(matches)==1
        _,info,addend=matches[0];assert info&0xffffffff==7 and addend==0
        symbol=syms[info>>32];assert symbol['name']==expected and symbol['section']==0
        version=struct.unpack_from('<H',e.slice(e.sections['.gnu.version']),2*symbol['index'])[0]&0x7fff
        attachment=versions[version];assert attachment=={'library':'libc.so.6','version':'GLIBC_2.2.5'}
        out.append({'callsite':site,'call_hex':call.hex(),'PLT':plt,'PLT_hex':e.read(plt,16).hex(),'GOT':got,'undefined_symbol':expected,**attachment})
    return out

def bounds(c,s,p=INT_MAX):
    assert 1<=c<=C_MAX and 0<=s<PTRDIFF_MAX and 4096<=p<=INT_MAX
    b=max(4096,2*c)
    peak=max(p+c+1,2*b+DIR_MAX)
    returned=max(p,b)
    cumulative=p+2*b+c+1+(c//2)*DIR_MAX
    return {'C':c,'S':s,'P':p,'B':b,'directory_constructions_upper':c//2,'getcwd_peak':peak,'getcwd_cumulative':cumulative,'getcwd_retained':returned,'two_strdup_peak_and_cumulative':2*(s+1),'three_calls_tighter_peak':max(peak,returned+2*(s+1)),'three_calls_additive_peak':peak+2*(s+1),'three_calls_cumulative':cumulative+2*(s+1)}

def generic_trace(names,p=4096,shrink_succeeds=False):
    # This finite executable model challenges the reviewed recurrence; it is
    # not a proof of C, directory semantics, malloc or realloc.
    a=4096;used=1;requests=[p,a];peak=max(p,a);path_requests=[a]
    h=len(names)
    for n in names:
        assert 1<=n<=4095
        if a-used<=n:
            new=a+max(a,n);requests.append(new);path_requests.append(new)
            peak=max(peak,a+new+DIR_MAX);a=new
        used+=n+1
        assert used<=a
        requests.append(DIR_MAX);peak=max(peak,a+DIR_MAX)
    if not names:used=2
    if used<a:
        requests.append(used);peak=max(peak,a+used)
        if shrink_succeeds:a=used
    c=used-1
    return {'C':c,'H':h,'peak':peak,'cumulative':sum(requests),'retained':a,'path_request_sum':sum(path_requests)}

def project():
    return {'scope':'selected getcwd/strdup requested objects only; successful ordinary service, component guard and exact noninterposed library attachment','server_call_chains':server_chains(SERVER.read_bytes()),'libc_sha256':'85e64f97e348786a8fb4d9f3d52fec289e2fb86bba20f0731dfe61990525e0f7','source_package':'glibc 2.43-2ubuntu2.4','initial_path_bound_without_page_observation':INT_MAX,'generic_initial_path':4096,'DIR_record_bytes':48,'DIR_backing_min':32768,'DIR_backing_max':1048576,'DIR_request_max':DIR_MAX,'getcwd_calls_per_server':1,'strdup_calls_per_server':2,'formulas':{'B(C)':'max(4096,2*C)','G_peak(C,P)':'max(P+C+1,2*B(C)+1048624)','G_cumulative(C,P)':'P+2*B(C)+C+1+floor(C/2)*1048624','G_return(C,P)':'max(P,B(C))','D_strdup(S)':'S+1','R57_addition':'G_peak(C,P)+2*(S+1)','tighter_three_call_peak':'max(G_peak(C,P),G_return(C,P)+2*(S+1))'},'guards':{'C_min':1,'C_max_from_R57':C_MAX,'S_max':PTRDIFF_MAX-1,'PTRDIFF_MAX':PTRDIFF_MAX,'P_min':4096,'P_max':INT_MAX,'ancestor_component_max':4095},'unguarded_growth_counterexample':{'capacity':4096,'used':4096,'next_component':4096,'new_capacity':8192,'needed':8193},'examples':[bounds(c,11,p) for p in (4096,INT_MAX) for c in (1,64,4095,4096,1000000,C_MAX)],'historical_loaded_libc':None,'historical_page_size':None,'selected_runtime_IFUNC_targets':None,'source_semantics_machine_proved':False,'allocator_physical_bound':None,'aggregate_RAM_gate_required':False,'complete_q':None,'production_adopted':False}

if __name__=='__main__':print(json.dumps(project(),indent=2,sort_keys=True))
