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

	private(set) var counter: Int
	private(set) var counterString: String = "Not set"

	private(set) var counter2: Int {
		didSet { counter2String = "\(counter2)^2 = \(counter2 * counter2)" }
	}
	private(set) var counter2String: String = "Not set"

	init(
		properties: ShowcaseProperties,
		router: any SampleBuilder.AssociatedRouter,
		sampleGeneratorService: SampleGeneratorService
	) {
		self.properties = properties
		self.router = router
		self.sampleGeneratorService = sampleGeneratorService
		self.counter = 0
		self.counter2 = 0
		withObservationTracking {
			self.counterString = "\(self.counter)^2 = \(self.counter * self.counter)"
		}
	}

	func counterIncrementAction() {
		counter += 1
	}

	func counter2IncrementAction() {
		counter2 += 1
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
