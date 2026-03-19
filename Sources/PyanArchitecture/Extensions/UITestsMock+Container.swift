//
//  UITestsMock+Container.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 19/03/2026.
//

import Foundation

public extension UITestsMock {
	/// Registers this mock as a singleton in the given dependency injection container if its environment variable is set.
	///
	/// Call this method during app setup to conditionally replace a production service with
	/// a mock configured through the process environment. If the environment variable
	/// associated with ``UITestsMock/id`` is **not** present, the method returns immediately
	/// without modifying the container.
	///
	/// - Parameters:
	///   - type: The service protocol type to register the mock as (e.g. `SomeService.self`).
	///   - container: The ``Container`` in which the mock should be registered as a singleton.
	@MainActor
	static func register<T>(as type: T.Type, in container: Container) {
		guard ProcessInfo.processInfo.environment[id.environmentKey] != nil else { return }
		container.registerSingleton(type: type, Self.fromEnvironment() as! T)
	}
}
