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
