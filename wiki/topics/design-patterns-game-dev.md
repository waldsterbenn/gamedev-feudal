---
type: topic
created: 2026-04-07
updated: 2026-04-07
sources:
  - docs/tech/technical-spec.md
tags: [design-patterns, architecture, game-development, software-engineering]
---

# Design Patterns in Game Development

## Overview

Design patterns are proven solutions to common game development challenges. This page covers patterns particularly applicable to Godot-based game projects.

## Core Patterns

### State Machine

**Purpose:** Manage distinct behavioral states for game objects.

**Use Cases:**
- Player states: idle, move, attack, stunned, death
- AI enemy behavior: patrol, chase, attack, flee
- Game flow: menu, playing, paused, game-over

**Godot Implementation:** Each state is a separate node or script branch, with transitions triggered by signals or conditions.

### Observer (Signals)

**Purpose:** Decouple event producers from event consumers.

**Use Cases:**
- Player emits `took_damage` signal, UI listens to update health bar
- Enemy emits `died` signal, save system records the kill
- Item emits `picked_up` signal, inventory updates

**Godot Implementation:** Godot's built-in Signal system provides native observer pattern support. Nodes emit signals, other nodes connect to them using `signal_name.connect()`.

### Singleton (Autoload)

**Purpose:** Provide globally accessible services without coupling components to specific scene hierarchies.

**Common Singletons:**
- **Game Manager** -- orchestrates overall game flow
- **Save System** -- handles persisting and loading game state
- **Event Bus** -- centralized signal hub for cross-system communication
- **Audio Manager** -- centralized volume control and audio playback

### Strategy Pattern

**Purpose:** Enable runtime swapping of algorithms or behaviors.

**Use Cases:**
- Different weapon attack patterns that share a common interface
- AI tactics that can be swapped (aggressive, defensive, stealthy)
- Movement behaviors (walking, swimming, flying)

### Object Pool

**Purpose:** Reuse frequently created and destroyed objects to avoid allocation overhead.

**Use Cases:**
- Arrows and projectiles in combat
- Particle effects
- Spawned enemy waves
- UI notification popups

### Facade Pattern

**Purpose:** Simplify complex subsystems behind a single manager interface.

**Use Cases:**
- A Save Manager that abstracts file I/O, serialization, and error handling
- An Audio Manager wrapping multiple AudioStreamPlayer nodes
- A Scene Manager handling transitions, loading screens, and resource preloading

## Pattern Relationships

Design patterns in Godot often compose together:
- State Machine + Observer -- states emit signals on transitions
- Singleton + Observer -- the Event Bus singleton routes signals between any subsystems
- Object Pool + Strategy -- pooled objects can have different behaviors
- Facade + Singleton -- managers use the Facade pattern exposed via autoload singletons

## See Also

- [[Godot Architecture]]
- [[Project Structure and Organization]]
- [[Godot Engine]]
- [[AI in Game Development]]
