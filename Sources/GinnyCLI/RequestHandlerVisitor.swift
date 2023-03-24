//
//  RequestHandlerVisitor.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import SwiftSyntax

/// Visitor for finding `RequestHandler` and `AsyncRequestHandler` classes.
final class RequestHandlerVisitor: SyntaxVisitor {
  /// An array of identifiers for `RequestHandler` and `AsyncRequestHandler` classes.
  var identifiers: [String] = []

  override func visit(_ node: TypeInheritanceClauseSyntax) -> SyntaxVisitorContinueKind {
    guard
      node.isRequestHandler,
      let parent = node.parent,
      let identifier = parent.classOrStructIdentifier
    else {
      return .skipChildren
    }
    identifiers.append(identifier)
    return .skipChildren
  }
}

// MARK: - Syntax

extension Syntax {

  /// Returns the identifier of a `ClassDeclSyntax` or `StructDeclSyntax` if it exists.
  var classOrStructIdentifier: String? {
    let tokenSyntax: TokenSyntax
    if let asClass = self.as(ClassDeclSyntax.self) {
      tokenSyntax = asClass.identifier
    } else if let asStruct = self.as(StructDeclSyntax.self) {
      tokenSyntax = asStruct.identifier
    } else {
      return nil
    }
    return tokenSyntax.text
  }
}

// MARK: - TypeInheritanceClauseSyntax

extension TypeInheritanceClauseSyntax {

  /// Returns `true` if the `TypeInheritanceClauseSyntax` is a `RequestHandler` or `AsyncRequestHandler`.
  var isRequestHandler: Bool {
    inheritedTypeCollection.contains { node in
      let typeNameText = SimpleTypeIdentifierSyntax(node.typeName)?.name.text
      return typeNameText == "AsyncRequestHandler" || typeNameText == "RequestHandler"
    }
  }
}
