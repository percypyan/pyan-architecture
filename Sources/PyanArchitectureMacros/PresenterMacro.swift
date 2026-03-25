//
//  PresenterMacro.swift
//  PyanArchitecture
//
//  Created by Claude on 22/03/2026.
//

#if os(macOS)

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct PresenterMacro {}

// MARK: - MemberMacro

extension PresenterMacro: MemberMacro {
	public static func expansion(
		of node: AttributeSyntax,
		providingMembersOf declaration: some DeclGroupSyntax,
		conformingTo protocols: [TypeSyntax],
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		guard declaration.is(ClassDeclSyntax.self) else {
			context.diagnose(Diagnostic(
				node: node,
				message: PresenterDiagnostic.requiresClass
			))
			return []
		}

		return [
			"""
			@ObservationIgnored
			var _changeMonitoringRegistry: [String: any Equatable] = [:]
			""",
		]
	}
}

// MARK: - ExtensionMacro

extension PresenterMacro: ExtensionMacro {
	public static func expansion(
		of node: AttributeSyntax,
		attachedTo declaration: some DeclGroupSyntax,
		providingExtensionsOf type: some TypeSyntaxProtocol,
		conformingTo protocols: [TypeSyntax],
		in context: some MacroExpansionContext
	) throws -> [ExtensionDeclSyntax] {
		var extensions: [ExtensionDeclSyntax] = []

		if protocols.contains(where: { $0.trimmedDescription == "Presenter" }) {
			let ext: DeclSyntax =
				"""
				extension \(type.trimmed): @MainActor Presenter {}
				"""
			if let extensionDecl = ext.as(ExtensionDeclSyntax.self) {
				extensions.append(extensionDecl)
			}
		}

		return extensions
	}
}

// MARK: - Diagnostics

enum PresenterDiagnostic: String, DiagnosticMessage {
	case requiresClass

	var severity: DiagnosticSeverity { .error }

	var message: String {
		switch self {
		case .requiresClass:
			return "@Presenter can only be applied to a class declaration"
		}
	}

	var diagnosticID: MessageID {
		MessageID(domain: "PyanArchitectureMacros", id: rawValue)
	}
}

#endif
