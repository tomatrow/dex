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
    let model: MapModel

    var cellViewModels: [MapCellViewModel] {
        return items.toMapCellViewModelList()
    }

    init(_ model: MapModel) {
        self.model = model
        items = [Item]()
        keyIndexMap = [String: Int]()

        for i in 0 ..< model.count {
            let tuple = model[i]
            let item = Item(key: tuple.0, list: tuple.1, fold: .closed)
            items.append(item)
            keyIndexMap[tuple.0.title] = i
        }
    }

    private func getIndex(_ key: String) -> Int {
        guard let index = keyIndexMap[key] else { assert(false) }
        return index
    }

    mutating func open(_ key: String) {
        let index = getIndex(key)
        items[index].fold = .open
    }

    mutating func toggle(_ key: String) {
        let index = getIndex(key)
        items[index].fold.toggle()
    }

    mutating func close(_ key: String) {
        let index = getIndex(key)
        items[index].fold = .closed
    }
}

extension MapViewModel {
    /// Calculate delta suitable for a table view
    static func calculateChanges(from oldVm: MapViewModel, to newVm: MapViewModel) -> (deleted: [Int], inserted: [Int]) {
        let oldValue = oldVm.items
        let items = newVm.items

        // get indexes of changes in items with their new status
        let changes = oldValue.indices.filter { oldValue[$0].fold != items[$0].fold }
        let rawDict = changes.map { oldValue[$0] }.map { ($0.key, $0.fold.toggled()) }
        let newlyFolded = [MapItem: Fold](uniqueKeysWithValues: rawDict)
        func wasChanged(_ key: MapItem) -> Bool {
            return newlyFolded[key] != nil
        }

        // this returns indexes of newly folded lists
        func getListIndexes(for fold: Fold, in list: [MapCellViewModel]) -> [Int] {
            return list.enumerated()
                // get the keys with their index in list
                .compactMap { tuple -> (offset: Int, key: MapItem)? in
                    if case let .key(key) = tuple.element {
                        return (tuple.offset, key)
                    } else {
                        return nil
                    }
                }
                // get all the ones with currentOpenStatus
                .filter {
                    wasChanged($0.key) && newlyFolded[$0.key]! == fold
                }
                // get the index of the corresponding list
                .map { $0.offset + 1 }
        }

        // so lets find the indexes of all the newly closed lists in oldCellViewModels
        let oldCellViewModels = oldValue.toMapCellViewModelList()
        let deletedIndexes = getListIndexes(for: .closed, in: oldCellViewModels)

        // now lets find the indexes of all the newly opened lists in oldCellViewModelsAfterCloses
        let oldCellViewModelsAfterCloses = oldCellViewModels.enumerated()
            .compactMap {
                deletedIndexes.contains($0.offset) ? nil : $0.element
            }
        let insertedIndexes = getListIndexes(for: .open, in: oldCellViewModelsAfterCloses)

        return (deletedIndexes, insertedIndexes)
    }
}

fileprivate enum Fold {
    case open
    case closed
    mutating func toggle() {
        self = toggled()
    }

    func toggled() -> Fold {
        return self == .open ? .closed : .open
    }
}

fileprivate struct Item {
    var key: MapItem
    var list: [MapItem]
    var fold = Fold.closed
}

fileprivate extension Array where Element == Item {
    func toMapCellViewModelList() -> [MapCellViewModel] {
        return flatMap { item -> [MapCellViewModel] in
            var out = [MapCellViewModel.key(item.key)]
            if item.fold == .open {
                out.append(MapCellViewModel.list(item.list))
            }
            return out
        }
    }
}
