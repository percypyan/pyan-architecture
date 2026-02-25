//
//  ProductionSampleService.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import Foundation
import Observation

@Observable
final class ProductionSampleGeneratorService: SampleGeneratorService {
	func generateInteger() -> Int {
		return Int.random(in: 1...100)
	}
}
