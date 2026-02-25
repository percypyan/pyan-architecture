//
//  Presenter.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 04/02/2026.
//

import Observation

/// A type that drives a screen's behavior and holds its state.
///
/// Presenters sit between the view layer (``Screen``) and your services.
/// They own the router for navigation, expose observable state for the view,
/// and react to lifecycle events.
///
/// Mark concrete implementations with `@Observable` to automatically publish
/// state changes to the view.
///
/// ```swift
/// @MainActor
/// @Observable
/// final class ProfilePresenter: Presenter {
///     let router: any ProfileBuilder.AssociatedRouter
///     var username: String = ""
///
///     init(router: any ProfileBuilder.AssociatedRouter) {
///         self.router = router
///     }
///
///     func onAppear() {
///         // Load data
///     }
/// }
/// ```
@MainActor
public protocol Presenter: AnyObject, Observable {
	/// The module builder this presenter belongs to.
	associatedtype Builder: ModuleBuilder

	/// The router used to trigger navigation from this presenter.
	var router: any Builder.AssociatedRouter { get }

	/// Called when the screen appears. The default implementation does nothing.
	func onAppear()

	/// Called when the screen disappears. The default implementation does nothing.
	func onDisappear()
}

public extension Presenter {
	func onAppear() {}
	func onDisappear() {}
}

#if DEBUG
public extension Presenter {
	/// A convenience alias for the mock router type, available in DEBUG builds only.
	typealias MockRouter = Builder.AssociatedMockRouter
}
#endif
