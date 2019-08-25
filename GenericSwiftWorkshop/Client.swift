//
//  Client.swift
//  GenericSwiftWorkshop
//
//  Created by Ben Chatelain on 8/25/19.
//  Copyright © 2019 Ben Chatelain. All rights reserved.
//

import Foundation

protocol Fetchable: Decodable {
    static var apiBase: String { get }
}

extension User: Fetchable {
    static var apiBase: String { return "user" }
}

extension Document: Fetchable {
    static var apiBase: String { return "document" }
}

final class Client {
    let baseURL = URL(string: "file:///")!
    
    /// GET /user/<id>
    func fetch<Model: Fetchable>(id: Int, completion: @escaping (Result<Model, Error>) -> Void) -> URLSessionTask {
        let urlRequest = URLRequest(url: baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        )
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let decoder = JSONDecoder()
                completion(Result {
                    try decoder.decode(Model.self, from: data)
                })
            }
        }
        task.resume()
        return task
    }
}

//let client = Client()
//client.fetch(User.self, id: 1) { (_) in
//
//}
