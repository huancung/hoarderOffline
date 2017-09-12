//
//  AlertUtilities.swift
//  Hoarder
//
//  Created by Huan Cung on 7/19/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation
import UIKit

/**
 Singleton class that contains methods to aid in the displaying and dismissal of alerts.
 */
public class AlertUtil {
    static let sharedInstance = AlertUtil()
    
    /**
     Creates an exception alert.
     - parameters:
        - message: message to display in the alert.
        - targetViewController: UIViewContoller that will display the alert.
     */
    static func alert(message: String, targetViewController: UIViewController) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        targetViewController.present(alert, animated: true, completion: nil)
    }
    
    /**
     Creates an alert and will pop the viewcontroller after dismisal.
     - parameters:
        - title: title to display above the alert view.
        - message: message to display in the alert.
        - targetViewController: UIViewContoller that will display the alert.
     */
    static func messageThenPop(title: String, message: String, targetViewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (alert) in
            targetViewController.navigationController?.popViewController(animated: true)
        })
        targetViewController.present(alert, animated: true, completion: nil)
    }
    
    /**
     Creates a generic alert.
     - parameters:
        - title: title to display above the alert view.
        - message: message to display in the alert.
        - targetViewController: UIViewContoller that will display the alert.
     */
    static func message(title: String, message: String, targetViewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        targetViewController.present(alert, animated: true, completion: nil)
    }
}
