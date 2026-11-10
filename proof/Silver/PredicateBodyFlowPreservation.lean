module

public import Silver.PredicateBodyFlowValidity
public import Silver.PredicateLoopFlowValidity

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
open Compose

theorem loopBody_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (ready : scan.FlowReady context)
    (environment : ScalarExpression.ValidEnvironment text context.scalarNames) :
    (loopBody (catalog := catalog) (procedures := procedures) text context scan).FlowReady context := by
  rw [loopBody]
  dsimp only
  split
  · exact invalidBody_flowReady ready
  · split
    · exact invalidBody_flowReady ready
    · split
      · split
        · exact invalidBody_flowReady ready
        · split
          · exact invalidBody_flowReady ready
          · apply bodyTokens_flowReady
            exact loopAfterHeader_flowReady base ready environment _ _
      · exact invalidBody_flowReady ready

mutual
  theorem statementBody_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
      (valid : FunctionBindings.ValidMetadata text catalog)
      (procedureValid : ProcedureBindings.ValidMetadata text procedures)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (ready : scan.FlowReady context)
      (environment : ScalarExpression.ValidEnvironment text context.scalarNames) :
      (statementBody (catalog := catalog) (procedures := procedures) text context scan).FlowReady context := by
    rw [statementBody]
    split
    · exact invalidBody_flowReady ready
    · split
      · exact conditionalBody_flowReady (procedureValid := procedureValid) text context scan valid base ready environment
      · split
        · exact loopBody_flowReady (catalog := catalog) (procedures := procedures) text context scan base ready environment
        · exact basic_flowReady (procedureValid := procedureValid) (catalog := catalog) (procedures := procedures) text context scan valid base ready
  termination_by (bodyRemaining text scan, 2)

  theorem conditionalBody_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
      (valid : FunctionBindings.ValidMetadata text catalog)
      (procedureValid : ProcedureBindings.ValidMetadata text procedures)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (ready : scan.FlowReady context)
      (environment : ScalarExpression.ValidEnvironment text context.scalarNames) :
      (conditionalBody (catalog := catalog) (procedures := procedures) text context scan).FlowReady context := by
    rw [conditionalBody]
    try dsimp only
    split
    · exact invalidBody_flowReady ready
    · split
      · split
        · exact invalidBody_flowReady ready
        · split
          · try dsimp only
            split
            · exact invalidBody_flowReady ready
            · have branches := branchStart_flowReady text context scan "if" base ready
              have yes := readBody_flowReady (procedureValid := procedureValid) text context (branchStart text context scan "if").1 .arm
                valid base branches.1 environment
              have no := alternativeBody_flowReady (procedureValid := procedureValid) text context
                {readBody (catalog := catalog) (procedures := procedures) text context (branchStart text context scan "if").1 .arm with
                  facts := (branchStart text context scan "if").2} valid base branches.2 environment
              apply bodyTokens_flowReady
              exact ScalarMetadata.FlowReady.join_context base yes no
          · exact invalidBody_flowReady ready
      · exact invalidBody_flowReady ready
  termination_by (bodyRemaining text scan, 1)

  theorem alternativeBody_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
      (valid : FunctionBindings.ValidMetadata text catalog)
      (procedureValid : ProcedureBindings.ValidMetadata text procedures)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (ready : scan.FlowReady context)
      (environment : ScalarExpression.ValidEnvironment text context.scalarNames) :
      (alternativeBody (catalog := catalog) (procedures := procedures) text context scan).FlowReady context := by
    rw [alternativeBody]
    split
    · exact invalidBody_flowReady ready
    · split
      · try dsimp only
        split
        · exact invalidBody_flowReady ready
        · split
          · split
            · exact invalidBody_flowReady ready
            · split
              · have branches := branchStart_flowReady text context scan "elsif" base ready
                have yes := readBody_flowReady (procedureValid := procedureValid) text context (branchStart text context scan "elsif").1 .arm
                  valid base branches.1 environment
                have no := alternativeBody_flowReady (procedureValid := procedureValid) text context
                  {readBody (catalog := catalog) (procedures := procedures) text context (branchStart text context scan "elsif").1 .arm with
                    facts := (branchStart text context scan "elsif").2} valid base branches.2 environment
                exact ScalarMetadata.FlowReady.join_context base yes no
              · exact invalidBody_flowReady ready
          · exact invalidBody_flowReady ready
      · split
        · try dsimp only
          split
          · exact invalidBody_flowReady ready
          · split
            · exact readBody_flowReady (procedureValid := procedureValid) text context _ .endOnly valid base ready environment
            · exact invalidBody_flowReady ready
        · split
          · exact ready
          · exact invalidBody_flowReady ready
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_flowReady (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (valid : FunctionBindings.ValidMetadata text catalog)
      (procedureValid : ProcedureBindings.ValidMetadata text procedures)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (ready : scan.FlowReady context)
      (environment : ScalarExpression.ValidEnvironment text context.scalarNames) :
      (bodyTail (catalog := catalog) (procedures := procedures) text context scan stop).FlowReady context := by
    rw [bodyTail]
    split
    · exact invalidBody_flowReady ready
    · split
      · exact ready
      · try dsimp only
        split
        · exact invalidBody_flowReady (statementBody_flowReady (procedureValid := procedureValid) text context scan valid base ready environment)
        · split
          · exact bodyTail_flowReady (procedureValid := procedureValid) text context _ stop valid base
              (statementBody_flowReady (procedureValid := procedureValid) text context scan valid base ready environment) environment
          · exact invalidBody_flowReady (statementBody_flowReady (procedureValid := procedureValid) text context scan valid base ready environment)
  termination_by (bodyRemaining text scan, 3)

  theorem readBody_flowReady (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (valid : FunctionBindings.ValidMetadata text catalog)
      (procedureValid : ProcedureBindings.ValidMetadata text procedures)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (ready : scan.FlowReady context)
      (environment : ScalarExpression.ValidEnvironment text context.scalarNames) :
      (readBody (catalog := catalog) (procedures := procedures) text context scan stop).FlowReady context := by
    rw [readBody]
    try dsimp only
    split
    · exact invalidBody_flowReady (statementBody_flowReady (procedureValid := procedureValid) text context scan valid base ready environment)
    · split
      · exact bodyTail_flowReady (procedureValid := procedureValid) text context _ stop valid base
          (statementBody_flowReady (procedureValid := procedureValid) text context scan valid base ready environment) environment
      · exact invalidBody_flowReady (statementBody_flowReady (procedureValid := procedureValid) text context scan valid base ready environment)
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
