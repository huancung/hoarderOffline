//
//  DatabaseModels.swift
//  Hoarder
//
//  Created by Huan Cung on 8/29/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation
import RealmSwift

/**
 Realm data object definition for an item.
 */
public class Item: Object {
    @objc dynamic var collectionID = ""
    @objc dynamic var itemID = ""
    @objc dynamic var itemName = ""
    @objc dynamic var itemDesc = ""
    @objc dynamic var imageID = ""
    @objc dynamic var dateAdded = 0.0
    @objc dynamic var dateAddedString = ""
}

/**
 Realm data object definition for a collection.
 */
public class ItemCollection: Object {
    @objc dynamic var collectionName = ""
    @objc dynamic var category = ""
    @objc dynamic var collectionDesc = ""
    @objc dynamic var collectionID = ""
    @objc dynamic var itemCount = 0
    @objc dynamic var isFavorite = false
    @objc dynamic var dateCreated = 0.0
    @objc dynamic var dateCreatedString = ""
}
