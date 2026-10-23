#!/usr/bin/env python3
"""Prepare new composition inputs; no retained checker or target is executed."""
import hashlib
import json
from pathlib import Path
import posixpath
import re
import struct
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INSTALL = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef')
inputs = {}


def ident(b):
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}


def read(path, commit=None):
    key = f'git:{commit}:{path}' if commit else path
    b = subprocess.check_output(['git', 'show', f'{commit}:{path}'], cwd=ROOT) if commit else (ROOT/path).read_bytes()
    inputs[key] = ident(b)
    return b


def dump(name, value):
    (HERE/name).write_text(json.dumps(value, indent=2, sort_keys=True)+'\n')


def quoted(source):
    """Keep quoted source; replace nested comments by same-width whitespace."""
    i = depth = 0
    clean = list(source)
    tokens = []
    while i < len(source):
        if source.startswith('(*)', i) and not depth:
            i += 3
        elif source.startswith('(*', i):
            clean[i:i+2] = '  '; depth += 1; i += 2
        elif depth:
            if source.startswith('*)', i):
                clean[i:i+2] = '  '; depth -= 1; i += 2
            else:
                if source[i] != '\n': clean[i] = ' '
                i += 1
        elif source[i] == '"':
            start = i; i += 1
            while i < len(source):
                if source[i] == '\\': i += 2
                elif source[i] == '"': i += 1; break
                else: i += 1
            else: raise ValueError('unfinished string')
            tokens.append(source[start:i])
        else: i += 1
    assert depth == 0
    return ''.join(clean), tokens


def elf(data):
    h = struct.unpack_from('<16sHHIQQQIHHHHHH', data)
    assert h[0][:6] == b'\x7fELF\x02\x01' and h[2] == 62
    sections = [struct.unpack_from('<IIQQQQIIQQ', data, h[6]+i*h[11]) for i in range(h[12])]
    symbols = {}
    for s in sections:
        if s[1] != 2: continue
        st = sections[s[6]]; names = data[st[4]:st[4]+st[5]]
        for off in range(s[4], s[4]+s[5], s[9]):
            n, info, other, ix, address, size = struct.unpack_from('<IBBHQQ', data, off)
            name = names[n:names.index(0, n)].decode()
            if name: symbols[name] = (address, size)
    def at(address, size):
        ss = [s for s in sections if s[1] != 8 and s[3] <= address and address+size <= s[3]+s[5]]
        assert len(ss) == 1
        s = ss[0]; off = s[4]+address-s[3]
        return data[off:off+size]
    return symbols, at


def main():
    HERE.mkdir(parents=True, exist_ok=True)
    cfg = HERE/'configuration'; cfg.mkdir(exist_ok=True)
    overlay = cfg/'overlay'; overlay.mkdir(exist_ok=True)
    rename = {'cvc5_gnatprove.drv':'cvc5_silvercap.drv',
              'z3_gnatprove.drv':'z3_silvercap.drv',
              'alt_ergo_gnatprove_smt2.drv':'alt_ergo_silvercap_smt2.drv',
              'smt-libv2.gen':'slv-libv2.gen'}
    oldbase = read('docs/evidence/retained-adapter-config-composition-20261020/candidate-base-why3.conf')
    base = oldbase
    changes = []
    for old, new in list(rename.items())[:3]:
        oldline = b'driver = "'+old[:-4].encode()+b'"'
        newline = b'driver = "'+new[:-4].encode()+b'"'
        assert base.count(oldline) == 1 and len(oldline) == len(newline)
        base = base.replace(oldline, newline)
        changes.append({'before':oldline.decode(), 'after':newline.decode()})
    (cfg/'why3.conf').write_bytes(base)
    files = {}
    for old in ['cvc5_gnatprove.drv','z3_gnatprove.drv','alt_ergo_gnatprove_smt2.drv','silver_cvc5_no_steps.gen','smt-libv2.gen','why3.conf']:
        src = 'docs/evidence/retained-response-timing-config-20261020/overlay/'+old
        before = read(src)
        after = before.replace(b'import "smt-libv2.gen"', b'import "slv-libv2.gen"')
        name = rename.get(old, old)
        assert len(before) == len(after) and len(old) == len(name)
        (overlay/name).write_bytes(after)
        files[name] = {'source':src, 'source_identity':ident(before), 'identity':ident(after),
                       'old_name':old, 'import_replacements':before.count(b'import "smt-libv2.gen"')}
    dump('configuration-repair.json', {'base_before':ident(oldbase), 'base_after':ident(base),
        'base_driver_edits':changes, 'files':files, 'rename':rename,
        'production_files_changed':False, 'common_extra_FileTags_names_upper':1})

    roles = json.loads(read('docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json'))
    initial = {r['path']:r for r in roles['put_line']['captures'][1]['ordered_opens'] if '/drivers/' in r['path'] or r['path'].endswith(('.drv','.gen'))}
    dimarc = 'docs/evidence/retained-producer-prefix-gc-20261018/dimensions-sources.tar.gz'
    read(dimarc)
    driver_rows = []; raw_by_name = {}
    with tarfile.open(ROOT/dimarc) as arc:
        for path, row in sorted(initial.items()):
            name = Path(path).name
            if path.startswith('$PRIVATE'):
                source = 'docs/evidence/retained-solver-request-bytes-20261020/drivers/'+name
                raw = read(source); origin = {'path':source}
            elif name == 'coq-realizations.aux':
                raw = Path(path).read_bytes()
                assert ident(raw) == row['identity']
                (HERE/name).write_bytes(raw)
                origin = {'path':'docs/evidence/retained-fixed-failure-composition-20261023/'+name,
                          'retained_open_identity':row['identity'], 'installed_path':path}
            else:
                member = 'installed/'+path.split('gnatprove_16.1.0_82528bef/',1)[1]
                raw = arc.extractfile(member).read(); origin = {'archive':dimarc,'member':member}
            assert ident(raw) == row['identity'], name
            clean, tokens = quoted(raw.decode())
            imports = re.findall(r'(?m)^\s*import\s+"([^"\n]+)"', clean)
            digits = [m for tok in tokens for m in re.findall(r'%(?:[a-z])?(\d+)', tok)]
            assert not re.search(r'(?m)^\s*plugin\b', clean)
            driver_rows.append({'name':name,'role_path':path,'identity':ident(raw),'origin':origin,
                'imports':imports,'maximum_numeric_placeholder_bytes':max(map(len,digits),default=0),
                'numeric_placeholder_occurrences':len(digits)})
            raw_by_name[name] = raw
        installed_names = sorted(Path(m.name).name for m in arc.getmembers() if '/drivers/' in m.name)
    assert len(driver_rows) == 27
    for new in rename.values(): assert new not in installed_names
    installed_dir = INSTALL/'libexec/spark/share/why3/drivers'
    actual_names = sorted(p.name for p in installed_dir.iterdir())
    for new in rename.values(): assert new not in actual_names
    names = set(raw_by_name)
    assert all(set(r['imports']) <= names for r in driver_rows)
    dump('initial-driver-closure.json', {'files':driver_rows,'file_count':27,
        'installed_driver_member_names':installed_names,'numeric_placeholder_maximum':max(r['maximum_numeric_placeholder_bytes'] for r in driver_rows),
        'actual_installed_directory':str(installed_dir), 'actual_installed_entry_names':actual_names,
        'actual_directory_observation':'finite read-only listing; prospective immutable membership remains an explicit input',
        'standard_stderr_fragment':{'B':64,'E':8,'attempts':1},
        'previous_14_file_scope':'selected later SMT printer roots only'})

    exe = INSTALL/'libexec/spark/bin/gnatwhy3'; data = exe.read_bytes()
    expected = next(v for k,v in roles['put_line']['captures'][1]['mapped_files'].items() if k.endswith('/gnatwhy3'))
    assert ident(data) == expected
    symbols, at = elf(data)
    source_disasm = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt').read_text()
    funcs = ['camlWhy3__Sysutil__resolve_from_paths_1493','camlWhy3__Sysutil__is_file_1490',
             'camlWhy3__Sysutil__fun_2014','camlWhy3__Sysutil__entry',
             'camlWhy3__Driver_lexer__multifile_534','camlGnat_util__find_driver_file_1079']
    witnesses = []; displays = []
    for name in funcs:
        address, size = symbols[name]; raw = at(address,size)
        m = re.search(r'^([0-9a-f]+) <'+re.escape(name)+r'>:\n(.*?)(?=^[0-9a-f]+ <|\Z)',source_disasm,re.M|re.S)
        assert m and int(m[1],16) == address
        displayed = bytearray()
        for line in m[2].splitlines():
            match = re.match(r'\s*([0-9a-f]+):\s*\t((?:[0-9a-f]{2}\s+)+)',line)
            if match: displayed.extend(bytes.fromhex(match[2]))
        assert bytes(displayed[:size]) == raw, name
        witnesses.append({'symbol':name,'address':address,'size':size,'identity':ident(raw),'hex':raw.hex()})
        displays.append(m[0])
    display='\n'.join(line.rstrip() for line in '\n'.join(displays).splitlines()).rstrip()+'\n'
    (HERE/'resolver-disassembly.txt').write_text(display)
    dump('resolver-native.json', {'ELF_path':str(exe),'ELF_identity':ident(data),'functions':witnesses,
        'origin':'selected complete bodies extracted from already retained disassembly; checked against exact ELF',
        'new_disassembler_runs':0,'inferior_runs':0})
    plugin_rows = []
    for name in ['gnat_json.cmxs','ada_terms.cmxs']:
        path = INSTALL/'libexec/spark/lib/why3/plugins'/name; b=path.read_bytes()
        assert ident(b) == roles['put_line']['captures'][1]['mapped_files'][str(path)]
        h=struct.unpack_from('<16sHHIQQQIHHHHHH',b)
        ph=[struct.unpack_from('<IIQQQQQQ',b,h[5]+i*h[9]) for i in range(h[10])]
        seg=next(p for p in ph if p[0]==2); raw=b[seg[2]:seg[2]+seg[5]]
        entries=[list(struct.unpack_from('<QQ',raw,o)) for o in range(0,len(raw),16)]
        assert not any(tag in [1,15,29] for tag,value in entries)
        plugin_rows.append({'path':str(path),'identity':ident(b),'dynamic_offset':seg[2],
                            'dynamic_identity':ident(raw),'dynamic_hex':raw.hex(),'entries':entries,
                            'DT_NEEDED':[],'DT_RPATH':[],'DT_RUNPATH':[]})
    dump('loader-native.json',plugin_rows)

    sources = {
        'why3/src/util/sysutil.ml':[(128,130),(147,230),(257,271)],
        'why3/src/util/plugin.ml':[(18,37)],
        'why3/src/util/util.ml':[(123,128)],
        'why3/src/gnat/gnat_util.ml':[(41,124)],
        'why3/src/gnat/gnat_config.ml':[(346,390),(552,565),(712,744)],
        'why3/src/driver/whyconf.ml':[(518,542)],
        'why3/src/driver/driver.ml':[(53,92),(235,282)],
        'why3/src/driver/driver_lexer.mll':[(117,140)],
        'why3/src/session/controller_itp.ml':[(114,137),(271,285)],
        'why3/src/session/session_itp.ml':[(292,295),(618,640),(1778,1804)],
        'why3/src/gnat/gnat_checks.ml':[(57,61),(380,415)],
        'why3/src/core/env.ml':[(156,221)],
        'why3/plugins/gnat_json/gnat_ast_to_ptree.ml':[(1371,1423)],
    }
    arcpath='docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'; read(arcpath)
    spans=[]
    with tarfile.open(ROOT/arcpath) as arc:
        for member,ranges in sources.items():
            raw=arc.extractfile(member).read();lines=raw.decode().splitlines(keepends=True)
            for start,end in ranges:
                text=''.join(lines[start-1:end]);spans.append({'archive':arcpath,'member':member,'member_identity':ident(raw),
                    'start':start,'end':end,'identity':ident(text.encode()),'text':text})
    libc='docs/evidence/retained-server-libc-storage-20261020/glibc_2.43.orig.tar.xz';read(libc)
    with tarfile.open(ROOT/libc) as arc:
        member='glibc-2.43/elf/dl-load.c';raw=arc.extractfile(member).read();lines=raw.decode().splitlines(keepends=True)
        for start,end in [(2121,2142),(2172,2203)]:
            text=''.join(lines[start-1:end]);spans.append({'archive':libc,'member':member,'member_identity':ident(raw),
                'start':start,'end':end,'identity':ident(text.encode()),'text':text})
    dump('source-witnesses.json',spans)

    pathdata=json.loads(read('docs/evidence/retained-why-report-path-inputs-20261023/projection.json'))
    probes=json.loads(read('docs/evidence/retained-why-library-probe-paths-20261023/projection.json'))
    dirs=probes['loadpath_sorted']; extensions=probes['extensions']
    paths={}
    root_names=re.findall(rb'^driver = "([^"]+)"',base,re.M)
    assert len(root_names)==9
    for domain, row in pathdata['domains'].items():
        cap=roles[domain]['captures'][1]; private=cap['private_root']; ov=private+'/overlay'
        # Equality is by complete ordered normalized roles/identities, not basename only.
        original=[r for r in cap['ordered_opens'] if '/drivers/' in r['path'] or r['path'].endswith(('.drv','.gen'))]
        reference=[r for r in roles['put_line']['captures'][1]['ordered_opens'] if '/drivers/' in r['path'] or r['path'].endswith(('.drv','.gen'))]
        assert original == reference and len(original)==57
        libraries=[]
        for name in row['matched_library_paths']:
            prefixes=[d for d in dirs if name.startswith(d+'/')];assert len(prefixes)==1
            libraries.append(name[len(prefixes[0])+1:].rsplit('.',1)[0])
        library_candidates=[d+'/'+b+'.'+e for b in libraries for d in dirs for e in extensions]
        assert len(library_candidates)==420
        observed_selected=sorted(p for p in library_candidates if Path(p).exists())
        assert observed_selected==sorted(row['matched_library_paths'])
        discovery=[]
        for name in root_names:
            fn=name.decode()+'.drv'
            discovery.append({'root':fn,'candidates':[fn,ov+'/'+fn,str(installed_dir)+'/'+fn]})
        repaired=[]
        imports=[]
        for r in driver_rows:
            old=r['name']; new=rename.get(old,old) if r['role_path'].startswith('$PRIVATE') else old
            path=(ov+'/'+new) if r['role_path'].startswith('$PRIVATE') else r['role_path']
            raw=(overlay/new).read_bytes() if r['role_path'].startswith('$PRIVATE') else raw_by_name[old]
            repaired.append({'path':path,'identity':ident(raw)})
            text,_=quoted(raw.decode())
            for imported in re.findall(r'(?m)^\s*import\s+"([^"\n]+)"',text):
                current=posixpath.dirname(path)
                ds=[current] if current==str(installed_dir) else [current,str(installed_dir)]
                imports.append({'from':path,'name':imported,'candidates':[d+'/'+imported for d in ds]})
        repaired.append({'path':ov+'/slv-libv2.gen','identity':ident((overlay/'slv-libv2.gen').read_bytes())})
        known={x['path']:x['identity'] for x in repaired}
        for r in imports:
            hits=[p for p in r['candidates'] if p in known]; assert len(hits)==1
            r['required_existing_candidate']=hits[0]
            r['required_absent_candidates']=[p for p in r['candidates'] if p not in known]
        for r in discovery:
            hits=[p for p in r['candidates'] if p in known];assert len(hits)==1
            r['required_existing_candidate']=hits[0]
            r['required_absent_candidates']=[p for p in r['candidates'] if p not in known]
        names=row['configured_names'];stem=names['session_directory']
        additional=[names['input'],names['log'],names['endpoint'],posixpath.dirname(names['endpoint']),posixpath.basename(names['endpoint']),
                    stem,stem+'/why3session.xml',stem+'/why3ession.xml',stem+'/why3shapes.gz',stem+'.sexp',stem+'.mlw',
                    'why3.conf',ov+'/why3.conf','.why3.conf','GMON_OUT_PREFIX',names['profiling_value'],
                    '', '<dummy>', 'gnat_json.cmxs','ada_terms.cmxs','getcwd','chdir','connect']
        retained_paths=[r[k].replace('$PRIVATE',private) for r in cap['ordered_opens'] for k in ['path','resolved_path']]
        loader_paths=list(cap['mapped_files'])
        all_names=(retained_paths+library_candidates+additional+loader_paths+libraries+dirs+
                   [p for r in discovery+imports for p in r['candidates']]+[x['path'] for x in repaired])
        assert max(map(len,all_names))==180
        paths[domain]={'initial_libraries':libraries,'library_candidates':library_candidates,
            'required_existing_library_candidates':row['matched_library_paths'],
            'observed_existing_library_candidates':observed_selected,
            'driver_discovery':discovery,'driver_imports':imports,'repaired_driver_files':repaired,
            'configured_other_spellings':additional,'retained_open_spellings':retained_paths,'loader_image_spellings':loader_paths,
            'constant_maximum':180,'library_candidate_maximum':max(map(len,library_candidates)),
            'initial_driver_open_occurrences':57,'initial_input_open_occurrences':81,
            'client_cwd_observed':None,'PrecutP':{'max':[180,{'client_initial_cwd_bytes':1,'constant':10}]},
            'P_file':180,'raw_label_U':row['decoded_string_max_bytes_U'],
            'controlled_environment':cap['normalized_environment'], 'actual_client_cwd_inferred':False}
    dump('paths.json',{'loadpath':dirs,'extensions':extensions,'domains':paths,
        'filesystem_relation':'exact fixed files at required candidates; all other search candidates absent, private namespace exclusive, immutable during each run'})
    read('docs/evidence/retained-combined-parallel-startup-20261020/projection.json')
    read('docs/evidence/retained-combined-parallel-startup-20261020/check-result.json')

    providers={
        'continuation':('f0995fc7ebe56b718fdbfc07572d36e77856bb6a','retained-fixed-domain-composition',
                        '91f626807eb2477f73dd132ca6b065a8c32b29cd','retained-fixed-domain-composition-review'),
        'precut':('07e63b97f3623b2405172433ae093ce894defd23','retained-precut-failure-capacity',
                  'd256a0a354cc11df761c408592b4601c32f6d25a','review-precut-failure-capacity'),
        'mlw':('d25ff5cad0060704ee53fee9e18a62c1c3f82c25','retained-fixed-ptree-mlw-output',
               '28ea4fbe6372a61c30a9dc7cdbcefcd4e86db627','retained-fixed-ptree-mlw-review'),
        'sexp':('e47e5236cfe9e73087870e0e3283d184e05bacf2','retained-fixed-ptree-sexp-output',
                '573ffc89030522b3751563f398e651b12f40f170','review-fixed-ptree-sexp-output')}
    provider_rows={}
    for key,(author,packet,review,rpacket) in providers.items():
        row={'author':author,'review':review,'files':[]}
        author_paths=[f'docs/research/{packet}.md',f'docs/evidence/{packet}-20261023']
        review_path=f'docs/evidence/{rpacket}-20261023'
        for commit,wanted in [(author,author_paths),(review,[review_path])]:
            ls=subprocess.check_output(['git','ls-tree','-r','--name-only',commit,'--',*wanted],cwd=ROOT).decode().splitlines()
            assert ls,(key,commit,wanted)
            for path in ls:
                read(path,commit);row['files'].append({'commit':commit,'path':path})
        provider_rows[key]=row
    read('docs/research/retained-precut-failure-capacity.md','7100d0c29f6311efe3c9bf497e0669e1236f7c16')
    read('docs/evidence/retained-fixed-ptree-capture-20261023/result.json','91ad324d83')
    dump('providers.json',provider_rows)
    dump('inputs.json',inputs)


if __name__ == '__main__':
    main()
