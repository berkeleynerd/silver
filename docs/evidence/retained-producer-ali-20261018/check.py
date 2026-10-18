#!/usr/bin/env python3
"""Pinned-source reconciliation and conditional null-family ALI arithmetic only."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    sources = {}
    manifest_path = PROJECT / identity['gcc_manifest']['path']
    assert hashlib.sha256(manifest_path.read_bytes()).hexdigest() == identity['gcc_manifest']['sha256']
    manifest = json.loads(manifest_path.read_text())
    assert manifest['commit'] == identity['gcc_commit']
    gcc_index = {r['path']: r for r in manifest['files']}
    for archive in identity['archives']:
        path = PROJECT / archive['path']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == archive['sha256']
        with tarfile.open(path) as tar:
            for row in archive['files']:
                data = tar.extractfile(row['member']).read()
                assert len(data) == row['bytes']
                assert hashlib.sha256(data).hexdigest() == row['sha256']
                if 'git_blob_sha1' in row:
                    assert hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest() == row['git_blob_sha1']
                    retained = gcc_index.get(row['name']) or gcc_index['gcc/ada/' + row['name']]
                    assert retained['sha256'] == row['sha256']
                sources[row['name']] = data.decode()
    for row in identity['local_files']:
        data = (PROJECT / row['path']).read_bytes()
        assert len(data) == row['bytes']
        assert hashlib.sha256(data).hexdigest() == row['sha256']
        sources[row['path']] = data.decode()

    def has(name, fragment):
        assert ' '.join(fragment.split()) in ' '.join(sources[name].split()), (name, fragment)

    has('gnat1drv.adb', 'Write_ALI (Object => True);')
    has('frontend.adb', 'elsif not Temp_File then Prepcomp.Add_Dependency (Source_Config_File);')
    has('prepcomp.adb', 'Add_Preprocessing_Dependency (Dependencies.Table (Index));')
    has('sem_elab.adb', 'if GNATprove_Mode then return False;')
    recording = sources['sem_elab.adb'].split('function Invocation_Graph_Recording_OK return Boolean is')[1].split('end Invocation_Graph_Recording_OK;')[0]
    assert 'if GNATprove_Mode then' in recording and 'return False;' in recording
    has('src/why/gnat2why-driver.adb', 'Initialize_ALI; Initialize_ALI_Source;')
    has('src/why/gnat2why-driver.adb', 'Free (Text); Read_Withed_ALIs (Main_Lib_Id);')
    has('ali-util.adb', 'and then Get_Name_Table_Int (Afile) = 0')
    has('ali-util.adb', 'Read_Withed_ALIs (Idread);')
    has('ali.adb', '--  This ALI parser does not care about Xref lines. return Id;')
    has('ali.adb', "Args.Table (Args.Last) := new String'(Name_Buffer (1 .. Name_Len));")
    has('ali.adb', 'Linker_Options.Increment_Last; Notes.Increment_Last;')
    has('osint.adb', "Len := Integer (File_Length (Name_Buffer'Address, Lib_File_Attr));")
    has('osint.adb', 'Text := new Text_Buffer (Lo .. Hi);')
    has('types.ads', "type Text_Ptr is new Int range -4 .. Int'Last;")
    has('src/flow/flow_generated_globals-phase_2.adb', 'Line : constant String := Get_Line (ALI_File);')
    has('libgnat/a-textio.adb', "Buffer : String (1 .. Integer'Max (500, S'Length));")
    has('libgnat/a-textio.adb', 'return Get_Rest (R);')
    has('lib-util.adb', 'Max_Line : constant Natural := 2 * Hostparm.Max_Name_Length + 64;')
    has('lib-util.adb', 'Max_Buffer : constant Natural := 1000 * Max_Line;')
    has('hostparm.ads', 'Max_Name_Length : constant := 1024;')
    has('gnatvsn.ads', 'Ver_Len_Max : constant := 256;')
    has('opt.ads', 'Table_Factor : Int := 1;')
    has('table.adb', 'Length := Int\'Max (Int (New_Length), Length + 10);')
    has('ali.adb', 'Sig_Map.Create (500);')
    has('libgnat/g-dynhta.adb', "Nod := new Node'(Key, Value, null, null);")

    system = sources['docs/evidence/retained-producer-null-global-20261018/system.ali'].encode()
    probe = sources['docs/evidence/retained-producer-fixed-20261018/main.ali'].encode()

    def inventory(data):
        lines = data.splitlines()
        return {'bytes': len(data), 'lines': len(lines), 'max_line_excluding_lf': max(map(len, lines)),
                'A': sum(line.startswith(b'A ') for line in lines),
                'A_sum': sum(len(line)-2 for line in lines if line.startswith(b'A ')),
                'A_max': max([len(line)-2 for line in lines if line.startswith(b'A ')] or [0]),
                'U': sum(line.startswith(b'U ') for line in lines),
                'withs': sum(line[:2] in [b'W ', b'Y ', b'Z '] for line in lines),
                'D': sum(line.startswith(b'D ') for line in lines),
                'constructs': sum(line.startswith(b'G c ') for line in lines),
                'relations': sum(line.startswith(b'G r ') for line in lines),
                'GG': sum(line.startswith(b'GG ') for line in lines)}

    sysinv = inventory(system)
    probeinv = inventory(probe)
    assert {k: sysinv[k] for k in ['A','U','withs','D','constructs','relations','GG']} == {'A':10,'U':1,'withs':0,'D':1,'constructs':5,'relations':0,'GG':0}
    assert probeinv['constructs'] == probeinv['relations'] == 0
    assert probeinv['GG'] == 11

    def capacity(initial, increment, demand):
        result = initial
        while result < demand:
            result = max(result * (100 + increment) // 100, result + 10)
        return result

    def record_bound(source, name):
        body = sources[source].split('type ' + name + ' is record', 1)[1].split('end record;', 1)[0]
        body = re.sub(r'--[^\n]*', '', body)
        fields = re.findall(r'^\s*([A-Za-z][A-Za-z0-9_, ]*)\s*:\s*([^;]+);', body, re.M)
        count = 0
        bound = 0
        for names, typ in fields:
            n = len(names.split(','))
            count += n
            # Per-field padding included. Other selected fields are scalars,
            # pointers, Time_Stamp_Type (14 bytes), or Version_String (8 bytes).
            b = 304 if typ.strip().startswith('Restrictions_Info') else 264 if 'Ver_Len_Max' in typ else 16
            bound += n * b
        assert count > 0
        return {'fields': count, 'component_byte_bound': bound}

    records = {name: record_bound(source, name) for source, name in [
        ('ali.ads','ALIs_Record'),('ali.ads','Unit_Record'),('ali.ads','With_Record'),
        ('ali.ads','Sdep_Record'),('ali.ads','CUDA_Kernel_Record'),('ali.ads','Interrupt_State_Record'),
        ('ali.ads','Specific_Dispatching_Record'),('ali.ads','Linker_Option_Record'),
        ('ali.ads','Notes_Record'),('ali.ads','No_Dep_Record'),('ali.ads','Xref_Section_Record'),
        ('ali.ads','Xref_Entity_Record'),('ali.ads','Xref_Record'),('ali-util.ads','Source_Record'),
        ('ali.adb','Invocation_Construct_Record'),('ali.adb','Invocation_Relation_Record'),
        ('ali.adb','Invocation_Signature_Record')]}
    xrefs = 50 + 16 * (10 + 1) + 2 * (12784 + 1) + 1
    assert xrefs == 25797

    def table_bounds(A, C):
        shapes = [
            ('ALIs','ALIs_Record',2,500,200),('Units','Unit_Record',2,100,200),
            ('Withs','With_Record',1,5000,200),('Args',None,A+10,1000,100),
            ('Sdep','Sdep_Record',C+3,5000,200),
            ('Invocation_Constructs','Invocation_Construct_Record',5,2500,200),
            ('Invocation_Relations','Invocation_Relation_Record',0,2500,200),
            ('Invocation_Signatures','Invocation_Signature_Record',5,2500,200),
            ('Linker_Options','Linker_Option_Record',1,200,400),('Notes','Notes_Record',1,200,400),
            ('No_Deps','No_Dep_Record',0,200,400),('CUDA_Kernels','CUDA_Kernel_Record',0,100,200),
            ('Interrupt_States','Interrupt_State_Record',0,100,200),
            ('Specific_Dispatching','Specific_Dispatching_Record',0,100,200),
            ('Xref_Section','Xref_Section_Record',0,50,300),('Xref_Entity','Xref_Entity_Record',0,500,300),
            ('Xref','Xref_Record',0,2000,300),('Source','Source_Record',0,1000,200)]
        result = {}
        for name, record, demand, initial, increment in shapes:
            backing = capacity(initial, increment, demand)
            component = records[record]['component_byte_bound'] if record else 8
            result[name] = {'population':demand, 'capacity':backing, 'component_bound':component,
                            'backing_byte_bound':backing*component,
                            'capacity_and_one_past_fit_conservative_id_limit':backing+1 <= 99999999}
        return result

    def envelope(P, A, A_sum, A_max, C, V_lib=12, V_spark=10):
        # Excludes source lexical/location obligations, supplied by frontend packet.
        file_bytes = (V_lib+5) + 64 + 64 + A_sum + 3*A + 110*56 + 5 + (P+161) + (2*P+81) + (C+2)*(2*P+65) + 6 + 10 + xrefs*(P+1138) + (16+V_spark) + 947
        record_including_lf = max(V_lib+5,64,A_max+3,P+161,2*P+81,2*P+65,789,335,P+14,289,16+V_spark)
        return {'P':P,'A':A,'A_sum':A_sum,'A_max':A_max,'C':C,
                'file_byte_bound':file_bytes,'record_byte_bound_including_lf':record_including_lf,
                'line_count_bound':A+C+150+3*xrefs,
                'writer_record_alternative':record_including_lf <= 2112,
                'writer_whole_file_alternative':file_bytes < 2112000,
                'reader_buffer_bytes':file_bytes+1,'reader_signed32_with_one_past':file_bytes+1 <= 2**31-1,
                'quoted_name_buffer_bytes':2*P+2,
                'Get_Line_largest_string_object':max(500,record_including_lf-1),
                'Get_Line_recursion_bound':2+max(0,((record_including_lf-2)//500).bit_length()),
                'writer_sort_vector_bytes':4*(xrefs+1),
                'writer_xref_backing_capacity':capacity(5000,300,xrefs)}

    # These are arithmetic examples using a historical direct-probe A/C shape.
    # They deliberately do not assert that GPRbuild's production descriptor is it.
    examples = [envelope(P, probeinv['A'], probeinv['A_sum'], probeinv['A_max'], probeinv['D']-2) for P in [222,4096]]
    assert examples[0]['writer_record_alternative']
    assert not examples[1]['writer_record_alternative']
    assert all(row['reader_signed32_with_one_past'] for row in examples)
    result = {'scope':identity['scope'],'installed_System_ALI':sysinv,
              'historical_direct_probe_not_production_descriptor':probeinv,
              'xref_backing_demand':xrefs,'record_component_bounds':records,
              'reader_tables_at_historical_probe_A_C_shape_not_production':table_bounds(probeinv['A'], probeinv['D']-2),
              'conditional_arithmetic_examples_not_production_evaluation':examples}
    output = json.dumps(result, indent=2)+'\n'
    (HERE/'result.json').write_text(output)
    print(output)


if __name__ == '__main__':
    main()
