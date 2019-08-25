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
    private class _BoxBase<Input, Output>: Processor {
        var base: Any { fatalError() }
        func process(from input: Input) -> Output {
            fatalError()
        }
    }

    private class _Box<P: Processor>: _BoxBase<Input, Output>
    where
        P.Input == Input,
        P.Output == Output
    {
        let _base: P
        init(_ base: P) { self._base = base }

        override func process(from input: Input) -> Output {
            return _base.process(from: input)
        }
    }

    var base: Any { _box.base }
    private var _box: _BoxBase<Input, Output>

    init<P: Processor>(_ base: P)
    where
        P.Input == Input,
        P.Output == Output
    {
        self._box = _Box(base)
    }

    func process(from input: Input) -> Output {
        return self._box.process(from: input)
    }
}

struct SomeProcessor: Processor {
    typealias Input = Int
    typealias Output = String
    func process(from input: Int) -> String { return "" }
}

let p = AnyProcessor(SomeProcessor())
let s = p.base as? SomeProcessor
