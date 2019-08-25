//
//  TypeErasers.swift
//  GenericSwiftWorkshop
//
//  Created by Ben Chatelain on 8/25/19.
//  Copyright © 2019 Ben Chatelain. All rights reserved.
//

import Foundation

protocol Processor {
    associatedtype Input
    associatedtype Output
    func process(from input: Input) -> Output
}

struct AnyProcessor<Input, Output>: Processor {
    let base: Any

    private let _process: (Input) -> Output

    init<P: Processor>(_ processor: P)
    where
        P.Input == Input,
        P.Output == Output
    {
        _process = processor.process
        base = processor
    }

    func process(from input: Input) -> Output {
        return _process(input)
    }
}

struct SomeProcessor: Processor {
    typealias Input = Int
    typealias Output = String
    func process(from input: Int) -> String { return "" }
}

let p = AnyProcessor(SomeProcessor())
let s = p.base as? SomeProcessor
