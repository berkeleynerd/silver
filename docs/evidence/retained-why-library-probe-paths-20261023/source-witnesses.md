# Raw pathname source witnesses

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/core/env.ml

### Lines 12–48

```text

(** Library environment *)

type fformat = string (* format name *)
type filename = string (* file name *)
type extension = string (* file extension *)
type pathname = string list (* library path *)

exception KnownFormat of fformat
exception UnknownFormat of fformat
exception InvalidFormat of fformat
exception UnspecifiedFormat
exception UnknownExtension of extension

exception LibraryNotFound of pathname
exception TheoryNotFound of pathname * string
exception AmbiguousPath of filename * filename

type env = {
  env_path : Sstr.t;
  env_tag  : Weakhtbl.tag;
}

let env_tag env = env.env_tag

module Wenv = Weakhtbl.Make(struct type t = env let tag = env_tag end)

(** Environment construction and utilisation *)

let create_env = let c = ref (-1) in fun lp -> {
  env_path = Sstr.of_list lp;
  env_tag  = (incr c; Weakhtbl.create_tag !c)
}

let get_loadpath env = Sstr.elements env.env_path

(** Input languages *)
```

### Lines 60–126

```text
type 'a language = {
  memo : 'a Hpath.t Wenv.t;
  push : env -> pathname -> 'a -> unit;
  regf : format_info -> unit format_parser -> unit;
  regb : (env -> pathname -> unit) -> unit;
  mutable fmts : unit format_parser Mstr.t;
  mutable bins : (env -> pathname -> unit) list;
  mutable info : format_info list;
}

let base_language = {
  memo = Wenv.create 3;
  push = (fun _ _ _ -> ());
  regf = (fun _ _ -> ());
  regb = (fun _ -> ());
  fmts = Mstr.empty;
  bins = [];
  info = [];
}

exception LibraryConflict of pathname

let store lang env path c =
  let ht = try Wenv.find lang.memo env with Not_found ->
    let ht = Hpath.create 17 in Wenv.set lang.memo env ht; ht in
  match path with
  | "why3" :: _ ->
      begin try
        if Hpath.find ht path != c then raise (LibraryConflict path)
      with Not_found -> lang.push env path c; Hpath.add ht path c end
  | _ ->
      assert (path = [] || not (Hpath.mem ht path));
      lang.push env path c; Hpath.add ht path c

let register_format lang (ff,_,_ as inf) fp =
  lang.regf inf fp;
  lang.fmts <- Mstr.add_new (KnownFormat ff) ff fp lang.fmts;
  lang.info <- inf :: lang.info

let add_builtin lang bp =
  lang.regb bp;
  lang.bins <- bp :: lang.bins

let register_language parent convert = {
  memo = Wenv.create 3;
  push = (fun env path c -> store parent env path (convert c));
  regf = (fun inf fp -> register_format parent inf fp);
  regb = (fun bp -> add_builtin parent bp);
  fmts = Mstr.empty;
  bins = [];
  info = [];
}

let extension_table = ref Mstr.empty

let register_format ~desc lang ff extl fp =
  let fp env path fn ch = store lang env path (fp env path fn ch) in
  register_format lang (ff,extl,desc) fp;
  let add_ext m e = Mstr.add e ff m in
  extension_table := List.fold_left add_ext !extension_table extl

let add_builtin lang bp =
  let bp env path = store lang env ("why3" :: path) (bp path) in
  add_builtin lang bp

let list_formats lang =
  let filter_ext (ff,extl,desc) =
```

### Lines 169–219

```text

let locate_library env path =
  if path = [] || path = ["why3"]
    then invalid_arg "Env.locate_library";
  let check_qualifier s =
    if (s = Filename.parent_dir_name ||
        s = Filename.current_dir_name ||
        Filename.basename s <> s)
    then invalid_arg "Env.locate_library" in
  List.iter check_qualifier path;
  let file = List.fold_left Filename.concat "" path in
  let add_ext ext = file ^ "." ^ ext in
  let fl = List.map add_ext (Mstr.keys !extension_table) in
  let add_dir dir = List.map (Filename.concat dir) fl in
  let fl = List.concat (List.map add_dir (get_loadpath env)) in
  match List.filter Sys.file_exists fl with
  | [] -> raise (LibraryNotFound path)
  | [file] -> file
  | file1 :: file2 :: _ -> raise (AmbiguousPath (file1, file2))

exception CircularDependency of pathname

let read_library lang env = function
  | "why3" :: path ->
      let read bp = try bp env path with Not_found -> () in
      List.iter read lang.bins
  | path ->
      let file = locate_library env path in
      let (_: fformat) = read_lib_file lang env path file in ()

let libstack = Hpath.create 17

let read_library lang env path =
  if Hpath.mem libstack path then
    raise (CircularDependency path);
  try
    Hpath.add libstack path ();
    read_library lang env path;
    Hpath.remove libstack path
  with exn ->
    Hpath.remove libstack path;
    raise exn

let read_library lang env path =
  let path = if path = [] then ["why3"] else path in
  try Hpath.find (Wenv.find lang.memo env) path with Not_found ->
  read_library lang env path;
  try Hpath.find (Wenv.find lang.memo env) path with Not_found ->
  raise (LibraryNotFound path)

let read_theory env path s =
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/gnat/gnat_util.ml

### Lines 41–61

```text
let why3_prefix =
  Filename.dirname (Filename.dirname Sys.executable_name)
let spark_prefix =
  Filename.dirname (Filename.dirname why3_prefix)

let gnatprove_why3conf_file = "why3.conf"

let rec file_concat l =
  match l with
  | [] -> ""
  | [x] -> x
  | [x;y] -> Filename.concat x y
  | x :: xs -> Filename.concat x (file_concat xs)

let spark_loadpath =
  [ file_concat [why3_prefix; "share"; "why3"; "theories"];
    file_concat [why3_prefix; "share"; "why3"; "modules"];
    file_concat [spark_prefix; "share"; "spark"; "theories"]
  ]

let find_driver_file ~conf_file ?extra_conf_file (extra_dir,fn) =
```

### Lines 110–123

```text
let build_env_from_config ~load_plugins ~proof_dir config =
  let config_main = Whyconf.get_main config in
  ( if load_plugins then
      Whyconf.load_plugins config_main
    else (* At least load the gnatwhy3 plugins *)
      let dirs = [Whyconf.pluginsdir (Whyconf.get_main config)] in
      List.iter (Plugin.load ~dirs) ["gnat_json"; "ada_terms"] );
  let base_loadpath = spark_loadpath @ Whyconf.loadpath config_main in
  let extended_loadpath =
    match proof_dir with
    | Some dir -> (Filename.concat dir "_theories") :: base_loadpath
    | None -> base_loadpath
  in
  Env.create_env extended_loadpath
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/gnat/gnat_config.ml

### Lines 10–20

```text
  | Per_Check

let builtin_provers = ["altergo"; "colibri"; "cvc5"; "z3"]

let is_builtin_prover =
  let builtin_provers_set =
    List.fold_left (fun acc x -> Sstr.add x acc) Sstr.empty builtin_provers in
  (fun s ->
    let s = String.lowercase_ascii s in
    Sstr.mem s builtin_provers_set)

```

### Lines 346–409

```text
let provers, prover_ce, prover_warn, config, env =
  let prover_str_list = computer_prover_str_list () in
  (* did the user request some prover which is not shipped with SPARK? *)
  let builtin_provers_only = List.for_all is_builtin_prover prover_str_list in
  (* now load the configuration of Why3 *)
  let config =
     try
       let gnatprove_config =
         Gnat_util.get_gnatprove_config ?extra_conf_file:!opt_why3_conf_file
           (read_config (Some Gnat_util.gnatprove_why3conf_file)) in
       (* We read the user-provided why3.conf file, if any. We never use a file
          like $HOME/.why3.conf. We make sure of that by not calling
          Whyconf.read_config with a None argument. *)
       if !opt_why3_conf_file = None then gnatprove_config
       else begin
           let conf =
             Gnat_util.get_gnatprove_config ?extra_conf_file:!opt_why3_conf_file
                (read_config !opt_why3_conf_file) in
           check_config_for_builtin_provers conf;
           let provers =
             prover_merge
               (get_provers gnatprove_config)
               (get_provers conf) in
           let editors = editor_merge (get_editors gnatprove_config)
                                      (get_editors conf) in
           let shortcuts =
             shortcut_merge (get_prover_shortcuts gnatprove_config)
                            (get_prover_shortcuts conf) in
           let config =
             set_editors
               (set_provers ~shortcuts gnatprove_config provers)
               editors
           in
           config
        end
     with e when Debug.test_flag Debug.stack_trace -> raise e
     | Rc.CannotOpen (f,s) ->
       Gnat_util.abort_with_message ~internal:false
         (Format.sprintf "cannot read file %s: %s" f s)
     | ConfigFailure (_,s) ->
         (* no need to mention the file, it is already mentioned in the error
            message s *)
       Gnat_util.abort_with_message ~internal:false
         (Format.sprintf "%s" s)
  in

  (* now we build the Whyconf.config_prover for all requested provers
   * and for the prover for counterexample generation *)
  let base_provers, base_prover_ce, base_prover_warn =
    compute_base_provers config prover_str_list in
  let env =
    Gnat_util.build_env_from_config
      ~load_plugins:(not builtin_provers_only)
      ~proof_dir:!opt_proof_dir
      config in
  let provers =
    List.map (fun x -> x.prover) base_provers in
  let prover_ce =
    Option.map (fun conf_prover -> conf_prover.prover) base_prover_ce
  in
  let prover_warn =
    Option.map (fun conf_prover -> conf_prover.prover) base_prover_warn
  in
  provers, prover_ce, prover_warn, config, env
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/driver/whyconf.ml

### Lines 206–238

```text
  m.libobjdir

let set_libdir m d = { m with libdir = d}

let datadir =
  let env_datadir = try Some (Sys.getenv "WHY3DATA") with Not_found -> None in
  fun m -> Option.value ~default:m.datadir env_datadir

let set_datadir m d = { m with datadir = d}

let stdlib_path = ref ""

let default_loadpath m =
  [ Filename.concat (datadir m) "stdlib" ]

let loadpath =
  let env_loadpath =
    try Some (Strings.split ':' (Sys.getenv "WHY3LOADPATH"))
    with Not_found -> None
  in
  fun m ->
    match env_loadpath with
    | Some l -> stdlib_path := List.hd l; l
    | None ->
      let stdlib =
        if m.stdlib then
          let loadpath = default_loadpath m in
          let () = stdlib_path := List.hd loadpath in
          loadpath
        else [] in
      m.loadpath@stdlib

let set_loadpath m l = { m with loadpath = l}
```

### Lines 304–321

```text
  strategies : config_strategy Mstr.t;
}

let empty_main =
  {
    libdir = Config.libdir;
    datadir = Config.datadir;
    libobjdir = Config.libobjdir;
    loadpath = [];
    stdlib = true;
    load_default_plugins = true;
    timelimit = 5.;   (* 5 seconds *)
    memlimit = 1000; (* 1 Mb *)
    running_provers_max = 2; (* two provers run in parallel *)
    plugins = [];
    default_editor = Config.editor ^ " %f"
  }

```

### Lines 494–525

```text

  let load_main old dirname section =
    if get_int ~default:0 section "magic" <> magicnumber then
      raise WrongMagicNumber;
    { libdir    = get_string ~default:old.libdir section "libdir";
      datadir   = get_string ~default:old.datadir section "datadir";
      libobjdir = Config.libobjdir;
      loadpath  =
        begin match get_stringl section "loadpath" with
        | [] -> old.loadpath
        | l -> List.map (Sysutil.concat dirname) l end;
      stdlib = get_bool ~default:old.stdlib section "stdlib";
      load_default_plugins = get_bool ~default:old.load_default_plugins section "load_default_plugins";
      timelimit = get_float ~default:old.timelimit section "timelimit";
      memlimit  = get_int ~default:old.memlimit section "memlimit";
      running_provers_max = get_int ~default:old.running_provers_max
          section "running_provers_max";
      plugins =
        begin match get_stringl section "plugin" with
        | [] -> old.plugins
        | l -> l end;
      default_editor = get_string ~default:old.default_editor section "default_editor";
    }

  let get_dirname filename =
    Filename.dirname (Sysutil.concat (Sys.getcwd ()) filename)

  let config_from_rc config filename rc =
    Debug.dprintf debug "[Whyconf.config_from_rc] filename=%s@." filename;
    let dirname = get_dirname filename in
    let main =
      match get_section rc "main" with
```

### Lines 840–859

```text
    raise (ProverAmbiguity (whyconf,fp,provers))


(** add extra config *)

let add_extra_config config filename =
  Debug.dprintf debug "[Whyconf.add_extra_config] filename=%s@." filename;
  let dirname = RC_load.get_dirname filename in
  let rc = Rc.from_file filename in
  (* modify main *)
  let main = match get_section rc "main" with
    | None -> config.main
    | Some rc ->
      let loadpath = (List.map (Sysutil.concat dirname)
        (get_stringl rc "loadpath")) @ config.main.loadpath in
      let plugins =
        (get_stringl rc "plugin") @ config.main.plugins in
      { config.main with loadpath = loadpath; plugins = plugins } in
  (* get more strategies *)
  let more_strategies = get_strategies rc in
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/wstdlib.ml

### Lines 13–33

```text
module Int = struct
  type t = int
  let compare (x : int) y = Stdlib.compare x y
  let equal (x : int) y = x = y
  let hash  (x : int) = x
end

module Mint = Extmap.Make(Int)
module Sint = Extset.MakeOfMap(Mint)
module Hint = Exthtbl.Make(Int)

module Mstr = Extmap.Make(String)
module Sstr = Extset.MakeOfMap(Mstr)
module Hstr = Exthtbl.Make(struct
  type t    = String.t
  let hash  = (Hashtbl.hash : string -> int)
  let equal = ((=) : string -> string -> bool)
end)


module Float = struct
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/extmap.ml

### Lines 392–401

```text
        Empty -> 0
      | Node(l, _, _, r, _) -> cardinal l + 1 + cardinal r

    let rec keys_aux accu = function
        Empty -> accu
      | Node(l, v, _, r, _) -> keys_aux (v :: keys_aux accu r) l

    let keys s =
      keys_aux [] s

```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/extset.ml

### Lines 60–100

```text

  let is_true b = if b then Some () else None

  let empty = M.empty
  let is_empty = M.is_empty
  let mem = M.mem
  let add e s = M.add e () s
  let singleton e = M.singleton e ()
  let remove = M.remove
  let merge f s t =
    M.merge (fun e a b -> is_true (f e (a <> None) (b <> None))) s t
  let compare = M.set_compare
  let equal = M.set_equal
  let subset = M.set_submap
  let disjoint = M.set_disjoint
  let iter f s = M.iter (fun e _ -> f e) s
  let fold f s acc = M.fold (fun e _ -> f e) s acc
  let for_all f s = M.for_all (fun e _ -> f e) s
  let exists f s = M.exists (fun e _ -> f e) s
  let filter f s = M.filter (fun e _ -> f e) s
  let partition f s = M.partition (fun e _ -> f e) s
  let cardinal = M.cardinal
  let elements = M.keys
  let min_elt t = fst (M.min_binding t)
  let max_elt t = fst (M.max_binding t)
  let choose t = fst (M.choose t)
  let split e t = let l,m,r = M.split e t in l,(m <> None),r
  let change f x s = M.change (fun a -> is_true (f (a <> None))) x s
  let union = M.set_union
  let inter = M.set_inter
  let diff = M.set_diff
  let fold_left f acc s = M.fold_left (fun acc k () -> f acc k) acc s
  let fold_right f s acc = M.fold_right (fun k _ acc -> f k acc) s acc
  let fold2_inter f s t acc = M.fold2_inter (fun k _ _ acc -> f k acc) s t acc
  let fold2_union f s t acc = M.fold2_union (fun k _ _ acc -> f k acc) s t acc
  let translate = M.translate
  let add_new e x s = M.add_new e x () s
  let is_num_elt n m = M.is_num_elt n m
  let of_list l = List.fold_left (fun acc a -> add a acc) empty l
  let contains = M.contains
  let add_left s e = M.add e () s
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/config.mli

### Lines 1–26

```text
(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(********************************************************************)

val version : string
val editor : string
val libdir : string
val datadir : string
val localdir : string option

val libobjdir : string
val enable_ide : string
val enable_zip : string
val enable_coq_libs : string
val enable_coq_fp_libs : string
val enable_pvs_libs : string
val enable_isabelle_libs : string
val enable_hypothesis_selection : string
val enable_local : string
val enable_relocation : string
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/lexer.mll

### Lines 270–279

```text
      let print_m _ m = Format.eprintf "%a@\n@." print_module m in
      let add_m _ m mm = Mid.add m.mod_theory.th_name m mm in
      Mid.iter print_m (Mstr.fold add_m mm Mid.empty)
    end;
    mm

  let whyml_format = "whyml"

  let () = Env.register_format mlw_language whyml_format ["mlw";"why"]
      read_channel ~desc:"WhyML@ programming@ and@ specification@ language"
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/sexp_parser.ml

### Lines 1–24

```text
(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2025 --  Inria - CNRS - Paris-Saclay University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(********************************************************************)


let read_channel env path file c =
  try
    let sexp = Mysexplib.input_sexp c in
    let ptree = Ptree.mlw_file_of_sexp sexp in
    Typing.type_mlw_file env path file ptree
  with e ->
    let loc = Loc.user_position (String.concat Filename.dir_sep (path@[file])) 0 0 0 0 in
    raise (Loc.Located(loc,e))

let sexp_format = "sexp"

let () = Env.register_format Pmodule.mlw_language sexp_format ["sexp"]
    read_channel ~desc:"WhyML@ code in s-expressions format"
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/plugins/ada_terms/ada_main.ml

### Lines 186–195

```text
  ada_ext_printer is_record

(* Registration of ada_terms plugin *)

let () =
  Env.register_format ~desc:"WhyML@ for@ Ada"
    Pmodule.mlw_language ada_format ["adb"] Lexer.read_channel

let register_ada_terms format =
  let open Ada_lexer in
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/plugins/gnat_json/gnat_ast_to_ptree.ml

### Lines 1421–1427

```text
  | exception e ->
      print_mlw_file ();
      raise e

let () =
  Env.register_format ~desc:"Gnat@ AST@ in@ JSON@ format"
    Pmodule.mlw_language gnat_json_format [gnat_json_file_ext] read_channel
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/sys.ml.in

### Lines 22–55

```text
(* System interface *)

external get_config: unit -> string * int * bool = "caml_sys_get_config"
external get_executable_name : unit -> string = "caml_sys_executable_name"
external argv : string array = "%sys_argv"
external big_endian : unit -> bool = "%big_endian"
external word_size : unit -> int = "%word_size"
external int_size : unit -> int = "%int_size"
external max_wosize : unit -> int = "%max_wosize"
external unix : unit -> bool = "%ostype_unix"
external win32 : unit -> bool = "%ostype_win32"
external cygwin : unit -> bool = "%ostype_cygwin"
external get_backend_type : unit -> backend_type = "%backend_type"

let executable_name = get_executable_name()
let (os_type, _, _) = get_config()
let backend_type = get_backend_type ()
let big_endian = big_endian ()
let word_size = word_size ()
let int_size = int_size ()
let unix = unix ()
let win32 = win32 ()
let cygwin = cygwin ()
let max_array_length = max_wosize ()
let max_floatarray_length = max_array_length / (64 / word_size)
let max_string_length = word_size / 8 * max_array_length - 1
external runtime_variant : unit -> string = "caml_runtime_variant"
external runtime_parameters : unit -> string = "caml_runtime_parameters"

external file_exists: string -> bool = "caml_sys_file_exists"
external is_directory : string -> bool = "caml_sys_is_directory"
external remove: string -> unit = "caml_sys_remove"
external rename : string -> string -> unit = "caml_sys_rename"
external getenv: string -> string = "caml_sys_getenv"
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/startup_nat.c

### Lines 140–158

```text
  init_static();
  caml_init_signals();
#ifdef _WIN32
  caml_win32_overflow_detection();
#endif
  caml_init_backtrace();
  caml_debugger_init (); /* force debugger.o stub to be linked */
  exe_name = argv[0];
  if (exe_name == NULL) exe_name = T("");
  proc_self_exe = caml_executable_name();
  if (proc_self_exe != NULL)
    exe_name = proc_self_exe;
  else
    exe_name = caml_search_exe_in_path(exe_name);
  caml_sys_init(exe_name, argv);
  if (sigsetjmp(caml_termination_jmpbuf.buf, 0)) {
    caml_terminate_signals();
    if (caml_termination_hook != NULL) caml_termination_hook(NULL);
    return Val_unit;
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/sys.c

### Lines 239–258

```text
CAMLprim value caml_sys_file_exists(value name)
{
#ifdef _WIN32
  struct _stati64 st;
#else
  struct stat st;
#endif
  char_os * p;
  int ret;

  if (! caml_string_is_c_safe(name)) return Val_false;
  p = caml_stat_strdup_to_os(String_val(name));
  caml_enter_blocking_section();
  ret = stat_os(p, &st);
  caml_leave_blocking_section();
  caml_stat_free(p);

  return Val_bool(ret == 0);
}

```

### Lines 419–460

```text
char_os * caml_exe_name;
static value main_argv;

CAMLprim value caml_sys_get_argv(value unit)
{
  CAMLparam0 ();   /* unit is unused */
  CAMLlocal2 (exe_name, res);
  exe_name = caml_copy_string_of_os(caml_exe_name);
  res = caml_alloc_small(2, 0);
  Field(res, 0) = exe_name;
  Field(res, 1) = main_argv;
  CAMLreturn(res);
}

CAMLprim value caml_sys_argv(value unit)
{
  return main_argv;
}

CAMLprim value caml_sys_modify_argv(value new_argv)
{
  caml_modify_generational_global_root(&main_argv, new_argv);
  return Val_unit;
}

CAMLprim value caml_sys_executable_name(value unit)
{
  return caml_copy_string_of_os(caml_exe_name);
}

void caml_sys_init(char_os * exe_name, char_os **argv)
{
#ifdef _WIN32
  /* Initialises the caml_win32_* globals on Windows with the version of
     Windows which is running */
  caml_probe_win32_version();
#if WINDOWS_UNICODE
  caml_setup_win32_terminal();
#endif
#endif
  caml_exe_name = exe_name;
  main_argv = caml_alloc_array((void *)caml_copy_string_of_os,
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/unix.c

### Lines 130–149

```text
caml_stat_string caml_search_in_path(struct ext_table * path, const char * name)
{
  const char * p;
  char * dir, * fullname;
  int i;
  struct stat st;

  for (p = name; *p != 0; p++) {
    if (*p == '/') goto not_found;
  }
  for (i = 0; i < path->size; i++) {
    dir = path->contents[i];
    if (dir[0] == 0) dir = ".";  /* empty path component = current dir */
    fullname = caml_stat_strconcat(3, dir, "/", name);
    if (stat(fullname, &st) == 0 && S_ISREG(st.st_mode))
      return fullname;
    caml_stat_free(fullname);
  }
 not_found:
  return caml_stat_strdup(name);
```

### Lines 199–216

```text
caml_stat_string caml_search_exe_in_path(const char * name)
{
  struct ext_table path;
  char * tofree;
  caml_stat_string res;

  caml_ext_table_init(&path, 8);
  tofree = caml_decompose_path(&path, getenv("PATH"));
#ifndef __CYGWIN__
  res = caml_search_in_path(&path, name);
#else
  res = cygwin_search_exe_in_path(&path, name);
#endif
  caml_stat_free(tofree);
  caml_ext_table_free(&path, 0);
  return res;
}

```

### Lines 354–386

```text
/* Recover executable name from /proc/self/exe if possible */

char * caml_executable_name(void)
{
#if defined(__linux__)
  int namelen, retcode;
  char * name;
  struct stat st;

  /* lstat("/proc/self/exe") returns st_size == 0 so we cannot use it
     to determine the size of the buffer.  Instead, we guess and adjust. */
  namelen = 256;
  while (1) {
    name = caml_stat_alloc(namelen);
    retcode = readlink("/proc/self/exe", name, namelen);
    if (retcode == -1) { caml_stat_free(name); return NULL; }
    if (retcode < namelen) break;
    caml_stat_free(name);
    if (namelen >= 1024*1024) return NULL; /* avoid runaway and overflow */
    namelen *= 2;
  }
  /* readlink() does not zero-terminate its result.
     There is room for a final zero since retcode < namelen. */
  name[retcode] = 0;
  /* Make sure that the contents of /proc/self/exe is a regular file.
     (Old Linux kernels return an inode number instead.) */
  if (stat(name, &st) == -1 || ! S_ISREG(st.st_mode)) {
    caml_stat_free(name); return NULL;
  }
  return name;

#elif defined(__APPLE__)
  unsigned int namelen;
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/filename.ml

### Lines 36–72

```text
let generic_basename is_dir_sep current_dir_name name =
  let rec find_end n =
    if n < 0 then String.sub name 0 1
    else if is_dir_sep name n then find_end (n - 1)
    else find_beg n (n + 1)
  and find_beg n p =
    if n < 0 then String.sub name 0 p
    else if is_dir_sep name n then String.sub name (n + 1) (p - n - 1)
    else find_beg (n - 1) p
  in
  if name = ""
  then current_dir_name
  else find_end (String.length name - 1)

(* This function implements the Open Group specification found here:
  [[2]] http://pubs.opengroup.org/onlinepubs/9699919799/utilities/dirname.html
  In step 6 of [[2]], we choose to process "//" normally.
*)
let generic_dirname is_dir_sep current_dir_name name =
  let rec trailing_sep n =
    if n < 0 then String.sub name 0 1
    else if is_dir_sep name n then trailing_sep (n - 1)
    else base n
  and base n =
    if n < 0 then current_dir_name
    else if is_dir_sep name n then intermediate_sep n
    else base (n - 1)
  and intermediate_sep n =
    if n < 0 then String.sub name 0 1
    else if is_dir_sep name n then intermediate_sep (n - 1)
    else String.sub name 0 (n + 1)
  in
  if name = ""
  then current_dir_name
  else trailing_sep (String.length name - 1)

module type SYSDEPS = sig
```

### Lines 88–98

```text
  val dirname : string -> string
end

module Unix : SYSDEPS = struct
  let null = "/dev/null"
  let current_dir_name = "."
  let parent_dir_name = ".."
  let dir_sep = "/"
  let is_dir_sep s i = s.[i] = '/'
  let is_relative n = String.length n < 1 || n.[0] <> '/'
  let is_implicit n =
```

### Lines 125–127

```text
                                                else " 2>" ^ quote f)
  let basename = generic_basename is_dir_sep current_dir_name
  let dirname = generic_dirname is_dir_sep current_dir_name
```

### Lines 279–295

```text
end

module Sysdeps =
  (val (match Sys.os_type with
       | "Win32" -> (module Win32: SYSDEPS)
       | "Cygwin" -> (module Cygwin: SYSDEPS)
       | _ -> (module Unix: SYSDEPS)))

include Sysdeps

let concat dirname filename =
  let l = String.length dirname in
  if l = 0 || is_dir_sep dirname (l-1)
  then dirname ^ filename
  else dirname ^ dir_sep ^ filename

let chop_suffix name suff =
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/stdlib.ml

### Lines 202–220

```text

(* String and byte sequence operations -- more in modules String and Bytes *)

external string_length : string -> int = "%string_length"
external bytes_length : bytes -> int = "%bytes_length"
external bytes_create : int -> bytes = "caml_create_bytes"
external string_blit : string -> int -> bytes -> int -> int -> unit
                     = "caml_blit_string" [@@noalloc]
external bytes_blit : bytes -> int -> bytes -> int -> int -> unit
                        = "caml_blit_bytes" [@@noalloc]
external bytes_unsafe_to_string : bytes -> string = "%bytes_to_string"

let ( ^ ) s1 s2 =
  let l1 = string_length s1 and l2 = string_length s2 in
  let s = bytes_create (l1 + l2) in
  string_blit s1 0 s 0 l1;
  string_blit s2 0 s l1 l2;
  bytes_unsafe_to_string s

```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/list.ml

### Lines 15–35

```text

(* An alias for the type of lists. *)
type 'a t = 'a list = [] | (::) of 'a * 'a list

(* List operations *)

let rec length_aux len = function
    [] -> len
  | _::l -> length_aux (len + 1) l

let length l = length_aux 0 l

let cons a l = a::l

let hd = function
    [] -> failwith "hd"
  | a::_ -> a

let tl = function
    [] -> failwith "tl"
  | _::l -> l
```

### Lines 82–94

```text
  else init_aux 0 len f

let rec flatten = function
    [] -> []
  | l::r -> l @ flatten r

let concat = flatten

let rec map f = function
    [] -> []
  | a::l -> let r = f a in r :: map f l

let rec mapi i f = function
```

### Lines 238–245

```text

let find_all p =
  let rec find accu = function
  | [] -> rev accu
  | x :: l -> if p x then find (x :: accu) l else find accu l in
  find []

let filter = find_all
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/alloc.c

### Lines 78–96

```text
/* [len] is a number of bytes (chars) */
CAMLexport value caml_alloc_string (mlsize_t len)
{
  value result;
  mlsize_t offset_index;
  mlsize_t wosize = (len + sizeof (value)) / sizeof (value);

  if (wosize <= Max_young_wosize) {
    Alloc_small (result, wosize, String_tag);
  }else{
    result = caml_alloc_shr (wosize, String_tag);
    result = caml_check_urgent_gc (result);
  }
  Field (result, wosize - 1) = 0;
  offset_index = Bsize_wsize (wosize) - 1;
  Byte (result, offset_index) = offset_index - len;
  return result;
}

```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/str.c

### Lines 62–79

```text
CAMLprim value caml_create_string(value len)
{
  mlsize_t size = Long_val(len);
  if (size > Bsize_wsize (Max_wosize) - 1){
    caml_invalid_argument("String.create");
  }
  return caml_alloc_string(size);
}

/* [len] is a value that represents a number of bytes (chars) */
CAMLprim value caml_create_bytes(value len)
{
  mlsize_t size = Long_val(len);
  if (size > Bsize_wsize (Max_wosize) - 1){
    caml_invalid_argument("Bytes.create");
  }
  return caml_alloc_string(size);
}
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/caml/mlvalues.h

### Lines 69–79

```text
/* Longs vs blocks. */
#define Is_long(x)   (((x) & 1) != 0)
#define Is_block(x)  (((x) & 1) == 0)

/* Conversion macro names are always of the form  "to_from". */
/* Example: Val_long as in "Val from long" or "Val of long". */
#define Val_long(x)     ((intnat) (((uintnat)(x) << 1)) + 1)
#define Long_val(x)     ((x) >> 1)
#define Max_long (((intnat)1 << (8 * sizeof(value) - 2)) - 1)
#define Min_long (-((intnat)1 << (8 * sizeof(value) - 2)))
#define Val_int(x) Val_long(x)
```

### Lines 150–159

```text
#define Num_tags (1 << 8)
#ifdef ARCH_SIXTYFOUR
#ifdef WITH_PROFINFO
#define Max_wosize (((intnat)1 << (54-PROFINFO_WIDTH)) - 1)
#else
#define Max_wosize (((intnat)1 << 54) - 1)
#endif
#else
#define Max_wosize ((1 << 22) - 1)
#endif /* ARCH_SIXTYFOUR */
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/caml/misc.h

### Lines 365–386

```text
#define execv_os execv
#define execve_os execve
#define execvp_os execvp
#define execvpe_os execvpe
#define strcmp_os strcmp
#define strlen_os strlen
#define sscanf_os sscanf
#define strcpy_os strcpy
#define mktemp_os mktemp
#define fopen_os fopen

#define clock_os clock

#define caml_stat_strdup_os caml_stat_strdup
#define caml_stat_strconcat_os caml_stat_strconcat

#define caml_stat_strdup_to_os caml_stat_strdup
#define caml_stat_strdup_of_os caml_stat_strdup
#define caml_copy_string_of_os caml_copy_string

#endif /* _WIN32 */

```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/memory.c

### Lines 889–906

```text
CAMLexport caml_stat_string caml_stat_strdup_noexc(const char *s)
{
  size_t slen = strlen(s);
  caml_stat_block result = caml_stat_alloc_noexc(slen + 1);
  if (result == NULL)
    return NULL;
  memcpy(result, s, slen + 1);
  return result;
}

CAMLexport caml_stat_string caml_stat_strdup(const char *s)
{
  caml_stat_string result = caml_stat_strdup_noexc(s);
  if (result == NULL)
    caml_raise_out_of_memory();
  return result;
}

```

## docs/evidence/retained-why-parallel-residual-transfer-20261020/first-or-default-capture.tar.gz :: collector/probe.py

### Lines 66–83

```text
    (OUT/'maps.txt').write_bytes((proc/'maps').read_bytes())
    mapped={}
    for line in (proc/'maps').read_text().splitlines():
     parts=line.split()
     if len(parts)>=6 and parts[-1].startswith('/') and Path(parts[-1]).is_file():mapped[parts[-1]]=identity(parts[-1])
    SUMMARY['mapped_files']=mapped
    capture_fixed_session()
    SUMMARY['completed']=True;save()
  except Exception as e:SUMMARY['failures'].append(type(e).__name__+': '+str(e));save();return True
  return self.final
proc=Path('/proc')/str(INF.pid)
env=dict(s.decode().split('=',1) for s in (proc/'environ').read_bytes().split(b'\0') if s)
assert env==CASE['environment'],env
args=[s.decode() for s in (proc/'cmdline').read_bytes().split(b'\0') if s]
assert args==CASE['argv'],args
(OUT/'process.json').write_text(json.dumps({'pid':INF.pid,'executable':str((proc/'exe').resolve()),'environment':env,'argv':args,'initial_threads':len(INF.threads())},indent=2)+'\n')
for name in PLAN['guards']:Guard(name)
Phase('caml_start_program');Phase(PLAN['protected_start'],start=True);Phase(PLAN['endpoint']['symbol'],True)
```

## docs/evidence/retained-why-parallel-residual-transfer-20261020/input-is-valid-capture.tar.gz :: collector/probe.py

### Lines 66–83

```text
    (OUT/'maps.txt').write_bytes((proc/'maps').read_bytes())
    mapped={}
    for line in (proc/'maps').read_text().splitlines():
     parts=line.split()
     if len(parts)>=6 and parts[-1].startswith('/') and Path(parts[-1]).is_file():mapped[parts[-1]]=identity(parts[-1])
    SUMMARY['mapped_files']=mapped
    capture_fixed_session()
    SUMMARY['completed']=True;save()
  except Exception as e:SUMMARY['failures'].append(type(e).__name__+': '+str(e));save();return True
  return self.final
proc=Path('/proc')/str(INF.pid)
env=dict(s.decode().split('=',1) for s in (proc/'environ').read_bytes().split(b'\0') if s)
assert env==CASE['environment'],env
args=[s.decode() for s in (proc/'cmdline').read_bytes().split(b'\0') if s]
assert args==CASE['argv'],args
(OUT/'process.json').write_text(json.dumps({'pid':INF.pid,'executable':str((proc/'exe').resolve()),'environment':env,'argv':args,'initial_threads':len(INF.threads())},indent=2)+'\n')
for name in PLAN['guards']:Guard(name)
Phase('caml_start_program');Phase(PLAN['protected_start'],start=True);Phase(PLAN['endpoint']['symbol'],True)
```

## docs/evidence/retained-why-parallel-residual-transfer-20261020/is-message-capture.tar.gz :: collector/probe.py

### Lines 66–83

```text
    (OUT/'maps.txt').write_bytes((proc/'maps').read_bytes())
    mapped={}
    for line in (proc/'maps').read_text().splitlines():
     parts=line.split()
     if len(parts)>=6 and parts[-1].startswith('/') and Path(parts[-1]).is_file():mapped[parts[-1]]=identity(parts[-1])
    SUMMARY['mapped_files']=mapped
    capture_fixed_session()
    SUMMARY['completed']=True;save()
  except Exception as e:SUMMARY['failures'].append(type(e).__name__+': '+str(e));save();return True
  return self.final
proc=Path('/proc')/str(INF.pid)
env=dict(s.decode().split('=',1) for s in (proc/'environ').read_bytes().split(b'\0') if s)
assert env==CASE['environment'],env
args=[s.decode() for s in (proc/'cmdline').read_bytes().split(b'\0') if s]
assert args==CASE['argv'],args
(OUT/'process.json').write_text(json.dumps({'pid':INF.pid,'executable':str((proc/'exe').resolve()),'environment':env,'argv':args,'initial_threads':len(INF.threads())},indent=2)+'\n')
for name in PLAN['guards']:Guard(name)
Phase('caml_start_program');Phase(PLAN['protected_start'],start=True);Phase(PLAN['endpoint']['symbol'],True)
```

## docs/evidence/retained-why-parallel-residual-transfer-20261020/put-capture.tar.gz :: collector/probe.py

### Lines 66–83

```text
    (OUT/'maps.txt').write_bytes((proc/'maps').read_bytes())
    mapped={}
    for line in (proc/'maps').read_text().splitlines():
     parts=line.split()
     if len(parts)>=6 and parts[-1].startswith('/') and Path(parts[-1]).is_file():mapped[parts[-1]]=identity(parts[-1])
    SUMMARY['mapped_files']=mapped
    capture_fixed_session()
    SUMMARY['completed']=True;save()
  except Exception as e:SUMMARY['failures'].append(type(e).__name__+': '+str(e));save();return True
  return self.final
proc=Path('/proc')/str(INF.pid)
env=dict(s.decode().split('=',1) for s in (proc/'environ').read_bytes().split(b'\0') if s)
assert env==CASE['environment'],env
args=[s.decode() for s in (proc/'cmdline').read_bytes().split(b'\0') if s]
assert args==CASE['argv'],args
(OUT/'process.json').write_text(json.dumps({'pid':INF.pid,'executable':str((proc/'exe').resolve()),'environment':env,'argv':args,'initial_threads':len(INF.threads())},indent=2)+'\n')
for name in PLAN['guards']:Guard(name)
Phase('caml_start_program');Phase(PLAN['protected_start'],start=True);Phase(PLAN['endpoint']['symbol'],True)
```

## docs/evidence/retained-why-parallel-residual-transfer-20261020/put-line-capture.tar.gz :: collector/probe.py

### Lines 66–83

```text
    (OUT/'maps.txt').write_bytes((proc/'maps').read_bytes())
    mapped={}
    for line in (proc/'maps').read_text().splitlines():
     parts=line.split()
     if len(parts)>=6 and parts[-1].startswith('/') and Path(parts[-1]).is_file():mapped[parts[-1]]=identity(parts[-1])
    SUMMARY['mapped_files']=mapped
    capture_fixed_session()
    SUMMARY['completed']=True;save()
  except Exception as e:SUMMARY['failures'].append(type(e).__name__+': '+str(e));save();return True
  return self.final
proc=Path('/proc')/str(INF.pid)
env=dict(s.decode().split('=',1) for s in (proc/'environ').read_bytes().split(b'\0') if s)
assert env==CASE['environment'],env
args=[s.decode() for s in (proc/'cmdline').read_bytes().split(b'\0') if s]
assert args==CASE['argv'],args
(OUT/'process.json').write_text(json.dumps({'pid':INF.pid,'executable':str((proc/'exe').resolve()),'environment':env,'argv':args,'initial_threads':len(INF.threads())},indent=2)+'\n')
for name in PLAN['guards']:Guard(name)
Phase('caml_start_program');Phase(PLAN['protected_start'],start=True);Phase(PLAN['endpoint']['symbol'],True)
```
