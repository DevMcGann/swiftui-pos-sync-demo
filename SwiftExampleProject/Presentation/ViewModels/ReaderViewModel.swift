import Foundation
import Observation

@MainActor
@Observable
final class ReaderViewModel {
    let demoDevice = ReaderDevice(id: "demo-reader-1", name: "Demo Pocket Reader")

    private(set) var connectionState: ReaderConnectionState = .disconnected
    private(set) var lastCardRead: CardReadResult?
    private(set) var actionErrorMessage: String?

    private let observeConnectionUseCase: ObserveReaderConnectionUseCase
    private let observeCardReadsUseCase: ObserveCardReadsUseCase
    private let startScanningUseCase: StartReaderScanningUseCase
    private let connectUseCase: ConnectReaderDeviceUseCase
    private let disconnectUseCase: DisconnectReaderUseCase
    private let simulateCardReadUseCase: SimulateCardReadUseCase

    @ObservationIgnored
    private var connectionTask: Task<Void, Never>?
    @ObservationIgnored
    private var cardReadTask: Task<Void, Never>?

    init(
        observeConnectionUseCase: ObserveReaderConnectionUseCase,
        observeCardReadsUseCase: ObserveCardReadsUseCase,
        startScanningUseCase: StartReaderScanningUseCase,
        connectUseCase: ConnectReaderDeviceUseCase,
        disconnectUseCase: DisconnectReaderUseCase,
        simulateCardReadUseCase: SimulateCardReadUseCase
    ) {
        self.observeConnectionUseCase = observeConnectionUseCase
        self.observeCardReadsUseCase = observeCardReadsUseCase
        self.startScanningUseCase = startScanningUseCase
        self.connectUseCase = connectUseCase
        self.disconnectUseCase = disconnectUseCase
        self.simulateCardReadUseCase = simulateCardReadUseCase
        startSubscriptions()
    }

    deinit {
        connectionTask?.cancel()
        cardReadTask?.cancel()
    }

    var connectionStatusTitle: String {
        switch connectionState {
        case .disconnected:
            return "Disconnected"
        case .scanning:
            return "Scanning for devices"
        case .connecting:
            return "Connecting…"
        case .connected:
            return "Connected"
        case .failed:
            return "Connection failed"
        }
    }

    var lastReadSummary: String? {
        guard let read = lastCardRead else { return nil }
        return "\(read.brand) ···· \(read.last4) · \(read.entryMode.rawValue)\nToken: \(read.token)\nReader ID: \(read.readerId)"
    }

    func startScanning() async {
        clearActionError()
        await startScanningUseCase.execute()
    }

    func connectDemoDevice() async {
        clearActionError()
        do {
            try await connectUseCase.execute(device: demoDevice)
        } catch let error as CardReaderActionError {
            actionErrorMessage = error.userFacingMessage
        } catch {
            actionErrorMessage = "Something went wrong. Please try again."
        }
    }

    func disconnect() async {
        clearActionError()
        await disconnectUseCase.execute()
    }

    func simulateCardRead() async {
        clearActionError()
        do {
            try await simulateCardReadUseCase.execute()
        } catch let error as CardReaderActionError {
            actionErrorMessage = error.userFacingMessage
        } catch {
            actionErrorMessage = "Something went wrong. Please try again."
        }
    }

    var isConnectEnabled: Bool {
        connectionState == .scanning
    }

    var isSimulateCardReadEnabled: Bool {
        connectionState == .connected
    }

    var isDisconnectEnabled: Bool {
        connectionState != .disconnected
    }

    private func clearActionError() {
        actionErrorMessage = nil
    }

    private func startSubscriptions() {
        connectionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = self.observeConnectionUseCase.execute()
            for await state in stream {
                self.connectionState = state
            }
        }

        cardReadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = self.observeCardReadsUseCase.execute()
            for await read in stream {
                self.lastCardRead = read
            }
        }
    }
}
