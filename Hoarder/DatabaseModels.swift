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
    dynamic var collectionID = ""
    dynamic var itemID = ""
    dynamic var itemName = ""
    dynamic var itemDesc = ""
    dynamic var imageID = ""
    dynamic var dateAdded = 0.0
    dynamic var dateAddedString = ""
}

/**
 Realm data object definition for a collection.
 */
public class ItemCollection: Object {
    dynamic var collectionName = ""
    dynamic var category = ""
    dynamic var collectionDesc = ""
    dynamic var collectionID = ""
    dynamic var itemCount = 0
    dynamic var isFavorite = false
    dynamic var dateCreated = 0.0
    dynamic var dateCreatedString = ""
}
