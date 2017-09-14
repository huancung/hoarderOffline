//
//  ItemType.swift
//  Hoarder
//
//  Created by Huan Cung on 8/3/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
/**
 Item class object.
 */
public class ItemType {
    private var _collectionID = ""
    private var _itemID = ""
    private var _itemName = ""
    private var _description = ""
    private var _imageID = ""
    private var _dateAdded = 0.0
    private var _dateAddedString = ""
    private var _itemImage: UIImage?
    
    /**
     Default constructor.
     - parameters:
        - collectionID: the id of the collection this item belongs to.
        - itemID: unique id for this item.
        - itemName: Name of item.
        - description: description of item.
        - imageID: ID of image for this item.
        - dateAdded: UTC timestamp for the date this item was added.
        - dateAddedString: MMM DD, YYYY string representation of date created.
    */
    init(collectionID: String, itemID: String, itemName: String, description: String, imageID: String, dateAdded: Double, dateAddedString: String) {
        _collectionID = collectionID
        _itemID = itemID
        _itemName = itemName
        _description = description
        _imageID = imageID
        _dateAdded = dateAdded
        _dateAddedString = dateAddedString
    }
    
    var collectionID: String {
        get{
            return _collectionID
        }
    }
    
    var itemID: String {
        get{
            return _itemID
        }
    }
    
    var itemName: String {
        get{
            return _itemName
        }
    }
    
    var description: String {
        get{
            return _description
        }
    }
    
    var imageID: String {
        get{
            return _imageID
        }
    }
    
    var dateAdded: Double {
        get{
            return _dateAdded
        }
    }
    
    var dateAddedString: String {
        get{
            return _dateAddedString
        }
    }
    
    var itemImage: UIImage? {
        get{
            return _itemImage
        }
        
        set{
            _itemImage = newValue
        }
    }
    
    public func downloadImage() {
        if let image = DataAccessUtilities.getCachedImage(imageID: _imageID) {
            _itemImage = image
        }
    }
}
