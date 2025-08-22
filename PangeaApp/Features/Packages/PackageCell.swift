//
//  PackageCell.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 16/08/25.
//

import UIKit

class PackageCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 14.0, *) {
                var bg = UIBackgroundConfiguration.listGroupedCell()
                bg.backgroundColor = AppColor.card
                self.backgroundConfiguration = bg
            } else {
                // Fallback iOS 13
                self.backgroundColor = AppColor.card
            }

            // Estado seleccionado (opcional)
            let sel = UIView()
            sel.backgroundColor = AppColor.backgroundSecondary
            self.selectedBackgroundView = sel

            // Tint para el disclosure indicator
            self.tintColor = AppColor.primary

            // Colores de tus labels
            countryLabel.textColor = AppColor.primary
            packageLabel.textColor = AppColor.textPrimary
            infoLabel.textColor = AppColor.textMuted
            priceLabel.textColor = AppColor.primary

    }
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var packageLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
           super.prepareForReuse()
           countryLabel.text = nil
           packageLabel.text = nil
           infoLabel.text = nil
           priceLabel.text = nil
       }
    
    func configure(countryName: String, item: PackageRow) {
        countryLabel.text = countryName
        
        // Título con prefijo (Only Data / Data & Calls / Unlimited Data)
        packageLabel.text = item.packageLabelText
        
        // Features con ✅ (solo los que existan)
        var feats: [String] = []
        if item.withCall == true   { feats.append("✓ " + NSLocalizedString("feature.calls",   comment: "Calls")) }
        if item.withSMS == true    { feats.append("✓ " + NSLocalizedString("feature.sms",     comment: "SMS")) }
        if item.withHotspot == true{ feats.append("✓ " + NSLocalizedString("feature.hotspot", comment: "Hotspot")) }
        infoLabel.text = feats.joined(separator: " · ")
        
        // Precio
        let price = item.price_public
        let cur = item.currency ?? ""
        priceLabel.text = String(format: "%.2f %@", price, cur)
    }
}
