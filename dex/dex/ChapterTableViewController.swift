//
//  ChapterTableViewController.swift
//  dex
//
//  Created by AJ Caldwell on 12/28/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import UIKit

class ChapterTableViewController: UITableViewController {
	
	lazy var objects = ["Hello", "World"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return objects.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
		cell.textLabel!.text = objects[indexPath.row]

        return cell
    }
}
