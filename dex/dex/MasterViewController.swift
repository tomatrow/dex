//
//  MasterViewController.swift
//  dex
//
//  Created by AJ Caldwell on 12/19/18.
//  Copyright © 2018 optional(default). All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController?
    lazy var objects = loadCommentaries()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }

        // https://www.hackingwithswift.com/example-code/uikit/how-to-load-a-html-string-into-a-wkwebview-or-uiwebview-loadhtmlstring
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.title = object.info.description
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.info.description
        return cell
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

extension MasterViewController {
    func loadCommentaries() -> [Commentary] {
        let decoder = JSONDecoder()
        var commentaries = [Commentary]()
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        for path in paths {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let commentary = try decoder.decode(Commentary.self, from: data)
                commentaries.append(commentary)
            } catch {
                print(error.localizedDescription)
            }
        }
        commentaries.sort(by: <)
        return commentaries
    }
}
