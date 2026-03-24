//
//  Plugin.swift
//  PyanArchitecture
//
//  Created by Claude on 22/03/2026.
//

#if os(macOS)

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct PyanArchitecturePlugin: CompilerPlugin {
	let providingMacros: [Macro.Type] = [
		PresenterMacro.self,
		MonitorChangeMacro.self,
		ValueMacro.self,
	]
}

#endif
