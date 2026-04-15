# AGENTS

## Project
PocketPOS Demo - modern iOS learning app

## Goal
Build a production-style Swift + SwiftUI app using:
- URLSession + async/await
- SwiftData
- Keychain
- CoreBluetooth
- offline-first architecture
- sync/outbox strategy

## Architecture
- Presentation
- Domain
- Data

## Agents
### Agent 1 - Coordinator
Owns planning, sequencing, reviews, and task assignment.

### Agent 2 - Data Layer
Owns API, DTOs, persistence, Keychain, Bluetooth implementation, sync engine.

### Agent 3 - Domain Layer
Owns entities, repository protocols, use cases, business rules.

### Agent 4 - Presentation Layer
Owns SwiftUI screens, view models, navigation, UI states.

### Agent 5 - Testing
Owns unit tests, integration-style tests, UI tests.

## Rules
- No business logic in views
- No networking in views
- No persistence in views
- Prefer async/await
- Use AsyncStream for BLE/event streams
- Keep architecture clean
- Update PROJECT_PLAN.md after completing a phase
