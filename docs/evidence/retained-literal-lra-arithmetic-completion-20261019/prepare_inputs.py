#!/usr/bin/env python3
"""Offline extraction of the exact source/repository inputs; no compiler run."""
from pathlib import Path
import argparse, hashlib, json, subprocess, tarfile
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
def ident(b): return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
# Literal LF endpoints, with at least one operative expression in each span.
SPEC='''lra.cc|229|246|lra_assign_reg_val;lra_set_regno_unique_value
lra.cc|249|285|lra_invalidate_insn_regno_info;lra_set_insn_deleted
lra.cc|629|752|insn_code_data;n_bytes = sizeof;data->operand[i].type
lra.cc|877|982|collect_non_operand_hard_regs;GET_RTX_LENGTH;XVECLEN
lra.cc|988|1162|arg_hard_regs[FIRST_PSEUDO_REGISTER];operand_mode[MAX_RECOG_OPERANDS];get_preferred_alternatives
lra.cc|1232|1303|lra_update_insn_recog_data;constraints[MAX_RECOG_OPERANDS]
lra.cc|1344|1422|++last_reg_value;preferred_hard_regno_profit1 = 0;offset = 0
lra.cc|1484|1588|add_regs_to_insn_regno_info;GET_RTX_LENGTH;XVECLEN
lra.cc|1709|1798|lra_rtx_hash;case SYMBOL_REF:;case 'u':
lra.cc|2420|2667|lra_live_range_iter =;lra_curr_reload_num = 0;lra_eliminate (true, false)
lra-int.h|24|30|LRA_MAX_INSN_RELOADS
lra-int.h|247|287|LRA_LOSER_COST_FACTOR 6;LRA_MAX_REJECT 600;LRA_MAX_INHERITANCE_PASSES 2
lra-int.h|529|561|lra_update_reg_val_offset;offset += incr;lra_assign_reg_val
lra-eliminations.cc|74|115|poly_int64 previous_offset;NUM_ELIMINABLE_REGS
lra-eliminations.cc|243|278|hard_regno >= FIRST_PSEUDO_REGISTER;self_elim_offsets
lra-eliminations.cc|767|901|mark_not_eliminable;curr_sp_change += offset;GET_RTX_LENGTH
lra-eliminations.cc|922|935|substed_operand[MAX_RECOG_OPERANDS];orig_operand[MAX_RECOG_OPERANDS]
lra-eliminations.cc|1133|1376|spill_pseudos;targetm.compute_frame_layout;ep->offset = ep->previous_offset = -1;curr_sp_change = 0
lra-eliminations.cc|1439|1563|if (frame_pointer_needed;if (flag_checking);insns_with_changed_offsets
lra-constraints.cc|198|274|get_hard_regno;SMALL_REGISTER_CLASS_P;targetm.class_likely_spilled_p
lra-constraints.cc|450|477|extract_mem_from_operand;return op
lra-constraints.cc|548|625|get_equiv;init_curr_operand_mode
lra-constraints.cc|2134|2168|static unsigned int curr_small_class_check = 0;small_class_input_nums[op_class]++
lra-constraints.cc|2193|3595|process_alt_operands;curr_small_class_check++;losers * LRA_LOSER_COST_FACTOR + reject;losers == 0 && !curr_alt_class_change_p
lra-constraints.cc|3848|3905|process_address_1;extract_mem_from_operand;return false
lra-constraints.cc|4180|4199|for (int i = 0; i < 10;return res
lra-constraints.cc|4233|4256|simple_move_p;targetm.register_move_cost
lra-constraints.cc|4335|4517|goal_alt_matched[MAX_RECOG_OPERANDS][MAX_RECOG_OPERANDS];best_losers = best_overall = INT_MAX;process_alt_operands
lra-constraints.cc|4688|4710|goal_alt_win
lra-constraints.cc|5450|5465|changed_nops[MAX_RECOG_OPERANDS + 1]
lra-constraints.cc|5560|5605|lra_constraint_iter++;lra_eliminate (false, first_p)
lra-constraints.cc|5675|5705|min_len = new_min_len;new_insns_num = 0;new_insns_num++
lra-constraints.cc|6982|7011|to_inherit[LRA_MAX_INSN_RELOADS];to_inherit_num++
lra-constraints.cc|7523|7595|REG_BR_PROB_BASE * param_lra_inheritance_ebb_probability_cutoff;curr_usage_insns_check = 0
lra-assigns.cc|170|257|regno_assign_info[i].freq;lra_reg_info[r2].freq - lra_reg_info[r1].freq
lra-assigns.cc|411|445|1U << lra_max_pseudos_points_log2_considered_for_preferences;lra_live_max_point + 1
lra-assigns.cc|705|790|update_hard_regno_preference;lra_setup_reload_pseudo_preferenced_hard_reg
lra-assigns.cc|1163|1278|nregs_diff =;pseudo_compare_func;lra_hard_reg_usage
lra-assigns.cc|1286|1348|improve_inheritance;lra_constraint_new_regno_start
lra-assigns.cc|1394|1717|nfails == 0;n = 0;lra_assignment_iter++;r->finish - r->start + 1
lra-lives.cc|547|592|preferred_hard_regno_profit1 += profit;preferred_hard_regno_profit2 += profit
lra-lives.cc|726|783|lra_set_insn_deleted
lra-lives.cc|810|863|src_regno >= lra_constraint_new_regno_start;lra_setup_reload_pseudo_preferenced_hard_reg
lra-lives.cc|1373|1415|preferred_hard_regno_profit1 = 0;lra_hard_reg_usage[hard_regno] +=
lra-spills.cc|655|766|alter_subregs;GET_RTX_FORMAT
lra-spills.cc|767|879|SET_REGNO;lra_invalidate_insn_data;delete_insn
recog.cc|1511|1565|general_operand;CONSTANT_P
recog.cc|1646|1721|register_operand;immediate_operand;targetm.legitimate_constant_p
recog.cc|2729|2750|get_preferred_alternatives;BA_PREFERRED_FOR_SIZE
recog.cc|2931|3080|op_alt[i].reject += 6;1U << filter_id;XALLOCAVEC (const char *, n_operands)
recog.cc|3134|3164|struct funny_match;constraints[MAX_RECOG_OPERANDS]
recog.cc|3453|3464|which_alternative++;constrain_operands (-1, alternatives)
params.opt|464|478|Init(40);Init(500);Init(30)
profile-count.h|65|79|REG_BR_PROB_BASE  10000
profile-count.h|1076|1110|operator*;nonzero_p
predict.cc|3866|3900|expensive_function_p;count * threshold;sum += bb->count
config/i386/i386.h|1789|1798|ELIMINABLE_REGS;INITIAL_ELIMINATION_OFFSET
config/i386/i386.cc|6074|6084|ix86_get_frame_size;return 0
config/i386/i386.cc|6857|6938|ix86_nsaved_regs;ix86_nsaved_sseregs;ix86_initial_elimination_offset
config/i386/i386.cc|6999|7377|save_regs_using_push_pop;ix86_compute_frame_layout;offset = INCOMING_FRAME_SP_OFFSET;ROUND_UP (offset, preferred_alignment)
config/i386/i386.cc|21200|21224|ix86_class_likely_spilled_p;return false
config/i386/i386.cc|21382|21402|ix86_class_max_nregs;CEIL (GET_MODE_SIZE
config/i386/i386.md|921|927|"x64";"nox64"
config/i386/i386.md|996|1004|preferred_for_size;preferred_for_speed
config/i386/i386.md|2594|2599|*movdi_internal;riFo,riF,Z,rem,i
config/i386/i386.md|2656|2674|"0,1,17,18";"2,3,4,5,10,11"
config/i386/i386.md|2746|2765|preferred_for_speed;symbol_ref "true";attr "enabled"
config/i386/i386.md|20469|20500|define_mode_attr c;define_insn "*call"
config/i386/i386.md|20923|20927|unspec_volatile [(const_int 0)]
config/i386/i386.md|21055|21061|define_insn "nop";const_int 0
config/i386/constraints.md|216|222|"Bz";constant_call_address_operand
config/i386/predicates.md|690|702|constant_call_address_operand;match_code "symbol_ref"
config/i386/predicates.md|801|806|call_insn_operand;constant_call_address_operand
genextract.cc|378|403|insn_extract;rtx *ro = recog_data.operand
genextract.cc|478|501|ro[%d];recog_data.dup_loc[%d]
genrecog.cc|3384|3481|create_subroutine;find_subroutines (type, trans->to;size.depth += 1
genrecog.cc|4799|4852|print_subroutine_call;recog_%d (x1, insn, pnum_clobbers)
genrecog.cc|5123|5163|rtx * const operands;int res ATTRIBUTE_UNUSED
genrecog.cc|5221|5285|print_subroutine;print_state
genpreds.cc|1472|1503|get_register_filter_id;return -1'''
REPO_FILES='''docs/research/retained-output-rtl.md
docs/research/retained-backend-gigi.md
docs/research/retained-literal-ira-lra-helpers.md
docs/research/retained-literal-ira-numeric.md
docs/research/retained-literal-lra-recognition.md
docs/research/retained-literal-ira-lra-helper-attachment.md
docs/research/retained-literal-invocation-join.md
docs/research/retained-split-options.md
docs/reviews/review-literal-ira-lra-helpers-b795c8f745.md
docs/reviews/review-literal-ira-lra-helper-attachment-71624df232.md
docs/reviews/review-literal-ira-numeric-9ed466e07f.md
docs/reviews/review-literal-lra-recognition-b341b7f33a.md
docs/evidence/retained-literal-ira-lra-helper-attachment-20261019/result.json
docs/evidence/retained-literal-lra-recognition-20261019/result.json
docs/evidence/retained-literal-ira-numeric-20261019/result.json
docs/evidence/retained-literal-ira-lra-helpers-20261019/result.json
docs/evidence/unbounded-programs/retained-native-expansion-20261017/df-backing-selected-headers.tar.gz
docs/evidence/unbounded-programs/retained-native-expansion-20261017/df-backing-source-identity.json
samples/hello_world.adb'''.split('\n')

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--gcc-source',required=True)
    src=Path(parser.parse_args().gcc_source)
    ex=[]; errors=[]
    for line in SPEC.split('\n'):
        p,a,b,terms=line.split('|');path='gcc/'+p;a,b=int(a),int(b);terms=terms.split(';')
        text='\n'.join((src/path).read_bytes().decode().split('\n')[a-1:b])
        missing=[t for t in terms if t not in text]
        if missing: errors.append((path,a,b,missing))
        ex.append(dict(name=f'{path}:{a}-{b}',root='gcc',path=path,first_LF_line=a,last_LF_line=b,text=text,identity=ident(text.encode()),operative_fragments=terms))
    if errors: raise ValueError(errors)
    repo_files=REPO_FILES+[str(p.relative_to(REPO)) for p in REPO.glob('docs/evidence/retained-literal-invocation-join-*/result.json')]
    files=[dict(root='gcc',path=p,identity=ident((src/p).read_bytes())) for p in sorted({r['path'] for r in ex})]
    files += [dict(root='repository',path=p,identity=ident((REPO/p).read_bytes())) for p in repo_files]
    h=[]
    with tarfile.open(REPO/REPO_FILES[16]) as archive:
        for name,terms in [('insn-config.h',['#define MAX_RECOG_OPERANDS 30','#define NUM_REGISTER_FILTERS 0']),('insn-modes.h',['#define NUM_POLY_INT_COEFFS 1'])]:
            raw=archive.extractfile(name).read();h.append(dict(path=name,identity=ident(raw),operative_fragments=terms))
    refs={k:subprocess.check_output(['git','rev-parse',v],cwd=REPO,text=True).strip() for k,v in dict(integration_base='7b66f9b6c3',owner_authorization='44936e7216',helper_source='b795c8f745',helper_review='4d7100e7fb',attachment_source='71624df232',attachment_review='ac4694d0f7',numeric_source='9ed466e07f',numeric_review='d7b20eb4d2',recognition_source='b341b7f33a',recognition_review='df9ada3f10').items()}
    params=dict(inheritance_probability_cutoff=40,considered_reload_pseudos=500,preference_log2=30,operands=30,hard_registers=92,register_classes=34,alternative_bits=64,poly_coefficients=1,register_filters=0,loser_factor=6,maximum_reject=600)
    manifest=dict(GCC_revision='6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea',accepted_references=refs,files=files,excerpts=ex,generated_headers=h,fixed_parameters=params,generated_recognizer_output_not_retained=True)
    (HERE/'inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(dict(source_files=sum(r['root']=='gcc' for r in files),repository_files=len(repo_files),excerpts=len(ex)))

if __name__=='__main__':main()
