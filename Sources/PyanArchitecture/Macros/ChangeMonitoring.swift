//
//  ChangeMonitoring.swift
//  pyan-architecture
//
//  Created by Perceval Archimbaud on 22/03/2026.
//

import Foundation

public extension Presenter {
	/// Compares the current value of an observed expression against its previously
	/// stored value in a registry and conditionally invokes a closure.
	///
	/// This is an implementation detail used by the ``MonitorChange(of:initial:perform:)`` macro expansion.
	/// > Warning: Do not call directly.
	@MainActor
	func _monitorChange<Value: Equatable>(
		of value: @MainActor @escaping @autoclosure () -> Value,
		id: String,
		runClosure: Bool,
		perform: @escaping @MainActor (_ previous: Value?, _ current: Value) -> Void
	) {
		nonisolated(unsafe) weak let weakSelf = self
		var current: Value!
		withObservationTracking {
			current = value()
		} onChange: {
			RunLoop.main.perform {
				MainActor.assumeIsolated {
					weakSelf?._monitorChange(of: value(), id: id, runClosure: true, perform: perform)
				}
			}
		}

		let previous = _changeMonitoringRegistry[id] as? Value
		_changeMonitoringRegistry[id] = current

		if runClosure {
			perform(previous, current)
		}
	}
}
