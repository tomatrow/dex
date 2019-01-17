//
//  Index.swift
//  dex
//
//  Created by AJ Caldwell on 1/16/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation

// Index for biblical reference 00 000 001
struct Index: ExpressibleByIntegerLiteral {
    var value: Int
    typealias IntegerLiteralType = Int

    init(integerLiteral value: Index.IntegerLiteralType) {
        self.init(value)
    }

    init(_ value: Int) {
        self.value = value
    }

    init() {
        self.init(1)
    }
}
