from pathlib import Path
import json,re
root=Path(__file__).parent
all_hooks=json.loads((root/'all-hooks.json').read_text())
known_positive={
 'atree__atree_private_part__alloc_node_id','atree__atree_private_part__alloc_slots',
 'atree__mutate_nkind__2','atree__allocate_new_node','atree__change_node',
 'atree__copy_node','atree__new_copy','atree__rewrite','atree__set_paren_count',
 'atree__set_paren_count_of_copy','namet__name_enter','namet__name_find',
 'uintp__release_and_save','uintp__release_and_save__2','uintp__vector_to_uint',
 'urealp__store_ureal',
 'stringt__start_string','stringt__start_string__2','stringt__store_string_char',
 'stringt__store_string_char__2','stringt__store_string_chars',
 'stringt__store_string_chars__2','stringt__store_string_int',
 'stringt__string_from_name_buffer',
 'elists__insert_elmt_after','elists__new_elmt_list','elists__prepend_elmt',
 'elists__append_elmt',
 'nlists__new_list__2.part.0','nlists__allocate_list_tables',
 'nlists__new_copy_list','nlists__new_copy_list_original','nlists__new_list',
 *['nlists__new_list__'+str(i) for i in range(2,8)],
 'nlists__prepend_new','nlists__prepend_new_to',
}
kept=[];excluded=[]
for h in all_hooks:
 fn=h['function'];generic=bool(re.search(r'__(append|append_all|increment_last|set_item)X?\w*$',fn))
 # Exact generic operation spelling avoids e.g. Append_Elmt, separately reviewed above.
 generic=bool(re.search(r'__(append|append_all|increment_last|set_item)(X[nbr]*)?$',fn))
 if generic or fn in known_positive:excluded.append(dict(h,reason='generic monotone table operation' if generic else 'source-proved monotone allocator'))
 else:kept.append(h)
(root/'decrease-hooks.json').write_text(json.dumps(kept,indent=2)+'\n')
(root/'excluded-positive-stores.json').write_text(json.dumps(excluded,indent=2)+'\n')
print('retained',len(kept),'excluded',len(excluded))
case=root/'all-miss'
for name in ['probe.log','result.json','pool-counters.json','progress.json']:
 p=case/name
 if p.exists():p.rename(case/(name+'.interrupted'))
p=root/'counter-all.py';(root/'counter-all-fullstore.py').write_bytes(p.read_bytes());s=p.read_text().replace("'all-hooks.json'","'decrease-hooks.json'")
s=s.replace("initial=None,latest=None,peak=None)","initial=readi_start(base+static[k]),latest=None,peak=None)")
# Initial read helper must precede counts declaration.
s=s.replace("counts={k:","def readi_start(address):return int.from_bytes(bytes(inf.read_memory(address,4)),'little',signed=True)\ncounts={k:")
# Positive count reconstructed from final minus initial plus every decrease.
s=s.replace("def record(tag):\n row=", "def record(tag):\n for k,v in counts.items():v['positive']=readi(base+static[k])-v['initial']+v['negative']\n row=")
s=s.replace("row['positive']+=max(0,new-old);", "")
p.write_text(s)
