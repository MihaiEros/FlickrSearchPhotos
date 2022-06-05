//
//  MainViewController.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import UIKit

final class MainViewController: UIViewController {
    /// Properties
    var viewModel: PhotoViewModel?
    /// Views
    lazy var collectionView: UICollectionView = {
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth / 2) - (5 * 2)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isHidden = true
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        return collection
    }()
    
    /// Private
    var loadingQueue = OperationQueue()
    var loadingOperations: [IndexPath: ImageLoadOperation] = [:]
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search photos using any word"
        controller.obscuresBackgroundDuringPresentation = true
        return controller
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "You didn't search anything yet."
        label.sizeToFit()
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isSearching: Bool = false {
        didSet {
            searchController.isActive = isSearching
            collectionView.isHidden = isSearching
            infoLabel.isHidden = !isSearching
        }
    }

    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
        setupSearchController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addConstraints()
    }

    // MARK: - Constraints
    
    private func addConstraints() {
        addCollectionViewConstraints()
        addInfoLabelConstraints()
    }
    
    private func addCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func addInfoLabelConstraints() {
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(infoLabel)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
    }
    
    private func setupSearchController() {
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("[DEBUG] Selected item at row: \(indexPath.row), section: \(indexPath.section):\n \(viewModel?.photo(at: indexPath.row)?.description ?? "n/a")")
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.totalCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("Dequeue for `PhotoCollectionViewCell` is failing!")
        }

        cell.configure(with: .none)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCollectionViewCell else { return }
        
        let updateCellClosure: (UIImage?) -> Void = { [weak self] image in
            guard let self = self else {
                return
            }
            
            cell.configure(with: image, animated: true)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        
        if let operation = loadingOperations[indexPath] {
            if let image = operation.image {
                cell.configure(with: image, animated: false)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                operation.loadingCompleteHandler = updateCellClosure
            }
        } else {
            if let photo = viewModel?.photo(at: indexPath.row) {
                let operation = ImageLoadOperation(photo)
                operation.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(operation)
                loadingOperations[indexPath] = operation
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let operation = loadingOperations[indexPath] {
            operation.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel?.fetchPhotos()
        }
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else {
             return
        }
        
        let request = PhotoRequest(searchTerm: searchTerm)
        viewModel = PhotoViewModel(request: request, delegate: self)
        viewModel?.fetchPhotos()
        
        isSearching = false
    }
}
