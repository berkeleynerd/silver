module

public import Silver.ApplicationPackageBodyTotal

@[expose] public section

namespace Silver.ApplicationAdmission
open Compose ApplicationUnits ApplicationPackageBodies
open ApplicationPackageDeclarations (readSpecification)

/-- The wrapper selects the original package specification and body readers;
the input, budget, Main and statement callees retain their native interfaces. -/
def packageReaders (reader : BooleanElaboration.Native.Reader) (completion : CompletionCalls) (calls : Calls) : Calls :=
  {calls with packageSpecification := readSpecification reader, packageBody := readBody reader completion}

structure ParsedPackage (reader : BooleanElaboration.Native.Reader) (completion : CompletionCalls) (calls : Calls)
    (sources : Bundle) (result : AnalysisResult) where
  specification : SpecificationResult
  body : BodyResult
  specified : readSpecification reader (sources.prefix .packageSpecification) {units := sources.units} = specification
  specificationAccepted : specification.exports.position ≠ 0
  parsed : readBody reader completion (sources.prefix .packageBody) specification.exports specification.info = body
  bodyAccepted : body.accepted = true
  history : BodyHistory reader completion sources specification body
  complete : PackageBindings.completeMetadata ⟨1, sources.pool.take sources.used⟩ body.info = true
  main : calls.packageMain sources specification.exports body.info = result

theorem AcceptedTrace.package_history {reader : BooleanElaboration.Native.Reader} {completion : CompletionCalls}
    {calls : Calls} {sources : Bundle} {result : AnalysisResult}
    (representable : sources.Representable)
    (trace : AcceptedTrace (packageReaders reader completion calls) sources result) :
    Nonempty (ParsedPackage reader completion calls sources result) := by
  obtain ⟨specification, body, specified, specAccepted, _, parsed, bodyAccepted, complete, _, main, _⟩ := trace.readers
  have specificationRead : readSpecification reader (sources.prefix .packageSpecification) {units := sources.units} =
      specification := specified
  have bodyRead : readBody reader completion (sources.prefix .packageBody) specification.exports specification.info =
      body := parsed
  have evaluated := (readBody_eq reader completion (sources.prefix .packageBody) specification.exports specification.info).trans
    (congrArg some bodyRead)
  obtain ⟨history⟩ := original_body_history reader completion sources ⟨representable, trace.layout⟩
    specificationRead specAccepted evaluated bodyAccepted
  exact ⟨⟨specification, body, specificationRead, specAccepted, bodyRead, bodyAccepted, history, complete, main⟩⟩

theorem analyzed_package_history (reader : BooleanElaboration.Native.Reader) (completion : CompletionCalls)
    (calls : Calls) (sources : Bundle) (representable : sources.Representable)
    (accepted : (analyzeApplication (packageReaders reader completion calls) sources).accepted = true) :
    Nonempty (ParsedPackage reader completion calls sources (analyzeApplication (packageReaders reader completion calls) sources)) :=
  (analyzeApplication_trace accepted).package_history representable

end Silver.ApplicationAdmission
