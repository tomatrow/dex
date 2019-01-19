//
//  FindViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/14/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

typealias TopicTable = [String: [TopicResult]]

class FindViewController: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar {
        return searchController.searchBar
    }

    var text: String {
        return searchBar.text!
    }

    var scope: String {
        let scopeIndex = searchBar.selectedScopeButtonIndex
        let scopes = searchBar.scopeButtonTitles!
        return scopes[scopeIndex]
    }

    lazy var table = loadData()

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

    var viewModel: [String] {
        return filteredItems ?? allItems
    }

    @IBAction func doneButtonTapped(_: Any) {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up the search bar
        searchBar.scopeButtonTitles = data.keys.sorted()
        searchBar.selectedScopeButtonIndex = 1

        // We're using the same contoller => we don't obscure it
        searchController.obscuresBackgroundDuringPresentation = false

        // Make this controller the delegate of various items
        searchController.searchResultsUpdater = self
        searchBar.delegate = self

        // Set up the navigation item
        navigationItem.searchController = searchController

        // required by UISearchController
        definesPresentationContext = true

        // Set the default search
        updateSearch()
    }
}

// MARK: - Private methods

extension FindViewController {
    private func updateSearch() {
        searchBar.placeholder = "Search \(scope)"
        allItems = data[scope]!
        filteredItems = text.isEmpty ? nil : search()
    }

    private func search() -> [String] {
        return allItems.filter { $0.contains(text) }
    }

    func loadData() -> TopicTable {
        // topic-votes.txt is raw unmoderated/unfiltered data, devoid of any votes from openbible (I think)
        // topic-scores.txt has been moderated

        // load the raw text
        let path = Bundle.main.path(forResource: "topic-scores", ofType: "txt")!
        let text = try! String(contentsOfFile: path)

        // separate columns by tabs and rows by lines
        let rows = text
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.split(separator: "\t").map { col in String(col) } }
        assert(53508 == rows.count)

        // convert into a live table
        var table = TopicTable()
        // first line is header, last line is blank
        rows[1 ..< rows.endIndex - 1].forEach { row in
            assert(row.count == 3)

            // extract data from row
            let topic = row[0]
            let result = TopicResult(section: row[1], score: row[2])!

            // save in table
            if table[topic] != nil {
                table[topic]!.append(result)
            } else {
                table[topic] = [result]
            }
        }

        // sort the results
        table.keys.forEach { key in
            table[key]!.sort { $0.qualityScore > $1.qualityScore }
        }

        return table
    }
}

// MARK: - Table view delegate

extension FindViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let text = viewModel[indexPath.row]
        cell.textLabel?.text = text

        return cell
    }
}

// MARK: - Table view data source

extension FindViewController {
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
