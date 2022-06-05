//
//  PagedPhotosResponse.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import Foundation

struct PagedPhotosResponse: Decodable {
    private let wrappedResponse: WrapperPagedPhotosResponse

    var page: Int {
        wrappedResponse.page
    }

    var pages: Int {
        wrappedResponse.pages
    }

    var perPage: Int {
        wrappedResponse.perPage
    }

    var totalPhotos: Int {
        wrappedResponse.totalPhotos
    }

    var photos: [Photo] {
        wrappedResponse.photos
    }
    
    enum CodingKeys: String, CodingKey {
        case wrappedResponse = "photos"
    }
}

private struct WrapperPagedPhotosResponse: Decodable {
    let page: Int
    let pages: Int
    let perPage: Int
    let totalPhotos: Int
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case totalPhotos = "total"
        case photos = "photo"
    }
}
