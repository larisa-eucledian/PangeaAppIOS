//
//  SettingsViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import UIKit

final class SettingsViewController: UITableViewController {
    @IBOutlet weak var videosCell: UITableViewCell!
    @IBOutlet weak var supportCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserHeader()

        // Listen for session changes (login/logout)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionDidChange),
            name: SessionManager.sessionDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func sessionDidChange() {
        print("⚙️ Settings: Session changed, refreshing header")
        setupUserHeader()
    }

    private func setupUserHeader() {
        print("⚙️ Settings: setupUserHeader called")
        print("⚙️ Settings: Session exists: \(SessionManager.shared.session != nil)")
        if let session = SessionManager.shared.session {
            print("⚙️ Settings: User email: '\(session.user.email)'")
            print("⚙️ Settings: User username: '\(session.user.username)'")
        }

        // Remove old header if exists
        tableView.tableHeaderView = nil

        guard let userEmail = SessionManager.shared.session?.user.email, !userEmail.isEmpty else {
            print("⚠️ Settings: No email found, header not shown")
            return
        }

        print("✅ Settings: Showing email header: \(userEmail)")
        let headerView = UIView()
        headerView.backgroundColor = AppColor.card

        let emailLabel = UILabel()
        emailLabel.text = userEmail
        emailLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emailLabel.textColor = AppColor.textPrimary
        emailLabel.textAlignment = .center
        emailLabel.numberOfLines = 0
        emailLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(emailLabel)

        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            emailLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])

        tableView.tableHeaderView = headerView

        // Force layout to calculate proper size
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        headerView.frame = CGRect(origin: .zero, size: size)
        tableView.tableHeaderView = headerView
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        if cell === videosCell {
            openVideos()
        } else if cell === supportCell {
            openSupport()
        } else if cell === logoutCell {
            showLogoutConfirmation()
        }
    }

    private func openVideos() {
        let urlString = "https://youtube.com/playlist?list=PLcd7uoNUhdwhQO8SVP8_QOOFcJq-bl-7V&si=GmDHy4kwy_WObd2-"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func openSupport() {
        let urlString = "https://api.whatsapp.com/send/?phone=5628298160"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: NSLocalizedString("settings.logout.title", comment: ""),
            message: NSLocalizedString("settings.logout.message", comment: ""),
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("settings.logout.confirm", comment: ""), style: .destructive) { _ in
            SessionManager.shared.clear()
        })
        present(alert, animated: true)
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
