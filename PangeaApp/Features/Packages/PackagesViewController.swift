//
//  PackagesViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

import UIKit

enum PackageFilter {
    case onlyData
    case dataCalls
    case unlimitedData
    case all
}

final class PackagesViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate {
    enum Section: Hashable { case main }

    var repository: PlansRepository?
    var countryName: String!

    private var all: [PackageRow] = []
    private var filtered: [PackageRow] = []
    private var query = ""
    private var ds: UITableViewDiffableDataSource<Section, PackageRow>!
    private var currentFilter: PackageFilter = .all

    @IBOutlet weak var onlyDataButton: UIButton!
    
    @IBAction func filterOnlyDataTapped(_ sender: UIButton) {
        currentFilter = .onlyData
        applyFilter()
        refreshChipStyles()
    }
    
    @IBOutlet weak var dataCallsButton: UIButton!
    
    
    @IBAction func filterDataCallsTapped(_ sender: UIButton) {
        currentFilter = .dataCalls
        applyFilter()
        refreshChipStyles()
    }
    
    
    @IBOutlet weak var unlimitedButton: UIButton!
    
    @IBAction func filterUnlimitedTapped(_ sender: UIButton) {
        currentFilter = .unlimitedData
        applyFilter()
        refreshChipStyles()
    }
    
    @IBOutlet weak var packagesTableView: UITableView!

    required init?(coder: NSCoder) { super.init(coder: coder) }

        override func viewDidLoad() {
            super.viewDidLoad()
            setNavBarLogo()

            if repository == nil {
                repository = AppDependencies.shared.plansRepository
            }

            precondition(repository != nil && countryName != nil, "Falta inyección")

            title = NSLocalizedString("title.packages", comment: "")
            view.backgroundColor = .systemBackground

            // Search en la NavBar
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            navigationItem.hidesSearchBarWhenScrolling = false

            let sc = UISearchController(searchResultsController: nil)
            sc.obscuresBackgroundDuringPresentation = false
            sc.searchBar.placeholder = NSLocalizedString("search.packages.placeholder", comment: "")
            sc.searchResultsUpdater = self
            navigationItem.searchController = sc
            definesPresentationContext = true
            
            onlyDataButton.styleAsChip(selected: currentFilter == .onlyData)
            dataCallsButton.styleAsChip(selected: currentFilter == .dataCalls)
            unlimitedButton.styleAsChip(selected: currentFilter == .unlimitedData)


            packagesTableView.delegate = self
            packagesTableView.rowHeight = UITableView.automaticDimension
            packagesTableView.estimatedRowHeight = 88


            ds = UITableViewDiffableDataSource<Section, PackageRow>(tableView: packagesTableView) { [weak self] tv, ip, item in
                        guard
                            let self = self,
                            let cell = tv.dequeueReusableCell(withIdentifier: "PackageCell", for: ip) as? PackageCell
                        else { return UITableViewCell() }

                        cell.configure(countryName: self.countryName, item: item)
                        cell.accessoryType = .disclosureIndicator
                        return cell
                    }
                    packagesTableView.dataSource = ds

                    load()
            
            view.backgroundColor = AppColor.background
            packagesTableView.backgroundColor = .clear
            packagesTableView.separatorColor = AppColor.border

            // Search (UISearchController)
            if let tf = navigationItem.searchController?.searchBar.searchTextField {
                tf.backgroundColor = AppColor.backgroundSecondary
                tf.textColor = AppColor.textPrimary
                tf.attributedPlaceholder = NSAttributedString(
                    string: tf.placeholder ?? "",
                    attributes: [.foregroundColor: AppColor.textMuted]
                )
            }
            navigationController?.navigationBar.tintColor = AppColor.primary

                }

    private func load() {
           Task {
               do {
                   guard let repository else { return }
                   let rows = try await repository.fetchPackages(countryName: countryName)
                   await MainActor.run {
                       self.all = rows
                       self.applyFilter()
                   }
               } catch {
                   print("packages error:", error) // TODO: mostrar alerta localizada
               }
           }
       }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let newQuery = searchController.searchBar.text ?? ""
        guard newQuery != query else { return }
        query = newQuery
        applyFilter()
    }

    private func applyFilter() {
        var result = all

        if !query.isEmpty {
            result = result.filter { $0.package.localizedCaseInsensitiveContains(query) }
        }

        switch currentFilter {
        case .all:
            break
        case .onlyData:
            result = result.filter { ($0.withCall ?? false) == false && ($0.withSMS ?? false) == false }
        case .dataCalls:
            result = result.filter { ($0.withCall ?? false) || ($0.withSMS ?? false) }
        case .unlimitedData:
            result = result.filter { $0.isUnlimited }
        }

        filtered = result
        var snap = NSDiffableDataSourceSnapshot<Section, PackageRow>()
        snap.appendSections([.main])
        snap.appendItems(filtered, toSection: .main)
        ds.apply(snap, animatingDifferences: true)
    }

    private func refreshChipStyles() {
        onlyDataButton.styleAsChip(selected: currentFilter == .onlyData)
        dataCallsButton.styleAsChip(selected: currentFilter == .dataCalls)
        unlimitedButton.styleAsChip(selected: currentFilter == .unlimitedData)
    }


     // MARK: - UITableViewDelegate
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         defer { tableView.deselectRow(at: indexPath, animated: true) }
         if let pkg = ds.itemIdentifier(for: indexPath) {
             print("Seleccionaste paquete:", pkg.package_id) //TODO: Flujo de compra de paquete. Agregar al carrito?
         }
     }
 }
