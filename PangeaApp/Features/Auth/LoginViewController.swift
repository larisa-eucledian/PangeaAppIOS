//
//  LoginViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "AppLogo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("auth.login.title", value: "Welcome to Pangea", comment: "")
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("auth.login.subtitle", value: "Sign in to continue", comment: "")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailField: OutlinedTextField = {
        let field = OutlinedTextField(placeholder: NSLocalizedString("auth.email.placeholder", value: "Email or username", comment: ""))
        field.keyboardType = .emailAddress
        field.textContentType = .username
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var passwordField: OutlinedTextField = {
        let field = OutlinedTextField(placeholder: NSLocalizedString("auth.password.placeholder", value: "Password", comment: ""))
        field.isSecureTextEntry = true
        field.textContentType = .password
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("auth.forgotPassword", value: "Forgot password?", comment: ""), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.contentHorizontalAlignment = .trailing
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("auth.login.button", value: "Login", comment: ""), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let registerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let registerPromptLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("auth.register.prompt", value: "Don't have an account?", comment: "")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("auth.register.link", value: "Register", comment: ""), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - State
    private var touchedEmail = false
    private var touchedPassword = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyTheme()
        setupActions()
        setupPasswordToggle()
    }

    // MARK: - Setup UI
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
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailField)
        contentView.addSubview(passwordField)
        contentView.addSubview(forgotPasswordButton)
        contentView.addSubview(loginButton)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(dividerView)
        contentView.addSubview(registerContainerView)
        
        registerContainerView.addSubview(registerPromptLabel)
        registerContainerView.addSubview(registerButton)
        
        // Layout constraints
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
            
            // Logo - 48dp top margin
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 48),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 180),
            logoImageView.heightAnchor.constraint(equalToConstant: 180),
            
            // Title - 24dp margin from logo
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Subtitle - 8dp margin from title
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Email field - 32dp margin from subtitle
            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Password field - 16dp margin from email
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Forgot password - 8dp margin from password
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Login button - 24dp margin from forgot password
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            
            // Divider - 32dp margin from login button
            dividerView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 32),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            // Register container - 24dp margin from divider
            registerContainerView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 24),
            registerContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Register prompt and button
            registerPromptLabel.leadingAnchor.constraint(equalTo: registerContainerView.leadingAnchor),
            registerPromptLabel.topAnchor.constraint(equalTo: registerContainerView.topAnchor),
            registerPromptLabel.bottomAnchor.constraint(equalTo: registerContainerView.bottomAnchor),
            
            registerButton.leadingAnchor.constraint(equalTo: registerPromptLabel.trailingAnchor, constant: 4),
            registerButton.trailingAnchor.constraint(equalTo: registerContainerView.trailingAnchor),
            registerButton.topAnchor.constraint(equalTo: registerContainerView.topAnchor),
            registerButton.bottomAnchor.constraint(equalTo: registerContainerView.bottomAnchor)
        ])
    }

    // MARK: - Theme
    private func applyTheme() {
        titleLabel.textColor = AppColor.textPrimary
        subtitleLabel.textColor = AppColor.textMuted
        forgotPasswordButton.setTitleColor(AppColor.primary, for: .normal)
        loginButton.backgroundColor = AppColor.primary
        loginButton.setTitleColor(.white, for: .normal)
        dividerView.backgroundColor = AppColor.border
        registerPromptLabel.textColor = AppColor.textMuted
        registerButton.setTitleColor(AppColor.primary, for: .normal)
        loadingIndicator.color = .white
    }

    // MARK: - Actions
    private func setupActions() {
        emailField.onTextChange { [weak self] _ in
            self?.touchedEmail = true
            self?.validateForm()
        }
        
        passwordField.onTextChange { [weak self] _ in
            self?.touchedPassword = true
            self?.validateForm()
        }
        
        emailField.onEditingEnd { [weak self] in
            self?.touchedEmail = true
            self?.validateEmailField()
        }
        
        passwordField.onEditingEnd { [weak self] in
            self?.touchedPassword = true
            self?.validatePasswordField()
        }
        
        loginButton.addTarget(self, action: #selector(onLoginTap), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(onForgotPasswordTap), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(onRegisterTap), for: .touchUpInside)
    }
    
    private func setupPasswordToggle() {
        let toggleButton = UIButton(type: .system)
        toggleButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        toggleButton.tintColor = AppColor.textMuted
        toggleButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordField.rightView = toggleButton
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func onLoginTap() {
        view.endEditing(true)
        
        emailField.clearError()
        passwordField.clearError()
        
        guard validateAllFields() else { return }
        
        performLogin()
    }
    
    @objc private func onForgotPasswordTap() {
        let forgotVC = ForgotPasswordViewController()
        forgotVC.title = NSLocalizedString("auth.forgot.title", value: "Forgot Password", comment: "")
        forgotVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissModal)
        )
        let nav = UINavigationController(rootViewController: forgotVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(nav, animated: true)
    }
    
    @objc private func onRegisterTap() {
        let registerVC = RegisterViewController()
        registerVC.title = NSLocalizedString("auth.register.title", value: "Create Account", comment: "")
        registerVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissModal)
        )
        let nav = UINavigationController(rootViewController: registerVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    // MARK: - Validation
    private func validateForm() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        let isValid = isValidEmail(email) && password.count >= 8
        loginButton.isEnabled = isValid
        loginButton.alpha = isValid ? 1.0 : 0.5
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
    
    private func validatePasswordField() {
        guard touchedPassword else { return }
        let password = passwordField.text ?? ""
        
        if password.isEmpty {
            passwordField.setError(NSLocalizedString("auth.error.empty_password", value: "Password is required", comment: ""))
        } else if password.count < 8 {
            let message = String(format: NSLocalizedString("auth.error.short_password", value: "Password must be at least %d characters", comment: ""), 8)
            passwordField.setError(message)
        } else {
            passwordField.clearError()
        }
    }
    
    private func validateAllFields() -> Bool {
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text ?? ""
        
        var isValid = true
        
        if email.isEmpty {
            emailField.setError(NSLocalizedString("auth.error.empty_email", value: "Email is required", comment: ""))
            isValid = false
        } else if !isValidEmail(email) {
            emailField.setError(NSLocalizedString("auth.error.invalid_email", value: "Invalid email address", comment: ""))
            isValid = false
        }
        
        if password.isEmpty {
            passwordField.setError(NSLocalizedString("auth.error.empty_password", value: "Password is required", comment: ""))
            isValid = false
        } else if password.count < 8 {
            let message = String(format: NSLocalizedString("auth.error.short_password", value: "Password must be at least %d characters", comment: ""), 8)
            passwordField.setError(message)
            isValid = false
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
    // MARK: - Network
    private func performLogin() {
        setLoading(true)
        
        let identifier = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        Task {
            do {
                let session = try await AppDependencies.shared.authRepository
                    .login(identifier: identifier, password: password)
                SessionManager.shared.save(session: session)
                // Navigation handled by SceneDelegate observer
            } catch {
                await MainActor.run {
                    self.handleLoginError(error)
                    self.setLoading(false)
                }
            }
        }
    }
    
    private func handleLoginError(_ error: Error) {
        let errorMessage = (error as NSError).localizedDescription
        
        // Show error on password field (common UX pattern)
        passwordField.setError(errorMessage)
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        emailField.isEnabled = !loading
        passwordField.isEnabled = !loading
        
        if loading {
            loadingIndicator.startAnimating()
            loginButton.setTitle("", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            loginButton.setTitle(NSLocalizedString("auth.login.button", value: "Login", comment: ""), for: .normal)
        }
    }
}
