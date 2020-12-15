/** Provides classes for detecting generated code. */

import csharp
private import semmle.code.csharp.frameworks.system.codedom.Compiler

/** A source file that contains generated code. */
abstract class GeneratedCodeFile extends SourceFile { }

/** An auto-generated Designer file. */
class DesignerFile extends GeneratedCodeFile {
  DesignerFile() { this.getBaseName().toLowerCase().matches("%.designer.cs") }
}

/** An auto-generated SpecFlow feature file. */
class FeatureFile extends GeneratedCodeFile {
  FeatureFile() { this.getBaseName().toLowerCase().matches("%.feature.cs") }
}

/** An auto-generated XAML code file. */
class XamlFile extends GeneratedCodeFile {
  XamlFile() { this.getBaseName().matches("%.g.cs") }
}

/** An auto-generated XSD code file. */
class AutogenXsdFile extends GeneratedCodeFile {
  AutogenXsdFile() { this.getBaseName().matches("%.autogen.cs") }
}

/** An auto-generated CodeDOM file. */
class GeneratedAttributeFile extends GeneratedCodeFile {
  GeneratedAttributeFile() {
    exists(Attribute a | a.getType() instanceof SystemCodeDomCompilerGeneratedCodeAttributeClass |
      a.getFile() = this
    )
  }
}

/** A file auto-generated by `sgen.exe`. */
class GeneratedNamespaceFile extends GeneratedCodeFile {
  GeneratedNamespaceFile() {
    exists(Namespace n | n.getATypeDeclaration().getFile() = this |
      n.getQualifiedName() = "Microsoft.Xml.Serialization.GeneratedAssembly"
    )
  }
}

/** A file contining comments suggesting it contains generated code. */
class GeneratedCommentFile extends GeneratedCodeFile {
  GeneratedCommentFile() { this = any(GeneratedCodeComment c).getLocation().getFile() }
}

/** A comment line that indicates generated code. */
abstract class GeneratedCodeComment extends CommentLine { }

/**
 * A generic comment line that suggests that the file is generated.
 */
class GenericGeneratedCodeComment extends GeneratedCodeComment {
  GenericGeneratedCodeComment() {
    exists(string line, string entity, string was, string automatically | line = getText() |
      entity = "file|class|interface|art[ei]fact|module|script" and
      was = "was|is|has been" and
      automatically = "automatically |mechanically |auto[- ]?" and
      line.regexpMatch("(?i).*\\bThis (" + entity + ") (" + was + ") (" + automatically +
          ")?generated\\b.*")
    )
  }
}

/** A comment warning against modifications. */
class DontModifyMarkerComment extends GeneratedCodeComment {
  DontModifyMarkerComment() {
    exists(string line | line = getText() |
      line.regexpMatch("(?i).*\\bGenerated by\\b.*\\bDo not edit\\b.*") or
      line.regexpMatch("(?i).*\\bAny modifications to this file will be lost\\b.*")
    )
  }
}

/** Holds if `file` looks like it contains generated code. */
predicate isGeneratedCode(GeneratedCodeFile file) { any() }
