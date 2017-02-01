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
    @IBOutlet var CompletedTasks: UILabel!
    @IBOutlet var TaskTimingsSwitch: UISwitch!
    @IBOutlet var TemperatureProfileSwitch: UISwitch!
    @IBOutlet var VersionNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CompletedTasks.text = String(ModelUtility.getInstance().GetCompletedTaskCount())
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            VersionNumber.text = version
        }
        
        TaskTimingsSwitch.isOn = Session.UseTaskTiming
        TemperatureProfileSwitch.isOn = Session.UseTemperatureProfile
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentView: UIView = self.navigationController!.view
        {
            headsUpDisplay = MBProgressHUD(view: currentView)
            
            currentView.addSubview(headsUpDisplay!)
            
            //set the HUD mode
            headsUpDisplay!.mode = .determinateHorizontalBar;
            
            // Register for HUD callbacks so we can remove it from the window at the right time
            headsUpDisplay!.delegate = self
        }
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      }
    
    // MARK: - User preferences
    @IBAction func SelectProbe(_ sender: UIButton) {
        EAController.shared().showBlueThermDeviceList()
    }
    
  
    // MARK: - Navigation
    
    @IBAction func Done(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section
        {
        case 1:
            
            switch indexPath.row
            {
            case 0:
                //upload tasks
                let userPrompt: UIAlertController = UIAlertController(title: "Upload Tasks?", message: "Upload unsent tasks to COMPASS?", preferredStyle: UIAlertControllerStyle.alert)

                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "Cancel",
                    style: UIAlertActionStyle.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Upload",
                    style: UIAlertActionStyle.destructive,
                    handler: self.UploadHandler))

                present(userPrompt, animated: true, completion: nil)

            case 1:
                //download data
                let userPrompt: UIAlertController = UIAlertController(title: "Synchronise Data", message: "Are you sure you want to synchronise data with COMPASS?", preferredStyle: UIAlertControllerStyle.alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "Cancel",
                    style: UIAlertActionStyle.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Download",
                    style: UIAlertActionStyle.destructive,
                    handler: self.ResynchroniseHandler))

                present(userPrompt, animated: true, completion: nil)
                
            case 2:
                //reset synchronisation dates
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset the synchronisation dates?", preferredStyle: UIAlertControllerStyle.alert)
 
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertActionStyle.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertActionStyle.destructive,
                    handler: self.ResetSynchronisationHandler))

                present(userPrompt, animated: true, completion: nil)
                
            case 3:
                //reset tasks
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset all tasks?", preferredStyle: UIAlertControllerStyle.alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertActionStyle.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertActionStyle.destructive,
                    handler: self.ResetTaskHandler))
                
                present(userPrompt, animated: true, completion: nil)
                
            case 4:
                //reset all data
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset all data?", preferredStyle: UIAlertControllerStyle.alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertActionStyle.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertActionStyle.destructive,
                    handler: self.ResetAllDataSecondPromptHandler))
                
                present(userPrompt, animated: true, completion: nil)

            default:
                print("default")
            }
            
        case 3:
            let urlString = "http://" + Session.Server + "/HelpDocuments/COMPASSMOBILE/COMPASSMOBILE-Tasks-User-Guide-for-iOS.pdf"
            let url = URL(string: urlString)
            let application = UIApplication.shared
            application.openURL(url!)
        
        default:
            print("default")
        }
    }
    
    @IBAction func Logout(_ sender: UIBarButtonItem) {
        Session.OperativeId = nil
        Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Action Handlers

    func UploadHandler (_ actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Uploading"
        headsUpDisplay!.showWhileExecuting({Utility.SendTasks(self, HUD: self.headsUpDisplay)}, animated: true)

    }
    
    func ResynchroniseHandler (_ actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Downloading"
        headsUpDisplay!.showWhileExecuting({Utility.DownloadAll(self, HUD: self.headsUpDisplay)}, animated: true)

    }
    
    func ResetSynchronisationHandler (_ actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Resetting"
        headsUpDisplay!.showWhileExecuting({Utility.ResetSynchronisationDates(self, HUD: self.headsUpDisplay)}, animated: true)

    }
    
    func ResetTaskHandler (_ actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Resetting"
        headsUpDisplay!.showWhileExecuting({Utility.ResetTasks(self, HUD: self.headsUpDisplay)}, animated: true)

    }
    
    func ResetAllDataSecondPromptHandler (_ actionTarget: UIAlertAction) {
        let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "The action you are about to take cannot be undone and will erase all data on this device.  Are you sure you want to proceeed?", preferredStyle: UIAlertControllerStyle.alert)
        
        //the cancel action
        userPrompt.addAction(UIAlertAction(
            title: "No",
            style: UIAlertActionStyle.cancel,
            handler: nil))
        
        //the destructive option
        userPrompt.addAction(UIAlertAction(
            title: "Yes",
            style: UIAlertActionStyle.destructive,
            handler: self.ResetAllDataHandler))
        
        present(userPrompt, animated: true, completion: nil)
    }
    
    func ResetAllDataHandler (_ actionTarget: UIAlertAction) {

        headsUpDisplay!.labelText = "Resetting"
        headsUpDisplay!.showWhileExecuting({Utility.ResetAllData(self, HUD: self.headsUpDisplay)}, animated: true)
        
        //Logout
        Session.OperativeId = nil
        Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func TaskTimingsSwitchValueChanged(_ sender: UISwitch) {
        Session.UseTaskTiming = TaskTimingsSwitch.isOn
        let defaults = UserDefaults.standard
        defaults.set(Session.UseTaskTiming, forKey: "TaskTimings")
    }
    
    @IBAction func TemperatureProfileSwitchValueChanged(_ sender: UISwitch) {
        Session.UseTemperatureProfile = TemperatureProfileSwitch.isOn
        let defaults = UserDefaults.standard
        defaults.set(Session.UseTemperatureProfile, forKey: "TemperatureProfile")
    }
}
