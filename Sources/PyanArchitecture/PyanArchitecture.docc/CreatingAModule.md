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
│       ├── ProfileService.swift          // Protocol
│       ├── ProductionProfileService.swift
│       └── MockProfileService.swift
├── MyBuilder.swift                // ModuleBuilder
└── MyPreviewer.swift              // Previewer (DEBUG only)
```

### Defining Services

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
    let rootScreen: MyScreen = .home

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

Override ``Presenter/onAppear()`` or ``Presenter/onDisappear()`` to react
to lifecycle events.

### The Screen View

A ``Screen`` defines its UI in ``Screen/screenBody`` and stores its
presenter as a `@State` property. The default `body` implementation
automatically calls `onAppear` and `onDisappear` on the presenter.

### Embedding Sub-Modules

Use ``SubModuleView`` (or the ``ModuleBuilder/SubModuleView`` alias) to
embed a child module. The child receives a dismiss callback so it can
return to the parent's navigation:

```swift
case .child:
    SubModuleView(router: router) { dismiss in
        ChildBuilder(container: container, onDismiss: dismiss)
    }
```

### Setting Up Previews

Create a ``Previewer`` that builds the module with an overridable
container and mock services:

```swift
#if DEBUG
struct MyPreviewer: Previewer {
    let builder: MyBuilder
    let container: Container

    init() {
        let container = Container(overridableDependencies: true)
            .register(ProfileService.self, factory: { _ in MockProfileService() })
        self.container = container
        self.builder = MyBuilder(container: container)
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

// Preview with an overridden dependency
#Preview {
    MyPreviewer()
        .register(ProfileService.self, factory: { _ in
            MockProfileService(profile: .sample)
        })
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
