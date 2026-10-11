import Silver.OutputLexicalBodyCertificate
import Silver.OutputLexicalSpecCertificate
import Silver.AuthoritativeSource
import Silver.ProfileSpecCertificate
import Silver.ProfileBodyCertificate
import Silver.OutputSpecCertificate
import Silver.OutputBodyCertificate
import Silver.IOSpecCertificate
import Silver.IOBodyCertificate
import Silver.OutputLibcCertificate
import Silver.ArgumentsSpecCertificate
import Silver.ArgumentsBodyCertificate
import Silver.RuntimeSpecCertificate

/-! Independent source certificates share the checked lexer and handwritten
authoritative bindings. Lake can check the source files concurrently; every
line, complete reconstruction and original byte remains kernel checked. -/
