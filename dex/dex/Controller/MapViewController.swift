//
//  MapViewController.swift
//  dex
//
//  Created by AJ Caldwell on 1/18/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import UIKit

/* Displays a dictionary of lists is a selectable manner. */
class MapViewController: UITableViewController {
    var model = MapModel() {
        didSet {
            configureView()
        }
    }

    weak var delegate: MapViewControllerDelegate?

    @IBAction func cancelButtonTapped(_: Any) {
        finish(with: nil)
    }

    @IBAction func buttonTapped(_ sender: Any) {
        // want the key, and the list index in the model
        // need to recover what button this is
        let button = sender as! UIButton
        let tableCellIndex = button.tag

        // Recover the key and value
        let keyCellViewModel = viewModel.cellViewModels[tableCellIndex - 1]
        guard
            case let .key(item) = keyCellViewModel
        else { assert(false) }
        let selectedListItemTitle = button.currentTitle!

        // get the index in the model
        let section = model.firstIndex { $0.0 == item }!
        let row = model[section].1.firstIndex { $0.title == selectedListItemTitle }!

        let coord = (section: section, row: row)
        finish(with: coord)
    }

    var viewModel: MapViewModel! {
        didSet(oldViewModel) {
            guard oldViewModel != nil else { return }

            let changes = MapViewModel.calculateChanges(from: oldViewModel, to: viewModel)
            func createIndexPath(_ index: Int) -> IndexPath {
                return IndexPath(row: index, section: 0)
            }

            let deletedRows = changes.deleted.map(createIndexPath)
            let insertedRows = changes.inserted.map(createIndexPath)

            tableView.beginUpdates()
            tableView.deleteRows(at: deletedRows, with: .top)
            tableView.insertRows(at: insertedRows, with: .top)
            tableView.endUpdates()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MapViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.cellViewModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cellViewModel = viewModel.cellViewModels[row]
        let identifier = cellViewModel.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        switch cellViewModel {
        case .key:
            (cell as! MapKeyCell).labelView.text = cellViewModel.description
        case .list:
            let mapListCell = cell as! MapListCell
            mapListCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: row)
            let flowlayout = mapListCell.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            mapListCell.collectionViewHeightConstraint.constant = flowlayout.collectionViewContentSize.height
            mapListCell.collectionView.collectionViewLayout.invalidateLayout()
        }

        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let .key(key) = viewModel.cellViewModels[indexPath.row] else { return }
        viewModel.toggle(key.title)
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource for MapSubheadingCell

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return items(forCollectionView: collectionView)!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ListItemCell

        let item = items(forCollectionView: collectionView)![indexPath.row]
        cell.button.setTitle(item.title, for: .normal)
        cell.button.tag = collectionView.tag

        return cell
    }
}

// MARK: Helpers

extension MapViewController {
    func items(forCollectionView collectionView: UICollectionView) -> [MapItem]? {
        let indexOfTableCell = collectionView.tag
        let tableCellViewModel = viewModel.cellViewModels[indexOfTableCell]
        guard case let .list(items) = tableCellViewModel else { return nil }
        return items
    }

    func configureView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300

        viewModel = MapViewModel(model)

        // Why do I do this? I think this might enforce a height recalculation.
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func finish(with result: MapViewControllerDelegate.Coord?) {
        dismiss(animated: true) {
            // this is probably a leak
            self.delegate?.mapViewController(self, with: self.model, didFinishWith: result)
        }
    }

    static var defaultExampleModel: MapModel {
        let alphabetRange = UnicodeScalar("a").value ... UnicodeScalar("z").value
        let alphabet = alphabetRange.compactMap(Unicode.Scalar.init)
        return alphabet.enumerated().map { tuple -> MapCoord in
            let (index, letter) = tuple
            let letterKey = String(letter)
            let numberlist = (0 ... index).compactMap(String.init)
            return (MapItem(letterKey), numberlist.map { MapItem($0) })
        }
    }
}

// MARK: - MapViewControllerDelegate

protocol MapViewControllerDelegate: class {
    typealias Coord = (section: Int, row: Int)
    func mapViewController(_: MapViewController, with model: MapModel, didFinishWith result: Coord?)
}

extension MapViewControllerDelegate {
    func mapViewController(_: MapViewController, with model: MapModel, didFinishWith result: Coord?) {
        var resultDescription = "<None>"
        if let result = result {
            let item = model[result.section]
            resultDescription = "\(item.0) \(item.1[result.row])"
        }
        print("Finished with result: \(resultDescription)")
    }
}
