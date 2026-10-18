#!/usr/bin/env python3
"""Source-selected literal Main producer core; no compiler or prover execution.

The general producer envelope remains authoritative for live construction.
The pinned zero-check source argument excludes Main's JSON serialization only.
This is a research component, not an admission predicate for the whole pipeline.
"""
import hashlib
import json
from pathlib import Path
import re
import runpy
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = HERE.parent
I32 = 2**31 - 1


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


class Context:
    def __init__(self):
        manifest = json.loads((HERE / 'inputs.json').read_bytes())
        for row in manifest['files']:
            require(identity((REPO / row['path']).read_bytes()) ==
                    {key: row[key] for key in ('bytes', 'sha256')},
                    'changed specialization input: ' + row['path'])
        general_dir = EVIDENCE / 'retained-producer-composition-20261018'
        for path, digest in json.loads((general_dir / 'result.json').read_bytes())['input_sha256'].items():
            require(identity((EVIDENCE / path).read_bytes())['sha256'] == digest,
                    'changed general producer input: ' + path)
        # The old source-path record predates indexed Main discovery. Its
        # external SPARK identities still apply; current local files are pinned
        # above and their relevant output selection is checked below.
        zero_dir = EVIDENCE / 'retained-producer-zero-check-sources-20261018'
        zero = json.loads((zero_dir / 'identity.json').read_bytes())
        archive = EVIDENCE / 'unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
        require(identity(archive.read_bytes())['sha256'] == zero['spark_archive_sha256'],
                'changed retained SPARK archive')
        sources = {}
        with tarfile.open(archive) as retained:
            for row in zero['spark_files']:
                data = retained.extractfile('spark-source/' + row['path']).read()
                require(identity(data) == {key: row[key] for key in ('bytes', 'sha256')},
                        'changed zero-check source: ' + row['path'])
                sources[row['path']] = data.decode()
        block = runpy.run_path(str(zero_dir / 'check.py'))['block']
        driver = block(sources['src/why/gnat2why-driver.adb'],
                       '   procedure Do_Generate_VCs (E : Entity_Id) is',
                       '   end Do_Generate_VCs;')
        guard = block(driver, '      if Num_Registered_VCs_In_Why3 > Old_Num then',
                      '      end if;')
        for call in ('Print_GNAT_Json_File (File_Name);', 'Run_Gnatwhy3 (E, File_Name);'):
            require(driver.count(call) == 1 and call in guard,
                    'changed producer emission/launch guard')
        require('Old_Num : constant Natural := Num_Registered_VCs_In_Why3;' in driver,
                'changed producer registration snapshot')
        silver = (REPO / 'src/silver.adb').read_text()
        require('Output_Accepted := not Null_Accepted and then' in silver and
                '" -U --mode=all --report=all"' in silver,
                'changed selected output verification route')
        io_spec = (REPO / 'src/silver_io.ads').read_text()
        require('procedure Put (Item : String)' in io_spec and
                'procedure Put_Line (Item : String)' in io_spec and
                'Pre =>' not in io_spec, 'changed selected output contracts')
        self.literal = runpy.run_path(str(EVIDENCE /
            'unbounded-programs/retained-native-expansion-20261017/derive-literal-output.py'))
        self.general = runpy.run_path(str(general_dir / 'check.py'))
        self.fixed, self.modules = self.general['fixed_envelope']()
        self.schema = json.loads((EVIDENCE /
            'retained-producer-storage-20261018/serialization.json').read_bytes())['schema']
        self.verified_local_inputs = len(manifest['files'])
        self.verified_external_sources = len(zero['spark_files'])


def source_counts(raw, context):
    """Recognize the complete family before deriving its zero-check premise."""
    require(all(32 <= byte <= 126 or byte in (9, 10, 13) for byte in raw),
            'current ASCII source alphabet required')
    native = context.literal['source_counts'](raw)
    require(native['maximum_literal_length'] <= I32,
            'static String last index exceeds Standard.Positive')
    words = [match[0] for match in context.literal['TOKEN'].finditer(raw)
             if re.fullmatch(rb'[A-Za-z][A-Za-z_0-9]*', match[0])]
    c, n = native['output_calls'], native['null_statements']
    why = dict(W=len(words), I=max(map(len, words)), S=c, N=0,
               context=1, dots=c, calls_with_actual=c, C_lib=c, output=c,
               X=c, H_chars=native['decoded_literal_bytes'], null=n,
               shape_regions=[dict(dots=1, calls_with_actual=1) for _ in range(c)]
                             + [dict(null=1) for _ in range(n)])
    return native, why


def retained_conditions(general):
    """Keep every general core conjunct except its per-file JSON byte bound.

    Even the now-unneeded emitted-occurrence and quoted-string bounds remain
    conservative restrictions. No construction, pool or undo condition is lost.
    """
    totals, aux, lengths = general['totals'], general['auxiliary'], general['string_lengths']
    return dict(
        Why_nodes=totals[0] <= 2**30-1,
        Why_lists=totals[1] <= 2**30,
        Why_list_elements=totals[2] <= I32,
        retained_occurrence_envelope=totals[3] <= I32,
        Why_intern_pool=aux['why_calls'] <= 1610612741,
        retained_string_length_envelope=max(value for key, value in lengths.items()
            if key != 'symbol_set_characters') <= 1073741822,
        common_intern_pool=aux['common_calls'] <= 1610612741,
        Why_symbol_map=aux['why_symbol_map'] <= 1610612741,
        source_node_domain=aux['A_total'] <= 1610612741,
        scoped_undo_peak=aux['undo_peak'] <= I32)


def evaluate(raw, context, path_bytes=512):
    require(type(path_bytes) is int and path_bytes >= 0, 'nonnegative integer path bound')
    native, counts = source_counts(raw, context)
    general = context.general['compose'](counts, context.schema,
        context.fixed, context.modules, path_bytes)
    conditions = retained_conditions(general)
    require(general['producer_core_fits'] ==
            (all(conditions.values()) and general['json_bytes'] <= I32-1),
            'general core conjuncts changed')
    return dict(source=identity(raw), source_counts=native, Why_source_counts=counts,
        path_bytes=path_bytes, general_core=general, conditions=conditions,
        literal_Main_core_fits=all(conditions.values()),
        failed_predicates=[key for key, value in conditions.items() if not value],
        source_selected_Main_registered_Why3_checks=0,
        Main_gnat_json_files=0, Main_gnat_json_bytes=0,
        Main_Why3_launches=0, Main_solver_launches=0,
        hypothetical_general_JSON_bytes=general['json_bytes'],
        fixed_library_Why3_inputs=5,
        fixed_library_capacity_still_required=True,
        native_frontend_and_flow_capacity_still_required=True,
        final_spark_report_capacity_still_required=True,
        whole_literal_pipeline_capacity_established=False,
        production_admission_changed=False, native_tool_executions=0,
        premises=['Relevant installed producer behavior matches the reviewed source.',
                  'The selected ordinary Standard.String literal and unchanged output contracts apply.',
                  'Other native/producer representations and fixed-library processes retain their own bounds.'])
