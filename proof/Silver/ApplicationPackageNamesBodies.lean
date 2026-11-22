module

public import Silver.ApplicationNativeCommands
public import Silver.ApplicationPackageNamesExpressions

@[expose] public section

namespace Silver.ApplicationPackageNames.Native
open ApplicationNative

/-- All ordinary helper locals are initialized constants. The shared scope
checker visits initializers before introducing each local name. -/
def constant (ty : Ty) (name : String) (typeName : List String) (initial : E ty) : Declaration Function :=
  ⟨ty, name, typeName, true, initial⟩

def packageWordBody : Body Function .number where
  name := "package_word"
  declarations :=
    [constant .number "first" ["literal_position"] (apply2 .skip text position),
     constant .number "after" ["literal_position"] (apply2 .nameAfter text first)]
  commands := .returned packageWordResult

def sparkPragmaBody : Body Function .number where
  name := "spark_pragma_after"
  declarations := []
  commands := .returned sparkPragmaResult

def packageTypeBody : Body Function .packageType where
  name := "package_type_at"
  declarations :=
    [constant .number "first" ["literal_position"] (apply2 .skip text position),
     constant .number "last" ["literal_position"] (apply2 .nameAfter text first),
     constant .functionType "value" ["function_type_result"] (apply3 .functionType text frame position),
     constant .number "export" ["packages", ".", "export_count_type"]
       (apply3 .lookupExport text info (.nameSpan first last))]
  commands := .choose typeRejected (.returned .invalidType)
    (.choose typeBoolean (.returned (typeResult .full .booleanType))
      (.choose typeInteger (.returned (typeResult (.field .typeBounds value) .integerType))
        (.choose typeExport
          (.returned (typeResult (.field .typeBounds value) (.add exportId (.number 1))))
          (.returned .invalidType))))

abbrev WellFormedBodies : Prop :=
  packageWordBody.wellFormed functionNames = true ∧ sparkPragmaBody.wellFormed functionNames = true ∧
    packageTypeBody.wellFormed functionNames = true

theorem checked_bodies : WellFormedBodies := by decide +kernel

abbrev WellScopedBodies : Prop :=
  packageWordBody.scoped [(.source,"text"),(.number,"position"),(.spelling,"word")] = true ∧
  sparkPragmaBody.scoped [(.source,"text"),(.number,"position")] = true ∧
  packageTypeBody.scoped [(.source,"text"),(.state,"frame"),(.metadata,"info"),(.number,"position")] = true

theorem checked_body_scopes : WellScopedBodies := by decide +kernel

end Silver.ApplicationPackageNames.Native
