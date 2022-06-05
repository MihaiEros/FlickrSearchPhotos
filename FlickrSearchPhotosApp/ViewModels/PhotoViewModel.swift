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
    
    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    private func calculateIndexPathsToReload(from newPhotos: [Photo]) -> [IndexPath] {
        let startIndex = photos.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        
        return (startIndex..<endIndex).map {
            IndexPath(row: $0, section: 0)
        }
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
                    if self?.currentPage == 1 {
                        self?.total = pagedResponse.totalPhotos
                    }
                    
                    self?.currentPage += 1
                    self?.isFetchingInProgress = false
                    
                    self?.photos.append(contentsOf: pagedResponse.photos)
                    
                    if pagedResponse.page > 1 {
                        let indexPaths = self?.calculateIndexPathsToReload(from: pagedResponse.photos)
                        self?.delegate?.fetchingDidComplete(with: indexPaths)
                    } else {
                        self?.delegate?.fetchingDidComplete(with: .none)
                    }
                }
            }
        }
    }
}
