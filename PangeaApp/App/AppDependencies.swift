// AppDependencies.swift

import Foundation

final class AppDependencies {
    static let shared = AppDependencies()

    lazy var plansRepository: PlansRepository = {
        return MockPlansRepository()
    }()


    lazy var apiClient: APIClient = {
        DefaultAPIClient(
            baseURL: Config.baseURL,
            tokenProvider: { SessionManager.shared.session?.jwt }
        )
    }()

    
    lazy var authRepository: AuthRepository = {
        // return RealAuthRepository(api: apiClient)
        return MockAuthRepository()
    }()


    
    
    private init() {}
}
