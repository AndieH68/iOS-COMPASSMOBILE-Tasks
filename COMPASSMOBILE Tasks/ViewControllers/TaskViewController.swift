//
//
//  Created by Andrew Harper on 20/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import BRYXBanner
import Foundation
import MBProgressHUD
import UIKit

class TaskViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate, ETIPassingData, AlertMessageDelegate {
    // MARK: Variables

    var instanceOfCustomObject: ThermaLib = ThermaLib()

    var task: Task = Task()
    var asset: Asset = Asset()

    var taskTemplateParameterFormItems: Dictionary<String, TaskTemplateParameterFormItem> = Dictionary<String, TaskTemplateParameterFormItem>()
    var formTaskTemplateParameters: [TaskTemplateParameter] = [TaskTemplateParameter]()

    var removeAssetParameter: TaskTemplateParameter = TaskTemplateParameter()
    var alternateAssetCodeParameter: TaskTemplateParameter = TaskTemplateParameter()
    var additionalNotesParameter: TaskTemplateParameter = TaskTemplateParameter()

    var taskTemperatureProfiles: Dictionary<String, TemperatureProfile> = Dictionary<String, TemperatureProfile>()

    var probeTimer: Timer = Timer()

    var activeField: UITextField?

    // parameter table
    @IBOutlet var taskParameterTable: UITableView!

    // header fields
    @IBOutlet var AssetType: UILabel!
    @IBOutlet var TaskName: UILabel!
    @IBOutlet var Location: UILabel!
    @IBOutlet var AssetNumber: UILabel!
    @IBOutlet var TaskReference: UILabel!

    // footer fields
    @IBOutlet var AdditionalNotes: UITextView!
    @IBOutlet var RemoveAsset: UISwitch!
    @IBOutlet var AlternateAssetCode: UITextField!
    @IBOutlet var TaskTimeTakenStack: UIStackView!
    @IBOutlet var TaskTravelTimeStack: UIStackView!
    @IBOutlet var TaskTimeLabel: UILabel!
    @IBOutlet var TaskTime: UITextField!
    @IBOutlet var TravelTimeLabel: UILabel!
    @IBOutlet var TravelTime: UITextField!

    var HotType: String?
    var ColdType: String?

    // MARK: Form load & show

    deinit {
        if Session.UseBlueToothProbe {
            NotificationCenter.default.removeObserver(self)
        }
    }

    // standard actions
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()

        // self.device = Session.CurrentDevice

        if Session.UseBlueToothProbe {
            instanceOfCustomObject = ThermaLib.sharedInstance()
            NotificationCenter.default.addObserver(self, selector: #selector(newDeviceFound), name: Notification.Name(rawValue: ThermaLibNewDeviceFoundNotificationName), object: nil)
            // Listen for sensor updates
            NotificationCenter.default.addObserver(self, selector: #selector(sensorUpdatedNotificationReceived), name: Notification.Name(rawValue: ThermaLibSensorUpdatedNotificationName), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(deviceNotificationReceived), name: Notification.Name(ThermaLibNotificationReceivedNotificationName), object: nil)
        }
        Session.CodeScanned = nil
        Session.MatrixScanned = nil

        task = ModelManager.getInstance().getTask(Session.TaskId!)!

        if task.AssetId != nil {
            // get the hot cold details for the task
            let asset: Asset? = ModelManager.getInstance().getAsset(task.AssetId!)
            if asset != nil {
                HotType = asset!.HotType != nil ? asset!.HotType : "None"
                ColdType = asset!.ColdType != nil ? asset!.ColdType : "None"
            } else {
                // asset is missing - need to notify user to resync assets
                let userPrompt: UIAlertController = UIAlertController(title: "Missing asset", message: "The asset record for this task is missing", preferredStyle: UIAlertController.Style.alert)

                // the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.destructive,
                    handler: LeaveTask))

                present(userPrompt, animated: true, completion: nil)
            }

            // are we recording task times
            TaskTimeTakenStack.isHidden = !Session.UseTaskTiming
            TaskTravelTimeStack.isHidden = !Session.UseTaskTiming
        }
        if task.PPMGroup != nil {
            AssetType.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!) + " - " + ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!)
        } else {
            AssetType.text = task.AssetType ?? "Missing Asset Type"
        }

        if task.TaskName == RemedialTask {
            TaskName.text = RemedialTask
        } else {
            TaskName.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup)
        }

        Location.text = task.LocationName
        if let assetNumber: String = task.AssetNumber { AssetNumber.text = assetNumber } else { AssetNumber.text = "no asset" }
        TaskReference.text = task.TaskRef

        // get the the parameters for the table
        if TaskName.text != RemedialTask {
            let taskTemplateId = task.TaskTemplateId

            var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            criteria["TaskTemplateId"] = taskTemplateId as AnyObject?

            formTaskTemplateParameters = ModelManager.getInstance().findTaskTemplateParameterList(criteria)

            for taskTemplateParameter: TaskTemplateParameter in formTaskTemplateParameters {
                taskTemplateParameterFormItems[taskTemplateParameter.RowId] = TaskTemplateParameterFormItem(taskTemplateParameter: taskTemplateParameter)
                if taskTemplateParameter.Predecessor != nil {
                    let keyExists = taskTemplateParameterFormItems[taskTemplateParameter.Predecessor!] != nil

                    if !keyExists {
                        // the predecessor item does not yet exist
                        taskTemplateParameterFormItems[taskTemplateParameter.Predecessor!] = TaskTemplateParameterFormItem(taskTemplateParameter: TaskTemplateParameter())
                    }

                    // the predecessor item already exists
                    let taskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[taskTemplateParameter.Predecessor!]!
                    taskTemplateParameterFormItem.Dependencies.append(taskTemplateParameterFormItems[taskTemplateParameter.RowId]!)
                }
            }

            if formTaskTemplateParameters.count > 3 {
                // additional notes will always be the last record
                additionalNotesParameter = formTaskTemplateParameters[formTaskTemplateParameters.count - 1]
                formTaskTemplateParameters.removeLast()

                // remove alternate asset code and remove asset
                alternateAssetCodeParameter = formTaskTemplateParameters[1]
                formTaskTemplateParameters.remove(at: 1)

                removeAssetParameter = formTaskTemplateParameters[0]
                formTaskTemplateParameters.remove(at: 0)
            }
        }

        AdditionalNotes.delegate = self
        AlternateAssetCode.delegate = self
        TaskTime.delegate = self
        TravelTime.delegate = self

        // reload the table
        taskParameterTable.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        if Session.GettingAlternateAssetCode {
            if (!Session.CancelFromScan) {
                AlternateAssetCode.text = Session.CodeScanned!
                Session.CodeScanned = nil
                Session.GettingAlternateAssetCode = false
            }
            Session.CancelFromScan = false;
        }
        
        if Session.GettingProfile {
            if Session.CurrentProfileControl != nil && !Session.CancelFromProfile {
                taskTemperatureProfiles[Session.CurrentProfileControl!.restorationIdentifier!] = Session.Profile
                Session.CurrentProfileControl!.text = Session.Profile?.ToStringForDisplay()
                Session.CurrentProfileControl = nil
                Session.Profile = nil
                Session.GettingProfile = false
            }
            Session.CancelFromProfile = false
        }

        if Session.GettingScanUniversal {
            if Session.CurrentScanUniversalControl != nil && !Session.CancelFromScan {
                if Session.CurrentScanUniversalControl!.restorationIdentifier != nil {
                    if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[Session.CurrentScanUniversalControl!.restorationIdentifier!]
                    {
                        if (Session.MatrixScanned != nil)
                        {
                            currentTaskTemplateParameterFormItem.SelectedItem = Session.MatrixScanned!
                            Session.CurrentScanUniversalControl!.text = Session.MatrixScanned!
                        }
                        else if Session.CodeScanned != nil
                        {
                            currentTaskTemplateParameterFormItem.SelectedItem = Session.CodeScanned!
                            Session.CurrentScanUniversalControl!.text = Session.CodeScanned!
                        }
                    }
                }
                
                Session.CurrentScanUniversalCell!.updateFromAnswer()
                Session.CurrentScanUniversalControl = nil
                Session.MatrixScanned = nil
                Session.CodeScanned = nil
                Session.GettingScanUniversal = false
            }
            Session.CancelFromScan = false
        }

        if Session.GettingDataMatrix {
            if Session.CurrentDataMatrixControl != nil && !Session.CancelFromScan {
                if Session.CurrentDataMatrixControl!.restorationIdentifier != nil {
                    if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[Session.CurrentDataMatrixControl!.restorationIdentifier!]
                    {
                        currentTaskTemplateParameterFormItem.SelectedItem = Session.MatrixScanned!
                    }
                }
                Session.CurrentDataMatrixControl!.text = Session.MatrixScanned!
                Session.CurrentDataMatrixCell!.updateFromAnswer()
                Session.CurrentDataMatrixControl = nil
                Session.MatrixScanned = nil
                Session.GettingDataMatrix = false
            }
            Session.CancelFromScan = false
        }
        
        if Session.GettingScanCode {
            if Session.CurrentScanCodeControl != nil && !Session.CancelFromScan {
                if Session.CurrentScanCodeControl!.restorationIdentifier != nil {
                    if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[Session.CurrentScanCodeControl!.restorationIdentifier!]
                    {
                        currentTaskTemplateParameterFormItem.SelectedItem = Session.CodeScanned!
                    }
                }
                Session.CurrentScanCodeControl!.text = Session.CodeScanned!
                Session.CurrentScanCodeControl = nil
                Session.CodeScanned = nil
                Session.GettingScanCode = false
            }
            Session.CancelFromScan = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        taskParameterTable.allowsSelection = false

        if Session.UseBlueToothProbe {
            // Start scanning for devices
            let banner: Banner
            if !Session.ThermaQBluetoothProbeConnected {
                if !Session.BluetoothProbeConnected {
                    NSLog("Scanning for new ThermaQ Device")
                    banner = Banner(title: "Scanning", subtitle: "Scanning for ThermaQ Device", image: nil, backgroundColor: UIColor(red: 48.00 / 255.0, green: 174.0 / 255.0, blue: 51.5 / 255.0, alpha: 1.000))
                    banner.show(duration: 4.0)

                    instanceOfCustomObject.startDeviceScan()
                } else if Session.BluetoothProbeConnected && EAController.shared().selectedAccessory.isAwaitingUI {
                    stopProbeTimer()
                    Session.BluetoothProbeConnected = false

                    NSLog("Scanning for new ThermaQ Device")
                    banner = Banner(title: "Scanning", subtitle: "Scanning for ThermaQ Device", image: nil, backgroundColor: UIColor(red: 48.00 / 255.0, green: 174.0 / 255.0, blue: 51.5 / 255.0, alpha: 1.000))
                    banner.show(duration: 4.0)
                    instanceOfCustomObject.startDeviceScan()
                }

                let scantimer = DispatchTime.now() + 4
                DispatchQueue.main.asyncAfter(deadline: scantimer, execute: {
                    let devicelist = self.instanceOfCustomObject.deviceList()
                    if devicelist!.count == 0 {
                        let bannerFound = Banner(title: "Scanning", subtitle: "No New ThermaQ device found. Scanning now for old Probe", image: nil, backgroundColor: UIColor(red: 0.78, green: 0.12, blue: 0.12, alpha: 1.0))
                        bannerFound.dismissesOnTap = true
                        bannerFound.show(duration: 2)
                        bannerFound.dismiss()
                        if EAController.shared().callBack == nil {
                            let eac: EAController = EAController.shared()
                            eac.notificationCallBack = nil

                            if !(eac.selectedAccessory.isAwaitingUI || eac.selectedAccessory.isNoneAvailable)
                            {
                                if eac.selectedAccessory == nil || !eac.openSession() {
                                    NSLog("No BlueTherm Connected")
                                    Session.BluetoothProbeConnected = false
                                    self.readingAndDisplaying()
                                } else {
                                    if !Session.BluetoothProbeConnected {
                                        let bannerFound = Banner(title: "Connected", subtitle: "Connected to old " + eac.selectedAccessory.getAccessory().name, image: nil, backgroundColor: UIColor(red: 48.00 / 255.0, green: 174.0 / 255.0, blue: 51.5 / 255.0, alpha: 1.000))
                                        bannerFound.dismissesOnTap = true
                                        bannerFound.show(duration: 2)
                                    }
                                    NSLog("BlueThermConnected")
                                    Session.BluetoothProbeConnected = true
                                    eac.callBack = self
                                }
                            } else {
                                // readingAndDisplaying()
                                return
                            }
                        } else {
                            EAController.shared().notificationCallBack = self
                            EAController.shared().callBack = self
                        }
                    } else {
                        if !Session.ThermaQBluetoothProbeConnected && Session.CurrentDevice == nil {
                            let devicelist = self.instanceOfCustomObject.deviceList()
                            for device in devicelist! {
                                if device.deviceName.contains("ThermaQ") {
                                    Session.ThermaQBluetoothProbeConnected = true
                                    Session.CurrentDevice = device
                                }
                            }
                            self.instanceOfCustomObject.connect(to: Session.CurrentDevice)
                            let banner = Banner(title: "Connected", subtitle: "Connected to " + (Session.CurrentDevice?.deviceName)!, image: nil, backgroundColor: UIColor(red: 48.00 / 255.0, green: 174.0 / 255.0, blue: 51.5 / 255.0, alpha: 1.000))
                            banner.dismissesOnTap = true
                            banner.show(duration: 3.0)
                        }
                        return
                    }
                })
            }
        }
    }

    // MARK: New proble notifications

    @objc func newDeviceFound(_ sender: Notification) {
        // A new device has been found so refresh the table
        let devicelist = instanceOfCustomObject.deviceList()
        for device in devicelist! {
            if device.deviceName.contains("ThermaQ") {
                Session.ThermaQBluetoothProbeConnected = true
                Session.CurrentDevice = device
            }
        }
        if Session.CurrentDevice?.isConnected() == false {
            instanceOfCustomObject.connect(to: Session.CurrentDevice)
            var connectionState: TLDeviceConnectionState? = Session.CurrentDevice?.connectionState
            while connectionState != TLDeviceConnectionState.connected {
                connectionState = Session.CurrentDevice?.connectionState
            }
            if connectionState == TLDeviceConnectionState.connected {
                let banner = Banner(title: "Connected", subtitle: "Connected to " + (Session.CurrentDevice?.deviceName)!, image: nil, backgroundColor: UIColor(red: 48.00 / 255.0, green: 174.0 / 255.0, blue: 51.5 / 255.0, alpha: 1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }
        }
    }

    @objc func sensorUpdatedNotificationReceived(_ sender: Notification) {
        if Session.ReadingDevice != 0 {
            var SensorIndex: UInt = 0
            let Sensor1: Bool = (Session.CurrentDevice?.isSensorEnabled(at: 0))!
            let Sensor2: Bool = (Session.CurrentDevice?.isSensorEnabled(at: 1))!
            if Sensor1 {
                SensorIndex = 0
            } else if Sensor2 {
                SensorIndex = 1
            } else {
                let banner = Banner(title: "Sensor", subtitle: "Sensors not Enabled", image: nil, backgroundColor: UIColor(red: 48.00 / 255.0, green: 174.0 / 255.0, blue: 51.5 / 255.0, alpha: 1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }
            let currentSensor: TLSensor = (Session.CurrentDevice?.sensor(at: SensorIndex))!
            let reading = currentSensor.reading
            Session.CurrentTemperatureControl?.text = String(format: "%.1f", reading)
        }
    }

    @objc func deviceNotificationReceived(sender: Notification) {
        let cDevice: TLDevice = sender.object as! TLDevice
        var connectionState: TLDeviceConnectionState? = cDevice.connectionState
        sleep(3)
        connectionState = cDevice.connectionState
        if connectionState == TLDeviceConnectionState.disconnected || connectionState == TLDeviceConnectionState.disconnecting {
            instanceOfCustomObject.remove(Session.CurrentDevice)
            Session.ThermaQBluetoothProbeConnected = false
            Session.CurrentDevice = nil
            return
        }
        //        let scantimer = DispatchTime.now() + 0
        //        DispatchQueue.main.asyncAfter(deadline: scantimer, execute: {
        //            connectionState = cDevice.connectionState
        //            if connectionState == TLDeviceConnectionState.disconnected || connectionState == TLDeviceConnectionState.disconnecting{
        //                self.instanceOfCustomObject.remove(Session.CurrentDevice)
        //                Session.ThermaQBluetoothProbeConnected = false
        //                Session.CurrentDevice = nil
        //                return
        //            }
        //        })

        if Session.ReadingDevice == 1 {
            Session.ReadingDevice = 0
            probeButtonHasBeenPressed()
        } else {
            Session.ReadingDevice = 1
        }
    }

    // MARK: Keyboard handling methods

    func registerForKeyboardNotifications() {
        // Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIControl.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIControl.keyboardWillHideNotification, object: nil)
    }

    func deregisterFromKeyboardNotifications() {
        // Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size

        let tabbarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        let toolbarHeight = navigationController?.toolbar.frame.size.height ?? 0
        let bottomInset = keyboardSize.height - tabbarHeight - toolbarHeight

        tableView.contentInset.bottom = bottomInset
        tableView.scrollIndicatorInsets.bottom = bottomInset
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }

    // MARK: UITableView delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formTaskTemplateParameters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let taskTemplateParameter: TaskTemplateParameter = formTaskTemplateParameters[indexPath.row]
        let taskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[taskTemplateParameter.RowId]!

        var predecessor: String?
        if taskTemplateParameter.Predecessor != nil {
            predecessor = taskTemplateParameter.Predecessor!
        } else {
            taskTemplateParameterFormItem.Enabled = true
        }

        if predecessor != nil {
            let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[predecessor!]!

            // we did this when the form was loaded.
            // currentTaskTemplateParameterFormItem.Dependencies.append(taskTemplateParameterFormItem)

            if currentTaskTemplateParameterFormItem.SelectedItem == taskTemplateParameter.PredecessorTrueValue
            {
                taskTemplateParameterFormItem.Enabled = true
            }
        }

        if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TemperatureCell", for: indexPath) as! TaskTemplateParameterCellTemperature
            cell.restorationIdentifier = taskTemplateParameter.RowId
            if HotType == "Blended" && taskTemplateParameter.ParameterDisplay == "Hot Temperature" {
                cell.Question.text = "Blended Temperature"
            } else {
                cell.Question.text = taskTemplateParameter.ParameterDisplay
            }
            cell.Question.textColor = taskTemplateParameterFormItem.LabelColour
            cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

            cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
            cell.Answer.delegate = self

            if taskTemplateParameterFormItem.SelectedItem != nil {
                cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
            }

            cell.Answer.tag = TemperatureCell

            if (taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "None") || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "None")
            {
                taskTemplateParameterFormItem.Enabled = false
                cell.ProfileButton.isHidden = true
                cell.ProfileButton.isEnabled = false
            } else {
                if (taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "Hot") || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "Cold") || (taskTemplateParameter.ParameterName == "TemperatureFeedHot") || (taskTemplateParameter.ParameterName == "TemperatureFeedCold")
                {
                    cell.Answer.isEnabled = (taskTemplateParameterFormItem.Enabled && !Session.UseTemperatureProfile)
                    cell.ProfileButton.isHidden = !Session.UseTemperatureProfile
                    cell.ProfileButton.isEnabled = (taskTemplateParameterFormItem.Enabled && !Session.UseTemperatureProfile)

                    cell.Answer.tag = taskTemplateParameter.ParameterName.contains("Hot") ? TemperatureProfileCellHot : TemperatureProfileCellCold

                    cell.ProfileButton.tag = cell.Answer.tag
                } else {
                    cell.Answer.isEnabled = taskTemplateParameterFormItem.Enabled
                    cell.ProfileButton.isHidden = true
                    cell.ProfileButton.isEnabled = taskTemplateParameterFormItem.Enabled
                }
            }

            return cell
        } else  {
            switch taskTemplateParameter.ParameterType {
            case "Scan Universal":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScanUniversalCell", for: indexPath) as! TaskTemplateParameterCellScanUniversal
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay

                cell.Question.textColor = taskTemplateParameterFormItem.LabelColour
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self

                if taskTemplateParameterFormItem.SelectedItem != nil {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }

                cell.Answer.tag = ScanUniversalCell

                cell.Answer.isEnabled = (taskTemplateParameterFormItem.Enabled)
                cell.ScanUniversalButton.isHidden = false
                cell.ScanUniversalButton.isEnabled = (taskTemplateParameterFormItem.Enabled)
                cell.ScanUniversalTextButton.isHidden = false
                cell.ScanUniversalTextButton.isEnabled = (taskTemplateParameterFormItem.Enabled)
                
                cell.ScanUniversalButton.tag = cell.Answer.tag
                return cell
                
            case "GS1 Data Matrix":
                let cell = tableView.dequeueReusableCell(withIdentifier: "DataMatrixCell", for: indexPath) as! TaskTemplateParameterCellDataMatrix
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay

                cell.Question.textColor = taskTemplateParameterFormItem.LabelColour
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self

                if taskTemplateParameterFormItem.SelectedItem != nil {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }

                cell.Answer.tag = DataMatrixCell

                cell.Answer.isEnabled = (taskTemplateParameterFormItem.Enabled)
                cell.DataMatrixButton.isHidden = false
                cell.DataMatrixButton.isEnabled = (taskTemplateParameterFormItem.Enabled)

                cell.DataMatrixButton.tag = cell.Answer.tag
                return cell
                
            case "Scan Code":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScanCodeCell", for: indexPath) as! TaskTemplateParameterCellScanCode
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay

                cell.Question.textColor = taskTemplateParameterFormItem.LabelColour
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self

                if taskTemplateParameterFormItem.SelectedItem != nil {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }

                cell.Answer.tag = ScanCodeCell

                cell.Answer.isEnabled = (taskTemplateParameterFormItem.Enabled)
                cell.ScanCodeButton.isHidden = false
                cell.ScanCodeButton.isEnabled = (taskTemplateParameterFormItem.Enabled)

                cell.ScanCodeButton.tag = cell.Answer.tag
                return cell
                
            case "Freetext":
                let cell = tableView.dequeueReusableCell(withIdentifier: "FreetextCell", for: indexPath) as! TaskTemplateParameterCellFreetext
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor = taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                if taskTemplateParameterFormItem.SelectedItem != nil {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }
                cell.Answer.isEnabled = taskTemplateParameterFormItem.Enabled
                return cell

            case "Number":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath) as! TaskTemplateParameterCellNumber
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor = taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                if taskTemplateParameterFormItem.SelectedItem != nil {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }
                cell.Answer.isEnabled = taskTemplateParameterFormItem.Enabled
                return cell

            case "Reference Data":
                let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath) as! TaskTemplateParameterCellDropdown
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor = taskTemplateParameterFormItem.LabelColour

                var dropdownData: [String] = []

                dropdownData.append(PleaseSelect)
                dropdownData.append(contentsOf: ModelUtility.getInstance().GetLookupList(taskTemplateParameter.ReferenceDataType!, ExtendedReferenceDataType: taskTemplateParameter.ReferenceDataExtendedType))
                if taskTemplateParameter.ParameterName != "Accessible" {
                    dropdownData.append(NotApplicable)
                }

                cell.AnswerSelector.restorationIdentifier = taskTemplateParameter.RowId
                cell.AnswerSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                cell.AnswerSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.AnswerSelector.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.AnswerSelector.options = dropdownData.map { KFPopupSelector.Option.text(text: $0) }
                cell.AnswerSelector.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                var selectedItem: Int = 0

                if taskTemplateParameterFormItem.SelectedItem != nil {
                    var count: Int = 0
                    for value in dropdownData {
                        if value == taskTemplateParameterFormItem.SelectedItem {
                            selectedItem = count
                            break
                        }
                        count += 1
                    }
                }

                cell.AnswerSelector.selectedIndex = selectedItem
                cell.AnswerSelector.unselectedLabelText = PleaseSelect
                cell.AnswerSelector.displaySelectedValueInLabel = true
                if taskTemplateParameter.ParameterName == Accessible {
                    cell.AnswerSelector.isEnabled = true
                } else {
                    cell.AnswerSelector.isEnabled = taskTemplateParameterFormItem.Enabled
                }

                return cell

            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FreetextCell", for: indexPath) as! TaskTemplateParameterCellFreetext
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor = taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                if taskTemplateParameterFormItem.SelectedItem != nil {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }

                return cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // need to work out here what type of cell so that we can return the correct height
        // nope all are fixed height now
        //return 68
        let taskTemplateParameter: TaskTemplateParameter = formTaskTemplateParameters[indexPath.row]
        if taskTemplateParameter.ParameterType == "GS1 Data Matrix" || taskTemplateParameter.ParameterType == "Scan Universal"
        {
            return 134
        }
        else
        {
            return 68
        }
    }

    // MARK: Control handling

    fileprivate func ProcessDependencies(_ thisTaskTemplateParameterFormItem: TaskTemplateParameterFormItem) {
        debugPrint("ProcessDependencies: " + thisTaskTemplateParameterFormItem.TemplateParameter.RowId)

        for currentTaskTemplateParameterFormItem in thisTaskTemplateParameterFormItem.Dependencies {
            if (currentTaskTemplateParameterFormItem.TemplateParameter.PredecessorTrueValue == thisTaskTemplateParameterFormItem.SelectedItem)
                &&
                (
                    !(
                        (currentTaskTemplateParameterFormItem.TemplateParameter.ParameterName == "TemperatureHot" && HotType == "None") || (currentTaskTemplateParameterFormItem.TemplateParameter.ParameterName == "TemperatureCold" && ColdType == "None")
                    )
                )
            {
                currentTaskTemplateParameterFormItem.Enabled = true
                EnableControl(currentTaskTemplateParameterFormItem.TemplateParameter.RowId, enabled: true)
                currentTaskTemplateParameterFormItem.SelectedItem = nil
                SetParameterValue(currentTaskTemplateParameterFormItem.TemplateParameter.RowId, value: nil)
            } else {
                currentTaskTemplateParameterFormItem.Enabled = false
                EnableControl(currentTaskTemplateParameterFormItem.TemplateParameter.RowId, enabled: false)
                currentTaskTemplateParameterFormItem.SelectedItem = NotApplicable
                SetParameterValue(currentTaskTemplateParameterFormItem.TemplateParameter.RowId, value: NotApplicable)
            }

            // Handle the dependencies dependents
            ProcessDependencies(currentTaskTemplateParameterFormItem)
        }
    }

    @IBAction func AnswerPopupChanged(_ sender: KFPopupSelector) {
        if let thisTaskTemplateParameterId: String = sender.restorationIdentifier {
            debugPrint("AnswerPopupChanged: " + thisTaskTemplateParameterId)

            if let thisTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[thisTaskTemplateParameterId]
            {
                // record the selected value
                if thisTaskTemplateParameterFormItem.SelectedItem != sender.selectedValue {
                    thisTaskTemplateParameterFormItem.SelectedItem = sender.selectedValue

                    ProcessDependencies(thisTaskTemplateParameterFormItem)
                }
            }
        }
    }

    // MARK: - segue handling

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        
        case "SearchSegue":
            Session.GettingAlternateAssetCode = true
            
        case "TemperatureProfileSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellTemperature = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellTemperature
                Session.CurrentProfileControl = cell.Answer
            } else {
                Session.CurrentProfileControl = sender as? UITextField
            }

            let temperatureProfileViewController = segue.destination as! TemperatureProfileViewController
            temperatureProfileViewController.hot = (Session.CurrentProfileControl!.tag == TemperatureProfileCellHot)
            Session.GettingProfile = true

        case "ScanUniversalSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellScanUniversal = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellScanUniversal
                Session.CurrentScanUniversalControl = cell.Answer
                Session.CurrentScanUniversalCell = cell
            } else {
                Session.CurrentScanUniversalControl = sender as? UITextField
            }

            Session.GettingScanUniversal = true

        case "DataMatrixSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellDataMatrix = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellDataMatrix
                Session.CurrentDataMatrixControl = cell.Answer
                Session.CurrentDataMatrixCell = cell
            } else {
                Session.CurrentDataMatrixControl = sender as? UITextField
            }

            Session.GettingDataMatrix = true
        
        case "ScanCodeSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellScanCode = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellScanCode
                Session.CurrentScanCodeControl = cell.Answer
            } else {
                Session.CurrentScanCodeControl = sender as? UITextField
            }

            Session.GettingScanCode = true

        default:

            // no action
            print("default action???")
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if Session.TimerRunning {
            return false
        }

        switch identifier {
        case "SearchSegue":
            if sender is UIButton {
                if AlternateAssetCode.text != String() {
                    let userPrompt: UIAlertController = UIAlertController(title: "Overwrite ScanCode?", message: "Are you sure you want to overwrite the current scancode?", preferredStyle: UIAlertController.Style.alert)

                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        _ in
                        // do nothing
                    }

                    let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive) {
                        _ in
                        self.performSegue(withIdentifier: "SearchSegue", sender: sender)
                    }

                    userPrompt.addAction(cancelAction)
                    userPrompt.addAction(OKAction)

                    present(userPrompt, animated: true, completion: nil)
                }
            }
            
        case "TemperatureProfileSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellTemperature = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellTemperature
                if cell.Answer.text != String() {
                    let userPrompt: UIAlertController = UIAlertController(title: "Overwrite Profile?", message: "Are you sure you want to overwrite the current profile?", preferredStyle: UIAlertController.Style.alert)

                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        _ in
                        // do nothing
                    }

                    let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive) {
                        _ in
                        self.performSegue(withIdentifier: "TemperatureProfileSegue", sender: sender)
                    }

                    userPrompt.addAction(cancelAction)
                    userPrompt.addAction(OKAction)

                    present(userPrompt, animated: true, completion: nil)
                }
            }

        case "ScanUniversalSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellScanUniversal = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellScanUniversal
                if cell.Answer.text != String() {
                    let userPrompt: UIAlertController = UIAlertController(title: "Overwrite Scan?", message: "Are you sure you want to overwrite the current scan?", preferredStyle: UIAlertController.Style.alert)

                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        _ in
                        // do nothing
                    }

                    let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive) {
                        _ in
                        self.performSegue(withIdentifier: "ScanUniversalSegue", sender: sender)
                    }

                    userPrompt.addAction(cancelAction)
                    userPrompt.addAction(OKAction)

                    present(userPrompt, animated: true, completion: nil)
                }
            }

        case "DataMatrixSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellDataMatrix = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellDataMatrix
                if cell.Answer.text != String() {
                    let userPrompt: UIAlertController = UIAlertController(title: "Overwrite Data Matrix?", message: "Are you sure you want to overwrite the current data matrix?", preferredStyle: UIAlertController.Style.alert)

                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        _ in
                        // do nothing
                    }

                    let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive) {
                        _ in
                        self.performSegue(withIdentifier: "DataMatrixSegue", sender: sender)
                    }

                    userPrompt.addAction(cancelAction)
                    userPrompt.addAction(OKAction)

                    present(userPrompt, animated: true, completion: nil)
                }
            }

        case "ScanCodeSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellScanCode = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellScanCode
                if cell.Answer.text != String() {
                    let userPrompt: UIAlertController = UIAlertController(title: "Overwrite ScanCode?", message: "Are you sure you want to overwrite the current scancode?", preferredStyle: UIAlertController.Style.alert)

                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        _ in
                        // do nothing
                    }

                    let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive) {
                        _ in
                        self.performSegue(withIdentifier: "ScanCodeSegue", sender: sender)
                    }

                    userPrompt.addAction(cancelAction)
                    userPrompt.addAction(OKAction)

                    present(userPrompt, animated: true, completion: nil)
                }
            }

        default:
            print("Default segue!!!")
        }
        return true
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if Session.TimerRunning {
            return false
        }
       
        if textField.tag >= TemperatureProfileCellHot && Session.UseTemperatureProfile {
            if textField.text != String() {
                let userPrompt: UIAlertController = UIAlertController(title: "Overwrite Profile?", message: "Are you sure you want to overwrite the current profile?", preferredStyle: UIAlertController.Style.alert)

                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                    _ in
                    // do nothing
                }

                let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive) {
                    _ in
                    self.performSegue(withIdentifier: "TemperatureProfileSegue", sender: textField)
                }

                userPrompt.addAction(cancelAction)
                userPrompt.addAction(OKAction)

                present(userPrompt, animated: true, completion: nil)
            } else {
                performSegue(withIdentifier: "TemperatureProfileSegue", sender: textField)
            }
            return false
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag >= TemperatureCell && Session.ThermaQBluetoothProbeConnected {
            if !Session.TimerRunning {
                Session.ReadingDevice = 1
                Session.CurrentTemperatureControl = textField
                Session.CurrentTemperatureControl!.isEnabled = false
                Session.CurrentTemperatureControl!.backgroundColor = UIColor.green
                Session.TimerRunning = true
            }
            addDoneButtonOnKeyboard(textField)
            activeField = textField
        } else {
            if textField.tag >= TemperatureCell && Session.BluetoothProbeConnected {
                if !EAController.shared().selectedAccessory.isAwaitingUI {
                    if !Session.TimerRunning {
                        Session.CurrentTemperatureControl = textField
                        Session.CurrentTemperatureControl!.isEnabled = false
                        Session.CurrentTemperatureControl!.backgroundColor = UIColor.green
                        startProbeTimer(0.25)
                    }
                }
            }
            addDoneButtonOnKeyboard(textField)
            activeField = textField
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == ScanUniversalCell {
            textField.isHidden = true
            let cell: TaskTemplateParameterCellScanUniversal = textField.superview!.superview as! TaskTemplateParameterCellScanUniversal
            cell.updateFromAnswer()
        }
        
        if textField.tag >= TemperatureCell && Session.BluetoothProbeConnected || textField.tag >= TemperatureCell && Session.ThermaQBluetoothProbeConnected
        {
            stopProbeTimer()
            Session.CurrentTemperatureControl!.isEnabled = true
            Session.CurrentTemperatureControl!.backgroundColor = UIColor.white
        }

        if textField.restorationIdentifier != nil {
            if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[textField.restorationIdentifier!]
            {
                currentTaskTemplateParameterFormItem.SelectedItem = textField.text
            }
        }
        activeField = nil
        textField.resignFirstResponder()
    }

    // MARK: UITextViewDelegate

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if Session.TimerRunning {
            return false
        }
        addDoneButtonOnKeyboard(textView)
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.restorationIdentifier != nil {
            if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[textView.restorationIdentifier!]
            {
                currentTaskTemplateParameterFormItem.SelectedItem = textView.text
            }
        }
        textView.resignFirstResponder()
    }

    @IBOutlet var BluetoothButton: UIBarButtonItem!

    // MARK: Actions

    @IBAction func CancelPressed(_ sender: UIBarButtonItem) {
        if Session.TimerRunning {
            let userPrompt: UIAlertController = UIAlertController(title: "Probe Active", message: "You have an active connection to the probe.  Please close the connection before proceeding", preferredStyle: UIAlertController.Style.alert)

            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.cancel,
                handler: nil))

            present(userPrompt, animated: true, completion: nil)
        } else {
            let userPrompt: UIAlertController = UIAlertController(title: "Leave task?", message: "Are you sure you want to leave this task?  Any unsaved data will be lost.", preferredStyle: UIAlertController.Style.alert)

            // the cancel action
            userPrompt.addAction(UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))

            // the destructive option
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.destructive,
                handler: LeaveTask))

            present(userPrompt, animated: true, completion: nil)
        }
    }

    func LeaveTask(_ actionTarget: UIAlertAction) {
        if Session.BluetoothProbeConnected {
            Session.CodeScanned = nil
            Session.DataMatrix = nil
            Session.ScanUniversal = nil
            Session.TaskId = nil
            EAController.shared().callBack = nil
            _ = navigationController?.popViewController(animated: true)
        } else {
            Session.CodeScanned = nil
            Session.DataMatrix = nil
            Session.ScanUniversal = nil
            Session.TaskId = nil
            _ = navigationController?.popViewController(animated: true)
        }
    }

    //MARK: Validation
    func Validate() -> Bool {
        var valid: Bool = true

        for (_, taskTemplateParameterFormItem) in taskTemplateParameterFormItems {
            let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItem.TemplateParameter
            if !((taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "None")
                || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "None")
                || (taskTemplateParameter.ParameterName == "RemoveAsset")
                || (taskTemplateParameter.ParameterName == "AlternateAssetCode")
                || (taskTemplateParameter.ParameterName.hasPrefix("Add") && taskTemplateParameter.ParameterName.hasSuffix("Notes")))
            {
                var value: String? = GetParameterValue(taskTemplateParameter.RowId)
                if value == nil && taskTemperatureProfiles.keys.contains(taskTemplateParameter.RowId)
                {
                    value = taskTemperatureProfiles[taskTemplateParameter.RowId]!.ToString()
                }
		//TBD: check collect parameter
                if value == nil || value == String() || value == PleaseSelect { 
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)

                    taskTemplateParameterFormItem.ControlBackgroundColor = UIColor.red
                    SetCellBackgroundColour(taskTemplateParameter.RowId, colour: UIColor.red)

                    valid = false
                } else {
                    taskTemplateParameterFormItem.LabelColour = UIColor.white
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.white)

                    taskTemplateParameterFormItem.ControlBackgroundColor = UIColor.white
                    SetCellBackgroundColour(taskTemplateParameter.RowId, colour: UIColor.white)
                }
            }
        }

        if Session.UseTaskTiming {
            let value: String? = TaskTime.text
            if value == nil || value == String() {
                TaskTimeLabel.textColor = UIColor.red
                valid = false
            } else {
                TaskTimeLabel.textColor = UIColor.white
            }

            let value2: String? = TravelTime.text
            if value2 == nil || value2 == String() {
                TravelTimeLabel.textColor = UIColor.red
                valid = false
            } else {
                TravelTimeLabel.textColor = UIColor.white
            }
        }

        return valid
    }

    //MARK: Parameter Value
    func GetParameterValue(_ taskTemplateParameterId: String) -> String? {
        return taskTemplateParameterFormItems[taskTemplateParameterId]?.SelectedItem
    }

    func SetParameterValue(_ taskTemplateParameterId: String, value: String?) {
        debugPrint("SetParameterValue: " + taskTemplateParameterId + " = " + (value != nil ? value! : "nil"))

        for tableCell in tableView.visibleCells {
            if tableCell.restorationIdentifier == taskTemplateParameterId {
                let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItems[taskTemplateParameterId]!.TemplateParameter

                switch taskTemplateParameter.ParameterType {
                case "Scan Universal":
                    let cell: TaskTemplateParameterCellScanUniversal = tableCell as! TaskTemplateParameterCellScanUniversal
                    cell.Answer.text = value
                    return

                case "GS1 Data Matrix":
                    let cell: TaskTemplateParameterCellDataMatrix = tableCell as! TaskTemplateParameterCellDataMatrix
                    cell.Answer.text = value
                    return

                case "Scan Code":
                    let cell: TaskTemplateParameterCellScanCode = tableCell as! TaskTemplateParameterCellScanCode
                    cell.Answer.text = value
                    return
                    
                case "Freetext":
                    let cell: TaskTemplateParameterCellFreetext = tableCell as! TaskTemplateParameterCellFreetext
                    cell.Answer.text = value
                    return

                case "Number":
                    if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                    {
                        let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature
                        cell.Answer.text = value
                    } else {
                        let cell: TaskTemplateParameterCellNumber = tableCell as! TaskTemplateParameterCellNumber
                        cell.Answer.text = value
                    }
                    return

                case"Reference Data":

                    let cell: TaskTemplateParameterCellDropdown = tableCell as! TaskTemplateParameterCellDropdown
                    let options: [KFPopupSelector.Option] = cell.AnswerSelector.options
                    if value != nil {
                        for index in 0 ... options.count - 1 {
                            if String(describing: options[index]) == "text(\"" + value! + "\")" {
                                if cell.AnswerSelector.selectedIndex != index {
                                    cell.AnswerSelector.selectedIndex = index
                                }
                                return
                            }
                        }
                    } else {
                        cell.AnswerSelector.selectedIndex = 0
                    }

                    return

                default:
                    return
                }
            }
        }
    }

    //MARK: Control Mapping
    func EnableControl(_ taskTemplateParameterId: String, enabled: Bool) {
        for tableCell in tableView.visibleCells {
            if tableCell.restorationIdentifier == taskTemplateParameterId {
                let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItems[taskTemplateParameterId]!.TemplateParameter

                switch taskTemplateParameter.ParameterType {
                case "Scan Universal":
                    let cell: TaskTemplateParameterCellScanUniversal = tableCell as! TaskTemplateParameterCellScanUniversal
                    cell.Answer.isEnabled = true
                    cell.ScanUniversalButton.isHidden = false
                    cell.ScanUniversalButton.isEnabled = true
                    cell.ScanUniversalTextButton.isHidden = false
                    cell.ScanUniversalTextButton.isEnabled = true
                    return

                case "GS1 Data Matrix":
                    let cell: TaskTemplateParameterCellDataMatrix = tableCell as! TaskTemplateParameterCellDataMatrix
                    cell.Answer.isEnabled = true
                    cell.DataMatrixButton.isHidden = false
                    cell.DataMatrixButton.isEnabled = true
                    return

                case "Scan Code":
                    let cell: TaskTemplateParameterCellScanCode = tableCell as! TaskTemplateParameterCellScanCode
                    cell.Answer.isEnabled = true
                    cell.ScanCodeButton.isHidden = false
                    cell.ScanCodeButton.isEnabled = true
                    return
                    
                case "Freetext":
                    let cell: TaskTemplateParameterCellFreetext = tableCell as! TaskTemplateParameterCellFreetext
                    cell.Answer.isEnabled = enabled
                    return

                case "Number":
                    if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                    {
                        let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature

                        if
                            (taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "Hot")
                            || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "Cold")
                            || (taskTemplateParameter.ParameterName == "TemperatureFeedHot")
                            || (taskTemplateParameter.ParameterName == "TemperatureFeedCold")

                        {
                            cell.Answer.isEnabled = enabled && !Session.UseTemperatureProfile
                            cell.ProfileButton.isHidden = !Session.UseTemperatureProfile
                            cell.ProfileButton.isEnabled = enabled && Session.UseTemperatureProfile
                        } else {
                            cell.Answer.isEnabled = enabled
                            cell.ProfileButton.isHidden = true
                            cell.ProfileButton.isEnabled = false
                        }
                    } else {
                        let cell: TaskTemplateParameterCellNumber = tableCell as! TaskTemplateParameterCellNumber
                        cell.Answer.isEnabled = enabled
                    }
                    return

                case"Reference Data":
                    let cell: TaskTemplateParameterCellDropdown = tableCell as! TaskTemplateParameterCellDropdown
                    cell.AnswerSelector.isEnabled = enabled
                    return

                default:
                    return
                }
            }
        }
    }

    func SetCellLabelColour(_ taskTemplateParameterId: String, colour: UIColor) {
        for tableCell in tableView.visibleCells {
            if tableCell.restorationIdentifier == taskTemplateParameterId {
                let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItems[taskTemplateParameterId]!.TemplateParameter

                switch taskTemplateParameter.ParameterType {
                case "Scan Universal":
                    let cell: TaskTemplateParameterCellScanUniversal = tableCell as! TaskTemplateParameterCellScanUniversal
                    cell.Question.textColor = colour
                    return

                case "GS1 Data Matrix":
                    let cell: TaskTemplateParameterCellDataMatrix = tableCell as! TaskTemplateParameterCellDataMatrix
                    cell.Question.textColor = colour
                    return

                case "Scan Code":
                    let cell: TaskTemplateParameterCellScanCode = tableCell as! TaskTemplateParameterCellScanCode
                    cell.Question.textColor = colour
                    return

                case "Freetext":
                    let cell: TaskTemplateParameterCellFreetext = tableCell as! TaskTemplateParameterCellFreetext
                    cell.Question.textColor = colour
                    return

                case "Number":
                    if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                    {
                        let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature
                        cell.Question.textColor = colour
                    } else {
                        let cell: TaskTemplateParameterCellNumber = tableCell as! TaskTemplateParameterCellNumber
                        cell.Question.textColor = colour
                    }
                    return

                case"Reference Data":
                    let cell: TaskTemplateParameterCellDropdown = tableCell as! TaskTemplateParameterCellDropdown
                    cell.Question.textColor = colour
                    return

                default:
                    return
                }
            }
        }
    }

    func SetCellBackgroundColour(_ taskTemplateParameterId: String, colour: UIColor) {
        for tableCell in tableView.visibleCells {
            if tableCell.restorationIdentifier == taskTemplateParameterId {
                let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItems[taskTemplateParameterId]!.TemplateParameter

                switch taskTemplateParameter.ParameterType {
                case "Scan Universal":
                    let cell: TaskTemplateParameterCellScanUniversal = tableCell as! TaskTemplateParameterCellScanUniversal
                    cell.Answer.backgroundColor = colour
                    return

                case "GS1 Data Matrix":
                    let cell: TaskTemplateParameterCellDataMatrix = tableCell as! TaskTemplateParameterCellDataMatrix
                    cell.Answer.backgroundColor = colour
                    return

                case "Scan Code":
                    let cell: TaskTemplateParameterCellScanCode = tableCell as! TaskTemplateParameterCellScanCode
                    cell.Answer.backgroundColor = colour
                    return

                case "Freetext":
                    let cell: TaskTemplateParameterCellFreetext = tableCell as! TaskTemplateParameterCellFreetext
                    cell.Answer.backgroundColor = colour
                    return

                case "Number":
                    if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                    {
                        let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature
                        cell.Answer.backgroundColor = colour
                    } else {
                        let cell: TaskTemplateParameterCellNumber = tableCell as! TaskTemplateParameterCellNumber
                        cell.Answer.backgroundColor = colour
                    }
                    return

                case"Reference Data":
                    let cell: TaskTemplateParameterCellDropdown = tableCell as! TaskTemplateParameterCellDropdown
                    cell.AnswerSelector.backgroundColor = colour
                    return

                default:
                    return
                }
            }
        }
    }

    @IBAction func DonePressed(_ sender: UIBarButtonItem) {
        if Session.TimerRunning {
            let userPrompt: UIAlertController = UIAlertController(title: "Probe Active", message: "You have an active connection to the probe.  Please close the connection before proceeding", preferredStyle: UIAlertController.Style.alert)

            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.cancel,
                handler: nil))

            present(userPrompt, animated: true, completion: nil)
        } else {
            // do all the validation
            if !Validate() {
                let userPrompt: UIAlertController = UIAlertController(title: "Incomplete task!", message: "Please complete the fields highlighted with red.", preferredStyle: UIAlertController.Style.alert)

                // the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.default,
                    handler: nil))

                present(userPrompt, animated: true, completion: nil)

                return
            }

            let now = Date()
            var accessbile: Bool = true

            // add the removea asset and alternate asset code parameters
            var currentTaskParameter: TaskParameter = TaskParameter()
            currentTaskParameter.RowId = UUID().uuidString
            currentTaskParameter.CreatedBy = Session.OperativeId!
            currentTaskParameter.CreatedOn = now
            currentTaskParameter.TaskId = Session.TaskId!
            currentTaskParameter.TaskTemplateParameterId = removeAssetParameter.RowId
            currentTaskParameter.ParameterName = removeAssetParameter.ParameterName
            currentTaskParameter.ParameterType = removeAssetParameter.ParameterType
            currentTaskParameter.ParameterDisplay = removeAssetParameter.ParameterDisplay
            currentTaskParameter.Collect = removeAssetParameter.Collect
            currentTaskParameter.ParameterValue = (RemoveAsset.isOn ? "true" : "false")
            _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)

            currentTaskParameter = TaskParameter()
            currentTaskParameter.RowId = UUID().uuidString
            currentTaskParameter.CreatedBy = Session.OperativeId!
            currentTaskParameter.CreatedOn = now
            currentTaskParameter.TaskId = Session.TaskId!
            currentTaskParameter.TaskTemplateParameterId = alternateAssetCodeParameter.RowId
            currentTaskParameter.ParameterName = alternateAssetCodeParameter.ParameterName
            currentTaskParameter.ParameterType = alternateAssetCodeParameter.ParameterType
            currentTaskParameter.ParameterDisplay = alternateAssetCodeParameter.ParameterDisplay
            currentTaskParameter.Collect = alternateAssetCodeParameter.Collect
            currentTaskParameter.ParameterValue = AlternateAssetCode.text!
            _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)

            // commit the values
            for taskTemplateParameter in formTaskTemplateParameters {
                currentTaskParameter = TaskParameter()
                currentTaskParameter.RowId = UUID().uuidString
                currentTaskParameter.CreatedBy = Session.OperativeId!
                currentTaskParameter.CreatedOn = now
                currentTaskParameter.TaskId = Session.TaskId!
                currentTaskParameter.TaskTemplateParameterId = taskTemplateParameter.RowId
                currentTaskParameter.ParameterName = taskTemplateParameter.ParameterName
                currentTaskParameter.ParameterType = taskTemplateParameter.ParameterType
                currentTaskParameter.ParameterDisplay = taskTemplateParameter.ParameterDisplay
                currentTaskParameter.Collect = taskTemplateParameter.Collect
                if taskTemperatureProfiles.keys.contains(taskTemplateParameter.RowId) {
                    currentTaskParameter.ParameterValue = taskTemperatureProfiles[taskTemplateParameter.RowId]!.ToString()
                } else {
                    currentTaskParameter.ParameterValue = GetParameterValue(currentTaskParameter.TaskTemplateParameterId!)!
                }
                _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                if currentTaskParameter.ParameterName == "Accessible" && currentTaskParameter.ParameterValue == "No"
                {
                    accessbile = false
                }
            }

            // add the additional notes parameter
            currentTaskParameter = TaskParameter()
            currentTaskParameter.RowId = UUID().uuidString
            currentTaskParameter.CreatedBy = Session.OperativeId!
            currentTaskParameter.CreatedOn = now
            currentTaskParameter.TaskId = Session.TaskId!
            currentTaskParameter.TaskTemplateParameterId = additionalNotesParameter.RowId
            currentTaskParameter.ParameterName = additionalNotesParameter.ParameterName
            currentTaskParameter.ParameterType = additionalNotesParameter.ParameterType
            currentTaskParameter.ParameterDisplay = additionalNotesParameter.ParameterDisplay
            currentTaskParameter.Collect = additionalNotesParameter.Collect
            currentTaskParameter.ParameterValue = AdditionalNotes.text
            _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)

            // update the task
            task.LastUpdatedBy = Session.OperativeId!
            task.LastUpdatedOn = now
            task.CompletedDate = now
            task.OperativeId = Session.OperativeId!
            if Session.UseTaskTiming {
                task.ActualDuration = Int(TaskTime.text!)
                task.TravelDuration = Int(TravelTime.text!)
            }
            if accessbile {
                task.Status = "Dockable"
            } else {
                task.Status = "Outstanding"
            }

            _ = ModelManager.getInstance().updateTask(task)

            Utility.SendTasks(navigationController!, HUD: nil)
            if Session.BluetoothProbeConnected {
                Session.CodeScanned = nil
                Session.DataMatrix = nil
                Session.ScanUniversal = nil
                Session.ScanCode = nil
                Session.TaskId = nil
                Session.FilterAssetNumber = nil
                EAController.shared().callBack = nil
                _ = navigationController?.popViewController(animated: true)
            } else {
                Session.CodeScanned = nil
                Session.DataMatrix = nil
                Session.ScanUniversal = nil
                Session.ScanCode = nil
                Session.TaskId = nil
                Session.FilterAssetNumber = nil
                _ = navigationController?.popViewController(animated: true)
            }

            // close the view
            Session.TaskId = nil
            _ = navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Probe

    func readingAndDisplaying() {
        if ProbeProperties.isBlueThermConnected() {
            Session.CurrentReading = ProbeProperties.sensor1Reading()
        } else {
            Session.CurrentReading = nil
        }

        // set the value on the control with focus
        Session.CurrentTemperatureControl?.text = Session.CurrentReading
    }

    func startProbeTimer(_ interval: Double) {
        let timerInterval: TimeInterval = TimeInterval(interval)
        probeTimer.invalidate()
        probeTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(TaskViewController.doSend), userInfo: nil, repeats: true)
        Session.TimerRunning = true
    }

    func stopProbeTimer() {
        probeTimer.invalidate()
        Session.TimerRunning = false
    }

    @objc func doSend() {
        EAController.doSend()
    }

    // MARK: Probe functions

    func settingTheProbe() {
        print("Set reply")
    }

    func probeButtonHasBeenPressed() {
        print("BlueTherm button has been pressed")
        stopProbeTimer()
        if Session.CurrentTemperatureControl != nil {
            Session.CurrentTemperatureControl!.backgroundColor = UIColor.white
            Session.CurrentTemperatureControl!.isEnabled = true
            if Session.CurrentTemperatureControl!.restorationIdentifier != nil {
                if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[Session.CurrentTemperatureControl!.restorationIdentifier!]
                {
                    currentTaskTemplateParameterFormItem.SelectedItem = Session.CurrentTemperatureControl!.text
                }
            }
            Session.CurrentTemperatureControl!.resignFirstResponder()
        }
    }

    func soundtheAlarmInBackground() {
        // displayAlarm
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

        print("Emissivity value: %@", emissivity)
    }

    // MARK: Alert Messages Delegate

    func alertMessagesCreateAlertViewNoConnectionFoundSHOW() {
        Session.BluetoothProbeConnected = false
    }

    func alertMessagesCreateAlertViewNoConnectionFoundDISMISS() {
        Session.BluetoothProbeConnected = false
    }

    func alertViewConnectionHasBeenLostSHOW() {
        Session.BluetoothProbeConnected = false
    }

    func alertViewConnectionHasBeenLostDISMISS() {
        Session.BluetoothProbeConnected = false
    }

    // MARK: Keyboard Handling
    func addDoneButtonOnKeyboard(_ view: UIView?) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: view, action: #selector(UIResponder.resignFirstResponder))
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
