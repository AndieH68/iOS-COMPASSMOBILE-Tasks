//
//  TemperatureProfileViewController.swift
//  COMPASSMOBILE Tasks
//
//  Created by Andrew Harper on 23/01/2017.
//  Copyright © 2017 HYDOP E.C.S. All rights reserved.
//

import AVFoundation
import UIKit

class TemperatureProfileViewController: UITableViewController, UITextFieldDelegate, ETIPassingData, AlertMessageDelegate
{
    
    //MARK: - Variables
    
    let MinuteLength: Int = 60
    
    @IBOutlet var TemperatureProfileTableView: UITableView!
    @IBOutlet var HeaderCell: UITableViewCell!
    
    let HotLabel: String = "Hot Temperatute Profile"
    let HotLabelColor: UIColor = UIColor.redColor()
    let HotReading1Label: String = "Temperature @ 1 min"
    let HotReading2Label: String = "Temperature @ 2 min"
    let HotReading3Label: String = "Temperature @ 3 min"
    let HotReading4Label: String = "Temperature @ 4 min"
    let HotReading5Label: String = "Temperature @ 5 min"
    
    let ColdLabel: String = "Cold Temperatute Profile"
    let ColdLabelColor: UIColor = UIColor.blueColor()
    let ColdReading1Label: String = "Temperature @ 2 min"
    let ColdReading2Label: String = "Temperature @ 3 min"
    let ColdReading3Label: String = "Temperature @ 4 min"
    let ColdReading4Label: String = "Temperature @ 5 min"
    let ColdReading5Label: String = "Temperature @ 6 min"
    
    var profileTimer: NSTimer = NSTimer()
    var processInterval: Int = 0
    var probeTimer: NSTimer = NSTimer()

    var currentControlNumber: Int = 0
    var firstMinute: Bool = false
    
    var hot: Bool = false
    var auto: Bool = false
    
    var timerRunning: Bool = false
    
    @IBOutlet var TemperatureProfileTitleLabel: UILabel!
    @IBOutlet var TimeLabel: UILabel!
    
    @IBOutlet var Reading1Label: UILabel!
    @IBOutlet var Reading2Label: UILabel!
    @IBOutlet var Reading3Label: UILabel!
    @IBOutlet var Reading4Label: UILabel!
    @IBOutlet var Reading5Label: UILabel!
    
    @IBOutlet var Reading1TextField: UITextField!
    @IBOutlet var Reading2TextField: UITextField!
    @IBOutlet var Reading3TextField: UITextField!
    @IBOutlet var Reading4TextField: UITextField!
    @IBOutlet var Reading5TextField: UITextField!
    
    @IBOutlet var ManualButton: UIButton!
    @IBOutlet var GoStopButton: UIButton!
    @IBOutlet var AutoButton: UIButton!
    
    //MARK: - Navigation Actions
    
    @IBAction func CancelPressed(sender: UIBarButtonItem) {
        if(Session.TimerRunning)
        {
            let userPrompt: UIAlertController = UIAlertController(title: "Probe Active", message: "You have an active connection to the probe.  Please close the connection before proceeding", preferredStyle: UIAlertControllerStyle.Alert)
            
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Cancel,
                handler: nil))
            
            presentViewController(userPrompt, animated: true, completion: nil)
        }
        else
        {
            let userPrompt: UIAlertController = UIAlertController(title: "Leave Profile?", message: "Are you sure you want to leave this profile?  Any unsaved data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
            
            //the cancel action
            userPrompt.addAction(UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Cancel,
                handler: nil))
            
            //the destructive option
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Destructive,
                handler: self.CancelTask))
            
            presentViewController(userPrompt, animated: true, completion: nil)
        }
    }
    
    func CancelTask (actionTarget: UIAlertAction) {
        Session.CancelFromProfile = true;
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func DonePressed(sender: UIBarButtonItem) {
        if(Session.TimerRunning)
        {
            let userPrompt: UIAlertController = UIAlertController(title: "Probe Active", message: "You have an active connection to the probe.  Please close the connection before proceeding", preferredStyle: UIAlertControllerStyle.Alert)
            
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Cancel,
                handler: nil))
            
            presentViewController(userPrompt, animated: true, completion: nil)
        }
        else
        {
            let temperatureProfile: TemperatureProfile = TemperatureProfile()
            if (Reading1TextField.text != String())
            {
                temperatureProfile.AddNextTemperature(Reading1TextField.text!, time: String(format: "%d", 1 + (hot ? 0 : 1)))

                if (Reading2TextField.text != String())
                {
                    temperatureProfile.AddNextTemperature(Reading2TextField.text!, time: String(format: "%d", 2 + (hot ? 0 : 1)))

                    if (Reading3TextField.text != String())
                    {
                        temperatureProfile.AddNextTemperature(Reading3TextField.text!, time: String(format: "%d", 3 + (hot ? 0 : 1)))

                        if (Reading4TextField.text != String())
                        {
                            temperatureProfile.AddNextTemperature(Reading4TextField.text!, time: String(format: "%d", 4 + (hot ? 0 : 1)))

                            if (Reading5TextField.text != String())
                            {
                                temperatureProfile.AddNextTemperature(Reading5TextField.text!, time: String(format: "%d", 5 + (hot ? 0 : 1)))
                            }
                        }
                    }
                }
            }

            Session.Profile = temperatureProfile
            
            let userPrompt: UIAlertController = UIAlertController(title: "Profile", message: "Profile saved", preferredStyle: UIAlertControllerStyle.Alert)
            
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Cancel,
                handler: self.LeaveTask))
            
            presentViewController(userPrompt, animated: true, completion: nil)
        }
    }
    
    func LeaveTask (actionTarget: UIAlertAction) {
        self.navigationController?.popViewControllerAnimated(true)
    }
  
    //MARK: - Form Actions
    
    @IBAction func ManualButton(sender: UIButton) {
        if (ManualButton.currentTitle == "Man")
        {
            GoStopButton.enabled = false
            GoStopButton.backgroundColor = UIColor.darkGrayColor()
            AutoButton.enabled = false
            AutoButton.backgroundColor = UIColor.darkGrayColor()
            ManualButton.setTitle("Stop", forState: UIControlState.Normal)
            ManualButton.backgroundColor = UIColor.redColor()
            
            Reading1TextField.enabled = true
            Reading2TextField.enabled = true
            Reading3TextField.enabled = true
            Reading4TextField.enabled = true
            Reading5TextField.enabled = true
        }
        else
        {
            GoStopButton.enabled = true
            GoStopButton.backgroundColor = UIColor.blueColor()
            AutoButton.enabled = true
            AutoButton.backgroundColor = UIColor.blueColor()
            ManualButton.setTitle("Man", forState: UIControlState.Normal)
            ManualButton.backgroundColor = UIColor.blueColor()
            
            Reading1TextField.enabled = false
            Reading2TextField.enabled = false
            Reading3TextField.enabled = false
            Reading4TextField.enabled = false
            Reading5TextField.enabled = false
        }
    }
    
    @IBAction func GoStopButton(sender: UIButton) {
        if (GoStopButton.currentTitle == "Timed")
        {
            auto = false
            Session.CurrentTemperatureControl = nil
            currentControlNumber = 0
            ManualButton.enabled = false
            ManualButton.backgroundColor = UIColor.darkGrayColor()
            AutoButton.enabled = false
            AutoButton.backgroundColor = UIColor.darkGrayColor()
            GoStopButton.setTitle("Stop", forState: UIControlState.Normal)
            GoStopButton.backgroundColor = UIColor.redColor()
            if (!hot) {firstMinute = true}
            startProfileTimer()
            
        }
        else
        {
            auto = false
            Session.CurrentTemperatureControl = nil
            currentControlNumber = 0
            ManualButton.enabled = true
            ManualButton.backgroundColor = UIColor.blueColor()
            AutoButton.enabled = true
            AutoButton.backgroundColor = UIColor.blueColor()
            GoStopButton.setTitle("Timed", forState: UIControlState.Normal)
            GoStopButton.backgroundColor = UIColor.blueColor()
            stopProfileTimer()
        }
    }
    
    @IBAction func AutoButton(sender: UIButton) {
        if (AutoButton.currentTitle == "Auto")
        {
            auto = true
            Session.CurrentTemperatureControl = Reading1TextField
            Session.CurrentTemperatureControl!.backgroundColor = UIColor.greenColor()
            //Session.CurrentTemperatureControl!.enabled = false
            currentControlNumber = 1
            ManualButton.enabled = false
            ManualButton.backgroundColor = UIColor.darkGrayColor()
            GoStopButton.enabled = false
            GoStopButton.backgroundColor = UIColor.darkGrayColor()
            AutoButton.setTitle("Stop", forState: UIControlState.Normal)
            AutoButton.backgroundColor = UIColor.redColor()
            if (!hot) {firstMinute = true}
            startProfileTimer()
            startProbeTimer(0.25)
        }
        else
        {
            auto = false
            if(Session.CurrentTemperatureControl != nil)
            {
                Session.CurrentTemperatureControl!.backgroundColor = UIColor.whiteColor()
                Session.CurrentTemperatureControl = nil
            }
            currentControlNumber = 0
            ManualButton.enabled = true
            ManualButton.backgroundColor = UIColor.blueColor()
            GoStopButton.enabled = true
            GoStopButton.backgroundColor = UIColor.blueColor()
            AutoButton.setTitle("Auto", forState: UIControlState.Normal)
            AutoButton.backgroundColor = UIColor.blueColor()
            stopProfileTimer()
            stopProbeTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Reading1TextField.delegate = self
        Reading1TextField.enabled = false
        Reading2TextField.delegate = self
        Reading2TextField.enabled = false
        Reading3TextField.delegate = self
        Reading3TextField.enabled = false
        Reading4TextField.delegate = self
        Reading4TextField.enabled = false
        Reading5TextField.delegate = self
        Reading5TextField.enabled = false
        
        AutoButton.enabled = Session.BluetoothProbeConnected
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        TemperatureProfileTableView.allowsSelection = false
        
        if (hot)
        {
            TemperatureProfileTitleLabel.text = HotLabel
            TemperatureProfileTitleLabel.backgroundColor = HotLabelColor
            Reading1Label.text = HotReading1Label
            Reading2Label.text = HotReading2Label
            Reading3Label.text = HotReading3Label
            Reading4Label.text = HotReading4Label
            Reading5Label.text = HotReading5Label
        }
        else
        {
            TemperatureProfileTitleLabel.text = ColdLabel
            TemperatureProfileTitleLabel.backgroundColor = ColdLabelColor
            Reading1Label.text = ColdReading1Label
            Reading2Label.text = ColdReading2Label
            Reading3Label.text = ColdReading3Label
            Reading4Label.text = ColdReading4Label
            Reading5Label.text = ColdReading5Label
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if EAController.sharedController().callBack == nil
        {
            let eac: EAController =  EAController.sharedController()
            eac.notificationCallBack = self
            
            if !(eac.selectedAccessory.isAwaitingUI || eac.selectedAccessory.isNoneAvailable)
            {
                if (eac.selectedAccessory == nil || !(eac.openSession()))
                {
                    NSLog("No BlueTherm Connected")
                    Session.BluetoothProbeConnected = false
                    readingAndDisplaying()
                }
                else
                {
                    NSLog("BlueThermConnected")
                    Session.BluetoothProbeConnected = true
                    eac.callBack = self
                }
            }
            else
            {
                //readingAndDisplaying()
                return
            }
        }
        else
        {
            EAController.sharedController().callBack = self
            EAController.sharedController().notificationCallBack = self
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //need to work out here what type of cell so that we can return the correct height
        //nope all are fixed height now
        var height: CGFloat = 68
        if (indexPath.section == 2)
        {
            height =  168
        }
        return height
        
    }
    
    //MARK: - Profile timer
    func startProfileTimer()
    {
        startProfileTimer(1)
    }

    func startProfileTimer(interval: Int)
    {
        processInterval = 0
        let timerInterval: NSTimeInterval = NSTimeInterval(interval)
        profileTimer.invalidate()
        profileTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: #selector(processTimeInterval), userInfo: nil, repeats: true)
    }
    
    func processTimeInterval()
    {
        //update the display time
        processInterval += 1
        let minutes: Int =  Int(floor(Double(processInterval) / Double(MinuteLength)))
        let seconds: Int = Int(processInterval - (minutes * MinuteLength))
        let timerValue: String = String(format: "%02d", minutes) + "m " + String(format: "%02d", seconds) + "s"
        TimeLabel.text = timerValue
        
        if (processInterval % MinuteLength == 0)
        {
            if (auto)
            {
                if (!hot && firstMinute)
                {
                    firstMinute = false
                }
                else
                {
                    switch (currentControlNumber)
                    {
                    case 0:
                        currentControlNumber = 1
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.whiteColor()
                        Session.CurrentTemperatureControl = Reading1TextField
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.greenColor()
                        startProbeTimer(0.25)
                        
                    case 1:
                        currentControlNumber = 2
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.whiteColor()
                        Session.CurrentTemperatureControl = Reading2TextField
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.greenColor()
                      
                    case 2:
                        currentControlNumber = 3
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.whiteColor()
                        Session.CurrentTemperatureControl = Reading3TextField
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.greenColor()

                    case 3:
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.whiteColor()
                        currentControlNumber = 4
                        Session.CurrentTemperatureControl = Reading4TextField
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.greenColor()

                    case 4:
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.whiteColor()
                        currentControlNumber = 5
                        Session.CurrentTemperatureControl = Reading5TextField
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.greenColor()

                    default:
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.whiteColor()
                        Session.CurrentTemperatureControl = nil
                        currentControlNumber = 0
                        auto = false
                        currentControlNumber = 0
                        ManualButton.enabled = true
                        ManualButton.backgroundColor = UIColor.blueColor()
                        GoStopButton.enabled = true
                        GoStopButton.backgroundColor = UIColor.blueColor()
                        AutoButton.setTitle("Auto", forState: UIControlState.Normal)
                        AutoButton.backgroundColor = UIColor.blueColor()
                        stopProfileTimer()
                        stopProbeTimer()
                    }
                }
            }
            else
            {
                if (!hot && firstMinute)
                {
                    firstMinute = false
                }
                else
                {
                    switch (currentControlNumber)
                    {
                    case 0:
                        currentControlNumber = 1
                        Reading1TextField.enabled = true
                                                
                    case 1:
                        currentControlNumber = 2
                        Reading2TextField.enabled = true
                        
                    case 2:
                        currentControlNumber = 3
                        Reading3TextField.enabled = true
                        
                    case 3:
                        currentControlNumber = 4
                        Reading4TextField.enabled = true
                        
                    case 4:
                        currentControlNumber = 5
                        Reading5TextField.enabled = true
                        stopProfileTimer()
                        
                    default:
                        stopProfileTimer()
                    }
                }
            }
        }
    }
    
    func stopProfileTimer()
    {
        profileTimer.invalidate()
    }
    
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (Session.TimerRunning)
        {
            return false
        }
        return true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (Session.BluetoothProbeConnected)
        {
            if(!Session.TimerRunning)
            {
                Session.CurrentTemperatureControl = textField
                Session.CurrentTemperatureControl!.backgroundColor = UIColor.greenColor()
                Session.CurrentTemperatureControl!.enabled = false
                startProbeTimer(0.25)
            }
        }
        self.addDoneButtonOnKeyboard(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (Session.BluetoothProbeConnected)
        {
            stopProbeTimer()
            Session.CurrentTemperatureControl!.enabled = true
        }
        textField.resignFirstResponder()
    }
    
    //MARK: - Probe
    
    func readingAndDisplaying()
    {
        if ProbeProperties.isBlueThermConnected()
        {
            Session.CurrentReading = ProbeProperties.sensor1Reading()
        }
        else
        {
            Session.CurrentReading = nil
        }
        
        //set the value on the control with focus
        Session.CurrentTemperatureControl?.text = Session.CurrentReading
    }
    
    func startProbeTimer(interval: Double)
    {
        let timerInterval: NSTimeInterval = NSTimeInterval(interval)
        probeTimer.invalidate()
        probeTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: #selector(TemperatureProfileViewController.doSend), userInfo: nil, repeats: true)
        Session.TimerRunning = true
    }
    
    func stopProbeTimer()
    {
        probeTimer.invalidate()
        Session.TimerRunning = false
    }
    
    func doSend()
    {
        EAController.doSend()
    }
    
    // MARK: Probe functions
    func settingTheProbe() {
        print("Set reply")
    }
    
    func probeButtonHasBeenPressed() {
        print("BlueTherm button has been pressed")
        if(auto)
        {
            stopProfileTimer()
        }
        stopProbeTimer()
        if Session.CurrentTemperatureControl != nil
        {
            Session.CurrentTemperatureControl!.backgroundColor = UIColor.whiteColor()
            Session.CurrentTemperatureControl!.enabled = true
            Session.CurrentTemperatureControl!.resignFirstResponder()
        }
    }
    
    func soundtheAlarmInBackground() {
        //displayAlarm
    }
    
    func blueThermConnected() {
        print("BlueTherm has connected")
        Session.BluetoothProbeConnected = true
    }
    
    func bluethermDisconnected() {
        print("BlueTherm has disconnected")
        Session.BluetoothProbeConnected = false
        readingAndDisplaying()
    }
    
    func newBlueThermFound() {
        print("New BlueTherm found")
    }
    
    func displayEmissivity() {
        print("Display emissivity")
        
        let emissivity: String = ProbeProperties.getEmissivityValue()
        
        print("Emissivity value: %@",emissivity)
    }
    
    
    //MARK: Alert Messages Delegate
    func alertMessagesCreateAlertViewNoConnectionFoundSHOW() {
        Session.BluetoothProbeConnected = false
    }
    
    func alertMessagesCreateAlertViewNoConnectionFoundDISMISS() {
        Session.BluetoothProbeConnected = true
    }
    
    func alertViewConnectionHasBeenLostSHOW() {
        Session.BluetoothProbeConnected = false
    }
    
    func alertViewConnectionHasBeenLostDISMISS() {
        Session.BluetoothProbeConnected = true
    }
    
    func addDoneButtonOnKeyboard(view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: view, action: #selector(UIResponder.resignFirstResponder))
        var items: [UIBarButtonItem] = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        if let accessorizedView = view as? UITextView {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        } else if let accessorizedView = view as? UITextField {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        }
        
    }
    

}
