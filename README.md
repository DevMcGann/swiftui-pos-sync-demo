# PocketPOS Demo App

## Overview
A production-style iOS demo app built with **Swift + SwiftUI** using **Clean Architecture** principles.

This project simulates a mobile POS system with:

- Secure login (Keychain-based session)
- Remote + local-first data (SwiftData)
- Mock BLE card reader (AsyncStream)
- Local payment drafts
- Outbox-based sync engine (offline-first)
- End-to-end flow: customer → card read → payment → sync

---

## ⚡ How this project was built

This project was built using a **multi-agent AI development workflow**.

Instead of writing everything manually, the system was designed and implemented through **coordinated AI agents**, each responsible for a specific architectural layer:

- **Agent 1 (Coordinator)**  
  Defined phases, scope, and ensured architectural consistency.

- **Agent 2 (Data Layer)**  
  Implemented persistence (SwiftData), API clients, BLE mock, and sync engine.

- **Agent 3 (Domain Layer)**  
  Defined business logic, entities, use cases, and state transitions.

- **Agent 4 (Presentation Layer)**  
  Built SwiftUI screens, view models, and user flows.

- **Agent 5 (Testing)**  
  Added targeted tests for sync logic, idempotency, and critical flows.

The process was incremental and phase-driven:
1. App skeleton
2. Login flow
3. Remote API integration
4. Local-first persistence
5. BLE simulation
6. Payment creation
7. Outbox + sync engine
8. Testing
9. Final polish

---

## 💡 Why this matters

This project demonstrates:

- Ability to design and build complex systems **from scratch**
- Strong understanding of **Clean Architecture**
- Practical **offline-first + sync patterns**
- Real-world patterns like:
  - idempotency
  - outbox processing
  - async streams
- Effective use of **AI as a development multiplier**

> I had no prior iOS experience before building this project.

---

## 🏗 Architecture

- **Domain / Data / Presentation**
- Async/await (no Combine)
- SwiftData for persistence
- Dependency Injection via container
- Clear separation of concerns

---

## 🚀 Running the app

Open the project in Xcode and run on a simulator.

---

## 🧪 Running tests

```bash
xcodebuild test -scheme SwiftExampleProject
