//
//  DateTimeUtilities.swift
//  Hoarder
//
//  Created by Huan Cung on 7/22/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation

/**
 Singleton helper class for date and time formatting.
 */
public class DateTimeUtilities {
    static let sharedInstance = DateTimeUtilities()
    
    /**
     Takes in an UTC time and converts it to MMM d,yyyy hh:mma format.
     - parameters:
        - timeInterval: epoc time as a double.
    */
    static func formatTimeInterval(timeInterval: Double) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d,yyyy hh:mma" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    /**
     Gets the current UTC timestamp.
     - parameters:
        - timeInterval: epoc time as a double.
     - Returns: UTC time as a Double
     */
    static func getTimestamp() -> Double {
        return NSDate().timeIntervalSince1970
    }
    
    /**
     Gets the current date formatted as MMM d,yyyy hh:mma.
     - parameters:
     - timeInterval: epoc time as a double.
     - Returns: MMM d,yyyy hh:mma String
     */
    static func getCurrentDate() -> String {
        return formatTimeInterval(timeInterval: getTimestamp())
    }
}
