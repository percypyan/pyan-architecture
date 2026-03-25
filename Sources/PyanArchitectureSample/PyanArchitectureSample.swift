//
//  Sample.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI
import PyanArchitecture

@MainActor
let productionContainer = {
	Container(overridableDependencies: true)
		.register(SampleGeneratorService.self, factory: { _ in
			MockSampleGeneratorService(integer: 10)
		})
}()

@MainActor
let previewContainer = {
	Container(overridableDependencies: true)
		.register(SampleGeneratorService.self, factory: { _ in
			MockSampleGeneratorService(integer: 10)
		})
}()

#Preview {
	SampleBuilder(
		container: previewContainer,
		rootProperties: .init(title: "Title")
	)
}

#Preview {
	SamplePreviewer()
		.previewModule()
}
