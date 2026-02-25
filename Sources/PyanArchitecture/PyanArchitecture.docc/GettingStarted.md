# Getting Started with PyanArchitecture

Build a feature module with dependency injection, routing, and previews.

## Overview

This guide walks you through the key concepts of PyanArchitecture and
shows you how to set up a minimal module. For a complete working example,
refer to the `PyanArchitectureSample` target included in the package.

### Architecture at a Glance

Every feature is organized as a **module**. A module consists of:

| Component | Role |
|---|---|
| Screen enum | Lists navigable destinations (``BuildableScreen``) |
| Modal enum | Lists presentable modals (``BuildableModal``) |
| Builder | Maps keys to views and owns the ``Container`` (``ModuleBuilder``) |
| Presenter | Holds state and drives navigation (``Presenter``) |
| Screen view | Displays UI and delegates actions to its presenter (``Screen``) |

### Step 1 -- Create a Container

Register your services in a ``Container``. Use protocol types as keys so
you can swap in mocks for previews and tests.

```swift
let container = Container()
    .register(ProfileService.self) { _ in
        ProductionProfileService()
    }
```

### Step 2 -- Define Screens and Modals

Create enums conforming to ``BuildableScreen`` and ``BuildableModal``:

```swift
enum MyScreen: BuildableScreen {
    case home
    case detail(id: String)
    case settings

    var segue: Segue {
        switch self {
        case .settings: .sheet
        default: .push
        }
    }
}

enum MyModal: BuildableModal {
    case confirmation
}
```

> note: If you don't need modals, you can omit defining a ``BuildableModal`` enum.

### Step 3 -- Implement the Builder

Your ``ModuleBuilder`` maps keys to views and resolves services from the
container using the `<~` operator from PyanInject:

```swift
struct MyBuilder: ModuleBuilder {
    let container: Container
    let rootScreen: MyScreen = .home

    func build(screen: MyScreen, with router: any AssociatedRouter) -> any View {
        switch screen {
        case .home:
            HomeScreen(presenter: .init(router: router, service: <~container))
        case .detail(let id):
            DetailScreen(presenter: .init(id: id, router: router))
        case .settings:
            SettingsScreen(presenter: .init(router: router))
        }
    }

	// Omit this if you have not defined a ``BuildableModal`` enum.
    func build(modal: MyModal) -> any Modal {
        switch modal {
        case .confirmation: ConfirmationModal()
        }
    }
}
```

### Step 4 -- Build a Presenter

A ``Presenter`` is an `@Observable` class that owns the router and exposes
state to the view:

```swift
@MainActor
@Observable
final class HomePresenter: Presenter {
    let router: any MyBuilder.AssociatedRouter
    let service: ProfileService

    init(router: any MyBuilder.AssociatedRouter, service: ProfileService) {
        self.router = router
        self.service = service
    }

    func goToDetail() {
        router.navigate(to: .detail(id: "42"))
    }
}
```

### Step 5 -- Build a Screen

A ``Screen`` pairs a view with its presenter. Implement ``Screen/screenBody``
instead of `body` -- lifecycle callbacks are wired automatically:

```swift
struct HomeScreen: Screen {
    @State var presenter: HomePresenter

    var screenBody: some View {
        Button("Open Detail", action: presenter.goToDetail)
    }
}
```

### Step 6 -- Display the Module

Call ``RouteBuilder/root()`` on the builder to obtain the root view:

```swift
@main
struct MyApp: App {
    let container = Container()
        .register(ProfileService.self) { _ in ProductionProfileService() }

    var body: some Scene {
        WindowGroup {
            MyBuilder(container: container).root()
        }
    }
}
```

### Next Steps

- Learn how to set up Xcode Previews with mock dependencies in
  <doc:CreatingAModule>.
- See the `PyanArchitectureSample` target for a full working example.
