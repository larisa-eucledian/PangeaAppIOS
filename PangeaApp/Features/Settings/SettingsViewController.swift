//
//  SettingsViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import UIKit

final class SettingsViewController: UITableViewController {
    @IBOutlet weak var logoutCell: UITableViewCell! // TODO: Conectar a la celda “Logout” en el Storyboard

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        if cell === logoutCell {
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
}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
