//
//  ShowcaseScreen.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 05/02/2026.
//

import SwiftUI
import PyanArchitecture

// MARK: - Screen
// Contains only the View
//  - Only knows about a Presenter

struct ShowcaseScreen: @MainActor Screen {
	@State var presenter: ShowcasePresenter

    var screenBody: some View {
		List {
			seguesSection
			modalSection
			dismissSection
		}
		.navigationTitle(presenter.title)
    }

	var seguesSection: some View {
		Section {
			Button("Push", action: presenter.pushAction)
			Button("Full screen cover", action: presenter.fullScreenCoverAction)
			Button("Sheet", action: presenter.sheetAction)
			Button("Dismiss", action: presenter.dismissAction)
				.tint(.red)
		} header: {
			Text("Segues")
		}
	}

	var modalSection: some View {
		Section {
			Button("Present", action: presenter.modalAction)
		} header: {
			Text("Modal")
		}
	}

	var dismissSection: some View {
		Section {
			Button("Dismiss full screen cover", action: presenter.dismissFullScreenCoverAction)
				.tint(.red)
			Button("Dismiss sheet", action: presenter.dismissSheetAction)
				.tint(.red)
			Button("Dismiss all", action: presenter.dismissAllAction)
				.tint(.red)
		} header: {
			Text("Dismisses")
		}
	}
}

#Preview {
	SamplePreviewer()
		.register(SampleGeneratorService.self, factory: { _ in
			MockSampleGeneratorService(integer: 42)
		})
		.preview(screen: .showcase(title: "Showcase"))
}
