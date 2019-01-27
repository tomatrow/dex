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

    var chapter: Chapter? {
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

extension BibleViewController: MapViewControllerDelegate {}

extension BibleViewController {
    func configureView() {
        guard let chapter = chapter,
            let textView = textView
        else { return }

        textView.text = chapter.verses
            .map { "\($0.number) \($0.text)" }
            .joined(separator: "\n")
    }
}
