//
//  ForgotPasswordViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/11/25.
//

import UIKit

final class ForgotPasswordViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("auth.forgot.title", comment: "")
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("auth.forgot.subtitle", value: "Enter your email and we'll send you a reset link", comment: "")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = AppColor.textMuted
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailField: OutlinedTextField = {
        let field = OutlinedTextField(placeholder: NSLocalizedString("auth.email.placeholder", value: "Email", comment: ""))
        field.keyboardType = .emailAddress
        field.textContentType = .emailAddress
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("auth.forgot.button", value: "Send Reset Link", comment: ""), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = AppColor.primary
        btn.setTitleColor(AppColor.background, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("common.cancel", value: "Cancel", comment: ""), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var touchedEmail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = AppColor.background
        
        // ScrollView
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        
        // Content view
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailField)
        contentView.addSubview(sendButton)
        contentView.addSubview(cancelButton)
        contentView.addSubview(loadingIndicator)
        
        // Layout
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Email field
            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Send Button
            sendButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 24),
            sendButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            sendButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Cancel Button
            cancelButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        emailField.onTextChange { [weak self] _ in
            self?.touchedEmail = true
            self?.validateForm()
        }
        
        emailField.onEditingEnd { [weak self] in
            self?.touchedEmail = true
            self?.validateEmailField()
        }
        
        sendButton.addTarget(self, action: #selector(onSendTap), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(onCancelTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func onSendTap() {
        view.endEditing(true)
        emailField.clearError()
        
        guard validateAllFields() else { return }
        performSendResetLink()
    }
    
    @objc private func onCancelTap() {
        dismiss(animated: true)
    }
    
    // MARK: - Validation
    private func validateForm() {
        let email = emailField.text ?? ""
        let isValid = isValidEmail(email)
        sendButton.isEnabled = isValid
        sendButton.alpha = isValid ? 1.0 : 0.5
    }
    
    private func validateEmailField() {
        guard touchedEmail else { return }
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email.isEmpty {
            emailField.setError(NSLocalizedString("auth.error.empty_email", value: "Email is required", comment: ""))
        } else if !isValidEmail(email) {
            emailField.setError(NSLocalizedString("auth.error.invalid_email", value: "Invalid email address", comment: ""))
        } else {
            emailField.clearError()
        }
    }
    
    private func validateAllFields() -> Bool {
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email.isEmpty {
            emailField.setError(NSLocalizedString("auth.error.empty_email", value: "Email is required", comment: ""))
            return false
        } else if !isValidEmail(email) {
            emailField.setError(NSLocalizedString("auth.error.invalid_email", value: "Invalid email address", comment: ""))
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
    // MARK: - Network
    private func performSendResetLink() {
        setLoading(true)
        
        let email = emailField.text ?? ""
        
        Task {
            do {
                try await AppDependencies.shared.authRepository.forgotPassword(email: email)
                
                await MainActor.run {
                    setLoading(false)
                    showSuccessAlert()
                }
            } catch {
                await MainActor.run {
                    handleError(error)
                    setLoading(false)
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let errorMessage = (error as NSError).localizedDescription
        emailField.setError(errorMessage)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func setLoading(_ loading: Bool) {
        sendButton.isEnabled = !loading
        emailField.isEnabled = !loading
        
        if loading {
            loadingIndicator.startAnimating()
            sendButton.setTitle("", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            sendButton.setTitle(NSLocalizedString("auth.forgot.button", value: "Send Reset Link", comment: ""), for: .normal)
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("auth.forgot.success.title", value: "Email Sent!", comment: ""),
            message: NSLocalizedString("auth.forgot.success.message", value: "Check your inbox for the password reset link", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("general.ok", value: "OK", comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}
