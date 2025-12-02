//
//  OfflineBannerView.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 27/09/25.
//

import UIKit

final class OfflineBannerView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemRed.withAlphaComponent(0.9)
        layer.cornerRadius = 10
        layer.masksToBounds = true

        label.text = NSLocalizedString("net.offline", comment: "Sin conexión a Internet.")
        label.font = UIFont.preferredFont(forTextStyle: .footnote).withWeight(.semibold)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
