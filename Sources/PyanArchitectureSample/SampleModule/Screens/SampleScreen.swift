//
//  SampleScreen.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI
import PyanArchitecture

enum SampleScreen: @MainActor BuildableScreen {
	case showcase(title: String = "Segue")
	case showcaseCover(title: String = "Cover")
	case showcaseSheet(title: String = "Sheet")

	var segue: Segue {
		return switch self {
		case .showcaseCover: .fullScreenCover
		case .showcaseSheet: .sheet
		default: .push
		}
	}
}
