# Module Composition

Embed a child module inside a parent module.

## Overview

A ``ModuleBuilder`` conforms to `View`, so a child module can be returned
directly from the parent's `build(screen:with:)` method. The parent
passes a dismiss callback wired to its own router so the child can
dismiss itself without knowing about the parent's navigation.

### Example

Give the child builder an `onDismiss` closure:

```swift
struct SettingsBuilder: ModuleBuilder {
    let container: Container
    let onDismiss: () -> Void

    var root: some View { root(for: .general) }

    func build(screen: SettingsScreen, with router: any AssociatedRouter) -> any View {
        // ...
    }
}
```

Then return it from the parent builder, binding dismiss to the parent's
router:

```swift
func build(screen: ParentScreen, with router: any AssociatedRouter) -> any View {
    switch screen {
    case .settings:
        SettingsBuilder(container: container, onDismiss: { router.dismissScreen() })
    case .home:
        HomeScreen(presenter: .init(router: router))
    }
}
```

The child manages its own `NavigationStack` independently. The dismiss
callback is the only connection point between the two modules.

### Separate Dependencies

If the child needs services the parent does not provide, create a child
container:

```swift
case .settings:
    let childContainer = Container(parent: container)
        .register(SettingsService.self) { _ in DefaultSettingsService() }
    SettingsBuilder(container: childContainer, onDismiss: { router.dismissScreen() })
```

