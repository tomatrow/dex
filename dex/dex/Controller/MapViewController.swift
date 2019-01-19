//
//  MapViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/18/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class MapViewController: UITableViewController {
    let model = ["1": ["l"], "2": ["o"], "3": ["a", "b", "c"], "4": ["p", "q", "r"], "5": ["x", "y", "z"]]
    var viewModel = [MapCellViewModel]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = model.keys.map(MapCellViewModel.init)
        viewModel.append(.multiple(["a", "b", "c"]))
    }
}

// MARK: - Table view delegate

extension MapViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cellViewModel = viewModel[row]
        let identifier = cellViewModel.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MapViewModelConfigurable

        if let subCell = cell as? MapSubheadingCell {
            subCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: row)
        } else {
            let cell = cell as! MapHeadingCell
            cell.labelView.text = cellViewModel.description
        }

        return cell as! UITableViewCell
    }
}

// MARK: - Table view data source

extension MapViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.count
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource for MapSubheadingCell

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return model[collectionView.tag.description]!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell

        let title = model[collectionView.tag.description]![indexPath.row]
        cell.button.setTitle(title, for: .normal)

        return cell
    }
}

// MARK: Cell View Model

enum MapCellViewModel: CustomStringConvertible {
    case single(String)
    case multiple([String])

    var identifier: String {
        switch self {
        case .single:
            return "HeadingCell"
        case .multiple:
            return "SubheadingCell"
        }
    }

    var description: String {
        switch self {
        case let .single(item):
            return item
        case let .multiple(items):
            return items.joined(separator: ",")
        }
    }

    init(_ s: String) {
        self = .single(s)
    }

    init(_ m: [String]) {
        self = .multiple(m)
    }
}

protocol MapViewModelConfigurable where Self: UITableViewCell {
    func configureFor(_ viewModel: MapCellViewModel)
}

class MapHeadingCell: UITableViewCell, MapViewModelConfigurable {
    @IBOutlet var labelView: UILabel!

    func configureFor(_ viewModel: MapCellViewModel) {
        guard let labelView = labelView else { return }
        guard case let .single(title) = viewModel else { assert(false) }
        labelView.text = title
    }
}

class MapSubheadingCell: UITableViewCell, MapViewModelConfigurable {
    @IBOutlet var collectionView: UICollectionView!
    func configureFor(_ viewModel: MapCellViewModel) {
        guard let collectionView = collectionView else { return }
        guard case let .multiple(list) = viewModel else { assert(false) }
    }

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
}

class ItemCell: UICollectionViewCell {
    @IBOutlet var button: UIButton!
}
