# PyanArchitecture

A module-based SwiftUI architecture built on dependency injection, type-safe routing, structured logging, and feature switching.

## Overview

PyanArchitecture ties together four companion libraries into a cohesive architecture pattern for SwiftUI applications. Each feature is organized as a self-contained *module* that owns its screens, modals, services, and dependencies.

| Library | Role |
|---|---|
| [PyanInject](https://github.com/percypyan/pyan-inject) | Dependency injection |
| [PyanRouter](https://github.com/percypyan/pyan-router) | Type-safe navigation |
| [PyanLogging](https://github.com/percypyan/pyan-logging) | Structured logging |
| [PyanFeatureSwitcher](https://github.com/percypyan/pyan-feature-switcher) | Runtime feature flags |
| [PyanTesting](https://github.com/percypyan/pyan-testing) | Testing utilities |

## Requirements

### Platform

- iOS 18.0+
- macOS 15.0+
- tvOS 18.0+
- watchOS 11.0+
- visionOS 2.0+

### Toolchain

- Swift 6.2+

## Installation

Add PyanArchitecture as a local package dependency in Xcode, or reference it in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/percypyan/PyanArchitecture.git", .upToNextMajor("0.1.0"))
]
```

## Documentation

Full API documentation and guides are available in the [DocC catalog](Sources/PyanArchitecture/PyanArchitecture.docc).

## Quick Start

**1. Register services in a Container**

```swift
let container = Container()
    .register(ProfileService.self) { _ in ProductionProfileService() }
```

**2. Define screen keys**

```swift
enum MyScreen: BuildableScreen {
    case home
    case detail(id: String)
}
```

**3. Implement a ModuleBuilder**

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
        }
    }
}
```

**4. Create a Presenter**

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

**5. Build a Screen**

```swift
struct HomeScreen: Screen {
    @State var presenter: HomePresenter

    var screenBody: some View {
        Button("Open Detail", action: presenter.goToDetail)
    }
}
```

**6. Display the module**

```swift
MyBuilder(container: container).root()
```

## Sample App

The `PyanArchitectureSample` module, included in the package sources, is a fully working reference implementation that demonstrates all core patterns in action:

- **Modular structure** — a self-contained `SampleModule` with its own screens, modals, services, and builder
- **Dependency injection** — service registration and resolution through a `Container`
- **Type-safe routing** — enum-based screen keys (`SampleScreen`) with push, sheet, and fullScreenCover segues
- **Presenter / Screen separation** — `ShowcasePresenter` owns the logic; `ShowcaseScreen` owns the UI
- **Modal management** — `SampleModal` with custom transitions and animations
- **Service abstraction** — `SampleGeneratorService` protocol with production and mock implementations
- **Preview support** — `SamplePreviewer` with an overridable preview container for Xcode Previews

Browse the source under `Sources/PyanArchitectureSample/` or follow the step-by-step guide in the [Creating a Module](Sources/PyanArchitecture/PyanArchitecture.docc/CreatingAModule.md) DocC article, which walks through the sample in detail.

## Testing

Use `MockRouter` to verify navigation logic in unit tests without running the UI:

```swift
let router = HomePresenter.MockRouter()
let presenter = HomePresenter(router: router, service: MockProfileService())

presenter.goToDetail()
#expect(router.hasNavigated(to: .detail(id: "42")))
```

## AI disclaimer

The code of this package is **entirely human-written**.
However, AI has been used to _generate unit tests suites and documentation_. Every generated bit of code or
documentation has been **reviewed and approved by a human developer**.

## License

The repository use an MIT licence.

See [LICENSE](LICENSE.md) file for details.
