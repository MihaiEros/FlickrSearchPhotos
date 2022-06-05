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
                    
                    if pagedResponse.page > 1 {
                        let indexPaths = self?.calculateIndexPathsToReload(from: pagedResponse.photos)
                        self?.delegate?.fetchingDidComplete(with: indexPaths)
                    } else {
                        var indices = [IndexPath]()
                        let photosCount = self?.photos.count
                        for row in 0..<(photosCount ?? 0) {
                            let index = IndexPath(row: row, section: 0)
                            indices.append(index)
                        }
                        self?.delegate?.fetchingDidComplete(with: indices)
                    }
                }
            }
        }
    }
}

class ImageLoadOperation: Operation {
    var image: UIImage?
    var loadingCompleteHandler: ((UIImage) -> Void)?
    
    private let _photo: Photo
    
    init(_ photo: Photo) {
        _photo = photo
    }
    
    override func main() {
        if isCancelled { return }
        
        guard let url = _photo.url else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            self.image = image
            if self.isCancelled { return }
            if let loadingCompleteHandler = self.loadingCompleteHandler {
                DispatchQueue.main.async {
                    loadingCompleteHandler(image)
                }
            }
        }.resume()
    }
}

extension Collection {
    subscript(safe index: Index) -> Iterator.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
