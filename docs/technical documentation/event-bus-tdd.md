# Technical Design Document (TDD) — EventBus Architecture

## 1. Purpose & Scope
The `EventBus` (also referred to as `SignalBus`) is a standalone global Autoload singleton (`EventBus.gd`) that acts as a decoupled notification switchboard for the application.

> **Architectural Distinction**: The `EventBus` is **NOT** part of the `GameCoordinator` package. It exists as an independent global system to separate core simulation mechanics from presentation and audio concerns.

---

## 2. Signal Scope & Architectural Boundary

To maintain absolute decoupling and prevent architectural drift, signal responsibilities are strictly partitioned based on where an action takes place:

| Scope | Architectural Owner | Mechanism | Example Use Cases |
| :--- | :--- | :--- | :--- |
| **Inside/Between Modules** | `GameCoordinator` | Context Passing & Sequential Method Calls | Combat calculations, resource yields, population updates, stat mutations, state handoffs. |
| **Outside Modules** | `EventBus` | Asynchronous Global Signals | HUD updates, UI text wiggles, playing sound effects, screen flash/shake, achievement popups. |

### Core Rule:
* **Inside a Module**: Everything that takes place within or between modules is driven by the `GameCoordinator` through **Context Passing**. Core modules **never** use the `EventBus` to communicate state changes to each other or trigger core gameplay logic.
* **Outside a Module**: Everything that takes place outside core module simulation (UI, Audio, VFX) listens to `EventBus` signals. Core modules emit `EventBus` signals strictly as "fire-and-forget" notifications for secondary observers.

---

## 3. Communication & Data Flow

```
                      ┌────────────────────────┐
                      │    GameCoordinator     │
                      └───────────┬────────────┘
                                  │ Context Passing (Top-Down)
                                  ▼
                      ┌────────────────────────┐
                      │       GameModule       │ (e.g. ManagementModule)
                      └───────────┬────────────┘
                                  │ Emits Signal (Fire-and-Forget)
                                  ▼
                      ┌────────────────────────┐
                      │        EventBus        │ (Global Autoload)
                      └────┬──────────────┬────┘
                           │              │
       Subscribes          ▼              ▼          Subscribes
                  ┌──────────────┐  ┌──────────────┐
                  │  UI System   │  │ Audio System │
                  └──────────────┘  └──────────────┘
```

1. **Top-Down Execution**: `GameCoordinator` passes the state context (`Resource`) into `GameModule.process_tick(context)`.
2. **Module Processing**: `GameModule` executes its domain logic and directly mutates the passed context.
3. **Notification Emission**: If an external system needs to visually or aurally reflect a change, `GameModule` emits a signal on `EventBus` (e.g., `EventBus.gold_changed.emit(new_amount)` or `EventBus.populants_starving.emit(count)`).
4. **Secondary Reaction**: UI components and Audio players subscribed to `EventBus` update their displays or play sound effects. The module does not wait for or care about their response.

---

## 4. Signal Definition & Safety Rules

1. **No Inter-Module State Dependencies**: A module must **never** subscribe to an `EventBus` signal to alter game state or trigger another module's execution.
2. **One-Way Broadcasts**: `EventBus` signals must be void return type (`void`). They are strictly notifications, not queries.
3. **Primitive/DTO Arguments**: Signal parameters must only contain primitive types (`int`, `float`, `String`) or immutable Data Transfer Objects (DTOs). Never pass mutable domain objects or Node references through `EventBus`.
4. **Stateless Listeners**: Listeners on `EventBus` (such as UI elements or SFX players) must be side-effect observers only and must not alter the master game context.

---

## 5. System Files

The `EventBus` system is composed of the following files:

| File Path | Type | Description |
| :--- | :--- | :--- |
| `res://scenes/event_bus/EventBus.tscn` | Godot Scene | Reusable scene instantiating the sub-buses as child nodes. |
| `res://scripts/event_bus/EventBus.gd` | Script | Attached to the scene root. References child nodes (`UI`, `Audio`, `VFX`). **Must not** declare `class_name EventBus` to avoid singleton name hiding. |
| `res://scripts/event_bus/EventBusUI.gd` | Script | Attached to the `UI` child node. Declares UI-specific signals. |
| `res://scripts/event_bus/EventBusAudio.gd` | Script | Attached to the `Audio` child node. Declares audio-specific signals. |
| `res://scripts/event_bus/EventBusVFX.gd` | Script | Attached to the `VFX` child node. Declares visual feedback/effects signals. |

---

## 6. Scene-Tree Integration & Autoload Setup

### Autoload Registration
To integrate the `EventBus` into the global game loop, it is added to the project's autoload configurations in `project.godot`:

```ini
[autoload]
EventBus="*res://scenes/event_bus/EventBus.tscn"
```

### Runtime Node Hierarchy
When the game starts, Godot instantiates `EventBus.tscn` directly under the root Viewport (`/root`). It sits outside the local gameplay scene tree (`World`) to prevent destruction during level loads or scene resets:

```
[Viewport Root: /root]
 ├── ServiceLocator (Autoload Singleton)
 ├── ManagementAPI (Autoload Singleton)
 ├── EventBus (Autoload Singleton - EventBus.tscn root)
 │    ├── UI (Node, EventBusUI.gd)
 │    ├── Audio (Node, EventBusAudio.gd)
 │    └── VFX (Node, EventBusVFX.gd)
 └── World (Gameplay Scene Tree Root)
      └── GameCoordinator (Node)
```

