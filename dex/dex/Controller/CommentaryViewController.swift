//
//  CommentaryViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/16/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit
import WebKit

class CommentaryViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    static var orderedCommentaryMap = createOrderedCommentaryMap()
    static var commentaryModel = createCommentaryModel()
    var commentary: Commentary? {
        didSet {
            configureView()
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
            mapController.model = CommentaryViewController.commentaryModel
        }
    }
}

extension CommentaryViewController: MapViewControllerDelegate {
    func mapViewController(_: MapViewController, with _: MapModel, didFinishWith result: Coord?) {
        guard let result = result else { return }
        commentary = CommentaryViewController.orderedCommentaryMap[result.section].1[result.row]
    }
}

extension CommentaryViewController {
    func configureView() {
        guard let commentary = commentary,
            let webView = webView
        else { return }

        let markup = commentary.markup
        webView.loadHTMLString(markup, baseURL: Bundle.main.bundleURL)
    }

    static func createOrderedCommentaryMap() -> [(String, [Commentary])] {
        let commentaries = Loader.commentaries
        let dict = [String: [Commentary]](grouping: commentaries, by: { ($0.info.volume?.description ?? "") + $0.info.book })
        let orderedKeys = dict.keys.sorted()
        return orderedKeys.map { ($0, dict[$0]!.sorted(by: { $0 < $1 })) }
    }

    static func createCommentaryModel() -> MapModel {
        return orderedCommentaryMap
            .map { (book, chapterCommentaries) -> MapCoord in
                let bookItem = MapItem(book)
                let chapters = chapterCommentaries
                    // get the first chapter the commentary covers
                    .map { $0.info.chapters.first!.description }
                    .map(MapItem.init)
                return (bookItem, chapters)
            }
    }
}
