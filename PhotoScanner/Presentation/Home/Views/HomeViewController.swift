//
//  HomeViewController.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import UIKit
import SwiftUI

protocol HomeViewControllerProtocol: AnyObject, Alertable {
    func updateProgress(_ progress: ScanProgress)
    func updateGroupedAssets(_ groupedAssets: GroupedAssets)
    func updateScanButtonState(isScanning: Bool)
    func showScanCompleted()
    func updatePhotoAccess(_ hasAccess: Bool)
}

final class HomeViewController: UIViewController, HomeViewControllerProtocol {
    
    private var collectionView: UICollectionView!
    private var progressContainerView: UIView!
    private var progressView: UIProgressView!
    private var progressLabel: UILabel!
    private var scanButton: UIBarButtonItem!
    private var clearButton: UIBarButtonItem!
    
    private lazy var viewModel = HomeViewModel()
    
    private var groupItems: [GroupItem] = []
    private var currentProgress: ScanProgress?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
        viewModel.viewDidLoad()
    }
    
    private func setupUI() {
        title = "Photo Scanner"
        view.backgroundColor = .systemGroupedBackground
        
        setupNavigationBar()
        setupProgressView()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        scanButton = UIBarButtonItem(
            title: "Start Scan",
            style: .done,
            target: self,
            action: #selector(scanButtonTapped)
        )
        scanButton.tintColor = .systemGreen
        
        clearButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearButtonTapped)
        )
        clearButton.tintColor = .systemRed
        
        navigationItem.rightBarButtonItem = scanButton
        navigationItem.leftBarButtonItem = clearButton
    }
    
    private func setupProgressView() {
        progressContainerView = UIView()
        progressContainerView.backgroundColor = .secondarySystemGroupedBackground
        progressContainerView.layer.cornerRadius = 12
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressContainerView)
        
        progressLabel = UILabel()
        progressLabel.text = "Ready to scan photos"
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        progressLabel.textColor = .label
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(progressLabel)
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            progressContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            progressLabel.topAnchor.constraint(equalTo: progressContainerView.topAnchor, constant: 16),
            progressLabel.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 16),
            progressLabel.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12),
            progressView.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GroupCollectionViewCell.self, forCellWithReuseIdentifier: "GroupCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func scanButtonTapped() {
        if viewModel.isScanning {
            viewModel.stopScanning()
        } else {
            viewModel.startScanning()
        }
    }
    
    @objc private func clearButtonTapped() {
        showConfirmationAlert(
            title: "Clear Data",
            message: "This will clear all scanning progress and grouped data. Continue?"
        ) { [weak self] in
            self?.viewModel.clearData()
            self?.scanButton.title = "Start"
            self?.progressLabel.text = "Ready to scan photos"
        }
    }
}

//MARK: - HomeViewControllerProtocol Methods
extension HomeViewController {
    func updateProgress(_ progress: ScanProgress) {
        progressLabel.text = progress.isComplete ?
        (progress.totalAssets == 0 && progress.processedAssets == 0) ? "Ready to scan photos" : "Scan completed! Found \(progress.totalAssets) photos." :
            "Scanning: \(progress.formattedProgress)"
        
        progressView.setProgress(Float(progress.percentage), animated: true)
        currentProgress = progress
    }
    
    func updateGroupedAssets(_ groupedAssets: GroupedAssets) {
        groupItems = groupedAssets.getAllGroupItems()
        collectionView.reloadData()
    }
    
    func updateScanButtonState(isScanning: Bool) {
        scanButton.title = isScanning ? "Stop" :
            (currentProgress?.isComplete == true ? "Start Scan" : "Continue")
        scanButton.tintColor = isScanning ? .systemRed : .systemGreen
    }
    
    func updatePhotoAccess(_ hasAccess: Bool) {
        if !hasAccess {
            showAlert(
                title: "Photo Access Required",
                message: "Please grant photo access to use this app."
            )
        }
    }
    
    func showErrorAlert(error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    func showScanCompleted() {
        showAlert(title: "Scan Completed", message: "You can now view your scanned photos.")
    }
}

//MARK: - CollectionView DataSource & Delegate Methods
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as? GroupCollectionViewCell else { return UICollectionViewCell() }
        
        if let groupItem = groupItems[safe: indexPath.row] {
            cell.configure(with: groupItem)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = groupItems[safe: indexPath.row] else { return }

        let groupDetailView = GroupDetailView(groupItem: item)
        let hostingController = UIHostingController(rootView: groupDetailView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 3 
        let availableWidth = collectionView.bounds.width - padding
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth, height: 120)
    }
}
