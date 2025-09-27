//
//  LoginViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - UI
    private let scroll = UIScrollView()
    private let content = UIStackView()

    private let logoImageView = UIImageView(image: UIImage(named: "AppLogo"))
    private let titleLabel = UILabel()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let errorLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let activity = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        applyTheme()
        wireEvents()
        validateForm()
    }

    // MARK: - Build
    private func buildUI() {
        view.backgroundColor = AppColor.background

        // Scroll + content
        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scroll.addSubview(content)
        content.axis = .vertical
        content.alignment = .fill
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 32),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        // Logo
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.setContentHuggingPriority(.required, for: .vertical)
        logoImageView.isAccessibilityElement = true
        logoImageView.accessibilityLabel = NSLocalizedString("app.logo", comment: "")
        content.addArrangedSubview(logoImageView)
        logoImageView.heightAnchor.constraint(equalToConstant: 96).isActive = true

        // Título
        titleLabel.text = NSLocalizedString("auth.login.title", comment: "Iniciar sesión")
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        content.addArrangedSubview(titleLabel)

        // Campos
        styleTextField(emailField,
                       placeholder: NSLocalizedString("auth.email.placeholder", comment: "Correo electrónico"),
                       contentType: .username,
                       keyboard: .emailAddress,
                       isSecure: false)

        styleTextField(passwordField,
                       placeholder: NSLocalizedString("auth.password.placeholder", comment: "Contraseña"),
                       contentType: .password,
                       keyboard: .default,
                       isSecure: true)

        content.addArrangedSubview(emailField)
        content.addArrangedSubview(passwordField)

        emailField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Error
        errorLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        content.addArrangedSubview(errorLabel)

        // Botón + activity
        let btnContainer = UIView()
        btnContainer.translatesAutoresizingMaskIntoConstraints = false
        btnContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        content.addArrangedSubview(btnContainer)

        loginButton.setTitle(NSLocalizedString("auth.login.button", comment: "Iniciar sesión"), for: .normal)
        loginButton.layer.cornerRadius = 12
        loginButton.layer.masksToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false

        btnContainer.addSubview(loginButton)
        btnContainer.addSubview(activity)

        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: btnContainer.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: btnContainer.trailingAnchor),
            loginButton.topAnchor.constraint(equalTo: btnContainer.topAnchor),
            loginButton.bottomAnchor.constraint(equalTo: btnContainer.bottomAnchor),

            activity.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            activity.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -16)
        ])
        createAccountButton.setTitle(NSLocalizedString("auth.register.cta", comment: "Crear cuenta"), for: .normal)
        createAccountButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        createAccountButton.titleLabel?.adjustsFontForContentSizeCategory = true
        content.addArrangedSubview(createAccountButton)
        
        attachPasswordToggle(to: passwordField)

    }

    private func styleTextField(_ tf: UITextField,
                                placeholder: String,
                                contentType: UITextContentType,
                                keyboard: UIKeyboardType,
                                isSecure: Bool) {
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textContentType = contentType
        tf.keyboardType = keyboard
        tf.isSecureTextEntry = isSecure
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .none
        tf.layer.cornerRadius = 12
        tf.layer.masksToBounds = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        tf.font = UIFont.preferredFont(forTextStyle: .body)
        tf.adjustsFontForContentSizeCategory = true

        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: AppColor.textMuted]
        )
    }

    // MARK: - Theme
    private func applyTheme() {
        view.backgroundColor = AppColor.background
        titleLabel.textColor = AppColor.textPrimary

        [emailField, passwordField].forEach {
            $0.backgroundColor = AppColor.backgroundSecondary
            $0.textColor = AppColor.textPrimary
            $0.layer.borderWidth = 1
            $0.layer.borderColor = AppColor.border.cgColor
            $0.tintColor = AppColor.primary
        }

        errorLabel.textColor = .systemRed

        loginButton.backgroundColor = AppColor.primary
        loginButton.setTitleColor(AppColor.textPrimary, for: .normal)
        loginButton.tintColor = AppColor.background
        
        createAccountButton.setTitleColor(AppColor.primary, for: .normal)
        createAccountButton.tintColor = AppColor.primary

    }

    // MARK: - Events / Logic
    private func wireEvents() {
        emailField.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(onTapLogin), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(onTapShowRegister), for: .touchUpInside)
        emailField.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)

        emailField.addTarget(self, action: #selector(onEditingDidEnd(_:)), for: .editingDidEnd)
        passwordField.addTarget(self, action: #selector(onEditingDidEnd(_:)), for: .editingDidEnd)


    }

    @objc private func onTextChanged() {
        if !(emailField.text ?? "").isEmpty { touchedEmail = true }
        if !(passwordField.text ?? "").isEmpty { touchedPass = true }
        updateValidationUI()
    }

    @objc private func onEditingDidEnd(_ tf: UITextField) {
        if tf === emailField { touchedEmail = true }
        if tf === passwordField { touchedPass = true }
        updateValidationUI()
    }

    private func updateValidationUI() {
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pass  = passwordField.text ?? ""

        let emailOK = isValidEmail(email)
        let passOK  = pass.count >= 8

        loginButton.isEnabled = emailOK && passOK
        loginButton.alpha = loginButton.isEnabled ? 1.0 : 0.5

        clearInvalid([emailField, passwordField])
        errorLabel.isHidden = true

        // Mostrar errores inmediatos (solo si el campo fue “tocado” y hay valor)
        if touchedEmail && !email.isEmpty && !emailOK {
            markInvalid([emailField])
            showInlineError(NSLocalizedString("auth.error.invalid_email", comment: ""))
        } else if touchedPass && !pass.isEmpty && !passOK {
            markInvalid([passwordField])
            let msg = String(format: NSLocalizedString("auth.error.short_password", comment: ""), 8)
            showInlineError(msg)
        }
    }


    private func validateForm() {
        let emailOK = isValidEmail(emailField.text ?? "")
        let passOK  = (passwordField.text ?? "").count >= 8
        loginButton.isEnabled = emailOK && passOK
        loginButton.alpha = loginButton.isEnabled ? 1.0 : 0.5
    }

    @objc private func onTapLogin() {
        view.endEditing(true)
        setLoading(true)
        errorLabel.isHidden = true
        clearInvalid([emailField, passwordField])
        
        if let msg = validationErrorLogin() {
                // Marca campos problemáticos
                var bad: [UITextField] = []
                if msg == NSLocalizedString("auth.error.empty_email", comment: "") ||
                   msg == NSLocalizedString("auth.error.invalid_email", comment: "") { bad.append(emailField) }
                if msg == NSLocalizedString("auth.error.empty_password", comment: "") ||
                   msg.contains("8") { bad.append(passwordField) }

                markInvalid(bad)
                showInlineError(msg)
                return
            }

        let identifier = emailField.text ?? ""
        let password = passwordField.text ?? ""

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let session = try await AppDependencies.shared.authRepository
                    .login(identifier: identifier, password: password)
                SessionManager.shared.save(session: session)
                // El SceneDelegate observará sessionDidChange y cerrará este modal.
            } catch {
                showError(error)
            }
            setLoading(true)
        }
    }

    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loginButton.alpha = loginButton.isEnabled ? 1.0 : 0.6
        loading ? activity.startAnimating() : activity.stopAnimating()
    }

    private func showError(_ error: Error) {
        errorLabel.text = (error as NSError).localizedDescription
        errorLabel.isHidden = false
    }

    private func isValidEmail(_ s: String) -> Bool {
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return s.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
    private let createAccountButton = UIButton(type: .system)
    
    @objc private func onTapShowRegister() {
        let reg = RegisterViewController()
        reg.title = NSLocalizedString("auth.register.title", comment: "")
        reg.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissRegister)
        )
        let nav = UINavigationController(rootViewController: reg)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func dismissRegister() {
        dismiss(animated: true)
    }

    
    private func showInlineError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        UIAccessibility.post(notification: .announcement, argument: message)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func markInvalid(_ fields: [UITextField]) {
        fields.forEach {
            $0.layer.borderColor = UIColor.systemRed.cgColor
            $0.layer.borderWidth = 1
        }
    }

    private func clearInvalid(_ fields: [UITextField]) {
        fields.forEach {
            $0.layer.borderColor = AppColor.border.cgColor
            $0.layer.borderWidth = 1
        }
    }
    
    private var touchedEmail = false
    private var touchedPass  = false

    
    
    private func validationErrorLogin() -> String? {
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pass  = passwordField.text ?? ""

        if email.isEmpty { return NSLocalizedString("auth.error.empty_email", comment: "") }
        if !isValidEmail(email) { return NSLocalizedString("auth.error.invalid_email", comment: "") }
        if pass.isEmpty { return NSLocalizedString("auth.error.empty_password", comment: "") }
        if pass.count < 8 {
            return String(format: NSLocalizedString("auth.error.short_password", comment: ""), 8)
        }
        return nil
    }

    private func attachPasswordToggle(to tf: UITextField) {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = AppColor.textMuted
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        tf.rightView = btn
        tf.rightViewMode = .always
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        // Soporta uno o varios campos con ojito
        let fields: [UITextField] = [passwordField]
        guard let tf = fields.first(where: { $0.rightView === sender }) else { return }

        tf.isSecureTextEntry.toggle()
        sender.setImage(UIImage(systemName: tf.isSecureTextEntry ? "eye.slash" : "eye"), for: .normal)

        // Truco para mantener el cursor visible al cambiar isSecureTextEntry
        let txt = tf.text
        tf.text = nil
        tf.text = txt
    }


}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
