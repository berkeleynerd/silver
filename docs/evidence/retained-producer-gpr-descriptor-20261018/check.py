#!/usr/bin/env python3
"""Reconstruct selected producer arguments/configuration from pinned bytes only."""
import hashlib
import json
from pathlib import Path
import re
import tarfile
import xml.etree.ElementTree as ET
from xml.parsers import expat

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]


def main():
    identity = json.loads((HERE/'identity.json').read_text())
    sources = {}
    for archive in identity['archives']:
        path = PROJECT/archive['path']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == archive['sha256']
        with tarfile.open(path) as t:
            for row in archive['files']:
                data = t.extractfile(row['member']).read()
                assert len(data) == row['bytes']
                assert hashlib.sha256(data).hexdigest() == row['sha256']
                sources[row['name']] = data.decode()
    manifest_path = PROJECT/identity['gcc_manifest']['path']
    assert hashlib.sha256(manifest_path.read_bytes()).hexdigest() == identity['gcc_manifest']['sha256']
    manifest = json.loads(manifest_path.read_text())
    indexed = {row['path']:row for row in manifest['files']}
    for name, source in sources.items():
        if name.startswith('gcc/'):
            key = name[4:]
            row = indexed.get(key) or indexed['gcc/ada/'+key]
            assert hashlib.sha256(source.encode()).hexdigest() == row['sha256']
    for row in identity['local_files']:
        data = (PROJECT/row['path']).read_bytes()
        assert len(data) == row['bytes']
        assert hashlib.sha256(data).hexdigest() == row['sha256']
        sources[row['path']] = data.decode()

    def has(name, fragment):
        assert ' '.join(fragment.split()) in ' '.join(sources[name].split()), (name, fragment)

    has('gpr/src/gprbuild-compile.adb','List := Config.Compiler_Leading_Required_Switches;')
    has('gpr/src/gprbuild-compile.adb','Add_Compilation_Switches (Id);')
    has('gpr/src/gprbuild-compile.adb','Add_Config_File_Switches (Id, Source_Project);')
    has('gpr/src/gprbuild-compile.adb','Tempdir.Create_Temp_File (File, Name => File_Name);')
    has('gpr/gpr/src/gpr-util.adb','elsif GnatProve_Mode and then Lang.Name = Name_Ada then "gnat2why"')
    has('gpr/gpr/src/gpr-tempdir.adb','Create_Temp_File (FD, File_Name);')
    has('gcc/libgnat/s-os_lib.adb','First_Temp_File_Name : constant String := "GNAT-TEMP-000000.TMP";')
    has('gcc/frontend.adb','elsif not Temp_File then Prepcomp.Add_Dependency (Source_Config_File);')
    has('gcc/switch-c.adb',"when 'A' => Ptr := Ptr + 1; Config_File := False;")
    has('spark/src/why/back_end.adb','GNAT2Why_BE.Scan_Compiler_Arguments;')
    has('gcc/adabkend.adb','Lib.Store_Compilation_Switch (Argv);')
    has('gpr/gpr/src/gpr.ads','Resp_File_Format : Response_File_Format := None;')
    has('gpr/gpr/src/gpr-opt.ads','Use_Include_Path_File : Boolean := False;')
    has('gcc/sinput-l.adb','Reference_Name => N,')
    has('spark/src/gnatprove/gnatprove.adb','Args.Append ("-gnatc");')
    has('spark/src/gnatprove/gnatprove.adb','Args.Append ("-gnates=" & Opt_File);')
    has('spark/src/gnatprove/gnatprove.adb','Args.Append ("-gnatis");')
    has('src/silver.adb','"      for Default_Switches (""Ada"") use (""-gnat2022"", ""-gnata"", ""-gnato"");" & LF &')
    has('src/silver.adb','for Body (""Main"") use ""main.adb"" at 1;')
    has('gpr/src/gprbuild-compile.adb', 'elsif Id.Index /= 0 then')
    has('gpr/src/gprbuild-compile.adb', 'Get_Name_String (Id.Object)')
    has('gpr/src/gprbuild-compile.adb', 'Add_Object_File_Switches (Id); Add_Multi_Unit_Switches (Id); Add_Object_Path_Switches (Id);')
    has('gpr/gpr/src/gpr-util.adb', 'Source_Index => Source.Index, Index_Separator => Source.Language.Config.Multi_Unit_Object_Separator, Object_File_Suffix => Source.Language.Config.Object_File_Suffix')
    has('gcc/adabkend.adb', 'if Switch_Chars (First .. Last) = "o"')
    has('gcc/switch-c.adb', 'Scan_Pos (Switch_Chars, Max, Ptr, Multiple_Unit_Index, C);')
    has('gpr/gpr/src/gpr-env.adb','Get_Name_String (Source.Display_File); Put_Name_Buffer;')
    has('gcc/lib-xref.adb','(Reference_Name (Source_Index (XE.Key.Eun)));')

    def parse_xml(name):
        builder = ET.TreeBuilder()
        parser = expat.ParserCreate()
        parser.StartElementHandler = builder.start
        parser.EndElementHandler = builder.end
        parser.CharacterDataHandler = builder.data
        def external(parent, context, system):
            assert '/' not in system and '\\' not in system
            child = parent.ExternalEntityParserCreate(context)
            child.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
            child.ExternalEntityRefHandler = lambda context, base, system, public: external(child, context, system)
            child.Parse(sources['db/'+system], True)
            return 1
        parser.ExternalEntityRefHandler = lambda context, base, system, public: external(parser, context, system)
        parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
        parser.Parse(sources[name], True)
        return builder.close()

    def applies(configuration, target):
        for group in configuration:
            if group.tag == 'config':
                continue
            assert group.tag in ['compilers','targets','hosts'], group.tag
            def match(child):
                for key, pattern in child.attrib.items():
                    if key == 'except':
                        if pattern and re.search(pattern, target):
                            return False
                    else:
                        value = {'name':'GNAT' if group.tag == 'compilers' else target,
                                 'version':'16.1','runtime':'default','language':'Ada'}[key]
                        if key == 'language':
                            if pattern.lower() != value.lower():
                                return False
                        elif not re.search(pattern, value):
                            return False
                return True
            matches = any(match(child) for child in group)
            if group.get('negate','').lower() == 'true':
                matches = not matches
            if not matches:
                return False
        return True

    selected = []
    fragments = []
    xml_files = sorted(name for name in sources if name.startswith('db/') and name.endswith('.xml'))
    assert len(xml_files) == 63
    for name in xml_files:
        tree = parse_xml(name)
        for index, config in enumerate(tree.findall('configuration')):
            fragment = config.findtext('config') or ''
            compiler = re.search(r'package\s+Compiler\s+is(.*?)end\s+Compiler;',fragment,re.I|re.S)
            if compiler is None or not re.search(r'\("ada"\)',compiler[1],re.I):
                continue
            yes = applies(config,'x86_64-linux')
            assert yes == applies(config,'x86_64-pc-linux-gnu')
            if yes:
                selected.append([name,index])
                fragments.append(compiler[1])
    assert selected == [['db/0_default.xml',0],['db/gnat.xml',0],['db/gnat.xml',8],['db/gnat.xml',11]]

    # GPR strings are decoded before substitution; punctuation inside a quoted
    # string is not a statement separator. Reject unexpected expression shapes.
    def attributes(fragment):
        tokens = re.findall(r'"(?:""|[^"])*"|[A-Za-z_][A-Za-z_0-9]*|[^\s]',fragment)
        result = {}
        k = 0
        while k < len(tokens):
            if tokens[k].lower() != 'for':
                k += 1
                continue
            name = tokens[k+1]
            k += 2
            while tokens[k].lower() != 'use':
                k += 1
            k += 1
            expr = []
            while tokens[k] != ';':
                expr.append(tokens[k]);k += 1
            result[name] = expr
        return result

    attrs = {}
    for fragment in fragments:
        attrs.update(attributes(fragment))
    def string_values(expr):
        return [token[1:-1].replace('""','"') for token in expr if token.startswith('"')]
    assert string_values(attrs['Leading_Required_Switches']) == ['-c','-x','ada','-gnatA','Ada']
    for absent in ['Trailing_Required_Switches','Object_File_Switches','Source_File_Switches',
                   'Dependency_Switches','Include_Switches','Include_Switches_Via_Spec','Response_File_Format']:
        assert absent not in attrs, absent
    assert string_values(attrs['Config_File_Unique']) == ['False']
    naming_lines = []
    for name in ['Config_Spec_File_Name_Pattern','Config_Body_File_Name_Pattern']:
        expr = attrs[name]
        assert all(token.startswith('"') or token == '&' for token in expr)
        text = ''.join(string_values(expr))
        for key,value in {'%s':'.ads','%b':'.adb','%c':'lowercase','%d':'-'}.items():
            text = text.replace(key,value)
        naming_lines.append(text)
    patterns = '\n'.join(naming_lines)+'\n'
    retained = sources['docs/evidence/unbounded-programs/retained-source-closure-20261017/driver-snapshots/293256/GNAT-TEMP-000002.TMP']
    assert patterns == retained and len(patterns.encode()) == 244
    template, = string_values(attrs['Config_Body_File_Name_Index'])[:1]
    indexed_line = template.replace('%u', 'main').replace('%f', 'main.adb').replace('%i', ' 1')+'\n'
    assert indexed_line == 'pragma Source_File_Name_Project (main, Body_File_Name => "main.adb", Index =>  1);\n'
    assert len(indexed_line) == 83
    naming = patterns + indexed_line
    assert len(naming) == 327
    (HERE/'naming.reconstructed.adc').write_text(naming)

    # Indexes are deliberately abstract path placeholders, not shell commands.
    leading = ['-c','-x','ada','-gnatA']
    project = ['-gnat2022','-gnata','-gnato']
    phase1 = leading + project + ['-gnatc','-gnates=<options>','-gnatis','-gnatec=<config>','-gnatem=<map>','<main>','-o','main~1.ali','-gnateI1']
    phase2 = leading + project + ['-gnatc','-gnates=<options>','-gnatec=<config>','-gnatem=<map>','<main>','-o','main~1.spark','-gnateI1','-gnateO=<objects>']
    datarep = leading + project + ['-S','-gnatR2js','-gnatws','-gnatx','-gnatis','-gnatec=<config>','-gnatem=<map>','<main>','-o','main~1.o','-gnateI1']
    A1 = ['-x','ada','-gnatA'] + project + ['-gnatc','-gnatis','-gnateI1']
    A2 = [s for s in A1 if s != '-gnatis']
    assert (len(A1),sum(map(len,A1)),max(map(len,A1))) == (9,53,9)
    assert (len(A2),sum(map(len,A2)),max(map(len,A2))) == (8,46,9)
    assert len(phase1) == len(phase2) == 16 and len(datarep) == 18
    for phase,name in [('frames','ALI_File'),('gnat2why','ALI_Closure')]:
        custom = attributes(parse_xml(phase+'/config.xml').find('configuration').findtext('config'))
        assert string_values(custom['Dependency_Kind']) == [name]
    X=25797
    p_ali=10
    F = (12+5)+64+64+53+3*9+110*56+5+(p_ali+161)+(2*p_ali+81)+2*(2*p_ali+65)+6+10+X*(p_ali+1138)+(16+10)+947
    R = max(17,64,12,p_ali+161,2*p_ali+81,2*p_ali+65,789,335,p_ali+14,289,26)
    assert R == 789 and F+1 < 2**31-1
    result = {'scope':identity['scope'],'compiler_selection':{'name':'GNAT','version':'16.1','runtime':'default','canonical_target':'x86_64-linux'},
        'all_base_xml_files_parsed':len(xml_files),'selected_Ada_Compiler_configurations':selected,
        'generated_naming':{'bytes':len(naming),'lines':3,'source_range_charge':4096,'ALI_dependency_entries':0,'temporary_basename':'GNAT-TEMP-000000.TMP','source_derived_not_captured':True},
        'phase1':{'argv_excluding_executable':phase1,'argc':len(phase1),'A_rows':A1,'A':9,'A_sum':53,'A_max':9,'argv_payload_bound':'4P+91'},
        'phase2':{'argv_excluding_executable':phase2,'argc':len(phase2),'A_rows_if_output_were_enabled':A2,'A':8,'A_sum':46,'A_max':9,'argv_payload_bound':'5P+94','ALI_output_disabled':True},
        'data_representation':{'argv_excluding_executable':datarep,'argc':len(datarep),'separate_native_component_required':True},
        'generic_ALI_join':{'A':9,'A_sum':53,'A_max':9,'C_dependencies':0,'ALI_emitted_filename_bound':10,'max_record_bytes_including_lf':R,'loose_file_byte_bound':F,'reader_buffer_byte_bound':F+1,'line_count_bound':9+150+3*X,'writer_record_condition':True,'reader_signed32_condition':True},
        'indexed_frontend_table_delta':{'ordinary_nodes':18,'dynamic_slots':162,'syntax_list_headers':2,'Name_entries':7,'Name_characters':74,'String_descriptors':2,'String_characters':16,'SFN_Table_entries':1,'SFN_Table_initial_object_bytes':120,'SFN_hash_bucket_bytes':808,'SFN_hash_new_wrapper_bytes':16,'Uint_entries':0,'Uint_digits':0},
        'production_orchestration_capacity_closed':False,'installed_executable_source_identity_established':False}
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__ == '__main__':
    main()
