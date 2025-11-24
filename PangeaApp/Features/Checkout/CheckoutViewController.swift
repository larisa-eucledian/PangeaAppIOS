//
//  CheckoutViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 23/11/25.
//

import UIKit
import StripePaymentSheet

final class CheckoutViewController: UIViewController {

    // MARK: - Props

    private let pack: PackageRow
    private let countryName: String
    private let transactions = AppDependencies.shared.transactionRepository

    private var paymentSheet: PaymentSheet?
    private var isLoadingPayment = false {
        didSet { updateLoadingState() }
    }

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // Summary
    private let summaryCard = UIView()
    private let countryRow = UIStackView()
    private let countryFlagLabel = UILabel()
    private let countryNameLabel = UILabel()
    private let planTitleLabel = UILabel()
    private let planSubtitleLabel = UILabel()
    private let priceLabel = UILabel()

    // Details
    private let detailsCard = UIView()
    private let validityInfoLabel = UILabel()
    private let dataLabel = UILabel()
    private let callsLabel = UILabel()
    private let smsLabel = UILabel()
    private let extrasLabel = UILabel()
    private let coverageLabel = UILabel()

    // Payment
    private let payButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let secureLabel = UILabel()
    private let logosStack = UIStackView()

    private let stripeLogoView = UIImageView()
    private let visaLogoView = UIImageView()
    private let masterLogoView = UIImageView()
    private let amexLogoView = UIImageView()

    private let statusLabel = UILabel() // hidden

    // MARK: - Init

    init(package: PackageRow, countryName: String) {
        self.pack = package
        self.countryName = countryName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupLayout()
        configureContent()
        preparePayment()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = AppColor.background
        title = NSLocalizedString("title.checkout", comment: "")

        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        scrollView.addSubview(contentStack)

        // Header
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = AppColor.textMuted
        subtitleLabel.numberOfLines = 0

        // Summary
        configureCardView(summaryCard)

        countryRow.axis = .horizontal
        countryRow.spacing = 10
        countryRow.alignment = .center

        countryFlagLabel.font = .systemFont(ofSize: 34)
        countryNameLabel.font = .boldSystemFont(ofSize: 22)
        countryNameLabel.textColor = AppColor.textPrimary
        countryNameLabel.numberOfLines = 1

        countryRow.addArrangedSubview(countryFlagLabel)
        countryRow.addArrangedSubview(countryNameLabel)

        planTitleLabel.font = .boldSystemFont(ofSize: 18)
        planTitleLabel.textColor = AppColor.textPrimary
        planTitleLabel.numberOfLines = 0

        planSubtitleLabel.font = .systemFont(ofSize: 14)
        planSubtitleLabel.textColor = AppColor.textMuted
        planSubtitleLabel.numberOfLines = 0

        priceLabel.font = .boldSystemFont(ofSize: 22)
        priceLabel.textColor = AppColor.primary
        priceLabel.textAlignment = .right

        // Details
        configureCardView(detailsCard)

        validityInfoLabel.font = .systemFont(ofSize: 12)
        validityInfoLabel.textColor = AppColor.textMuted
        validityInfoLabel.numberOfLines = 0

        [dataLabel, callsLabel, smsLabel, extrasLabel, coverageLabel].forEach {
            $0.font = .systemFont(ofSize: 14)
            $0.numberOfLines = 0
            $0.textColor = AppColor.textPrimary
        }

        // Pay button
        payButton.setTitle(NSLocalizedString("checkout.pay.button", comment: ""), for: .normal)
        payButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        payButton.backgroundColor = AppColor.primary
        payButton.setTitleColor(.white, for: .normal)
        payButton.layer.cornerRadius = 12
        payButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        payButton.addTarget(self, action: #selector(onPayTapped), for: .touchUpInside)

        // Secure text
        secureLabel.font = .systemFont(ofSize: 13)
        secureLabel.textColor = AppColor.textMuted
        secureLabel.textAlignment = .center
        secureLabel.numberOfLines = 0
        secureLabel.text = NSLocalizedString("checkout.secure.info", comment: "")

        // Logos
        logosStack.axis = .horizontal
        logosStack.spacing = 12
        logosStack.alignment = .center

        configureLogoImageView(stripeLogoView, assetName: "logo_stripe")
        configureLogoImageView(visaLogoView, assetName: "logo_visa")
        configureLogoImageView(masterLogoView, assetName: "logo_mastercard")
        configureLogoImageView(amexLogoView, assetName: "logo_amex")

        logosStack.addArrangedSubview(stripeLogoView)
        logosStack.addArrangedSubview(visaLogoView)
        logosStack.addArrangedSubview(masterLogoView)
        logosStack.addArrangedSubview(amexLogoView)
        
        stripeLogoView.contentMode = .scaleAspectFit
        visaLogoView.contentMode = .scaleAspectFit
        masterLogoView.contentMode = .scaleAspectFit
        amexLogoView.contentMode = .scaleAspectFit

        logosStack.spacing = 12
        logosStack.distribution = .fillEqually
        logosStack.alignment = .center
        
        NSLayoutConstraint.activate([
            stripeLogoView.heightAnchor.constraint(equalToConstant: 24),
            visaLogoView.heightAnchor.constraint(equalToConstant: 24),
            masterLogoView.heightAnchor.constraint(equalToConstant: 24),
            amexLogoView.heightAnchor.constraint(equalToConstant: 24)
        ])

        // Status (hidden)
        statusLabel.isHidden = true
    }

    private func configureCardView(_ card: UIView) {
        card.backgroundColor = AppColor.card
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = AppColor.border.cgColor
    }

    private func configureLogoImageView(_ img: UIImageView, assetName: String) {
        img.image = UIImage(named: assetName)
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.heightAnchor.constraint(equalToConstant: 24).isActive = true
        img.widthAnchor.constraint(equalToConstant: 48).isActive = true
        img.isAccessibilityElement = false
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Summary
        let summaryStack = UIStackView(arrangedSubviews: [])
        summaryStack.axis = .vertical
        summaryStack.spacing = 12
        summaryStack.isLayoutMarginsRelativeArrangement = true
        summaryStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        summaryStack.addArrangedSubview(countryRow)

        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .top
        titleRow.spacing = 8

        let titleSide = UIStackView(arrangedSubviews: [planTitleLabel, planSubtitleLabel])
        titleSide.axis = .vertical
        titleSide.spacing = 4

        titleRow.addArrangedSubview(titleSide)
        titleRow.addArrangedSubview(priceLabel)

        summaryStack.addArrangedSubview(titleRow)

        summaryCard.addSubview(summaryStack)
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: summaryCard.topAnchor),
            summaryStack.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor),
            summaryStack.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor),
            summaryStack.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor)
        ])

        // Details
        let detailsStack = UIStackView()
        detailsStack.axis = .vertical
        detailsStack.spacing = 8
        detailsStack.isLayoutMarginsRelativeArrangement = true
        detailsStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        detailsStack.addArrangedSubview(validityInfoLabel)
        detailsStack.addArrangedSubview(dataLabel)
        detailsStack.addArrangedSubview(callsLabel)
        detailsStack.addArrangedSubview(smsLabel)
        detailsStack.addArrangedSubview(extrasLabel)
        detailsStack.addArrangedSubview(coverageLabel)

        detailsCard.addSubview(detailsStack)
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailsStack.topAnchor.constraint(equalTo: detailsCard.topAnchor),
            detailsStack.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor),
            detailsStack.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor),
            detailsStack.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor)
        ])

        // Combine all
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.setCustomSpacing(20, after: subtitleLabel)

        contentStack.addArrangedSubview(summaryCard)
        contentStack.addArrangedSubview(detailsCard)
        contentStack.setCustomSpacing(24, after: detailsCard)

        // Payment section
        contentStack.addArrangedSubview(payButton)
        contentStack.addArrangedSubview(loadingIndicator)
        contentStack.addArrangedSubview(secureLabel)
        contentStack.addArrangedSubview(logosStack)
        contentStack.addArrangedSubview(statusLabel)
    }

    // MARK: - Content

    private func configureContent() {
        titleLabel.text = NSLocalizedString("checkout.title", comment: "")
        subtitleLabel.text = NSLocalizedString("checkout.subtitle", comment: "")

        // País
        let flag: String
        if let coverage = pack.coverage, coverage.count > 1 {
            flag = "🌍"
        } else {
            let code = (pack.coverage?.first ?? "")
            flag = flagEmoji(for: code)
        }
        countryFlagLabel.text = flag
        countryNameLabel.text = countryName

        // Plan
        planTitleLabel.text = pack.packageLabelText

        let daysText = String(format: NSLocalizedString("unit.days.long", comment: ""),
                              pack.validity_days)
        planSubtitleLabel.text = daysText

        priceLabel.text = String(format: "%.2f %@", pack.price_public, pack.currency ?? "")

        // Vigencia
        validityInfoLabel.text = NSLocalizedString("checkout.validity.info", comment: "")

        // Details
        dataLabel.attributedText = detailLine(
            title: NSLocalizedString("checkout.data", comment: ""),
            value: pack.dataAmountDisplay
        )

        if pack.withCall == true {
            let title = NSLocalizedString("checkout.calls", comment: "")
            var desc = NSLocalizedString("checkout.calls.included", comment: "")
            if let a = pack.callAmount, let u = pack.callUnit { desc = "\(a) \(u)" }
            callsLabel.attributedText = detailLine(title: title, value: desc)
        } else {
            callsLabel.attributedText = nil
        }

        if pack.withSMS == true {
            let title = NSLocalizedString("checkout.sms", comment: "")
            var desc = NSLocalizedString("checkout.sms.included", comment: "")
            if let a = pack.smsAmount, let u = pack.smsUnit { desc = "\(a) \(u)" }
            smsLabel.attributedText = detailLine(title: title, value: desc)
        } else {
            smsLabel.attributedText = nil
        }

        var extras: [String] = []
        if pack.withHotspot == true {
            extras.append(NSLocalizedString("feature.hotspot", comment: ""))
        }
        if pack.withDataRoaming == true {
            extras.append(NSLocalizedString("feature.data_roaming", comment: ""))
        }
        if pack.withUsageCheck == true {
            extras.append(NSLocalizedString("feature.usage_check", comment: ""))
        }

        if !extras.isEmpty {
            extrasLabel.attributedText = detailLine(
                title: NSLocalizedString("checkout.extras", comment: ""),
                value: extras.joined(separator: " · ")
            )
        } else {
            extrasLabel.attributedText = nil
        }

        if let cov = pack.coverage, !cov.isEmpty {
            let countryNames = cov.map { countryName(for: $0) }.joined(separator: ", ")
            coverageLabel.attributedText = detailLine(
                title: NSLocalizedString("checkout.coverage", comment: ""),
                value: countryNames
            )
        } else {
            coverageLabel.attributedText = nil
        }

        statusLabel.text = NSLocalizedString("checkout.status.preparing", comment: "")
    }

    private func detailLine(title: String, value: String) -> NSAttributedString {
        let full = "\(title): \(value)"
        let attr = NSMutableAttributedString(string: full)
        let range = (full as NSString).range(of: "\(title):")
        attr.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: AppColor.textPrimary
        ], range: range)
        return attr
    }

    // MARK: - Flags

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

    // MARK: - Stripe

    private func preparePayment() {
        guard !isLoadingPayment else { return }
        isLoadingPayment = true

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await transactions.createStripeTransaction(
                                    amount: pack.price_public,
                                    currency: pack.currency ?? "mxn",
                                    packageId: pack.package_id
                                )

                var config = PaymentSheet.Configuration()
                config.merchantDisplayName = "Pangea eSIM"
                config.primaryButtonColor = AppColor.primary

                self.paymentSheet = PaymentSheet(
                    paymentIntentClientSecret: response.clientSecret,
                    configuration: config
                )

                await MainActor.run {
                    self.isLoadingPayment = false
                    self.statusLabel.text = NSLocalizedString("checkout.status.ready", comment: "")
                }

            } catch {
                await MainActor.run {
                    self.isLoadingPayment = false
                    self.statusLabel.text = error.localizedDescription
                }
            }
        }
    }

    private func updateLoadingState() {
        if isLoadingPayment {
            loadingIndicator.startAnimating()
            payButton.isEnabled = false
            payButton.alpha = 0.5
        } else {
            loadingIndicator.stopAnimating()
            payButton.isEnabled = paymentSheet != nil
            payButton.alpha = payButton.isEnabled ? 1 : 0.5
        }
    }
    
    private func showError(_ error: Error) {
        let ac = UIAlertController(
            title: NSLocalizedString("error.title", comment: ""),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: NSLocalizedString("general.ok", comment: ""), style: .default))
        present(ac, animated: true)
    }

    // MARK: - Actions

    @objc private func onPayTapped() {
        guard let paymentSheet else { return }
        paymentSheet.present(from: self) { result in
            print("STRIPE RESULT:", result)

            switch result {
                case .completed:
                    // Success - notify eSIMs list and go to tab
                    NotificationCenter.default.post(name: .eSimPurchaseCompleted, object: nil)

                    self.navigationController?.popToRootViewController(animated: true)

                    // Switch to eSIMs tab
                    if let tabBar = self.tabBarController {
                        tabBar.selectedIndex = 1
                    }
                    
                case .canceled:
                    // User canceled, stay on checkout
                    break
                    
                case .failed(let error):
                    self.showError(error)
                }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let eSimPurchaseCompleted = Notification.Name("eSimPurchaseCompleted")
}
