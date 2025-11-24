//
//  CountryCell.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 12/08/25.
//  Updated: 23/11/25 - Made programmatic for better layout control
//

import UIKit

class CountryCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private let flagImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = AppColor.textPrimary
        label.numberOfLines = 2  // Allow 2 lines for long country names
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = AppColor.textMuted
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - Setup
    
    private func setupCell() {
        // Cell appearance
        if #available(iOS 14.0, *) {
            var bg = UIBackgroundConfiguration.listGroupedCell()
            bg.backgroundColor = AppColor.card
            backgroundConfiguration = bg
        } else {
            backgroundColor = AppColor.card
        }
        
        // Selected state
        let selectedView = UIView()
        selectedView.backgroundColor = AppColor.backgroundSecondary
        selectedBackgroundView = selectedView
        
        // Disclosure indicator
        accessoryType = .disclosureIndicator
        tintColor = AppColor.primary
        
        // Add subviews
        contentView.addSubview(flagImageView)
        contentView.addSubview(labelsStack)
        
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            // Flag image
            flagImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            flagImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 60),
            flagImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Labels stack
            labelsStack.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 16),
            labelsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60), // Space for disclosure
            labelsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    
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
        
        // Load flag image
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
