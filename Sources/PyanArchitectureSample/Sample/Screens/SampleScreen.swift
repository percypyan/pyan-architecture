//
//  SampleScreen.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI
import PyanArchitecture

enum SampleScreen: BuildableScreen {
	case showcase(title: String = "Segue")
	case showcaseCover(title: String = "Cover")
	case showcaseSheet(title: String = "Sheet")

	var segue: Segue {
		return switch self {
		#if os(macOS)
		case .showcaseCover: .sheet
		#else
		case .showcaseCover: .fullScreenCover
		#endif
		case .showcaseSheet: .sheet
		default: .push
		}
	}
}
