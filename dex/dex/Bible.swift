//
//  Bible.swift
//  dex
//
//  Created by AJ Caldwell on 1/18/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation

struct Verse: Equatable {
    var number: Int
    var text: String
}

struct Chapter: Equatable {
    var number: Int
    var verses: [Verse]
}

struct Book: Equatable {
    var name: String
    var chapters: [Chapter]
}
