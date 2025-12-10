//
//  OutlinedTextField.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/11/25.
//


import UIKit

final class OutlinedTextField: UIView {
    
    // MARK: - Properties
    var text: String? {
        get { textField.text }
        set {
            textField.text = newValue
            updateFloatingLabel()
        }
    }
    
    var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    
    var textContentType: UITextContentType? {
        get { textField.textContentType }
        set { textField.textContentType = newValue }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }
    
    var isEnabled: Bool = true {
        didSet {
            textField.isEnabled = isEnabled
            updateAppearance()
        }
    }
    
    private let placeholder: String
    private var onTextChanged: ((String?) -> Void)?
    private var onEditingDidEnd: (() -> Void)?
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let textField = UITextField()
    private let floatingLabel = UILabel()
    private let borderLayer = CAShapeLayer()
    private let errorLabel = UILabel()
    
    var rightView: UIView? {
        didSet {
            textField.rightView = rightView
            textField.rightViewMode = rightView != nil ? .always : .never
        }
    }
    
    // MARK: - State
    private var isFloating = false
    private var isInvalid = false
    
    // MARK: - Init
    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        setupUI()
        setupTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Container
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Border layer
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1
        containerView.layer.addSublayer(borderLayer)
        
        // TextField
        containerView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        
        // Floating label
        containerView.addSubview(floatingLabel)
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        floatingLabel.text = placeholder
        floatingLabel.font = .systemFont(ofSize: 16, weight: .regular)
        floatingLabel.isUserInteractionEnabled = false
        
        // Error label
        addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = .systemFont(ofSize: 12, weight: .regular)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        // Layout
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 56),
            
            // TextField
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            // Floating label
            floatingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            floatingLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Error label
            errorLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupTheme() {
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        textField.textColor = AppColor.textPrimary
        floatingLabel.textColor = AppColor.textMuted
        errorLabel.textColor = AppColor.error
        updateBorder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorderPath()
    }
    
    private func updateBorderPath() {
        let path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 8)
        borderLayer.path = path.cgPath
    }
    
    private func updateBorder() {
        if isInvalid {
            borderLayer.strokeColor = AppColor.error.cgColor
            borderLayer.lineWidth = 2
        } else if textField.isFirstResponder {
            borderLayer.strokeColor = AppColor.primary.cgColor
            borderLayer.lineWidth = 2
        } else {
            borderLayer.strokeColor = AppColor.border.cgColor
            borderLayer.lineWidth = 1.5
        }
    }
    
    private func updateFloatingLabel() {
        let shouldFloat = textField.isFirstResponder || !(textField.text?.isEmpty ?? true)
        
        if shouldFloat != isFloating {
            isFloating = shouldFloat
            animateFloatingLabel()
        }
    }
    
    private func animateFloatingLabel() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            if self.isFloating {
                // Floating state
                self.floatingLabel.transform = CGAffineTransform(translationX: 0, y: -38)
                    .scaledBy(x: 0.75, y: 0.75)
                self.floatingLabel.textColor = self.textField.isFirstResponder ? AppColor.primary : AppColor.textMuted
            } else {
                // Normal state
                self.floatingLabel.transform = .identity
                self.floatingLabel.textColor = AppColor.textMuted
            }
        }
    }
    
    private func updateAppearance() {
        updateBorder()
        textField.textColor = isEnabled ? AppColor.textPrimary : AppColor.textMuted
        floatingLabel.textColor = isEnabled ? AppColor.textMuted : AppColor.textMuted.withAlphaComponent(0.5)
    }
    
    // MARK: - Actions
    @objc private func textDidChange() {
        updateFloatingLabel()
        onTextChanged?(textField.text)
    }
    
    @objc private func editingDidBegin() {
        updateFloatingLabel()
        updateBorder()
    }
    
    @objc private func editingDidEnd() {
        updateFloatingLabel()
        updateBorder()
        onEditingDidEnd?()
    }
    
    // MARK: - Public Methods
    func setError(_ message: String?) {
        if let message = message {
            errorLabel.text = message
            errorLabel.isHidden = false
            isInvalid = true
        } else {
            errorLabel.isHidden = true
            isInvalid = false
        }
        updateBorder()
    }
    
    func clearError() {
        setError(nil)
    }
    
    func onTextChange(_ handler: @escaping (String?) -> Void) {
        self.onTextChanged = handler
    }
    
    func onEditingEnd(_ handler: @escaping () -> Void) {
        self.onEditingDidEnd = handler
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension OutlinedTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
