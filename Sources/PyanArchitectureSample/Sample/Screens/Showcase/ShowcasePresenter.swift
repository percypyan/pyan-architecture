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
@Presenter
final class ShowcasePresenter {
	let properties: ShowcaseProperties
	let router: any SampleBuilder.AssociatedRouter

	let sampleGeneratorService: SampleGeneratorService

	var title: String {
		return "\(properties.title) #\(sampleGeneratorService.generateInteger())"
	}

	private(set) var counter: Int = 0 {
		didSet { didSetStr = updated(for: counter) }
	}

	private(set) var macroInitialTrueStr: String = "Not set"
	private(set) var macroInitialFalseStr: String = "Not set"
	private(set) var withObservationStr: String = "Not set"
	private(set) var didSetStr: String = "Not set"

	init(
		properties: ShowcaseProperties,
		router: any SampleBuilder.AssociatedRouter,
		sampleGeneratorService: SampleGeneratorService
	) {
		self.properties = properties
		self.router = router
		self.sampleGeneratorService = sampleGeneratorService

		#MonitorChange(of: counter, initial: true) { _, current in
			self.macroInitialTrueStr = self.updated(for: current)
		}
		#MonitorChange(of: counter) { _, current in
			self.macroInitialFalseStr = self.updated(for: current)
		}
		withObservationTracking {
			self.withObservationStr = self.updated(for: self.counter)
		}
	}

	func incrementAction() {
		counter += 1
	}

	func resetAction() {
		counter = 0

		// Since monitoring with macro or withObservationTracking method are async,
		// they will be triggered after the whole method end, and therefore override
		// the "Not set" value. In the other hand, the didSet occurs synchronously, so
		// setting it below will override the already updated value.
		macroInitialTrueStr = "Not set"
		macroInitialFalseStr = "Not set"
		withObservationStr = "Not set"
		didSetStr = "Not set"
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
		#if os(macOS)
		router.dismissSheet()
		#else
		router.dismissFullScreenCover()
		#endif
	}

	func dismissSheetAction() {
		router.dismissSheet()
	}

	func dismissAllAction() {
		router.dismissAll()
	}

	private func updated(for counter: Int) -> String {
		return "\(counter)^2 = \(counter * counter)"
	}
}
