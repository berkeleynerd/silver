# FileTags source witnesses

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/loc.ml

### Lines 13–30

```text
open Lexing

let current_offset = ref 0
let reloc p = { p with pos_cnum = p.pos_cnum + !current_offset }

let set_file file lb =
  lb.Lexing.lex_curr_p <-
    { lb.Lexing.lex_curr_p with Lexing.pos_fname = file }

let transfer_loc lb_from lb_to =
  lb_to.lex_start_p <- lb_from.lex_start_p;
  lb_to.lex_curr_p <- lb_from.lex_curr_p

(*

To reduce memory consumption, a pair (line,col) is stored in a single
   int using

```

### Lines 42–115

```text
module FileTags = struct

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

### Lines 254–298

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
    pos_end = (el lsl bits_col) lor ec }


let position_of_sexp sexp =
  let (s,bl,bc,el,ec) = expanded_position_of_sexp sexp in
  user_position s bl bc el ec
                          [@@warning "-32"]


let extract (b,e) =
  let f = b.pos_fname in
  let bl = b.pos_lnum in
  let bc = b.pos_cnum - b.pos_bol in
  let el = e.pos_lnum in
  let ec = e.pos_cnum - e.pos_bol in
  user_position f bl bc el ec

```

### Lines 343–360

```text
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

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/loc.mli

### Lines 25–100

```text
*)

type position
[@@deriving sexp]

val user_position : string -> int -> int -> int -> int -> position
(** [user_position f bl bc el ec] builds the source position for file
    [f], starting at line [bl] and character [bc] and ending at line
    [el] and character [ec]. *)

val dummy_position : position
(** Dummy source position. *)

val get : position -> string * int * int * int * int
(** [get p] returns the file, the line and character numbers of the
    beginning and the line and character numbers of the end of the
    given position. *)

val join : position -> position -> position
(** [join p1 p2] attempts to join positions [p1] and [p2],
    returning a position that covers both of them. This function
    assumes that the files are the same. *)


val compare : position -> position -> int
val equal : position -> position -> bool
val hash : position -> int

val pp_position : formatter -> position -> unit
(** [pp_position fmt loc] formats the position [loc] in the given
    formatter, in a human readable way, that is:
    - either ["filename", line l, characters bc--ec] if the position is on a single line,
    - or ["filename", line bl, character bc to line el, character ce] if the position is multi-line.

    The file name is not printed if empty. *)

val pp_position_no_file : formatter -> position -> unit
(** Similar to [pp_position] but do not show the file name. *)

(** {2 Helper functions about OCaml locations used in module [Lexing]} *)

val extract : Lexing.position * Lexing.position -> position
(** [extract p1 p2] build a source position from two OCaml lexing
   positions *)

val current_offset : int ref
val reloc : Lexing.position -> Lexing.position
(** [reloc l] returns the location with character num augmented by [!current_offset]. *)

val set_file : string -> Lexing.lexbuf -> unit
(** [set_file f lb] sets the file name to [f] in [lb]. *)

val transfer_loc : Lexing.lexbuf -> Lexing.lexbuf -> unit
(** [transfer_loc from to] sets the [lex_start_p] and [lex_curr_p]
   fields of [to] to the ones of [from]. *)

(** {2 Located warnings} *)

type warning_id
(** warning identifiers *)

val register_warning : string -> Pp.formatted -> warning_id
(** [register_warning name desc] registers a new warning under the
   given [name] with the given [desc]ription. *)

val warning: warning_id ->
  ?loc:position -> ('b, Format.formatter, unit, unit) format4 -> 'b
(** [warning ~id ~loc fmt] emits a warning in the given formattter
   [fmt]. Adds the location [loc] if it is given. Emits nothing if the
   [id] is given and disabled, with one of the functions below. *)

val without_warning : warning_id -> (unit -> 'a) -> 'a
(** Given a warning identifier, execute an inner operation with the
   warning temporarily disabled. *)

val disable_warning : warning_id -> unit
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/wstdlib.ml

### Lines 13–32

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


```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/exthtbl.ml

### Lines 38–50

```text
let hash = Hashtbl.hash

module Make (X:Hashtbl.HashedType) : S with type key = X.t =
struct
  module M = Hashtbl.Make(X)
  include M

  let memo size f =
    let h = create size in
    fun x -> try find h x
      with Not_found -> let y = f x in add h x y; y

  let find_def h d k =
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/util/lexlib.mll

### Lines 18–31

```text
  let () = Exn_printer.register (fun fmt e -> match e with
    | IllegalEscape -> Format.pp_print_string fmt "illegal escape"
    | IllegalCharInString -> Format.pp_print_string fmt "illegal character in string"
    | UnterminatedString -> Format.pp_print_string fmt "unterminated string"
    | _ -> raise e)

  let loc lb = Loc.extract (lb.lex_start_p,lb.lex_curr_p)

  let char_for_backslash = function
    | '\\' -> '\\'
    | 'n'  -> '\n'
    | 'r'  -> '\r'
    | 't'  -> '\t'
    | 'b'  -> '\b'
```

### Lines 131–145

```text
  exception UnterminatedComment
  exception IllegalCharacter of string

  let () = Exn_printer.register (fun fmt e -> match e with
    | UnterminatedComment -> Format.pp_print_string fmt "unterminated comment"
    | IllegalCharacter s -> Format.fprintf fmt "illegal character %s" s
    | _ -> raise e)

  let loc lb = Loc.extract (lexeme_start_p lb, lexeme_end_p lb)

  let comment lexbuf =
    let start = loc lexbuf in
    try comment lexbuf
    with Not_found -> raise (Loc.Located (start, UnterminatedComment))

```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/lexer.mll

### Lines 59–73

```text
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
  | '\n'
      { Lexing.new_line lexbuf; token lexbuf }
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

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/parser_common.mly

### Lines 18–39

```text
%{
  open Ptree

  let floc s e = Loc.extract (s,e)

  let add_attr id l = (* id.id_ats is usually nil *)
    { id with id_ats = List.rev_append id.id_ats l }

  let id_anonymous loc = Ptree_helpers.ident ~loc "_"

  let mk_id id s e = Ptree_helpers.ident ~loc:(floc s e) id

  let get_op  q s e = Qident (mk_id (Ident.op_get q) s e)
  let upd_op  q s e = Qident (mk_id (Ident.op_update q) s e)
  let cut_op  q s e = Qident (mk_id (Ident.op_cut q) s e)
  let rcut_op q s e = Qident (mk_id (Ident.op_rcut q) s e)
  let lcut_op q s e = Qident (mk_id (Ident.op_lcut q) s e)

  let mk_pat  d s e = Ptree_helpers.pat ~loc:(floc s e) d
  let mk_term d s e = Ptree_helpers.term ~loc:(floc s e) d
  let mk_expr d s e = Ptree_helpers.expr ~loc:(floc s e) d

```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/parser.mly

### Lines 66–98

```text
    { let loc = floc $startpos($3) $endpos($3) in
      Typing.close_module loc; Typing.close_file () }

mlw_file_parsing_only:
| EOF { (Modules([])) }
| mlw_module_parsing_only mlw_module_no_decl_parsing_only* EOF { (Modules( [$1] @ $2)) }
| module_decl_parsing_only module_decl_no_head_parsing_only* EOF { (Decls( [$1] @ $2)) }


mlw_module:
| module_head module_decl_no_head* END
    { Typing.close_module (floc $startpos($3) $endpos($3)) }

mlw_module_parsing_only:
| module_head_parsing_only module_decl_no_head_parsing_only* END { ($1,$2) }

module_head:
| THEORY attrs(uident_nq)  { Typing.open_module $2 }
| MODULE attrs(uident_nq) intf = option(preceded(COLON, tqualid))
    { Typing.open_module ?intf $2 }

scope_head:
| SCOPE boption(IMPORT) attrs(uident_nq)
    { Typing.open_scope (floc $startpos $endpos) $3; $2 }

module_decl:
| scope_head module_decl* END
    { Typing.close_scope (floc $startpos($1) $endpos($1)) ~import:$1 }
| IMPORT uqualid
    { Typing.add_decl (floc $startpos $endpos) (Dimport($2)) }
| d = pure_decl | d = prog_decl | d = meta_decl
    { Typing.add_decl (floc $startpos $endpos) d }
| use_clone { () }
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/typing.ml

### Lines 258–261

```text
let loc_cutoff loc13 _loc23 loc2 =
  let f,bl,bc,_,_ = Loc.get loc13 in
  let _,_,_,el,ec = Loc.get loc2 in
  Loc.user_position f bl bc el ec
```

### Lines 1756–1770

```text
let type_mlw_file env path filename mlw_file =
  if Debug.test_flag Glob.flag then Glob.clear filename;
  let file = Mstr.empty in
  let loc = Loc.user_position filename 1 0 1 0 in
  let file =
    match mlw_file with
    | Ptree.Decls decls -> type_module file env loc path ({id_str=""; id_ats=[]; id_loc=loc},decls)
    | Ptree.Modules m_or_t ->
        let type_module_env_loc_path file (id,dl) = type_module file env loc path (id,dl) in
        List.fold_left type_module_env_loc_path file m_or_t
  in
  file

module Unsafe = struct
  let dexpr = dexpr
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/core/ident.ml

### Lines 380–423

```text
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

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/plugins/gnat_json/gnat_ast_to_ptree.ml

### Lines 57–66

```text
  | No_symbol -> None
  | Symbol s -> Some (ATstr (Ident.create_attribute s))

let mk_location = function
  | Source_ptr r ->
      let loc = Loc.user_position r.filename r.line 0 r.line 0 in
      Some (mk_pos loc)
  | No_location -> None

let mk_idents ~notation attrs =
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

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/mlw_printer.ml

### Lines 20–28

```text

let dummy_filename = ""

let id_loc_counter = ref 0

let id_loc () =
  incr id_loc_counter;
  Loc.user_position dummy_filename !id_loc_counter 0 !id_loc_counter 0

```

### Lines 73–83

```text
        fprintf fmt "%a(*%s*)@ %a" pp_loc_id loc msg pp_raw x
  | None ->
      fprintf fmt "%a%a" pp_loc_id loc pp_raw x

let next_pos =
  let counter = ref 0 in
  fun () ->
    incr counter;
    Loc.user_position "" !counter 0 !counter 0

let todo fmt str =
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/transform/args_wrapper.ml

### Lines 434–445

```text
  | Loc.Located (loc, e) -> raise (Arg_parse_type_error (loc, s, e))

let build_error s e =
  let loc = Loc.user_position "" 1 0 1 (String.length s - 1) in
  raise (Arg_parse_type_error (loc, s, e))

let parse_int s =
  try int_of_string s
  with Failure _ ->
    build_error s (Parse_error "int expected")

let parse_theory env s =
```

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/parser/sexp_parser.ml

### Lines 12–24

```text
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

## docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz :: why3/src/session/session_itp.ml

### Lines 1838–1850

```text
    theories, List.rev detached
  in
  f.file_theories <- theories @ detached;
  update_file_node (fun _ -> ()) s f

let read_file env ?format fn =
  match Env.read_file Env.base_language env ?format fn with
  | exception Sys_error msg -> (* File not found and other problems opening the file *)
    raise (Loc.Located (Loc.user_position fn 0 0 0 0, Loc.Message msg))
  | theories, format ->
    let ltheories =
      Mstr.fold
        (fun name th acc ->
```

## docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz :: ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/hashtbl.ml

### Lines 20–40

```text

type ('a, 'b) t =
  { mutable size: int;                        (* number of entries *)
    mutable data: ('a, 'b) bucketlist array;  (* the buckets *)
    seed: int;                        (* for randomization *)
    mutable initial_size: int;                (* initial array size *)
  }

and ('a, 'b) bucketlist =
    Empty
  | Cons of { mutable key: 'a;
              mutable data: 'b;
              mutable next: ('a, 'b) bucketlist }

(* The sign of initial_size encodes the fact that a traversal is
   ongoing or not.

   This disables the efficient in place implementation of resizing.
*)

let ongoing_traversal h =
```

### Lines 64–76

```text
   code below the functor definitions. *)

(* Creating a fresh, empty table *)

let rec power_2_above x n =
  if x >= n then x
  else if x * 2 > Sys.max_array_length then x
  else power_2_above (x * 2) n

let create ?(random = !randomized) initial_size =
  let s = power_2_above 16 initial_size in
  let seed = if random then Random.State.bits (Lazy.force prng) else 0 in
  { initial_size = s; size = 0; seed = seed; data = Array.make s Empty }
```

### Lines 115–152

```text
let insert_all_buckets indexfun inplace odata ndata =
  let nsize = Array.length ndata in
  let ndata_tail = Array.make nsize Empty in
  let rec insert_bucket = function
    | Empty -> ()
    | Cons {key; data; next} as cell ->
        let cell =
          if inplace then cell
          else Cons {key; data; next = Empty}
        in
        let nidx = indexfun key in
        begin match ndata_tail.(nidx) with
        | Empty -> ndata.(nidx) <- cell;
        | Cons tail -> tail.next <- cell;
        end;
        ndata_tail.(nidx) <- cell;
        insert_bucket next
  in
  for i = 0 to Array.length odata - 1 do
    insert_bucket odata.(i)
  done;
  if inplace then
    for i = 0 to nsize - 1 do
      match ndata_tail.(i) with
      | Empty -> ()
      | Cons tail -> tail.next <- Empty
    done

let resize indexfun h =
  let odata = h.data in
  let osize = Array.length odata in
  let nsize = osize * 2 in
  if nsize < Sys.max_array_length then begin
    let ndata = Array.make nsize Empty in
    let inplace = not (ongoing_traversal h) in
    h.data <- ndata;          (* so that indexfun sees the new bucket count *)
    insert_all_buckets (indexfun h) inplace odata ndata
  end
```

### Lines 340–405

```text
    val replace_seq : 'a t -> (key * 'a) Seq.t -> unit
    val of_seq : (key * 'a) Seq.t -> 'a t
  end

module MakeSeeded(H: SeededHashedType): (SeededS with type key = H.t) =
  struct
    type key = H.t
    type 'a hashtbl = (key, 'a) t
    type 'a t = 'a hashtbl
    let create = create
    let clear = clear
    let reset = reset
    let copy = copy

    let key_index h key =
      (H.hash h.seed key) land (Array.length h.data - 1)

    let add h key data =
      let i = key_index h key in
      let bucket = Cons{key; data; next=h.data.(i)} in
      h.data.(i) <- bucket;
      h.size <- h.size + 1;
      if h.size > Array.length h.data lsl 1 then resize key_index h

    let rec remove_bucket h i key prec = function
      | Empty ->
          ()
      | (Cons {key=k; next}) as c ->
          if H.equal k key
          then begin
            h.size <- h.size - 1;
            match prec with
            | Empty -> h.data.(i) <- next
            | Cons c -> c.next <- next
          end
          else remove_bucket h i key c next

    let remove h key =
      let i = key_index h key in
      remove_bucket h i key Empty h.data.(i)

    let rec find_rec key = function
      | Empty ->
          raise Not_found
      | Cons{key=k; data; next} ->
          if H.equal key k then data else find_rec key next

    let find h key =
      match h.data.(key_index h key) with
      | Empty -> raise Not_found
      | Cons{key=k1; data=d1; next=next1} ->
          if H.equal key k1 then d1 else
          match next1 with
          | Empty -> raise Not_found
          | Cons{key=k2; data=d2; next=next2} ->
              if H.equal key k2 then d2 else
              match next2 with
              | Empty -> raise Not_found
              | Cons{key=k3; data=d3; next=next3} ->
                  if H.equal key k3 then d3 else find_rec key next3

    let rec find_rec_opt key = function
      | Empty ->
          None
      | Cons{key=k; data; next} ->
          if H.equal key k then Some data else find_rec_opt key next
```

### Lines 477–488

```text
module Make(H: HashedType): (S with type key = H.t) =
  struct
    include MakeSeeded(struct
        type t = H.t
        let equal = H.equal
        let hash (_seed: int) x = H.hash x
      end)
    let create sz = create ~random:false sz
    let of_seq i =
      let tbl = create 16 in
      replace_seq tbl i;
      tbl
```
