//
//  Macros.swift
//  pyan-architecture
//
//  Created by Perceval Archimbaud on 22/03/2026.
//

/// Transforms a class into a ``Presenter``.
///
/// Applying `@Presenter` to a `class` will:
/// 1. Add conformance to the ``Presenter`` protocol.
/// 2. Inject a private `_changeMonitoringRegistry` property used by ``MonitorChange(of:initial:perform:)``.
///
/// You must also apply `@Observable` to the class for observation support.
/// You must still provide the `router` property and `Builder` typealias
/// required by ``Presenter`` yourself; the compiler will emit an error if they are missing.
///
/// ```swift
/// @Observable
/// @Presenter
/// final class ProfilePresenter {
///     let router: any ProfileBuilder.AssociatedRouter
///     var username: String = ""
///
///     init(router: any ProfileBuilder.AssociatedRouter) {
///         self.router = router
///     }
/// }
/// ```
@attached(member, names: named(_changeMonitoringRegistry))
@attached(extension, conformances: Presenter)
public macro Presenter() = #externalMacro(module: "PyanArchitectureMacros", type: "PresenterMacro")

/// Monitors an observable expression for changes and invokes a closure when the value changes.
///
/// Use `#MonitorChange` inside a method on a `@Presenter` class to reactively observe
/// a value derived from `@Observable` properties.
///
/// - Parameters:
///   - of: An expression that reads one or more observable properties (e.g., `service.text`).
///   - initial: When `true`, the closure is called immediately with `nil` as the previous value.
///     When `false`, the first observation stores the value and the closure is only called on subsequent changes.
///     Optional, default to `false`.
///   - perform: A closure receiving the optional previous value and the current value.
///
/// ```swift
/// func onAppear() {
///     #MonitorChange(of: service.text, initial: true) { previous, current in
///         print("Changed from \(String(describing: previous)) to \(current)")
///     }
/// }
/// ```
///
/// > Important: This macro requires the enclosing class to be annotated with `@Presenter`.
@freestanding(expression)
@discardableResult
public macro MonitorChange<Value: Equatable>(
	of: Value,
	initial: Bool = false,
	perform: (Value?, Value) -> Void
) -> Void = #externalMacro(module: "PyanArchitectureMacros", type: "MonitorChangeMacro")

/// Returns a value conditionally based on a compilation flag.
///
/// Use `#value` to provide different values depending on a compiler condition
/// (such as `DEBUG`, `MOCK`, etc.) without cluttering call sites with `#if` blocks.
///
/// - Parameters:
///   - releaseValue: The value used when the flag is **not** defined.
///   - withAlternative: The value used when the flag **is** defined.
///   - for: The compilation flag to check as a string literal (e.g., `"DEBUG"`, `"MOCK"`).
///
/// ```swift
/// let endpoint = #value("https://api.prod.com", withAlternative: "https://api.staging.com", for: "DEBUG")
/// ```
@freestanding(expression)
public macro value<T>(
	_ releaseValue: T,
	withAlternative altValue: T,
	for flag: StaticString
) -> T = #externalMacro(module: "PyanArchitectureMacros", type: "ValueMacro")
