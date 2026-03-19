# ``PyanArchitecture``

A module-based SwiftUI architecture built on dependency injection, type-safe routing, structured logging, and feature switching.

## Overview

PyanArchitecture ties together four companion libraries into a cohesive
architecture pattern for building SwiftUI applications:

- **PyanInject** -- lightweight dependency injection via ``Container``.
- **PyanRouter** -- type-safe, enum-driven navigation via ``RouteBuilder`` and ``Router``.
- **PyanLogging** -- structured logging with categories and metadata.
- **PyanFeatureSwitcher** -- runtime feature flags via ``FeatureManager``.
- **PyanTesting** -- testing utilities and UITests mocks tools.

_See the complete documentation of each of those packages to learn more about what they are offering._

A *module* is a self-contained feature that owns its screens, modals,
services, and dependencies. Each module is defined by a ``ModuleBuilder``
that maps screen and modal keys to views and resolves services from its
``Container``.

### Core Protocols

- **``ModuleBuilder``** -- combines routing and dependency injection.
  Implement this to define a module's screens, modals, and container.
- **``Presenter``** -- drives a screen's state and navigation. Presenters
  are `@Observable` and respond to lifecycle events.
- **``Screen``** -- a SwiftUI view paired with a ``Presenter``. Lifecycle
  methods are called automatically.
- **``Previewer``** -- simplifies Xcode Previews by letting you preview
  individual screens, modals, or a full module with mock dependencies.

### Utilities

- **``SubModuleView``** -- embeds a child module inside a parent module's
  navigation, automatically wiring dismiss callbacks.
- **``LoggingManager``** -- manages the logging system bootstrap and
  provides categorized loggers with shared metadata.

## Topics

### Essentials

- <doc:GettingStarted>
- ``ModuleBuilder``
- ``Presenter``
- ``Screen``

### Previewing

- ``Previewer``

### Module Composition

- ``SubModuleView``

### Logging

- ``LoggingManager``

### Observation

- ``withObservationTracking(perform:)``

### Creating a Module

- <doc:CreatingAModule>
