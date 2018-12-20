//
//  DetailViewController.swift
//  dex
//
//  Created by AJ Caldwell on 12/19/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    @IBOutlet var webView: WKWebView!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem, let view = webView {
            let markup = detail.markup
            view.loadHTMLString(markup, baseURL: Bundle.main.bundleURL)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: Commentary? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}
