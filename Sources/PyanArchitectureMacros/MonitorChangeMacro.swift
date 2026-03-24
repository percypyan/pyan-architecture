//
//  MonitorChangeMacro.swift
//  PyanArchitecture
//
//  Created by Claude on 22/03/2026.
//

#if os(macOS)

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct MonitorChangeMacro: ExpressionMacro {
	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> ExprSyntax {
		let arguments = node.arguments

		// Extract `of:` argument
		guard let ofArg = arguments.first, ofArg.label?.text == "of" else {
			context.diagnose(Diagnostic(
				node: Syntax(node),
				message: MonitorChangeDiagnostic.missingOfArgument
			))
			return "() as Void"
		}
		let observedExpression = ofArg.expression

		// Extract `initial:` argument (optional, defaults to `false`)
		let initialExpression = arguments
			.first(where: { $0.label?.text == "initial" })?
			.expression
			?? ExprSyntax(BooleanLiteralExprSyntax(booleanLiteral: false))

		// Validate initial is a boolean literal
		guard let boolLiteral = initialExpression.as(BooleanLiteralExprSyntax.self),
			  boolLiteral.literal.tokenKind == .keyword(.true) ||
			  boolLiteral.literal.tokenKind == .keyword(.false)
		else {
			context.diagnose(Diagnostic(
				node: Syntax(initialExpression),
				message: MonitorChangeDiagnostic.initialMustBeLiteral
			))
			return "() as Void"
		}

		// Extract the trailing closure
		guard let closure = node.trailingClosure else {
			context.diagnose(Diagnostic(
				node: Syntax(node),
				message: MonitorChangeDiagnostic.missingPerformClosure
			))
			return "() as Void"
		}

		// Use source location as stable identifier for the registration
		let location = context.location(of: node, at: .afterLeadingTrivia, filePathMode: .filePath)
		let file = location?.file ?? ExprSyntax(StringLiteralExprSyntax(content: "unknown"))
		let line = location?.line ?? ExprSyntax(IntegerLiteralExprSyntax(literal: .integerLiteral("0")))
		let column = location?.column ?? ExprSyntax(IntegerLiteralExprSyntax(literal: .integerLiteral("0")))

		let id: ExprSyntax = """
		"\\(\(file)):\\(\(line)):\\(\(column))"
		"""

		return """
		{
			if !self._changeMonitoringRegistry.keys.contains(\(id)) {
				self._monitorChange(
					of: self.\(observedExpression),
					id: \(id),
					runClosure: \(initialExpression),
					perform: \(closure)
				)
			}
		}()
		"""
	}
}

// MARK: - Diagnostics

enum MonitorChangeDiagnostic: String, DiagnosticMessage {
	case missingOfArgument
	case missingInitialArgument
	case initialMustBeLiteral
	case missingPerformClosure

	var severity: DiagnosticSeverity { .error }

	var message: String {
		switch self {
		case .missingOfArgument:
			return "#MonitorChange requires an 'of:' argument"
		case .missingInitialArgument:
			return "#MonitorChange requires an 'initial:' argument"
		case .initialMustBeLiteral:
			return "'initial' must be a boolean literal (true or false)"
		case .missingPerformClosure:
			return "#MonitorChange requires a trailing closure"
		}
	}

	var diagnosticID: MessageID {
		MessageID(domain: "PyanArchitectureMacros", id: rawValue)
	}
}

#endif
