package body Silver_Image_Model_Templates with SPARK_Mode => On is
   subtype Chunk is String (1 .. 128);
   type Chunks is array (Positive range <>) of Chunk;
   Integer_Template_Data : constant Chunks :=
     (1 => "[""W_THEORY_DECLARATION"",0,4,[[""W_TYPE_DECL"",0,1,null,[""W_NAME"",0,1,""integer"","""",null,false],[],[""W_RANGE_TYPE_DEFINITION"",0,1,""-",
      2 => "2147483648"",""2147483647""]],[""W_FUNCTION_DECL"",0,2,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""first"","""",null,false],[""W_TYPE"",0,1,0,[""W_N",
      3 => "AME"",0,1,""int"","""",null,false],false,false],[]],null,[""W_EFFECTS"",0,1,null,null,null],[""W_LITERAL"",0,3,0,null],[""W_LITERAL"",0,3,0",
      4 => ",null],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[""W_INTEGER_CONSTANT"",0,1,""-2147483648""],[],null],[""W_FUN",
      5 => "CTION_DECL"",0,2,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""last"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false",
      6 => ",false],[]],null,[""W_EFFECTS"",0,1,null,null,null],[""W_LITERAL"",0,3,0,null],[""W_LITERAL"",0,3,0,null],[""W_TYPE"",0,1,0,[""W_NAME"",0,",
      7 => "1,""int"","""",null,false],false,false],[""W_INTEGER_CONSTANT"",0,1,""2147483647""],[],null],[""W_FUNCTION_DECL"",0,3,[""W_IDENTIFIER"",0,1,",
      8 => "[""W_NAME"",0,1,""in_range"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""bool"","""",null,false],false,false],[]],[[""W_BINDER"",0,3,[""",
      9 => "W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]],[""W_TYPE""",
      10 => ",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false]]],[""W_EFFECTS"",0,1,null,null,null],[""W_LITERAL"",0,3,0,null],[""W_LITERAL"",",
      11 => "0,3,0,null],null,[""W_CONNECTION"",0,3,[""W_LABEL"",0,3,[""GP_Pretty_Ada:-1""],[""W_CALL"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""<="",""""",
      12 => ",[""W_MODULE"",0,1,""int"",""Int""],true],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""bool"","""",null,false],false,false],[]],[[""W_IDENTIFIER"",0,1,[""",
      13 => "W_NAME"",0,1,""first"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]],[""W_IDENTIFIER"",0,1,[""W_N",
      14 => "AME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""",
      15 => "bool"","""",null,false],false,false]],null],5,[""W_LABEL"",0,3,[""GP_Pretty_Ada:-2""],[""W_CALL"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""",
      16 => "<="","""",[""W_MODULE"",0,1,""int"",""Int""],true],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""bool"","""",null,false],false,false],[]],[[""W_IDENTIFIER"",",
      17 => "0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]],[""W_IDENTIFIER"",0,1,[""W",
      18 => "_NAME"",0,1,""last"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]]],[""W_TYPE"",0,1,0,[""W_NAME"",",
      19 => "0,1,""bool"","""",null,false],false,false]],null],null],[""GP_Inline""],null],[""W_CLONE_DECLARATION"",0,1,[""W_MODULE"",0,1,""ada__model"",",
      20 => """Static_Discrete""],"""",1,[[""W_CLONE_SUBSTITUTION"",0,1,0,[""W_NAME"",0,1,""t"","""",null,false],[""W_NAME"",0,1,""integer"","""",null,false]],",
      21 => "[""W_CLONE_SUBSTITUTION"",0,1,1,[""W_NAME"",0,1,""first"","""",null,false],[""W_NAME"",0,1,""first"","""",null,false]],[""W_CLONE_SUBSTITUTION""",
      22 => ",0,1,1,[""W_NAME"",0,1,""last"","""",null,false],[""W_NAME"",0,1,""last"","""",null,false]],[""W_CLONE_SUBSTITUTION"",0,1,2,[""W_NAME"",0,1,""in_",
      23 => "range"","""",null,false],[""W_NAME"",0,1,""in_range"","""",null,false]]],1],[""W_TYPE_DECL"",0,1,null,[""W_NAME"",0,1,""integer__ref"","""",null,",
      24 => "false],[],[""W_RECORD_DEFINITION"",0,1,[[""W_RECORD_BINDER"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""integer__content"","""",null,false]",
      25 => ",[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integer"","""",null,false],false,false],[]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integer"","""",null,false],",
      26 => "false,false],[],true]]]],[""W_FUNCTION_DECL"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""integer__ref_integer__content__projection"",""""",
      27 => ",null,false],null,[]],[[""W_BINDER"",0,4,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""a"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integ",
      28 => "er__ref"","""",null,false],false,false],[]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integer__ref"","""",null,false],false,false]]],null,null,nu",
      29 => "ll,[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integer"","""",null,false],false,false],[""W_RECORD_ACCESS"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,",
      30 => """a"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integer__ref"","""",null,false],false,false],[]],[""W_IDENTIFIER"",0,1,[""W_NAME"",0,",
      31 => "1,""integer__content"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integer"","""",null,false],false,false],[]],null],[],null],[""W_M",
      32 => "ETA_DECLARATION"",0,1,""model_projection"",""function integer__ref_integer__content__projection""],[""W_META_DECLARATION"",0,1,""inline:",
      33 => "no"",""function integer__ref_integer__content__projection""],[""W_FUNCTION_DECL"",0,4,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""integer__hav",
      34 => "oc"","""",null,false],null,[]],[[""W_BINDER"",0,4,[""W_IDENTIFIER"",0,4,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,",
      35 => """integer__ref"","""",null,false],false,false],[]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integer__ref"","""",null,false],false,false]]],[""W_EF",
      36 => "FECTS"",0,1,null,[[""W_IDENTIFIER"",0,4,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""integer__ref"","""",null,false",
      37 => "],false,false],[]]],null],null,null,[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""unit"","""",null,false],false,false],null,[],null]],""Standard__i",
      38 => "nteger"",1,[[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],1,0],[""W_INCLUDE_DECLARATION"",0,1,[""W_MODU",
      39 => "LE"",0,1,""int"",""Int""],1,0],[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,""int"",""Int""],1,0]],""Module for axiomatizing type \""intege",
      40 => "r\"", created in Gnat2Why.Types.Translate_Type""]                                                                                 ");
   String_Template_Data : constant Chunks :=
     (1 => "[""W_THEORY_DECLARATION"",0,4,[[""W_TYPE_DECL"",0,1,null,[""W_NAME"",0,1,""component_type"","""",null,false],[],[""W_TRANSPARENT_TYPE_DEFIN",
      2 => "ITION"",0,4,[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""character"","""",[""W_MODULE"",0,1,"""",""Standard__character""],false],false,false]]],[""W_FUNC",
      3 => "TION_DECL"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""index_1_id"","""",null,false],null,[]],[[""W_BINDER"",0,1,[""W_IDENTIFIER"",0,1,[""W_N",
      4 => "AME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""i",
      5 => "nt"","""",null,false],false,false]]],[""W_EFFECTS"",0,1,null,null,null],[""W_LITERAL"",0,3,0,null],[""W_LITERAL"",0,3,0,null],[""W_TYPE"",0",
      6 => ",1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,0,[""W_NA",
      7 => "ME"",0,1,""int"","""",null,false],false,false],[]],[],null],[""W_CLONE_DECLARATION"",0,1,[""W_MODULE"",0,1,""ada__model"",""Unconstr_Array""]",
      8 => ","""",1,[[""W_CLONE_SUBSTITUTION"",0,1,0,[""W_NAME"",0,1,""map"","""",null,false],[""W_NAME"",0,1,""map"","""",[""W_MODULE"",0,1,"""",""Array__Int__S",
      9 => "tandard__character""],false]],[""W_CLONE_SUBSTITUTION"",0,1,2,[""W_NAME"",0,1,""has_bounds"","""",null,false],[""W_NAME"",0,1,""has_bounds"",",
      10 => """"",[""W_MODULE"",0,1,"""",""Array__Int__Standard__character""],false]],[""W_CLONE_SUBSTITUTION"",0,1,2,[""W_NAME"",0,1,""eq_ext"","""",null,fa",
      11 => "lse],[""W_NAME"",0,1,""eq_ext"","""",[""W_MODULE"",0,1,"""",""Array__Int__Standard__character""],false]],[""W_CLONE_SUBSTITUTION"",0,1,1,[""W_N",
      12 => "AME"",0,1,""array_bool_eq"","""",null,false],[""W_NAME"",0,1,""bool_eq"","""",[""W_MODULE"",0,1,"""",""Array__Int__Standard__character""],false]]",
      13 => ",[""W_CLONE_SUBSTITUTION"",0,1,0,[""W_NAME"",0,1,""index_base_type"","""",null,false],[""W_NAME"",0,1,""integer"","""",[""W_MODULE"",0,1,"""",""Sta",
      14 => "ndard__integer""],false]],[""W_CLONE_SUBSTITUTION"",0,1,0,[""W_NAME"",0,1,""index_rep_type"","""",null,false],[""W_NAME"",0,1,""int"","""",null",
      15 => ",false]],[""W_CLONE_SUBSTITUTION"",0,1,1,[""W_NAME"",0,1,""to_rep"","""",null,false],[""W_NAME"",0,1,""to_rep"","""",[""W_MODULE"",0,1,"""",""Stand",
      16 => "ard__integer___rep""],false]],[""W_CLONE_SUBSTITUTION"",0,1,1,[""W_NAME"",0,1,""rep_to_int"","""",null,false],[""W_NAME"",0,1,""index_1_id"",",
      17 => """"",null,false]],[""W_CLONE_SUBSTITUTION"",0,1,2,[""W_NAME"",0,1,""in_range_base"","""",null,false],[""W_NAME"",0,1,""in_range"","""",[""W_MODUL",
      18 => "E"",0,1,"""",""Standard__integer""],false]],[""W_CLONE_SUBSTITUTION"",0,1,2,[""W_NAME"",0,1,""index_dynamic_property"","""",null,false],[""W_N",
      19 => "AME"",0,1,""dynamic_property"","""",[""W_MODULE"",0,1,"""",""Standard__positive""],false]],[""W_CLONE_SUBSTITUTION"",0,1,2,[""W_NAME"",0,1,""ind",
      20 => "ex_rep_le"","""",null,false],[""W_NAME"",0,1,""<="","""",[""W_MODULE"",0,1,""int"",""Int""],true]]],1],[""W_TYPE_DECL"",0,1,null,[""W_NAME"",0,1,""s",
      21 => "tring__"","""",null,false],[],[""W_TRANSPARENT_TYPE_DEFINITION"",0,4,[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__t"","""",null,false],false,false]]",
      22 => "],[""W_META_DECLARATION"",0,1,""model_projection"",""function to_array""],[""W_META_DECLARATION"",0,1,""inline:no"",""function to_array""],[",
      23 => """W_META_DECLARATION"",0,1,""model_projection"",""function first""],[""W_META_DECLARATION"",0,1,""inline:no"",""function first""],[""W_META_D",
      24 => "ECLARATION"",0,1,""model_projection"",""function last""],[""W_META_DECLARATION"",0,1,""inline:no"",""function last""],[""W_TYPE_DECL"",0,1,nu",
      25 => "ll,[""W_NAME"",0,1,""string____ref"","""",null,false],[],[""W_RECORD_DEFINITION"",0,1,[[""W_RECORD_BINDER"",0,1,[""W_IDENTIFIER"",0,1,[""W_NA",
      26 => "ME"",0,1,""string____content"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"","""",null,false],false,false],[]],[""W_TYPE"",0,",
      27 => "1,2,[""W_NAME"",0,1,""string__"","""",null,false],false,false],[],true]]]],[""W_FUNCTION_DECL"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s",
      28 => "tring____ref_string____content__projection"","""",null,false],null,[]],[[""W_BINDER"",0,4,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""a"","""",nu",
      29 => "ll,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string____ref"","""",null,false],false,false],[]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string___",
      30 => "_ref"","""",null,false],false,false]]],null,null,null,[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"","""",null,false],false,false],[""W_RECO",
      31 => "RD_ACCESS"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""a"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string____ref"","""",null,false]",
      32 => ",false,false],[]],[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""string____content"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"",",
      33 => """"",null,false],false,false],[]],null],[],null],[""W_META_DECLARATION"",0,1,""model_projection"",""function string____ref_string____co",
      34 => "ntent__projection""],[""W_META_DECLARATION"",0,1,""inline:no"",""function string____ref_string____content__projection""],[""W_FUNCTION_D",
      35 => "ECL"",0,4,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""string____havoc"","""",null,false],null,[]],[[""W_BINDER"",0,4,[""W_IDENTIFIER"",0,4,[""W_NA",
      36 => "ME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string____ref"","""",null,false],false,false],[]],[""W_TYPE"",0,1,2,[""W_NAM",
      37 => "E"",0,1,""string____ref"","""",null,false],false,false]]],[""W_EFFECTS"",0,1,null,[[""W_IDENTIFIER"",0,4,[""W_NAME"",0,1,""x"","""",null,false]",
      38 => ",[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string____ref"","""",null,false],false,false],[]]],null],null,null,[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""u",
      39 => "nit"","""",null,false],false,false],null,[],null]],""Standard__string"",1,[[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,""_gnatprove_s",
      40 => "tandard"",""Main""],1,0],[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,""int"",""Int""],1,0],[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,",
      41 => "1,""int"",""Int""],1,0],[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,"""",""Standard__integer""],1,2],[""W_INCLUDE_DECLARATION"",0,1,[""W_M",
      42 => "ODULE"",0,1,"""",""Standard__positive""],1,2],[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,"""",""Standard__character""],1,2],[""W_INCLUDE",
      43 => "_DECLARATION"",0,1,[""W_MODULE"",0,1,"""",""Array__Int__Standard__character""],1,2],[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,"""",""St",
      44 => "andard__integer___rep""],1,2]],""Module for axiomatizing type \""string\"", created in Gnat2Why.Types.Translate_Type""]              ");
   Image_Template_Data : constant Chunks :=
     (1 => "[""W_THEORY_DECLARATION"",0,4,[[""W_FUNCTION_DECL"",0,2,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""to_string"","""",null,false],null,[]],[[""W_B",
      2 => "INDER"",0,2,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gna",
      3 => "tprove_standard"",""Main""],false],false,false],[]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard",
      4 => """,""Main""],false],false,false]],[""W_BINDER"",0,2,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,",
      5 => "1,""int"","""",null,false],false,false],[]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false]]],[""W_EFFECTS"",0,1,null,",
      6 => "null,null],[""W_LITERAL"",0,3,0,null],[""W_LITERAL"",0,3,0,null],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"","""",[""W_MODULE"",0,1,"""",""Sta",
      7 => "ndard__string""],false],false,false],null,[],null],[""W_FUNCTION_DECL"",0,2,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""from_string"","""",null",
      8 => ",false],null,[]],[[""W_BINDER"",0,2,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"",",
      9 => """"",[""W_MODULE"",0,1,"""",""Standard__string""],false],false,false],[]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"","""",[""W_MODULE"",0,1,""""",
      10 => ",""Standard__string""],false],false,false]]],[""W_EFFECTS"",0,1,null,null,null],[""W_LITERAL"",0,3,0,null],[""W_LITERAL"",0,3,0,null],[""",
      11 => "W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false],null,[],null],[""W_AXI",
      12 => "OM"",0,1,""to_string__first"",[""W_UNIVERSAL_QUANTIF"",0,3,[[""W_BINDER"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_",
      13 => "TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false],[]],[""W_TYPE"",0,1,2,[""W",
      14 => "_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false]],[""W_BINDER"",0,3,[""W_IDENTIFIER"",0,1,[",
      15 => """W_NAME"",0,1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]],[""W_TYPE"",0,1,0,[""W_NAME"",0,",
      16 => "1,""int"","""",null,false],false,false]]],[],[""W_TRIGGERS"",0,1,[[""W_TRIGGER"",0,1,[[""W_CALL"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""t",
      17 => "o_string"","""",null,false],null,[]],[[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"",",
      18 => """"",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false],[]],[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"","""",null,false],[""",
      19 => "W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"","""",[""W_MODULE"",0,1,""",
      20 => """,""Standard__string""],false],false,false]]]]]],[""W_CALL"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""="","""",null,true],[""W_TYPE"",0,1,0",
      21 => ",[""W_NAME"",0,1,""bool"","""",null,false],false,false],[]],[[""W_CALL"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""first"","""",[""W_MODULE"",0,",
      22 => "1,"""",""Standard__string""],false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]],[[""W_CALL"",0,1,[""W_IDENTIFIE",
      23 => "R"",0,1,[""W_NAME"",0,1,""to_string"","""",null,false],null,[]],[[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[",
      24 => """W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false],[]],[""W_IDENTIFIER"",0,1,[""W_NAME"",0,",
      25 => "1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string_",
      26 => "_"","""",[""W_MODULE"",0,1,"""",""Standard__string""],false],false,false]]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,fals",
      27 => "e]],[""W_INTEGER_CONSTANT"",0,1,""1""]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""bool"","""",null,false],false,false]]],[""W_AXIOM_DEP"",0,1,[""W_ID",
      28 => "ENTIFIER"",0,1,[""W_NAME"",0,1,""to_string"","""",null,false],null,[]],0]],[""W_AXIOM"",0,1,""to_string__length"",[""W_UNIVERSAL_QUANTIF"",0,",
      29 => "3,[[""W_BINDER"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0",
      30 => ",1,""_gnatprove_standard"",""Main""],false],false,false],[]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_",
      31 => "standard"",""Main""],false],false,false]],[""W_BINDER"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_",
      32 => "NAME"",0,1,""int"","""",null,false],false,false],[]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false]]],[],[""W_TRIGGER",
      33 => "S"",0,1,[[""W_TRIGGER"",0,1,[[""W_CALL"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""to_string"","""",null,false],null,[]],[[""W_IDENTIFIER"",0",
      34 => ",1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],fal",
      35 => "se],false,false],[]],[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],fal",
      36 => "se,false],[]]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"","""",[""W_MODULE"",0,1,"""",""Standard__string""],false],false,false]]]]]],[""W_C",
      37 => "ONNECTION"",0,3,[""W_CALL"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,"">="","""",[""W_MODULE"",0,1,""int"",""Int""],true],[""W_TYPE"",0,1,0,[""W_NA",
      38 => "ME"",0,1,""bool"","""",null,false],false,false],[]],[[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0",
      39 => ",1,""int"","""",null,false],false,false],[]],[""W_INTEGER_CONSTANT"",0,1,""0""]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""bool"","""",null,false],fal",
      40 => "se,false]],2,[""W_CALL"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""<="","""",[""W_MODULE"",0,1,""int"",""Int""],true],[""W_TYPE"",0,1,0,[""W_NAME",
      41 => """,0,1,""bool"","""",null,false],false,false],[]],[[""W_CALL"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""length"","""",[""W_MODULE"",0,1,"""",""St",
      42 => "andard__string""],false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]],[[""W_CALL"",0,1,[""W_IDENTIFIER"",0,1,[",
      43 => """W_NAME"",0,1,""to_string"","""",null,false],null,[]],[[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME""",
      44 => ",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false],[]],[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"",""""",
      45 => ",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"","""",[""",
      46 => "W_MODULE"",0,1,"""",""Standard__string""],false],false,false]]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false]],[""W_",
      47 => "IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]]],[""W_TYPE"",",
      48 => "0,1,0,[""W_NAME"",0,1,""bool"","""",null,false],false,false]],null]],[""W_AXIOM_DEP"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""to_string"",",
      49 => """"",null,false],null,[]],0]],[""W_AXIOM"",0,1,""to_string__wf"",[""W_UNIVERSAL_QUANTIF"",0,3,[[""W_BINDER"",0,3,[""W_IDENTIFIER"",0,1,[""W_N",
      50 => "AME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],fals",
      51 => "e,false],[]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false]],[""W_B",
      52 => "INDER"",0,3,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],",
      53 => "[]],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false]]],[],[""W_TRIGGERS"",0,1,[[""W_TRIGGER"",0,1,[[""W_CALL"",0,1,[""W_",
      54 => "IDENTIFIER"",0,1,[""W_NAME"",0,1,""to_string"","""",null,false],null,[]],[[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE",
      55 => """,0,1,2,[""W_NAME"",0,1,""__image"","""",[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false],[]],[""W_IDENTIFIER"",0,1,[""W",
      56 => "_NAME"",0,1,""s"","""",null,false],[""W_TYPE"",0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1",
      57 => ",""string__"","""",[""W_MODULE"",0,1,"""",""Standard__string""],false],false,false]]]]]],[""W_CALL"",0,3,[""W_IDENTIFIER"",0,3,[""W_NAME"",0,1,""",
      58 => "well_formed"","""",[""W_MODULE"",0,1,"""",""Standard__string""],false],null,[]],[[""W_CALL"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""to_stri",
      59 => "ng"","""",null,false],null,[]],[[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""x"","""",null,false],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""__image"","""",[""W",
      60 => "_MODULE"",0,1,""_gnatprove_standard"",""Main""],false],false,false],[]],[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""s"","""",null,false],[""W_TYPE",
      61 => """,0,1,0,[""W_NAME"",0,1,""int"","""",null,false],false,false],[]]],[""W_TYPE"",0,1,2,[""W_NAME"",0,1,""string__"","""",[""W_MODULE"",0,1,"""",""Sta",
      62 => "ndard__string""],false],false,false]]],null]],[""W_AXIOM_DEP"",0,1,[""W_IDENTIFIER"",0,1,[""W_NAME"",0,1,""to_string"","""",null,false],nul",
      63 => "l,[]],0]]],""Standard_String__Img"",1,[[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,""int"",""Int""],1,0],[""W_INCLUDE_DECLARATION"",0,1",
      64 => ",[""W_MODULE"",0,1,"""",""Standard__string""],1,2],[""W_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,""_gnatprove_standard"",""Main""],1,0],[""W",
      65 => "_INCLUDE_DECLARATION"",0,1,[""W_MODULE"",0,1,""int"",""Int""],1,0]],""Module defining to_string/of_string functions, created in Gnat2Why",
      66 => ".Types.Translate_Type""]                                                                                                         ");
   Declarations_Fragment_Data : constant Chunks :=
     (1 => ",[""W_CLONE_DECLARATION"",1073741844,1,[""W_MODULE"",1073741843,1,""silver_image"",""Integer_Image_Length""],""Silver_Image"",2,[[""W_CLONE",
      2 => "_SUBSTITUTION"",1073741830,1,0,[""W_NAME"",1073741828,1,""image"","""",null,false],[""W_NAME"",1073741829,1,""__image"","""",[""W_MODULE"",1073",
      3 => "741824,1,""_gnatprove_standard"",""Main""],false]],[""W_CLONE_SUBSTITUTION"",1073741833,1,0,[""W_NAME"",1073741831,1,""text"","""",null,fals",
      4 => "e],[""W_NAME"",1073741832,1,""string__"","""",[""W_MODULE"",1073741825,1,"""",""Standard__string""],false]],[""W_CLONE_SUBSTITUTION"",10737418",
      5 => "36,1,1,[""W_NAME"",1073741834,1,""scalar_image"","""",null,false],[""W_NAME"",1073741835,1,""attr__ATTRIBUTE_IMAGE"","""",[""W_MODULE"",107374",
      6 => "1826,1,"""",""Standard__integer""],false]],[""W_CLONE_SUBSTITUTION"",1073741839,1,1,[""W_NAME"",1073741837,1,""string_image"","""",null,fals",
      7 => "e],[""W_NAME"",1073741838,1,""to_string"","""",null,false]],[""W_CLONE_SUBSTITUTION"",1073741842,1,1,[""W_NAME"",1073741840,1,""length"","""",",
      8 => "null,false],[""W_NAME"",1073741841,1,""length"","""",[""W_MODULE"",1073741827,1,"""",""Standard__string""],false]]],1]                      ");
   Includes_Fragment_Data : constant Chunks :=
     (1 => ",[""W_INCLUDE_DECLARATION"",1073741846,1,[""W_MODULE"",1073741845,1,"""",""Standard__integer""],1,2]                                    ");

   function Length (Item : Kind) return Positive is
     (case Item is
        when Integer_Template => 5039,
        when String_Template => 5618,
        when Image_Template => 8343,
        when Declarations_Fragment => 1002,
        when Includes_Fragment => 92);

   function Byte_At (Item : Kind; Position : Positive) return Character is
   begin
      case Item is
         when Integer_Template =>
            return Integer_Template_Data ((Position - 1) / 128 + 1)
              ((Position - 1) mod 128 + 1);
         when String_Template =>
            return String_Template_Data ((Position - 1) / 128 + 1)
              ((Position - 1) mod 128 + 1);
         when Image_Template =>
            return Image_Template_Data ((Position - 1) / 128 + 1)
              ((Position - 1) mod 128 + 1);
         when Declarations_Fragment =>
            return Declarations_Fragment_Data ((Position - 1) / 128 + 1)
              ((Position - 1) mod 128 + 1);
         when Includes_Fragment =>
            return Includes_Fragment_Data ((Position - 1) / 128 + 1)
              ((Position - 1) mod 128 + 1);
      end case;
   end Byte_At;
end Silver_Image_Model_Templates;
