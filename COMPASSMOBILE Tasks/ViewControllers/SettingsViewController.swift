//
//  SettingsViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 17/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import AVFoundation
import UIKit
import MBProgressHUD

class SettingsViewController: UITableViewController, MBProgressHUDDelegate
{
    
    var headsUpDisplay: MBProgressHUD?
    var eac: EAController?
    var showDebug: Int = 0

    @IBOutlet var EnableBlueToothProbeSwitch: UISwitch!
    @IBOutlet var SelectedProbeName: UILabel!
    @IBOutlet var SelectProbeLabel: UILabel!
    @IBOutlet var SelectProbeButton: UIButton!
    @IBOutlet var CompletedTasks: UILabel!
    @IBOutlet var TaskTimingsSwitch: UISwitch!
    @IBOutlet var TemperatureProfileSwitch: UISwitch!
    @IBOutlet var RememberFilterSettingsSwitch: UISwitch!
    @IBOutlet var FilterOnTasksSwitch: UISwitch!
    @IBOutlet var VersionNumber: UILabel!
    @IBOutlet weak var Debug: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let DebugValue: String = String(ModelUtility.getInstance().GetTaskCountByStatus(Status: "Dockable")) + " : " + String(ModelUtility.getInstance().GetTaskCountByStatus(Status: "Docked")) + " : " + String(ModelUtility.getInstance().GetTaskCountByStatus(Status: "Outstanding")) + " : " + String(ModelUtility.getInstance().GetTaskCountByStatus(Status: "Complete"))
        Debug.text = DebugValue
        CompletedTasks.text = String(ModelUtility.getInstance().GetTaskCountByStatus(Status: "Dockable"))
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            VersionNumber.text = version
        }
        
        let debugTap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.debugTapFunction))
        VersionNumber.addGestureRecognizer(debugTap)
        
        EnableBlueToothProbeSwitch.isOn = Session.UseBlueToothProbe
        SelectProbeLabel.isEnabled = Session.UseBlueToothProbe
        SelectProbeButton.isEnabled = Session.UseBlueToothProbe
        
        TaskTimingsSwitch.isOn = Session.UseTaskTiming
        TemperatureProfileSwitch.isOn = Session.UseTemperatureProfile
        RememberFilterSettingsSwitch.isOn = Session.RememberFilterSettings
        FilterOnTasksSwitch.isOn = Session.FilterOnTasks
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
    @IBAction func EnableBlueToothProbeSwitchChanged(_ sender: UISwitch) {
        Session.UseBlueToothProbe = EnableBlueToothProbeSwitch.isOn
        let defaults = UserDefaults.standard
        defaults.set(Session.UseBlueToothProbe, forKey: "UseBlueToothProbe")
        SelectProbeLabel.isEnabled = Session.UseBlueToothProbe
        SelectProbeButton.isEnabled = Session.UseBlueToothProbe
    }
    
    @IBAction func SelectProbePressed(_ sender: UIButton) {
        EAController.shared().showBlueThermDeviceList()
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
     
    @IBAction func RememberFilterSettingsSwitchValueChanged(_ sender: UISwitch) {
        Session.RememberFilterSettings = RememberFilterSettingsSwitch.isOn
        let defaults = UserDefaults.standard
        defaults.set(Session.RememberFilterSettings, forKey: "RememberFilterSettings")
    }
    
    @IBAction func FilterOnTasksSwitchValueChanged(_ sender: UISwitch) {
        Session.FilterOnTasks = FilterOnTasksSwitch.isOn
        let defaults = UserDefaults.standard
        defaults.set(Session.FilterOnTasks, forKey: "FilterOnTasks")
    }

    // MARK: - Navigationj7
    
    
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
                let userPrompt: UIAlertController = UIAlertController(title: "Upload Tasks?", message: "Upload unsent tasks to COMPASS?", preferredStyle: UIAlertController.Style.alert)

                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "Cancel",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Upload",
                    style: UIAlertAction.Style.destructive,
                    handler: self.UploadHandler))

                present(userPrompt, animated: true, completion: nil)

            case 1:
                //download data
                let userPrompt: UIAlertController = UIAlertController(title: "Synchronise Data", message: "Are you sure you want to synchronise data with COMPASS?", preferredStyle: UIAlertController.Style.alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "Cancel",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Download",
                    style: UIAlertAction.Style.destructive,
                    handler: self.ResynchroniseHandler))

                present(userPrompt, animated: true, completion: nil)
                
            case 2:
                //reset synchronisation dates
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset the synchronisation dates?", preferredStyle: UIAlertController.Style.alert)
 
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertAction.Style.destructive,
                    handler: self.ResetSynchronisationHandler))

                present(userPrompt, animated: true, completion: nil)
                
            case 3:
                //reset tasks
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset all tasks?", preferredStyle: UIAlertController.Style.alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertAction.Style.destructive,
                    handler: self.ResetTaskHandler))
                
                present(userPrompt, animated: true, completion: nil)
                
            case 4:
                //reset all data
                let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "Are you sure you want to reset all data?", preferredStyle: UIAlertController.Style.alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "No",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "Yes",
                    style: UIAlertAction.Style.destructive,
                    handler: self.ResetAllDataSecondPromptHandler))
                
                present(userPrompt, animated: true, completion: nil)

            case 5:
                //backup database
                var result: Bool
                var message: String
                (result, message) = Utility.backupDatabase("COMPASSDB.sqlite")
                result = message == "";
                if(!result){
                    let userPrompt: UIAlertController = UIAlertController(title: "Backup failed", message: message, preferredStyle: UIAlertController.Style.alert)
                    userPrompt.addAction(UIAlertAction(
                        title: "Ok",
                        style: UIAlertAction.Style.cancel,
                        handler: nil))
                    present(userPrompt, animated: true, completion: nil)
                }
                else
                {
                    let userPrompt: UIAlertController = UIAlertController(title: "Backup", message: "Backup successful", preferredStyle: UIAlertController.Style.alert)
                    userPrompt.addAction(UIAlertAction(
                        title: "Ok",
                        style: UIAlertAction.Style.cancel,
                        handler: nil))
                    present(userPrompt, animated: true, completion: nil)
                }
                
                
            default:
                print("default")
            }
            
        case 3:
            switch indexPath.row
            {
            case 0:
                let urlString = Session.WebProtocol + Session.Server + "/HelpDocuments/COMPASSMOBILE/COMPASSMOBILE-Tasks-User-Guide-for-iOS.pdf"
                let url = URL(string: urlString)
                let application = UIApplication.shared
                application.openURL(url!)
            case 1:
                debugTapFunction()
            default:
                print("default")
            }
        
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

        //headsUpDisplay!.label.text = "Uploading"
        //headsUpDisplay!.showWhileExecuting({Utility.SendTasks(self, HUD: self.headsUpDisplay)}, animated: true)

        headsUpDisplay = MBProgressHUD.showAdded(to: self.view, animated: true)
        headsUpDisplay!.mode = .determinate
        headsUpDisplay!.label.text = "Synchronising"
        
        DispatchQueue.global().async
            {
                Utility.SendTasks(self, HUD: self.headsUpDisplay!)
               
                DispatchQueue.main.async
                    {
                        self.headsUpDisplay!.hide(animated: true)
                    }
            }
    }
    
    func ResynchroniseHandler (_ actionTarget: UIAlertAction) {

        //headsUpDisplay!.label.text = "Downloading"
        //headsUpDisplay!.showWhileExecuting({Utility.DownloadAll(self, HUD: self.headsUpDisplay)}, animated: true)

        headsUpDisplay = MBProgressHUD.showAdded(to: self.view, animated: true)
        headsUpDisplay!.mode = .determinate
        headsUpDisplay!.label.text = "Downloading"
        
        DispatchQueue.global().async
            {
                Utility.DownloadAll(self, HUD: self.headsUpDisplay!)
                
                DispatchQueue.main.async
                    {
                        self.headsUpDisplay!.hide(animated: true)
                    }
            }
    }
    
    func ResetSynchronisationHandler (_ actionTarget: UIAlertAction) {

        //headsUpDisplay!.label.text = "Resetting"
        //headsUpDisplay!.showWhileExecuting({Utility.ResetSynchronisationDates(self, HUD: self.headsUpDisplay)}, animated: true)

        headsUpDisplay = MBProgressHUD.showAdded(to: self.view, animated: true)
        headsUpDisplay!.mode = .determinate
        headsUpDisplay!.label.text = "Resetting"
        
        DispatchQueue.global().async
            {
                Utility.ResetSynchronisationDates(self, HUD: self.headsUpDisplay!)
                
                DispatchQueue.main.async
                    {
                        self.headsUpDisplay!.hide(animated: true)
                    }
            }
    }
    
    func ResetTaskHandler (_ actionTarget: UIAlertAction) {

        //headsUpDisplay!.label.text = "Resetting"
        //headsUpDisplay!.showWhileExecuting({Utility.ResetTasks(self, HUD: self.headsUpDisplay)}, animated: true)

        headsUpDisplay = MBProgressHUD.showAdded(to: self.view, animated: true)
        headsUpDisplay!.mode = .determinate
        headsUpDisplay!.label.text = "Resetting"
        
        DispatchQueue.global().async
            {
                Utility.ResetTasks(self, HUD: self.headsUpDisplay!)
                
                DispatchQueue.main.async
                    {
                        self.headsUpDisplay!.hide(animated: true)
                    }
            }
    }
    
    func ResetAllDataSecondPromptHandler (_ actionTarget: UIAlertAction) {
        let userPrompt: UIAlertController = UIAlertController(title: "Confirm reset", message: "The action you are about to take cannot be undone and will erase all data on this device.  Are you sure you want to proceeed?", preferredStyle: UIAlertController.Style.alert)
        
        //the cancel action
        userPrompt.addAction(UIAlertAction(
            title: "No",
            style: UIAlertAction.Style.cancel,
            handler: nil))
        
        //the destructive option
        userPrompt.addAction(UIAlertAction(
            title: "Yes",
            style: UIAlertAction.Style.destructive,
            handler: self.ResetAllDataHandler))
        
        present(userPrompt, animated: true, completion: nil)
    }
    
    func ResetAllDataHandler (_ actionTarget: UIAlertAction) {

        //headsUpDisplay!.labelText = "Resetting"
        //headsUpDisplay!.showWhileExecuting({Utility.ResetAllData(self, HUD: self.headsUpDisplay)}, animated: true)
        
        headsUpDisplay = MBProgressHUD.showAdded(to: self.view, animated: true)
        headsUpDisplay!.mode = .determinate
        headsUpDisplay!.label.text = "Resetting"
        
        DispatchQueue.global().async
            {
                Utility.ResetAllData(self, HUD: self.headsUpDisplay!)
                
                DispatchQueue.main.async
                    {
                        self.headsUpDisplay!.hide(animated: true)

                        //Logout
                        Session.OperativeId = nil
                        Session.OrganisationId = "00000000-0000-0000-0000-000000000000"
                        _ = self.navigationController?.popViewController(animated: true)
                    }
            }
    }
    
    @objc func debugTapFunction(){
        showDebug = showDebug + 1
        if(showDebug>4) {Debug.isHidden = false}
    }
}
