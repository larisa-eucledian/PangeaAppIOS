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

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard (scene as? UIWindowScene) != nil else { return }

        configureAppearance()

        // Carga sesión local (Keychain) y observa cambios
        SessionManager.shared.loadFromKeychain()
        hookSessionObserverIfNeeded()

        // Reachability + banner global (overlay por encima de modales)
        Reachability.shared.start()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            OfflineBannerPresenter.shared.start(window: self.window)

            // Si no hay sesión válida, muestra Login
            if !SessionManager.shared.isValid {
                self.presentLogin()
            }
        }
    }

    // MARK: - Session Observer
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
                if self.window?.rootViewController?.presentedViewController != nil {
                    self.window?.rootViewController?.dismiss(animated: true)
                }
            } else {
                self.presentLogin()
            }
        }
    }

    // MARK: - Present Login
    private func presentLogin() {
        window?.endEditing(true)

        let vc = LoginViewController()
        vc.modalPresentationStyle = .fullScreen

        guard let host = window?.rootViewController,
              host.presentedViewController == nil else { return }
        host.present(vc, animated: false)
    }

    // MARK: - Scene lifecycle (todo dentro de la clase)
    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        //>Banner esté montado si la window cambió
        OfflineBannerPresenter.shared.start(window: self.window)
    }

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        validateSession()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {}

    // MARK: - Session validation (solo local; sin /users/me)
    private func validateSession() {
        if SessionManager.shared.session?.isExpired == true {
            SessionManager.shared.clear() // observer presentará Login
        }
        // Política Fase 2/3: validación remota desactivada (no existe /users/me)
        // El interceptor 401 del APIClient hará logout cuando corresponda.
    }

    // MARK: - Appearance
    private func configureAppearance() {
        // NAV BAR
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = AppColor.background
        nav.titleTextAttributes = [.foregroundColor: AppColor.textPrimary]
        nav.largeTitleTextAttributes = [.foregroundColor: AppColor.textPrimary]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().tintColor = AppColor.primary // íconos/botones

        // TAB BAR
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = AppColor.background
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = AppColor.primary // item seleccionado
    }

    deinit {
        if let token = sessionObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
}
