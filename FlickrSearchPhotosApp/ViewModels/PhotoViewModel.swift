//
//  PhotoViewModel.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import UIKit

protocol PhotoViewModelDelegate: AnyObject {
    func fetchingDidComplete(with newIndexPaths: [IndexPath]?)
    func fetchingDidFail(with reason: String)
}

final class PhotoViewModel {
    /// Private
    private weak var delegate: PhotoViewModelDelegate?
    
    private var dataTask: URLSessionDataTask?
    private var photos = [Photo]()
    private var currentPage = 1
    private var total = 0
    private var isFetchingInProgress = false
    
    private lazy var client: FlickrClient = {
        FlickrClient()
    }()
    
    /// Internal
    let request: PhotoRequest
    
    /// Computed
    var totalCount: Int {
        total
    }
    
    var currentCount: Int {
        photos.count
    }
    
    // MARK: - Initializer
    
    init(request: PhotoRequest, delegate: PhotoViewModelDelegate) {
        self.request = request
        self.delegate = delegate
    }
    
    // MARK: - Photos
    
    func photo(at index: Int) -> Photo? {
        photos[safe: index]
    }
    
    private func calculateIndexPathsToReload(from newPhotos: [Photo]) -> [IndexPath] {
        let startIndex = photos.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        
        return (startIndex..<endIndex).map {
            IndexPath(row: $0, section: 0)
        }
    }
    
    func clearAllPhotos() {
        photos = [Photo]()
    }

    
    // MARK: Data fetch
    
    func fetchPhotos() {
        guard !isFetchingInProgress else {
            return
        }
        
        isFetchingInProgress = true
        
        client.fetch(with: request, page: currentPage) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.isFetchingInProgress = false
                    self?.delegate?.fetchingDidFail(with: error.localizedDescription)
                }
            case .success(let pagedResponse):
                DispatchQueue.main.async { [weak self] in
                    /// See https://www.flickr.com/groups/51035612836@N01/discuss/72157631512108069/
                    /// `total` value is inconsistent between `pages`
                    /// Workaround: only assign for first page the total number of photos.
                    /// Otherwise `UIKit` will complain when reloading items at [IndexPath] and fall back to `reloadData()`.
                    if self?.currentPage == 1 {
                        self?.total = pagedResponse.totalPhotos
                    }
                    
                    self?.currentPage += 1
                    self?.isFetchingInProgress = false
                    
                    self?.photos.append(contentsOf: pagedResponse.photos)
                    
                    let indexPaths = self?.calculateIndexPathsToReload(from: pagedResponse.photos)
                    self?.delegate?.fetchingDidComplete(with: indexPaths)
                }
            }
        }
    }
}
