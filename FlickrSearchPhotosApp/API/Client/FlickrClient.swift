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

final class FlickrClient {
    private lazy var baseURL: URL? = {
        guard let url = URL(string: "https://www.flickr.com/services/rest/") else {
            return nil
        }
        return url
    }()
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetch(with request: PhotoRequest,
               page: Int,
               completion: @escaping (Result<PagedPhotosResponse, Error>) -> Void) {
        guard let baseURL = baseURL else {
            return
        }
        
        let urlRequest = URLRequest(url: baseURL)
        let parameters = ["page": "\(page)"].merging(request.parameters, uniquingKeysWith: +)
        
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
