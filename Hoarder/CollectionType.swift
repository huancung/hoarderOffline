//
//  CollectionType.swift
//  Hoarder
//
//  Created by Huan Cung on 7/22/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation

/**
 Collection class object.
*/
public class CollectionType {
    private var _collectionName = ""
    private var _category = ""
    private var _description = ""
    private var _collectionID = ""
    private var _itemCount = 0
    private var _isFavorite = false
    private var _dateCreated = 0.0
    private var _dateCreatedString = ""
    
    /**
     Default constructor.
     - parameters:
        - collectionName: Name of collection.
        - category: Collection category.
        - collectionID: Collection unique identifier.
        - itemCount: Number of items in the collection.
        - creationDateString: MMM DD, YYYY representation of the date the collection was created.
        - creationDate: Creation date as UTC Double.
        - isFavorite: Indicates if the collection is favored by the user for sorting and displaying purposes.
    */
    init(collectionName: String, category: String, description: String, collectionID: String, itemCount: Int, creationDateString: String, creationDate: Double, isFavorite: Bool) {
        _collectionName = collectionName
        _category = category
        _description = description
        _collectionID = collectionID
        _dateCreated = creationDate
        _dateCreatedString = creationDateString
        _itemCount = itemCount
        _isFavorite = isFavorite
    }
    
    var collectionName: String {
        get{
            return _collectionName
        }
    }
    
    var category: String {
        get{
            return _category
        }
    }
    
    var description: String {
        get{
            return _description
        }
    }
    
    var collectionID: String {
        get{
            return _collectionID
        }
    }
    
    var dateCreated: Double {
        get{
            return _dateCreated
        }
    }
    
    var dateCreatedString: String {
        get{
            return _dateCreatedString
        }
    }
    
    var itemCount: Int {
        get{
            return _itemCount
        }
    }
    
    var isFavorite: Bool {
        get{
            return _isFavorite
        }
    }
}
