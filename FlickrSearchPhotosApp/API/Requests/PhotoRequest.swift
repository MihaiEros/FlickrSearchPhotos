//
//  PhotoRequest.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import Foundation

class PhotoRequest {
    var parameters: Parameters {
        let parameters = defaultParameters.merging(self._parameters, uniquingKeysWith: +)
        return parameters
    }
    
    let _parameters: Parameters
    
    init(searchTerm: String) {
        self._parameters = ["text": searchTerm]
    }
    
    private lazy var defaultParameters: Parameters = {
        return [
            "method": "flickr.photos.search",
            "api_key": "84291e09c736db071ec45426c55189b4",
            "format": "json",
            "nojsoncallback": "1",
            "per_page": "10"
        ]
    }()
}
