module

public import Silver.PredicateNativeExpressions

@[expose] public section

namespace Silver.Predicate.Native

namespace Expr

def declared (name : String) (typeName : List String) (value : Expr a) (body : Expr b) : Expr b :=
  .group (.locals (.local name typeName value body))

def declaredCondition (name : String) (count : Expr .number) (value : Expr .condition) (body : Expr b) : Expr b :=
  .group (.locals (.localCondition name count value body))

end Expr

def summaryBody : Expr .summary :=
  .summary (.field .resultMinimum (.variable "value"))
    (.field .resultLength (.variable "value")) (.field .resultDynamic (.variable "value"))
    (.field .resultEmpty (.variable "value"))

def boundBody : Expr .bound :=
  .bound (.field .bindingLength (.variable "value")) (.field .bindingDynamic (.variable "value"))

def bindingSummaryBody : Expr .summary :=
  let value : Expr .binding := .variable "value"
  .summary (.group (.ite (.field .bindingDynamic value) (.number 0) (.field .bindingLength value)))
    (.group (.ite (.field .bindingDynamic value) (.number 0) (.field .bindingLength value)))
    (.group (.ite (.field .bindingDynamic value) (.number 1) (.number 0))) (.truth false)

def comparisonBody : Expr .compared :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let take (token : Token) := Expr.callTake text position (.token token)
  .ite (.ne (take .notEqual) (.number 0)) (.compared (take .notEqual) (.comparison .ne))
    (.elsif (.ne (take .lessEqual) (.number 0)) (.compared (take .lessEqual) (.comparison .le))
      (.elsif (.ne (take .greaterEqual) (.number 0)) (.compared (take .greaterEqual) (.comparison .ge))
        (.elsif (.ne (take .equal) (.number 0)) (.compared (take .equal) (.comparison .eq))
          (.elsif (.ne (take .less) (.number 0)) (.compared (take .less) (.comparison .lt))
            (.elsif (.ne (take .greater) (.number 0)) (.compared (take .greater) (.comparison .gt))
              (.compared (.number 0) (.comparison .eq)))))))

def lengthBody : Expr .length :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let index : Expr .number := .variable "index"
  let number : Expr .literal := .variable "number"
  let names := Expr.field .contextNames context
  .locals <| .local "first" ["literal_position"] (.callSkip text (.variable "position")) <|
    .local "after" ["literal_position"] (.callNameAfter text first) <|
    .local "index" ["binding_count"] (.callLookup text names first after) <|
    .local "number" ["silver_integer_literals", ".", "literal_result"] (.callInteger text first) <|
    .group <| .ite (.andThen (.variable "literal") (.ne (.field .literalAfter number) (.number 0)))
      (.length (.field .literalAfter number) (.bound (.field .literalValue number) (.truth false)))
      (.elsif (.orElse (.eq index (.number 0))
        (.ne (.callScalarLookup text (.field .contextScalarNames context) first after) (.number 0))) (.length (.number 0) (.bound (.number 0) (.truth false)))
        (.length (.callTake text (.callTake text after (.token .apostrophe)) (.token .lengthName))
          (.callBound (.bindingAt names index))))

def booleanAtomBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  .locals <| .local "first" ["literal_position"] (.callSkip text (.variable "position")) <|
    .local "after" ["literal_position"] (.callNameAfter text first) <|
    .group <| .ite
      (.orElse (.orElse (.orElse (.orElse (.orElse (.eq first (.number 0)) (.le after first))
        (.group (.andThen (.ne (.field .contextMaskFirst context) (.number 0))
          (.callEqualName text (.field .contextMaskFirst context) (.field .contextMaskAfter context) first after))))
        (.ne (.callScalarLookup text (.field .contextScalarNames context) first after) (.number 0)))
        (.ne (.callLookup text (.field .contextNames context) first after) (.number 0)))
        (.ne (.callArrayLookup text (.field .contextArrays context) first after) (.number 0)))
      (.number 0)
      (.elsif (.ne (.callBooleanLookup text (.field .contextBooleans context) first after) (.number 0)) after
        (.elsif
          (.orElse (.group (.andThen (.callNameIs text first after (.word "true"))
            (.not (.field .contextTrueHidden context))))
            (.group (.andThen (.callNameIs text first after (.word "false"))
              (.not (.field .contextFalseHidden context))))) after (.number 0)))

def primaryBody : Expr .condition :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .facts := .variable "facts"
  let path := Expr.field .flowPath facts
  let after : Expr .number := .variable "after"
  let result : Expr .condition := .variable "result"
  let close : Expr .number := .variable "close"
  let afterCall : Expr .number := .variable "after_call"
  .ite (.eq position (.number 0)) (.invalid facts) <|
    .declared "after" ["literal_position"] (.callTake text position (.token .leftParenthesis)) <|
    .group <| .ite (.ne after (.number 0))
      (.group <| .locals <|
        .localCondition "result" (.field .flowCount facts) (.callModel text context after facts (.variable "initials")) <|
        .local "close" ["literal_position"] (.callTake text (.field .conditionAfter result) (.token .rightParenthesis)) <|
        .group <| .ite (.eq close (.number 0)) (.invalid facts) (.updateAfter result close))
      (.elsif (.ne (.callBooleanAtom text context position) (.number 0))
        (.condition false (.field .flowCount facts) (.callBooleanAtom text context position) facts facts)
      (.elsif (.eq (.field .dynamicFirst context) (.number 0)) (.invalid facts)
        (.declared "after_call" ["literal_position"]
          (.callOperation text (.field .contextNames context) position (.operation .validity)
            (.field .contextScalarNames context) (.field .contextArrays context)
            (.group (.orElse (.subtypeHidden context (.operation .validity))
              (.group (.andThen (.ne (.field .contextMaskFirst context) (.number 0))
                (.callNameIs text (.field .contextMaskFirst context) (.field .contextMaskAfter context) (.word "input_is_valid"))))))
            (.field .contextBooleans context)) <|
          .group <| .ite (.eq afterCall (.number 0)) (.invalid facts)
            (.condition true (.field .flowCount facts) afterCall
              (.updatePath facts (.callAssumeValid path)) (.updatePath facts (.callAssumeInvalid path))))))

def booleanFactorBody : Expr .condition :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .facts := .variable "facts"
  let initials : Expr .initials := .variable "initials"
  let after : Expr .number := .variable "after"
  let result : Expr .condition := .variable "result"
  let primary (position : Expr .number) : Expr .condition :=
    .app (.app (.app (.app (.app (.function .primary) text) context) position) facts) initials
  .locals <| .local "after" ["literal_position"] (.callTake text position (.token .notKeyword)) <|
    .group <| .ite (.eq after (.number 0)) (primary position)
      (.declaredCondition "result" (.field .flowCount facts) (primary after)
        (.condition false (.field .conditionCount result) (.field .conditionAfter result)
          (.field .whenFalse result) (.field .whenTrue result)))

def booleanRelationBody : Expr .condition :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .facts := .variable "facts"
  let initials : Expr .initials := .variable "initials"
  let left : Expr .condition := .variable "left"
  let right : Expr .condition := .variable "right"
  let operator : Expr .compared := .variable "operator"
  .locals <| .localCondition "left" (.field .flowCount facts)
      (.callBooleanFactor text context position facts initials) <|
    .local "operator" ["comparison_result"] (.callComparison text (.field .conditionAfter left)) <|
    .group <| .ite (.eq (.field .conditionAfter left) (.number 0)) (.invalid facts)
      (.elsif (.eq (.field .comparedAfter operator) (.number 0)) left
        (.elsif (.notEquality (.field .comparedOperator operator)) (.invalid facts)
          (.declaredCondition "right" (.field .flowCount facts)
            (.callBooleanFactor text context (.field .comparedAfter operator) facts initials) <|
            .group <| .ite (.eq (.field .conditionAfter right) (.number 0)) (.invalid facts)
              (.condition false (.field .flowCount facts) (.field .conditionAfter right) facts facts))))

def relationBody : Expr .condition :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .facts := .variable "facts"
  let path := Expr.field .flowPath facts
  let count := Expr.field .flowCount facts
  let after : Expr .number := .variable "after"
  let leftLength : Expr .length := .variable "left_length"
  let leftScalar : Expr .scalarResult := .variable "left_scalar"
  let rightScalar : Expr .scalarResult := .variable "right_scalar"
  let rightLength : Expr .length := .variable "right_length"
  let operator : Expr .compared := .variable "operator"
  let left : Expr .result := .variable "left"
  let right : Expr .result := .variable "right"
  let equalFacts : Expr .path := .variable "equal_facts"
  let operation := Expr.field .comparedOperator operator
  let stringResult : Expr .condition :=
    .declared "equal_facts" ["paths", ".", "context"]
      (.callRefineEqual path (.callSummary left) (.callSummary right))
      (.condition true count (.field .resultAfter right)
        (.updatePath facts (.group (.ite (.comparisonEq operation (.comparison .eq)) equalFacts path)))
        (.updatePath facts (.group (.ite (.comparisonEq operation (.comparison .eq)) path equalFacts))))
  let readRight : Expr .condition :=
    .declared "right" ["expression_result"]
      (.callStringInFlow text context (.field .comparedAfter operator) facts (.variable "initials")) <|
      .group <| .ite
        (.orElse (.orElse (.orElse (.le (.field .resultAfter right) position)
          (.not (.group (.orElse (.field .resultNamed left) (.field .resultNamed right)))))
          (.not (.callFits path (.callSummary left)))) (.not (.callFits path (.callSummary right))))
        (.invalid facts) stringResult
  let stringCase : Expr .condition :=
    .declared "left" ["expression_result"] (.callStringInFlow text context position facts (.variable "initials")) <|
      .group <| .ite (.ne (.field .resultAfter left) (.number 0))
        (.declared "operator" ["comparison_result"] (.callComparison text (.field .resultAfter left)) <|
          .group <| .ite (.orElse (.eq (.field .comparedAfter operator) (.number 0)) (.notEquality operation))
            (.invalid facts) readRight)
        (.callBooleanRelation text context position facts (.variable "initials"))
  let scalarCase : Expr .condition :=
    .group <| .locals <|
      .local "operator" ["comparison_result"] (.callComparison text (.field .scalarAfter leftScalar)) <|
      .local "right_scalar" ["scalar_expressions", ".", "expression_result"]
        (.callScalarInFlow text context (.field .comparedAfter operator) facts (.variable "initials")) <|
      .group <| .ite (.le (.field .scalarAfter rightScalar) position) (.invalid facts)
        (.callScalarCondition text context position (.field .comparedAfter operator) facts leftScalar rightScalar operation)
  let lengthCase : Expr .condition :=
    .group <| .locals <|
      .local "operator" ["comparison_result"] (.callComparison text (.field .lengthAfter leftLength)) <|
      .local "right_length" ["length_result"] (.callLength text context (.field .comparedAfter operator) (.truth true)) <|
      .group <| .ite (.le (.field .lengthAfter rightLength) position) (.invalid facts)
        (.condition true count (.field .lengthAfter rightLength)
          (.updatePath facts (.callRefineBounds path operation (.field .lengthValue leftLength) (.field .lengthValue rightLength) (.truth true)))
          (.updatePath facts (.callRefineBounds path operation (.field .lengthValue leftLength) (.field .lengthValue rightLength) (.truth false))))
  .ite (.eq position (.number 0)) (.invalid facts) <|
    .group <| .locals <|
      .local "after" ["literal_position"] (.callTake text position (.token .notKeyword)) <|
      .local "left_length" ["length_result"] (.callLength text context position (.truth false)) <|
    .local "left_scalar" ["scalar_expressions", ".", "expression_result"]
      (.callScalarInFlow text context position facts (.variable "initials")) <|
      .group <| .ite (.ne after (.number 0))
        (.callBooleanRelation text context position facts (.variable "initials"))
        (.elsif (.ne (.field .lengthAfter leftLength) (.number 0)) lengthCase
        (.elsif (.ne (.field .scalarAfter leftScalar) (.number 0)) scalarCase stringCase))

def chainTokenBody : Expr .chain :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let take (token : Token) : Expr .number := .callTake text position (.token token)
  .ite (.ne (take .andKeyword) (.number 0))
    (.group (.ite (.ne (.callTake text (take .andKeyword) (.token .thenKeyword)) (.number 0))
      (.chain .shortAnd) (.chain .eagerAnd)))
    (.elsif (.ne (take .orKeyword) (.number 0))
      (.group (.ite (.ne (.callTake text (take .orKeyword) (.token .elseKeyword)) (.number 0))
        (.chain .shortOr) (.chain .eagerOr)))
      (.elsif (.ne (take .xorKeyword) (.number 0)) (.chain .eagerXor) (.chain .noChain)))

def chainAfterBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let take (token : Token) : Expr .number := .callTake text position (.token token)
  .chainCase (.variable "operator") (.number 0)
    (.callTake text (take .andKeyword) (.token .thenKeyword))
    (.callTake text (take .orKeyword) (.token .elseKeyword))
    (take .andKeyword) (take .orKeyword) (take .xorKeyword)

def tailBody : Expr .condition :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let result : Expr .condition := .variable "result"
  let initials : Expr .initials := .variable "initials"
  let incoming : Expr .facts := .variable "incoming"
  let originalStart : Expr .number := .variable "original_start"
  let count := Expr.field .conditionCount result
  let invalid := Expr.invalid (.field .whenTrue result)
  let selected : Expr .chain := .variable "selected"
  let after : Expr .number := .variable "after"
  let right : Expr .condition := .variable "right"
  let next := Expr.group <| .ite (.chainEq selected (.chain .shortAnd))
    (.condition false count (.field .conditionAfter right) (.field .whenTrue right)
      (.callJoin (.field .whenFalse result) (.field .whenFalse right)))
    (.elsif (.chainEq selected (.chain .shortOr))
      (.condition false count (.field .conditionAfter right)
        (.callJoin (.field .whenTrue result) (.field .whenTrue right)) (.field .whenFalse right))
      (.condition false count (.field .conditionAfter right) incoming incoming))
  .ite (.eq (.field .conditionAfter result) (.number 0)) invalid <|
    .declared "selected" ["chain_kind"] (.callChainToken text (.field .conditionAfter result)) <|
    .group <| .ite (.chainEq selected (.chain .noChain)) result
      (.elsif (.orElse (.group (.andThen (.variable "chained") (.chainNe (.variable "operator") selected)))
          (.group (.andThen (.chainEq selected (.chain .eagerXor))
            (.not (.callXorFree text originalStart (.field .conditionAfter result)))))) invalid
        (.declared "after" ["literal_position"] (.callChainAfter text (.field .conditionAfter result) selected) <|
          .group <| .ite (.eq after (.number 0)) invalid
            (.declaredCondition "right" count
              (.callRelation text context after
                (.group (.ite (.chainEq selected (.chain .shortAnd)) (.field .whenTrue result)
                  (.elsif (.chainEq selected (.chain .shortOr)) (.field .whenFalse result) incoming))) initials) <|
              .group <| .ite (.orElse (.eq (.field .conditionAfter right) (.number 0))
                  (.group (.andThen (.chainEq selected (.chain .eagerXor))
                    (.not (.callXorFree text after (.field .conditionAfter right)))))) invalid
                (.callTail text context next selected (.truth true) initials incoming originalStart))))

def modelBody : Expr .condition :=
  let result : Expr .condition := .variable "result"
  let final : Expr .condition := .variable "final"
  let facts : Expr .facts := .variable "facts"
  let initials : Expr .initials := .variable "initials"
  .locals <| .localCondition "result" (.field .flowCount facts)
    (.callRelation (.variable "text") (.variable "context") (.variable "position") facts initials) <|
    .group <| .ite (.eq (.field .conditionAfter result) (.number 0)) (.invalid facts)
      (.declaredCondition "final" (.field .flowCount facts)
        (.callTail (.variable "text") (.variable "context") result (.chain .shortAnd) (.truth false) initials facts (.variable "position")) <|
        .group <| .ite (.eq (.field .conditionAfter final) (.number 0)) (.invalid facts) final)

/-- The exact Static equality RHS of Read_Condition_Into. -/
def conditionBody : Expr .condition :=
  .callModel (.variable "text") (.variable "context") (.variable "position") (.variable "facts") (.variable "initials")

end Silver.Predicate.Native
