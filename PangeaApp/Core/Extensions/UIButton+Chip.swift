//
//  UIButton+.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/08/25.
//

import UIKit

extension UIButton {
    func styleAsChip(selected: Bool) {
        // 1) Leer el título desde donde esté (configuration o state)
        let fromConfig = (self.configuration?.title?.isEmpty == false) ? self.configuration?.title : nil
        let current = fromConfig ?? self.currentTitle ?? self.title(for: .normal) ?? ""

        // 2) Partimos de la config actual para no perder contenido
        var cfg = self.configuration ?? .plain()
        cfg.title = current
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        cfg.cornerStyle = .capsule
        cfg.background.backgroundColor = selected ? AppColor.primary : AppColor.backgroundSecondary
        cfg.baseForegroundColor = selected ? AppColor.textPrimary : AppColor.textPrimary
        cfg.background.strokeWidth = 1
        cfg.background.strokeColor = AppColor.border

        self.configuration = cfg
        // Nota: con UIButton.Configuration NO uses setTitleColor.
    }
}
