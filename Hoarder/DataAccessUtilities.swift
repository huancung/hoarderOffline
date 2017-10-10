//
//  DataAccessUtilities.swift
//  Hoarder
//
//  Created by Huan Cung on 8/22/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation
import RealmSwift

/**
 Helper class to handle data management for the app.
 */
public class DataAccessUtilities {
    static let sharedInstance = DataAccessUtilities()
    static var itemCountHandles = [UInt]()
    static let realm = try! Realm()
    
    /**
     Returns a list of all the collections saved in the app.
     - Returns: [CollectionType]
    */
    static func getCollectionsList() -> [CollectionType] {
        let collectionSet = realm.objects(ItemCollection.self)
        var collectionList = [CollectionType]()
        
        for collection in collectionSet {
            let name = collection.collectionName
            let category = collection.category
            let description = collection.collectionDesc
            let collectionID = collection.collectionID
            let itemCount = collection.itemCount
            let creationDate = collection.dateCreated
            let isFavorite = collection.isFavorite
            let creationDateString = DateTimeUtilities.formatTimeInterval(timeInterval: collection.dateCreated)
            
            let collectionObj = CollectionType(collectionName: name, category: category, description: description, collectionID: collectionID, itemCount: itemCount, creationDateString: creationDateString, creationDate: creationDate, isFavorite: isFavorite)
            collectionList.append(collectionObj)
        }
        
        return collectionList
    }
    
    /**
     Updates the collection info.
     - parameters:
        - collectionName: Name of the collection.
        - category: Category of that the collection.
        - description: Description of the collection.
        - collectionID: Id for the collection being updated.
        - creationDate: Creation date as a unix timestamp.
        - isFavorite: true or false string to mark if collection is favorite.
     */
    static func updateCollectionInfo(collectionName: String, category: String, description: String, collectionID: String, creationDate: Double, isFavorite: Bool) {
        let refCollection = realm.objects(ItemCollection.self).filter("collectionID ='\(collectionID)'").first
        
        if let itemCollection = refCollection {
            do {
                try realm.write {
                    itemCollection.collectionName = collectionName
                    itemCollection.category = category
                    itemCollection.collectionDesc = description
                    itemCollection.isFavorite = isFavorite
                    itemCollection.dateCreated = creationDate
                }
            } catch {
                print("Error updating collection information updateCollectionInfo(...): collectionID: \(collectionID)")
            }
        }
    }
    
    /**
     Saves the collection info.
     - parameters:
        - collectionName: Name of the collection.
        - category: Category of that the collection.
        - description: Description of the collection.
     */
    static func saveCollectionInfo(collectionName: String, category: String, description: String, isFavorite: Bool) -> String {
        let itemCollection = ItemCollection()
        let collectionID = NSUUID().uuidString
        
        itemCollection.collectionName = collectionName
        itemCollection.category = category
        itemCollection.collectionDesc = description
        itemCollection.collectionID = collectionID
        itemCollection.itemCount = 0
        itemCollection.dateCreated = DateTimeUtilities.getTimestamp()
        itemCollection.isFavorite = isFavorite
        
        do {
            try realm.write {
                realm.add(itemCollection)
            }
        } catch {
            print("Error creating collection information saveCollectionInfo(...): collectionID: \(collectionID)")
        }
        
        return collectionID
    }
    
    /**
     Deletes the collection information.
     - parameters:
        - collectionID: the id of the collection to be deleted.
    */
    static func deleteCollection(collectionID: String) {
        let refCollection = realm.objects(ItemCollection.self).filter("collectionID ='\(collectionID)'")
        
        do {
            try realm.write {
                realm.delete(refCollection)
            }
        } catch {
            print("Error deleting collection information deleteCollection(...): collectionID: \(collectionID)")
        }

    }
    
    /**
     Deletes all the items and item photos for a given collection.
     - parameters:
        - collectionID: The id of the collection.
     */
    static func deleteItems(collectionID: String) {
        let refItems = realm.objects(Item.self).filter("collectionID ='\(collectionID)'")

        for item in refItems {
            // Delete saved image
            deleteImageFromCache(imageID: item.imageID)
        }
        
        do {
            try realm.write {
                realm.delete(refItems)
            }
        } catch {
            print("Error deleting items information deleteItems(...): collectionID: \(collectionID)")
        }
    }
    
    /**
     Deletes an item's information.
     - parameters:
        - itemID: The id of the item.
     */
    static func deleteItemInfo(itemID: String) {
        if let refItem = realm.objects(Item.self).filter("itemID ='\(itemID)'").first {
            do {
                try realm.write {
                    realm.delete(refItem)
                }
            } catch {
                print("Error deleting item information deleteItemInfo(...): collectionID: \(itemID)")
            }
        } else {
            print("Error deleting item information deleteItemInfo(...): collectionID: \(itemID)")
        }
    }
    
    /**
     Saves the information for an item.
     - parameters:
        - itemName: name of the item.
        - description: description of the item.
        - imageID: id of the image associated with the item. Empty string can be passed if there is no image for the item.
        - collectionID: id of the collection the item belongs to.
        - itemID: id of the item to save the information to. If nil is passed the item will be saved as a new entry and a new item id will be assigned.
    */
    static func saveItemInfo(itemName: String, description: String, imageID: String, collectionID: String, itemID: String?) {
        var item: Item
        
        var key: String!
        
        if itemID == nil {
            key = NSUUID().uuidString
            
            item = Item()
            item.collectionID = collectionID
            item.itemName = itemName
            item.itemDesc = description
            item.itemID = key
            item.imageID = imageID
            
            do {
                try realm.write {
                    realm.add(item)
                }
            } catch {
                print("Error saving item information saveItemInfo(...): itemID: \(key)")
            }
        } else {
            item = realm.objects(Item.self).filter("itemID ='\(itemID!)'").first!
            key = itemID
            
            do {
                try realm.write {
                    item.itemName = itemName
                    item.itemDesc = description
                    item.imageID = imageID
                }
            } catch {
                print("Error updating item information saveItemInfo(...): itemID: \(key)")
            }
        }
        
        
    }
    
    /**
     Creates a new entry that is a duplicate of the item passed with a new item id.
     - parameters:
        - item: ItemType
        - toCollectionID: id of the collection that the copied item will be added to.
    */
    static func copyItem(item: ItemType, toCollectionID: String) {
        if item.collectionID != toCollectionID {
            if let image = item.itemImage {
                let imageID = saveImage(image: image)
                saveItemInfo(itemName: item.itemName, description: item.description, imageID: imageID, collectionID: toCollectionID, itemID: nil)
                
            } else {
                saveItemInfo(itemName: item.itemName, description: item.description, imageID: "", collectionID: toCollectionID, itemID: nil)
            }
        }
    }
    
    /**
     Save the image to app storage.
     - parameters:
        - image: UIImage to be saved.
    */
    static func saveImage(image: UIImage) -> String {
        let imageID = NSUUID().uuidString
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        let imageData = UIImagePNGRepresentation(image)
        
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
            print("Image saved \(imageID)")
        } else {
            print("Image already exists imageID: \(imageID)")
        }
        
        return imageID
    }
    
    /**
     Gets a list of items associated with a collection.
     - parameters:
        - collectionID: id of the collection.
     */
    static func getItemsList(collectionID: String) -> [ItemType] {
        let itemRef = realm.objects(Item.self).filter("collectionID ='\(collectionID)'")
        var itemList = [ItemType]()
        
        for item in itemRef {
            let collectionID = item.collectionID
            let itemID = item.itemID
            let name = item.itemName
            let description = item.itemDesc
            let imageID = item.imageID
            let dateAdded = item.dateAdded
            let dateAddedString = DateTimeUtilities.formatTimeInterval(timeInterval: item.dateAdded)
            
            let item = ItemType(collectionID: collectionID, itemID: itemID, itemName: name, description: description, imageID: imageID, dateAdded: dateAdded, dateAddedString: dateAddedString)
            
            item.downloadImage()
            itemList.append(item)
        }
        
        return itemList
    }
    
    /**
     Updates the item count information for a collection.
     - parameters:
        - collectionID: id of the collection to update.
    */
    static func updateItemCount(collectionID: String) {
        let refCollection = realm.objects(ItemCollection.self).filter("collectionID ='\(collectionID)'").first
        
        if let itemCollection = refCollection {
            do {
                try realm.write {
                    itemCollection.itemCount = getItemCount(collectionID: collectionID)
                }
            } catch {
                print("Error updating collection information updateItemCount(...): collectionID: \(collectionID)")
            }
        }
    }
    
    /**
     Gets the item count for a collection.
     - parameters:
        - collectionID: id of the collection to update.
     - Returns: item count as Int.
     */
    static func getItemCount(collectionID: String) -> Int {
        let itemDataRef = realm.objects(Item.self).filter("collectionID ='\(collectionID)'")
        
        return itemDataRef.count
    }
    
    /**
     Save an image to the devices document directory.
     - parameters:
        - imageID: id of the image.
        - image: UIImage to save.
     */
    static func cacheImage(imageID: String, image: UIImage) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        let imageData = UIImagePNGRepresentation(image)
        
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
            print("cached image \(imageID)")
        }
        
    }
    
    /**
     Gets a store image.
     - parameters:
        - imageID: id of the image.
     - Returns: UIImage if one exists and nil if image is not found.
     */
    static func getCachedImage(imageID: String) -> UIImage? {
        print("get cached image")
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        if fileManager.fileExists(atPath: path){
            if let image = UIImage(contentsOfFile: path) {
                print("Image returned \(imageID)")
                return image
            } else {
                print("Image not found")
                return nil
            }
        }else{
            print("No Image")
        }
        return nil
    }
    
    /**
     Deletes a store image.
     - parameters:
         - imageID: id of the image.
     */
    static func deleteImageFromCache(imageID: String) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        if fileManager.fileExists(atPath: path) {
            try! fileManager.removeItem(atPath: path)
            print("Delete Image \(imageID)")
        }else{
            print("Nothing to delete \(imageID)")
        }
    }

    /**
     Stores a flag determining whether or not a tutorial has been completed for a given view.
     - parameters:
         - step: String
         - flag: Bool
     */
    static func setTutorialFlag(step: String, flag: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(flag, forKey: step)
    }
    
    /**
     Stores a flag determining whether or not a tutorial has been completed for a given view.
     - parameters:
         - step: String
     - returns: Bool
     */
    static func getTutorialFlag(step: String) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: step)
    }
}
