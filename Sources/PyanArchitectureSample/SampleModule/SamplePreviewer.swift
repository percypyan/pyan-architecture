//
//  SamplePreviewer.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

#if DEBUG

import SwiftUI
import PyanArchitecture

typealias SamplePreviewer = Previewer<SampleBuilder>

extension SamplePreviewer {
	init() {
		self.init(
			container: previewContainer,
			builder: .init(
				container: previewContainer,
				rootProperties: .init(title: "Hello World")
			)
		)
	}
}

#Preview {
	SamplePreviewer()
		.previewModule()
}

#endif
