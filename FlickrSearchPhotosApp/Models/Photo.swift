//
//  Photo.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import UIKit

struct Photo: Decodable {
    let id: String
    let title: String
    let secret: String
    let server: String
    var url: URL? {
        URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")
    }
    
    /// `Description` used to see details about a `Photo` struct.
    var description: String {
        """
        
        id: \(id)
        title: \(title)
        secret: \(secret)
        server: \(server)
        URL: \(url?.absoluteString ?? "N/A")
        
        """
    }
}
