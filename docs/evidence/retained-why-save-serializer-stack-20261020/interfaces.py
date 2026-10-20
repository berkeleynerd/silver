"""Source-selected callback contexts; native instruction addresses are checked."""
def why(module, *suffixes):
    return ['camlWhy3__'+module+'__'+s for s in suffixes]
def std(module, *suffixes):
    return ['camlStdlib__'+module+'__'+s for s in suffixes]
FORMAT_RETURNED = ['camlStdlib__Format__fun_2958','camlStdlib__Format__fun_2984',
 'camlStdlib__Format__k_1819','camlCamlinternalFormat__fun_6270',
 'camlCamlinternalFormat__fun_6280','camlCamlinternalFormat__fun_6520',
 'camlCamlinternalFormat__fun_6559','camlCamlinternalFormat__fun_6659']
FORMAT_SCALARS = std('Format','pp_print_int_901','pp_print_string_793','pp_print_char_913')
PRINTER_CALLBACKS = why('Pp','html_string_1054','space_762','print_list_622','print_list_pre_608') + why('Session_itp',
 'save_ident_4262','save_file_path_4247','save_arg_4301','fun_9969','fun_9980',
 'fun_10023','fun_10048','fun_10056','fun_10064','fun_10072','fun_10161','fun_10169',
 'fun_10242','fun_10253','fun_10289','fun_10321','fun_10329') + why('Termcode',
 'pp_sum_shape_version_1772','fun_9383','fun_9373')
HASH = std('Hashtbl','hash_1177')
EQUAL = why('Wstdlib','equal_271','equal_1382','equal_1826') + why('Whyconf','equal_1165')
COMPARE = why('Wstdlib','compare_268','compare_1830') + why('Whyconf','compare_1159') + std('String','compare_594')
SORT_COMPARE = why('Session_itp','fun_10193','fun_10204')
CALLBACK_CONTEXTS = {
 'camlStdlib__Ephemeron__equal_1252': why('Weakhtbl','equal_299'),
 'camlStdlib__Ephemeron__find_730': std('Ephemeron','hash_1334'),
 'camlStdlib__Ephemeron__find_rec_721': std('Ephemeron','equal_1252'),
 'camlStdlib__Filename__concat_814': std('Filename','is_dir_sep_473'),
 'camlStdlib__Hashtbl__do_bucket_734': why('Session_itp','fun_9928','fun_9955','fun_10389'),
 'camlStdlib__Hashtbl__do_bucket_769': why('Session_itp','fun_8412','fun_8446','fun_10397','fun_10364','fun_9947','fun_9949','fun_9951','fun_10184'),
 'camlStdlib__Hashtbl__find_1059': EQUAL,
 'camlStdlib__Hashtbl__find_rec_1053': EQUAL,
 'camlStdlib__Hashtbl__key_index_1028': HASH,
 'camlStdlib__Hashtbl__mem_in_bucket_1118': EQUAL,
 'camlStdlib__Hashtbl__replace_bucket_1100': EQUAL,
 'camlStdlib__List__fold_left_521': why('Session_itp','fun_8393','fun_8403','fun_8422','fun_8437','fun_10201'),
 'camlWhy3__Extmap__add_397': COMPARE,
 'camlWhy3__Extmap__find_409': COMPARE,
 'camlWhy3__Extmap__fold_489': why('Session_itp','fun_10367'),
 'camlWhy3__Extmap__iter_460': why('Session_itp','fun_10376') + why('Termcode','fun_9793'),
 'camlWhy3__Pp__print_list_622': why('Pp','space_762') + why('Session_itp','save_arg_4301') + why('Termcode','fun_9373') + FORMAT_SCALARS,
 'camlWhy3__Pp__print_list_pre_608': why('Pp','space_762') + why('Session_itp','save_arg_4301') + why('Termcode','fun_9373') + FORMAT_SCALARS,
}
for suffix in ['rev_merge_811','rev_merge_rev_821','rev_sort_832','sort_831']:
    CALLBACK_CONTEXTS['camlStdlib__List__'+suffix] = SORT_COMPARE
for suffix in ['fold_all_any_1945','fold_all_any_of_file_1938','fold_all_any_of_proofn_1849',
 'fold_all_any_of_theory_1931','fold_all_any_of_transn_1848','fun_8412']:
    CALLBACK_CONTEXTS['camlWhy3__Session_itp__'+suffix] = why('Session_itp','fun_10400')
# Each call to apply in these bodies consumes the closure returned by the fixed
# fprintf/kasprintf immediately preceding it. %a payloads remain callback roots.
for suffix in ['fun_10033','fun_9969','opt_4195','save_4319','save_arg_4301',
 'save_bool_def_4219','save_file_4312','save_float_def_4231','save_goal_4268',
 'save_ident_4262','save_int_def_4225','save_proof_attempt_4252','save_prover_4202',
 'save_result_4237','save_string_attrib_4214','save_theory_4306','save_trans_4269']:
    CALLBACK_CONTEXTS['camlWhy3__Session_itp__'+suffix] = FORMAT_RETURNED
CALLBACK_CONTEXTS['camlWhy3__Termcode__string_of_shape_1782'] = FORMAT_RETURNED
INDIRECT = {
 'camlCamlinternalLazy__force_lazy_block_362': std('Hashtbl','fun_1739') + ['camlCamlinternalLazy__raise_undefined_269','camlCamlinternalLazy__fun_468'],
 'camlStdlib__Ephemeron__find_rec_721': std('Ephemeron','get_data_1170'),
 'camlStdlib__Ephemeron__hash_1334': why('Weakhtbl','hash_296'),
 'camlStdlib__Hashtbl__hash_1177': why('Wstdlib','hash_275','tag_2176') + why('Whyconf','hash_1169') + std('Hashtbl','hash_1261'),
 'camlStdlib__Hashtbl__insert_bucket_710': ['caml_curry2_1'],
 'camlStdlib__Hashtbl__resize_721': ['caml_curry2'],
 'camlStdlib__List__iter_507': why('Ident','fun_6276') + why('Termcode','do_d_2936','fun_9586','fun_9731','fun_9435') + why('Session_itp','fun_10033','fun_10198','fun_10211','fun_10269','fun_10303','fun_10345'),
 'camlWhy3__Ident__id_unique_inner_6286': why('Ident','same_3128'),
 'camlWhy3__Wstdlib__compare_1830': why('Wstdlib','tag_2176'),
 'camlWhy3__Wstdlib__equal_1826': why('Wstdlib','tag_2176'),
 'camlWhy3__Wstdlib__tag_2176': why('Ident','tag_2120'),
 'camlWhy3__Weakhtbl__hash_296': why('Ident','tag_2120'),
 'camlWhy3__Weakhtbl__equal_299': why('Ident','tag_2120'),
 'camlWhy3__Pp__space_762': FORMAT_RETURNED,
}
for suffix in ['save_4319','save_file_4312','save_goal_4268','save_proof_attempt_4252','save_theory_4306','save_trans_4269']:
    INDIRECT['camlWhy3__Session_itp__'+suffix] = FORMAT_RETURNED
# These indirect jumps dispatch within the same body; they are not callbacks.
SWITCHES = {
 'camlWhy3__Pp__html_char_1049': ('5487ce',0x9e71f8,6),
 'camlWhy3__Session_itp__fold_all_any_1945': ('7f1019',0x9ec250,5),
 'camlWhy3__Session_itp__is_detached_1820': ('7f09de',0x9ec228,5),
 'camlWhy3__Termcode__t_shape_2345': ('7eabcc',0x9ec164,10),
}
OPENING_SITES = {'7eadb1':'caml_tuplify3','7eaf77':'caml_tuplify3','7eafcd':'caml_tuplify4'}
