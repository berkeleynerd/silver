#!/usr/bin/env python3
"""One changed-obligation source/arithmetic check. No previous checker runs."""
import ast, hashlib, json, re, tarfile, time, platform
from xml.parsers import expat
from xml.etree import ElementTree as ET
from pathlib import Path
import capacity as C
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[3]
def sha(b): return hashlib.sha256(b).hexdigest()
def read(path): return json.loads((REPO/path).read_bytes())
def runtime_macro_selection(text):
    """All fragments, not merely Ada Compiler: no selector/native replay."""
    assert 'return Name_As_Directory (Get_Name_String (Comp.Runtime_Dir));' in text['gpr/gpr-knowledge.adb']
    assert 'return Dir & Directory_Separator;' in text['gpr/gpr-knowledge.adb']
    assert "Compiler.Runtime_Dir := Compiler.Runtime;" in text['gpr/gpr-knowledge.adb']
    path=REPO/'docs/evidence/retained-producer-gpr-descriptor-20261018/installed-configs.tar.gz'
    with tarfile.open(path) as t:
        db={m.name:t.extractfile(m).read() for m in t if m.isfile()}
    def parse(name):
        builder=ET.TreeBuilder(); parser=expat.ParserCreate()
        parser.StartElementHandler=builder.start
        parser.EndElementHandler=builder.end
        parser.CharacterDataHandler=builder.data
        def external(parent,context,system):
            assert '/' not in system and '\\' not in system
            child=parent.ExternalEntityParserCreate(context)
            child.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
            child.ExternalEntityRefHandler=lambda context,base,system,public: external(child,context,system)
            child.Parse(db['db/'+system],True); return 1
        parser.ExternalEntityRefHandler=lambda context,base,system,public: external(parser,context,system)
        parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
        parser.Parse(db[name],True)
        return builder.close()
    def applies(config,runtime,target):
        for group in config:
            if group.tag=='config': continue
            assert group.tag in ['compilers','targets','hosts']
            def match(child):
                for key,pattern in child.attrib.items():
                    if key=='except':
                        if pattern and re.search(pattern,target): return False
                    else:
                        value={'name':'GNAT' if group.tag=='compilers' else target,
                               'version':'16.1','runtime':runtime,'language':'Ada'}[key]
                        if key=='language':
                            if pattern.lower()!=value.lower(): return False
                        elif not re.search(pattern,value): return False
                return True
            yes=any(match(child) for child in group)
            if group.get('negate','').lower()=='true': yes=not yes
            if not yes:return False
        return True
    selected={'default':[],C.R:[]}; fragments={}
    xmls=sorted(n for n in db if n.startswith('db/') and n.endswith('.xml'))
    assert len(xmls)==63
    for n in xmls:
        tree=parse(n)
        assert not any(x.get('name')=='RUNTIME_DIR' for x in tree.iter('variable'))
        for i,config in enumerate(tree.findall('configuration')):
            fragments[(n,i)]=config.findtext('config') or ''
            for runtime in selected:
                yes=applies(config,runtime,'x86_64-linux')
                assert yes==applies(config,runtime,'x86_64-pc-linux-gnu')
                if yes:selected[runtime].append([n,i])
    added=[x for x in selected[C.R] if x not in selected['default']]
    removed=[x for x in selected['default'] if x not in selected[C.R]]
    assert added==[['db/gnat.xml',13]] and removed==[]
    extra=fragments[('db/gnat.xml',13)]
    assert extra.count('--RTS=${RUNTIME_DIR(ada)}')==2
    linker=[key for key,fragment in fragments.items() if '-Wl,-rpath-link,${RUNTIME_DIR(ada)}/adalib' in fragment]
    assert len(linker)==1 and list(linker[0]) in selected['default'] and list(linker[0]) in selected[C.R]
    return dict(all_xml_files=63, default_all_selected=selected['default'],
        prospective_all_selected=selected[C.R],added=added,removed=removed,
        linker_fragment=list(linker[0]),linker_selection_changed=False,
        Runtime_raw_bytes=162,Runtime_Dir_substitution_bytes=163,
        top_level_RTS_bytes=168,compiler_and_binder_RTS_bytes=169,
        source_loci=['gpr-knowledge.adb:465-475,1410-1411,3968-3973,4638-4645',
                     'gnat.xml configuration13','linker.xml existing rpath-link clause'])

def main():
    start=time.monotonic()
    m=json.loads((HERE/'source-manifest.json').read_text())
    for p,h in m['providers'].items(): assert sha((REPO/p).read_bytes())==h,p
    assert sha((HERE/'sources.tar.gz').read_bytes())==m['source_archive_sha256']
    with tarfile.open(HERE/'sources.tar.gz') as t:
        sources={x.name:t.extractfile(x).read() for x in t if x.isfile()}
    assert set(sources)==set(m['sources'])
    archives={}
    gcc=read('docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json')
    gccpins={r['path']:r for r in gcc['files']}
    for n,b in sources.items():
        row=m['sources'][n]; assert len(b)==row['bytes'] and sha(b)==row['sha256'],n
        o=row['origin']
        if 'archive' in o:
            if o['archive'] not in archives:
                with tarfile.open(REPO/o['archive']) as t:
                    archives[o['archive']]={x.name:t.extractfile(x).read() for x in t if x.isfile()}
            assert b==archives[o['archive']][o['member']],n
        else: assert sha(b)==gccpins[o['path']]['sha256'],n
    inventory=json.loads((HERE/'gcc-rts-consumers.json').read_text())
    for item in inventory:
        b=sources['gcc/ada/'+item['path']]
        assert sha(b)==item['sha256']
        rows=[{'line':i,'text':line.strip()} for i,line in enumerate(b.decode().splitlines(),1)
              if re.search(r'\b(RTS_Switch|RTS_Specified|RTS_Src_Path_Name|RTS_Lib_Path_Name|No_Stdinc)\b',line)]
        assert rows==item['matches']
    gprarchive=archives['docs/evidence/retained-producer-gpr-descriptor-20261018/gprbuild-v26.0.0.tar.gz']
    actual=[]
    for n,b in gprarchive.items():
        if n.endswith(('.adb','.ads')):
            actual += [{'path':n,'line':i,'text':line.strip()} for i,line in enumerate(b.decode().splitlines(),1) if 'Set_Ada_Paths' in line]
    assert actual==json.loads((HERE/'gpr-set-ada-paths-inventory.json').read_text())
    prior=(REPO/'docs/research/retained-fixed-report-composition.md').read_bytes()
    assert sha(prior[:m['accepted_research_prefix']['bytes']])==m['accepted_research_prefix']['sha256']
    text={n:b.decode() for n,b in sources.items()}
    assert '{ "--", NULL, "-f", true, false }' in text['gcc/opts-common.cc']
    assert '%{g*&m*&f*}' in text['gcc/ada/gcc-interface/lang-specs.h']
    assert 'fRTS=\nAda AdaWhy AdaSCIL Joined RejectNegative' in text['gcc/ada/gcc-interface/lang.opt']
    assert len(C.R)==162 and len(C.TOPLEVEL_RTS)==168 and len(C.RTS)==169
    descriptor=read('docs/evidence/retained-producer-gpr-descriptor-20261018/result.json')
    phases={}
    for phase in ['phase1','phase2']:
        d=descriptor[phase]; args=d['argv_excluding_executable'].copy()
        args.insert(4,C.RTS); args.insert(8,'-Wno-free-nonheap-object')
        assert len(args)==18
        switches=d.get('A_rows',d.get('A_rows_if_output_were_enabled')).copy()
        switches += ['-Wno-free-nonheap-object',C.RTS]
        counts=(len(switches),sum(map(len,switches)),max(map(len,switches)))
        assert counts==((11,246,169) if phase=='phase1' else (10,239,169))
        phases[phase]=dict(argv_excluding_executable=args,stored_switches=switches,
            switch_count=counts[0],switch_payload=counts[1],switch_max=counts[2],
            switches=C.table(counts[0],1,30,100,16),argv=C.argv(19),
            source_search=C.table(4,0,10,100,16),
            library_search=C.table(4 if phase=='phase1' else 5,0,10,100,16))
    # The existing source read/semantic proof is reused, not re-executed.
    null=read('docs/evidence/retained-producer-null-frontend-20261018/result.json')
    assert null['all_selected_frontend_predicates_pass']
    for phase,row in null['phases'].items():
        base=row['table_backing']
        changed=C.fixed_transfer(0,base['File_Mapping']['demand'],base['Name_Entries']['demand'])
        changed['ALI_Args']=C.table(21,1,1000,100,16)
        assert all(v['passed'] for v in changed.values())
        phases[phase]['recomposed_null_configuration_tables']=changed
        phases[phase]['other_accepted_source_semantic_coordinates_retained']=True
    null_ali=dict(Main_A=11,System_A=10,Args=C.table(21,1,1000,100,16),
                  file_bytes=29622976,reader_bytes=29622977,lines=77552,
                  max_record=789,extra_row_bytes=172)
    assert null_ali['reader_bytes']<=C.I32 and null_ali['max_record']>=172
    datarep=read('docs/evidence/retained-producer-datarep-null-20261018/result.json')
    command=datarep['components']['command']
    assert datarep['source_transfer']['compiler_child_argc_source_bound']+1==24
    assert command['gnat1_argc_bound']==24 and command['canonical_save_argc_bound']==48
    assert command['largest_argument_characters']>=max(C.P+8,len(C.RTS))
    assert command['Compilation_Switches_table']['all_selected_checks_pass']
    libs=read('docs/evidence/retained-main-semantics-20261018/library-capture/summary.json')
    fixed={}
    for c in libs['cases']:
        b=c['fixed_logical_growth']
        rows=C.fixed_transfer(b['ali__args__last_val'], b['fmap__file_mapping__last_valX'],
                              b['namet__name_entries__last_val'])
        assert all(r['passed'] for r in rows.values())
        fixed[c['case']]=dict(coordinates=rows,
            names_basis='raw retained coordinate plus mapping delta; retain owner path/name adjustments',
            semantic_vector_replaced=False)
    # Read the accepted config bytes; do not run the XML selector or GPR again.
    config_path='docs/evidence/retained-producer-orchestration-20261018/observations.tar.gz'
    with tarfile.open(REPO/config_path) as t:
        configs={Path(x.name).name:t.extractfile(x).read().decode() for x in t
                 if x.name.startswith('complete_configs/retained-temporaries/') and
                 Path(x.name).name in ['2-GNAT-TEMP-000001.TMP','12-GNAT-TEMP-000001.TMP','22-GNAT-TEMP-000001.TMP']}
    chunks=[f'for Leading_Required_Switches ("Ada") use\n        Compiler\'Leading_Required_Switches ("Ada") & ("{C.RTS}");',
            f'for Required_Switches ("Ada") use\n        Binder\'Required_Switches ("Ada") & ("{C.RTS}");']
    chunk_bytes=sum(1+6+len(s) for s in chunks)
    cfg={}
    for name,s in configs.items():
        old=re.search(r'for Runtime_Dir\s+\("Ada"\) use "([^"]+)"',s).group(1)
        assert s.count(old)==2
        # Retain old command/cwd widths (prospective ones are shorter); replace
        # both old runtime occurrences with R plus a separator, and add R to
        # the Gprconfig --config field. Exact clause bytes follow Merge_Config.
        bound=len(s)+len(C.R)+2*max(0,len(C.R)+1-len(old))+chunk_bytes
        aligned=((bound+1+4095)//4096)*4096
        assert aligned==8192,(name,bound)
        assert '("-c", "-x", "ada", "-gnatA")' in s
        assert '("gnatbind_prefix=")' in s
        cfg[name]=dict(previous_bytes=len(s),runtime_occurrences=2,
            old_runtime_bytes=len(old),upper_bytes=bound,aligned_bytes=aligned)
    macro=runtime_macro_selection(text)
    mapping=C.mapping_objects(); assert mapping['passed']
    pathsrc=REPO/'docs/evidence/retained-fixed-report-composition-20261024/paths/capacity.py'
    assignments=[n for n in ast.parse(pathsrc.read_text()).body if isinstance(n,ast.Assign)]
    frozen_names=next(ast.literal_eval(n.value) for n in assignments if any(isinstance(t,ast.Name) and t.id=='SOURCES' for t in n.targets))
    assert mapping['source_names']==frozen_names
    assert mapping['bytes']==489 and mapping['reader_bytes']==506
    gpr=C.gpr_unit_transfer_conditions()
    assert gpr['endpoint_arithmetic']['passed']
    rts=C.rts_objects(); assert rts['passed']
    result=dict(scope='Additional prospective RTS producer/native storage join under #212/#119',
        platform=platform.system()+' '+platform.machine(),verified_provider_files=len(m['providers']),
        verified_complete_sources=len(sources),light_phases=phases,RTS_objects=rts,
        indexed_null_ALI=null_ali,fixed_library_configuration_coordinates=fixed,
        datarep=dict(driver_argc_excluding_executable=20,gnat1_argc_including_executable=24,
            canonical_envelope=48,accepted_P=512,prospective_P=C.P,
            accepted_command_component_reused=True,accepted_ALI_component_reused=True,
            direct_native_build_89_covered=False),
        GPR=dict(added_chunk_bytes=chunk_bytes,configurations=cfg,
            runtime_macro_and_full_fragment_selection=macro,
            longest_changed_literal_bytes=186, longest_new_Name_Entry_object_bytes=234,
            single_name_prefix_temporary_table=C.table(1,1,10,100,32),
            ordinary_AST_nodes_per_configuration_parse=20,
            String_Elements_per_configuration_evaluation=7,
            full_Name_List_cells_per_language_conversion=7,
            added_array_entries=0,added_array_element_entries=0,
            changed_literal_spellings_upper=3,context_transfer=gpr,
            package_map_keys_added=0,complete_parent_capacity_established=False),
        generated_ALI_transfer=dict(same_prior_descriptor_extra_bytes=172,
            same_prior_descriptor_extra_lines=1,
            historical_descriptor_conservative_replacement_A_rows_per_file=11,
            historical_descriptor_extra_bytes_per_file=11*172,
            at_most_project_sources=7,reader_Args_additive_allowance=77,
            unchanged_installed_runtime_ALIs=True,
            GPR_DW_W_reader_Args=0,GG_reader_extra_lines=1),
        mapping_objects=mapping, report_P=188,actual_complete_common_path_bytes=None,
        semantic_source_counts_relabelled=False,whole_toolchain_capacity_established=False,
        aggregate_RAM_gate=False,production_implemented=False,native_executions=0,
        predecessor_checkers_executed=0,runtime_corpus_rescanned=False,
        e_upper=2,save_entering_callbacks_upper=2,saves_upper=3,
        all_changed_concrete_checks_pass=True,elapsed_seconds=round(time.monotonic()-start,6))
    (HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:result[k] for k in ['verified_provider_files','verified_complete_sources','all_changed_concrete_checks_pass','elapsed_seconds']}))
if __name__=='__main__':main()
