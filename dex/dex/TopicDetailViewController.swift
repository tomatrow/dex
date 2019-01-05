//
//  TopicDetailViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/1/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class TopicDetailViewController: UITableViewController {
    var topicResults = [TopicResult]() {
        didSet {
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        print(topicResults)
        tableView.reloadData()
    }
}

// Table view delegate
extension TopicDetailViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let topic = topicResults[indexPath.row]
        cell.textLabel!.text = "\(topic.bibleSection) \(topic.qualityScore)"
        return cell
    }
}

// Table view data source
extension TopicDetailViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return topicResults.count
    }
}
