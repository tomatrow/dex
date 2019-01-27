//
//  MapCellViewModel.swift
//  dex
//
//  Created by AJ Caldwell on 1/24/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation

enum MapCellViewModel: CustomStringConvertible {
    case key(MapItem)
    case list([MapItem])

    var identifier: String {
        switch self {
        case .key:
            return "HeadingCell"
        case .list:
            return "SubheadingCell"
        }
    }

    var description: String {
        switch self {
        case let .key(item):
            return item.title
        case let .list(items):
            return items.map { $0.title }.joined(separator: ",")
        }
    }
}
