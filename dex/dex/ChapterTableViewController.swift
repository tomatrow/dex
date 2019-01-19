//
//  ChapterTableViewController.swift
//  dex
//
//  Created by AJ Caldwell on 12/28/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import UIKit

class ChapterTableViewController: UITableViewController {
    lazy var objects = loadViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        cell.textLabel!.text = objects[indexPath.row].title

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showDetail" {
            if let index = tableView.indexPathForSelectedRow {
                let text = objects[index.row].text
                let controller = segue.destination as! DetailTextViewController
                controller.text = text
            }
        }
    }
}

struct CellViewModel {
    var title = "Title"
    var text = "An amount of text."
}

extension ChapterTableViewController {
    func loadViewModel() -> [CellViewModel] {
        var viewModel = [CellViewModel]()
        let bible = Loader.bible

        for book in bible {
            viewModel += book.chapters.map { chapter -> CellViewModel in
                let title = "\(book.name) \(chapter.number)"
                let text = chapter.verses.map { verse in verse.text }.joined(separator: "\n")
                return CellViewModel(title: title, text: text)
            }
        }

        return viewModel
    }
}
