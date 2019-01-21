//
//  MapKeyCell.swift
//  dex
//
//  Created by AJ Caldwell on 1/21/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation
import UIKit

class MapKeyCell: UITableViewCell, MapViewModelConfigurable {
    @IBOutlet var labelView: UILabel!

    func configureFor(_ viewModel: MapCellViewModel) {
        guard let labelView = labelView else { return }
        guard case let .single(title) = viewModel else { assert(false) }
        labelView.text = title
    }
}
