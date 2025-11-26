//
//  ESimDetailViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 23/11/25.
//

import UIKit

final class ESimDetailViewController: UIViewController {

    var repository: ESimsRepository?
    var esim: ESimRow!

    private var packageInfo: PackageRow?
    private let plansRepository: PlansRepository
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Header
    private let flagLabel = UILabel()
    private let packageNameLabel = UILabel()
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    
    // QR Section
    private let qrContainer = UIView()
    private let qrImageView = UIImageView()
    private let quickInstallButton = UIButton(type: .system)
    
    // Info Section
    private let infoStack = UIStackView()
    
    // Usage Section (only for active)
    private let usageContainer = UIView()
    private let usageStack = UIStackView()
    private let usageLoader = UIActivityIndicatorView(style: .medium)
    
    // Activate button
    private let activateButton = UIButton(type: .system)
    
    init(esim: ESimRow, repository: ESimsRepository? = nil, plansRepository: PlansRepository? = nil) {
        self.esim = esim
        self.repository = repository
        self.plansRepository = plansRepository ?? AppDependencies.shared.plansRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.plansRepository = AppDependencies.shared.plansRepository
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(esim != nil, "eSIM is required")
        
        if repository == nil {
            repository = AppDependencies.shared.esimsRepository
        }
        
        title = NSLocalizedString("title.esim.detail", comment: "")
        view.backgroundColor = AppColor.background
        
        setupUI()
        configure()

        // Fetch package info to show features
        fetchPackageInfo()

        // Fetch usage if active
        if esim.status == .installed {
            fetchUsage()
        }
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        setupHeader()
        setupQRSection()
        setupInfoSection()
        setupUsageSection()
        setupActivateButton()
    }
    
    private func setupHeader() {
        let header = UIView()

        flagLabel.font = .systemFont(ofSize: 28)
        flagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        packageNameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        packageNameLabel.textColor = AppColor.textPrimary
        packageNameLabel.numberOfLines = 0
        packageNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusBadge.layer.cornerRadius = 12
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.font = .systemFont(ofSize: 12, weight: .bold)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.addSubview(statusLabel)
        
        header.addSubview(flagLabel)
        header.addSubview(packageNameLabel)
        header.addSubview(statusBadge)
        
        NSLayoutConstraint.activate([
            flagLabel.topAnchor.constraint(equalTo: header.topAnchor),
            flagLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            flagLabel.widthAnchor.constraint(equalToConstant: 36),
            
            packageNameLabel.topAnchor.constraint(equalTo: header.topAnchor),
            packageNameLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 8),
            packageNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -12),
            packageNameLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            
            statusBadge.topAnchor.constraint(equalTo: header.topAnchor),
            statusBadge.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -4)
        ])
        
        packageNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        statusBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(header)
        
        
    }
    
    private func setupQRSection() {
        qrContainer.backgroundColor = AppColor.card
        qrContainer.layer.cornerRadius = 12
        qrContainer.layer.borderWidth = 1
        qrContainer.layer.borderColor = AppColor.border.cgColor
        qrContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let qrStack = UIStackView()
        qrStack.axis = .vertical
        qrStack.spacing = 16
        qrStack.alignment = .center
        qrStack.translatesAutoresizingMaskIntoConstraints = false
        qrContainer.addSubview(qrStack)
        
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrStack.addArrangedSubview(qrImageView)
        
        quickInstallButton.setTitle(NSLocalizedString("esim.quick.install", comment: ""), for: .normal)
        quickInstallButton.backgroundColor = AppColor.primary
        quickInstallButton.setTitleColor(.white, for: .normal)
        quickInstallButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        quickInstallButton.layer.cornerRadius = 12
        quickInstallButton.addTarget(self, action: #selector(quickInstallTapped), for: .touchUpInside)
        quickInstallButton.translatesAutoresizingMaskIntoConstraints = false
        qrStack.addArrangedSubview(quickInstallButton)
        
        NSLayoutConstraint.activate([
            qrStack.topAnchor.constraint(equalTo: qrContainer.topAnchor, constant: 20),
            qrStack.leadingAnchor.constraint(equalTo: qrContainer.leadingAnchor, constant: 20),
            qrStack.trailingAnchor.constraint(equalTo: qrContainer.trailingAnchor, constant: -20),
            qrStack.bottomAnchor.constraint(equalTo: qrContainer.bottomAnchor, constant: -20),
            
            qrImageView.heightAnchor.constraint(equalToConstant: 200),
            qrImageView.widthAnchor.constraint(equalToConstant: 200),
            
            quickInstallButton.heightAnchor.constraint(equalToConstant: 50),
            quickInstallButton.widthAnchor.constraint(equalTo: qrStack.widthAnchor)
        ])
        
        contentStack.addArrangedSubview(qrContainer)
    }
    
    private func setupInfoSection() {
        infoStack.axis = .vertical
        infoStack.spacing = 12
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(infoStack)
    }
    
    private func setupUsageSection() {
        usageContainer.backgroundColor = AppColor.card
        usageContainer.layer.cornerRadius = 12
        usageContainer.layer.borderWidth = 1
        usageContainer.layer.borderColor = AppColor.border.cgColor
        usageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        usageStack.axis = .vertical
        usageStack.spacing = 12
        usageStack.translatesAutoresizingMaskIntoConstraints = false
        usageContainer.addSubview(usageStack)
        
        usageLoader.hidesWhenStopped = true
        usageLoader.translatesAutoresizingMaskIntoConstraints = false
        usageContainer.addSubview(usageLoader)
        
        NSLayoutConstraint.activate([
            usageStack.topAnchor.constraint(equalTo: usageContainer.topAnchor, constant: 16),
            usageStack.leadingAnchor.constraint(equalTo: usageContainer.leadingAnchor, constant: 16),
            usageStack.trailingAnchor.constraint(equalTo: usageContainer.trailingAnchor, constant: -16),
            usageStack.bottomAnchor.constraint(equalTo: usageContainer.bottomAnchor, constant: -16),
            
            usageLoader.centerXAnchor.constraint(equalTo: usageContainer.centerXAnchor),
            usageLoader.centerYAnchor.constraint(equalTo: usageContainer.centerYAnchor)
        ])
        
        contentStack.addArrangedSubview(usageContainer)
        usageContainer.isHidden = true
    }
    
    private func setupActivateButton() {
        activateButton.setTitle(NSLocalizedString("esim.button.activate", comment: ""), for: .normal)
        activateButton.backgroundColor = AppColor.primary
        activateButton.setTitleColor(.white, for: .normal)
        activateButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        activateButton.layer.cornerRadius = 12
        activateButton.addTarget(self, action: #selector(activateTapped), for: .touchUpInside)
        activateButton.translatesAutoresizingMaskIntoConstraints = false
        activateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        contentStack.addArrangedSubview(activateButton)
    }
    
    private func configure() {
        // Clear previous info rows to avoid duplication
        infoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Flag
        if esim.coverage.count == 1 {
            flagLabel.text = flagEmoji(for: esim.coverage[0])
        } else {
            flagLabel.text = "🌍"
        }

        packageNameLabel.text = esim.packageName

        let (bgColor, textColor) = colorsForStatus(esim.status)
        statusBadge.backgroundColor = bgColor
        statusLabel.text = esim.status.displayName
        statusLabel.textColor = textColor
        
        // QR and quick install
        if let qrUrl = esim.qrCodeUrl, !qrUrl.isEmpty {
            loadQRCode(from: qrUrl)
            qrContainer.isHidden = false
            
            // Prioritize ios_quick_install
            if let quickInstall = esim.iosQuickInstall, !quickInstall.isEmpty {
                quickInstallButton.isHidden = false
            } else {
                quickInstallButton.isHidden = true
            }
        } else {
            qrContainer.isHidden = true
        }
        
        // Info
        addInfoRow(title: NSLocalizedString("esim.detail.iccid", comment: ""),
                   value: esim.iccid ?? NSLocalizedString("esim.detail.not.available", comment: ""))
        
        if let activationDate = esim.activationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            addInfoRow(title: NSLocalizedString("esim.detail.activated", comment: ""),
                       value: formatter.string(from: activationDate))
        }
        
        if let expirationDate = esim.expirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            addInfoRow(title: NSLocalizedString("esim.detail.expiration", comment: ""),
                       value: formatter.string(from: expirationDate))
        }
        
        let countryNames = esim.coverage.map { countryName(for: $0) }.joined(separator: ", ")
        addInfoRow(title: NSLocalizedString("esim.detail.coverage", comment: ""),
                   value: countryNames)
        
        // Activate button
        activateButton.isHidden = esim.status != .readyForActivation
        
        // Usage section
        usageContainer.isHidden = esim.status != .installed
    }
    
    private func addInfoRow(title: String, value: String) {
        let row = UIStackView()
        row.axis = .vertical
        row.spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = AppColor.textMuted
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = AppColor.textPrimary
        valueLabel.numberOfLines = 0
        
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        
        infoStack.addArrangedSubview(row)
    }
    
    private func fetchPackageInfo() {
        print("🔍 Fetching package info for packageId: \(esim.packageId)")
        Task {
            do {
                if let package = try await plansRepository.fetchPackage(packageId: esim.packageId) {
                    print("✅ Package fetched: \(package.package)")
                    print("   Data: \(package.dataAmount) \(package.dataUnit)")
                    print("   withCall: \(package.withCall ?? false)")
                    print("   withSMS: \(package.withSMS ?? false)")
                    print("   withHotspot: \(package.withHotspot ?? false)")
                    await MainActor.run {
                        self.packageInfo = package
                        self.addPackageFeatures(package)
                    }
                } else {
                    print("⚠️ Package not found for packageId: \(esim.packageId)")
                }
            } catch {
                print("❌ Failed to fetch package info: \(error)")
            }
        }
    }

    private func addPackageFeatures(_ package: PackageRow) {
        // Data
        let dataDisplay = "\(package.dataAmount) \(package.dataUnit)"
        addInfoRow(title: NSLocalizedString("package.data", comment: "Datos"),
                   value: dataDisplay)

        // Calls
        if package.withCall == true {
            var callsValue = NSLocalizedString("package.included", comment: "Incluidas")
            if let amount = package.callAmount, let unit = package.callUnit {
                callsValue = "\(amount) \(unit)"
            }
            addInfoRow(title: NSLocalizedString("package.calls", comment: "Llamadas"),
                       value: callsValue)
        }

        // SMS
        if package.withSMS == true {
            var smsValue = NSLocalizedString("package.included", comment: "Incluidos")
            if let amount = package.smsAmount, let unit = package.smsUnit {
                smsValue = "\(amount) \(unit)"
            }
            addInfoRow(title: NSLocalizedString("package.sms", comment: "SMS"),
                       value: smsValue)
        }

        // Hotspot
        if package.withHotspot == true {
            addInfoRow(title: NSLocalizedString("package.hotspot", comment: "Hotspot"),
                       value: NSLocalizedString("package.available", comment: "Disponible"))
        }
    }

    private func fetchUsage() {
        guard let repository else { return }
        usageLoader.startAnimating()
        
        Task {
            do {
                let usage = try await repository.fetchUsage(esimId: esim.esimId)
                await MainActor.run {
                    self.usageLoader.stopAnimating()
                    self.displayUsage(usage)
                }
            } catch {
                await MainActor.run {
                    self.usageLoader.stopAnimating()
                    print("Usage fetch error: \(error)")
                }
            }
        }
    }
    
    private func displayUsage(_ usage: ESimUsage) {
        let details = usage.usage.data
        
        // Convert MB to GB
        let dataUsedGB = Double(details.allowedData - details.remainingData) / 1024.0
        let dataAllowedGB = Double(details.allowedData) / 1024.0
        let dataPercentage = details.dataUsagePercentage
        
        addUsageRow(title: NSLocalizedString("esim.usage.data", comment: ""),
                    value: String(format: "%.2f GB / %.2f GB (%d%%)", dataUsedGB, dataAllowedGB, Int(dataPercentage)))
        
        if details.allowedSms > 0 {
            addUsageRow(title: NSLocalizedString("esim.usage.sms", comment: ""),
                        value: "\(details.remainingSms) / \(details.allowedSms)")
        }
        
        if details.allowedVoice > 0 {
            addUsageRow(title: NSLocalizedString("esim.usage.voice", comment: ""),
                        value: "\(details.remainingVoice) / \(details.allowedVoice) min")
        }
    }
    
    private func addUsageRow(title: String, value: String) {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = AppColor.textPrimary
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        valueLabel.textColor = AppColor.primary
        
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        
        usageStack.addArrangedSubview(row)
    }
    
    @objc private func quickInstallTapped() {
        guard let urlString = esim.iosQuickInstall,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func activateTapped() {
        let ac = UIAlertController(
            title: NSLocalizedString("esim.activate.confirm.title", comment: ""),
            message: NSLocalizedString("esim.activate.confirm.message", comment: ""),
            preferredStyle: .alert
        )
        
        ac.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: ""), style: .cancel))
        ac.addAction(UIAlertAction(title: NSLocalizedString("esim.button.activate", comment: ""), style: .default) { [weak self] _ in
            self?.activateESim()
        })
        
        present(ac, animated: true)
    }
    
    private func activateESim() {
        guard let repository else { return }
        
        Task {
            do {
                let updated = try await repository.activate(esimId: esim.esimId)
                await MainActor.run {
                    self.esim = updated
                    self.configure()
                    self.fetchUsage()
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                }
            }
        }
    }
    
    private func loadQRCode(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.qrImageView.image = image
                    }
                }
            } catch {
                print("QR load error: \(error)")
            }
        }
    }
    
    private func showError(_ error: Error) {
        let ac = UIAlertController(
            title: NSLocalizedString("error.title", comment: ""),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
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

    private func countryName(for countryCode: String) -> String {
        let code = countryCode.uppercased()
        let locale = Locale.current
        return locale.localizedString(forRegionCode: code) ?? code
    }
}
