module

public import Silver.PredicateNativeExpressions

@[expose] public section

namespace Silver.Predicate.Native

namespace Expr

def declared (name : String) (typeName : List String) (value : Expr a) (body : Expr b) : Expr b :=
  .group (.locals (.local name typeName value body))

end Expr

def summaryBody : Expr .summary :=
  .summary (.field .resultLength (.variable "value")) (.field .resultDynamic (.variable "value"))

def boundBody : Expr .bound :=
  .bound (.field .bindingLength (.variable "value")) (.field .bindingDynamic (.variable "value"))

def bindingSummaryBody : Expr .summary :=
  let value : Expr .binding := .variable "value"
  .summary (.group (.ite (.field .bindingDynamic value) (.number 0) (.field .bindingLength value)))
    (.group (.ite (.field .bindingDynamic value) (.number 1) (.number 0)))

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
      (.elsif (.eq index (.number 0)) (.length (.number 0) (.bound (.number 0) (.truth false)))
        (.length (.callTake text (.callTake text after (.token .apostrophe)) (.token .lengthName))
          (.callBound (.bindingAt names index))))

def primaryBody : Expr .condition :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .facts := .variable "facts"
  let after : Expr .number := .variable "after"
  let result : Expr .condition := .variable "result"
  .ite (.eq position (.number 0)) .invalid <|
    .declared "after" ["literal_position"] (.callTake text position (.token .leftParenthesis)) <|
    .group <| .ite (.ne after (.number 0))
      (.declared "result" ["condition_result"] (.callCondition text context after facts)
        (.updateAfter result (.callTake text (.field .conditionAfter result) (.token .rightParenthesis))))
      (.elsif (.eq (.field .dynamicFirst context) (.number 0)) .invalid
        (.condition
          (.callTake text (.callTake text (.callTake text position (.token .argumentsName)) (.token .dot)) (.token .inputIsValid))
          (.callAssumeValid facts) (.callAssumeInvalid facts)))

def relationBody : Expr .condition :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let position : Expr .number := .variable "position"
  let facts : Expr .facts := .variable "facts"
  let after : Expr .number := .variable "after"
  let leftLength : Expr .length := .variable "left_length"
  let rightLength : Expr .length := .variable "right_length"
  let result : Expr .condition := .variable "result"
  let operator : Expr .compared := .variable "operator"
  let left : Expr .result := .variable "left"
  let right : Expr .result := .variable "right"
  let equalFacts : Expr .facts := .variable "equal_facts"
  let operation := Expr.field .comparedOperator operator
  let stringResult : Expr .condition :=
    .declared "equal_facts" ["paths", ".", "context"]
      (.callRefineEqual facts (.callSummary left) (.callSummary right))
      (.condition (.field .resultAfter right)
        (.group (.ite (.comparisonEq operation (.comparison .eq)) equalFacts facts))
        (.group (.ite (.comparisonEq operation (.comparison .eq)) facts equalFacts)))
  let readRight : Expr .condition :=
    .declared "right" ["expression_result"]
      (.callExpression text (.field .comparedAfter operator) (.field .contextNames context)) <|
      .group <| .ite
        (.orElse (.orElse (.orElse (.le (.field .resultAfter right) position)
          (.not (.group (.orElse (.field .resultNamed left) (.field .resultNamed right)))))
          (.not (.callFits facts (.callSummary left)))) (.not (.callFits facts (.callSummary right))))
        .invalid stringResult
  let stringCase : Expr .condition :=
    .declared "left" ["expression_result"] (.callExpression text position (.field .contextNames context)) <|
      .group <| .ite (.ne (.field .resultAfter left) (.number 0))
        (.declared "operator" ["comparison_result"] (.callComparison text (.field .resultAfter left)) <|
          .group <| .ite (.orElse (.eq (.field .comparedAfter operator) (.number 0)) (.notEquality operation))
            .invalid readRight)
        (.callPrimary text context position facts)
  let lengthCase : Expr .condition :=
    .group <| .locals <|
      .local "operator" ["comparison_result"] (.callComparison text (.field .lengthAfter leftLength)) <|
      .local "right_length" ["length_result"] (.callLength text context (.field .comparedAfter operator) (.truth true)) <|
      .group <| .ite (.le (.field .lengthAfter rightLength) position) .invalid
        (.condition (.field .lengthAfter rightLength)
          (.callRefineBounds facts operation (.field .lengthValue leftLength) (.field .lengthValue rightLength) (.truth true))
          (.callRefineBounds facts operation (.field .lengthValue leftLength) (.field .lengthValue rightLength) (.truth false)))
  .ite (.eq position (.number 0)) .invalid <|
    .group <| .locals <|
      .local "after" ["literal_position"] (.callTake text position (.token .notKeyword)) <|
      .local "left_length" ["length_result"] (.callLength text context position (.truth false)) <|
      .group <| .ite (.ne after (.number 0))
        (.declared "result" ["condition_result"] (.callPrimary text context after facts)
          (.condition (.field .conditionAfter result) (.field .whenFalse result) (.field .whenTrue result)))
        (.elsif (.ne (.field .lengthAfter leftLength) (.number 0)) lengthCase stringCase)

def chainTokenBody : Expr .token :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  .ite (.ne (.callTake text position (.token .andKeyword)) (.number 0)) (.token .andKeyword)
    (.elsif (.ne (.callTake text position (.token .orKeyword)) (.number 0)) (.token .orKeyword)
      (.token .endKeyword))

def chainAfterBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let operator : Expr .token := .variable "operator"
  .callTake text (.callTake text (.variable "position") operator)
    (.group (.ite (.tokenEq operator (.token .andKeyword)) (.token .thenKeyword) (.token .elseKeyword)))

def tailBody : Expr .condition :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let result : Expr .condition := .variable "result"
  let selected : Expr .token := .variable "selected"
  let after : Expr .number := .variable "after"
  let right : Expr .condition := .variable "right"
  let next := Expr.group <| .ite (.tokenEq selected (.token .andKeyword))
    (.condition (.field .conditionAfter right) (.field .whenTrue right)
      (.callJoin (.field .whenFalse result) (.field .whenFalse right)))
    (.condition (.field .conditionAfter right)
      (.callJoin (.field .whenTrue result) (.field .whenTrue right)) (.field .whenFalse right))
  .ite (.eq (.field .conditionAfter result) (.number 0)) .invalid <|
    .declared "selected" ["token_kind"] (.callChainToken text (.field .conditionAfter result)) <|
    .group <| .ite (.notChain selected) result
      (.elsif (.andThen (.variable "chained") (.tokenNe (.variable "operator") selected)) .invalid
        (.declared "after" ["literal_position"] (.callChainAfter text (.field .conditionAfter result) selected) <|
          .group <| .ite (.eq after (.number 0)) .invalid
            (.declared "right" ["condition_result"]
              (.callRelation text context after
                (.group (.ite (.tokenEq selected (.token .andKeyword)) (.field .whenTrue result) (.field .whenFalse result)))) <|
              .group <| .ite (.eq (.field .conditionAfter right) (.number 0)) .invalid
                (.callTail text context next selected (.truth true)))))

def modelBody : Expr .condition :=
  let result : Expr .condition := .variable "result"
  .locals <| .local "result" ["condition_result"]
    (.callRelation (.variable "text") (.variable "context") (.variable "position") (.variable "facts")) <|
    .group <| .ite (.eq (.field .conditionAfter result) (.number 0)) .invalid
      (.callTail (.variable "text") (.variable "context") result (.token .andKeyword) (.truth false))

def conditionBody : Expr .condition :=
  .callModel (.variable "text") (.variable "context") (.variable "position") (.variable "facts")

end Silver.Predicate.Native
