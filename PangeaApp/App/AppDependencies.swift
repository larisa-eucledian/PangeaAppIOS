// AppDependencies.swift

import Foundation

final class AppDependencies {
    static let shared = AppDependencies()

    // Cambia a false cuando conectes el repo real
    private let useMock = true

    // Repos/Servicios compartidos
    lazy var plansRepository: PlansRepository = {
        #if DEBUG
        if useMock { return MockPlansRepository() }
        #endif
        // TODO: Cambiar por el repo real cuando lo implementes
        return MockPlansRepository() // Placeholder hasta tener RemotePlansRepository
    }()

    private init() {}
}
