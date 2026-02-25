//
//  TestFixtures.swift
//  PyanArchitectureTests
//
//  Created by Claude on 07/03/2026.
//

import SwiftUI
@testable import PyanArchitecture

// MARK: - Test Screen & Modal

enum TestScreen: @MainActor BuildableScreen {
	case home
	case detail
	case sheetScreen

	var segue: Segue {
		switch self {
		case .sheetScreen: .sheet
		default: .push
		}
	}
}

enum TestModal: @MainActor BuildableModal {
	case confirmation
}

// MARK: - Test Builder

@MainActor
struct TestBuilder: @MainActor ModuleBuilder {
	let container: Container
	let rootScreen: TestScreen = .home

	func build(screen: TestScreen, with router: any AssociatedRouter) -> any View {
		Text(verbatim: "Screen: \(screen)")
	}

	func build(modal: TestModal) -> any Modal {
		TestModalView()
	}
}

struct TestModalView: Modal {
	let transition: AnyTransition = .opacity
	let animation: Animation = .default

	var content: some View {
		Text("Modal")
	}
}

// MARK: - Sub Module Builder

@MainActor
struct SubTestBuilder: @MainActor ModuleBuilder {
	let container: Container
	let rootScreen: TestScreen = .home
	let onDismiss: () -> Void

	func build(screen: TestScreen, with router: any AssociatedRouter) -> any View {
		Text("SubModule")
	}

	func build(modal: TestModal) -> any Modal {
		TestModalView()
	}
}
