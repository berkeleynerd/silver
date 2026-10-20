"""Complete owned call-instance stack sum; imports are disjoint root components."""
def factors(names):
    f = {n: '1' for n in names if not n.startswith(('caml_apply','caml_curry'))}
    forest = {
      'fold_all_any_of_file_1938':'F','fold_all_any_of_theory_1931':'Th',
      'fold_all_any_of_proofn_1849':'G','fold_all_any_of_transn_1848':'T',
      'save_file_4312':'F','save_theory_4306':'Th','save_goal_4268':'G','save_trans_4269':'T',
      'fun_8393':'T','fun_8403':'G','fun_8412':'G','fun_8422':'Th',
      'fun_8437':'F','fun_8446':'F','fun_10211':'G','fun_10269':'T',
      'fun_10303':'Th','fun_10345':'F',
    }
    for n,count in forest.items(): f['camlWhy3__Session_itp__'+n] = count
    f.update({
      'camlWhy3__Termcode__t_shape_2345':'D+1',
      'camlWhy3__Termcode__fun_9586':'D+1',
      'camlWhy3__Termcode__fun_9731':'D+1',
      'camlStdlib__List__iter_507':'2*D+Z+4',
      'camlStdlib__List__fold_left_521':'Z+1',
      'camlStdlib__List__sort_831':'S+1',
      'camlStdlib__List__rev_sort_832':'S+1',
      'camlWhy3__Extmap__add_397':'K+P+A+V+3',
      'camlWhy3__Extmap__iter_460':'K+V+2',
      'camlWhy3__Extmap__fold_489':'V+1',
      'camlStdlib__Hashtbl__iter_730':'2',
      'camlStdlib__Hashtbl__do_bucket_734':'2',
      'camlStdlib__Hashtbl__fold_764':'2',
      'camlStdlib__Hashtbl__do_bucket_769':'2',
    })
    assert set(f) == {n for n in names if not n.startswith(('caml_apply','caml_curry'))}
    # Each owned source body can suspend at one application edge. On that
    # edge an apply frame and a curry application entry suffice; tail entries
    # and sequential currying stages are deliberately also overcharged.
    # M counts ALL permitted simultaneously active non-adapter instances.
    for n in names:
        if n.startswith(('caml_apply','caml_curry')): f[n] = '2*(M+1)'
    return f

def evaluate(frames, fs, env):
    env = dict(env)
    env['Z'] = env['F']+env['Th']+env['G']+env['T']
    safe = {'__builtins__':{}}
    env['M'] = sum(eval(s,safe,env) for n,s in fs.items()
                   if not n.startswith(('caml_apply','caml_curry')))
    rows = {n: dict(active_instances_upper=eval(s,safe,env), own_bytes=frames[n]['own_bytes_upper'],
                   bytes=eval(s,safe,env)*frames[n]['own_bytes_upper']) for n,s in fs.items()}
    return dict(inputs=env, native_body_contributions=rows,
                owned_complete_to_imports_bytes=sum(r['bytes'] for r in rows.values()))
