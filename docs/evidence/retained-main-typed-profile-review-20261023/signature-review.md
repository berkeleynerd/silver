# Selected contract signature review

This table records the source review used by the successful exact-freeze audit.
The separate review report gives the scoped acceptance; #178 remains unfinished.
The retained Q0NIav `main.gnat-json` has SHA256
`594cb4e23ba1a6c370eb2a058a4648825f1cdf4f1e476b005d330278259b7c7a`.
It is read as an existing source-correspondence witness; no target is run.
The final audit binds the complete author freeze and independently checks
the selected occurrence/context inventory against this signature table.

The five-contract slice uses 29 distinct callable/projection symbols.
The following table groups symbols only where their declaration/import routes
and type signatures agree. `Prop` means a Why3 logical proposition; it is
distinct from the value type `bool`.

| Selected symbol(s) | Arity / logical result | Declaration and transfer |
| --- | --- | --- |
| `=` | 2 / Prop | Why3 built-in equality; Dterm equality branch 633–637 preserves the binary skeleton and uses iff only when a child is a proposition. |
| `int.Int.+`, `int.Int.<=` | 2 / int, Prop respectively | Retained installed `int.mlw:19,25`; no body inlining at this application-typing step. |
| `Array__Int__Standard__character.bool_eq` | 6 / bool | Native function declaration ID511, domain Pterm, six parameters and bool return. |
| `Array__Int__Standard__character.get`, `.slice` | 2 / Character; 3 / map | Native clone ID473 of `_gnatprove_standard.Array__1`; installed source lines1890,1972. Clone substitutions supply the existing int index and Character component types. |
| `Array__Int__Standard__character.map__content` | 1 / map | Same clone, named field at installed `_gnatprove_standard.mlw:1884`. |
| `int__content`, `bool__content` | 1 / int, bool respectively | Named reference fields at installed `_gnatprove_standard.mlw:32–33`. |
| `Standard__character___rep.to_rep` | 1 / int | Native clone ID439 of `ada__model.Rep_Proj_Int`; source105–106 clones `Rep_Proj_Base`, whose function declaration is line6. |
| `Standard__string.first`, `.last`, `.length`, `.to_array` | 1 / int, int, int, map respectively | Native clone ID1176 of `ada__model.Unconstr_Array`; declarations at1636,1640,1644,1629. |
| `Silver_io__put_line__T4s.{first,last,to_array,of_array}` and `Silver_io__put__T6s.{first,last,to_array,of_array}` | 1 / int,int,map; 3 / String | Both native theories export `Standard__string` and alias its String type. `of_array` is declared at `ada__model.mlw:1631`; other signatures are the preceding row. |
| `Standard__string___axiom.dynamic_invariant` | 5 / Prop | Native predicate declaration ID1638. |
| `Silver_arguments__input_is_valid___logic_fun.input_is_valid` | 1 / bool | Native Pterm declaration ID1762 with unit formal. |
| `Silver_arguments__input_is_valid.input_is_valid` | 1 / bool | This theory exports the preceding logic module. The logical symbol resolves through that export; the separate program declaration is RKnone and does not itself introduce a logic symbol. |
| `Silver_arguments__first_or_default___logic_fun.first_or_default` | 1 / String | Native Pterm declaration ID1854. |
| `Silver_arguments__first_or_default___logic_fun.first_or_default__function_guard` | 2 / Prop | Native Pred declaration ID1872. Its native return_type annotation says bool, but the converter's Pred branch constructs a logical predicate. The annotation is not the logical result sort. |
| `Silver_io__Twritten_countS___axiom.dynamic_invariant`, `Silver_io__Twritten_bytesS___axiom.dynamic_invariant` | 5 / Prop | Native predicate declarations ID2761 and ID2956. |

The imported theory sources are complete members of
`retained-producer-main-types-20261018/sources.tar.gz`, identified by its
existing manifest. Converter and typing sources are complete members of
`retained-producer-typing-20261018/sources.tar.gz`; `dterm.ml` is retained in
`retained-producer-prefix-gc-20261018/sources.tar.gz`.

The relevant nonenlargement conditions are substantive. `typing.ml:335–342`
builds one DTapp for a fully applied first-order logical symbol; underapplication
can construct a closure and overapplication adds DTfapp nodes. The selected
arity inventory excludes both. The named mutable-reference fields above
are explicit unary applications, not implicit dereference of polymorphic
builtin refs.

`dterm.ml:613–617` can add equality-with-True when a bool value is requested as
a proposition, or an if/True/False wrapper when a proposition is requested as
a value. The selected contracts use Boolean values as equality operands and
predicate symbols as formulas. The final context traversal confirms every
occurrence, including let definitions, conditional tests and quantifier bodies.
Native W_CALL domain/type annotations alone do not establish this property.

The converter uses nonassociative `Tinnfix` for comparisons and `Tbinnop` for
connections (`gnat_ast_to_ptree.ml:337–383,495–537`). The selected contracts
therefore do not acquire a repeated middle operand through parser chaining.
No selected term has triggers, higher-order application, record update,
embedded application spelling or complex result pattern. Those exclusions
are checked on the complete selected native trees, not inferred from the
few contract examples shown in prose.

The author and reviewer independently identified the coercion/saturation
boundary. Author separately identified two further typed-contract details:
native Some True preconditions become singleton requires lists, so p<=1 is
safe whereas p=0 needs an additional simplification proof; `create_cty` adds
postcondition free program variables to reads, so Put/Put_Line may read all
eleven effect keys. Both were incorporated before freeze.
