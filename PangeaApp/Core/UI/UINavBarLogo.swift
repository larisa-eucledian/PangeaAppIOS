//
//  UINavBarLogo.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//
import UIKit

extension UIViewController {

    func setNavBarLogo(centerWidth: CGFloat = 120, centerHeight: CGFloat = 24) {
        guard let img = UIImage(named: "AppLogo")?.withRenderingMode(.alwaysOriginal) else { return }
        let iv = UIImageView(image: img)
        iv.contentMode = .scaleAspectFit
        iv.isAccessibilityElement = true
        iv.accessibilityLabel = NSLocalizedString("app.logo", comment: "")
        iv.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: centerWidth),
            iv.heightAnchor.constraint(equalToConstant: centerHeight)
        ])

        navigationItem.titleView = container
    }

    /// Logo a la izquierda (deja large titles activos).
    func setNavBarLogoAsLeftItem(size: CGSize = .init(width: 28, height: 28)) {
        guard let img = UIImage(named: "AppLogo")?.withRenderingMode(.alwaysOriginal) else { return }
        let iv = UIImageView(image: img)
        iv.contentMode = .scaleAspectFit
        iv.isAccessibilityElement = true
        iv.accessibilityLabel = NSLocalizedString("app.logo", comment: "")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        iv.heightAnchor.constraint(equalToConstant: size.height).isActive = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iv)
    }
}
