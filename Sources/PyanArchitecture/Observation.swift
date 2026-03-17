//
//  Observer.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 17/03/2026.
//

import Foundation
import Observation

/// Continuously observes changes to `@Observable` properties accessed within the given closure.
///
/// Unlike Swift's built-in `withObservationTracking(_:onChange:)`, which fires its `onChange`
/// callback only once, this function automatically re-registers observation after each change,
/// creating a persistent observation loop that runs for the lifetime of the caller.
///
/// The `perform` closure is executed immediately and then re-executed every time an observed
/// property changes. Re-execution is scheduled on the main run loop to coalesce rapid changes.
///
/// - Parameter perform: A closure that reads one or more `@Observable` properties.
///   It is called immediately and again after each observed change.
///
/// ### Example
/// ```swift
/// withObservationTracking {
///     label.text = model.title
/// }
/// ```
@MainActor
public func withObservationTracking(perform: @MainActor @escaping () -> Void) {
	withObservationTracking {
		perform()
	} onChange: {
		RunLoop.main.perform {
			Task { await withObservationTracking(perform: perform) }
		}
	}
}
