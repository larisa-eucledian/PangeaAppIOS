//
//  ESimCell.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 23/11/25.
//

import UIKit

final class ESimCell: UITableViewCell {
    
    private let cardContainer = UIView()
    private let flagLabel = UILabel()
    private let packageNameLabel = UILabel()
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    private let infoLabel = UILabel()
    private let ctaLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        cardContainer.backgroundColor = AppColor.card
        cardContainer.layer.cornerRadius = 12
        cardContainer.layer.borderWidth = 1
        cardContainer.layer.borderColor = AppColor.border.cgColor
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardContainer)
        
        flagLabel.font = .systemFont(ofSize: 32)
        flagLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(flagLabel)
        
        packageNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        packageNameLabel.textColor = AppColor.textPrimary
        packageNameLabel.numberOfLines = 2
        packageNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(packageNameLabel)
        
        statusBadge.layer.cornerRadius = 12
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(statusBadge)
        
        statusLabel.font = .systemFont(ofSize: 12, weight: .bold)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.addSubview(statusLabel)
        
        infoLabel.font = .systemFont(ofSize: 14, weight: .regular)
        infoLabel.textColor = AppColor.textPrimary
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(infoLabel)
        
        ctaLabel.font = .systemFont(ofSize: 13, weight: .medium)
        ctaLabel.textColor = AppColor.primary
        ctaLabel.numberOfLines = 0
        ctaLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(ctaLabel)
        
        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            flagLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 16),
            flagLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 16),
            flagLabel.widthAnchor.constraint(equalToConstant: 36),
            
            packageNameLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 18),
            packageNameLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 12),
            packageNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -8),
            
            statusBadge.centerYAnchor.constraint(equalTo: packageNameLabel.centerYAnchor),
            statusBadge.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -4),
            
            infoLabel.topAnchor.constraint(equalTo: packageNameLabel.bottomAnchor, constant: 12),
            infoLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
            
            ctaLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
            ctaLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 12),
            ctaLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
            ctaLabel.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with esim: ESimRow) {
        // Flag
        if esim.coverage.count == 1 {
            flagLabel.text = flagEmoji(for: esim.coverage[0])
        } else {
            flagLabel.text = "🌍"
        }
        
        packageNameLabel.text = esim.packageName
        
        // Status badge
        let (bgColor, textColor) = colorsForStatus(esim.status)
        statusBadge.backgroundColor = bgColor
        statusLabel.text = esim.status.displayName
        statusLabel.textColor = textColor
        
        // Info and CTA based on status
        switch esim.status {
        case .installed:
            // Active: show activation date, expiration, ICCID
            var info = ""

            print("📱 eSIM [\(esim.packageName)] - Status: INSTALLED")
            print("   activationDate: \(esim.activationDate?.description ?? "nil")")
            print("   expirationDate: \(esim.expirationDate?.description ?? "nil")")

            if let activationDate = esim.activationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let dateStr = formatter.string(from: activationDate)
                info += String(format: NSLocalizedString("esim.activated.on", comment: ""), dateStr)
            }

            if let expirationDate = esim.expirationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let dateStr = formatter.string(from: expirationDate)
                info += "\n" + String(format: NSLocalizedString("esim.expires.on", comment: ""), dateStr)
            }
            
            if let iccid = esim.iccid, !iccid.isEmpty {
                info += "\nICCID: \(iccid)"
            }
            
            infoLabel.text = info
            ctaLabel.text = NSLocalizedString("esim.check.usage", comment: "")
            
        case .readyForActivation:
            // Not activated: show purchase date
            var info = ""

            print("📱 eSIM [\(esim.packageName)] - Status: READY FOR ACTIVATION")
            print("   createdAt: \(esim.createdAt?.description ?? "nil")")

            if let createdAt = esim.createdAt {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let dateStr = formatter.string(from: createdAt)
                info = String(format: NSLocalizedString("esim.purchased.on", comment: ""), dateStr)
            }

            infoLabel.text = info
            ctaLabel.text = NSLocalizedString("esim.activate.cta", comment: "")
            
        default:
            infoLabel.text = ""
            ctaLabel.text = ""
        }
    }
    
    private func flagEmoji(for countryCode: String) -> String {
        let code = countryCode.uppercased()
        guard code.count == 2 else { return "🌍" }
        var scalars: [UnicodeScalar] = []
        for scalar in code.unicodeScalars {
            guard let regional = UnicodeScalar(127397 + scalar.value) else { continue }
            scalars.append(regional)
        }
        return String(scalars.map(Character.init))
    }
    
    private func colorsForStatus(_ status: ESimStatus) -> (bg: UIColor, text: UIColor) {
        switch status {
        case .readyForActivation:
            return (AppColor.warning, .black)
        case .installed:
            return (AppColor.success, .white)
        case .expired:
            return (AppColor.error, .white)
        case .unknown:
            return (AppColor.textMuted, .white)
        }
    }
}
