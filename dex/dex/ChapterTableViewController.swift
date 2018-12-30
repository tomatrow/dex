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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
		cell.textLabel!.text = objects[indexPath.row].title

        return cell
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
		let esvPath = paths.filter { $0.contains("ESV")}.first!
		
		// convert from data to raw nested dicts 
		typealias RawBible = [String:[String:[String:String]]] 
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
			for chapterObject in bookObject.value {
				let chapterNumber = chapterObject.key
				var verses = [Verse]()
				for verseObject in chapterObject.value {
					let verseNumber = verseObject.key
					let verseText = verseObject.value	
					let verse = Verse(number: Int(verseNumber)!, text: verseText)
					verses.append(verse)
				}
				let chapter = Chapter(number: Int(chapterNumber)!, verses: verses)
				chapters.append(chapter)
			}
			let book = Book(name: bookName, chapters: chapters)
			bible.append(book)
		}
		
		for book in bible  {

			viewModel += book.chapters.map { chapter -> CellViewModel in 
				let title = "\(book.name) \(chapter.number)"
				let text = chapter.verses.map { verse in verse.text }.joined(separator: "\n")
				return CellViewModel(title: title, text: text)  
			}
		}
		
		return viewModel
	}
}
