//
//  MapListCell.swift
//  dex
//
//  Created by AJ Caldwell on 1/21/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation
import UIKit

class MapListCell: UITableViewCell {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
}
