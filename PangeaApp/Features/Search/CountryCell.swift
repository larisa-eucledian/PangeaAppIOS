//
//  CountryCell.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 12/08/25.
//

import UIKit

class CountryCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        if #available(iOS 14.0, *) {
                  var bg = UIBackgroundConfiguration.listGroupedCell()
                  bg.backgroundColor = AppColor.card
                  self.backgroundConfiguration = bg
              } else {
                  self.backgroundColor = AppColor.card
              }

              // Estado seleccionado
              let sel = UIView()
              sel.backgroundColor = AppColor.backgroundSecondary
              self.selectedBackgroundView = sel

              // Tint para el disclosure
              self.tintColor = AppColor.primary

              // Labels
              titleLabel.textColor = AppColor.textPrimary
              subtitleLabel.textColor = AppColor.textMuted

    }
    
    @IBOutlet weak var flagImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
        func configure(with row: CountryRow) {
            titleLabel.text = row.country_name

            if row.geography == .regional || row.geography == .global {
                let n = row.covered_countries?.count ?? 0
                subtitleLabel.text = String(
                    format: NSLocalizedString("country.includes_countries", comment: ""),
                    n)
            } else {
                subtitleLabel.text = NSLocalizedString("country.packages_available", comment: "")
            }

            // Aquí cargamos la bandera
            if let urlString = row.image_url, let url = URL(string: urlString) {
                flagImageView.setImage(from: url, placeholder: UIImage(systemName: "globe"))
            } else {
                flagImageView.image = UIImage(systemName: "globe")
            }
        }
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        flagImageView.image = nil
    }

}
