//
//  DetailTextViewController.swift
//  dex
//
//  Created by AJ Caldwell on 12/29/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import UIKit

class DetailTextViewController: UIViewController {
	
	@IBOutlet weak var textLabel: UILabel!
	var text = "Some text." {
		didSet {
			configureView()
		}
	}
	
	func configureView() {
		if let label = textLabel {		
			label.text = text
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		configureView()
        // Do any additional setup after loading the view.
    }

}
