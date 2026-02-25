//
//  Previewer.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

#if DEBUG

import SwiftUI

/// A type that simplifies Xcode Previews for a module.
///
/// Conforming types hold a ``ModuleBuilder`` and a ``Container`` with
/// overridable dependencies, letting you quickly preview individual screens,
/// modals, or an entire module while substituting mock services.
///
/// ```swift
/// struct MyPreviewer: Previewer {
///     let builder: MyBuilder
///     let container: Container
///
///     init() {
///         let container = Container(overridableDependencies: true)
///             .register(MyService.self, factory: { _ in MockMyService() })
///         self.container = container
///         self.builder = MyBuilder(container: container)
///     }
/// }
///
/// #Preview {
///     MyPreviewer()
///         .register(AnalyticsService.self, factory: { _ in MockAnalytics() })
///         .preview(screen: .home)
/// }
/// ```
@MainActor
public protocol Previewer {
	/// The module builder type this previewer wraps.
	associatedtype Builder: ModuleBuilder

	/// The module builder used to build screens and modals.
	var builder: Builder { get }

	/// The container used to register and resolve dependencies for previews.
	var container: Container { get }

	/// Returns a preview of the given screen.
	func preview(screen: Builder.ScreenKey) -> AnyView

	/// Returns a preview of the given modal, optionally displayed over a background screen.
	func preview(modal: Builder.ModalKey, over screen: Builder.ScreenKey?, showButtonAlignment: Alignment?) -> AnyView

	/// Returns a preview of the entire module starting from the root screen.
	func previewModule() -> AnyView

	/// Registers a factory in the preview container and returns `self` for chaining.
	func register<T>(_ type: T.Type, factory: @escaping (Container) -> T) -> Self

	/// Registers an instance in the preview container and returns `self` for chaining.
	func register<T>(type: T.Type, _ factory: @autoclosure @escaping () -> T) -> Self

	/// Registers a singleton factory in the preview container and returns `self` for chaining.
	func registerSingleton<T>(_ type: T.Type, factory: @escaping (Container) -> T) -> Self

	/// Registers a singleton instance in the preview container and returns `self` for chaining.
	func registerSingleton<T>(type: T.Type, _ factory: @autoclosure @escaping () -> T) -> Self
}

@MainActor
struct PreviewWithFeatureManager<Content: View>: View {
	let featureManager: FeatureManager?
	let content: () -> Content

	var body: some View {
		let featureManager = featureManager
		Group {
			if featureManager?.isReady ?? true {
				content()
			}
		}
		.task { try! await featureManager?.bootstrap() }
	}
}

// MARK: Preview methods

public extension Previewer {
	func preview(screen: Builder.ScreenKey) -> AnyView {
		return AnyView(PreviewWithFeatureManager(featureManager: <~container) {
			builder.previewScreen(screen)
		})
	}

	func preview(
		modal: Builder.ModalKey,
		over screen: Builder.ScreenKey? = nil,
		showButtonAlignment: Alignment? = nil
	) -> AnyView {
		return AnyView(PreviewWithFeatureManager(featureManager: <~container) {
			builder.previewModal(modal, over: screen, showButtonAlignment: showButtonAlignment)
		})
	}

	func previewModule() -> AnyView {
		return AnyView(PreviewWithFeatureManager(featureManager: <~container) {
			builder.root()
		})
	}
}

// MARK: Container update passthrough methods

public extension Previewer {
	private func checkContainer() {
		precondition(
			container.areDependenciesOverridable,
			"Previewer needs an overridable dependencies container."
		)
	}

	func register<T>(_ type: T.Type, factory: @escaping (Container) -> T) -> Self {
		checkContainer()
		container.register(type, factory: factory)
		return self
	}

	func register<T>(type: T.Type = T.self, _ factory: @autoclosure @escaping () -> T) -> Self {
		checkContainer()
		container.register(type: type, factory())
		return self
	}

	func register<T>(_ factory: @autoclosure @escaping () -> T) -> Self {
		register(type: T.self, factory())
	}

	func registerSingleton<T>(_ type: T.Type, factory: @escaping (Container) -> T) -> Self {
		checkContainer()
		container.registerSingleton(type, factory: factory)
		return self
	}

	func registerSingleton<T>(type: T.Type = T.self, _ factory: @autoclosure @escaping () -> T) -> Self {
		checkContainer()
		container.registerSingleton(type: type, factory())
		return self
	}

	func registerSingleton<T>(_ factory: @autoclosure @escaping () -> T) -> Self {
		registerSingleton(type: T.self, factory())
	}
}

#endif
