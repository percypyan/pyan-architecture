# Creating a Module

Define services, screens, modals, and previews for a complete feature module.

## Overview

This article walks through the anatomy of a module using the
`PyanArchitectureSample` target as reference. By the end you will know
how all the pieces fit together and how to set up Xcode Previews with
mock dependencies.

### Module Structure

A typical module lives in its own directory and looks like this:

```
MyModule/
├── Screens/
│   ├── MyScreenEnum.swift         // BuildableScreen enum
│   └── Home/
│       ├── HomePresenter.swift    // Presenter
│       └── HomeScreen.swift       // Screen view
├── Modals/
│   ├── MyModalEnum.swift          // BuildableModal enum
│   └── Alert/
│       └── AlertModal.swift       // Modal view
├── Services/
│   └── ProfileService/
│       ├── ProfileService.swift   // Protocol
│       ├── ProductionProfileService.swift
│       └── MockProfileService.swift
├── MyBuilder.swift                // ModuleBuilder
└── MyPreviewer.swift              // Previewer (DEBUG only)
```

### Defining Services

Services can live outside Modules, but sometimes they are specific to
a Module an therefore should be placed in the `Module/Services` directory.
Define a protocol for each service. Provide a production implementation
and a mock for previews and tests:

```swift
protocol ProfileService: AnyObject, Observable {
    var profile: Profile? { get }
    func load() async
}

@Observable
final class ProductionProfileService: ProfileService { /* … */ }

#if DEBUG
@Observable
final class MockProfileService: ProfileService { /* … */ }
#endif
```

Register the production implementation in the ``Container`` when building
the module.

### The Builder

The ``ModuleBuilder`` is the single entry point for a module. It owns the
``Container`` and maps screen / modal keys to their concrete views:

```swift
struct MyBuilder: ModuleBuilder {
    let container: Container

    var root: MyScreen {
		root(for: .home)
	}

    func build(screen: MyScreen, with router: any AssociatedRouter) -> any View {
        // resolve services with <~container
    }

    func build(modal: MyModal) -> any Modal {
        // return modal views
    }
}
```

### The Presenter

Each screen has a ``Presenter``. Presenters are `@Observable` classes that:

1. Hold a reference to the router for navigation.
2. Resolve and interact with services.
3. Expose state properties that the ``Screen`` view observes.

Apply the ``Presenter()`` macro to your class instead of conforming to
``Presenter`` manually. The macro adds the protocol conformance allow usage
of ``MonitorChange(of:initial:perform:)``.

```swift
@MainActor
@Observable
@Presenter
final class HomePresenter {
    let router: any MyBuilder.AssociatedRouter
    let service: ProfileService

    init(router: any MyBuilder.AssociatedRouter, service: ProfileService) {
        self.router = router
        self.service = service
    }
}
```

> Note: If you use default @MainActor isolation (as recommended), `@MainActor`
decorator can be omitted.

Override ``Presenter/onAppear()`` or ``Presenter/onDisappear()`` to react
to lifecycle events.

### Reacting to Observable Changes

Use ``MonitorChange(of:initial:perform:)`` to observe an `@Observable`
property and run a closure each time its value changes. This is
particularly useful inside `onAppear()` or `init()` to keep presenter state
in sync with a service:

```swift
func onAppear() {
    #MonitorChange(of: service.profile, initial: true) { previous, current in
        self.username = current?.name ?? ""
    }
}
```

- **`initial: true`** -- fires the closure immediately with `nil` as the
  previous value and the current value of the expression.
- **`initial: false`** (default) -- stores the current value on first call
  and only fires the closure on subsequent changes.

The macro deduplicates registrations based on source location, so calling
it multiple times from the same call site (e.g. repeated `onAppear()`
invocations) is a safe no-op.

> important: The enclosing class must be annotated with `@Presenter`.

### The Screen View

A ``Screen`` defines its UI in ``Screen/screenBody`` and stores its
presenter as a `@State` property. The default `body` implementation
automatically calls `onAppear` and `onDisappear` on the presenter.

### Setting Up Previews

Alias ``Previewer`` with a specialized `Builder` and provide a parameter-free init
to access an easy way to show previews for a module:

```swift
#if DEBUG
typealias MyPreviewer = Previewer<MyBuilder>

extension MyPreviewer {
    init() {
        let container = previewContainer // Any container setup for previews.
        self.init(
			container: container,
			builder: .init(container: container),
			// If the container already contains ``FeatureManager`` adapted for previews.
			featureManager: <~container
		)
    }
}
#endif
```

Then use it in `#Preview` blocks:

```swift
// Preview a single screen
#Preview {
    MyPreviewer()
        .preview(screen: .home)
}

// Preview with overridden dependency and feature
#Preview {
    MyPreviewer()
        .register(type: ProfileService.self, MockProfileService(profile: .sample))
		.constant(SomeFeature.self, enabled: false)
        .preview(screen: .home)
}

// Preview a modal over a screen
#Preview {
    MyPreviewer()
        .preview(modal: .alert, over: .home, showButtonAlignment: .topTrailing)
}

// Preview the entire module
#Preview {
    MyPreviewer()
        .previewModule()
}
```

### Testing Presenters

In unit tests, use the `MockRouter` (available via the
``Presenter/MockRouter`` type alias in DEBUG builds) to verify navigation
calls without running real UI:

```swift
@Test func tapsProfile() {
    let router = HomePresenter.MockRouter()
    let presenter = HomePresenter(router: router, service: MockProfileService())

    presenter.goToDetail()

    #expect(router.hasNavigated(to: .detail(id: "42")))
}
```
