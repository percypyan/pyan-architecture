//
//  SampleGeneratorService.swift
//  PyanArchitectureSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import Foundation
import Observation

protocol SampleGeneratorService: AnyObject, Observable {
	func generateInteger() -> Int
}
