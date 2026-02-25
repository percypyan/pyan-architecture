//
//  Sample.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI
import PyanArchitecture

@MainActor
let previewContainer = {
	Container(overridableDependencies: true)
		.register(SampleGeneratorService.self, factory: { _ in
			MockSampleGeneratorService(integer: 10)
		})
}()

#Preview {
	SamplePreviewer()
		.previewModule()
}
