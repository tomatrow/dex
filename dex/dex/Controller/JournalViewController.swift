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

    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.keyboardDismissMode = .interactive
        textView.delegate = self
        textView.text = notes
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
