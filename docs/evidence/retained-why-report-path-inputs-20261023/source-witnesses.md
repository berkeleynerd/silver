# Retained pathname source witnesses

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/loc.ml

### Lines 43–115

```text

  open Wstdlib

  let tag_counter = ref 0

  let file_tags = Hstr.create 7
  let tag_to_file = Hint.create 7

  let get_file_tag file =
    try
      Hstr.find file_tags file
    with Not_found ->
      let n = !tag_counter in
      Hstr.add file_tags file n;
      Hint.add tag_to_file n file;
      incr tag_counter;
      n

  let tag_to_file tag =
    Hint.find tag_to_file tag

end


type position = {
    pos_file_tag : int;
    pos_start : int (* compressed line/col *);
    pos_end : int (* compressed line/col *);
  }

let bits_col =
  if Sys.word_size = 32 then 12 else
  if Sys.word_size = 64 then 16 else
    failwith "word size should be 32 or 64"

let mask_col = (1 lsl bits_col) - 1

let max_line = (1 lsl (Sys.word_size - bits_col - 1)) - 1

let get p =
  let f = FileTags.tag_to_file p.pos_file_tag in
  let b = p.pos_start in
  let e = p.pos_end in
  (f, b lsr bits_col, b land mask_col, e lsr bits_col, e land mask_col)

let sexp_of_expanded_position _ = assert false  [@@warning "-32"]
let expanded_position_of_sexp _ = assert false  [@@warning "-32"]
(* default values if the line below does not produce anything, i.e.,
   when ppx_sexp_conv is not installed *)

type expanded_position = string * int * int * int * int  [@@warning "-34"]
[@@deriving sexp]

let sexp_of_position loc =
  let eloc = get loc in sexp_of_expanded_position eloc
[@@warning "-32"]

let dummy_position =
  let tag = FileTags.get_file_tag "" in
  { pos_file_tag = tag; pos_start = 0; pos_end = 0 }

let join p1 p2 =
  assert (p1.pos_file_tag = p2.pos_file_tag);
  { p1 with
    pos_start = min p1.pos_start p2.pos_start;
    pos_end = max p1.pos_end p2.pos_end }

let compare = Stdlib.compare
let equal = Stdlib.(=)
let hash = Hashtbl.hash

let pp_position_tail fmt bl bc el ec =
  let open Format in
```

### Lines 254–281

```text
let user_position f bl bc el ec =
  if bl < 0 || bl > max_line then
    failwith ("Loc.user_position: start line number `" ^
                string_of_int bl ^ "` out of bounds");
  if bc < 0 then
    failwith ("Loc.user_position: start char number `" ^
                string_of_int bc ^ "` out of bounds");
  (* bc >= mask_col may happen with SPARK, but we do not want to display it *)
  if bc > mask_col && not !warning_emitted then
    begin
      warning warn_start_overflow "Loc.user_position: start char number `%d` overflows on next line" bc;
      warning_emitted := true;
    end;
  if el < 0 || el > max_line then
    failwith ("Loc.user_position: end line number `" ^
                string_of_int el ^ "` out of bounds");
  if ec < 0 then
    failwith ("Loc.user_position: end char number `" ^
                string_of_int ec ^ "` out of bounds");
  (* ec >= mask_col may happen with SPARK, but we do not want to display it *)
  if ec >= mask_col  && not !warning_emitted then
    begin
      warning warn_end_overflow "Loc.user_position: end char number `%d` overflows on next line" ec;
      warning_emitted := true;
    end;
  let tag = FileTags.get_file_tag f in
  { pos_file_tag = tag;
    pos_start = (bl lsl bits_col) lor bc;
```

### Lines 302–360

```text
exception Located of position * exn

let error ?loc e = match loc with
  | Some loc -> raise (Located (loc, e))
  | None -> raise e

let try1 ?loc f x =
  if Debug.test_flag Debug.stack_trace then f x else
  try f x with Located _ as e -> raise e | e -> error ?loc e

let try2 ?loc f x y =
  if Debug.test_flag Debug.stack_trace then f x y else
  try f x y with Located _ as e -> raise e | e -> error ?loc e

let try3 ?loc f x y z =
  if Debug.test_flag Debug.stack_trace then f x y z else
  try f x y z with Located _ as e -> raise e | e -> error ?loc e

let try4 ?loc f x y z t =
  if Debug.test_flag Debug.stack_trace then f x y z t else
  try f x y z t with Located _ as e -> raise e | e -> error ?loc e

let try5 ?loc f x y z t u =
  if Debug.test_flag Debug.stack_trace then f x y z t u else
  try f x y z t u with Located _ as e -> raise e | e -> error ?loc e

let try6 ?loc f x y z t u v =
  if Debug.test_flag Debug.stack_trace then f x y z t u v else
  try f x y z t u v with Located _ as e -> raise e | e -> error ?loc e

let try7 ?loc f x y z t u v w =
  if Debug.test_flag Debug.stack_trace then f x y z t u v w else
  try f x y z t u v w with Located _ as e -> raise e | e -> error ?loc e

(* located messages *)

exception Message of string

let errorm ?loc f =
  Format.kasprintf (fun s -> error ?loc (Message s)) ("@[" ^^ f ^^ "@]")

let () = Exn_printer.register
  (fun fmt exn ->
    let open Format in
    match exn with
    | Located (loc,e) ->
        fprintf fmt "@[File %a:@ %a@]" pp_position loc Exn_printer.exn_printer e
    | Message s ->
        pp_print_string fmt s
    | _ ->
        raise exn)

let with_location f lb =
  if Debug.test_flag Debug.stack_trace then f lb else
    try f lb with
    | Located _ as e -> raise e
    | e ->
       let loc = extract (Lexing.lexeme_start_p lb, Lexing.lexeme_end_p lb) in
       raise (Located (loc, e))
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/plugins/gnat_json/gnat_ast.ml

### Lines 1351–1360

```text
  let source_ptr_from_json : source_ptr from_json = function
    | `Null -> No_location
    | `List [`String filename; `Int line] ->
      Source_ptr {filename; line}
    | json -> unexpected_json "source_ptr" json

  let symbol_from_json : symbol from_json = function
    | `String "" -> No_symbol
    | `String s -> Symbol s
    | json -> unexpected_json "symbol" json
```

### Lines 1649–1662

```text
      } in
      {info; desc}
    | `List [`String "W_LOC_LABEL"; id; domain; sloc; def; marker] ->
      let info = {
        id = int_from_json id;
        domain = domain_from_json domain;
      } in
      let desc = Loc_label {
        sloc = source_ptr_from_json sloc;
        def = expr_opaque_id_from_json def;
        marker = symbol_from_json marker;
      } in
      {info; desc}
    | `List [`String "W_IDENTIFIER"; id; domain; name; typ; labels] ->
```

### Lines 1962–1978

```text
    | `List [`String "W_FUNCTION_DECL"; id; domain; name; binders; effects; pre; post; return_type; def; labels; location] ->
      let info = {
        id = int_from_json id;
        domain = domain_from_json domain;
      } in
      let desc = Function_decl {
        name = identifier_opaque_id_from_json name;
        binders = binder_opaque_olist_from_json binders;
        effects = effects_opaque_oid_from_json effects;
        pre = pred_opaque_oid_from_json pre;
        post = pred_opaque_oid_from_json post;
        return_type = type_opaque_oid_from_json return_type;
        def = expr_opaque_oid_from_json def;
        labels = symbol_set_from_json labels;
        location = source_ptr_from_json location;
      } in
      {info; desc}
```

### Lines 2011–2025

```text
      {info; desc}
    | `List [`String "W_GLOBAL_REF_DECLARATION"; id; domain; name; ref_type; labels; location] ->
      let info = {
        id = int_from_json id;
        domain = domain_from_json domain;
      } in
      let desc = Global_ref_declaration {
        name = identifier_opaque_id_from_json name;
        ref_type = type_opaque_id_from_json ref_type;
        labels = symbol_set_from_json labels;
        location = source_ptr_from_json location;
      } in
      {info; desc}
    | `List [`String "W_NAMESPACE_DECLARATION"; id; domain; declarations; name] ->
      let info = {
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/plugins/gnat_json/gnat_ast_to_ptree.ml

### Lines 60–64

```text
let mk_location = function
  | Source_ptr r ->
      let loc = Loc.user_position r.filename r.line 0 r.line 0 in
      Some (mk_pos loc)
  | No_location -> None
```

### Lines 229–257

```text
module Curr = struct

  let loc_ref = ref No_location
  let marker_ref = ref No_symbol

  let with_ curr f =
    let push (loc, marker) =
      loc_ref := loc;
      marker_ref := marker in
    let pop () =
      let loc, marker = No_location, No_symbol in
      loc_ref := loc;
      marker_ref := marker in
    push curr;
    let res = f () in
    pop ();
    res

  let mk_attrs () =
    match !loc_ref with
    | No_location ->
        []
    | Source_ptr r ->
        let filename =
          match !marker_ref with
          | No_symbol -> r.filename
          | Symbol s -> "'@"^s^"@'"^r.filename in
        Option.(to_list (mk_location (Source_ptr {r with filename})))
end
```

### Lines 539–549

```text
    | Label r ->
        let labels = List.filter_map mk_label r.labels in
        let body = mk_of_expr r.def in
        mk_attrs labels body

    | Loc_label r ->
        Curr.with_ (r.sloc, r.marker)
          (fun () ->
             let curr_attrs = Curr.mk_attrs () in
             let body = mk_of_expr r.def in
             mk_attrs curr_attrs body)
```

### Lines 1084–1097

```text
                        let args = List.map arg_for_param params in
                        List.fold_left (mk_apply ?loc:None) p args in
                      mk_infix left op right)] in
              mk_spec ~post () in
            E.mk_any params Expr.RKnone res_pty pat Ity.MaskVisible spec in
          D.mk_let ident false Expr.RKnone value in
        [logic_decl; let_decl]
  | Prog ->
      Curr.with_ (r.location, No_symbol)
        (fun () ->
           let spec =
             let pre = let open Option in
               let curr_attrs = Curr.mk_attrs () in
               to_list
```

### Lines 1425–1427

```text
let () =
  Env.register_format ~desc:"Gnat@ AST@ in@ JSON@ format"
    Pmodule.mlw_language gnat_json_format [gnat_json_file_ext] read_channel
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/plugins/gnat_json/ptree_constructors.ml

### Lines 10–20

```text
      loc
  | None ->
      incr loc_counter;
      let line = !loc_counter in
      Loc.user_position "<dummy>" line 0 line 0

let mk_ident attrs s = {
  id_str = s;
  id_ats = attrs;
  id_loc = get_pos ();
}
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/core/ident.ml

### Lines 307–351

```text
let char_to_alpha c = match c with
  | 'a'..'z' | 'A'..'Z' -> String.make 1 c
  | ' ' -> "sp" | '_'  -> "us" | '#' -> "sh"
  | '`' -> "bq" | '~'  -> "tl" | '!' -> "ex"
  | '@' -> "at" | '$'  -> "dl" | '%' -> "pc"
  | '^' -> "cf" | '&'  -> "et" | '*' -> "as"
  | '(' -> "lp" | ')'  -> "rp" | '-' -> "mn"
  | '+' -> "pl" | '='  -> "eq" | '[' -> "lb"
  | ']' -> "rb" | '{'  -> "lc" | '}' -> "rc"
  | ':' -> "cl" | '\'' -> "qt" | '"' -> "dq"
  | '<' -> "ls" | '>'  -> "gt" | '/' -> "sl"
  | '?' -> "qu" | '\\' -> "bs" | '|' -> "br"
  | ';' -> "sc" | ','  -> "cm" | '.' -> "dt"
  | '0' -> "zr" | '1'  -> "un" | '2' -> "du"
  | '3' -> "tr" | '4'  -> "qr" | '5' -> "qn"
  | '6' -> "sx" | '7'  -> "st" | '8' -> "oc"
  | '9' -> "nn" | '\n' -> "nl" |  _  -> "zz"

let char_to_lalpha c = Strings.uncapitalize (char_to_alpha c)
let char_to_ualpha c = Strings.capitalize (char_to_alpha c)

let char_to_alnum c =
  match c with '0'..'9' -> String.make 1 c | _ -> char_to_alpha c

let char_to_lalnum c =
  match c with '0'..'9' -> String.make 1 c | _ -> char_to_lalpha c

let char_to_alnumus c =
  match c with '_' | ' ' -> "_" | _ -> char_to_alnum c

let char_to_lalnumus c =
  match c with '_' | ' ' -> "_" | _ -> char_to_lalnum c

let sanitizer' head rest last n =
  let lst = ref [] in
  let n = if n = "" then "zilch" else n in
  let len = String.length n in
  let code i c = lst :=
    (if i = 0 then head
     else if i = len - 1 then last
     else rest) c :: !lst in
  String.iteri code n;
  String.concat "" (List.rev !lst)

let sanitizer head rest n = sanitizer' head rest rest n
```

### Lines 374–423

```text
  Strings.has_prefix ~prefix:"vc:written:" a.attr_string

let eid_attribute_prefix = "eid:"

let is_eid_attr a = Strings.has_prefix ~prefix:eid_attribute_prefix a.attr_string

let create_loc_attr prefix loc =
  let f,bl,bc,el,ec = Loc.get loc in
  (* The file comes last to permit filenames that contain colons *)
  let s = Format.sprintf "%s:%i:%i:%i:%i:%s" prefix bl bc el ec f in
  create_attribute s

let get_loc_attr prefix attr =
  match Strings.remove_prefix ~prefix:(prefix^":") attr.attr_string with
  | exception Not_found -> None
  | str -> match Strings.bounded_split ':' str 5 with
    | [stline; stcol; endline; endcol; file] ->
        begin try
            let stline = int_of_string stline in
            let stcol = int_of_string stcol in
            let endline = int_of_string endline in
            let endcol = int_of_string endcol in
            Some (Loc.user_position file stline stcol endline endcol)
          with _ -> None
        end
    | _ -> None

let create_written_attr = create_loc_attr "vc:written"

let get_written_loc = get_loc_attr "vc:written"

let is_counterexample_attr a =
  is_model_trace_attr a || attr_equal a model_projected_attr ||
  is_written_attr a || is_eid_attr a

let has_a_model_attr id =
  Sattr.exists is_counterexample_attr id.id_attrs

let relevant_for_counterexample id =
  (id.id_loc <> None && not (Sattr.mem proxy_attr id.id_attrs))
  || has_a_model_attr id

let remove_model_attrs ~attrs =
  Sattr.filter (fun l -> not (is_counterexample_attr l)) attrs

let call_result_name = "call_result"

let create_call_result_attr = create_loc_attr call_result_name

let get_call_result_loc = get_loc_attr call_result_name
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/typing.ml

### Lines 258–261

```text
let loc_cutoff loc13 _loc23 loc2 =
  let f,bl,bc,_,_ = Loc.get loc13 in
  let _,_,_,el,ec = Loc.get loc2 in
  Loc.user_position f bl bc el ec
```

### Lines 1756–1759

```text
let type_mlw_file env path filename mlw_file =
  if Debug.test_flag Glob.flag then Glob.clear filename;
  let file = Mstr.empty in
  let loc = Loc.user_position filename 1 0 1 0 in
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/lexer.mll

### Lines 53–71

```text
let op_char_pref = ['!' '?']

rule token = parse
  | "[##" space* ("\"" ([^ '\010' '\013' '"' ]* as file) "\"")?
    space* (dec+ as line) space* (dec+ as char) space* "]"
      { let file =
          Option.map (Lexlib.resolve_file Lexing.(lexbuf.lex_curr_p.pos_fname)) file
        in
        Lexlib.update_loc lexbuf file (int_of_string line) (int_of_string char);
        token lexbuf }
  | "[#" space* "\"" ([^ '\010' '\013' '"' ]* as file) "\""
    space* (dec+ as bline) space* (dec+ as bchar) space*
    space* (dec+ as eline) space* (dec+ as echar) space* "]"
      { let file = Lexlib.resolve_file Lexing.(lexbuf.lex_curr_p.pos_fname) file in
        POSITION (Loc.user_position file (int_of_string bline)
                    (int_of_string bchar) (int_of_string eline) (int_of_string echar)) }
  | "[@" space* ([^ ' ' '\n' ']']+ (' '+ [^ ' ' '\n' ']']+)* as lbl) space* ']'
      { Lexlib.adjust_pos_utf8 lexbuf lbl;
        ATTRIBUTE lbl }
```

### Lines 257–279

```text
  let parse_mlw_file lb = build_parsing_function Parser.Incremental.mlw_file_parsing_only lb

  let read_channel env path file c =
    let lb = Lexing.from_channel c in
    Loc.set_file file lb;
    Typing.open_file env path;
    let mm =
      try
        build_parsing_function Parser.Incremental.mlw_file lb
      with
        e -> ignore (Typing.discard_file ()); raise e
    in
    if path = [] && Debug.test_flag debug then begin
      let print_m _ m = Format.eprintf "%a@\n@." print_module m in
      let add_m _ m mm = Mid.add m.mod_theory.th_name m mm in
      Mid.iter print_m (Mstr.fold add_m mm Mid.empty)
    end;
    mm

  let whyml_format = "whyml"

  let () = Env.register_format mlw_language whyml_format ["mlw";"why"]
      read_channel ~desc:"WhyML@ programming@ and@ specification@ language"
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/lexlib.mll

### Lines 149–169

```text
  let update_loc lexbuf file line chars =
    let pos = lexbuf.lex_curr_p in
    let new_file = match file with None -> pos.pos_fname | Some s -> s in
    lexbuf.lex_curr_p <-
      { pos with
          pos_fname = new_file;
          pos_lnum = line;
          pos_bol = pos.pos_cnum - chars;
      }

  let warn_inexistent_file =
    Loc.register_warning "inexistent_file" "Warn about inexistent file in source location"

  let resolve_file orig_file file =
    try
      Sysutil.resolve_from_paths [Filename.dirname orig_file] file
    with
    | e ->
       Loc.warning warn_inexistent_file "inexistent file in source location: %a" Exn_printer.exn_printer e;
       file

```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/driver/driver.ml

### Lines 68–91

```text
    in
    Sysutil.resolve_from_paths paths name
  else
    (* driver names without extension are searched, with extension
       .drv, in the driver path of Why3 *)
    let paths = [ drivers_path ] in
    Sysutil.resolve_from_paths paths (name ^ ".drv")

let load_file whyconf_main ~extra_dir file =
  let file = resolve_driver_name whyconf_main "drivers" ~extra_dir file in
  let c = open_in file in
  let lb = Lexing.from_channel c in
  Loc.set_file file lb;
  let to_close = Stack.create () in
  Stack.push c to_close;
  let input_lexer filename =
    let c = open_in filename in
    Stack.push c to_close;
    let lb = Lexing.from_channel c in
    Loc.set_file filename lb;
    lb
  in
  let f = Driver_lexer.parse_file whyconf_main input_lexer lb in
  Stack.iter close_in to_close;
```

### Lines 294–309

```text
let get_filename drv ~input_file ~theory_name ~goal_name =
  let sanitize = Ident.sanitizer
    Ident.char_to_alnumus Ident.char_to_alnumus in
  let file = match drv.drv_filename with
    | Some f -> f
    | None -> "%f-%t-%g.dump"
  in
  let replace s = match Re.Str.matched_group 1 s with
    | "%" -> "%"
    | "f" -> sanitize input_file
    | "t" -> sanitize theory_name
    | "g" -> sanitize goal_name
    | s   -> raise (UnknownSpec s)
  in
  Re.Str.global_substitute filename_regexp replace file

```

### Lines 419–476

```text
           in_place and we keep the same file. *)
        false, fn
    | Some fn, _ when interactive <> Some true ->
        (* Example: cvc4. If a file is provided, it means it was passed to
           schedule_proof_attempt via its proof_script_filename argument.
           So we ask to erase and regenerate the file (the advantage is that
           we decide the location of the file).
        *)
        false, fn
    | Some _, _ ->
        (* Example: Coq.
           For Coq, the interactively edited file should be kept (not erased)
           and a new temp file is generated using the old one.
        *)
        let pr = Task.task_goal task in
        let fn = match pr.pr_name.id_loc with
          | Some loc -> let fn,_,_,_,_ = Loc.get loc in Filename.basename fn
          | None -> "" in
        let fn = try Filename.chop_extension fn with Invalid_argument _ -> fn in
        true, get_filename drv
          ~input_file:fn
          ~theory_name:"T"
          ~goal_name:pr.pr_name.id_string
    | _ ->
        (* Example: cvc4 without ?proof_script_filename argument
           No file were provided. We have to generate a new one.
        *)
        let pr = Task.task_goal task in
        let fn = match pr.pr_name.id_loc with
          | Some loc -> let fn,_,_,_,_ = Loc.get loc in Filename.basename fn
          | None -> "" in
        let fn = try Filename.chop_extension fn with Invalid_argument _ -> fn in
        true, get_filename drv
          ~input_file:fn
          ~theory_name:"T"
          ~goal_name:pr.pr_name.id_string

let prove_task_prepared
      ~command ~config ~limits ?old ?inplace ?interactive drv task =
  let buf = Buffer.create 1024 in
  let fmt = formatter_of_buffer buf in
  let old_channel = Option.map open_in old in
  let printing_info = print_task_prepared ?old:old_channel drv fmt task in
  pp_print_flush fmt ();
  Option.iter close_in old_channel;
  let gen_new_file, filename =
    file_name_of_task ?old ?inplace ?interactive drv task in
  let get_model = if get_counterexmp task then Some printing_info else None in
  let res =
    Call_provers.call_on_buffer
      ~command ~config ~limits ~gen_new_file ?inplace ~filename
      ~res_parser:drv.drv_res_parser
      ~get_model buf
  in
  Buffer.reset buf;
  ServerCall res

let prove_buffer_prepared
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/driver/driver_lexer.mll

### Lines 116–141

```text
{
  let parse_file_gen whyconf_main parse input_lexbuf lexbuf =
    let s = Stack.create () in
    Stack.push lexbuf s;
    let rec multifile lex_dumb =
      let lexbuf = Stack.top s in
      let tok = token lexbuf in
      Loc.transfer_loc lexbuf lex_dumb;
      match tok with
      | INPUT filename ->
         let current_dirname = Filename.dirname lexbuf.lex_curr_p.pos_fname in
         let drivers_path = Filename.concat (Whyconf.datadir whyconf_main) "drivers" in
         let paths =
           if current_dirname = drivers_path then [drivers_path] else
             [ current_dirname ; drivers_path ]
         in
         let filename = Sysutil.resolve_from_paths paths filename in
         Stack.push (input_lexbuf filename) s;
         multifile lex_dumb
      | EOF ->
         ignore (Stack.pop s);
         if Stack.is_empty s then EOF else multifile lex_dumb
      | _ -> tok in
    let lex_dumb = Lexing.from_function (fun _ _ -> assert false) in
    Loc.transfer_loc lexbuf lex_dumb;
    Loc.with_location (parse multifile) lex_dumb
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/driver/call_provers.ml

### Lines 154–180

```text
  | OutOfMemory -> fprintf fmt "Out@ of@ memory"
  | StepLimitExceeded -> fprintf fmt "Step@ limit@ exceeded"
  | Unknown s -> fprintf fmt "Unknown@ (%s)" s
  | Failure s -> fprintf fmt "Failure@ (%s)" s
  | HighFailure s -> fprintf fmt "High failure (%s)" s

let print_prover_status fmt = function
  | Unix.WSTOPPED n -> fprintf fmt "stopped by signal %d" n
  | Unix.WSIGNALED n -> fprintf fmt "killed by signal %d" n
  | Unix.WEXITED n -> fprintf fmt "exited with status %d" n

let print_steps fmt s =
  if s >= 0 then fprintf fmt ", %d steps" s

let read_and_delete_file fn =
  let cin = open_in fn in
  let out = Sysutil.channel_contents cin in
  close_in cin;
  if Debug.test_noflag debug then Sys.remove fn;
  out

let json_prover_result r =
  let open Json_base in
  let convert_model (a, m) =
    if not (is_model_empty m) then
      Record [
          "model", json_model m;
```

### Lines 604–618

```text
let call_on_buffer ~command ~config ~limits ~res_parser ~filename ~get_model
    ~gen_new_file ?(inplace=false) buffer =
  let fin,cin =
    if gen_new_file then
      Filename.open_temp_file "why_" ("_" ^ filename)
    else
      begin
        let filename = Sysutil.concat (Sys.getcwd ()) filename in
        if inplace then
          Sys.rename filename (backup_file filename);
        filename, open_out filename
      end
  in
  Buffer.output_buffer cin buffer; close_out cin;
  call_on_file ~command ~config ~limits ~res_parser ~get_model ~inplace fin
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/driver/prove_client.ml

### Lines 20–96

```text
let client_connect ~fail socket_name =
  if !socket <> None then raise AlreadyConnected;
  try
    let sock =
      if Sys.os_type = "Win32" then
        let name = "\\\\.\\pipe\\" ^ Filename.basename socket_name in
        Unix.openfile name [Unix.O_RDWR] 0
      else begin
        let curdir = Sys.getcwd () in
        let dir = Filename.dirname socket_name in
        let fn = Filename.basename socket_name in
        let sock = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
        try
          Sys.chdir dir;
          Unix.connect sock (Unix.ADDR_UNIX fn);
          Sys.chdir curdir;
          sock
        with e ->
          (* Make sure curdir is restored *)
          let bt = Printexc.get_raw_backtrace () in
          Sys.chdir curdir;
          Printexc.raise_with_backtrace e bt
      end
    in
    socket := Some sock
  with
  | Unix.Unix_error(err, func, arg) when fail ->
     let s = Format.sprintf "client_connect: connection failed: %s (%s,%s) (socket_name=%s)@."
             (Unix.error_message err) func arg socket_name in
     raise (ConnectionError s)
  | e when fail ->
     let s = Format.sprintf "client_connect failed for some unexpected reason: %s@\nAborting.@."
                    (Printexc.to_string e) in
     raise (ConnectionError s)

let client_disconnect () =
  match !socket with
  | None -> raise NotConnected
  | Some sock ->
      socket := None;
      if Sys.os_type <> "Win32" then
        Unix.shutdown sock Unix.SHUTDOWN_ALL;
      Unix.close sock

let send_request_string msg =
  match !socket with
  | None -> raise NotConnected
  | Some sock ->
      let to_write = String.length msg in
      let rec write pointer =
        if pointer < to_write then
          let written = Unix.write_substring sock msg pointer (to_write - pointer) in
          write (pointer + written)
      in write 0

let read_from_client =
  let buf = Bytes.make 1024 ' ' in
  fun blocking ->
    match !socket with
    | None -> raise NotConnected
    | Some sock ->
        (* we only call read() if we are allowed to block
           or if the socket is ready *)
        let do_read =
          blocking ||
          (let l,_,_ = Unix.select [sock] [] [] 0.0 in l <> [])
        in
        if do_read then
          let read = Unix.read sock buf 0 1024 in
          Bytes.sub_string buf 0 read
        else ""

(* TODO/FIXME: should we be able to change this setting when
   using an external server? *)
(* TODO/FIXME: this number should be stored server-side and
   consulted via a protocol request, if ever needed. The only
   reason for this reference to be here is to store the config
```

### Lines 178–242

```text
  | Some s ->
      Buffer.add_char send_buf ';';
      Buffer.add_string send_buf s
  end;
  Buffer.add_char send_buf '\n';
  let s = Buffer.contents send_buf in
  send_request_string s

let send_interrupt ~libdir ~id =
  if not (is_connected ()) then connect_internal libdir;
  Buffer.clear send_buf;
  Buffer.add_string send_buf "interrupt;";
  Buffer.add_string send_buf (string_of_int id);
  Buffer.add_char send_buf '\n';
  let s = Buffer.contents send_buf in
  send_request_string s

let rec read_lines blocking =
  let s = read_from_client blocking in
  (* TODO: should we detect and handle EOF here? *)
  if s = "" then [] else
  if String.contains s '\n' then begin
    let s = Buffer.contents recv_buf ^ s in
    Buffer.clear recv_buf;
    let l = Strings.rev_split '\n' s in
    match l with
    | [] -> assert false
    | [x] -> [x]
    | (x::xs) as l ->
      if x = "" then List.rev xs else
      if x.[String.length x - 1] = '\n' then List.rev l
      else begin
        Buffer.add_string recv_buf x;
        List.rev xs
      end
  end else begin
    Buffer.add_string recv_buf s;
    read_lines blocking
  end

type final_answer = {
  id        : int;
  time      : float;
  timeout   : bool;
  out_file  : string;
  exit_code : int64;
}

type answer =
  | Started of int
  | Finished of final_answer

let read_answer s =
  try
    match Strings.split ';' s with
    | "F":: id :: exit_s :: time_s :: timeout_s :: ( (_ :: _) as rest) ->
        (* same trick we use in other parsing code. The file name may contain
           ';'. Luckily, the file name comes last, so we still split on ';',
           and put the pieces back together afterwards *)
        Finished { id = int_of_string id;
          out_file = Strings.join ";" rest;
          time = float_of_string time_s;
          exit_code = Int64.of_string exit_s;
          timeout = (timeout_s = "1"); }
    | "S" :: [id] ->
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/core/env.ml

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

### Lines 41–62

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
  (* Here we search for the driver file. The argument [fn] is the driver path as
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

### Lines 34–45

```text
let opt_proof_mode = ref Progressive
let opt_lazy = ref true
let opt_filename : string option ref = ref None
let opt_parallel = ref 1
let opt_prover : string option ref = ref None
let opt_proof_dir : string option ref = ref None
let opt_ce_mode = ref false
let opt_ce_prover = ref "cvc5_ce"
let opt_warn_prover = ref None
let opt_giant_step_rac : bool ref = ref false
let opt_rac_timelimit = ref (Some 120)
let opt_rac_prover = ref (Some "cvc5")
```

### Lines 552–564

```text
let filename =
   let is_not_why_loc s =
      not (Filename.check_suffix s "why" ||
           Filename.check_suffix s "mlw" ||
           Filename.check_suffix s "gnat-json") in
   match !opt_filename with
   | None -> Gnat_util.abort_with_message ~internal:true "No file given."
   | Some s ->
         if is_not_why_loc s then
            Gnat_util.abort_with_message ~internal:true
              (Printf.sprintf "Not a Why input file: %s." s);
         s

```

### Lines 675–742

```text
let unit_name =
  let suffix = ".mlw" in
  if Strings.has_suffix filename ~suffix then
    String.sub filename 0 (String.length filename - String.length suffix)
  else Filename.chop_extension filename

let socket_name = !opt_socket_name

let stand_alone = !opt_standalone

let proof_dir = !opt_proof_dir

(* when not doing proof, stop after typing to avoid cost of the WP *)
let () =
  if proof_mode = No_WP then Debug.set_flag Typing.debug_type_only;
(*  Debug.set_flag (Debug.lookup_flag "fast_wp");*)
  let curdir = Sys.getcwd () in
  Unix.putenv "TEMP" curdir;
  Unix.putenv "TEMPDIR" curdir

let is_selected_prover p =
  try
    Some (List.find (fun g ->
      g = p) provers)
  with Not_found -> None

let is_ce_prover s p =
  counterexamples &&
  match prover_ce with
  | None -> false
  | Some cep ->
      let prover = (Session_itp.get_proof_attempt_node s p).Session_itp.prover in
      cep = prover

let replay = !opt_replay

(* TODO get_project_dir is the one from Session. We should be able to not use it *)
let db_filename = "why3session.xml"

let get_project_dir fname =
  if not (Sys.file_exists fname) then raise Not_found;
  let d =
    if Sys.is_directory fname then fname
    else if Filename.basename fname = db_filename then begin
      Filename.dirname fname
    end
    else
      begin
        try Filename.chop_extension fname
        with Invalid_argument _ -> fname^".w3s"
      end
  in
  d

let session_dir =
  let project_dir =
    try get_project_dir filename
    with Not_found ->
    Gnat_util.abort_with_message ~internal:true
      (Pp.sprintf "could not compute session file for %s" filename)
  in
  match proof_dir with
  | None -> project_dir
  | Some dir_name ->
     Filename.concat (Filename.concat dir_name "sessions")
                     (Filename.basename project_dir)

let session_file = Filename.concat session_dir "why3ession.xml"
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/gnat/gnat_checks.ml

### Lines 56–61

```text

  let outc = ref stdout

  let init () =
    outc := open_out (Gnat_config.unit_name ^ ".why3log")

```

### Lines 380–420

```text
let init_cont () =
  let session_dir = Gnat_config.session_dir in
  (* Shape version is only used for pairing of goals in session_itp.ml
     (nothing else). *)
  let is_new_session, session =
    if not Gnat_config.force && Sys.file_exists session_dir then
      try false, Session_itp.load_session session_dir
      with _ ->
        Gnat_util.abort_with_message ~internal:false
        (Pp.sprintf "error loading session located in %s, please delete the session and try again"
         session_dir)
    else begin
      if not (Sys.file_exists session_dir) then Unix.mkdir session_dir 0o700;
      true, Session_itp.empty_session session_dir
    end
  in
  let c = Controller_itp.create_controller Gnat_config.config Gnat_config.env session in
  if is_new_session || not (has_file session) then begin
    try
      Controller_itp.add_file c Gnat_config.filename
    with
    | Controller_itp.Errors_list l ->
      List.iter (fun exn ->
        match exn with
          | Out_of_memory | Loc.Located (_, Out_of_memory) ->
            raise Out_of_memory
          | _ -> ())
      l;
        Gnat_util.abort_with_message ~internal:true
          (Pp.sprintf "could not add file %s to the session: %a"
             Gnat_config.filename (Pp.print_list Pp.space Exn_printer.exn_printer) l)
  end;

  (* Init why3server *)
  init ();
  if Gnat_config.logging then Logging.init ();
  if is_new_session then c
  else
    begin
      let ses = c.Controller_itp.controller_session in
       (* Filenames saved inside the session *)
```

### Lines 1060–1077

```text
    let callback pa pas =
      let prover =
        (Session_itp.get_proof_attempt_node s pa).Session_itp.prover.Whyconf.prover_name
      in
      if Gnat_config.logging then Logging.log g prover pas;
      if !remaining = 0 then ()
      else match pas with
        | Controller_itp.Done pr ->
          remaining := !remaining - 1;
          begin match pr.Call_provers.pr_answer with
          | Call_provers.Valid ->
            C.interrupt_proof_attempts_for_goal c g;
            remaining := 0;
            callback pa pas
          | _ ->
            if !remaining = 0 then callback pa pas else ()
          end
        | _ -> ()
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/session/session_itp.ml

### Lines 620–640

```text
  { proofAttempt_table = Hint.create 97;
    next_proofAttemptID = 0;
    proofNode_table = Hint.create 97;
    next_proofNodeID = 0;
    trans_table = Hint.create 97;
    next_transID = 0;
    next_fileID = 0;
    session_dir = dir;
    session_files = Hfile.create 3;
    session_prover_ids = prover_ids;
    shapes = empty_shapes;
    session_raw_tasks = Hpn.create 97;
    session_task_tables = Hpn.create 97;
    file_state = Hfile.create 3;
    th_state = Ident.Hid.create 7;
    tn_state = Htn.create 97;
    pn_state = Hpn.create 97;
  }

(**************************************************)
(* proof node/attempt/transformation manipulation *)
```

### Lines 958–970

```text

(****************************)
(*     session opening      *)
(****************************)

let db_filename = "why3session.xml"
let shape_filename = "why3shapes"
let compressed_shape_filename = "why3shapes.gz"
let session_dir_for_save = ref "."

exception LoadError of Xml.element * string
exception SessionFileError of string

```

### Lines 2170–2176

```text
  fprintf fmt "@]@\n</file>"

let save fname shfname session =
  let ch = open_out fname in
  let chsh = Compress.Compress_z.open_out shfname in
  let fmt = formatter_of_out_channel ch in
  fprintf fmt "<?xml version=\"1.0\" encoding=\"UTF-8\"?>@\n";
```

### Lines 2212–2244

```text
let save_session (s : session) =
  let uniformize_shape () =
    (* When all is detached, don't erase the current shapes to not lose nodes *)
    if not (Hfile.fold (fun _ f b -> is_detached s (AFile f) && b)
              (get_files s) true) then
      begin
        Sshape.clear_only_shape s;
        s.shapes.shape_version <- Termcode.current_sum_shape_version;
        fold_all_session s (fun () any ->
            match any with
            | APn g when not (is_detached s any)  ->
                let t = get_task s g in
                let (_, expl, _) =
                  let root =
                    match get_proof_parent s g with
                    | Trans _ -> false | Theory _ -> true in
                  Termcode.goal_expl_task ~root t in
                Sshape.compute_and_add_shape s ~expl g t;
            | _ -> ()) ()
      end in
  (* Used here so that shape do not save artifacts of the old saved shapes or
     removed goals (making them grow). It also ensures the order of hypothesis
     is deterministic between two runs of Why3. *)
  uniformize_shape ();
  let f = Filename.concat s.session_dir db_filename in
  Sysutil.backup_file f;
  let fs = Filename.concat s.session_dir shape_filename in
  Sysutil.backup_file fs;
  let fz = Filename.concat s.session_dir compressed_shape_filename in
  Sysutil.backup_file fz;
  session_dir_for_save := s.session_dir;
  let fs = if Compress.compression_supported then fz else fs in
  save f fs s
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/gnat/gnat_main.ml

### Lines 280–291

```text
  (* Dump profiling data (when compiled with profiling enabled) to file whose
     name is based on the processed .mlw file; otherwise profile data from
     several compilation would be written to a single gmon.out file and
     overwrite each other. When compiled with profiling disabled it has no
     visible effect. Note: we set the filename just before the program exit
     to not interfere with profiling of provers.
   *)
  let basename =
    Filename.chop_extension
      (Filename.basename Gnat_config.filename) in
  Unix.putenv "GMON_OUT_PREFIX" (basename ^ "_gnatwhy3_gmon.out")

```

### Lines 324–329

```text
      let log = Sys.getenv "GNATWHY3LOG" in
      let out = open_out_gen [Open_text; Open_creat; Open_append] 0o666 log in
      let fmt = Format.formatter_of_out_channel out in
      Debug.set_debug_formatter fmt;
      Format.fprintf fmt "@.@.===== %s@." Gnat_config.filename;
      Loc.set_warning_hook (fun ?loc:_ line -> Format.fprintf fmt "%s@." line)
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

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/driver/whyconf.ml

### Lines 218–236

```text
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
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/session/controller_itp.ml

### Lines 518–540

```text

  (* if the number of prover tasks is less than S.multiplier times the maximum
     number of running provers, then we heuristically decide to add
     more tasks *)
  begin
    try
      if S.blocking ||
         (Hashtbl.length prover_tasks_in_progress <
          S.multiplier * !session_max_tasks)
      then
        let spa = Queue.pop scheduled_proof_attempts in
        try
          build_prover_call spa;
          update_observer ()
        with e when not (Debug.test_flag Debug.stack_trace) ->
          spa.spa_callback (InternalFailure e)
    with Queue.Empty -> idle_handler_running := false
  end;
  !idle_handler_running

let interrupt c =
  let config = Whyconf.get_main c.controller_config in
  (* Interrupt provers *)
```

### Lines 591–619

```text

let schedule_proof_attempt ?proof_script_filename c id pr ~limits ~callback ~notification =
  let ses = c.controller_session in
  let callback panid s =
    begin
      match s with
      | UpgradeProver _ | Removed _ -> ()
      | Scheduled ->
         Hpan.add c.controller_running_proof_attempts panid ();
         update_goal_node notification ses id
      | Running -> update_goal_node notification ses id
      | Done res ->
         Hpan.remove c.controller_running_proof_attempts panid;
         update_proof_attempt ~obsolete:false notification ses id pr res;
         update_goal_node notification ses id
      | Interrupted
      | InternalFailure _ ->
         Hpan.remove c.controller_running_proof_attempts panid;
         (* what to do ?
         update_proof_attempt ~obsolete:false notification ses id pr res;
          *)
         update_goal_node notification ses id
      | Detached -> assert false
      | Uninstalled _ -> assert false
      | Undone -> assert false
    end;
    callback panid s
  in
  let adaptlimits,ores,proof_script =
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/sysutil.ml

### Lines 10–20

```text

let backup_file f =
  if Sys.file_exists f then begin
    let fb = f ^ ".bak" in
    if Sys.file_exists fb then Sys.remove fb;
    Sys.rename f fb
  end

let channel_contents_fmt cin fmt =
  let buff = Bytes.create 1024 in
  let n = ref 0 in
```

### Lines 43–62

```text
  with End_of_file -> acc

let file_contents_fmt f fmt =
  try
    let cin = open_in f in
    channel_contents_fmt cin fmt;
    close_in cin
  with _ ->
    invalid_arg (Printf.sprintf "(cannot open %s)" f)

let file_contents_buf f =
  try
    let cin = open_in f in
    let buf = channel_contents_buf cin in
    close_in cin;
    buf
  with _ ->
    invalid_arg (Printf.sprintf "(cannot open %s)" f)

let file_contents f = Buffer.contents (file_contents_buf f)
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/filename.ml

### Lines 88–122

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
    is_relative n
    && (String.length n < 2 || String.sub n 0 2 <> "./")
    && (String.length n < 3 || String.sub n 0 3 <> "../")
  let check_suffix name suff =
    String.ends_with ~suffix:suff name

  let chop_suffix_opt ~suffix filename =
    let len_s = String.length suffix and len_f = String.length filename in
    if len_f >= len_s then
      let r = String.sub filename (len_f - len_s) len_s in
      if r = suffix then
        Some (String.sub filename 0 (len_f - len_s))
      else
        None
    else
      None

  let temp_dir_name =
    try Sys.getenv "TMPDIR" with Not_found -> "/tmp"
  let quote = generic_quote "'\\''"
  let quote_command cmd ?stdin ?stdout ?stderr args =
    String.concat " " (List.map quote (cmd :: args))
    ^ (match stdin  with None -> "" | Some f -> " <" ^ quote f)
    ^ (match stdout with None -> "" | Some f -> " >" ^ quote f)
```

### Lines 289–360

```text
let concat dirname filename =
  let l = String.length dirname in
  if l = 0 || is_dir_sep dirname (l-1)
  then dirname ^ filename
  else dirname ^ dir_sep ^ filename

let chop_suffix name suff =
  if check_suffix name suff
  then String.sub name 0 (String.length name - String.length suff)
  else invalid_arg "Filename.chop_suffix"

let extension_len name =
  let rec check i0 i =
    if i < 0 || is_dir_sep name i then 0
    else if name.[i] = '.' then check i0 (i - 1)
    else String.length name - i0
  in
  let rec search_dot i =
    if i < 0 || is_dir_sep name i then 0
    else if name.[i] = '.' then check i (i - 1)
    else search_dot (i - 1)
  in
  search_dot (String.length name - 1)

let extension name =
  let l = extension_len name in
  if l = 0 then "" else String.sub name (String.length name - l) l

let chop_extension name =
  let l = extension_len name in
  if l = 0 then invalid_arg "Filename.chop_extension"
  else String.sub name 0 (String.length name - l)

let remove_extension name =
  let l = extension_len name in
  if l = 0 then name else String.sub name 0 (String.length name - l)

external open_desc: string -> open_flag list -> int -> int = "caml_sys_open"
external close_desc: int -> unit = "caml_sys_close"

let prng = lazy(Random.State.make_self_init ())

let temp_file_name temp_dir prefix suffix =
  let rnd = (Random.State.bits (Lazy.force prng)) land 0xFFFFFF in
  concat temp_dir (Printf.sprintf "%s%06x%s" prefix rnd suffix)


let current_temp_dir_name = ref temp_dir_name

let set_temp_dir_name s = current_temp_dir_name := s
let get_temp_dir_name () = !current_temp_dir_name

let temp_file ?(temp_dir = !current_temp_dir_name) prefix suffix =
  let rec try_name counter =
    let name = temp_file_name temp_dir prefix suffix in
    try
      close_desc(open_desc name [Open_wronly; Open_creat; Open_excl] 0o600);
      name
    with Sys_error _ as e ->
      if counter >= 1000 then raise e else try_name (counter + 1)
  in try_name 0

let open_temp_file ?(mode = [Open_text]) ?(perms = 0o600)
                   ?(temp_dir = !current_temp_dir_name) prefix suffix =
  let rec try_name counter =
    let name = temp_file_name temp_dir prefix suffix in
    try
      (name,
       open_out_gen (Open_wronly::Open_creat::Open_excl::mode) perms name)
    with Sys_error _ as e ->
      if counter >= 1000 then raise e else try_name (counter + 1)
  in try_name 0
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/sys.c

### Lines 76–93

```text
CAMLexport void caml_sys_error(value arg)
{
  CAMLparam1 (arg);
  char * err;
  CAMLlocal1 (str);

  err = error_message();
  if (arg == NO_ARG) {
    str = caml_copy_string(err);
  } else {
    mlsize_t err_len = strlen(err);
    mlsize_t arg_len = caml_string_length(arg);
    str = caml_alloc_string(arg_len + 2 + err_len);
    memmove(&Byte(str, 0), String_val(arg), arg_len);
    memmove(&Byte(str, arg_len), ": ", 2);
    memmove(&Byte(str, arg_len + 2), err, err_len);
  }
  caml_raise_sys_error(str);
```

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

### Lines 299–319

```text

CAMLprim value caml_sys_rename(value oldname, value newname)
{
  char_os * p_old;
  char_os * p_new;
  int ret;
  caml_sys_check_path(oldname);
  caml_sys_check_path(newname);
  p_old = caml_stat_strdup_to_os(String_val(oldname));
  p_new = caml_stat_strdup_to_os(String_val(newname));
  caml_enter_blocking_section();
  ret = rename_os(p_old, p_new);
  caml_leave_blocking_section();
  caml_stat_free(p_new);
  caml_stat_free(p_old);
  if (ret != 0)
    caml_sys_error(NO_ARG);
  return Val_unit;
}

CAMLprim value caml_sys_chdir(value dirname)
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/otherlibs/unix/rename.c

### Lines 23–40

```text
{
  CAMLparam2(path1, path2);
  char * p1;
  char * p2;
  int ret;
  caml_unix_check_path(path1, "rename");
  caml_unix_check_path(path2, "rename");
  p1 = caml_stat_strdup(String_val(path1));
  p2 = caml_stat_strdup(String_val(path2));
  caml_enter_blocking_section();
  ret = rename(p1, p2);
  caml_leave_blocking_section();
  caml_stat_free(p2);
  caml_stat_free(p1);
  if (ret == -1)
    uerror("rename", path1);
  CAMLreturn(Val_unit);
}
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/otherlibs/unix/putenv.c

### Lines 31–55

```text
CAMLprim value unix_putenv(value name, value val)
{
  char * s;
  char_os * p;
  int ret;

  if (! (caml_string_is_c_safe(name) && caml_string_is_c_safe(val)))
    unix_error(EINVAL, "putenv", name);
  s = caml_stat_strconcat(3, name, "=", val);
  p = caml_stat_strdup_to_os(s);
  caml_stat_free(s);
  ret = putenv_os(p);
  if (ret == -1) {
    caml_stat_free(p);
    uerror("putenv", name);
  }
  return Val_unit;
}

#else

CAMLprim value unix_putenv(value name, value val)
{ caml_invalid_argument("putenv not implemented"); }

#endif
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/otherlibs/unix/read.c

### Lines 1–38

```text
/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <string.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/signals.h>
#include "unixsupport.h"

CAMLprim value unix_read(value fd, value buf, value ofs, value len)
{
  long numbytes;
  int ret;
  char iobuf[UNIX_BUFFER_SIZE];

  Begin_root (buf);
    numbytes = Long_val(len);
    if (numbytes > UNIX_BUFFER_SIZE) numbytes = UNIX_BUFFER_SIZE;
    caml_enter_blocking_section();
    ret = read(Int_val(fd), iobuf, (int) numbytes);
    caml_leave_blocking_section();
    if (ret == -1) uerror("read", Nothing);
    memmove (&Byte(buf, Long_val(ofs)), iobuf, ret);
  End_roots();
  return Val_int(ret);
}
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/otherlibs/unix/write.c

### Lines 1–86

```text
/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <errno.h>
#include <string.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/signals.h>
#include "unixsupport.h"

#ifndef EAGAIN
#define EAGAIN (-1)
#endif
#ifndef EWOULDBLOCK
#define EWOULDBLOCK (-1)
#endif

CAMLprim value unix_write(value fd, value buf, value vofs, value vlen)
{
  long ofs, len, written;
  int numbytes, ret;
  char iobuf[UNIX_BUFFER_SIZE];

  Begin_root (buf);
    ofs = Long_val(vofs);
    len = Long_val(vlen);
    written = 0;
    while (len > 0) {
      numbytes = len > UNIX_BUFFER_SIZE ? UNIX_BUFFER_SIZE : len;
      memmove (iobuf, &Byte(buf, ofs), numbytes);
      caml_enter_blocking_section();
      ret = write(Int_val(fd), iobuf, numbytes);
      caml_leave_blocking_section();
      if (ret == -1) {
        if ((errno == EAGAIN || errno == EWOULDBLOCK) && written > 0) break;
        uerror("write", Nothing);
      }
      written += ret;
      ofs += ret;
      len -= ret;
    }
  End_roots();
  return Val_long(written);
}

/* When an error occurs after the first loop, unix_write reports the
   error and discards the number of already written characters.
   In this case, it would be better to discard the error and return the
   number of bytes written, since most likely, unix_write will be call again,
   and the error will be reproduced and this time will be reported.
   This problem is avoided in unix_single_write, which is faithful to the
   Unix system call. */

CAMLprim value unix_single_write(value fd, value buf, value vofs, value vlen)
{
  long ofs, len;
  int numbytes, ret;
  char iobuf[UNIX_BUFFER_SIZE];

  Begin_root (buf);
    ofs = Long_val(vofs);
    len = Long_val(vlen);
    ret = 0;
    if (len > 0) {
      numbytes = len > UNIX_BUFFER_SIZE ? UNIX_BUFFER_SIZE : len;
      memmove (iobuf, &Byte(buf, ofs), numbytes);
      caml_enter_blocking_section();
      ret = write(Int_val(fd), iobuf, numbytes);
      caml_leave_blocking_section();
      if (ret == -1) uerror("single_write", Nothing);
    }
  End_roots();
  return Val_int(ret);
}
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/otherlibs/unix/select.c

### Lines 1–114

```text
/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/signals.h>
#include "unixsupport.h"

#ifdef HAS_SELECT

#include <sys/types.h>
#include <sys/time.h>
#ifdef HAS_SYS_SELECT_H
#include <sys/select.h>
#endif
#include <string.h>
#include <unistd.h>
#include <errno.h>

static int fdlist_to_fdset(value fdlist, fd_set *fdset, int *maxfd)
{
  value l;
  FD_ZERO(fdset);
  for (l = fdlist; l != Val_int(0); l = Field(l, 1)) {
    long fd = Long_val(Field(l, 0));
    /* PR#5563: harden against bad fds */
    if (fd < 0 || fd >= FD_SETSIZE) return -1;
    FD_SET((int) fd, fdset);
    if (fd > *maxfd) *maxfd = fd;
  }
  return 0;
}

static value fdset_to_fdlist(value fdlist, fd_set *fdset)
{
  value l;
  value res = Val_int(0);

  Begin_roots2(l, res);
    for (l = fdlist; l != Val_int(0); l = Field(l, 1)) {
      int fd = Int_val(Field(l, 0));
      if (FD_ISSET(fd, fdset)) {
        value newres = caml_alloc_small(2, 0);
        Field(newres, 0) = Val_int(fd);
        Field(newres, 1) = res;
        res = newres;
      }
    }
  End_roots();
  return res;
}

CAMLprim value unix_select(value readfds, value writefds, value exceptfds,
                           value timeout)
{
  fd_set read, write, except;
  int maxfd;
  double tm;
  struct timeval tv;
  struct timeval * tvp;
  int retcode;
  value res;

  Begin_roots3 (readfds, writefds, exceptfds);
    maxfd = -1;
    retcode  = fdlist_to_fdset(readfds, &read, &maxfd);
    retcode += fdlist_to_fdset(writefds, &write, &maxfd);
    retcode += fdlist_to_fdset(exceptfds, &except, &maxfd);
    /* PR#5563: if a bad fd was encountered, report EINVAL error */
    if (retcode != 0) unix_error(EINVAL, "select", Nothing);
    tm = Double_val(timeout);
    if (tm < 0.0)
      tvp = (struct timeval *) NULL;
    else {
      tv.tv_sec = (int) tm;
      tv.tv_usec = (int) (1e6 * (tm - tv.tv_sec));
      tvp = &tv;
    }
    caml_enter_blocking_section();
    retcode = select(maxfd + 1, &read, &write, &except, tvp);
    caml_leave_blocking_section();
    if (retcode == -1) uerror("select", Nothing);
    readfds = fdset_to_fdlist(readfds, &read);
    writefds = fdset_to_fdlist(writefds, &write);
    exceptfds = fdset_to_fdlist(exceptfds, &except);
    res = caml_alloc_small(3, 0);
    Field(res, 0) = readfds;
    Field(res, 1) = writefds;
    Field(res, 2) = exceptfds;
  End_roots();
  return res;
}

#else

CAMLprim value unix_select(value readfds, value writefds, value exceptfds,
                           value timeout)
{ caml_invalid_argument("select not implemented"); }

#endif
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/otherlibs/unix/shutdown.c

### Lines 1–40

```text
/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <caml/fail.h>
#include <caml/mlvalues.h>
#include "unixsupport.h"

#ifdef HAS_SOCKETS

#include <sys/socket.h>

static int shutdown_command_table[] = {
  0, 1, 2
};

CAMLprim value unix_shutdown(value sock, value cmd)
{
  if (shutdown(Int_val(sock), shutdown_command_table[Int_val(cmd)]) == -1)
    uerror("shutdown", Nothing);
  return Val_unit;
}

#else

CAMLprim value unix_shutdown(value sock, value cmd)
{ caml_invalid_argument("shutdown not implemented"); }

#endif
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/otherlibs/unix/close.c

### Lines 1–28

```text
/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           */
/*                                                                        */
/*   Copyright 1996 Institut National de Recherche en Informatique et     */
/*     en Automatique.                                                    */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <caml/mlvalues.h>
#include <caml/signals.h>
#include "unixsupport.h"

CAMLprim value unix_close(value fd)
{
  int ret;
  caml_enter_blocking_section();
  ret = close(Int_val(fd));
  caml_leave_blocking_section();
  if (ret == -1) uerror("close", Nothing);
  return Val_unit;
}
```
