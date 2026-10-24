"""Changed prospective RTS storage only; pure arithmetic, no native execution."""
I32, I64 = 2**31-1, 2**63-1
P = 188
R = '/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/16.1.0'
TOPLEVEL_RTS = '--RTS=' + R
RTS = TOPLEVEL_RTS + '/'  # GPR RUNTIME_DIR applies Name_As_Directory


def table(demand, low, initial, growth, size, high=I32):
    """Accepted derive.native_table_backing_row formula; factor=1."""
    assert isinstance(demand, int) and demand >= 0
    p = max(demand, initial)
    c = max(initial, demand+demand//1000, p*(100+growth)//100, p+10)
    checks = [initial <= I32, p*(100+growth) <= I64, c+1 <= I32,
              low-1 >= -2**31, low+c <= I32, low+demand-1 <= high,
              (c+1)*size <= I64]
    return dict(demand=demand, low=low, initial=initial, growth=growth,
                component_bytes=size, capacity=c, bytes=(c+1)*size,
                guards=checks, passed=all(checks))


def argv(argc, p=P):
    canonical = 2*argc
    longest = max(p+8, len(RTS), 24)
    objects = dict(C_argv=(argc+1)*8, decoded=96*argc,
                   canonical_C_argv=(canonical+1)*8,
                   Ada_pointers=16*canonical+16,
                   Ada_String=longest+16, C_String=longest+1,
                   obstack=max(4096, 4*(longest+67)+116),
                   GPR_String_vector=16*(2*argc)+16)
    return dict(argc_including_executable=argc, canonical=canonical,
                longest_argument=longest, individual_objects=objects,
                passed=canonical <= I32 and all(x <= I64 for x in objects.values()))


def fixed_transfer(args, fmap, names):
    """Only configuration-dependent coordinates; keep source owners' others.

    names is the owner's already path-adjusted Name_entries operand. Printed
    raw-library examples below are *partial coordinates*, not replacement
    full fixed-library semantic vectors.
    """
    new_names = names+22  # mapping filename and seven three-field records
    return dict(
        Compilation_Switches=table(11, 1, 30, 100, 16),
        Source_Search=table(4, 0, 10, 100, 16),
        Library_Search=table(5, 0, 10, 100, 16),
        ALI_Args=table(args+7*11, 1, 1000, 100, 16),
        File_Mapping=table(fmap+7, 1, 1000, 1000, 8),
        Path_Mapping=table(fmap+7, 1, 1000, 1000, 8),
        Name_Entries=table(new_names, -399999997, 6000, 100, 16, -300000000),
        Name_Chars=table(32768*new_names+5000, 0, 50000, 100, 1))


def gpr_context(nodes, strings, names_list, names, name_capacity,
                parses=1, evaluations=1, language_conversions=1):
    """Recompose actual context operands; never assume zero baseline.

    Multiplicities are caller-supplied context facts, not arbitrary caps.
    names is the previous GPR.Names vector length (different from GNAT Namet).
    Three fresh literal spellings pay RTS, Runtime_Dir and linker-path text.
    """
    assert all(isinstance(n, int) and n >= 0 for n in
               (nodes, strings, names_list, names, name_capacity, parses,
                evaluations, language_conversions))
    assert name_capacity >= names
    rows = dict(Project_Nodes=table(nodes+20*parses, 1, 1000, 100, 352, 99999999),
                String_Elements=table(strings+7*evaluations, 1, 200, 100, 80),
                Name_Lists=table(names_list+7*language_conversions, 1, 10, 100, 32))
    # Indefinite_Vectors append doubles existing storage up to Max_Length.
    # An unclamped sufficient envelope avoids relying on that saturation case.
    n = names+3
    c = max(name_capacity, 2*n)
    vector = dict(length=n, capacity_upper=c, pointer_array_bytes=16*c+16,
                  longest_new_element_bytes=max(len(RTS), len(R)+1,
                      len('-Wl,-rpath-link,'+R+'//adalib'))+48,
                  passed=n <= 99999998 and c <= 99999998 and 16*c+16 <= I64)
    return dict(tables=rows, Name_Vector=vector,
                passed=all(x['passed'] for x in rows.values()) and vector['passed'])


def gpr_unit_transfer_conditions():
    # Algebraic endpoints, NOT observed context counts. Evaluate the complete
    # backing arithmetic at the sufficient maximal baseline for each operand.
    limits = dict(Project_Nodes=49999979, String_Elements=1073741816,
                  Name_Lists=1073741816, Name_Vector_length=49999996,
                  Name_Vector_capacity=99999998)
    rows = gpr_context(limits['Project_Nodes'], limits['String_Elements'],
                       limits['Name_Lists'], limits['Name_Vector_length'],
                       limits['Name_Vector_capacity'])
    return dict(per_traversal_sufficient_baseline_limits=limits,
                endpoint_arithmetic=rows,
                observed_or_established_actual_context_counts=False)


def rts_objects():
    payloads = dict(Runtime_Dir=162, include_local_root=163,
                    object_local_root=163, include_suffix=10, object_suffix=6,
                    include_default=173, object_default=169, RTS_Specified=169,
                    stored_switch=169, source_path_token=173, object_path_token=169,
                    source_normalized=174, object_normalized=170)
    return dict(payload_bytes=payloads,
                individual_String_bytes={k:v+16 for k,v in payloads.items()},
                Read_Default_Search_Dirs_C_buffer=179,
                Normalize_Pathname_native_max_path=4096,
                inherited_pathfile_bytes=0,
                runtime_pathfile_branch='both absent; no file-length allocation',
                passed=all(v+16 <= I32 for v in payloads.values()))


def mapping_objects():
    names = ('main.adb', 'silver_io.ads', 'silver_io.adb',
             'silver_output_libc.ads', 'silver_arguments.ads',
             'silver_arguments.adb', 'silver_runtime.ads')
    work = '/tmp/program-XXXXXX'
    raw = ''.join(name[:-4]+('%s' if name.endswith('.ads') else '%b')+'\n'+
                  name+'\n'+work+'/'+name+'\n' for name in names).encode()
    return dict(source_names=names, records=len(names), bytes=len(raw),
                reader_bytes=len(raw)+17, object_pathfile_bytes=35,
                object_path_reader_bytes=52, passed=len(raw)+17 <= I32)
