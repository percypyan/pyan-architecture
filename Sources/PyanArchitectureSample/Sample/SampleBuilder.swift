//
//  ShowcaseBuilder.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI
import PyanArchitecture

@MainActor
struct SampleBuilder: @MainActor ModuleBuilder {
	let container: Container
	let rootScreen: SampleScreen

	init(container: Container, rootProperties: ShowcaseProperties) {
		self.container = container
		self.rootScreen = .showcase(title: rootProperties.title)
	}

	func build(screen: SampleScreen, with router: any AssociatedRouter) -> any View {
		return switch screen {
		case .showcase(let title), .showcaseCover(let title), .showcaseSheet(let title):
			ShowcaseScreen(presenter: .init(
				properties: .init(title: title),
				router: router,
				sampleGeneratorService: <~container
			))
		}
	}

	func build(modal: SampleModal) -> any Modal {
		return switch modal {
		case .showcaseModal: ShowcaseModal()
		}
	}
}
