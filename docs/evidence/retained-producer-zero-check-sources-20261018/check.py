#!/usr/bin/env python3
"""Pin an offline source-path audit; run no compiler, Why3 or proof tool."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]


def block(text, opening, closing):
    start = text.index(opening)
    return text[start:text.index(closing, start) + len(closing)]


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE.parent / 'unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['spark_archive_sha256']
    with tarfile.open(archive) as tar:
        source = {}
        for row in identity['spark_files']:
            data = tar.extractfile('spark-source/' + row['path']).read()
            assert len(data) == row['bytes']
            assert hashlib.sha256(data).hexdigest() == row['sha256']
            source[row['path']] = data.decode()
    for row in identity['local_files']:
        data = (PROJECT / row['path']).read_bytes()
        assert len(data) == row['bytes']
        assert hashlib.sha256(data).hexdigest() == row['sha256']

    driver = block(source['src/why/gnat2why-driver.adb'],
                   '   procedure Do_Generate_VCs (E : Entity_Id) is',
                   '   end Do_Generate_VCs;')
    assert 'Old_Num : constant Natural := Num_Registered_VCs_In_Why3;' in driver
    guard = block(driver, '      if Num_Registered_VCs_In_Why3 > Old_Num then',
                  '      end if;')
    assert driver.count('Print_GNAT_Json_File (File_Name);') == 1
    assert driver.count('Run_Gnatwhy3 (E, File_Name);') == 1
    assert 'Print_GNAT_Json_File (File_Name);' in guard
    assert 'Run_Gnatwhy3 (E, File_Name);' in guard
    registry = source['src/why/gnat2why-error_messages.adb']
    register_entity = block(registry, '   procedure Register_VC_Entity (E : Entity_Id) is',
                            '   end Register_VC_Entity;')
    assert 'Registered_VCs_In_Why3' not in register_entity
    assert 'VC_Set_Table.Insert' in register_entity
    assert 'Registered_VCs_In_Why3 := Registered_VCs_In_Why3 + 1;' in registry
    ignored = source['src/spark/spark_util.ads']
    assert '| N_Null_Statement' in ignored
    assert 'N_Ignored_In_SPARK in N_Ignored_In_Marking | N_Label | N_Body_Stub;' in ignored
    expr = source['src/why/gnat2why-expr.adb']
    assert 'when N_Ignored_In_SPARK' in expr
    assert '| Pragma_SPARK_Mode' in expr
    literal = block(expr, '   function Transform_String_Literal\n'
                    '     (N : Node_Id; Domain : EW_Domain; Params : Transformation_Params)\n'
                    '      return W_Expr_Id\n   is',
                    '   end Transform_String_Literal;')
    assert 'if not Is_True_Boolean (+Checks) then' in literal
    assert 'Compile_Time_Known_Value (Type_High_Bound (Idx_Ty))' in literal
    assert 'Expr_Value (Low) + UI_From_Int (Length - 1)' in literal
    types = source['src/spark/spark_util-types.adb']
    conversion = block(types, '   function Check_Needed_On_Conversion',
                       '   end Check_Needed_On_Conversion;')
    assert 'elsif To_R = Retysp (Etype (From_R)) then\n         return False;' in conversion
    pre = block(source['src/why/why-inter.adb'],
                '   function Why_Subp_Has_Precondition',
                '   end Why_Subp_Has_Precondition;')
    assert 'Has_Contracts (E, Pragma_Precondition)' in pre
    assert 'Pragma_Postcondition' not in pre
    assert 'Has_Classwide_Or_Inherited_Precondition' in pre
    type_vcs = block(source['src/why/gnat2why-types.adb'],
                     '   procedure Generate_VCs_For_Type (E : Type_Kind_Id) is',
                     '   end Generate_VCs_For_Type;')
    assert 'if not Need_Check then\n         return;' in type_vcs

    silver = (PROJECT / 'src/silver.adb').read_text()
    assert 'Output_Accepted := not Null_Accepted and then' in silver
    assert 'else "   for Source_Files use (""main.adb"");"' in silver
    assert '" -U --mode=all --report=all"' in silver
    io_spec = (PROJECT / 'src/silver_io.ads').read_text()
    assert 'procedure Put (Item : String)' in io_spec
    assert 'Pre =>' not in io_spec

    fixtures = []
    for name, size, output_mode in [('null', 64, False), ('literal_put', 95, True)]:
        data = (HERE / (name + '.adb')).read_bytes()
        assert len(data) == size
        fixtures.append(dict(name=name, source_bytes=size,
            source_sha256=hashlib.sha256(data).hexdigest(),
            output_mode=output_mode,
            source_audit_main_registered_why3_check_delta=0,
            main_why3_launches=0, main_terminal_tasks=0,
            main_response_records=0, main_solver_launches=0,
            main_raw_why3_response_bytes=0,
            selected_fixed_library_why3_files=(5 if output_mode else 0),
            fixed_library_terminal_task_bound=(None if output_mode else 0),
            native_frontend_and_flow_capacity_required=True,
            final_spark_report_capacity_required=True))
    result = dict(spark_revision=identity['spark_revision'],
        spark_archive_sha256=identity['spark_archive_sha256'],
        native_or_proof_executions=0,
        fixtures=fixtures,
        scope='Pinned source audit and fixture arithmetic; branch exclusions are argued in the research document, not mechanically proved here; complete retained-tool feasibility remains open')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
