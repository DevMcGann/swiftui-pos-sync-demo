# ARCHITECTURE

## Layers
### Presentation
SwiftUI views and view models

### Domain
Entities, repository protocols, use cases

### Data
API client, DTOs, SwiftData models, Keychain, BLE, SyncEngine

## Data Flow
UI -> ViewModel -> UseCase -> Repository -> Local/Remote/BLE

## Offline First
- read local first
- refresh remote
- write local first
- enqueue sync item

## Sync
- outbox pattern
- FIFO
- retries with backoff
- idempotency key

## Bluetooth
- CoreBluetooth abstraction
- mock BLE reader first
- AsyncStream for connection and card-read events
