//
//  Previewer.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

#if DEBUG

import SwiftUI

/// A helper that simplifies building SwiftUI previews for a module.
///
/// `Previewer` wraps a ``ModuleBuilder`` and its dependency injection
/// ``Container``, providing chainable methods to override services and
/// feature flags before rendering a screen, modal, or full module in a
/// `#Preview` block.
///
/// Create a typealias and an extension providing a parameter-free init for your
/// module's builder to keep preview call sites concise:
///
/// ```swift
/// // In a `SamplePreviewer.swift` file:
///
/// typealias SamplePreviewer = Previewer<SampleBuilder>
///
///	extension SamplePreviewer {
///		init() {
///			self.init(
///				container: someContainer,
///				builder: .init(someContainer),
///				// You can provide a base FeatureManager adapted for previews.
///				featureManager: <~someContainer
///			)
///		}
///	}
///
///	// Then in your preview location:
///
/// #Preview {
///     SamplePreviewer()
///         .constant(MyFeature.self, enabled: true)
///         .previewModule()
/// }
/// ```
@MainActor
public struct Previewer<Builder: ModuleBuilder> {
	public let container: Container

	private let builder: Builder
	private let featureManager: FeatureManager?
	private let constantFeatureManagerFactory: ConstantFeatureManagerFactory

	/// Creates a new previewer.
	///
	/// - Parameters:
	///   - container: The dependency injection container the module uses. Must to be overridable.
	///   - builder: The module builder that knows how to create screens and modals.
	///   - featureManager: A feature manager to override (through multiplexing).
	public init(
		container: Container,
		builder: Builder,
		featureManager manager: FeatureManager
	) {
		self.container = container
		self.builder = builder
		self.featureManager = manager
		self.constantFeatureManagerFactory = ConstantFeatureManagerFactory(isOverridable: true)
	}

	/// Creates a new previewer.
	///
	/// - Parameters:
	///   - container: The dependency injection container the module uses. Must to be overridable.
	///   - builder: The module builder that knows how to create screens and modals.
	public init(
		container: Container,
		builder: Builder
	) {
		self.container = container
		self.builder = builder
		self.featureManager = nil
		self.constantFeatureManagerFactory = ConstantFeatureManagerFactory(isOverridable: true)
	}
}

// MARK: FeatureManager boostrapping

struct PreviewFeatureManagerBoostrapper<Content: View>: View {
	let featureManager: FeatureManager
	let content: () -> Content

	var body: some View {
		let featureManager = featureManager
		Group {
			if featureManager.isReady {
				content()
			} else {
				ProgressView {
					Text("Loading preview...")
				}
			}
		}
		.task {
			guard !featureManager.isReady else { return }
			try! await featureManager.bootstrap()
		}
	}
}

// MARK: Preview methods

public extension Previewer {
	/// Returns a view that previews a single screen of the module.
	///
	/// Registers the mock feature manager into the container before
	/// building the screen.
	///
	/// - Parameter screen: The screen key identifying which screen to preview.
	/// - Returns: A type-erased view of the requested screen.
	func preview(screen: Builder.ScreenKey) -> AnyView {
		registerFeatureManager()
		return AnyView(PreviewFeatureManagerBoostrapper(featureManager: <~container) {
			builder.previewScreen(screen)
		})
	}

	/// Returns a view that previews a modal, optionally displayed over a screen.
	///
	/// Registers the mock feature manager into the container before
	/// building the modal.
	///
	/// - Parameters:
	///   - modal: The modal key identifying which modal to preview.
	///   - screen: An optional screen to display behind the modal. When `nil`,
	///     the modal is shown on its own.
	///   - showButtonAlignment: An optional alignment for the button that
	///     triggers the modal presentation.
	/// - Returns: A type-erased view of the modal preview.
	func preview(
		modal: Builder.ModalKey,
		over screen: Builder.ScreenKey? = nil,
		showButtonAlignment: Alignment? = .center
	) -> AnyView {
		registerFeatureManager()
		return AnyView(PreviewFeatureManagerBoostrapper(featureManager: <~container) {
			builder.previewModal(modal, over: screen, showButtonAlignment: showButtonAlignment)
		})
	}

	/// Returns a view that previews the full module starting from its root.
	///
	/// Registers the mock feature manager into the container before
	/// building the module root.
	///
	/// - Returns: A type-erased view of the module's root navigation.
	func previewModule() -> AnyView {
		registerFeatureManager()
		return AnyView(PreviewFeatureManagerBoostrapper(featureManager: <~container) {
			builder.root()
		})
	}
}

// MARK: MockFeatureManagerFactory update passthrough methods

public extension Previewer {
	private func registerFeatureManager() {
		let manager: FeatureManager
		if let featureManager {
			manager = constantFeatureManagerFactory.multiplexed(with: featureManager)
		} else {
			manager = constantFeatureManagerFactory.createBootstrappedManager()
		}
		container.registerSingleton(manager)
	}

	/// Sets a feature to a constant state for the preview.
	///
	/// This is a chainable passthrough to ``MockFeatureManagerFactory/constant(_:state:)``.
	///
	/// - Parameters:
	///   - featureType: The feature type to configure.
	///   - state: The constant state to assign to the feature.
	/// - Returns: `self`, allowing further configuration via chaining.
	func constant<F: Feature>(_ featureType: F.Type, state: F.State) -> Self {
		constantFeatureManagerFactory.constant(featureType, state: state)
		return self
	}

	/// Sets a boolean feature to enabled or disabled for the preview.
	///
	/// This is a chainable passthrough to ``MockFeatureManagerFactory/constant(_:enabled:)``.
	///
	/// - Parameters:
	///   - featureType: The boolean feature type to configure.
	///   - enabled: Whether the feature should be enabled.
	/// - Returns: `self`, allowing further configuration via chaining.
	func constant<F: Feature>(_ featureType: F.Type, enabled: Bool) -> Self where F.State == BooleanState {
		constantFeatureManagerFactory.constant(featureType, enabled: enabled)
		return self
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

	/// Registers a dependency using a factory closure that receives the container.
	///
	/// The container must have ``Container/areDependenciesOverridable`` set to
	/// `true`; otherwise a precondition failure is triggered.
	///
	/// - Parameters:
	///   - type: The type to register.
	///   - factory: A closure that creates the dependency, receiving the
	///     container for resolving other dependencies.
	/// - Returns: `self`, allowing further configuration via chaining.
	func register<T>(_ type: T.Type, factory: @escaping (Container) -> T) -> Self {
		checkContainer()
		container.register(type, factory: factory)
		return self
	}

	/// Registers a dependency using an autoclosure factory.
	///
	/// The container must have ``Container/areDependenciesOverridable`` set to
	/// `true`; otherwise a precondition failure is triggered.
	///
	/// - Parameters:
	///   - type: The type to register. Defaults to the inferred type of the factory.
	///   - factory: An autoclosure that creates the dependency.
	/// - Returns: `self`, allowing further configuration via chaining.
	func register<T>(type: T.Type = T.self, _ factory: @autoclosure @escaping () -> T) -> Self {
		checkContainer()
		container.register(type: type, factory())
		return self
	}

	/// Registers a dependency whose type is inferred from the factory expression.
	///
	/// The container must have ``Container/areDependenciesOverridable`` set to
	/// `true`; otherwise a precondition failure is triggered.
	///
	/// - Parameter factory: An autoclosure that creates the dependency.
	/// - Returns: `self`, allowing further configuration via chaining.
	func register<T>(_ factory: @autoclosure @escaping () -> T) -> Self {
		register(type: T.self, factory())
	}

	/// Registers a singleton dependency using a factory closure that receives the container.
	///
	/// The instance is created once and reused for subsequent resolutions.
	/// The container must have ``Container/areDependenciesOverridable`` set to
	/// `true`; otherwise a precondition failure is triggered.
	///
	/// - Parameters:
	///   - type: The type to register.
	///   - factory: A closure that creates the dependency, receiving the
	///     container for resolving other dependencies.
	/// - Returns: `self`, allowing further configuration via chaining.
	func registerSingleton<T>(_ type: T.Type, factory: @escaping (Container) -> T) -> Self {
		checkContainer()
		container.registerSingleton(type, factory: factory)
		return self
	}

	/// Registers a singleton dependency using an autoclosure factory.
	///
	/// The instance is created once and reused for subsequent resolutions.
	/// The container must have ``Container/areDependenciesOverridable`` set to
	/// `true`; otherwise a precondition failure is triggered.
	///
	/// - Parameters:
	///   - type: The type to register. Defaults to the inferred type of the factory.
	///   - factory: An autoclosure that creates the dependency.
	/// - Returns: `self`, allowing further configuration via chaining.
	func registerSingleton<T>(type: T.Type = T.self, _ factory: @autoclosure @escaping () -> T) -> Self {
		checkContainer()
		container.registerSingleton(type: type, factory())
		return self
	}

	/// Registers a singleton dependency whose type is inferred from the factory expression.
	///
	/// The instance is created once and reused for subsequent resolutions.
	/// The container must have ``Container/areDependenciesOverridable`` set to
	/// `true`; otherwise a precondition failure is triggered.
	///
	/// - Parameter factory: An autoclosure that creates the dependency.
	/// - Returns: `self`, allowing further configuration via chaining.
	func registerSingleton<T>(_ factory: @autoclosure @escaping () -> T) -> Self {
		registerSingleton(type: T.self, factory())
	}
}

#endif
