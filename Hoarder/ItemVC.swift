//
//  ItemVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/31/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import Instructions

class ItemVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    
    var isImageSet = false
    var imagePicker: UIImagePickerController!
    var collectionUID: String!
    var loadedItem: ItemType?
    var parentVC: ParentViewController?
    var editMode: Bool = false
    var imageRemoved: Bool = false
    let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        navigationItem.setHidesBackButton(true, animated: true)
            
        // Edit item mode
        if loadedItem != nil {
            navigationItem.title = "Item Details"
            editMode = true
            cancelButton.title = "Done"
            
            // load image
            if loadedItem?.itemImage != nil {
                itemImage.image = loadedItem?.itemImage
            }
            
            // load item info
            nameText.text = loadedItem?.itemName
            descriptionText.text = loadedItem?.description
        }
        
        if !DataAccessUtilities.getTutorialFlag(step: TutorialViews.ItemView.rawValue) {
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
            return coachMarksController.helper.makeCoachMark(for: itemImage)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: nameText)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: descriptionText)
        case 3:
            return coachMarksController.helper.makeCoachMark(for: saveButton)
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
            coachViews.bodyView.hintLabel.text = "Add an image here. You don't have to but it'll probably make your life easier."
            coachViews.bodyView.nextLabel.text = "Next"
        case 1:
            showArrow = true
            coachViews.bodyView.hintLabel.text = "Name of your item here."
            coachViews.bodyView.nextLabel.text = "Next"
        case 2:
            showArrow = true
            coachViews.bodyView.hintLabel.text = "Describe your item here. This is optional but it will help you find the item later."
            coachViews.bodyView.nextLabel.text = "Done"
        case 3:
            showArrow = false
            coachViews.bodyView.hintLabel.text = "Save your item!"
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
        DataAccessUtilities.setTutorialFlag(step: TutorialViews.ItemView.rawValue, flag: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func doneButtonKBDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }

    @IBAction func imageButtonPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: "Add Image", message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let chooseFile = UIAlertAction(title: "Choose Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(chooseFile)
        if editMode || isImageSet {
            let viewImage = UIAlertAction(title: "View Image", style: .default) { (alert) in
                self.performSegue(withIdentifier: "imageZoomSegue", sender: nil)
            }
            
            optionMenu.addAction(viewImage)
            
            let removeImage = UIAlertAction(title: "Remove Image", style: .default) { (alert) in
                self.isImageSet = false
                self.itemImage.image = UIImage(named: "imagePlaceholder")
                self.imageRemoved = true;
            }
            
            optionMenu.addAction(removeImage)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        parentVC?.willReloadData = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if let name = nameText.text, !name.isEmpty {
            var description = ""
            
            if let desc = descriptionText.text, !desc.isEmpty {
                description = desc
            }
            
            BusyModal.startBusyModalAndHideNav(targetViewController: self)
            if isImageSet {
                saveItemWithImage(itemName: name, description: description)
            } else {
                var imageID = ""
                if editMode {
                    if imageRemoved {
                        deleteSavedImage()
                    } else {
                        imageID = (loadedItem?.imageID)!
                    }
                }
                
                saveItemInfo(itemName: name, description: description, imageID: imageID)
            }
            
            BusyModal.stopBusyModalAndShowNav(targetViewController: self)
            self.parentVC?.willReloadData = true
            self.navigationController?.popViewController(animated: true)
        } else {
            AlertUtil.alert(message: "Please add an item name!", targetViewController: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        var image : UIImage!
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            image = img
        }
        else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            image = img
        }
        
        itemImage.image = image
        isImageSet = true
    }
    
    /**
     Save method of items that have an image associated with it.
     - parameters:
        - itemName: Name of item.
        - description: Item description.
    */
    private func saveItemWithImage(itemName: String, description: String) {
        if let image = itemImage.image {

            let height = image.size.height
            let width = image.size.width
            let targetSize:CGSize!
            
            // Resizing the image to conserve space if it's too large
            if (height + width) > 1500.0 {
                targetSize = CGSize(width: width/5, height: height/5)
            } else {
                targetSize = CGSize(width: width, height: height)
            }
        
            let resizedImage = resizeImage(image: image, targetSize: targetSize)
            
            let imageKey = DataAccessUtilities.saveImage(image: resizedImage)
            saveItemInfo(itemName: itemName, description: description, imageID: imageKey)
            
            if self.editMode {
                self.deleteSavedImage()
            }
        }
    }
    
    /**
     Deletes the image that is associated with the item.
    */
    private func deleteSavedImage() {
        if let oldImageID = loadedItem?.imageID {
            DataAccessUtilities.deleteImageFromCache(imageID: oldImageID)
        }
    }
    
    /**
     Resizes the image for saving.
     - parameters:
        - image: UIImage
        - targetSize: CGSize
    */
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    /**
     Saves all the item data.
     - parameters:
        - itemName: Name of item.
        - description: Item description.
        - imageID: ID of image associated with the item.
    */
    private func saveItemInfo(itemName: String, description: String, imageID: String) {
        if editMode {
            DataAccessUtilities.saveItemInfo(itemName: itemName, description: description, imageID: imageID, collectionID: collectionUID, itemID: loadedItem?.itemID)
        } else {
            DataAccessUtilities.saveItemInfo(itemName: itemName, description: description, imageID: imageID, collectionID: collectionUID, itemID: nil)
        }
        DataAccessUtilities.updateItemCount(collectionID: collectionUID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageZoomSegue" {
            let destination = segue.destination as? ImageZoomVC
            destination?.image = itemImage.image
        }
    }
}
