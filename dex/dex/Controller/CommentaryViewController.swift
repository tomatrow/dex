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
            mapController.model = MapViewController.defaultExampleModel
        }
    }
}

extension CommentaryViewController: MapViewControllerDelegate {}

extension CommentaryViewController {
    func configureView() {
        guard let commentary = commentary,
            let webView = webView
        else { return }

        let markup = commentary.markup
        webView.loadHTMLString(markup, baseURL: Bundle.main.bundleURL)
    }
}
