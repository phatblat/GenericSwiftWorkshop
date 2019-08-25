//
//  Model.swift
//  GenericSwiftWorkshop
//
//  Created by Ben Chatelain on 8/25/19.
//  Copyright © 2019 Ben Chatelain. All rights reserved.
//

import Foundation

//protocol IDType: Codable, Hashable {
//    associatedtype Value
//    var value: Value { get }
//    init(value: Value)
//}
//
//extension IDType {
//    init(_ value: Value) { self.init(value: value) }
//}

struct Identifier<Model, Value>
    where Value: Codable & Hashable
{
    let value: Value
    init(_ value: Value) { self.value = value }
}

extension Identifier: Codable, Hashable {
    init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(Value.self))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// Identifyable in stdlib?
protocol Identified: Codable {
    associatedtype IDType: Codable & Hashable
    typealias ID = Identifier<Self, IDType>
    var id: ID { get }
}

struct User: Identified, Hashable {
    typealias ID = Identifier<User, Int>
    let id: ID
    let name: String
}

struct Document: Codable, Hashable {
    typealias ID = Identifier<Document, String>
    let id: ID
    let title: String
}

let user = User(id: User.ID(1), name: "Alice")
