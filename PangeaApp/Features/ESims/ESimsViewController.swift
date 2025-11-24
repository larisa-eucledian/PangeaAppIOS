//
//  ESimsViewController.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 23/11/25.
//

import UIKit

final class ESimsViewController: UIViewController, UITableViewDelegate {
    enum Section: Hashable { case main }
    
    var repository: ESimsRepository?

    private var esims: [ESimRow] = []
    private var ds: UITableViewDiffableDataSource<Section, ESimRow>!
    private var expectingNewESim = false
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let emptyStateView = UIView()
    private let emptyTitleLabel = UILabel()
    private let emptySubtitleLabel = UILabel()
    
    init(repository: ESimsRepository? = nil) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if repository == nil {
            repository = AppDependencies.shared.esimsRepository
        }

        title = NSLocalizedString("title.myesims", comment: "")
        view.backgroundColor = AppColor.background

        setupTableView()
        setupDataSource()
        setupEmptyState()
        load()

        // Listen for purchase notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePurchaseCompleted),
            name: .eSimPurchaseCompleted,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorColor = AppColor.border
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        // Register cell
        tableView.register(ESimCell.self, forCellReuseIdentifier: "ESimCell")
        
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupDataSource() {
        ds = UITableViewDiffableDataSource<Section, ESimRow>(tableView: tableView) { tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: "ESimCell", for: ip) as! ESimCell
            cell.configure(with: item)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        tableView.dataSource = ds
    }
    
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        emptyTitleLabel.text = NSLocalizedString("myesims.empty.title", comment: "")
        emptyTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        emptyTitleLabel.textColor = AppColor.textPrimary
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptySubtitleLabel.text = NSLocalizedString("myesims.empty.subtitle", comment: "")
        emptySubtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        emptySubtitleLabel.textColor = AppColor.textMuted
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 0
        emptySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [emptyTitleLabel, emptySubtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -40)
        ])
        
        emptyStateView.isHidden = true
    }
    
    @objc private func refreshTriggered() {
        load()
    }

    @objc private func handlePurchaseCompleted() {
        // Wait a moment for backend to process, then reload with retries
        print("🔔 Purchase completed notification received, will refresh eSIMs list")
        expectingNewESim = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.load()
        }
    }
    
    private func load(retryCount: Int = 0, previousCount: Int? = nil) {
        Task {
            do {
                guard let repository else { return }
                let rows = try await repository.fetchESims()

                // Check if we need to retry
                let shouldRetry: Bool
                if expectingNewESim && retryCount < 5 {
                    // After purchase: retry if count hasn't increased
                    let initialCount = previousCount ?? esims.count
                    shouldRetry = rows.count <= initialCount
                    if shouldRetry {
                        print("⏳ Waiting for new eSIM to appear... (\(retryCount + 1)/5)")
                    }
                } else {
                    // Normal load: only retry if empty
                    shouldRetry = rows.isEmpty && retryCount < 3
                    if shouldRetry {
                        print("⏳ eSIMs list empty, retrying... (\(retryCount + 1)/3)")
                    }
                }

                if shouldRetry {
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    self.load(retryCount: retryCount + 1, previousCount: previousCount ?? esims.count)
                    return
                }

                await MainActor.run {
                    // Clear the flag once we have the new eSIM
                    if self.expectingNewESim {
                        print("✅ New eSIM appeared after \(retryCount) retries")
                        self.expectingNewESim = false
                    }

                    self.esims = rows.sorted { esim1, esim2 in
                        if esim1.status == esim2.status {
                            return (esim1.createdAt ?? Date.distantPast) > (esim2.createdAt ?? Date.distantPast)
                        }
                        return esim1.status.rawValue < esim2.status.rawValue
                    }
                    self.applySnapshot()
                    self.refreshControl.endRefreshing()
                }
            } catch {
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                    self.showError(error)
                }
            }
        }
    }
    
    private func applySnapshot() {
        var snap = NSDiffableDataSourceSnapshot<Section, ESimRow>()
        snap.appendSections([.main])
        snap.appendItems(esims, toSection: .main)
        ds.apply(snap, animatingDifferences: true)
        
        // Show/hide empty state
        emptyStateView.isHidden = !esims.isEmpty
        tableView.isHidden = esims.isEmpty
    }
    
    private func showError(_ error: Error) {
        let ac = UIAlertController(
            title: NSLocalizedString("error.title", comment: ""),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard let esim = ds.itemIdentifier(for: indexPath) else { return }
        
        // Navigate programmatically (no segue)
        let detailVC = ESimDetailViewController(esim: esim, repository: repository)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
