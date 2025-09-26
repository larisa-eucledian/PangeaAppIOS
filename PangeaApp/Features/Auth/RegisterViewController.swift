//
//  RegisterViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import UIKit

final class RegisterViewController: UIViewController {

    // MARK: UI
    private let scroll = UIScrollView()
    private let content = UIStackView()

    private let titleLabel = UILabel()
    private let nameField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let confirmField = UITextField()

    private let errorLabel = UILabel()
    private let registerButton = UIButton(type: .system)
    private let activity = UIActivityIndicatorView(style: .medium)

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        applyTheme()
        wireEvents()
        validateForm()
        setNavBarLogo()
    }

    // MARK: Build UI (programático)
    private func buildUI() {
        view.backgroundColor = AppColor.background

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
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 32),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        // Título
        titleLabel.text = NSLocalizedString("auth.register.title", comment: "Crear cuenta")
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        content.addArrangedSubview(titleLabel)

        // Campos
        styleTextField(nameField,
                       placeholder: NSLocalizedString("auth.name.placeholder", comment: "Nombre de usuario"),
                       contentType: .username,
                       keyboard: .default,
                       isSecure: false)

        styleTextField(emailField,
                       placeholder: NSLocalizedString("auth.email.placeholder", comment: "Correo electrónico"),
                       contentType: .emailAddress,
                       keyboard: .emailAddress,
                       isSecure: false)

        styleTextField(passwordField,
                       placeholder: NSLocalizedString("auth.password.placeholder", comment: "Contraseña"),
                       contentType: .newPassword,
                       keyboard: .default,
                       isSecure: true)

        styleTextField(confirmField,
                       placeholder: NSLocalizedString("auth.password.confirm.placeholder", comment: "Confirmar contraseña"),
                       contentType: .newPassword,
                       keyboard: .default,
                       isSecure: true)

        [nameField, emailField, passwordField, confirmField].forEach {
            content.addArrangedSubview($0)
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }

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

        registerButton.setTitle(NSLocalizedString("auth.register.button", comment: "Crear cuenta"), for: .normal)
        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false

        btnContainer.addSubview(registerButton)
        btnContainer.addSubview(activity)

        NSLayoutConstraint.activate([
            registerButton.leadingAnchor.constraint(equalTo: btnContainer.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: btnContainer.trailingAnchor),
            registerButton.topAnchor.constraint(equalTo: btnContainer.topAnchor),
            registerButton.bottomAnchor.constraint(equalTo: btnContainer.bottomAnchor),

            activity.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),
            activity.trailingAnchor.constraint(equalTo: registerButton.trailingAnchor, constant: -16)
        ])
        
        attachPasswordToggle(to: passwordField)
        attachPasswordToggle(to: confirmField)

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

        tf.font = UIFont.preferredFont(forTextStyle: .body)
        tf.adjustsFontForContentSizeCategory = true

        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: AppColor.textMuted]
        )
    }

    // MARK: Theme
    private func applyTheme() {
        view.backgroundColor = AppColor.background
        titleLabel.textColor = AppColor.textPrimary

        [nameField, emailField, passwordField, confirmField].forEach {
            $0.backgroundColor = AppColor.backgroundSecondary
            $0.textColor = AppColor.textPrimary
            $0.layer.borderWidth = 1
            $0.layer.borderColor = AppColor.border.cgColor
            $0.tintColor = AppColor.primary
        }

        errorLabel.textColor = .systemRed

        registerButton.backgroundColor = AppColor.primary
        registerButton.setTitleColor(AppColor.background, for: .normal)
        registerButton.tintColor = AppColor.background
    }

    // MARK: Events
    private func wireEvents() {
        [nameField, emailField, passwordField, confirmField].forEach {
            $0.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
        }
        registerButton.addTarget(self, action: #selector(onTapRegister), for: .touchUpInside)
        
        [nameField, emailField, passwordField, confirmField].forEach {
            $0.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
            $0.addTarget(self, action: #selector(onEditingDidEnd(_:)), for: .editingDidEnd)
        }

    }

    @objc private func onTextChanged() {
        if !(nameField.text ?? "").isEmpty     { touchedName = true }
        if !(emailField.text ?? "").isEmpty    { touchedEmail = true }
        if !(passwordField.text ?? "").isEmpty { touchedPass = true }
        if !(confirmField.text ?? "").isEmpty  { touchedConfirm = true }
        updateValidationUI()
    }

    @objc private func onEditingDidEnd(_ tf: UITextField) {
        if tf === nameField     { touchedName = true }
        if tf === emailField    { touchedEmail = true }
        if tf === passwordField { touchedPass = true }
        if tf === confirmField  { touchedConfirm = true }
        updateValidationUI()
    }

    private func updateValidationUI() {
        let name    = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email   = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pass    = passwordField.text ?? ""
        let confirm = confirmField.text ?? ""

        let nameOK   = name.count >= 2
        let emailOK  = isValidEmail(email)
        let passOK   = pass.count >= 8
        let matchOK  = confirm.isEmpty ? true : (pass == confirm)

        let enabled = nameOK && emailOK && passOK && (pass == confirm) && !name.isEmpty && !email.isEmpty
        registerButton.isEnabled = enabled
        registerButton.alpha = enabled ? 1.0 : 0.5

        clearInvalid([nameField, emailField, passwordField, confirmField])
        errorLabel.isHidden = true

        if touchedName && !name.isEmpty && !nameOK {
            markInvalid([nameField])
            showInlineError(NSLocalizedString("auth.error.short_name", comment: ""))
            return
        }
        if touchedEmail && !email.isEmpty && !emailOK {
            markInvalid([emailField])
            showInlineError(NSLocalizedString("auth.error.invalid_email", comment: ""))
            return
        }
        if touchedPass && !pass.isEmpty && !passOK {
            markInvalid([passwordField])
            let msg = String(format: NSLocalizedString("auth.error.short_password", comment: ""), 8)
            showInlineError(msg)
            return
        }
        if touchedConfirm && !confirm.isEmpty && !matchOK {
            markInvalid([passwordField, confirmField])
            showInlineError(NSLocalizedString("auth.error.password_mismatch", comment: ""))
            return
        }
    }


    private func validateForm() {
        let nameOK = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
        let emailOK = isValidEmail(emailField.text ?? "")
        let pass    = passwordField.text ?? ""
        let confirm = confirmField.text ?? ""
        let passOK  = pass.count >= 8 && pass == confirm

        let enabled = nameOK && emailOK && passOK
        registerButton.isEnabled = enabled
        registerButton.alpha = enabled ? 1.0 : 0.5
    }

    @objc private func onTapRegister() {
        view.endEditing(true)
        setLoading(true)
        errorLabel.isHidden = true
        
        if let msg = validationErrorRegister() {
                var bad: [UITextField] = []
                switch msg {
                case NSLocalizedString("auth.error.empty_name", comment: ""),
                     NSLocalizedString("auth.error.short_name", comment: ""):
                    bad = [nameField]
                case NSLocalizedString("auth.error.empty_email", comment: ""),
                     NSLocalizedString("auth.error.invalid_email", comment: ""):
                    bad = [emailField]
                case NSLocalizedString("auth.error.empty_password", comment: ""),
                     String(format: NSLocalizedString("auth.error.short_password", comment: ""), 8):
                    bad = [passwordField]
                case NSLocalizedString("auth.error.password_mismatch", comment: ""):
                    bad = [passwordField, confirmField]
                default: break
                }
                markInvalid(bad)
                showInlineError(msg)
                return
            }

        let username = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text ?? ""

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let session = try await AppDependencies.shared.authRepository
                    .register(username: username, email: email, password: password)
                SessionManager.shared.save(session: session)
                // SceneDelegate cerrará el modal por el observer.
            } catch {
                showError(error)
            }
            setLoading(true)
        }
    }

    private func setLoading(_ loading: Bool) {
        registerButton.isEnabled = !loading
        registerButton.alpha = registerButton.isEnabled ? 1.0 : 0.6
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
    
    private var touchedName    = false
    private var touchedEmail   = false
    private var touchedPass    = false
    private var touchedConfirm = false


    private func validationErrorRegister() -> String? {
        let name    = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email   = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pass    = passwordField.text ?? ""
        let confirm = confirmField.text ?? ""

        if name.isEmpty { return NSLocalizedString("auth.error.empty_name", comment: "") }
        if name.count < 2 { return NSLocalizedString("auth.error.short_name", comment: "") }
        if email.isEmpty { return NSLocalizedString("auth.error.empty_email", comment: "") }
        if !isValidEmail(email) { return NSLocalizedString("auth.error.invalid_email", comment: "") }
        if pass.isEmpty || confirm.isEmpty { return NSLocalizedString("auth.error.empty_password", comment: "") }
        if pass.count < 8 {
            return String(format: NSLocalizedString("auth.error.short_password", comment: ""), 8)
        }
        if pass != confirm { return NSLocalizedString("auth.error.password_mismatch", comment: "") }
        return nil
    }

    // MARK: - Password toggle
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
        let fields: [UITextField] = [passwordField, confirmField]
        guard let tf = fields.first(where: { $0.rightView === sender }) else { return }

        tf.isSecureTextEntry.toggle()
        sender.setImage(UIImage(systemName: tf.isSecureTextEntry ? "eye.slash" : "eye"), for: .normal)

        // Mantener el cursor al cambiar isSecureTextEntry
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
