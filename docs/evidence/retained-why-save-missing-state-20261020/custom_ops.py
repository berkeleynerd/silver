"""Recognize only the retained Zarith custom operations relocation.

The first custom payload word is a native operations pointer. Every later byte
is compared exactly. No arbitrary opaque pointer or custom type is normalized.
"""
import hashlib
import json
from pathlib import Path
import struct

HERE=Path(__file__).resolve().parent
E=HERE.parent
OPS_SYMBOL='ml_z_custom_ops'
OPS_VALUE=0xfa9e20
OPS_HEX='79019f0000000000000000000000000040bc9a000000000070bb9a0000000000f0b99a0000000000a0b79a000000000040bc9a00000000000000000000000000'
INIT_HEX='f30f1efa4883ec08488d3df11c5f00e85c4b0200b8010000004883c408c3'


def identity(path):
    h=hashlib.sha256();size=0
    with path.open('rb') as f:
        for data in iter(lambda:f.read(1<<20),b''):h.update(data);size+=len(data)
    return {'bytes':size,'sha256':h.hexdigest()}


def elf_witness(binary):
    raw=binary.read_bytes();h=struct.unpack_from('<16sHHIQQQIHHHHHH',raw)
    assert h[0][:6]==b'\x7fELF\x02\x01'
    sections=[struct.unpack_from('<IIQQQQIIQQ',raw,h[6]+i*h[11]) for i in range(h[12])]
    wanted={'ml_z_custom_ops','ml_z_init','ml_z_custom_compare','ml_z_custom_hash','ml_z_custom_serialize','ml_z_custom_deserialize','caml_register_custom_operations'}
    symbols={}
    def read_address(address,size):
        sec,=[s for s in sections if s[1]!=8 and s[3]<=address and address+size<=s[3]+s[5]]
        pos=sec[4]+address-sec[3];return raw[pos:pos+size]
    for section in sections:
        if section[1]!=2:continue
        st=sections[section[6]];names=raw[st[4]:st[4]+st[5]]
        for i in range(0,section[5],section[9]):
            n,_,_,index,address,size=struct.unpack_from('<IBBHQQ',raw,section[4]+i)
            name=names[n:names.index(0,n)].decode()
            if name in wanted:symbols[name]={'elf_value':address,'size':size}
    assert set(symbols)==wanted
    ops=symbols[OPS_SYMBOL];init=symbols['ml_z_init']
    assert (ops['elf_value'],ops['size'])==(OPS_VALUE,64)
    ops_raw=read_address(ops['elf_value'],64);assert ops_raw.hex()==OPS_HEX
    values=struct.unpack('<8Q',ops_raw)
    assert read_address(values[0],3)==b'_z\0'
    assert values[1]==values[7]==0
    for n,name in [(2,'ml_z_custom_compare'),(3,'ml_z_custom_hash'),(4,'ml_z_custom_serialize'),(5,'ml_z_custom_deserialize'),(6,'ml_z_custom_compare')]:
        assert values[n]==symbols[name]['elf_value']
    init_raw=read_address(init['elf_value'],init['size']);assert init_raw.hex()==INIT_HEX
    assert init_raw[8:11]==b'\x48\x8d\x3d'
    assert init['elf_value']+15+struct.unpack_from('<i',init_raw,11)[0]==ops['elf_value']
    assert init_raw[15]==0xe8
    assert init['elf_value']+20+struct.unpack_from('<i',init_raw,16)[0]==symbols['caml_register_custom_operations']['elf_value']
    return {'symbols':symbols,'ops_table_hex':OPS_HEX,'identifier_hex':'5f7a00','init_hex':INIT_HEX}


def load_bias(capture,plan):
    path=capture/'session-symbols.json'
    if path.exists():
        record=json.loads(path.read_text());addresses={k:v['address'] for k,v in record['checks'].items()}
    else:
        path=capture/'session-observer.json';record=json.loads(path.read_text());addresses=record['symbols']
    bias=record['load_bias']
    for name,spec in plan['session_observer']['symbols'].items():assert addresses[name]==bias+spec['elf_value']
    return bias,path


def context(old,new,oldplan,newplan):
    oldbin,newbin=Path(oldplan['inputs'][0]['argv'][0]),Path(newplan['inputs'][0]['argv'][0])
    old_id=identity(oldbin)
    assert old_id==oldplan['file_identities'][str(oldbin)]==newplan['file_identities'][str(newbin)]
    if oldbin!=newbin:assert identity(newbin)==old_id
    native=elf_witness(oldbin)
    oldbias,oldmeta=load_bias(old,oldplan);newbias,newmeta=load_bias(new,newplan)
    source=E/'retained-why-interval-native-effects-20261019/caml_z.c'
    source_id=identity(source)
    assert source_id=={'bytes':92312,'sha256':'f1f232391c01c36cf3cedd30d13168db1479d382749d92014ea7eb0960d566a7'}
    lines=source.read_text().splitlines(keepends=True)
    excerpts=[{'first':a,'last':b,'text':''.join(lines[a-1:b])} for a,b in [(99,151),(3461,3480),(3520,3540)]]
    runtime=E/'retained-why-fixed-session-atoms-20261020/source-excerpts.json'
    runtime_excerpt,=[r for r in json.loads(runtime.read_text()) if '#define Custom_tag 255' in r['text']]
    assert '#define Data_custom_val(v) ((void *) &Field((v), 1))' in runtime_excerpt['text']
    return {'symbol':OPS_SYMBOL,'elf_value':OPS_VALUE,'old_pointer':oldbias+OPS_VALUE,'new_pointer':newbias+OPS_VALUE,
        'old_load_bias':oldbias,'new_load_bias':newbias,'binary_identity':old_id,'native':native,
        'old_symbol_metadata':identity(oldmeta),'new_symbol_metadata':identity(newmeta),
        'source':str(source.relative_to(E.parent.parent)),'source_identity':source_id,'source_excerpts':excerpts,
        'runtime_custom_layout_packet_identity':identity(runtime),'runtime_custom_layout_excerpt':runtime_excerpt,
        'scope':'Only the first word of recognized Zarith custom blocks is relocated; sign/header/all limb/all unused bytes remain exact under the accepted source-family/native relation.'}


def compare(raw_old,raw_new,recognized):
    assert recognized is not None,'unknown custom operations type'
    assert len(raw_old)==len(raw_new)>=24,'Zarith custom block size'
    a=struct.unpack('<'+'Q'*(len(raw_old)//8),raw_old);b=struct.unpack('<'+'Q'*(len(raw_new)//8),raw_new)
    assert a[0]==recognized['old_pointer'] and b[0]==recognized['new_pointer'],'unrecognized custom operations relocation'
    used=a[1]&((1<<63)-1)
    assert 1<=used<=len(a)-2 and a[1+used]!=0,'invalid Zarith custom integer layout'
    assert raw_old[8:]==raw_new[8:],'changed Zarith custom data bytes'
