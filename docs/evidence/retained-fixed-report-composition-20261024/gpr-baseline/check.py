#!/usr/bin/env python3
"""New GPR parsed-configuration baseline obligation only. Offline source/data."""
import hashlib,json,re,tarfile,time,platform
from pathlib import Path
from xml.etree import ElementTree as ET
from xml.parsers import expat
import capacity as C
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[3]
def sha(b):return hashlib.sha256(b).hexdigest()
def main():
    start=time.monotonic()
    manifest=json.loads((HERE/'source-manifest.json').read_text())
    for p,h in manifest['providers'].items():assert sha((REPO/p).read_bytes())==h,p
    assert sha((HERE/'source-sites.json').read_bytes())==manifest['source_inventory_sha256']
    p=manifest['accepted_research_prefix'];assert sha((REPO/'docs/research/retained-fixed-report-composition.md').read_bytes()[:p['bytes']])==p['sha256']
    gpr='docs/evidence/retained-producer-gpr-descriptor-20261018/gprbuild-v26.0.0.tar.gz'
    with tarfile.open(REPO/gpr) as t:
        allsrc={m.name:t.extractfile(m).read() for m in t if m.isfile() and m.name.endswith(('.adb','.ads'))}
    for n,p in manifest['source_members'].items():
        assert len(allsrc[n])==p['bytes'] and sha(allsrc[n])==p['sha256']
    source=lambda name:next(b.decode() for n,b in allsrc.items() if n.endswith('/'+name))
    sites=sum(len(re.findall(r'\bDefault_Project_Node\s*\(',source(n))) for n in ['gpr-part.adb','gpr-dect.adb','gpr-strt.adb'])
    assert sites==34
    attr=source('gpr-attr.adb')
    init=attr[attr.index('--  Start of processing for Initialize'):attr.index('Initialized := True;')]
    attributes=len(re.findall(r'\bAdd_Attribute\s*\(',init))
    packages=len(re.findall(r'\bAdd_Package\s*\(',init))
    names=re.findall(r'Add_Name\s*\("((?:[^"]|"")*)"\)',source('gpr-snames.adb'))
    assert attributes>0 and packages>0 and len(names)>0
    # Parse the pinned XML for structural counts. No fragment-selection,
    # Gprconfig execution, or old configuration checker is replayed.
    dbpath=REPO/'docs/evidence/retained-producer-gpr-descriptor-20261018/installed-configs.tar.gz'
    with tarfile.open(dbpath) as t:db={m.name:t.extractfile(m).read() for m in t if m.isfile()}
    def parse(name):
        builder=ET.TreeBuilder();parser=expat.ParserCreate()
        parser.StartElementHandler=builder.start;parser.EndElementHandler=builder.end;parser.CharacterDataHandler=builder.data
        def external(parent,context,system):
            assert '/' not in system and '\\' not in system
            child=parent.ExternalEntityParserCreate(context)
            child.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
            child.ExternalEntityRefHandler=lambda context,base,system,public:external(child,context,system)
            child.Parse(db['db/'+system],True);return 1
        parser.ExternalEntityRefHandler=lambda context,base,system,public:external(parser,context,system)
        parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
        parser.Parse(db[name],True);return builder.close()
    xml=[];target_names=0
    for name in sorted(n for n in db if n.endswith('.xml')):
        tree=parse(name);els=list(tree.iter())
        targets=tree.findall('targetset');fallback=tree.findall('fallback_targets')
        target_names+=len(targets)  # one canonical or first-target name per set
        xml.append(dict(path=name,bytes=len(db[name]),sha256=sha(db[name]),elements=len(els),
            attributes=sum(len(e.attrib) for e in els),
            expanded_text_bytes=sum(len((e.text or '').encode())+len((e.tail or '').encode()) for e in els),
            target_sets=len(targets),target_patterns=sum(len(e.findall('target')) for e in targets),
            fallback_sets=len(fallback),fallback_strings=sum(len(e.findall('target')) for e in fallback),
            compiler_descriptions=len(tree.findall('compiler_description')),
            configurations=len(tree.findall('configuration'))))
    # Capture-independent reconstruction of the user project branch.
    project=[];active=False
    for line in (REPO/'src/silver.adb').read_text().splitlines():
        if '"project Program is"' in line:active=True
        if active and '& LF' in line and 'else "' not in line:
            m=re.search(r'"((?:[^"]|"")*)"\s*& LF',line)
            if m:project.append(m[1].replace('""','"'))
        if active and '"end Program;"' in line:break
    project=('\n'.join(project)+'\n').encode()
    assert project==(HERE/'inputs/program.gpr').read_bytes() and len(project)==541
    R='/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/16.1.0'
    inputs={};phases={}
    with tarfile.open(REPO/'docs/evidence/retained-producer-orchestration-20261018/observations.tar.gz') as t:
        for phase,num in [('datarep',2),('phase1',12),('translation',22)]:
            original=t.extractfile(f'complete_configs/retained-temporaries/{num}-GNAT-TEMP-000001.TMP').read()
            oldruntime=re.search(rb'for Runtime_Dir\s+\("Ada"\) use "([^"]+)"',original).group(1)
            assert original.count(oldruntime)==2
            baseline=original.replace(oldruntime,(R+'/').encode())
            file=HERE/'inputs'/f'{phase}-before-extra-clauses.gpr'
            assert baseline==file.read_bytes()
            row=C.project_prefix(project,baseline,sites,attributes,packages,len(names)+2,target_names)
            assert row['parser_shared_tables_closed']
            assert row['project']['max_references_per_rhs']<=1 and row['configuration']['max_references_per_rhs']<=1
            assert row['project']['max_literal']<10000 and row['configuration']['max_literal']<10000
            assert row['syntax_name_payload_upper']<1000000
            bound=row['gross_shared_table_bounds']
            # Attach accepted RTS table deltas to source-computed operands.
            rts=dict(Project_Nodes=C.table(bound['Project_Nodes']['demand']+20,1,1000,100,352,99999999),
                     String_Elements=C.table(bound['String_Elements']['demand']+7,1,200,100,80),
                     Name_Lists=C.table(bound['Name_Lists']['demand']+7,1,10,100,32))
            assert all(v['passed'] for v in rts.values())
            row['accepted_RTS_shared_table_attachment']=rts
            row['accepted_RTS_whole_context_attached']=False
            phases[phase]=row
            inputs[phase]=dict(original_bytes=len(original),original_sha256=sha(original),
                reconstructed_baseline_bytes=len(baseline),reconstructed_baseline_sha256=sha(baseline),
                reconstruction='Only both old runtime-prefix occurrences replaced by R/; original comments retained, extra RTS clauses excluded for additive attachment')
    # Source entry/branch receipts: they substantiate the manual control-flow
    # argument, not a claim that matching snippets prove the whole argument.
    guards={
      'explicit_target_disables_fallback':'Fallback_Try_Again := False;' in source('gpr-conf.adb'),
      'user_phase1_not_repeated':'Do_Phase_1                 => False' in source('gpr-conf.adb'),
      'config_phase1_retains_user_tables':'Reset_Tree             => False' in source('gpr-conf.adb'),
      'KB_parent_target_only':'Parse_Compiler_Info => False' in source('gpr-util-knowledge.adb'),
      'default_lists_empty':'Values               => Nil_String' in source('gpr-proc.adb'),
      'reset_dot_cell':'--  Create Dot_String_List' in source('gpr.adb'),
      'runtime_pathfile_absent_branch':'(Runtime_Dir\n                                                & Directory_Separator\n                                                & Directory)' in source('gpr-nmsc.adb'),
      'comments_disabled':'Store_Comments    : Boolean := False' in source('gpr-part.adb'),
      'names_buffer_one_million':'Name_Buffer : String (1 .. 1_000_000)' in source('gpr-names.ads'),
    }
    assert all(guards.values()),guards
    predefined=dict(attribute_initializers=attributes,package_initializers=packages,
        Snames_literal_requests=len(names),Snames_max_payload=max(map(len,names)),
        Attributes=C.table(attributes,1,50,100,144,99999999),
        Package_Attributes=C.table(packages,1,10,100,48,99999999),
        package_name_pointer_array_initial=20,package_name_requests=packages,
        package_name_String_upper=max(map(len,names))+16,
        Set_container_allocation_provider_attached=False)
    assert predefined['Attributes']['passed'] and predefined['Package_Attributes']['passed'] and packages<=20
    result=dict(scope='Parsed GPR configuration and shared-table baseline; complete process startup remains owned by #212',
        platform=platform.system()+' '+platform.machine(),provider_files=len(manifest['providers']),
        selected_complete_source_members=len(manifest['source_members']),
        complete_GPR_archive_Ada_files=len(allsrc),source_constructor_sites=sites,
        project=dict(bytes=len(project),sha256=sha(project)),inputs=inputs,
        predefined=predefined,XML_input_inventory=xml,GPRbuild_target_KB_Name_requests=target_names,
        phases=phases,source_branch_receipts=guards,
        parser_shared_table_baseline_closed=True,three_RTS_shared_table_deltas_attached=True,
        complete_GPR_Name_baseline_closed=False,complete_GPRconfig_capacity_closed=False,
        complete_GNATprove_GPR2_capacity_closed=False,complete_producer_configuration_capacity_closed=False,
        residuals=['Nonparsed GPR.Names command/environment/path/naming and later ALI/process contributions and prior vector capacity.',
        'KB XML/Ada DOM/input/entity tables and regexp compilation; target/fallback vectors/list/set allocations and shared startup accounting.',
        'Gprconfig full compiler-description/configuration containers, directory/candidate/output and selection/generation objects.',
        'Separate GNATprove GPR2 startup/project/runtime-discovery and later producer/report joins.'],
        native_executions=0,predecessor_checker_replays=0,new_captures=0,runtime_corpus_rescans=0,
        e_upper=2,save_entering_callbacks_upper=2,saves_upper=3,aggregate_RAM_or_stack_gate=False,
        elapsed_seconds=round(time.monotonic()-start,6))
    (HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:result[k] for k in ['provider_files','selected_complete_source_members','parser_shared_table_baseline_closed','three_RTS_shared_table_deltas_attached','complete_producer_configuration_capacity_closed','elapsed_seconds']}))
if __name__=='__main__':main()
