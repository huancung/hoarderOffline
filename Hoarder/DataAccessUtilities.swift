//
//  DataAccessUtilities.swift
//  Hoarder
//
//  Created by Huan Cung on 8/22/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation
import RealmSwift

public class DataAccessUtilities {
    static let sharedInstance = DataAccessUtilities()
    static var itemCountHandles = [UInt]()
    static let realm = try! Realm()
    
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
     - parameters
     - collectionName: Name of the collection.
     - category: Category of that the collection.
     - description: Description of the collection.
     */
    static func saveCollectionInfo(collectionName: String, category: String, description: String) -> String {
        let itemCollection = ItemCollection()
        let collectionID = NSUUID().uuidString
        
        itemCollection.collectionName = collectionName
        itemCollection.category = category
        itemCollection.collectionDesc = description
        itemCollection.collectionID = collectionID
        itemCollection.itemCount = 0
        itemCollection.dateCreated = DateTimeUtilities.getTimestamp()
        itemCollection.isFavorite = false
        
        do {
            try realm.write {
                realm.add(itemCollection)
            }
        } catch {
            print("Error creating collection information saveCollectionInfo(...): collectionID: \(collectionID)")
        }
        
        return collectionID
    }
    
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
    
    static func getItemCount(collectionID: String) -> Int{
        let itemDataRef = realm.objects(Item.self).filter("collectionID ='\(collectionID)'")
        
        return itemDataRef.count
    }
    
    
    static func cacheImage(imageID: String, image: UIImage) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        let imageData = UIImagePNGRepresentation(image)
        
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
            print("cached image \(imageID)")
        }
        
    }
    
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
    
    static func deleteImageFromCache(imageID: String){
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        if fileManager.fileExists(atPath: path){
            try! fileManager.removeItem(atPath: path)
            print("Delete Image \(imageID)")
        }else{
            print("Nothing to delete \(imageID)")
        }
    }
}
