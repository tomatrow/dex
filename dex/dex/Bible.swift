//
//  Bible.swift
//  dex
//
//  Created by AJ Caldwell on 1/18/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation

struct Verse {
    var number: Int
    var text: String
}

struct Chapter {
    var number: Int
    var verses: [Verse]
}

struct Book {
    var name: String
    var chapters: [Chapter]
}
