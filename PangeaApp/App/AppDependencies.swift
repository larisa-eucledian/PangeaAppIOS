// AppDependencies.swift

import Foundation

final class AppDependencies {
    static let shared = AppDependencies()

    lazy var plansRepository: PlansRepository = {
        //return MockPlansRepository()
        return CachedPlansRepository(api: apiClient)
        //return RealPlansRepository(api: apiClient)
    }()


    lazy var apiClient: APIClient = {
        DefaultAPIClient(
            baseURL: Config.baseURL,
            tokenProvider: { SessionManager.shared.session?.jwt }
        )
    }()

    
    lazy var authRepository: AuthRepository = {
        return RealAuthRepository(api: apiClient)
        //return MockAuthRepository()
    }()

    lazy var esimsRepository: ESimsRepository = {
        return CachedESimsRepository(api: apiClient)
        //return RealESimsRepository(api: apiClient)
    }()
    
    lazy var transactionRepository: TransactionRepository = {
        RealTransactionRepository(apiClient: apiClient)
    }()
    
    private init() {}
}
