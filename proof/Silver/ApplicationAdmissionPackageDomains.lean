module

public import Silver.ApplicationAdmissionPackageComposition
public import Silver.ApplicationPackageAdmissionHistory

@[expose] public section

namespace Silver.ApplicationAdmission
open Compose Compose.Expressions ApplicationUnits ApplicationPackageDeclarations
open ApplicationPackageBodies

/-- The accepted original wrapper supplies the complete domains needed by its
source decoders. The only external input restriction is native Bundle storage;
layout, reader success, original unit identity and parser/metadata types are all
conclusions of the actual guard and declaration histories. -/
theorem package_domains (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (main : ApplicationPackageMain.BodyLibraries)
    (mainOther : ApplicationPackageMain.Calls) (other : Calls) (sources : Bundle)
    (represented : sources.Representable)
    (accepted : (analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources).accepted = true) :
    ∃ parsed : ParsedPackage reader
        (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
        (packageCalls library reader (main.calls mainOther) other) sources
        (analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources),
      sources.Valid ∧
      ReaderFrame (sources.prefix .packageBody) parsed.specification.exports ∧
      ReaderFrame (ApplicationPackageMain.textOf sources) parsed.specification.exports ∧
      parsed.body.info.Typed ∧ parsed.body.info.units = sources.units ∧
      (ApplicationPackageMain.packageMainAt (main.calls mainOther) sources
        parsed.specification.exports parsed.body.info).accepted = true := by
  have trace := analyzeApplication_trace accepted
  obtain ⟨specification, body, specificationRead, specificationAccepted, bodyState,
    bodyRead, bodyAccepted, complete, mainState, mainRead, _finalValid⟩ := trace.readers
  have valid : sources.Valid := ⟨represented, trace.layout⟩
  have specificationEq : readSpecification reader (sources.prefix .packageSpecification)
      {units := sources.units} = specification := specificationRead
  have bodyEq : readBody reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
      (sources.prefix .packageBody) specification.exports specification.info = body := bodyRead
  have specificationTyped := readSpecification_typed reader
    (specification_prefix_valid sources valid .packageSpecification) {units := sources.units}
    (specification_seed_typed sources represented)
  rw [specificationEq] at specificationTyped
  have bodyFramed : ReaderFrame (sources.prefix .packageBody) specification.exports :=
    ⟨specificationTyped.2.typed, bodyState⟩
  have mainFramed : ReaderFrame (ApplicationPackageMain.textOf sources) specification.exports :=
    ⟨specificationTyped.2.typed, mainState⟩
  have bodyTyped : body.info.Typed := by
    have checked := readBody_accepted_typed library reader
      (specification_prefix_valid sources valid .packageBody) specification.exports bodyFramed
      specification.info specificationTyped.1 (by rwa [bodyEq])
    rwa [bodyEq] at checked
  have mainEq : ApplicationPackageMain.packageMainAt (main.calls mainOther) sources
      specification.exports body.info =
      analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources := mainRead
  have mainAccepted : (ApplicationPackageMain.packageMainAt (main.calls mainOther) sources
      specification.exports body.info).accepted = true := by rwa [mainEq]
  have units := (analyzeApplication_post represented accepted).2.1
  have tables := (ApplicationPackageMain.packageMainAt_tables mainAccepted).1
  rw [mainEq] at tables
  rw [tables] at units
  obtain ⟨history⟩ := original_body_history reader
    (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)) sources valid
    specificationEq specificationAccepted
    ((readBody_eq reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
      (sources.prefix .packageBody) specification.exports specification.info).trans (congrArg some bodyEq))
    bodyAccepted
  let parsed : ParsedPackage reader
      (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
      (packageCalls library reader (main.calls mainOther) other) sources
      (analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources) :=
    ⟨specification, body, specificationEq, specificationAccepted, bodyEq, bodyAccepted,
      history, complete, mainRead⟩
  exact ⟨parsed, valid, bodyFramed, mainFramed, bodyTyped, units, mainAccepted⟩

end Silver.ApplicationAdmission
