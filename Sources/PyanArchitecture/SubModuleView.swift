//
//  SubModuleView.swift
//  PyanArchitecture
//
//  Created by Perceval Archimbaud on 03/03/2026.
//

import SwiftUI

/// A view that embeds a child module inside a parent module's navigation.
///
/// Use the ``ModuleBuilder/SubModuleView`` type alias for a more ergonomic
/// spelling. The `moduleFactory` closure receives a dismiss callback so the
/// child module can dismiss itself back into the parent's navigation stack.
///
/// ```swift
/// func build(screen: ParentScreen, with router: any AssociatedRouter) -> any View {
///     switch screen {
///     case .child:
///         SubModuleView(router: router) { dismiss in
///             ChildBuilder(container: container, onDismiss: dismiss)
///         }
///     }
/// }
/// ```
public struct SubModuleView<Builder: ModuleBuilder, SubBuilder: ModuleBuilder>: View {
	let router: any Builder.AssociatedRouter
	let subBuilder: SubBuilder

	/// Creates a sub-module view.
	///
	/// - Parameters:
	///   - router: The parent module's router, used to wire up the dismiss callback.
	///   - moduleFactory: A closure that receives a dismiss action and returns the child module's builder.
	public init(router: any Builder.AssociatedRouter, moduleFactory: (@escaping () -> Void) -> SubBuilder) {
		self.router = router
		self.subBuilder = moduleFactory({ router.dismissScreen() })
	}

	public var body: some View {
		subBuilder.root()
	}
}
