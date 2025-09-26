// AppDependencies.swift

import Foundation

final class AppDependencies {
    static let shared = AppDependencies()

    lazy var plansRepository: PlansRepository = {
        return MockPlansRepository()
    }()

    lazy var authRepository: AuthRepository = {
        // TODO: Cambiar a RealAuthRepository cuando conectemos API real
        return MockAuthRepository(ttlSeconds: 60 * 60) 
    }()

    private init() {}
}
