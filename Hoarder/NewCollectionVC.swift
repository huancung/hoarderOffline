//
//  NewCollectionVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/21/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import Instructions

/**
 View Controller for the New Collection View.
 */
class NewCollectionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    @IBOutlet weak var collectionNameText: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var createButton: UIButton!
    
    let coachMarksController = CoachMarksController()
    
    let collectionCategories = ["Auto Supplies", "Clothing", "Toys", "Craft Supplies", "Furniture", "Household Goods", "Electronics", "Art", "Animals", "General Stuff", "Books", "Accessories", "Supplies", "Tools", "Toiletries", "Memorabilia", "Movies", "Antiques", "Hobby", "Other", "Garden", "Outdoors", "Food", "Wine and Spirits", "Baby and Kids", "Sports"]
    
    var parentVC: ParentViewController?
    var sortedCollectionCategories: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        sortedCollectionCategories = collectionCategories.sorted()
        navigationItem.setHidesBackButton(true, animated: true)
        
        if !DataAccessUtilities.getTutorialFlag(step: TutorialViews.NewCollectionView.rawValue) {
            coachMarksController.dataSource = self
            coachMarksController.delegate = self
            coachMarksController.start(on: self)
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: collectionNameText)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: categoryPicker)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: descriptionText)
        case 3:
            return coachMarksController.helper.makeCoachMark(for: createButton)
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
            coachViews.bodyView.hintLabel.text = "Add a collection name"
            coachViews.bodyView.nextLabel.text = "Next"
        case 1:
            showArrow = false
            coachViews.bodyView.hintLabel.text = "Select a category"
            coachViews.bodyView.nextLabel.text = "Next"
        case 2:
            showArrow = true
            coachViews.bodyView.hintLabel.text = "Add a description for this collection"
            coachViews.bodyView.nextLabel.text = "Next"
        case 3:
            showArrow = true
            coachViews.bodyView.hintLabel.text = "Create your hoard!"
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
        //DataAccessUtilities.setTutorialFlag(step: TutorialViews.NewCollectionView.rawValue, flag: true)
    }

    @IBAction func createCollectionPressed(_ sender: Any) {
        if let collectionName = collectionNameText.text, !collectionName.isEmpty {
            var description = ""
            
            if let desc = descriptionText.text, !desc.isEmpty {
                description = desc
            }
            
            let category = sortedCollectionCategories[categoryPicker.selectedRow(inComponent: 0)]
            
            AlertUtil.messageThenPop(title: "New Collection Created!", message: "Now you can start adding items to this collection!", targetViewController: self)
            
            let collectionID = DataAccessUtilities.saveCollectionInfo(collectionName: collectionName, category: category, description: description)
            DataAccessUtilities.updateItemCount(collectionID: collectionID)
            parentVC?.willReloadData = true
        } else {
            AlertUtil.alert(message: "Please add a collection name!", targetViewController: self)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortedCollectionCategories[row].capitalized
    }
    
    // Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedCollectionCategories.count
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
        label.font = UIFont(name: "Helvetica Neue", size: 17.0)
        label.adjustsFontSizeToFitWidth = false
        label.minimumScaleFactor = 0.5
        label.text = getTextForPicker(atRow: row) // implemented elsewhere
        
        return label
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /**
     Returns the text associated with the index of selected from the category picker.
     - parameters
        - atRow: Index of the selection in the picker.
    */
    private func getTextForPicker(atRow: Int) -> String {
        return sortedCollectionCategories[atRow]
    }
}
