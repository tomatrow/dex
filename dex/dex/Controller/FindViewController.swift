//
//  FindViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/14/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class FindViewController: UITableViewController {
    // MARK: - Properties

    let searchController = UISearchController(searchResultsController: nil)
    lazy var table = Loader.topicTable
    lazy var data = [
        "Topic": self.table.keys.sorted(),
        "Text": ["1", "2", "3"],
    ]
    var allItems = [String]() {
        didSet {
            tableView.reloadData()
        }
    }

    var filteredItems: [String]? {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Methods

    @IBAction func doneButtonTapped(_: Any) {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up the search bar
        searchController.searchBar.scopeButtonTitles = data.keys.sorted()
        searchController.searchBar.selectedScopeButtonIndex = 1

        // We're using the same contoller => we don't obscure it
        searchController.obscuresBackgroundDuringPresentation = false

        // Make this controller the delegate of various items
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

        // Set up the navigation item
        navigationItem.searchController = searchController

        // required by UISearchController
        definesPresentationContext = true

        // Set the default search
        updateSearch()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showDetail" {
            let topicController = segue.destination as! TopicDetailViewController
            let index = tableView.indexPathForSelectedRow!
            let text = viewModel[index.row]
            topicController.topicResults = table[text]!
        }
    }
}

// MARK: - Private Extention

private extension FindViewController {
    // MARK: - Methods

    func updateSearch() {
        searchController.searchBar.placeholder = "Search \(scope)"
        allItems = data[scope]!
        filteredItems = searchController.searchBar.text!.isEmpty ? nil : search()
    }

    func search() -> [String] {
        return allItems.filter { $0.contains(searchController.searchBar.text!) }
    }

    // MARK: - Computed Properties

    var scope: String {
        let scopeIndex = searchController.searchBar.selectedScopeButtonIndex
        let scopes = searchController.searchBar.scopeButtonTitles!
        return scopes[scopeIndex]
    }

    var viewModel: [String] {
        return filteredItems ?? allItems
    }
}

// MARK: - UITableViewDelegate, UITableViewDatasource

extension FindViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let text = viewModel[indexPath.row]
        cell.textLabel?.text = text

        return cell
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.count
    }
}

// MARK: - UISearchResultsUpdating

extension FindViewController: UISearchResultsUpdating {
    func updateSearchResults(for _: UISearchController) {
        updateSearch()
    }
}

// MARK: - UISearchBarDelegate

extension FindViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, selectedScopeButtonIndexDidChange _: Int) {
        updateSearch()
    }
}
