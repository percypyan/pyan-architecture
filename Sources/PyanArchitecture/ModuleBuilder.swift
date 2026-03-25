//
//  ModuleBuilder.swift
//  pyan-architecture
//
//  Created by Perceval Archimbaud on 04/02/2026.
//

/// A type that combines routing and dependency injection to form a self-contained feature module.
///
/// `ModuleBuilder` extends ``RouteBuilder`` with a dependency injection
/// ``Container``, giving each module its own isolated set of registered
/// services. Implement this protocol to define the screens, modals, and
/// dependencies for a feature.
///
/// ```swift
/// struct ProfileBuilder: ModuleBuilder {
///     let container: Container
///     let rootScreen: ProfileScreen = .overview
///
///     func build(screen: ProfileScreen, with router: any AssociatedRouter) -> any View {
///         switch screen {
///         case .overview:
///             ProfileOverview(presenter: .init(router: router, service: <~container))
///         }
///     }
/// }
/// ```
@MainActor
public protocol ModuleBuilder: RouteBuilder {
	/// The dependency injection container for this module.
	var container: Container { get }
}
