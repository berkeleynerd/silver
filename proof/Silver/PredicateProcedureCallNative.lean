module

public import Silver.PredicateProcedureCallSyntax

@[expose] public section
namespace Silver.Predicate.ProcedureCallNative
open Compose

/-- The native target pass reads every actual from the incoming flow. No
procedure-input validity or successful-target premise is hidden in the tree. -/
def targetBody : Command .actual :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .flow := .variable "facts"
  let parameter : Expr .formal := .variable "parameter"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let scalar : Expr .number := .variable "scalar"
  let flag : Expr .number := .variable "flag"
  let bounds := Expr.field .formalBounds parameter
  let incoming := Expr.valueAt facts scalar
  let empty (value : Expr .interval) := Expr.app (.function .isEmpty) value
  let included (value bounds : Expr .interval) := apply2 (.function .included) value bounds
  .letValue "first" ["literal_position"] (apply2 (.function .skip) text position) <|
  .letValue "after" ["literal_position"] (apply2 (.function .nameAfter) text first) <|
  .letValue "scalar" ["scalar_expressions", ".", "binding_count"]
    (apply3 (.function .scalarTarget) text context position) <|
  .letValue "flag" ["boolean_count"] (apply3 (.function .booleanTarget) text context position) <|
  .beginBody <|
  .guard (.orElse (.eq first (.number 0)) (.le after first)) .invalidActual <|
  .branch (.eqKind (.field .formalKind parameter) (.kind .integer))
    (.guard
      (.orElse (.orElse (.orElse (.orElse
        (.eq scalar (.number 0))
        (.not (.scalarMutable (.field .contextScalars context) scalar)))
        (empty bounds))
        (.not (included bounds (.declaredBounds (.field .contextScalars context) scalar))))
        (.group (.andThen (.eqMode (.field .formalMode parameter) (.mode .inputOutput))
          (.group (.orElse (empty incoming) (.not (included incoming bounds)))))))
      .invalidActual <| .returned (.actualResult first after scalar (.number 0)))
    (.guard (.orElse (.eq flag (.number 0))
      (.not (.booleanMutable (.field .contextBooleans context) flag))) .invalidActual <|
      .returned (.actualResult first after (.number 0) flag))

def actualBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .flow := .variable "facts"
  let parameter : Expr .formal := .variable "parameter"
  .ite (.eqMode (.field .formalMode parameter) (.mode .input))
    (apply5 (.function .functionActual) text context position facts
      (.functionFormal (.field .formalFirst parameter) (.field .formalAfter parameter)
        (.field .formalKind parameter) (.field .formalBounds parameter)))
    (.field .actualAfter (apply5 (.function .target) text context position facts parameter))

def actualsBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .flow := .variable "facts"
  let catalog : Expr .metadata := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let after : Expr .number := .variable "after"
  let comma := apply3 (.function .token) text after (.token .comma)
  .declare <| .letValue "after" (apply5 (.function .actual) text context position facts (.formalAt catalog first)) <|
    .beginValue <| .group <| .ite (.eq after (.number 0)) (.number 0)
      (.elsif (.eq first last) (apply3 (.function .token) text after (.token .rightParenthesis))
        (.elsif (.eq comma (.number 0)) (.number 0)
          (apply7 (.function .actualsModel) text context comma facts catalog (.add first (.number 1)) last)))

def updateBody : Command .scan :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let incoming : Expr .flow := .variable "incoming"
  let scan : Expr .scan := .variable "scan"
  let parameter : Expr .formal := .variable "parameter"
  let callFirst : Expr .number := .variable "call_first"
  let callAfter : Expr .number := .variable "call_after"
  let after : Expr .number := .variable "after"
  let target : Expr .actual := .variable "target"
  let first := Expr.field .actualFirst target
  let targetAfter := Expr.field .actualAfter target
  let scalar := Expr.field .actualScalar target
  let rejected := Expr.app (.function .invalid) scan
  let advanced := Expr.update .assigned (.update .position scan targetAfter) (.truth true)
  .beginBody <| .branch (.eqMode (.field .formalMode parameter) (.mode .input))
    (.block <| .letValue "after" ["literal_position"]
      (apply5 (.function .actual) text context (.field .scanPosition scan) incoming parameter) <|
      .beginBody <| .returned <| .group <| .ite (.le after (.field .scanPosition scan))
        rejected (.update .position scan after))
    (.block <| .letValue "target" ["procedure_actual_result"]
      (apply5 (.function .target) text context (.field .scanPosition scan) incoming parameter) <|
      .beginBody <| .guard
        (.orElse (.orElse (.orElse (.orElse
          (.eq targetAfter (.number 0)) (.lt first callFirst)) (.gt targetAfter callAfter))
          (.not (apply5 (.function .nameFree) text callFirst first first targetAfter)))
          (.not (apply5 (.function .nameFree) text targetAfter callAfter first targetAfter)))
        rejected <|
        .branch (.eq scalar (.number 0)) (.returned advanced)
          (.returned (.update .facts advanced
            (.replace (.field .scanFacts scan) scalar (.field .formalBounds parameter)))))

def updatesBody : Expr .scan :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let incoming : Expr .flow := .variable "incoming"
  let scan : Expr .scan := .variable "scan"
  let catalog : Expr .metadata := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let callFirst : Expr .number := .variable "call_first"
  let callAfter : Expr .number := .variable "call_after"
  let next : Expr .scan := .variable "next"
  let following : Expr .scan := .variable "following"
  let rejected := Expr.app (.function .invalidModel) scan
  .declare <| .letValue "next"
    (apply7 (.function .update) text context incoming scan (.formalAt catalog first) callFirst callAfter) <|
    .beginValue <| .group <| .ite (.eq (.field .scanPosition next) (.number 0)) rejected
      (.elsif (.eq first last) (apply4 (.function .bodyToken) text context next (.token .rightParenthesis))
        (.group <| .declare <| .letValue "following"
          (apply4 (.function .bodyToken) text context next (.token .comma)) <|
          .beginValue <| .group <| .ite (.eq (.field .scanPosition following) (.number 0)) rejected
            (apply9 (.function .updatesModel) text context incoming following catalog
              (.add first (.number 1)) last callFirst callAfter)))

def calleeBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let catalog : Expr .metadata := .variable "catalog"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  .declare <| .letValue "first" (apply2 (.function .skip) text position) <|
    .letValue "after" (apply2 (.function .nameAfter) text first) <|
    .beginValue <| .group <| .ite
      (.orElse (.orElse (.orElse (.orElse (.orElse
        (.eq first (.number 0)) (.le after first))
        (.ne (apply4 (.function .namesLookup) text (.field .contextNames context) first after) (.number 0)))
        (.ne (apply4 (.function .scalarLookup) text (.field .contextScalars context) first after) (.number 0)))
        (.ne (apply4 (.function .booleanLookup) text (.field .contextBooleans context) first after) (.number 0)))
        (.ne (apply4 (.function .arrayLookup) text (.field .contextArrays context) first after) (.number 0)))
      (.number 0) (apply4 (.function .procedureLookup) text catalog first after)

def callBody : Command .scan :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let scan : Expr .scan := .variable "scan"
  let catalog : Expr .metadata := .variable "catalog"
  let callee : Expr .number := .variable "callee"
  let item : Expr .signature := .variable "item"
  let start : Expr .number := .variable "start"
  let after : Expr .number := .variable "after"
  let first := Expr.field .signatureFirst item
  let last := Expr.sub (.add first (.field .signatureCount item)) (.number 1)
  let rejected := Expr.app (.function .invalid) scan
  .letValue "callee" ["procedures", ".", "procedure_count"]
    (apply4 (.function .callee) text context (.field .scanPosition scan) catalog) <|
    .beginBody <| .guard (.eq callee (.number 0)) rejected <|
    .block <| .letValue "item" ["procedures", ".", "signature"] (.signatureAt catalog callee) <|
      .letValue "start" ["literal_position"]
        (apply3 (.function .token) text
          (apply2 (.function .nameAfter) text (apply2 (.function .skip) text (.field .scanPosition scan)))
          (.token .leftParenthesis)) <|
      .letValue "after" ["literal_position"]
        (apply7 (.function .actuals) text context start (.field .scanFacts scan) catalog first last) <|
      .beginBody <| .guard (.orElse (.eq start (.number 0)) (.le after (.field .scanPosition scan))) rejected <|
      .returned (apply8 (.function .updates) text context (.update .position scan start) catalog first last start after)

def modelCalls : Calls
  | .skip => skipAt
  | .nameAfter => nameAfter
  | .namesLookup => lookupName
  | .scalarLookup => ScalarExpression.lookup
  | .booleanLookup => BooleanBindings.lookup
  | .arrayLookup => ArrayBindings.lookup
  | .procedureLookup => ProcedureBindings.lookup
  | .token => tokenAfter
  | .isEmpty => Integer.Interval.isEmpty
  | .included => Integer.Interval.included
  | .scalarTarget => fun text context position => Predicate.scalarTarget text context.model position
  | .booleanTarget => fun text context position => Predicate.booleanTarget text context.model position
  | .functionActual => fun text context position facts parameter => actualAfter text context.model position facts parameter
  | .nameFree => actualNameFree
  | .invalid | .invalidModel => invalidBody
  | .bodyToken => fun text _ scan token => Predicate.bodyToken text scan token
  | .target => fun text context position facts parameter => procedureTargetActual text context.model position facts parameter
  | .actual => fun text context position facts parameter => procedureActualAfter text context.model position facts parameter
  | .actualsModel | .actuals => fun text context position facts catalog first last =>
      procedureActualsAfter text context.model position facts catalog first last
  | .update => fun text context incoming scan parameter callFirst callAfter =>
      procedureUpdateStep text context.model incoming scan parameter callFirst callAfter
  | .updatesModel => fun text context incoming scan catalog first last callFirst callAfter =>
      procedureUpdatesModel text context.model incoming scan catalog first last callFirst callAfter
  | .updates => fun text context scan catalog first last callFirst callAfter =>
      procedureUpdates text context.model scan catalog first last callFirst callAfter
  | .callee => fun text context position catalog => procedureCalleeAt text context.model position catalog
  | .call => fun text context scan catalog => procedureCallBody text context.model scan catalog

structure Frame where
  text : Source := []
  context : Native.Context := {names := [], dynamicFirst := 0, dynamicAfter := 0}
  position : Nat := 0
  facts : ActiveFlow := ⟨PathFacts.Context.empty, []⟩
  incoming : ActiveFlow := ⟨PathFacts.Context.empty, []⟩
  scan : BodyScan := ⟨0,0,0,⟨PathFacts.Context.empty, []⟩,false,false⟩
  catalog : ProcedureBindings.Metadata := {}
  parameter : ProcedureBindings.Formal := ProcedureBindings.emptyFormal
  first : Nat := 0
  last : Nat := 0
  callFirst : Nat := 0
  callAfter : Nat := 0

def Frame.locals (frame : Frame) : Locals
  | .source, _ => frame.text
  | .context, _ => frame.context
  | .number, name => if name = "position" then frame.position else if name = "first" then frame.first else
      if name = "last" then frame.last else if name = "call_first" then frame.callFirst else
      if name = "call_after" then frame.callAfter else 0
  | .flow, name => if name = "incoming" then frame.incoming else frame.facts
  | .scan, _ => frame.scan
  | .metadata, _ => frame.catalog
  | .formal, _ => frame.parameter
  | ty, _ => ty.default

end Silver.Predicate.ProcedureCallNative
