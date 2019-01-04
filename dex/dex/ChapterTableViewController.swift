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

struct Verse {
    var number: Int
    var text: String
}

struct Chapter {
    var number: Int
    var verses: [Verse]
}

struct Book {
    var name: String
    var chapters: [Chapter]
}

extension ChapterTableViewController {
    func loadViewModel() -> [CellViewModel] {
        // load the bible
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        let esvPath = paths.filter { $0.contains("ESV") }.first!

        // convert from data to raw nested dicts
        typealias RawBible = [String: [String: [String: String]]]
        /* {
         "bookName": {
         "chapterNumber": {
         "verseNumber": "verse",...
         },...
         },...
         }*/

        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: esvPath), options: .mappedIfSafe),
            let rawBible = try? decoder.decode(RawBible.self, from: data)
        else { assert(false) }

        var viewModel = [CellViewModel]()

        var bible = [Book]()
        for bookObject in rawBible {
            let bookName = bookObject.key
            var chapters = [Chapter]()

            // read all the chapters
            for chapterObject in bookObject.value {
                let chapterNumber = chapterObject.key
                var verses = [Verse]()

                // read all the verses
                for verseObject in chapterObject.value {
                    let verseNumber = verseObject.key
                    let verseText = verseObject.value
                    let verse = Verse(number: Int(verseNumber)!, text: verseText)
                    verses.append(verse)
                }

                // sort the verses
                verses.sort { $0.number < $1.number }

                let chapter = Chapter(number: Int(chapterNumber)!, verses: verses)
                chapters.append(chapter)
            }

            // sort the chapters
            chapters.sort { $0.number < $1.number }

            let book = Book(name: bookName, chapters: chapters)
            bible.append(book)
        }

        // sort the books
        bible.sort { $0.name < $1.name }

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
