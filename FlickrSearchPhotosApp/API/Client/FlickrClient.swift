//
//  FlickrClient.swift
//  FlickrSearchPhotosApp
//
//  Created by Mihai Eros on 05.06.2022.
//

import Foundation

enum FlickrClientError: Error {
    case badNetwork
    case badDecoding
    case badRequestEncoding
}

private enum Constants {
    static let baseUrlString = "https://www.flickr.com/services/rest/"
    static let pageKey = "page"
}

final class FlickrClient {
    /// Private
    private lazy var baseURL: URL? = {
        guard let url = URL(string: Constants.baseUrlString) else {
            return nil
        }
        return url
    }()
    /// Properties
    let session: URLSession
    
    // MARK: - Initializer
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Fetch method
    
    func fetch(with request: PhotoRequest,
               page: Int,
               completion: @escaping (Result<PagedPhotosResponse, Error>) -> Void) {
        guard let baseURL = baseURL else {
            return
        }
        
        let urlRequest = URLRequest(url: baseURL)
        let parameters = [Constants.pageKey: "\(page)"].merging(request.parameters, uniquingKeysWith: +)
        
        guard let encodedURLRequest = urlRequest.encode(with: parameters) else {
            completion(.failure(FlickrClientError.badRequestEncoding))
            return
        }
        
        session.dataTask(with: encodedURLRequest, completionHandler: { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                completion(Result.failure(FlickrClientError.badNetwork))
                return
            }
            
            guard let decodedResponse = try? JSONDecoder().decode(PagedPhotosResponse.self, from: data) else {
                completion(Result.failure(FlickrClientError.badDecoding))
                return
            }
            
            completion(Result.success(decodedResponse))
        }).resume()
    }
}
