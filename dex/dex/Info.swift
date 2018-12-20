//
//  Info.swift
//  dex
//
//  Created by AJ Caldwell on 12/20/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import Foundation

// oh my gosh, yes.
// https://www.hackingwithswift.com/example-code/language/how-to-convert-json-into-swift-objects-using-codable

struct Info: Codable, CustomStringConvertible {
    var book: String
    var chapters: [Int]
    var volume: Int?
    var description: String {
        let left = volume != nil ? "\(volume!) " : ""
        let center = book.capitalized
        let right = chapters.count > 1 ? "\(chapters.first!)-\(chapters.last!)" : chapters.first!.description

        return "\(left)\(center):\(right)"
    }
}

func < (left: Info, right: Info) -> Bool {
    if left.book != right.book {
        return left.book < right.book
    }

    // same book
    if left.volume != right.volume {
        if left.volume == nil {
            return false
        } else if right.volume == nil {
            return true
        }
        return left.volume! < right.volume!
    }

    // same volume too
    return left.chapters.first! < right.chapters.first!
}
