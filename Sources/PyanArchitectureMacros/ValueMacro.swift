//
//  ValueMacro.swift
//  PyanArchitecture
//
//  Created by Claude on 24/03/2026.
//

#if os(macOS)

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ValueMacro: ExpressionMacro {
	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> ExprSyntax {
		let arguments = node.arguments

		// Extract first (unlabeled) argument: releaseValue
		guard let releaseArg = arguments.first, releaseArg.label == nil else {
			context.diagnose(Diagnostic(
				node: Syntax(node),
				message: ValueDiagnostic.missingReleaseValue
			))
			return "() as Never"
		}
		let releaseValue = releaseArg.expression

		// Extract `withAlternative:` argument
		guard let altArg = arguments.first(where: { $0.label?.text == "withAlternative" }) else {
			context.diagnose(Diagnostic(
				node: Syntax(node),
				message: ValueDiagnostic.missingAlternativeValue
			))
			return "() as Never"
		}
		let altValue = altArg.expression

		// Extract `for:` argument (the compilation flag as a string literal)
		guard let flagArg = arguments.first(where: { $0.label?.text == "for" }) else {
			context.diagnose(Diagnostic(
				node: Syntax(node),
				message: ValueDiagnostic.missingFlag
			))
			return "() as Never"
		}

		guard let stringLiteral = flagArg.expression.as(StringLiteralExprSyntax.self),
			  stringLiteral.segments.count == 1,
			  let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
		else {
			context.diagnose(Diagnostic(
				node: Syntax(flagArg.expression),
				message: ValueDiagnostic.flagMustBeStringLiteral
			))
			return "() as Never"
		}
		let flag = segment.content

		return """
		{
			#if \(raw: flag.text)
				return \(altValue)
			#else
				return \(releaseValue)
			#endif
		}()
		"""
	}
}

// MARK: - Diagnostics

enum ValueDiagnostic: String, DiagnosticMessage {
	case missingReleaseValue
	case missingAlternativeValue
	case missingFlag
	case flagMustBeStringLiteral

	var severity: DiagnosticSeverity { .error }

	var message: String {
		switch self {
		case .missingReleaseValue:
			return "#value requires a release value as the first argument"
		case .missingAlternativeValue:
			return "#value requires a 'withAlternative:' argument"
		case .missingFlag:
			return "#value requires a 'for:' argument specifying a compilation flag"
		case .flagMustBeStringLiteral:
			return "'for' must be a string literal (e.g., \"DEBUG\")"
		}
	}

	var diagnosticID: MessageID {
		MessageID(domain: "PyanArchitectureMacros", id: rawValue)
	}
}

#endif
