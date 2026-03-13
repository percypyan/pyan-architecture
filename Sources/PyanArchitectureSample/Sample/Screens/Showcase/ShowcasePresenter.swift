//
//  ShowcasePresenter.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 04/02/2026.
//

import SwiftUI
import PyanArchitecture

struct ShowcaseProperties {
	let title: String
}

@MainActor
@Observable
final class ShowcasePresenter: @MainActor Presenter {
	let properties: ShowcaseProperties
	let router: any SampleBuilder.AssociatedRouter

	let sampleGeneratorService: SampleGeneratorService

	var title: String {
		return "\(properties.title) #\(sampleGeneratorService.generateInteger())"
	}

	init(
		properties: ShowcaseProperties,
		router: any SampleBuilder.AssociatedRouter,
		sampleGeneratorService: SampleGeneratorService
	) {
		self.properties = properties
		self.router = router
		self.sampleGeneratorService = sampleGeneratorService
	}

	func pushAction() {
		router.navigate(to: .showcase(title: "Push showcase"))
	}

	func fullScreenCoverAction() {
		router.navigate(to: .showcaseCover(title: "Cover showcase"))
	}

	func sheetAction() {
		router.navigate(to: .showcaseSheet(title: "Sheet showcase"))
	}

	func dismissAction() {
		router.dismissScreen()
	}

	func modalAction() {
		router.present(.showcaseModal)
	}

	func dismissFullScreenCoverAction() {
		router.dismissFullScreenCover()
	}

	func dismissSheetAction() {
		router.dismissSheet()
	}

	func dismissAllAction() {
		router.dismissAll()
	}
}
