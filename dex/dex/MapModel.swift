//
//  MapModel.swift
//  dex
//
//  Created by AJ Caldwell on 1/26/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation

struct MapItem: Hashable, CustomStringConvertible {
    var title: String
    var subtitle: String?
    static func == (lhs: MapItem, rhs: MapItem) -> Bool {
        return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }

    init(_ title: String, _ subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
    }

    init(_ title: String) {
        self.init(title, nil)
    }

    init() {
        self.init("")
    }

    public var hashValue: Int { return title.hashValue }
    var description: String { return title }
}

typealias MapCoord = (MapItem, [MapItem])
typealias MapModel = [MapCoord]
