//
//  Commentary.swift
//  dex
//
//  Created by AJ Caldwell on 12/20/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import Foundation

struct Commentary: Codable, Equatable {
    var info: Info
    var markup: String
}

func < (left: Commentary, right: Commentary) -> Bool {
    return left.info < right.info
}
