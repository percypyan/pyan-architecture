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
		// Stored so the re-registration chain looks them up via `weakSelf` instead of capturing
		// `self` strongly — see `_cleanupChangeMonitoring`.
		let valueKey = "\(id).value"
		let valueClosure: @MainActor () -> Value
		if let stored = _changeMonitoringPerforms[valueKey] as? @MainActor () -> Value {
			valueClosure = stored
		} else {
			valueClosure = { value() }
			_changeMonitoringPerforms[valueKey] = valueClosure
		}
		_changeMonitoringPerforms[id] = perform

		nonisolated(unsafe) weak let weakSelf = self
		var current: Value!
		withObservationTracking {
			current = valueClosure()
		} onChange: {
			RunLoop.main.perform {
				MainActor.assumeIsolated {
					guard let self = weakSelf,
						  let storedValue = self._changeMonitoringPerforms[valueKey]
							as? @MainActor () -> Value,
						  let storedPerform = self._changeMonitoringPerforms[id]
							as? @MainActor (Value?, Value) -> Void
					else { return }
					self._monitorChange(of: storedValue(), id: id, runClosure: true, perform: storedPerform)
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
