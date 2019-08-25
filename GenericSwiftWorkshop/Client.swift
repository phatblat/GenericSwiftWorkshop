//
//  Client.swift
//  GenericSwiftWorkshop
//
//  Created by Ben Chatelain on 8/25/19.
//  Copyright © 2019 Ben Chatelain. All rights reserved.
//

import Foundation

protocol Cancellable {
    func cancel()
}

extension URLSessionTask: Cancellable {}

// Making this a PAT means we can't have an array of them
protocol Fetchable: Decodable {
    associatedtype ID: IDType
    var id: ID { get }
    static var apiBase: String { get }
}

extension User: Fetchable {
    static var apiBase: String { return "user" }
}

extension Document: Fetchable {
    static var apiBase: String { return "document" }
}

protocol Transport {
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable
}

extension URLSession: Transport {
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        let task = dataTask(with: request) { (data, _, error) in
            if let error = error { completion(.failure(error)) }
            else if let data = data { completion(.success(data)) }
            else { assertionFailure("Unexpected neither error or data.") }
        }
        task.resume()
        return task
    }
}

var defaultTransport: Transport = TransportRef(URLSession.shared)

//extension Transport {
//    static var `default`: Transport { return URLSession.shared }
//}

final class Client {
    let baseURL = URL(string: "file:///")!
    let transport: Transport

    init(transport: Transport = defaultTransport) {
        self.transport = transport
    }

    /// GET /user/<id>
    func fetch<Model: Fetchable>(_: Model.Type = Model.self, id: Model.ID,
                                 completion: @escaping (Result<Model, Error>) -> Void) -> Cancellable {
        let urlRequest = URLRequest(url: baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        )

        return transport.send(request: urlRequest) { data in
            let decoder = JSONDecoder()
            completion(Result {
                try decoder.decode(Model.self, from: data.get())
            })
        }
    }
}

// Generic function
// gets specialized by compiler for all types used
// T must be concrete type
func process<T: Transport>(transport: T) {}

// Takes an existential
// compiler can't optimize for eech type of transport
func process(transport: Transport) {}

//let client = Client()
//client.fetch(User.self, id: User.ID(1)) { (Result<Fetchable, Error>) in
//    <#code#>
//}

/// Nested transport which adds headers
final class AddHeadersTransport: Transport {
    let base: Transport
    var headers: [String: String]

    init(transport: Transport = URLSession.shared) {
        self.base = transport
        headers = [:]
    }

    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        var newRequest = request
        for (key, value) in headers {
            newRequest.addValue(value, forHTTPHeaderField: key)
        }

        return base.send(request: request, completion: completion)
    }
}


/// Turns a value type into a reference type
final class TransportRef: Transport {
    var base: Transport
    init(_ base: Transport) { self.base = base }
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        base.send(request: request, completion: completion)
    }
}
