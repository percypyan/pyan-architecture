//
//  Screen.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI

/// A SwiftUI view that is paired with a ``Presenter`` and responds to lifecycle events.
///
/// Implement ``screenBody`` instead of `body`. The default `body`
/// implementation wraps `screenBody` and automatically calls
/// ``Presenter/onAppear()`` and ``Presenter/onDisappear()`` on the presenter.
///
/// ```swift
/// struct ProfileScreen: Screen {
///     @State var presenter: ProfilePresenter
///
///     var screenBody: some View {
///         Text(presenter.username)
///     }
/// }
/// ```
public protocol Screen: View {
	/// The type of the view returned by ``screenBody``.
	associatedtype ScreenBody: View

	/// The presenter type that drives this screen.
	associatedtype ScreenPresenter: Presenter

	/// The presenter instance that manages this screen's state and navigation.
	var presenter: ScreenPresenter { get }

	/// The screen's content, analogous to SwiftUI's `body`.
	@ViewBuilder var screenBody: ScreenBody { get }
}

public extension Screen {
	var body: some View {
		screenBody
			.onAppear(perform: presenter.onAppear)
			.onDisappear(perform: presenter.onDisappear)
	}
}
