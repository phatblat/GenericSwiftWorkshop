//
//  Model.swift
//  GenericSwiftWorkshop
//
//  Created by Ben Chatelain on 8/25/19.
//  Copyright © 2019 Ben Chatelain. All rights reserved.
//

import Foundation

protocol IDType: Codable, Hashable {
    associatedtype Value
    var value: Value { get }
    init(value: Value)
}

extension IDType {
    init(_ value: Value) { self.init(value: value) }
}

struct User: Codable, Hashable {
    struct ID: IDType { let value: Int }
    let id: ID
    let name: String
}

struct Document: Codable, Hashable {
    struct ID: IDType { let value: String }
    let id: ID
    let title: String
}

let user = User(id: User.ID(1), name: "Alice")
