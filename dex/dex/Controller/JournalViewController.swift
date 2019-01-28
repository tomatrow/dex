//
//  NotesViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/5/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class JournalViewController: UIViewController {
    var notes = JournalViewController.loadText() {
        didSet {
            saveText(notes)
        }
    }

    private var subModelState = SubModelState()

    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.keyboardDismissMode = .interactive
        textView.delegate = self
        textView.text = notes
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard let identifier = segue.identifier else { return }
        let controller = segue.destination

        // Just load a default model for now
        switch identifier {
        case "showCommentary":
            let commentaryController = controller as! CommentaryViewController
            commentaryController.commentaryDelegate = self
            commentaryController.commentary = subModelState.commentary
        case "showBible":
            let bibleController = controller as! BibleViewController
            bibleController.bibleControllerDelegate = self
            bibleController.chapter = subModelState.chapter
        default:
            return
        }
    }
}

extension JournalViewController: UITextViewDelegate {
    func textViewDidEndEditing(_: UITextView) {
        notes = textView.text
    }
}

fileprivate let notesKey = "notes-text"

extension JournalViewController {
    func saveText(_ text: String) {
        UserDefaults.standard.set(text, forKey: notesKey)
    }

    static func loadText() -> String {
        return UserDefaults.standard.string(forKey: notesKey) ?? String(repeating: "\n", count: 100)
    }
}

extension JournalViewController: CommentaryViewControllerDelegate, BibleViewControllerDelegate {
    func bibleController(_: BibleViewController, didSet chapter: Chapter) {
        subModelState.chapter = chapter
    }

    func commentaryController(_: CommentaryViewController, didSet commentary: Commentary) {
        subModelState.commentary = commentary
    }
}

fileprivate struct SubModelState {
    var commentary = Loader.commentaries.first!
    var chapter = Loader.bible.first!.chapters.first!
}
