//
//  MacroExpansionTests.swift
//  PyanArchitectureTests
//
//  Created by Claude on 22/03/2026.
//

#if os(macOS)

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing
@testable import PyanArchitectureMacros

let testMacros: [String: Macro.Type] = [
	"Presenter": PresenterMacro.self,
	"MonitorChange": MonitorChangeMacro.self,
	"value": ValueMacro.self,
]

// MARK: - @Presenter Tests

@Suite("@Presenter Macro")
struct PresenterMacroTests {

	@Test("adds _changeMonitoringRegistry and Presenter conformance")
	func memberExpansion() {
		assertMacroExpansion(
			"""
			@Presenter
			final class MyPresenter {
				var name: String = ""
				let router: Router
			}
			""",
			expandedSource: """
			final class MyPresenter {
				var name: String = ""
				let router: Router

				@ObservationIgnored
				var _changeMonitoringRegistry: [String: any Equatable] = [:]
			}

			extension MyPresenter: Presenter {
			}
			""",
			macros: testMacros
		)
	}

	@Test("emits error when applied to a struct")
	func errorOnStruct() {
		assertMacroExpansion(
			"""
			@Presenter
			struct NotAClass {}
			""",
			expandedSource: """
			struct NotAClass {}
			""",
			diagnostics: [
				DiagnosticSpec(
					message: "@Presenter can only be applied to a class declaration",
					line: 1,
					column: 1
				)
			],
			macros: testMacros
		)
	}

	@Test("works on empty class")
	func emptyClass() {
		assertMacroExpansion(
			"""
			@Presenter
			final class MyPresenter {
			}
			""",
			expandedSource: """
			final class MyPresenter {

				@ObservationIgnored
				var _changeMonitoringRegistry: [String: any Equatable] = [:]
			}

			extension MyPresenter: Presenter {
			}
			""",
			macros: testMacros
		)
	}
}

// MARK: - #MonitorChange Tests

@Suite("#MonitorChange Macro")
struct MonitorChangeMacroTests {

	@Test("expands with initial: true")
	func initialTrue() {
		assertMacroExpansion(
			"""
			#MonitorChange(of: service.text, initial: true) { previous, current in
				print(current)
			}
			""",
			expandedSource: """
			{
				if !self._changeMonitoringRegistry.keys.contains("\\("unknown"):0:0") {
					self._monitorChange(
						of: self.service.text,
						id: "\\("unknown"):0:0",
						initial: true,
						perform: { previous, current in
							print(current)
						}
					)
				}
			}()
			""",
			macros: testMacros
		)
	}

	@Test("expands with initial: false")
	func initialFalse() {
		assertMacroExpansion(
			"""
			#MonitorChange(of: service.count, initial: false) { previous, current in
				print(current)
			}
			""",
			expandedSource: """
			{
				if !self._changeMonitoringRegistry.keys.contains("\\("unknown"):0:0") {
					self._monitorChange(
						of: self.service.count,
						id: "\\("unknown"):0:0",
						initial: false,
						perform: { previous, current in
							print(current)
						}
					)
				}
			}()
			""",
			macros: testMacros
		)
	}

	@Test("emits error when of: argument is missing")
	func missingOfArgument() {
		assertMacroExpansion(
			"""
			#MonitorChange(initial: true) { _, _ in }
			""",
			expandedSource: """
			() as Void
			""",
			diagnostics: [
				DiagnosticSpec(
					message: "#MonitorChange requires an 'of:' argument",
					line: 1,
					column: 1
				)
			],
			macros: testMacros
		)
	}

	@Test("emits error when initial: is not a boolean literal")
	func initialNotLiteral() {
		assertMacroExpansion(
			"""
			#MonitorChange(of: service.text, initial: someVariable) { _, _ in }
			""",
			expandedSource: """
			() as Void
			""",
			diagnostics: [
				DiagnosticSpec(
					message: "'initial' must be a boolean literal (true or false)",
					line: 1,
					column: 43
				)
			],
			macros: testMacros
		)
	}

	@Test("emits error when trailing closure is missing")
	func missingClosure() {
		assertMacroExpansion(
			"""
			#MonitorChange(of: service.text, initial: true)
			""",
			expandedSource: """
			() as Void
			""",
			diagnostics: [
				DiagnosticSpec(
					message: "#MonitorChange requires a trailing closure",
					line: 1,
					column: 1
				)
			],
			macros: testMacros
		)
	}
}

// MARK: - #value Tests

@Suite("#value Macro")
struct ValueMacroTests {

	@Test("expands with DEBUG flag and integer values")
	func debugFlagIntegers() {
		assertMacroExpansion(
			"""
			let number = #value(10, withAlternative: 100, for: "DEBUG")
			""",
			expandedSource: """
			let number = {
				#if DEBUG
					return 100
				#else
					return 10
				#endif
			}()
			""",
			macros: testMacros
		)
	}

	@Test("expands with DEBUG flag and floating point values")
	func debugFlagFloats() {
		assertMacroExpansion(
			"""
			let number = #value(10.25, withAlternative: 100, for: "DEBUG")
			""",
			expandedSource: """
			let number = {
				#if DEBUG
					return 100
				#else
					return 10.25
				#endif
			}()
			""",
			macros: testMacros
		)
	}

	@Test("expands with MOCK flag and string values")
	func mockFlagStrings() {
		assertMacroExpansion(
			"""
			let str = #value("str", withAlternative: "it's mock!", for: "MOCK")
			""",
			expandedSource: """
			let str = {
				#if MOCK
					return "it's mock!"
				#else
					return "str"
				#endif
			}()
			""",
			macros: testMacros
		)
	}

	@Test("emits error when release value is missing")
	func missingReleaseValue() {
		assertMacroExpansion(
			"""
			#value(withAlternative: 100, for: "DEBUG")
			""",
			expandedSource: """
			() as Never
			""",
			diagnostics: [
				DiagnosticSpec(
					message: "#value requires a release value as the first argument",
					line: 1,
					column: 1
				)
			],
			macros: testMacros
		)
	}

	@Test("emits error when withAlternative is missing")
	func missingAlternative() {
		assertMacroExpansion(
			"""
			#value(10, for: "DEBUG")
			""",
			expandedSource: """
			() as Never
			""",
			diagnostics: [
				DiagnosticSpec(
					message: "#value requires a 'withAlternative:' argument",
					line: 1,
					column: 1
				)
			],
			macros: testMacros
		)
	}

	@Test("emits error when for flag is missing")
	func missingFlag() {
		assertMacroExpansion(
			"""
			#value(10, withAlternative: 100)
			""",
			expandedSource: """
			() as Never
			""",
			diagnostics: [
				DiagnosticSpec(
					message: "#value requires a 'for:' argument specifying a compilation flag",
					line: 1,
					column: 1
				)
			],
			macros: testMacros
		)
	}

	@Test("emits error when for flag is not a string literal")
	func flagNotStringLiteral() {
		assertMacroExpansion(
			"""
			#value(10, withAlternative: 100, for: someVariable)
			""",
			expandedSource: """
			() as Never
			""",
			diagnostics: [
				DiagnosticSpec(
					message: "'for' must be a string literal (e.g., \"DEBUG\")",
					line: 1,
					column: 38
				)
			],
			macros: testMacros
		)
	}
}

#endif
