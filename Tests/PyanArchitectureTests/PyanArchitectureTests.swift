import Testing
import SwiftUI
@testable import PyanArchitecture

// MARK: - SubModuleView Tests

@Suite("SubModuleView")
struct SubModuleViewTests {
	@MainActor
	@Test("moduleFactory dismiss callback calls router.dismissScreen")
	func dismissCallbackCallsDismissScreen() {
		let router = MockRouter<TestBuilder>()
		let container = Container()

		var capturedDismiss: (() -> Void)?
		_ = SubModuleView<TestBuilder, SubTestBuilder>(router: router) { dismiss in
			capturedDismiss = dismiss
			return SubTestBuilder(container: container, onDismiss: dismiss)
		}

		#expect(capturedDismiss != nil)

		capturedDismiss?()

		#expect(router.hasDismissed(type: .screen))
		#expect(router.dismissedCount(type: .screen) == 1)
	}
}
