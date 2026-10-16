# Image producer applicability and consumer source review

This 2026-10-16 review supports [assurance #15](https://github.com/berkeleynerd/silver/issues/15)
and the [Image schema record](for-loops-image-schema.md). It covers the complete
Integer/String/Image templates and the broader normalization grammar for every
model routed through the adapter, including Main and fixed-library models.
Source review and finite reconstruction establish the facts stated below;
complete Silver scanner acceptance and refinement require the separately checked
Lean endpoints. Samples are not the universal argument.

The pinned sources are [spark2014 42554fc241fcd1fdf08d3a2feccb3f86912acbc0](https://github.com/AdaCore/spark2014/tree/42554fc241fcd1fdf08d3a2feccb3f86912acbc0),
[Why3 9390baf120ef260547dfa14f08e11c890b203d9c](https://github.com/AdaCore/why3/tree/9390baf120ef260547dfa14f08e11c890b203d9c)
and [GCC 6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea](https://github.com/gcc-mirror/gcc/tree/6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea).
Paths and line numbers below refer to these sources. This is not an attestation
that installed tools were built from these exact sources.

The [review manifest](evidence/for-loops-image/review-manifest.json) records input
and evidence hashes; the [GCC source manifest](evidence/for-loops-image/gcc-inputs.json)
records the exact fetched filename-handling sources. Independent
[Integer](evidence/for-loops-image/reconstruct_integer_template.py) and
[String/Image](evidence/for-loops-image/reconstruct_string_image_templates.py)
constructor reconstructions build expected trees before reading the native Ada
templates. Run either script from the repository root. Both passed exact tree
and compact-byte equality, with only occurrence IDs normalized. The
[field inventory](evidence/for-loops-image/template-field-audit.json) checks all
558 selected nested node occurrences against the producer field arities. The
[String/Image result](evidence/for-loops-image/string-image-template-parity.json)
retains the finite counts and hashes. These are review witnesses, not a verified
execution of the external producer.

| Template | Declarations / includes | Canonical bytes | SHA256 |
| --- | --- | --- | --- |
| Integer | 10 / 3 | 5039 | `e927fd5a3fef5ef2f99c318daf78c54caa36ef423c69902aed72da4c683f5652` |
| String | 15 / 8 | 5618 | `f98344dca9b6fc097bbcde99d0cf95947237bf0231db7523b8410494eda6545b` |
| Image | 5 / 4 | 8343 | `e3fc2d6f39f8f7f69967e2ccc46d86882cf2f2fb339b20dbf6bb7778820fc495` |

## Integer constructor correspondence

### Why the route applies to Main and the fixed-library models

All line references below are relative to the pinned source root; filenames
without a directory are under `src/why/`.

`gnat2why-driver.adb:1002–1011` initializes names/modules/sections, translates
Standard, and only then translates the current compilation unit. The Standard
loop at `1654–1682` stores entity information, translates and completes each
selected predefined entity before current-unit translation. This route is
common to the proof-mode invocations for Main and the fixed runtime units; it
does not depend on whether a Main sample happens to contain Integer or Image.

`gnat2why-types.adb:1584–1591,1626–1695` selects the scalar route, opens the
definition theory, emits scalar declarations, then the ref/projection/metas and
havoc. `Generate_Ref_Type_And_Havoc_Fun` at `1538–1577` applies to ordinary signed
Integer. Emit appends in order (`why-gen-decl.adb:74–88`). Application names,
locations, statement counts and Image operands cannot modify the already built
Standard Integer definition on this route. The external predefined metadata and
fresh translation lifecycle listed below remain required.

Whether a theory is printed is a separate dependency-plan question:
`gnat2why-util.adb:503–539` marks names seen before visiting dependencies, and
therefore appends each selected theory name at most once. If Integer is printed,
the complete reviewed definition is selected. Image explicitly includes String
(`why-gen-arrays.adb:1654–1655`); String's index-base clone substitution refers to
Integer (`2672–2683`), which module collection and definition imports retain
(`why-inter.adb:299–304,702–710`). Thus this comparison is not limited to one
observed probe. These source-reviewed presence and uniqueness facts are the
external `ProducerSchemas` interface; `producer_finishes` and
`FilesSource.native_producer_finishes` derive successful native scanning from
that interface and the independent document syntax/resource premises.

### Complete declaration and include correspondence

The theory is domain 4, kind 1, name `Standard__integer`, with the fixed comment
`Module for axiomatizing type "integer", created in Gnat2Why.Types.Translate_Type`.
`Open_Theory` sets its module kind (`why-inter.adb:1268–1282`), while the comment
is formed in `gnat2why-types.adb:1652–1665`. Standard has a nonpositive location,
so the optional ` defined at ...` segment is absent. `E_Module` uses the entity's
full name (`why-atree-modules.adb:135–145`); `New_Module` capitalizes its first
character (`why-gen-names.adb:825–832`). Local names are based on `Short_Name`
(`gnat2why-util.adb:1594–1595`).

| Index | Complete declaration shape | Constructor evidence |
| --- | --- | --- |
| 0 | Term type `integer`, null args, empty labels; range definition with quoted `-2147483648`, `2147483647` | `why-gen-scalars.adb:832–863`; static signed route `gnat2why-util.adb:1250–1258,1609–1615` |
| 1 | Pterm function `first`; term identifier of builtin int type; null binders; empty effects; true pre/post; int result; term integer constant minimum; empty labels, null location | `why-gen-scalars.adb:1117–1134,1238–1259,1546–1555`; wrapper `why-gen-binders.adb:1282–1340` |
| 2 | Same for `last`, maximum; emitted after `first` | `why-gen-scalars.adb:1260–1279` |
| 3 | Predicate `in_range` with term identifier of builtin bool type; one predicate binder `x` with term identifier/int type; empty effects and true pre/post; null return type; labeled `first <= x` AND `x <= last`; empty more-right; declaration label `GP_Inline`; null location | `why-gen-scalars.adb:542–574,702–739`; simplification `why-gen-expr.adb:3485–3503`; range construction `4883–4923`; comparisons `4289–4331` |
| 4 | Term export/module clone `ada__model.Static_Discrete`, empty alias; ordered substitutions type `t→integer`, function `first→first`, function `last→last`, predicate `in_range→in_range` | `why-gen-scalars.adb:410–535,757–824,908–918`; origin initialization `why-atree-modules.adb:602–603` |
| 5 | Term type `integer__ref`, null args, empty labels; term record with one mutable term binder `integer__content`, abstract local `integer` type, empty labels | `why-gen-decl.adb:115–136,234–245`; `why-gen-binders.adb:1127–1145,1374–1385` |
| 6 | Term projection `integer__ref_integer__content__projection`; name has null type; prog binder `a` with term identifier/abstract `integer__ref` type; null effects/pre/post; abstract integer result; term record access `a.integer__content` with null type; empty labels/null location | `why-gen-decl.adb:162–227`; generated record-access domain/defaults below |
| 7 | Term meta `model_projection`, parameter `function integer__ref_integer__content__projection` | `why-gen-decl.adb:94–109` |
| 8 | Term meta `inline:no`, same parameter | Same unconditional ordered meta emission |
| 9 | Prog `integer__havoc`, term identifier with null type; prog binder with **prog** identifier `x` of abstract `integer__ref`; effects reads/raises null, writes singleton same x; pre/post/def null; builtin unit return; labels empty/location null | `why-gen-decl.adb:252–268`; raw function builder defaults |

For the range predicate, both calls use the term identifier `int.Int.(<=)` with
infix true and builtin bool type; calls and enclosing labels are predicate domain,
and call results are bool. The names' namespace is empty. Label strings
`GP_Pretty_Ada:-1` and `GP_Pretty_Ada:-2` are fixed bound markers
(`why-gen-expr.adb:4911,4918`; `src/common/vc_kinds.ads:1274–1275`), not per-unit
allocation counters. The comparison argument order and AND operand order agree.

Includes are exactly, in order:

1. `_gnatprove_standard.Main`, term domain, module kind 1, import kind 0.
2. `int.Int`, same domains/kinds.
3. `int.Int`, same domains/kinds; the duplicate is intentional.

`why-inter.adb:562–568` collects the module set before appending imports;
`683–684` appends Main and Int, then `702–710` appends the collected dependencies.
The collected set here is just Int: constants add Int (`260–266`), the qualified
comparison names add Int (`299–304`), all other referenced names are local,
and clone substitution visits only the image (`199–206`). The clone's origin
is a module node; there is no module-node callback that adds it to the set.
The module set is ordered (`why-types.ads:72–73`), but contains only this one
member for Integer. `Add_With_Clause` forces Int import and appends without
deduplication (`why-inter.adb:361–375`). Main/Int initializations are fixed
(`why-atree-modules.adb:518–523,2765–2769`).

### Defaults, domains, nulls, ordering and serialization

- Enum values follow `why-sinfo.ads:809–844`: term 1, pterm 2, predicate 3,
  prog 4, builtin type 0, abstract type 2, true literal 0, module 1, import 0,
  export 1, substitutions type/function/predicate 0/1/2, AND 5.
- `xgen/xtree_sinfo.adb` declares all fields in serialized order: names/types
  80–98, effects 115–122, record binders/definitions/ranges 145–169,
  connections/labels 264–282, modules/identifiers/calls/literals 296–331,
  record access 430–435, functions 582–599, types 627–635, metas/clones/includes/
  theories 675–735. Record access is within the term/prog class range
  (`why-sinfo.ads:758–769`; `xtree_sinfo.adb:46–56`), so generated constructors
  select term domain (`xkind_tables.adb:179–208`; `xtree_builders.adb:187–203`).
- Effects domain is **term**, because `xtree_sinfo.adb:139` overrides the earlier
  prog setting at line 122. This non-obvious default matches every template
  effects node.
- Optional node fields default to `Why_Empty`; optional lists to empty lists
  (`xgen/xtree_tables.adb:110–140,536–548`). The higher-level scalar function
  wrapper supplies empty Effects and True_Pred pre/post, while projection and
  havoc use raw builders and retain their explicit null fields
  (`why-gen-binders.adb:1282–1340`; `why-gen-decl.adb:210–268`).
- `True_Pred` is the predicate overload of `New_Literal(EW_True)` with omitted
  optional type (`why-gen-terms.ads:38`; generated overload domain assignment
  in `xgen/xtree_builders.adb:187–203`). Therefore each true predicate's type is
  null. All builtin/abstract type nodes have Is_Mutable=false and
  Relaxed_Init=false. Ref **field** mutability is separately true.
- Name helpers default to term domain, empty namespace, absent module,
  infix=false and empty identifier labels (`why-gen-names.adb:714–809`);
  `To_Local` removes only the module and preserves the other identifier fields
  (`1136–1166`). Fixed suffixes are `__content`, `__havoc`, `__ref`.
- `xgen/xtree_why_ast.adb:171–227` emits tag, fresh occurrence ID, domain, then
  kind fields in declaration order; it excludes Ada_Node and Checked.
  `why-atree-to_json.adb-tmpl` emits Uint as quoted decimal (27–30), empty
  symbol/string sets as `[]` (45–58,89–102), No_Location as null (68–81),
  absent nodes/empty node lists as null (118–134), and present lists in order
  (141–156). Every list in the reconstruction retains its order and every
  optional field was compared; no additional field was erased.

### Residual external metadata and lifecycle dependencies

The route establishes exact shape under the following specific premises. They
must be part of the pinned-producer/frontend boundary or separately derived;
“well-typed JSON” and successful template matching do not establish them.

1. The pinned frontend supplies Standard_Integer as the ordinary signed,
   nonmodular, non-null, statically constrained type named `integer` in Standard,
   with compile-time-known bounds -2147483648 and 2147483647, a builtin
   nonpositive source location, and fixed Standard module naming. No user scalar
   type/annotation metadata is substituted for that predefined entity.
   The inspected producer checkout does not include GNAT's `stand.ads` or
   `cstand.adb`; this review therefore does not claim an independent verification
   of their Standard entity table construction.
2. The projection registry is fresh for the ordinary per-compilation producer
   process, and no earlier predefined entity emits the same projection key
   `integer__ref_integer__content`. The registry is package-global and emits
   suffix `__N` on a repeated key (`why-gen-decl.adb:138–208`). Driver order
   excludes application/fixed-unit declarations from preceding Integer; fixed
   initialization constructs identifiers/modules without record projection
   emission. Distinct predefined names/order still depend on the external
   Standard table. Reusing a producer process for repeated translation without
   resetting this map is outside this reviewed invocation route.
3. The configured proof translation uses these pinned constructor/generator
   sources and the normal Standard-before-CUnit path. Standard metadata and
   initialization are shared by Main and all fixed-library invocations. The
   static signed branch has no dynamic, modular, fixed-point, enumeration,
   record or array extra declarations. Ordinary Main source changes cannot
   select those alternate branches for Standard_Integer.

The projection suffix is the only identified non-ID state-dependent field in
this exact Integer tree once the Standard metadata is fixed. The optional
comment location and bounds/name fields are frontend metadata dependencies.
None of these premises assumes matcher success, the desired schema, offsets,
adapter acceptance, or the Image length assertion.

### Resource observations and scope limits

The reconstructed fixed tree has 146 serialized node occurrences, 22 distinct
node kinds, maximum decoded string length 80 bytes, quoted integer bound length
at most 11 bytes, and non-ID numeric fields in 0–5. These are fixed Integer-tree
facts, not bounds for an arbitrary generated model. IDs remain a separate
global producer/consumer bound. Full-model size, string/path/label-set bounds,
universal scanner/Finish success and the adapter's semantic Image theorem are
outside this parity result and remain separate obligations.

## String and Image constructor correspondence

### Universal construction route

`gnat2why-driver.adb:1002–1011` initializes Why and translates Standard before
`Translate_CUnit`; `:1654–1682` traverses Standard in the fixed frontend order.
`gnat2why-types.adb:1650–1695` creates and closes each ordinary type definition;
`:1726–1738` creates the separate String Image theory. The definitions therefore
precede application constants, String expressions, arithmetic, comparisons,
branches and loops, as well as the fixed library source translation. Their
constructors receive Standard entities, not an application source entity.

The external frontend metadata used here is explicit: Standard String is the
one-dimensional unconstrained array of Standard Character indexed by Standard
Positive, whose base index type is Standard signed-32-bit Integer. It is neither
a clone subtype nor a relaxed-initialization wrapper. Standard source locations
are absent, so the theory comments have no variable source-location suffix.
These are properties of the selected frontend configuration, not conclusions of
the JSON parser or a sample probe. The retained spark2014 checkout does not
contain GNAT's `stand.ads`/`cstand.adb`; this review does not claim those compiler
metadata definitions were independently verified here.

`why-gen-decl.adb:136–228` has a process-local projection-name counter. The
selected String reference projection is the first declaration with the unique
`string____ref_string____content` key: Standard is translated first, distinct
earlier Standard types have different keys, and the selected String definition
is built once. Subsequent application or library declarations cannot rename an
already constructed projection. A fresh translator process/registry is part of
the pinned invocation contract; arbitrary reuse of a dirty internal registry is
not included.

### Complete String declaration route

The numbering below is the zero-based declaration index in the reconstructed
tree. `why-gen-arrays.adb:1534–1623` selects the non-clone, non-relaxed,
unconstrained branch; `:2652–2807` handles its single index.

| Indices | Source and exact result |
| --- | --- |
| 0 | `Declare_Ada_Array` emits `component_type` as the transparent alias of qualified `Standard__character.character`. |
| 1 | `Declare_Unconstrained` sees the Integer representation `int`, emits `index_1_id(x:int):int = x`, with empty effects and true pre/postconditions from the binder helper. |
| 2 | The exported `ada__model.Unconstr_Array` clone has the four base substitutions (`map`, `has_bounds`, `eq_ext`, `array_bool_eq`) and seven index substitutions, in source order. The index substitutions select Standard Integer, built-in int, Integer's representation conversion, `index_1_id`, Integer's `in_range`, Positive's `dynamic_property` and `int.Int.<=`. |
| 3 | The abstract array name `string__` aliases local `__t`; `why-gen-decl.adb:283–296` sets the transparent-definition domain explicitly to `EW_Prog`. |
| 4–9 | `Emit_Projection_Metas` (`why-gen-decl.adb:94–109`) emits `model_projection` then `inline:no` for each of `to_array`, `first`, `last`. No extra dimensions execute the subsequent loop. |
| 10 | `Generate_Ref_Type_And_Havoc_Fun` and `Emit_Ref_Type_Definition` (`gnat2why-types.adb:1555–1577`, `why-gen-decl.adb:234–246`) emit `string____ref` with its one mutable `string____content` field. |
| 11–13 | `Emit_Record_Projection_Declaration` emits the local reference projection with one `a` binder, exact record-access definition, then its two metas. This raw builder leaves optional effects/pre/post as null, unlike the higher-level binder helper. |
| 14 | `New_Havoc_Declaration` (`why-gen-decl.adb:252–269`) emits `string____havoc` with program-domain `x`, a singleton write effect and built-in unit result. |

The complete eight-entry includes list is also significant. `Close_Theory`
(`why-inter.adb:562,683–710`) appends `_gnatprove_standard.Main`, then `int.Int`,
then the dependency set collected from the declaration tree. `Why_Node_Sets` is
an ordered set of allocated node IDs (`why-types.ads:72–73`). With the fixed
initialization/Standard traversal, those dependencies occur as `int.Int`,
Standard Integer, Standard Positive, Standard Character, the representative
`Array__Int__Standard__character` module, and Integer's `___rep` module. The two
`int.Int` entries are intentional. `Add_With_Clause` (`why-inter.adb:361–381`)
overrides Int's use kind to import; the five local dependencies retain clone
default. The constructor reconstruction checks that complete ordered list.

### Complete Image declaration route

`why-gen-arrays.adb:1629–1766` has no source-dependent branch for this theory.
`why-atree-modules.adb:872–891` fixes its module and function names, including
the spelling `from_string`; `:2764–2780` fixes the qualified `Main.__image` type.

| Index | Exact result |
| --- | --- |
| 0 | `to_string(x:Main.__image,s:int):Standard__string.string__`, program-term domain, empty effects, true pre/postconditions and absent body. |
| 1 | `from_string(x:Standard__string.string__):Main.__image`, with the same higher-level helper defaults. |
| 2 | `to_string__first`: universally quantifies x and s; one trigger is the exact `to_string(x,s)` call; the conclusion is `Standard__string.first(to_string(x,s)) = 1`. |
| 3 | `to_string__length`: the same quantifiers and trigger, with implication `s >= 0 -> Standard__string.length(to_string(x,s)) <= s`. |
| 4 | `to_string__wf`: the same quantifiers and trigger, with `Standard__string.well_formed(to_string(x,s))`. |

Every axiom carries the function dependency on local `to_string`.
`why-gen-binders.adb:1282–1307,1346–1370,1392–1411` fixes binder domains, empty
quantifier labels, true pre/postconditions, the optional implication and axiom
dependency fields. `Get_Array_Attr` (`why-gen-arrays.adb:2848–2892`) selects the
unconstrained first/length calls. `New_Well_Formed_Pred` (`:3835–3847`) supplies
the predicate call with its deliberately absent result type. `New_Comparison`
(`why-gen-expr.adb:4289–4332`) supplies bool-typed predicate calls.

The four includes are, in order, explicit Int import and Standard String clone
default (`why-gen-arrays.adb:1654–1655`), then Close_Theory's Main and Int imports.
The close uses `Standalone_Theory`, so it does not append a computed dependency
set. The full ordered list is reconstructed and compared.

### Shared fields and serialization

All common domains, enum values, flags, empty namespaces, absent modules,
optional nulls, empty label sets and node-list ordering are included in the
comparison. They follow `xtree_sinfo.adb` and the builder generation in
`xtree_builders.adb:180–213,309–325` plus `xtree_tables.adb:110–142`.
`why-sinfo.ads:809–848` gives enum order; `xtree_why_ast.adb:115–141` serializes
enum representations. Its `:171–228` writer serializes the kind, occurrence
counter, domain and declared fields in order, excluding Ada-node and checked
metadata. `why-atree-to_json.adb-tmpl:120–165` expands node references and
serializes absent optional lists as null. Thus allocation-dependent occurrence
IDs are the only fields removed by the normalization here.


## Complete normalization grammar

### Exhaustive array-head cases

`src/why/xgen/xtree_sinfo.adb` declares all primitive fields. Its non-node types are Symbol, Boolean, enum types, Uint, Ureal, Source_Ptr, Symbol_Set, and String_Sets.Set. Node references/lists share the generated serializer aliases (`xtree_why_ast.adb:237–296`). The only non-node arrays that can begin with a string are Ureal, Source_Ptr, Symbol_Set and String_Sets.Set.

- A node is serialized as `[kind, counter, domain, ...]`; kind is the `Why_Node_Kind'Image` tag, and the next value is `Integer'Image (Why_Node_Counter)` with `Why_Node_Counter : Natural` (`xtree_why_ast.adb:169–191`). The named faithful producer-format contract supplies the next bounded nonnegative decimal value whenever its head is a node tag; the compiled increment is not a checked capacity guard, as explained below. The pinned 32-bit Natural maximum is 2147483647, as already corrected in the schema record.
- A node list is empty or starts with an expanded node array, never a bare source string (`why-atree-to_json.adb-tmpl:120–164`). Optional absent nodes/lists are null.
- Ureal starts with a quoted decimal numerator (`why-atree-to_json.adb-tmpl:26–43`); that cannot start with `W_`.
- Source_Ptr starts with a controlled simple filename; see the filename argument below (`why-atree-to_json.adb-tmpl:68–82`).
- Symbol_Set and String_Sets.Set serialize label elements (`why-atree-to_json.adb-tmpl:45–58,90–103`). Every label source in the reviewed producer either supplies one of the fixed prefixes/constants below or copies an existing label set. Thus each member, not merely the set's current first member, avoids `W_`; set ordering is irrelevant.

Other primitive Symbol strings can contain arbitrary identifier/comment text, including `W_`, but appear inside an already started tagged node after its tag/counter/common fields. They are not array-head strings. The scanner records `String_Is_Tag` only from `Previous_Array_Start` (`src/silver_image_model.adb:244`), and ordinary commas clear that flag (`:285`).

### Source text, labels and arbitrary string values

`Get_Model_Trace_Label` builds `model_trace:` plus entity/name data and separately adds `name:` plus `Raw_Source_Name` (`gnat2why-util.adb:932–959`). `Get_Counterexample_Labels` only selects these sets and adds fixed `model_projected` (`:376–443`). Consequently an admitted identifier such as `W_tag` becomes `name:W_tag` where label text is needed, never a bare `W_tag` list element. This applies equally to fields, parameters and contract expressions in the fixed library/vendor units.

Other origins are:

| Producer origin | Fixed start |
| --- | --- |
| `why-gen-expr.adb:4272–4283` | `GP_Check:` followed by numeric/check/location data |
| `why-gen-expr.adb:4714–4722` | `GP_Shape:` before pretty source shape |
| `why-gen-expr.adb:4731–4736` | `branch_id=` before a node number |
| `why-gen-expr.adb:4876–4877,4910–4918` | `GP_Pretty_Ada:` before node/bound number |
| `why-gen-expr.adb:5330–5371` | Prior safe check/shape labels plus `model_vc_post` or `vc:annotation` |
| `gnat2why-types.adb:608`, `why-gen-scalars.adb:738`, `gnat2why-subprograms.adb:3352–3358` | `GP_Inline` |
| `gnat2why-expr.adb:7558,13279–13280` | `GP_Inlined` |
| `gnat2why-subprograms.adb:7890–7891` | `RAC:assume` |
| `why-gen-names.adb:849–867` | `mlw:proxy_symbol`, `introduced` |
| `gnat2why-util.adb:1381–1417,1477–1505` | `model_trace:` for Old/Loop_Entry identifiers |

Prefix/constants are defined in `src/common/vc_kinds.ads:1253–1271`; the corresponding module symbols are initialized in `why-atree-modules.adb:2756–2758`. The identifier constructor defaults attributes to an empty set and passes supplied attributes unchanged (`why-gen-names.adb:786–810`). Its nonempty attribute producers are the fixed temporary/Old/Loop_Entry cases above; localization copies labels. Binders/record projection/functions copy existing sets (`why-gen-binders.adb:648,1139,1281–1336`; `why-gen-decl.adb:121–135,166–227`). Other inspected call sites pass empty sets or these helper results. There is no generic user string-list-to-label conversion in this field inventory.

In particular the application string literal `"W_tag"` does not become JSON `["W_tag"]`: `Transform_String_Literal` represents its characters using numeric `New_Integer_Constant (UI_From_CC (Get_String_Char ...))` expressions (`gnat2why-expr.adb:30221–30360`). Generated theory comments are scalar Symbol fields. The same representation applies to fixed library literals; arbitrary content within a source-shape label follows `GP_Shape:`.

### Filenames and directory-prefix exclusion

The serializer takes `SPARK_Util.File_Name (X)` (`why-atree-to_json.adb-tmpl:69`). That is `Get_Name_String (Sinput.File_Name (Get_Source_File_Index (Loc)))` (`spark_util.ads:1190–1191`).

GCC's Sinput contract explicitly says `File_Name` is a **simple name with no directory information** (`sinput.ads:162–163`), distinguishing `Full_File_Name` at :165–167. The getter returns precisely the File_Name field (`sinput.adb:1117–1120`); the loader stores simple `N` there and `Osint.Full_Source_Name` separately (`sinput-l.adb:510–515`). An installation/build directory beginning `W_`, or an arbitrary path prefix, therefore cannot become the first bytes of a Source_Ptr string.

The original user filename is replaced with the canonical copied `main.adb`. Fixed owned sources are lowercase `silver_*` names. Vendor references are not just those six files: the installed `a-nbnbin.ads:16,18–19` depends on Ada.Strings.Text_Buffers, Ada.Finalization and System; `a-sttebu.ads:16` adds UTF_Encoding, and `a-finali.ads:37` adds System.Finalization_Root. The installed Linux GNAT16 runtime inventory has 1574 Ada source files, and GNATprove's share tree has 921; every source basename is lowercase, and none starts with `W_`. The retained complete inventory, whose SHA256 is recorded in the review manifest, gives paths and hashes for both directories. This covers the transitive vendor-source filename concern without assuming only Main is serialized.

Moreover `pragma Source_Reference` does not change Sinput.File_Name: its registration changes Reference_Name, Full_Ref_Name, Debug_Source_Name and Full_Debug_Name (`sinput.adb:802–850`). Source_Reference is excluded for Silver application authors anyway. This stronger source fact prevents confusing error-display references with the filename actually used by the JSON serializer.

Every primitive string-array member therefore avoids a `W_` start; each genuine
node tag is followed immediately by its counter under the named faithful
producer-format contract. The pending tag-ID state is discharged before that
node array ends. No global ASCII restriction on unselected theories is needed.

## Producer format, capacity and physical file bounds

The precise external producer contract covers every configured admitted Main
and fixed-library invocation. It includes the reviewed Standard metadata and
fresh translation lifecycle, complete selected schemas whenever emitted,
selected-name uniqueness, Image's String/Integer dependencies, the normalization
grammar above, and faithful occurrence-counter serialization in the intended
Natural domain. Generic semantic faithfulness of an arbitrary Why3 AST does not
by itself supply these format properties. None of them assumes Silver matcher
success, scanner state, insertion offsets or the desired Image assertion.

The serialized-ID maximum 2147483647 is the intended Natural counter domain,
not an observed machine-enforced guard. Installed Linux binary inspection found
unchecked 32-bit increments for both the JSON counter and Text_IO's column
counter. The former is at `0xd59366` in the reviewed installed `gnat2why`; Text_IO
character output increments at `0x1085e30` and String output stores its sum at
`0x1086061–0x1086068`. The bundled `a-textio.ali` records `-gnatp`.
The [manifest](evidence/for-loops-image/review-manifest.json) records the installed
binary and retained disassembly hashes. This is evidence that the source
subtypes cannot establish runtime enforcement; no overflowing admitted program
was demonstrated.

Faithful producer-format behavior, including no occurrence-counter wrap for the
configured input scope, is therefore an explicit application of the existing
trusted frontend's format, capacity and completion assumptions. It is not an
independently proved bound on the number of generated nodes. In particular,
the 4096-byte application bound plus the six owned library files is not the full
frontend source universe: fixed vendor declarations, Standard metadata and
generated/inlined structures also participate. This record makes no invented
per-node payload bound or universal finite-model-size calculation. A violation
of the external contract remains a toolchain defect, not a new membership
condition or permission to reject valid Silver.

The separate scanner byte/depth room uses physical representability of the
completed, stable regular model file on the supported 64-bit filesystem ABI:
its length is at most 9223372036854775807. This is an existing filesystem
interface premise, not a conclusion from Text_IO's counter or from scanner
acceptance. Complete document grammar supplies enough enclosing punctuation to
derive the per-theory depth/length room from that whole-file bound. Successful
infrastructure operations and sufficient resources remain the existing external
conditions; no additional source-size limit is introduced here.

## Finite consumer constructor and name interpretation

The consumer boundary is narrower than a theorem about arbitrary Why3 syntax.
It interprets the fixed inserted clone, include, their five substitutions and
the qualified symbols established by the three selected original schemas.
The finite JSON parse-success premise is separate: the three canonical
templates have specified meanings under the partial parser-soundness contract.
No universal parser-success assertion for unbounded integers is used.
The finite consumer theorem separately requires the original model to form a
valid typed name environment, including namespace uniqueness, and the external
lookup of `silver_image.Integer_Image_Length` to select the exact checked theory
text. Successful Silver scanning establishes neither premise. Its returned
`Signature` is the predefined-source semantic interpretation of the consumer's
symbolic instantiation, not the native OCaml return type or a solver result.

All references in this section are under the pinned Why3 source:

| Source | Reviewed interpretation |
| --- | --- |
| `plugins/gnat_json/gnat_ast.ml:1395–1406,2053–2099` | Clone kind 2 is `Clone_default`; substitution 0 is type and 1 is function. The exact declaration/include arrays are converted in their declared field order. |
| `plugins/gnat_json/gnat_ast_to_ptree.ml:76–117` | Symbol names use module-name, namespace and symbol components; module references use file plus module-name. Empty namespace/module fields stay absent. |
| `gnat_ast_to_ptree.ml:160–173` | Include kind 2 creates a use-import with the module's own name as alias. The added include therefore introduces `Standard__integer` as that namespace. |
| `gnat_ast_to_ptree.ml:1240–1280` | Type substitutions become `CStsym` and function substitutions `CSfsym`. Clone kind 2 creates `mk_cloneimport true` with the explicit `Silver_Image` alias and the five substitutions, preceded by `CSprop Paxiom` (`axiom .`). |
| `gnat_ast_to_ptree.ml:1315–1330` | Includes are deduplicated and emitted before declarations; declaration order is retained. Thus the added Integer namespace is available when the appended clone is interpreted. |
| `src/parser/typing.ml:87–109,126–127` | Qualified names resolve in the supplied namespace; target type/function kinds are checked. |
| `src/parser/typing.ml:1584–1601,1623–1628` | Module lookup distinguishes current-file and file-qualified modules. Clone sources resolve in the imported theorem's export namespace; target types/functions resolve in the current module/theory namespace. |
| `src/parser/typing.ml:1720–1737` | Use/clone imports open the selected alias scope, import or clone-export, then close according to the import flag. |

The two target types are `_gnatprove_standard.Main.__image` and
`Standard__string.string__`; the function roles are
`Standard__integer.attr__ATTRIBUTE_IMAGE`, local `to_string` in
`Standard_String__Img`, and `Standard__string.length`. The reviewed fixed
schemas and include ordering identify their declarations and scope. The
external primitive-meaning contract applies the inherited predefined Ada
meanings to those exact identities and the actual checked `Clone.substitutions`.
It does not assert that arbitrary malformed trees with equivalent decoded role
rows are accepted. It contains no Image assertion, adapter acceptance or
solver-success premise. `ImageModelConsumerBoundary` derives the actual
returned signature's equality with the predefined mathematical signature, then
the size-12 assertion from the independent Image theorem.
`ImageConsumerEndpoint.RefinedDocument.consumer_instance` connects that result
to the actual inserted occurrence and scope. The mathematical role decoder
alone is not that consumer composition.

The producer-to-Finish and native consumer/refinement endpoint chain is named
in the [capability delivery checkpoint](for-loops-integers.md#stable-delivery-evidence).
The final combined input-specific validation and independent review are
recorded there; the source inspection and finite reconstruction in this record
do not stand in for those checks.
