//
//  MapListCell.swift
//  dex
//
//  Created by AJ Caldwell on 1/21/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation
import UIKit

class MapListCell: UITableViewCell, MapViewModelConfigurable {
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
