//
//  SceneDelegate.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var sessionObserver: NSObjectProtocol?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene as? UIWindowScene) != nil else { return }
        configureAppearance()
        SessionManager.shared.loadFromKeychain()
        hookSessionObserverIfNeeded()
        Reachability.shared.start()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            OfflineBannerPresenter.shared.start(window: self.window)
            if !SessionManager.shared.isValid {
                self.presentLogin()
            }
        }
    }


    private func hookSessionObserverIfNeeded() {
        guard sessionObserver == nil else { return }
        sessionObserver = NotificationCenter.default.addObserver(
            forName: SessionManager.sessionDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            if SessionManager.shared.isValid {
                // Cierra solo si hay algo presentado
                if self.window?.rootViewController?.presentedViewController
                    != nil
                {
                    self.window?.rootViewController?.dismiss(animated: true)
                }
            } else {
                self.presentLogin()
            }
        }
    }

    private func presentLogin() {
        let vc = LoginViewController()  // programático
        vc.modalPresentationStyle = .fullScreen
        guard let host = window?.rootViewController,
            host.presentedViewController == nil
        else { return }
        host.present(vc, animated: false)
    }
    deinit {  // NEW
        if let token = sessionObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
    // MARK: - Session validation policy
    private var lastRemoteValidation: Date? = {
        let t = UserDefaults.standard.double(forKey: "lastRemoteValidation")
        return t > 0 ? Date(timeIntervalSince1970: t) : nil
    }()

    private let remoteCooldown: TimeInterval = 14 * 24 * 60 * 60 // 14 días

    func sceneWillEnterForeground(_ scene: UIScene) {
        validateSession()
    }

    private func validateSession() {
        // 1) Chequeo local (sin red)
        if SessionManager.shared.session?.isExpired == true {
            SessionManager.shared.clear() // mostrará Login por el observer
            return
        }

        // 2) Política remota: SOLO Wi-Fi / no costosa + cooldown cumplido
        let reach = Reachability.shared
        let onWifiOrUnmetered = reach.isOnline && !(reach.isExpensive || reach.isConstrained)

        let now = Date()
        let cooldownPassed = (lastRemoteValidation == nil) ||
                             (now.timeIntervalSince(lastRemoteValidation!) >= remoteCooldown)
        guard onWifiOrUnmetered && cooldownPassed else { return }

        // 3) Guardar timestamp (persistente)
        lastRemoteValidation = now
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "lastRemoteValidation")

        // 4) Validación remota (opcional; segura)
        guard let jwt = SessionManager.shared.session?.jwt, !jwt.isEmpty else { return }
        Task {
            do {
                let refreshed = try await AppDependencies.shared.authRepository.me(jwt: jwt)
                SessionManager.shared.save(session: refreshed) // si tu /me renueva exp, se guarda
            } catch let authErr as AuthError {
                // Solo cerrar sesión si el server devuelve 401
                if case .unauthorized = authErr { SessionManager.shared.clear() }
            } catch {
                // Errores de red u otros: NO limpies la sesión; reintenta en el próximo cooldown
            }
        }
    }

}

func sceneDidDisconnect(_ scene: UIScene) {}
func sceneDidBecomeActive(_ scene: UIScene) {}
func sceneWillResignActive(_ scene: UIScene) {}
func sceneWillEnterForeground(_ scene: UIScene) {
    validateSession()
}
private func validateSession() {
    // 1) Chequeo local
    if SessionManager.shared.session?.isExpired == true {
        SessionManager.shared.clear()
        return
    }
    // 2) Validación con repo (mock/real) para detectar invalidación server-side
    guard let jwt = SessionManager.shared.session?.jwt, !jwt.isEmpty else { return }
    Task {
        do {
            let refreshed = try await AppDependencies.shared.authRepository.me(jwt: jwt)
            SessionManager.shared.save(session: refreshed) // por si renuevas exp al validar
        } catch {
            SessionManager.shared.clear() // dispara presentación de Login
        }
    }
}


func sceneDidEnterBackground(_ scene: UIScene) {}
private func configureAppearance() {
    // NAV BAR
    let nav = UINavigationBarAppearance()
    nav.configureWithOpaqueBackground()
    nav.backgroundColor = AppColor.background
    nav.titleTextAttributes = [.foregroundColor: AppColor.textPrimary]
    nav.largeTitleTextAttributes = [.foregroundColor: AppColor.textPrimary]
    UINavigationBar.appearance().standardAppearance = nav
    UINavigationBar.appearance().scrollEdgeAppearance = nav
    UINavigationBar.appearance().tintColor = AppColor.primary  // íconos/botones

    // TAB BAR
    let tab = UITabBarAppearance()
    tab.configureWithOpaqueBackground()
    tab.backgroundColor = AppColor.background
    UITabBar.appearance().standardAppearance = tab
    UITabBar.appearance().scrollEdgeAppearance = tab
    UITabBar.appearance().tintColor = AppColor.primary  // item seleccionado
}
