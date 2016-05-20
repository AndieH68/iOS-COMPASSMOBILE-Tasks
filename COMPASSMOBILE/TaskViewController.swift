//
//  TaskViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 20/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import Foundation
import UIKit

class TaskViewController: UITableViewController,UITextFieldDelegate {
    
    
    //header fields
    @IBOutlet var AssetType: UILabel!
    @IBOutlet var TaskName: UILabel!
    @IBOutlet var Location: UILabel!
    @IBOutlet var AssetNumber: UILabel!
    @IBOutlet var TaskReference: UILabel!
    
    //footer fields
    @IBOutlet var AdditionalNotes: UITextView!
    @IBOutlet var RemoveAsset: UISwitch!
    @IBOutlet var AlternateAssetCode: UITextField!
    
    //standard actions
    
    @IBAction func CancelPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func DonePressed(sender: UIBarButtonItem) {
        //do all the vlaidation
        
        //commit the vales
        
        //update the task
        
        //close the view
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func AlternateAssetCodeLaunchScan(sender: UITextField) {
    }
    
    
    
    
}

