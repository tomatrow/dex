//
//  MapViewModel.swift
//  dex
//
//  Created by AJ Caldwell on 1/21/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation

// Represents a list of _openable_ named lists.
struct MapViewModel {
    private var items: [Item]
    private var keyIndexMap: [String: Int]
    let model: [(String, [String])]

    var cellViewModels: [MyMapCellViewModel] {
        return items.map { item in
            var out = [MyMapCellViewModel.key(item.key)]
            if item.open {
                out.append(MyMapCellViewModel.list(item.list))
            }
            return out
        }.reduce([], +)
    }

    init(_ model: [(String, [String])]) {
        self.model = model
        items = [Item]()
        keyIndexMap = [String: Int]()

        for i in 0 ..< model.count {
            let tuple = model[i]
            let item = Item(key: tuple.0, list: tuple.1, open: false)
            items.append(item)
            keyIndexMap[tuple.0] = i
        }
    }

    private func getIndex(_ key: String) -> Int {
        guard let index = keyIndexMap[key] else { assert(false) }
        return index
    }

    mutating func open(_ key: String) {
        let index = getIndex(key)
        items[index].open = true
    }

    mutating func toggle(_ key: String) {
        let index = getIndex(key)
        items[index].open = !items[index].open
    }

    mutating func close(_ key: String) {
        let index = getIndex(key)
        items[index].open = false
    }
}

fileprivate struct Item {
    var key = ""
    var list = [String]()
    var open = false
}
