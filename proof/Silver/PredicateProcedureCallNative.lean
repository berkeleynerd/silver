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

def actualsTailBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .flow := .variable "facts"
  let catalog : Expr .metadata := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let ordinal : Expr .number := .variable "ordinal"
  let named : Expr .truth := .variable "named"
  let seen : Expr .formalSet := .variable "seen"
  let association : Expr .association := .variable "association"
  let formal := Expr.field .associationFormal association
  let payload := Expr.field .associationPayload association
  let after : Expr .number := .variable "after"
  let comma := apply3 (.function .token) text after (.token .comma)
  .declare <| .letValue "association"
    (apply7 (.function .association) text position catalog first last ordinal named) <|
    .beginValue <| .group <| .ite (.orElse (.eq formal (.number 0)) (.seenAt seen formal)) (.number 0)
      (.group <| .declare <| .letValue "after"
        (apply5 (.function .actual) text context payload facts (.formalAt catalog formal)) <|
        .beginValue <| .group <| .ite (.eq after (.number 0)) (.number 0)
          (.elsif (.eq ordinal last) (apply3 (.function .token) text after (.token .rightParenthesis))
            (.elsif (.eq comma (.number 0)) (.number 0)
              (apply10 (.function .actualsTail) text context comma facts catalog first last
                (.add ordinal (.number 1)) (.field .associationNamed association) (.markSeen seen formal)))))

def actualsBody : Expr .number :=
  apply10 (.function .actualsTail) (.variable "text") (.variable "context") (.variable "position")
    (.variable "facts") (.variable "catalog") (.variable "first") (.variable "last")
    (.variable "first") (.truth false) .noFormals

/-- A selected formal's label never reaches Actual_Name_Free_Model. Replay
checks each payload under the same incoming flow and exempts exactly the
writable actual's own source span. -/
def payloadsFreeBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let incoming : Expr .flow := .variable "incoming"
  let catalog : Expr .metadata := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let ordinal : Expr .number := .variable "ordinal"
  let named : Expr .truth := .variable "named"
  let callAfter : Expr .number := .variable "call_after"
  let targetFirst : Expr .number := .variable "target_first"
  let targetAfter : Expr .number := .variable "target_after"
  let association : Expr .association := .variable "association"
  let formal := Expr.field .associationFormal association
  let payload := Expr.field .associationPayload association
  let after : Expr .number := .variable "after"
  let comma := apply3 (.function .token) text after (.token .comma)
  .declare <| .letValue "association"
    (apply7 (.function .association) text position catalog first last ordinal named) <|
    .beginValue <| .group <| .ite (.orElse (.eq callAfter (.number 0)) (.eq formal (.number 0))) (.truth false)
      (.group <| .declare <| .letValue "after"
        (apply5 (.function .actual) text context payload incoming (.formalAt catalog formal)) <|
        .beginValue <| .group <| .ite (.eq after (.number 0)) (.truth false)
          (.elsif (.not (.group (.orElse
            (.group (.andThen (.eq (apply2 (.function .skip) text payload) targetFirst) (.eq after targetAfter)))
            (apply5 (.function .nameFreeModel) text payload after targetFirst targetAfter)))) (.truth false)
            (.elsif (.eq ordinal last)
              (.eq (apply3 (.function .token) text after (.token .rightParenthesis)) callAfter)
              (.elsif (.eq comma (.number 0)) (.truth false)
                (apply12 (.function .payloadsFreeModel) text context comma incoming catalog first last
                  (.add ordinal (.number 1)) (.field .associationNamed association) callAfter targetFirst targetAfter)))))

def updateBody : Command .scan :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let incoming : Expr .flow := .variable "incoming"
  let scan : Expr .scan := .variable "scan"
  let parameter : Expr .formal := .variable "parameter"
  let catalog : Expr .metadata := .variable "catalog"
  let firstFormal : Expr .number := .variable "first"
  let lastFormal : Expr .number := .variable "last"
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
        (.orElse (.orElse (.orElse
          (.eq targetAfter (.number 0)) (.lt first callFirst)) (.gt targetAfter callAfter))
          (.not (apply10 (.function .payloadsFree) text context callFirst incoming catalog firstFormal lastFormal
            callAfter first targetAfter)))
        rejected <|
        .branch (.eq scalar (.number 0)) (.returned advanced)
          (.returned (.update .facts advanced
            (.replace (.field .scanFacts scan) scalar (.field .formalBounds parameter)))))

def updatesTailBody : Expr .scan :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let incoming : Expr .flow := .variable "incoming"
  let scan : Expr .scan := .variable "scan"
  let catalog : Expr .metadata := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let ordinal : Expr .number := .variable "ordinal"
  let named : Expr .truth := .variable "named"
  let seen : Expr .formalSet := .variable "seen"
  let callFirst : Expr .number := .variable "call_first"
  let callAfter : Expr .number := .variable "call_after"
  let association : Expr .association := .variable "association"
  let formal := Expr.field .associationFormal association
  let payload := Expr.field .associationPayload association
  let next : Expr .scan := .variable "next"
  let following : Expr .scan := .variable "following"
  let rejected := Expr.app (.function .invalidModel) scan
  .declare <| .letValue "association"
    (apply7 (.function .association) text (.field .scanPosition scan) catalog first last ordinal named) <|
    .beginValue <| .group <| .ite (.orElse (.eq formal (.number 0)) (.seenAt seen formal)) rejected
      (.group <| .declare <| .letValue "next"
        (apply10 (.function .update) text context incoming (.update .position scan payload)
          (.formalAt catalog formal) catalog first last callFirst callAfter) <|
        .beginValue <| .group <| .ite (.eq (.field .scanPosition next) (.number 0)) rejected
          (.elsif (.eq ordinal last) (apply4 (.function .bodyToken) text context next (.token .rightParenthesis))
            (.group <| .declare <| .letValue "following"
              (apply4 (.function .bodyToken) text context next (.token .comma)) <|
              .beginValue <| .group <| .ite (.eq (.field .scanPosition following) (.number 0)) rejected
                (apply12 (.function .updatesTail) text context incoming following catalog first last
                  (.add ordinal (.number 1)) (.field .associationNamed association) (.markSeen seen formal)
                  callFirst callAfter))))

def updatesBody : Expr .scan :=
  apply12 (.function .updatesTail) (.variable "text") (.variable "context") (.variable "incoming")
    (.variable "scan") (.variable "catalog") (.variable "first") (.variable "last") (.variable "first")
    (.truth false) .noFormals (.variable "call_first") (.variable "call_after")

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
  | .nameFree | .nameFreeModel => actualNameFree
  | .association => procedureAssociation
  | .invalid | .invalidModel => invalidBody
  | .bodyToken => fun text _ scan token => Predicate.bodyToken text scan token
  | .target => fun text context position facts parameter => procedureTargetActual text context.model position facts parameter
  | .actual => fun text context position facts parameter => procedureActualAfter text context.model position facts parameter
  | .actualsModel | .actuals => fun text context position facts catalog first last =>
      procedureActualsAfter text context.model position facts catalog first last
  | .actualsTail => fun text context position facts catalog first last ordinal named seen =>
      procedureActualsTailModel text context.model position facts catalog first last ordinal named seen
  | .payloadsFreeModel => fun text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter =>
      procedurePayloadsFreeModel text context.model position incoming catalog first last ordinal named callAfter targetFirst targetAfter
  | .payloadsFree => fun text context position incoming catalog first last callAfter targetFirst targetAfter =>
      procedurePayloadsFree text context.model position incoming catalog first last callAfter targetFirst targetAfter
  | .update => fun text context incoming scan parameter catalog first last callFirst callAfter =>
      procedureUpdateStep text context.model incoming scan parameter catalog first last callFirst callAfter
  | .updatesTail => fun text context incoming scan catalog first last ordinal named seen callFirst callAfter =>
      procedureUpdatesTailModel text context.model incoming scan catalog first last ordinal named seen callFirst callAfter
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
  ordinal : Nat := 0
  named : Bool := false
  seen : FormalSet := noFormals
  targetFirst : Nat := 0
  targetAfter : Nat := 0
  callFirst : Nat := 0
  callAfter : Nat := 0

def Frame.locals (frame : Frame) : Locals
  | .source, _ => frame.text
  | .context, _ => frame.context
  | .number, name => if name = "position" then frame.position else if name = "first" then frame.first else
      if name = "last" then frame.last else if name = "call_first" then frame.callFirst else
      if name = "call_after" then frame.callAfter else if name = "ordinal" then frame.ordinal else
      if name = "target_first" then frame.targetFirst else if name = "target_after" then frame.targetAfter else 0
  | .truth, _ => frame.named
  | .formalSet, _ => frame.seen
  | .flow, name => if name = "incoming" then frame.incoming else frame.facts
  | .scan, _ => frame.scan
  | .metadata, _ => frame.catalog
  | .formal, _ => frame.parameter
  | ty, _ => ty.default

end Silver.Predicate.ProcedureCallNative
