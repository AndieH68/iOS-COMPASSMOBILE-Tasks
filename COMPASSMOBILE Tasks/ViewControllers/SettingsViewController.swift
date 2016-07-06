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
    
    var headsUpDisplay: MBProgressHUD?
    var eac: EAController?

    @IBOutlet var SelectedProbeName: UILabel!
    @IBOutlet var TaskTiming: UISwitch!
    @IBOutlet var TemperatureProfile: UISwitch!
    @IBOutlet var CompletedTasks: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CompletedTasks.text = String(ModelUtility.getInstance().GetCompletedTaskCount())
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentView: UIView = self.navigationController!.view
        {
            headsUpDisplay = MBProgressHUD(view: currentView)
            
            currentView.addSubview(headsUpDisplay!)
            
            //set the HUD mode
            headsUpDisplay!.mode = .DeterminateHorizontalBar;
            
            // Register for HUD callbacks so we can remove it from the window at the right time
            headsUpDisplay!.delegate = self
        }
    }
   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
      }
    
    // MARK: - User preferences
    @IBAction func SelectProbe(sender: UIButton) {
        EAController.sharedController().showBlueThermDeviceList()
    }
    
  
    // MARK: - Navigation
    
    @IBAction func Done(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - UITableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section
        {
        case 1:
            
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
            
        case 2:
            let urlString = "http://" + Session.Server + "/HelpDocuments/COMPASSMOBILE/COMPASS%20MOBILE%20User%20Guide.pdf"
            let url = NSURL(string: urlString)
            let application = UIApplication.sharedApplication()
            application.openURL(url!)
        
        default:
            print("default")
        }
    }
    
    @IBAction func Logout(sender: UIBarButtonItem) {
        Session.OperativeId = nil
        Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Action Handlers

    func UploadHandler (actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Uploading"
        headsUpDisplay!.showWhileExecuting({Utility.SendTasks(self, HUD: self.headsUpDisplay)}, animated: true)

    }
    
    func ResynchroniseHandler (actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Downloading"
        headsUpDisplay!.showWhileExecuting({Utility.DownloadAll(self, HUD: self.headsUpDisplay)}, animated: true)

    }
    
    func ResetSynchronisationHandler (actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Resetting"
        headsUpDisplay!.showWhileExecuting({Utility.ResetSynchronisationDates(self, HUD: self.headsUpDisplay)}, animated: true)

    }
    
    func ResetTaskHandler (actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Resetting"
        headsUpDisplay!.showWhileExecuting({Utility.ResetTasks(self, HUD: self.headsUpDisplay)}, animated: true)

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

        headsUpDisplay!.labelText = "Resetting"
        headsUpDisplay!.showWhileExecuting({Utility.ResetAllData(self, HUD: self.headsUpDisplay)}, animated: true)
        
        //Logout
//        Session.OperativeId = nil
//        Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
//        self.navigationController?.popViewControllerAnimated(true)
    }
}