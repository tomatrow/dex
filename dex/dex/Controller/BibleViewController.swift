//
//  BibleViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/18/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class BibleViewController: UIViewController {
    @IBOutlet var textView: UITextView!

    weak var bibleControllerDelegate: BibleViewControllerDelegate?

    static var bibleModel = createBibleModel()
    var chapter: Chapter? {
        didSet {
            configureView()
            updateDelegateIfNeeded(from: oldValue, to: chapter)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showMap" {
            let mapController = segue.destination as! MapViewController
            mapController.delegate = self
            mapController.model = BibleViewController.bibleModel
        }
    }
}

extension BibleViewController: MapViewControllerDelegate {
    func mapViewController(_: MapViewController, with model: MapModel, didFinishWith result: Coord?) {
        guard let result = result else { return }
        let item = model[result.section]
        let bookName = item.0.title
        let chapterNumber = Int(item.1[result.row].title)!
        let chapterIndex = chapterNumber - 1

        let bible = Loader.bible
        let book = bible.first { $0.name == bookName }!
        let chapter = book.chapters[chapterIndex]
        self.chapter = chapter
    }
}

extension BibleViewController {
    func configureView() {
        guard let chapter = chapter,
            let textView = textView
        else { return }

        textView.text = chapter.verses
            .map { "\($0.number) \($0.text)" }
            .joined(separator: "\n")
    }

    static func createBibleModel() -> MapModel {
        let bible = Loader.bible
        let bibleModel = bible.map { book -> MapCoord in
            let bookName = MapItem(book.name)
            let chapters = book.chapters.map { $0.number.description }.map(MapItem.init)
            return (bookName, chapters)
        }
        return bibleModel
    }

    func updateDelegateIfNeeded(from: Chapter?, to: Chapter?) {
        guard to != from, let newChapter = to else { return }
        bibleControllerDelegate?.bibleController(self, didSet: newChapter)
    }
}

protocol BibleViewControllerDelegate: class {
    func bibleController(_ controller: BibleViewController, didSet chapter: Chapter)
}
