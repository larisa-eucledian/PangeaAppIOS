import UIKit

final class OfflineBannerPresenter {
    static let shared = OfflineBannerPresenter()

    private var obs: NSObjectProtocol?
    private let banner = OfflineBannerView()
    private var overlayWindow: UIWindow?   // 👈 NUEVO

    func start(window: UIWindow?) {
        guard obs == nil else { return } // idempotente

        // 1) Escena y overlay window por encima de todo
        let scene = window?.windowScene
            ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)
        guard let scene else { return }

        let overlay = UIWindow(windowScene: scene)
        overlay.frame = scene.coordinateSpace.bounds
        overlay.windowLevel = .alert + 1
        overlay.backgroundColor = .clear
        overlay.isHidden = false
        overlay.isUserInteractionEnabled = false

        let hostVC = UIViewController()
        hostVC.view.backgroundColor = .clear
        hostVC.view.isUserInteractionEnabled = false
        overlay.rootViewController = hostVC

        banner.isUserInteractionEnabled = false


        // 2) Colocar el banner en el safe area superior
        let host = hostVC.view!
        host.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            banner.trailingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            banner.topAnchor.constraint(equalTo: host.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        banner.isHidden = Reachability.shared.isOnline

        overlayWindow = overlay
        

        // 3) Observar cambios de red
        obs = NotificationCenter.default.addObserver(
            forName: Reachability.didChange, object: nil, queue: .main
        ) { [weak self] note in
            guard let self = self else { return }
            let online = (note.userInfo?["isOnline"] as? Bool) ?? true
            self.setVisible(!online, animated: true)
        }
    }

    func stop() {
        if let o = obs { NotificationCenter.default.removeObserver(o) }
        obs = nil
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    private func setVisible(_ show: Bool, animated: Bool) {
        guard banner.isHidden != !show else { return }
        if animated {
            if show {
                banner.alpha = 0; banner.transform = CGAffineTransform(translationX: 0, y: -10)
                banner.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.banner.alpha = 1; self.banner.transform = .identity
                }
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.banner.alpha = 0; self.banner.transform = CGAffineTransform(translationX: 0, y: -10)
                }, completion: { _ in
                    self.banner.isHidden = true
                    self.banner.alpha = 1; self.banner.transform = .identity
                })
            }
        } else {
            banner.isHidden = !show
        }
    }
}
