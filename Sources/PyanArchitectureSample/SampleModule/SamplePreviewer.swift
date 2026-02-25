//
//  SamplePreviewer.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

#if DEBUG

import SwiftUI
import PyanArchitecture

@MainActor
struct SamplePreviewer: @MainActor Previewer {
	let builder: SampleBuilder
	let container: Container

	init() {
		self.builder = SampleBuilder(
			container: previewContainer,
			rootProperties: .init(title: "Preview")
		)
		self.container = previewContainer
	}
}

#Preview {
	SamplePreviewer()
		.previewModule()
}

#endif
