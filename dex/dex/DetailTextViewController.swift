//
//  DetailTextViewController.swift
//  dex
//
//  Created by AJ Caldwell on 12/29/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import UIKit

class DetailTextViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    var text = "Some text." {
        didSet {
            configureView()
        }
    }

    func configureView() {
        if let textView = textView {
            textView.text = text
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }
}
