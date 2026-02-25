//
//  MockSampleGeneratorService.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

#if DEBUG

import Foundation
import Observation

@Observable
final class MockSampleGeneratorService: SampleGeneratorService {
	let integer: Int

	init(integer: Int) {
		self.integer = integer
	}

	func generateInteger() -> Int {
		return integer
	}
}

#endif
