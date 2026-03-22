//
//  ChangeMonitoringTests.swift
//  PyanArchitectureTests
//
//  Created by Claude on 22/03/2026.
//

import Testing
import SwiftUI
@testable import PyanArchitecture

// MARK: - Test Presenter for Change Monitoring

@MainActor
@Observable
@Presenter
final class ChangeMonitoringPresenter {
	typealias Builder = TestBuilder

	let router: any TestBuilder.AssociatedRouter

	let service = ObservableService()

	// Captured values for test assertions
	@ObservationIgnored
	var capturedPrevious: (any Sendable)?
	@ObservationIgnored
	var capturedCurrent: (any Sendable)?
	@ObservationIgnored
	var capturedOther: (any Sendable)?
	@ObservationIgnored
	var callCount: Int = 0

	init(router: any TestBuilder.AssociatedRouter) {
		self.router = router
	}

	func monitorTextInitialTrue() {
		#MonitorChange(of: service.text, initial: true) { previous, current in
			self.capturedPrevious = previous
			self.capturedCurrent = current
			self.callCount += 1
		}
	}

	func monitorTextInitialFalse() {
		// If initial is not specified, defaults to `false`
		#MonitorChange(of: service.text) { previous, current in
			self.capturedPrevious = previous
			self.capturedCurrent = current
			self.callCount += 1
		}
	}

	func monitorCountInitialTrue() {
		#MonitorChange(of: service.count, initial: true) { previous, current in
			self.capturedPrevious = previous
			self.capturedCurrent = current
			self.callCount += 1
		}
	}

	func monitorCountInitialFalse() {
		#MonitorChange(of: service.count, initial: false) { previous, current in
			self.capturedPrevious = previous
			self.capturedCurrent = current
			self.callCount += 1
		}
	}

	func monitorCountAndAccessText() {
		#MonitorChange(of: service.count, initial: true) { previous, current in
			self.capturedPrevious = previous
			self.capturedCurrent = current
			self.callCount += 1
			self.capturedOther = self.service.text
		}
	}
}

@Observable
final class ObservableService {
	var text: String = "initial"
	var count: Int = 0
}

// MARK: - Tests

@MainActor
@Suite("#MonitorChange")
struct ChangeMonitoringTests {

	// MARK: - initial: true

	@Test("initial: true calls perform on first invocation with nil previous")
	func initialTrueFirstCall() {
		let presenter = ChangeMonitoringPresenter(router: MockRouter<TestBuilder>())

		presenter.monitorTextInitialTrue()

		#expect(presenter.callCount == 1)
		#expect(presenter.capturedPrevious as? String == nil)
		#expect(presenter.capturedCurrent as? String == "initial")
	}

	@Test("subsequent calls with the same id are no-ops")
	func subsequentCallsAreNoOps() async {
		let presenter = ChangeMonitoringPresenter(router: MockRouter<TestBuilder>())

		// First call — registers and fires perform
		presenter.monitorTextInitialTrue()
		#expect(presenter.callCount == 1)

		// Initial call is synchronous - no yield needed

		// Change the value
		presenter.service.text = "updated"

		await Task.yield() // Callback is asynchronously called - yield to give it the chance to run

		#expect(presenter.capturedPrevious as? String == "initial")
		#expect(presenter.capturedCurrent as? String == "updated")
		#expect(presenter.callCount == 2)

		// Reset counters
		presenter.callCount = 0

		// Second call — already registered, should be a no-op
		presenter.monitorTextInitialTrue()

		// Initial call is synchronous - no yield needed

		#expect(presenter.callCount == 0)
	}

	// MARK: - initial: false

	@Test("initial: false does not call perform on first invocation")
	func initialFalseFirstCall() {
		let presenter = ChangeMonitoringPresenter(router: MockRouter<TestBuilder>())

		presenter.monitorTextInitialFalse()

		#expect(presenter.callCount == 0)
	}

	@Test("initial: false subsequent calls are no-ops")
	func initialFalseSubsequentCalls() async {
		let presenter = ChangeMonitoringPresenter(router: MockRouter<TestBuilder>())

		// First call — registers but does not call perform
		presenter.monitorTextInitialFalse()
		#expect(presenter.callCount == 0)

		// Change the value
		presenter.service.text = "changed"

		await Task.yield()

		#expect(presenter.callCount == 1)

		// Second call — already registered, should be a no-op
		presenter.monitorTextInitialFalse()

		await Task.yield()

		#expect(presenter.callCount == 1)
	}

	@Test("only monitored value change trigger a perform")
	func onlyPerformForMonitoredValueChange() async {
		let presenter = ChangeMonitoringPresenter(router: MockRouter<TestBuilder>())

		// First call — registers but does not call perform
		presenter.monitorCountAndAccessText()
		#expect(presenter.callCount == 1)
		#expect(presenter.capturedPrevious as? Int == nil)
		#expect(presenter.capturedCurrent as? Int == 0)
		#expect(presenter.capturedOther as? String == "initial")

		// Change the text
		presenter.service.text = "changed"

		await Task.yield() // Give a chance to the closure to run

		// Expect no perform
		#expect(presenter.callCount == 1)
		#expect(presenter.capturedPrevious as? Int == nil)
		#expect(presenter.capturedCurrent as? Int == 0)
		#expect(presenter.capturedOther as? String == "initial")

		// Change the count

		presenter.service.count = 42

		await Task.yield() // Give a chance to the closure to run

		// Expect perform
		#expect(presenter.callCount == 2)
		#expect(presenter.capturedPrevious as? Int == 0)
		#expect(presenter.capturedCurrent as? Int == 42)
		#expect(presenter.capturedOther as? String == "changed")
	}
}
