//
//  TopicalSearchViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/1/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class TopicalSearchViewController: UITableViewController {
    lazy var viewModel = loadData()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Topics"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["One", "Two", "Three"]
        searchController.searchBar.delegate = self
    }
}

// MARK: Helper methods

extension TopicalSearchViewController {
    func searchFor(_ text: String, in scope: String) {
        print("Searching for '\(text)' in scope: \(scope)")
    }

    func loadData() -> [String] {
        return ["Hello", "World", "!"]
    }
}

// MARK: Table view delegate

extension TopicalSearchViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let text = viewModel[indexPath.row]
        cell.textLabel?.text = text

        return cell
    }
}

// MARK: - Table view data source

extension TopicalSearchViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.count
    }
}

extension TopicalSearchViewController: UISearchResultsUpdating {
    // Note: This is called with the search text changes
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let text = searchBar.text!
        searchFor(text, in: scope)
    }
}

extension TopicalSearchViewController: UISearchBarDelegate {}
