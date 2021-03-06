//
//  ItemListVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/27/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import Instructions

class ItemListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ParentViewController {
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchSegmentedControl: UISegmentedControl!
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet var addItemButton: UIBarButtonItem!
    @IBOutlet weak var emptyItemLbl: UILabel!
    
    var doneButtonItem: UIBarButtonItem!
    
    var collectionName: String!
    var collectionUID: String!
    var collectionsList: [CollectionType]!
    var itemList = [ItemType]()
    var filteredItemList = [ItemType]()
    var inSearchMode = false
    var willReloadData: Bool = false
    let coachMarksController = CoachMarksController()
    var parentVC: ParentViewController?
    
    enum ItemActionOption: String {
        case copy, move, delete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.enablesReturnKeyAutomatically = false
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.backgroundColor = UIColor.clear
        itemTableView.allowsMultipleSelectionDuringEditing = true
        navigationItem.title = collectionName
        if let topItem = self.navigationController?.navigationBar.topItem {
            let button = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            
            topItem.backBarButtonItem = button
        }
        
        if !DataAccessUtilities.getTutorialFlag(step: TutorialViews.ItemListView.rawValue) {
            coachMarksController.dataSource = self
            coachMarksController.delegate = self
            coachMarksController.start(on: self)
        }
        
        populateItemCellData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if willReloadData {
            willReloadData = false
            populateItemCellData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        
        switch index {
        case 0:
            let buttonView = addItemButton.value(forKey: "view") as? UIView
            return coachMarksController.helper.makeCoachMark(for: buttonView, pointOfInterest: buttonView?.frame.origin)
        case 1:
            let buttonView = actionButton.value(forKey: "view") as? UIView
            return coachMarksController.helper.makeCoachMark(for: buttonView)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: searchBar)
        case 3:
            return coachMarksController.helper.makeCoachMark(for: emptyItemLbl)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        var showArrow = false;
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        switch index {
            
        case 0:
            showArrow = true
            coachViews.bodyView.hintLabel.text = "Add a new item to collection here."
            coachViews.bodyView.nextLabel.text = "Next"
        case 1:
            showArrow = true
            coachViews.bodyView.hintLabel.text = "Enter edit mode to move, copy, or delete items here."
            coachViews.bodyView.nextLabel.text = "Next"
        case 2:
            showArrow = true
            coachViews.bodyView.hintLabel.text = "Search items by name or description here."
            coachViews.bodyView.nextLabel.text = "Next,m"
        case 3:
            showArrow = false
            coachViews.bodyView.hintLabel.text = "Added items will appear here."
            coachViews.bodyView.nextLabel.text = "Done"
        default:
            coachViews.bodyView.hintLabel.text = "DONE!"
            coachViews.bodyView.nextLabel.text = "DONE!"
        }
        
        if showArrow {
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        } else {
            return (bodyView: coachViews.bodyView, arrowView: nil)
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        DataAccessUtilities.setTutorialFlag(step: TutorialViews.ItemListView.rawValue, flag: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredItemList.count
        }
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        if !itemTableView.isEditing {
            itemTableView.deselectRow(at: indexPath, animated: true)
            let item = getItem(index: indexPath.row)
            performSegue(withIdentifier: "editItemSegue", sender: item)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteItem(itemIndex: indexPath.row)
            self.itemTableView.deleteRows(at: [indexPath], with: .fade)
            DataAccessUtilities.updateItemCount(collectionID: self.collectionUID)
        }
        
        return [delete]
    }
    
    /**
     Will display the item data for a given cell.
     - parameters:
        - cell: ItemCell.
        - indexPath: IndexPath.
    */
    func configureCell(cell: ItemCell, indexPath: IndexPath) {
        let item = getItem(index: indexPath.row)
        
        cell.updateUI(item: item)
    }
    
    /**
     Gets the item at a given index.
     - parameters:
        - index: Index of item desired.
    */
    func getItem(index: Int) -> ItemType {
        var item: ItemType!
        
        if inSearchMode {
            item = filteredItemList[index]
        } else {
            item = itemList[index]
        }
        
        return item
    }
    
    /**
     Retrieves and populates the tableview with the item data for the collection.
    */
    private func populateItemCellData() {
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        itemList = DataAccessUtilities.getItemsList(collectionID: collectionUID)
        
        if itemList.isEmpty {
            emptyItemLbl.isHidden = false
        } else {
            emptyItemLbl.isHidden = true
        }
        itemList = itemList.sorted(by: {$0.itemName < $1.itemName})
        itemTableView.reloadData()
        BusyModal.stopBusyModalAndShowNav(targetViewController: self)
    }
    
    /**
     Resets the search parameters.
    */
    private func resetSearch() {
        inSearchMode = false
        searchBar.text = ""
    }
    
    /**
     Method for deleting a single item when user left swipes a row.
     - parameters:
        - itemIndex: index of the item to be deleted
    */
    private func deleteItem(itemIndex: Int) {
        var item: ItemType!
        
        if inSearchMode {
            item = filteredItemList[itemIndex]
        } else {
            item = itemList[itemIndex]
        }
        
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        // Delete item in database
        DataAccessUtilities.deleteItemInfo(itemID: item.itemID)
        
        // Delete saved image
        if !item.imageID.isEmpty {
            DataAccessUtilities.deleteImageFromCache(imageID: item.imageID)
        }
        
        BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        
        if inSearchMode {
            self.filteredItemList.remove(at: itemIndex)
        } else {
            self.itemList.remove(at: itemIndex)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text  == "" {
            resetSearch()
            view.endEditing(true)
            itemTableView.reloadData()
        } else {
            inSearchMode = true
            
            let searchText = searchBar.text!.lowercased()
            
            if searchSegmentedControl.selectedSegmentIndex == 0 {
                filteredItemList = itemList.filter({$0.itemName.lowercased().range(of: searchText) != nil})
            } else {
                filteredItemList = itemList.filter({$0.description.lowercased().range(of: searchText) != nil})
            }
            
            itemTableView.reloadData()
        }
    }
    
    @IBAction func addEditItemPressed(_ sender: Any) {
        performSegue(withIdentifier: "addItemSegue", sender: nil)
    }
    
    @IBAction func searchSegmentChanged(_ sender: Any) {
        if inSearchMode {
            let searchText = searchBar.text!.lowercased()
            
            if searchSegmentedControl.selectedSegmentIndex == 0 {
                filteredItemList = itemList.filter({$0.itemName.lowercased().range(of: searchText) != nil})
            } else {
                filteredItemList = itemList.filter({$0.description.lowercased().range(of: searchText) != nil})
            }
            
            itemTableView.reloadData()
        }
    }
    
    /**
     This function will display action options if items are selected during edit mode.
    */
    @objc func doneButtonPressed() {
        if let selectedItems = itemTableView.indexPathsForSelectedRows, selectedItems.count > 0 {
            let optionMenu = UIAlertController(title: "Choose an Action", message: nil, preferredStyle: .actionSheet)
            
            let copyAction = UIAlertAction(title: "Copy Items to...", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.collectionSelect(itemAction: ItemActionOption.copy)
            })
            
            let moveAction = UIAlertAction(title: "Move Items to...", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.collectionSelect(itemAction: ItemActionOption.move)
            })
            
            let deleteAction = UIAlertAction(title: "Delete Selected Items", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                //do something
                self.collectionSelect(itemAction: ItemActionOption.delete)
                self.endEditMode()
            })
            
            optionMenu.addAction(copyAction)
            optionMenu.addAction(moveAction)
            optionMenu.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                //do something
                self.endEditMode()
            })

            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            endEditMode()
        }
    }
    
    /**
     Edit mode functionality. Will apply desired action to selected items.
     - parameters:
        - itemAction: ItemActionOption.
    */
    private func collectionSelect(itemAction: ItemActionOption) {
        if collectionsList.count == 1 {
            AlertUtil.message(title: "Not Gonna Happen", message: "You have to create another hoard to do this action!", targetViewController: self)
        }
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 200)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        
        let selectCollectionAlert = UIAlertController(title: "Choose a collection", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        selectCollectionAlert.setValue(vc, forKey: "contentViewController")
        selectCollectionAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let toCollectionID = self.collectionsList[pickerView.selectedRow(inComponent: 0)].collectionID
            
            // We will do nothing if we are moving or copying to the same collection
            if toCollectionID != self.collectionUID {
                let selectedIndexPaths = self.itemTableView.indexPathsForSelectedRows
                // Copy action or move action
                if selectedIndexPaths != nil && itemAction == ItemActionOption.copy {
                    BusyModal.startBusyModal(targetViewController: self)
                    // Copy items
                    for indexPath in selectedIndexPaths! {
                        var itemToCopy: ItemType
                        if self.inSearchMode {
                            itemToCopy = self.filteredItemList[indexPath.row]
                        } else {
                            itemToCopy = self.itemList[indexPath.row]
                        }
                        
                        DataAccessUtilities.copyItem(item: itemToCopy, toCollectionID: toCollectionID)
                    }
                    BusyModal.stopBusyModal()
                    AlertUtil.message(title: "\(selectedIndexPaths?.count ?? 0) Items Copied!", message: "", targetViewController: self)
                } else if selectedIndexPaths != nil && itemAction == ItemActionOption.move {
                    BusyModal.startBusyModal(targetViewController: self)
                    // Move Items
                    
                    for indexPath in selectedIndexPaths! {
                        var itemToMove: ItemType
                        if self.inSearchMode {
                            itemToMove = self.filteredItemList[indexPath.row]
                        } else {
                            itemToMove = self.itemList[indexPath.row]
                        }
                        
                        DataAccessUtilities.copyItem(item: itemToMove, toCollectionID: toCollectionID)
                        
                        DataAccessUtilities.deleteItemInfo(itemID: itemToMove.itemID)
                        
                        if itemToMove.imageID != "" {
                            DataAccessUtilities.deleteImageFromCache(imageID: itemToMove.imageID)
                        }
                    }
                    BusyModal.stopBusyModal()
                    
                    AlertUtil.message(title: "\(selectedIndexPaths?.count ?? 0) Items Moved!", message: "", targetViewController: self)
                    self.populateItemCellData()
                } else {
                    BusyModal.startBusyModal(targetViewController: self)
                    // Move Items
                    
                    for indexPath in selectedIndexPaths! {
                        var itemsToDelete: ItemType
                        if self.inSearchMode {
                            itemsToDelete = self.filteredItemList[indexPath.row]
                        } else {
                            itemsToDelete = self.itemList[indexPath.row]
                        }
                        
                        DataAccessUtilities.deleteItemInfo(itemID: itemsToDelete.itemID)
                        
                        if itemsToDelete.imageID != "" {
                            DataAccessUtilities.deleteImageFromCache(imageID: itemsToDelete.imageID)
                        }
                    }
                    BusyModal.stopBusyModal()
                    
                    AlertUtil.message(title: "\(selectedIndexPaths?.count ?? 0) Items Deleted!", message: "", targetViewController: self)
                    self.populateItemCellData()
                }
                
                self.endEditMode()
            } else {
                AlertUtil.alert(message: "Pick a different collection!", targetViewController: self)
            }
            
            
            DataAccessUtilities.updateItemCount(collectionID: toCollectionID)
            DataAccessUtilities.updateItemCount(collectionID: self.collectionUID)
        }))
        
        selectCollectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.endEditMode()
        }))
        self.present(selectCollectionAlert, animated: true)
    }
    
    /**
     Toggles edit move for the tableview.
    */
    private func endEditMode() {
        itemTableView.setEditing(false, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.setRightBarButtonItems([addItemButton, actionButton], animated: true)
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        if !itemTableView.isEditing {
            itemTableView.setEditing(true, animated: true)
            navigationItem.setHidesBackButton(true, animated: true)
            navigationItem.setRightBarButton(nil, animated: true)
            doneButtonItem.isEnabled = true
            navigationItem.setRightBarButton(doneButtonItem, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return collectionsList[row].collectionName.capitalized
    }
    
    // Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return collectionsList.count
    }
    
    // Columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 25.0)
        label.adjustsFontSizeToFitWidth = false
        label.minimumScaleFactor = 0.5
        label.text = collectionsList[row].collectionName
        
        return label
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemSegue" {
            if let destination = segue.destination as? ItemVC {
                destination.parentVC = self
                destination.collectionUID = collectionUID
            }
        } else if segue.identifier == "editItemSegue" {
            if let destination = segue.destination as? ItemVC {
                destination.parentVC = self
                destination.collectionUID = collectionUID
                destination.loadedItem = sender as? ItemType
            }
        }
    }

}
