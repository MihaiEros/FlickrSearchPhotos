//
//  ImageLoadOperation.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 06.06.2022.
//

import UIKit

final class ImageLoadOperation: Operation {
    /// Internal
    var image: UIImage?
    var loadingCompleteHandler: ((UIImage) -> Void)?
    
    /// Private
    private let _photo: Photo
    
    // MARK: - Initializer
    
    init(_ photo: Photo) {
        _photo = photo
    }
    
    // MARK: - Main
    
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
