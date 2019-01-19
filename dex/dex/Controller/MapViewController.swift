//
//  MapViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/18/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class MapViewController: UITableViewController {
    lazy var viewModel = ["1", "2", "3"]
}

// MARK: - Table view delegate

extension MapViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let text = viewModel[indexPath.row]
        cell.textLabel?.text = text

        return cell
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
