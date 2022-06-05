//
//  Collection+.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Iterator.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
