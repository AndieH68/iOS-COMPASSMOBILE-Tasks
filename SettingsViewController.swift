//
//  SettingsViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 17/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AVFoundation
import UIKit

class SettingsViewController: UITableViewController
{
    
    @IBAction func Done(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func UploadTasks(sender: UIButton) {
    }
    

    @IBAction func TaskTiming(sender: UISwitch) {
        Session.TaskTiming = sender.on
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(Session.TaskTiming, forKey: "TaskTiming")
    }
    
    @IBAction func TemperatureProfile(sender: UISwitch) {
        Session.TemperatureProfile = sender.on
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(Session.TemperatureProfile, forKey: "TemperatureProfile")
    }
    
    
    override func viewDidLoad() {
        print("Did load")
    }
    
    // MARK - UItable
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(String(indexPath.section))
        print(String(indexPath.row))
        
        
        switch indexPath.section
        {
        case 0:
            //bluetooth
            print("do the bluetooth set up")
            
        case 1:
            print("nothing to do here")
            
        case 2:
            
            switch indexPath.row
            {
            case 0:
                //upload tasks
                let userPrompt: UIAlertController = UIAlertController(title: "Upload Tasks?", message: "Upload unsent tasks to COMPASS?", preferredStyle: UIAlertControllerStyle.Alert)

                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "Cancel",
                    style: UIAlertActionStyle.Cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Upload",
                    style: UIAlertActionStyle.Destructive,
                    handler: self.UploadHandler))

                presentViewController(userPrompt, animated: true, completion: nil)

            case 1:
                //download data
                let userPrompt: UIAlertController = UIAlertController(title: "Download Tasks", message: "Are you sure you want to download tasks from COMPASS?", preferredStyle: UIAlertControllerStyle.Alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "Cancel",
                    style: UIAlertActionStyle.Cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Download",
                    style: UIAlertActionStyle.Destructive,
                    handler: self.ResynchroniseHandler))

                presentViewController(userPrompt, animated: true, completion: nil)
                
            case 2:
                //reset synchronisation dates
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset the synchronisation dates?", preferredStyle: UIAlertControllerStyle.Alert)
 
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertActionStyle.Cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertActionStyle.Destructive,
                    handler: self.ResetSynchronisationHandler))

                presentViewController(userPrompt, animated: true, completion: nil)
                
            case 3:
                //reset tasks
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset all tasks?", preferredStyle: UIAlertControllerStyle.Alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertActionStyle.Cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertActionStyle.Destructive,
                    handler: self.ResetSynchronisationHandler))
                
                presentViewController(userPrompt, animated: true, completion: nil)
                
            case 4:
                //reset all data
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset all data?", preferredStyle: UIAlertControllerStyle.Alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertActionStyle.Cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertActionStyle.Destructive,
                    handler: self.ResetAllDataSecondPromptHandler))
                
                presentViewController(userPrompt, animated: true, completion: nil)

            default:
                print("default")
            }
            
        case 3:
            //Logout
            Session.OperativeId = nil
            Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
            self.navigationController?.popViewControllerAnimated(true)
            
        default:
            print("default")
        }
    }
    

    func UploadHandler (actionTarget: UIAlertAction) {
        
        var success: Bool = false
        var taskCount: Int32 = 0
        
        let title: String = "Tasks Sent"
        var message: String = "Send Tasks failed"
        
        (success,taskCount) = Utility.SendTaskDetails()
        
        if (success)
        {
            if (taskCount > 0)
            {
                message = String(taskCount) + " Task(s) sent to COMPASS"            }
            else
            {
                message = "No data sent to COMPASS"
            }
        }
        
        let userPrompt: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        //the default action
        userPrompt.addAction(UIAlertAction(
            title: "Ok",
            style: UIAlertActionStyle.Default,
            handler: nil))
        
        presentViewController(userPrompt, animated: true, completion: nil)
    
    }
    
    func ResynchroniseHandler (actionTarget: UIAlertAction) {
        print ("resynchronise pressed")
    }
    
    func ResetSynchronisationHandler (actionTarget: UIAlertAction) {
        print ("yes pressed")
    }
    
    func ResetTasksHandler (actionTarget: UIAlertAction) {
        print ("yes pressed")
    }
    
    func ResetAllDataSecondPromptHandler (actionTarget: UIAlertAction) {
        let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "The action you are about to take cannot be undone and will erase all data on this device.  Are you sure you want to proceeed?", preferredStyle: UIAlertControllerStyle.Alert)
        
        //the cancel action
        userPrompt.addAction(UIAlertAction(
            title: "No",
            style: UIAlertActionStyle.Cancel,
            handler: nil))
        
        //the destructive option
        userPrompt.addAction(UIAlertAction(
            title: "Yes",
            style: UIAlertActionStyle.Destructive,
            handler: self.ResetAllDataHandler))
        
        presentViewController(userPrompt, animated: true, completion: nil)
    }
    
    func ResetAllDataHandler (actionTarget: UIAlertAction) {
        print ("yes pressed")
    }
    

}