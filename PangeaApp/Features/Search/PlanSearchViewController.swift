//
//  PlanSearchViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

import UIKit
private var didApplyInitialSnapshot = false


final class PlanSearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    enum Mode: Int { case single = 0, multi = 1 }
    enum Section: Hashable { case main }

    var repository: PlansRepository?

    private var mode: Mode = .single
    private var query = ""
    private var rows: [CountryRow] = []

    @IBOutlet weak var modeSegmented: UISegmentedControl!
    
    @IBOutlet weak var countriesTableView: UITableView!
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var ds: UITableViewDiffableDataSource<Section, CountryRow>!

    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBarLogo()

        if repository == nil {
           repository = AppDependencies.shared.plansRepository
        }

        title = NSLocalizedString("title.countries", comment: "")
        view.backgroundColor = .systemBackground

        countriesTableView.register(CountryCell.self, forCellReuseIdentifier: "CountryCell")
            
        countriesTableView.delegate = self
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .done
        navigationItem.searchController = nil

        ds = UITableViewDiffableDataSource<Section, CountryRow>(tableView: countriesTableView) { tv, ip, item in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "CountryCell", for: ip) as? CountryCell else {
                return UITableViewCell()
            }
            cell.configure(with: item)
            return cell
               }
               countriesTableView.dataSource = ds

               modeSegmented.selectedSegmentIndex = 0
               fetchAndRender()
        
            view.backgroundColor = AppColor.background
            countriesTableView.backgroundColor = .clear
            countriesTableView.separatorColor = AppColor.border

            // UISegmentedControl
            modeSegmented.backgroundColor = AppColor.backgroundSecondary
            modeSegmented.selectedSegmentTintColor = AppColor.primary
            modeSegmented.setTitleTextAttributes([
                .foregroundColor: AppColor.textPrimary
            ], for: .normal)
            modeSegmented.setTitleTextAttributes([
                .foregroundColor: AppColor.textPrimary
            ], for: .selected)

            // UISearchBar
            let tf = searchBar.searchTextField
            tf.backgroundColor = AppColor.backgroundSecondary
            tf.textColor = AppColor.textPrimary
            tf.attributedPlaceholder = NSAttributedString(
                string: tf.placeholder ?? "",
                attributes: [.foregroundColor: AppColor.textMuted]
            )
            searchBar.tintColor = AppColor.primary  

           }

    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        mode = Mode(rawValue: sender.selectedSegmentIndex) ?? .single
        fetchAndRender()
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        query = searchText
        fetchAndRender()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        query = ""
        searchBar.resignFirstResponder()
        fetchAndRender()
    }

    private func fetchAndRender() {
            Task {
                guard let repo = repository else { return }
                do {
                    var list = try await repo.fetchCountries(
                        geography: mode == .single ? .local : nil,
                        search: query.isEmpty ? nil : query
                    )
                    if mode == .multi { list = list.filter { $0.geography != .local } }
                    await MainActor.run {
                        self.rows = list.sorted { $0.country_name < $1.country_name }
                        var snap = NSDiffableDataSourceSnapshot<Section, CountryRow>()
                        snap.appendSections([.main])
                        snap.appendItems(self.rows, toSection: .main)
                        
                        let shouldAnimate = (self.viewIfLoaded?.window != nil)
                            DispatchQueue.main.async {
                                self.ds?.apply(snap, animatingDifferences: shouldAnimate)
                            }
                    }
                } catch {
                    await MainActor.run {
                        let ac = UIAlertController(
                            title: "Error",
                            message: "No se pudo cargar countries_mock.json (\(error.localizedDescription))",
                            preferredStyle: .alert
                        )
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard let item = ds.itemIdentifier(for: indexPath) else { return }
        selectedCountryName = item.country_name
        performSegue(withIdentifier: "ShowPackages", sender: self)
    }

    private var selectedCountryName: String?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPackages",
           let dest = segue.destination as? PackagesViewController {
            dest.repository = repository
            guard let name = selectedCountryName else { return }
            dest.countryName = name
        }
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}
