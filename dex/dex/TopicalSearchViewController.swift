//
//  TopicalSearchViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/1/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class TopicalSearchViewController: UITableViewController {
    lazy var viewModel = self.table.keys.sorted()
    lazy var table = loadData()
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

struct TopicResult {
    var bibleSection = ""
    var qualityScore: Int

    init?(section: String, score: String) {
        bibleSection = section
        guard let qualityScore = Int(score) else { return nil }
        self.qualityScore = qualityScore
    }
}

typealias TopicTable = [String: [TopicResult]]

extension TopicalSearchViewController {
    func searchFor(_ text: String, in scope: String) {
        print("Searching for '\(text)' in scope: \(scope)")
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

            // exteact data from row
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
