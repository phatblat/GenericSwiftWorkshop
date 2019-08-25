//
//  Client.swift
//  GenericSwiftWorkshop
//
//  Created by Ben Chatelain on 8/25/19.
//  Copyright © 2019 Ben Chatelain. All rights reserved.
//

import Foundation

final class Client {
    let baseURL = URL(string: "file:///")!
    
    /// GET /user/<id>
    func fetchUser(id: Int, completion: @escaping (Result<User, Error>) -> Void) -> URLSessionTask {
        let urlRequest = URLRequest(url: baseURL
            .appendingPathComponent("user")
            .appendingPathComponent("\(id)")
        )
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let decoder = JSONDecoder()
                completion(Result {
                    try decoder.decode(User.self, from: data)
                })
            }
        }
        task.resume()
        return task
    }
}
