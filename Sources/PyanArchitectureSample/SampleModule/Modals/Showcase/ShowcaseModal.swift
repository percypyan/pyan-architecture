//
//  ShowcaseModal.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI
import PyanArchitecture

struct ShowcaseModal: Modal {
	let transition: AnyTransition = .move(edge: .leading)
	let animation: Animation = .bouncy

	var content: some View {
		VStack(spacing: 20) {
			Text("Showcase Modal")
				.font(.headline)
			Text("""
				`Previewer` automatically adds a button you can drag \
				around to show the modal again after you closed it.
				If you do not want this button, pass `nil` as `showButtonAlignment` value.
				""")
			.multilineTextAlignment(.center)
		}
		.padding()
		.background(.white)
		.clipShape(.rect(cornerRadius: 16))
		.padding()
	}
}

#Preview {
	SamplePreviewer()
		.preview(modal: .showcaseModal, over: .showcase(title: "Screen"), showButtonAlignment: .topTrailing)
}
