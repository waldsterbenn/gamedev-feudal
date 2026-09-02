---
status: open
type: grilling
blocked-by: [02-pin-slice-acceptance-criteria]
---

# Pick stub-vs-omit for each non-management module

## Question

The repository has TDDs for modules that are NOT yet implemented:

| Module | TDD | Built? | Used by slice? |
|---|---|---|---|
| TimeEngine (3-tier tick system) | `tick-time-engine.md` | No | The slice uses GameCoordinator's 3s daily tick for now, so TimeEngine is technically not required for the slice to work. |
| ReservationService | `reservation-service.md` | No | Populants don't actually move toward resource nodes in the slice yet — they stay parked. Could omit or stub a no-op. |
| GOAP agent + actions | `goap-ai-system-tdd.md` | No | Slice populants run a simple state machine. Could omit. |
| SaveLoadService | `serialization-save-system.md` | No | Slice doesn't need persistence. Omit. |
| InputRouter (UI-state-aware) | `input-handling-architecture-tdd.md` | No | `management_mode_controller` already does its own routing. Could omit and refactor later. |
| Social / Warfare modules | referenced in architecture | No | Not in slice. Omit. |
| UI sub-eventbus (Audio, VFX) | `event-bus-tdd.md` | Scripted but unwired | Slice needs UI signals; Audio/VFX can stay unwired. |
| UICoordinator OptionMenu | `ui-architecture-tdd.md` | Scripted but no scene | Slice doesn't need pause menu. Omit. |

The decision: for each row, **stub** (write a no-op node that satisfies the public interface so future tickets can wire into it) or **omit** (delete any half-built artifacts and don't reference it). The principle is "no file in the project that isn't mentioned in some documentation" — so stubs must appear in their TDD and not just be dead code.

Grilling ticket — the human decides which side of the line we sit on for each module, and what "stub" means concretely.