//
//  NotesViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/5/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.keyboardDismissMode = .interactive
    }
}
