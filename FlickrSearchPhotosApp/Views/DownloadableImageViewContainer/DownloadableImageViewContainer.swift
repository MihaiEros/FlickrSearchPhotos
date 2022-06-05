//
//  DownloadableImageViewContainer.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import UIKit

final class DownloadableImageViewContainer: UIView {
    
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = 200
        cache.totalCostLimit = 30 * 1024 * 1024
        return cache
    }()
    
    var urlString: String?
    var dataTask: URLSessionDataTask?
    
    private var isDownloading = false
    
    let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addImageViewConstraints()
        
        addSubview(activityIndicator)
        addActivityIndicatorConstraints()
        
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addImageViewConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func addActivityIndicatorConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func startAnimating() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func downloadImage(url: URL?) {
        guard let url = url else {
            activityIndicator.isHidden = false
            return
        }
        
        urlString = url.absoluteString
        imageView.image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.isHidden = true
                self?.imageView.image = imageFromCache
                return
            }
        }
        
        isDownloading = true
        self.dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self, let data = data, let image = UIImage(data: data) else {
                    self?.isDownloading = false
                    self?.activityIndicator.isHidden = false
                    return
                }
            
                self.isDownloading = false
                self.activityIndicator.isHidden = true
                self.imageView.image = image
                self.imageCache.setObject(image, forKey: self.urlString as AnyObject)
            }
        }
        
        dataTask?.resume()
    }
    
    
    func cancelImageDownload() {
        guard isDownloading else { return }
        dataTask?.cancel()
        dataTask = nil
    }
    
}
