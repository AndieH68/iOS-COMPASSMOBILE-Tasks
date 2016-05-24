//
//  SettingsViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 17/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AVFoundation
import UIKit

class SettingsViewController: UITableViewController, MBProgressHUDDelegate
{
    
    var selfHUD: MBProgressHUD?
    
    @IBAction func Done(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
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
    
    @IBOutlet var CompletedTasks: UILabel!
    
    override func viewDidLoad() {
        
        CompletedTasks.text = String(ModelUtility.getInstance().GetCompletedTaskCount())
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if let currentView: UIView = self.navigationController!.view
        {
            selfHUD = MBProgressHUD(view: currentView)
        
            currentView.addSubview(selfHUD!)
        
            //set the HUD mode
            selfHUD!.mode = .DeterminateHorizontalBar;
            
            // Register for HUD callbacks so we can remove it from the window at the right time
            selfHUD!.delegate = self
        }

    }
    
    // MARK - UItable
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section
        {
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
                    handler: self.ResetTaskHandler))
                
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

        selfHUD!.labelText = "Uploading"
        selfHUD!.showWhileExecuting({Utility.SendTasks(self, HUD: self.selfHUD)}, animated: true)

    }
    
    func ResynchroniseHandler (actionTarget: UIAlertAction) {

        selfHUD!.labelText = "Downloading"
        selfHUD!.showWhileExecuting({Utility.DownloadAll(self, HUD: self.selfHUD)}, animated: true)

    }
    
    func ResetSynchronisationHandler (actionTarget: UIAlertAction) {

        selfHUD!.labelText = "Resetting"
        selfHUD!.showWhileExecuting({Utility.ResetSynchronisationDates(self, HUD: self.selfHUD)}, animated: true)

    }
    
    func ResetTaskHandler (actionTarget: UIAlertAction) {

        selfHUD!.labelText = "Resetting"
        selfHUD!.showWhileExecuting({Utility.ResetTasks(self, HUD: self.selfHUD)}, animated: true)

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

        selfHUD!.labelText = "Resetting"
        selfHUD!.showWhileExecuting({Utility.ResetAllData(self, HUD: self.selfHUD)}, animated: true)
        
        //Logout
        Session.OperativeId = nil
        Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}