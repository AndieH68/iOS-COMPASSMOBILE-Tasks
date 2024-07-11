//
//
//  Created by Andrew Harper on 09/11/2021.
//  Copyright © 2021 HYDOP E.C.S. All rights reserved.
//

import BRYXBanner
import Foundation
import MBProgressHUD
import UIKit
import CoreMedia

class BiologicalMonitoringViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate, ETIPassingData, AlertMessageDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CheckBoxDelegate {
    
    var instanceOfCustomObject: ThermaLib = ThermaLib()
    
    var task: Task = Task()
    var asset: Asset = Asset()
    var taskInstruction: TaskInstruction = TaskInstruction()
    var testSuite: TestSuite = TestSuite()
    var testSuiteItems: [TestSuiteItem] = [TestSuiteItem]()
    
    var taskTemplateParameterFormItems: Dictionary<String, TaskTemplateParameterFormItem> = Dictionary<String, TaskTemplateParameterFormItem>()
    var formTaskTemplateParameters: [TaskTemplateParameter] = [TaskTemplateParameter]()
    
    var removeAssetParameter: TaskTemplateParameter = TaskTemplateParameter()
    var alternateAssetCodeParameter: TaskTemplateParameter = TaskTemplateParameter()
    var additionalNotesParameter: TaskTemplateParameter = TaskTemplateParameter()
    
    var assetOutlets: Dictionary<String,String> = Dictionary<String,String>()
    var flushTypes: Dictionary<String,String> = Dictionary<String,String>()
    
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
    
    @IBOutlet var AddSample: UIButton!
    
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
            let AssetTypeValue: String? = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!, parentType: "PPMAssetGroup", parentValue:task.PPMGroup!)
            if (AssetTypeValue != "")
            {
                AssetType.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!) + " - " + ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!, parentType: "PPMAssetGroup", parentValue:task.PPMGroup!)
            }
            else
            {
                AssetType.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!) + " - " + ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!, parentType: "PPMAssetGroup", parentValue: "DistributionServices")
            }
        } else {
            AssetType.text = task.AssetType ?? "Missing Asset Type"
        }
        
        TaskName.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup)
        
        Location.text = task.LocationName
        if let assetNumber: String = task.AssetNumber { AssetNumber.text = assetNumber } else { AssetNumber.text = "no asset" }
        TaskReference.text = task.TaskRef
        
        // get the the parameters for the table
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
        
        //is there a task instruction
        var taskInstructionCriteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        taskInstructionCriteria["TaskId"] = task.RowId as AnyObject?
        let taskInstructions: [TaskInstruction] = ModelManager.getInstance().findTaskInstructionList(taskInstructionCriteria)
        if(taskInstructions.count >= 1)
        {
            taskInstruction = taskInstructions[0]
            
            testSuite = ModelManager.getInstance().getTestSuite(taskInstruction.EntityId)!
            
            if(!testSuite.RowId.isEmpty)
            {
                TaskName.text! += " - " + testSuite.Name
                var testSuiteItemCriteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                testSuiteItemCriteria["TestSuiteId"] = testSuite.RowId as AnyObject?
                testSuiteItems = ModelManager.getInstance().findTestSuiteItemList(testSuiteItemCriteria)
                
                //add a sample
                let sampleTaskTemplateParameter = TaskTemplateParameter()
                //let taskTemplateParameterFormItem = TaskTemplateParameterFormItem(sampleTaskTemplateParameter)
                
                Session.LastUniqueReference = Utility.GenerateUniqueReference(last: Session.LastUniqueReference)
                
                sampleTaskTemplateParameter.RowId = UUID().uuidString
                sampleTaskTemplateParameter.ParameterName = Session.LastUniqueReference
                sampleTaskTemplateParameter.ParameterType = "SampleWithMultipleTests"
                sampleTaskTemplateParameter.ParameterDisplay = "Multiple Tests"
                sampleTaskTemplateParameter.Collect = true
                sampleTaskTemplateParameter.ReferenceDataType = nil
                sampleTaskTemplateParameter.ReferenceDataExtendedType = nil
                sampleTaskTemplateParameter.Ordinal = self.formTaskTemplateParameters.count + 2
                sampleTaskTemplateParameter.Predecessor = nil
                sampleTaskTemplateParameter.PredecessorTrueValue = nil
                
                self.formTaskTemplateParameters.append(sampleTaskTemplateParameter)
                
                self.taskTemplateParameterFormItems[sampleTaskTemplateParameter.RowId] = TaskTemplateParameterFormItemSampleWithMultipleTests(taskTemplateParameter: sampleTaskTemplateParameter)
                
                //populate with the data
                let taskTemplateParameterFormItemSampleWithMultipleTests: TaskTemplateParameterFormItemSampleWithMultipleTests = self.taskTemplateParameterFormItems[sampleTaskTemplateParameter.RowId] as! TaskTemplateParameterFormItemSampleWithMultipleTests
                
                taskTemplateParameterFormItemSampleWithMultipleTests.OutletType = taskInstruction.OutletId
                taskTemplateParameterFormItemSampleWithMultipleTests.SampleType = taskInstruction.FlushType
                taskTemplateParameterFormItemSampleWithMultipleTests.NumberOfBottles = "1"
                
                for currentTestSuiteItem: TestSuiteItem in testSuiteItems {
                    switch (currentTestSuiteItem.BacteriumType) {
                        
                    case "Legionella (cfu/l)":
                        break
                        
                    case "TVC (cfu/ml)", "TVC (cfu/ml) @ 22°C", "TVC (cfu/ml) @ 37°C", "TVC (cfu/ml) @ 37°C / 24 hrs", "TVC (cfu/ml) @ 37°C / 48 hrs":
                        taskTemplateParameterFormItemSampleWithMultipleTests.TVC = true
                        break
                        
                    case "E. Coli (cfu/100ml)":
                        taskTemplateParameterFormItemSampleWithMultipleTests.EColi = true
                        break
                        
                    case "Coliforms (cfu/100ml)":
                        taskTemplateParameterFormItemSampleWithMultipleTests.Coliforms = true
                        break
                        
                    case "Pseudomonas spp. (cfu/100ml)":
                        taskTemplateParameterFormItemSampleWithMultipleTests.PseudomonasSpp = true
                        break
                        
                    case "Pseudomonas aeruginosa (cfu/100ml)":
                        taskTemplateParameterFormItemSampleWithMultipleTests.PseudomonasAeruginosa = true
                        break
                        
                    case "Cryptosporidium":
                        taskTemplateParameterFormItemSampleWithMultipleTests.Cryptosporidium = true
                        break
                        
                    default:
                        break
                        
                    }
                }
                self.AddSample.isHidden = true
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
        
        if Session.GettingScanUniversal {
            if Session.CurrentScanUniversalControl != nil && !Session.CancelFromScan {
                if Session.CurrentScanUniversalControl!.restorationIdentifier != nil {
                    if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[Session.CurrentScanUniversalControl!.restorationIdentifier!]
                    {
                        if Session.CodeScanned != nil
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
        
        if Session.GettingSampleScancode{
            if Session.CurrentSampleRestorationIdentifier != nil && Session.CodeScanned != nil{
                if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[Session.CurrentSampleRestorationIdentifier!]
                {
                    currentTaskTemplateParameterFormItem.TemplateParameter.ParameterName = Session.CodeScanned!
                    
                    switch (currentTaskTemplateParameterFormItem.TemplateParameter.ParameterType){
                    case "Sample":
                        let sample: TaskTemplateParameterFormItemSample = currentTaskTemplateParameterFormItem as! TaskTemplateParameterFormItemSample
                        let cell = sample.cell as! TaskTemplateParameterCellSample
                        cell.SampleReference.text = Session.CodeScanned!
                    case "SampleWithBiocide":
                        let sampleWithBiocide: TaskTemplateParameterFormItemSampleWithBiocide = currentTaskTemplateParameterFormItem as! TaskTemplateParameterFormItemSampleWithBiocide
                        let cell = sampleWithBiocide.cell as! TaskTemplateParameterCellSampleWithBiocide
                        cell.SampleReference.text = Session.CodeScanned!
                    case "SampleWithMultipleTests":
                        let sampleWithMultipleTests: TaskTemplateParameterFormItemSampleWithMultipleTests = currentTaskTemplateParameterFormItem as! TaskTemplateParameterFormItemSampleWithMultipleTests
                        let cell = sampleWithMultipleTests.cell as! TaskTemplateParameterCellSampleWithMultipleTests
                        cell.SampleReference.text = Session.CodeScanned!
                    default:
                        break
                    }
                }
                Session.CurrentSampleRestorationIdentifier = nil
                Session.CodeScanned = nil
                Session.GettingSampleScancode = false
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
    
    // MARK: Add Sample Picker View
    let pickerwidth = UIScreen.main.bounds.width - 10
    let pickerheight = UIScreen.main.bounds.height / 4
    var selectedBacteriumType = 0
    
    var BacteriumTypes : KeyValuePairs =
    [
        "Multiple Tests" : "SampleWithMultipleTests",
        "Legionellae (cfu/l)" : "SampleWithBiocide",
        "TVC (cfu/ml)" : "Sample",
        "E. Coli (cfu/100ml)" : "Sample",
        "Coliforms (cfu/100ml)" : "Sample",
        "Pseudomonas spp. (cfu/100ml)" : "Sample",
        "Pseudomonas Aeruginosa (cfu/100ml)" : "Sample",
        "TVC (cfu/ml) @ 22°C" : "Sample",
        "TVC (cfu/ml) @ 37°C" : "Sample",
        "TVC (cfu/ml) @ 37°C / 24 hrs" : "Sample",
        "TVC (cfu/ml) @ 22°C / 48 hrs" : "Sample"
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BacteriumTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerwidth, height: 30))
        label.text = Array(BacteriumTypes)[row].key
        label.sizeToFit()
        return label
    }
    
    @IBAction func AddSamplePicker(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: pickerwidth, height: pickerheight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: pickerwidth, height: pickerheight))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedBacteriumType, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select Sample Bacterium type", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = AddSample
        alert.popoverPresentationController?.sourceRect = AddSample.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in }))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
            self.selectedBacteriumType = pickerView.selectedRow(inComponent: 0)
            let selected = Array(self.BacteriumTypes)[self.selectedBacteriumType]
            
            //this is where we add the sample control to the parameters
            let key = selected.key
            let type = selected.value
            let sampleTaskTemplateParameter = TaskTemplateParameter()
            //let taskTemplateParameterFormItem = TaskTemplateParameterFormItem(sampleTaskTemplateParameter)
            
            Session.LastUniqueReference = Utility.GenerateUniqueReference(last: Session.LastUniqueReference)
            
            sampleTaskTemplateParameter.RowId = UUID().uuidString
            sampleTaskTemplateParameter.ParameterName = Session.LastUniqueReference
            sampleTaskTemplateParameter.ParameterType = type
            sampleTaskTemplateParameter.ParameterDisplay = key
            sampleTaskTemplateParameter.Collect = true
            sampleTaskTemplateParameter.ReferenceDataType = nil
            sampleTaskTemplateParameter.ReferenceDataExtendedType = nil
            sampleTaskTemplateParameter.Ordinal = self.formTaskTemplateParameters.count + 2
            sampleTaskTemplateParameter.Predecessor = nil
            sampleTaskTemplateParameter.PredecessorTrueValue = nil
            
            self.formTaskTemplateParameters.append(sampleTaskTemplateParameter)
            switch type
            {
            case "SampleWithMultipleTests":
                self.taskTemplateParameterFormItems[sampleTaskTemplateParameter.RowId] = TaskTemplateParameterFormItemSampleWithMultipleTests(taskTemplateParameter: sampleTaskTemplateParameter)
                break
            case "SampleWithBiocide":
                self.taskTemplateParameterFormItems[sampleTaskTemplateParameter.RowId] = TaskTemplateParameterFormItemSampleWithBiocide(taskTemplateParameter: sampleTaskTemplateParameter)
                break
            default:
                self.taskTemplateParameterFormItems[sampleTaskTemplateParameter.RowId] = TaskTemplateParameterFormItemSample(taskTemplateParameter: sampleTaskTemplateParameter)
                break
            }
            
            // reload the table
            self.taskParameterTable.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func DeleteSample(_ sender: UIButton) {
        if let thisTaskTemplateParameterId: String = sender.restorationIdentifier {
            self.taskTemplateParameterFormItems.removeValue(forKey: thisTaskTemplateParameterId)

            var index: Int = 0;
            for formTaskTemplateParameter in formTaskTemplateParameters {
                if(formTaskTemplateParameter.RowId == thisTaskTemplateParameterId)
                {
                    break;
                }
                index+=1;
            }
            formTaskTemplateParameters.remove(at: index)
            self.taskParameterTable.reloadData()
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
                dropdownData.append(contentsOf: ModelUtility.getInstance().GetLookupList(taskTemplateParameter.ReferenceDataType!, extendedReferenceDataType: taskTemplateParameter.ReferenceDataExtendedType))
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

            case "Sample":
                let cell = tableView.dequeueReusableCell(withIdentifier: "Sample", for: indexPath) as! TaskTemplateParameterCellSample
                let taskTemplateParameterFormItemSample: TaskTemplateParameterFormItemSample = taskTemplateParameterFormItem as! TaskTemplateParameterFormItemSample
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.SampleReference.text = taskTemplateParameter.ParameterName
                cell.BacteriumType.text = taskTemplateParameter.ParameterDisplay
                cell.Delete.restorationIdentifier = taskTemplateParameter.RowId
                
                //Outlet Type
                if(assetOutlets.count == 0) {
                    assetOutlets = ModelUtility.getInstance().GetOutletsForAsset(task.AssetId!)
                }
                var OutletTypeDropdownData: [String] = []
                OutletTypeDropdownData.append(PleaseSelect)
                OutletTypeDropdownData.append(contentsOf: assetOutlets.keys)
                if OutletTypeDropdownData.count == 1 {
                    OutletTypeDropdownData[0] = "None"
                }
                
                cell.OutletType.restorationIdentifier = taskTemplateParameter.RowId
                cell.OutletType.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                cell.OutletType.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.OutletType.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.OutletType.options = OutletTypeDropdownData.map { KFPopupSelector.Option.text(text: $0) }

                var selectedOutletTypeItem: Int = 0
                if taskTemplateParameterFormItemSample.OutletType != nil {
                    var count: Int = 0
                    for value in assetOutlets {
                        if value.value == taskTemplateParameterFormItemSample.OutletType {
                            selectedOutletTypeItem = count + 1 //add 1 for "Please select" value
                            break
                        }
                        count += 1
                    }
                }
                debugPrint("Sample: selected " + (taskTemplateParameterFormItemSample.OutletType ?? "nil"))
                debugPrint("Sample: selected " + String(selectedOutletTypeItem))
                
                cell.OutletType.selectedIndex = selectedOutletTypeItem
                cell.OutletType.unselectedLabelText = PleaseSelect
                cell.OutletType.displaySelectedValueInLabel = true

                //Sample Type
                if(flushTypes.count == 0) {
                    flushTypes = ModelUtility.getInstance().GetFlushTypesForSample()
                }

                var SampleTypeTypeDropdownData: [String] = []
                SampleTypeTypeDropdownData.append(PleaseSelect)
                SampleTypeTypeDropdownData.append(contentsOf: ModelUtility.getInstance().GetLookupList("MonitoringFlushType", extendedReferenceDataType: "None"));
                
                cell.SampleType.restorationIdentifier = taskTemplateParameter.RowId
                cell.SampleType.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                cell.SampleType.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.SampleType.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.SampleType.options = SampleTypeTypeDropdownData.map { KFPopupSelector.Option.text(text: $0) }

                var selectedSampleTypeItem: Int = 0
                if taskTemplateParameterFormItemSample.SampleType != nil {
                    var count: Int = 0
                    for value in flushTypes {
                        if (value.value.caseInsensitiveCompare(taskTemplateParameterFormItemSample.SampleType!) == .orderedSame) {
                            selectedSampleTypeItem = count + 1 //add 1 for "Please select" value
                            break
                        }
                        count += 1
                    }
                }

                cell.SampleType.selectedIndex = selectedSampleTypeItem
                cell.SampleType.unselectedLabelText = PleaseSelect
                cell.SampleType.displaySelectedValueInLabel = true

                //Number Of Bottles
                cell.NumberOfBottles.restorationIdentifier = taskTemplateParameter.RowId
                cell.NumberOfBottles.delegate = self

                if taskTemplateParameterFormItemSample.NumberOfBottles != nil {
                    cell.NumberOfBottles.text = taskTemplateParameterFormItemSample.NumberOfBottles
                }
                
                taskTemplateParameterFormItemSample.cell = cell
                return cell
                
            case "SampleWithBiocide":
                let cell = tableView.dequeueReusableCell(withIdentifier: "SampleWithBiocide", for: indexPath) as! TaskTemplateParameterCellSampleWithBiocide
                let taskTemplateParameterFormItemSampleWithBiocide = taskTemplateParameterFormItem as! TaskTemplateParameterFormItemSampleWithBiocide
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.SampleReference.text = taskTemplateParameter.ParameterName
                cell.BacteriumType.text = taskTemplateParameter.ParameterDisplay
                cell.Delete.restorationIdentifier = taskTemplateParameter.RowId
                
                //Outlet Type
                if(assetOutlets.count == 0) {
                    assetOutlets = ModelUtility.getInstance().GetOutletsForAsset(task.AssetId!)
                }
                
                var OutletTypeDropdownData: [String] = []
                OutletTypeDropdownData.append(PleaseSelect)
                OutletTypeDropdownData.append(contentsOf: assetOutlets.keys)
                if OutletTypeDropdownData.count == 1 {
                    OutletTypeDropdownData[0] = "None"
                }
                
                cell.OutletType.restorationIdentifier = taskTemplateParameter.RowId
                cell.OutletType.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                cell.OutletType.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.OutletType.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.OutletType.options = OutletTypeDropdownData.map { KFPopupSelector.Option.text(text: $0) }

                var selectedOutletTypeItem: Int = 0
                if taskTemplateParameterFormItemSampleWithBiocide.OutletType != nil {
                    var count: Int = 0
                    for value in assetOutlets {
                        if value.value == taskTemplateParameterFormItemSampleWithBiocide.OutletType {
                            selectedOutletTypeItem = count + 1 //add 1 for "Please select" value
                            break
                        }
                        count += 1
                    }
                }
                debugPrint("SampleWithBiocide: selected " + (taskTemplateParameterFormItemSampleWithBiocide.OutletType ?? "nil"))
                debugPrint("SampleWithBiocide: selected " + String(selectedOutletTypeItem))
                
                cell.OutletType.selectedIndex = selectedOutletTypeItem
                cell.OutletType.unselectedLabelText = PleaseSelect
                cell.OutletType.displaySelectedValueInLabel = true

                //Sample Type
                if(flushTypes.count == 0) {
                    flushTypes = ModelUtility.getInstance().GetFlushTypesForSample()
                }

                var SampleTypeTypeDropdownData: [String] = []
                SampleTypeTypeDropdownData.append(PleaseSelect)
                SampleTypeTypeDropdownData.append(contentsOf: flushTypes.keys)

                cell.SampleType.restorationIdentifier = taskTemplateParameter.RowId
                cell.SampleType.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                cell.SampleType.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.SampleType.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.SampleType.options = SampleTypeTypeDropdownData.map { KFPopupSelector.Option.text(text: $0) }

                var selectedSampleTypeItem: Int = 0
                if taskTemplateParameterFormItemSampleWithBiocide.SampleType != nil {
                    var count: Int = 0
                    for value in flushTypes {
                        if (value.value.caseInsensitiveCompare(taskTemplateParameterFormItemSampleWithBiocide.SampleType!) == .orderedSame) {
                            selectedSampleTypeItem = count + 1 //add 1 for "Please select" value
                            break
                        }
                        count += 1
                    }
                }

                cell.SampleType.selectedIndex = selectedSampleTypeItem
                cell.SampleType.unselectedLabelText = PleaseSelect
                cell.SampleType.displaySelectedValueInLabel = true

                //Number Of Bottles
                cell.NumberOfBottles.restorationIdentifier = taskTemplateParameter.RowId
                cell.NumberOfBottles.tag = 1
                cell.NumberOfBottles.delegate = self

                if taskTemplateParameterFormItemSampleWithBiocide.NumberOfBottles != nil {
                    cell.NumberOfBottles.text = taskTemplateParameterFormItemSampleWithBiocide.NumberOfBottles
                }

                //Biocide Type
                var BiocideTypeDropdownData: [String] = []
                BiocideTypeDropdownData.append(PleaseSelect)
                BiocideTypeDropdownData.append(contentsOf: ModelUtility.getInstance().GetLookupList("ControlMethodType", extendedReferenceDataType: nil))
                BiocideTypeDropdownData = BiocideTypeDropdownData.filter { $0 != "Temperature Monitoring"}
                BiocideTypeDropdownData = BiocideTypeDropdownData.filter { $0 != "Ultraviolet Light"}
                BiocideTypeDropdownData = BiocideTypeDropdownData.filter { $0 != "Ozone"}
                BiocideTypeDropdownData = BiocideTypeDropdownData.filter { $0 != "Other Type"}
                BiocideTypeDropdownData.append(None)

                cell.BiocideType.restorationIdentifier = taskTemplateParameter.RowId
                cell.BiocideType.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                cell.BiocideType.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.BiocideType.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.BiocideType.options = BiocideTypeDropdownData.map { KFPopupSelector.Option.text(text: $0) }

                var selectedBiocideTypeItem: Int = 0

                if taskTemplateParameterFormItemSampleWithBiocide.BiocideType != nil {
                    var count: Int = 0
                    for value in BiocideTypeDropdownData {
                        if value == taskTemplateParameterFormItemSampleWithBiocide.BiocideType {
                            selectedBiocideTypeItem = count
                            break
                        }
                        count += 1
                    }
                }

                cell.BiocideType.selectedIndex = selectedBiocideTypeItem
                cell.BiocideType.unselectedLabelText = PleaseSelect
                cell.BiocideType.displaySelectedValueInLabel = true
                
               
                //Reading1
                cell.Reading1.restorationIdentifier = taskTemplateParameter.RowId
                cell.Reading1.tag = 2
                cell.Reading1.delegate = self

                if taskTemplateParameterFormItemSampleWithBiocide.Reading1 != nil {
                    cell.Reading1.text = taskTemplateParameterFormItemSampleWithBiocide.Reading1
                }
                
                //Reading2
                cell.Reading2.restorationIdentifier = taskTemplateParameter.RowId
                cell.Reading2.tag = 3
                cell.Reading2.delegate = self

                if taskTemplateParameterFormItemSampleWithBiocide.Reading2 != nil {
                    cell.Reading2.text = taskTemplateParameterFormItemSampleWithBiocide.Reading2
                }
                
                //Temperature
                cell.Temperature.restorationIdentifier = taskTemplateParameter.RowId
                cell.Temperature.tag = 4
                cell.Temperature.delegate = self

                if taskTemplateParameterFormItemSampleWithBiocide.Temperature != nil {
                    cell.Temperature.text = taskTemplateParameterFormItemSampleWithBiocide.Temperature
                }
                
                taskTemplateParameterFormItemSampleWithBiocide.cell = cell
                return cell
                
            case "SampleWithMultipleTests":
                let cell = tableView.dequeueReusableCell(withIdentifier: "SampleWithMultipleTests", for: indexPath) as! TaskTemplateParameterCellSampleWithMultipleTests
                
                let taskTemplateParameterFormItemSampleWithMultipleTests: TaskTemplateParameterFormItemSampleWithMultipleTests = taskTemplateParameterFormItem as! TaskTemplateParameterFormItemSampleWithMultipleTests
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.SampleReference.text = taskTemplateParameter.ParameterName
                cell.BacteriumType.text = taskTemplateParameter.ParameterDisplay
                cell.Delete.restorationIdentifier = taskTemplateParameter.RowId
               
                //Outlet Type
                if(assetOutlets.count == 0) {
                    assetOutlets = ModelUtility.getInstance().GetOutletsForAsset(task.AssetId!)
                }
                
                var OutletTypeDropdownData: [String] = []
                OutletTypeDropdownData.append(PleaseSelect)
                OutletTypeDropdownData.append(contentsOf: assetOutlets.keys)
                if OutletTypeDropdownData.count == 1 {
                    OutletTypeDropdownData[0] = "None"
                }
                
                cell.OutletType.restorationIdentifier = taskTemplateParameter.RowId
                cell.OutletType.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                cell.OutletType.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.OutletType.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.OutletType.options = OutletTypeDropdownData.map { KFPopupSelector.Option.text(text: $0) }

                var selectedOutletTypeItem: Int = 0
                if taskTemplateParameterFormItemSampleWithMultipleTests.OutletType != nil {
                    var count: Int = 0
                    for value in assetOutlets {
                        if (value.value.caseInsensitiveCompare(taskTemplateParameterFormItemSampleWithMultipleTests.OutletType!) == .orderedSame){
                            selectedOutletTypeItem = count + 1 //add 1 for "Please select" value
                            break
                        }
                        count += 1
                    }
                }
                debugPrint("SampleWithMultipleTests: selected " + (taskTemplateParameterFormItemSampleWithMultipleTests.OutletType ?? "nil"))
                debugPrint("SampleWithMultipleTests: selected " + String(selectedOutletTypeItem))
                
                cell.OutletType.selectedIndex = selectedOutletTypeItem
                cell.OutletType.unselectedLabelText = PleaseSelect
                cell.OutletType.displaySelectedValueInLabel = true

                //Sample Type
                if(flushTypes.count == 0) {
                    flushTypes = ModelUtility.getInstance().GetFlushTypesForSample()
                }
                
                var SampleTypeTypeDropdownData: [String] = []
                SampleTypeTypeDropdownData.append(PleaseSelect)
                SampleTypeTypeDropdownData.append(contentsOf: flushTypes.keys)
                
                cell.SampleType.restorationIdentifier = taskTemplateParameter.RowId
                cell.SampleType.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                cell.SampleType.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.SampleType.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.SampleType.options = SampleTypeTypeDropdownData.map { KFPopupSelector.Option.text(text: $0) }

                var selectedSampleTypeItem: Int = 0
                if taskTemplateParameterFormItemSampleWithMultipleTests.SampleType != nil {
                    var count: Int = 0
                    for value in flushTypes {
                        if (value.value.caseInsensitiveCompare(taskTemplateParameterFormItemSampleWithMultipleTests.SampleType!) == .orderedSame) {
                            selectedSampleTypeItem = count + 1 //add 1 for "Please select" value
                            break
                        }
                        count += 1
                    }
                }

                cell.SampleType.selectedIndex = selectedSampleTypeItem
                cell.SampleType.unselectedLabelText = PleaseSelect
                cell.SampleType.displaySelectedValueInLabel = true

                //Number Of Bottles
                cell.NumberOfBottles.restorationIdentifier = taskTemplateParameter.RowId
                cell.NumberOfBottles.delegate = self

                if taskTemplateParameterFormItemSampleWithMultipleTests.NumberOfBottles != nil {
                    cell.NumberOfBottles.text = taskTemplateParameterFormItemSampleWithMultipleTests.NumberOfBottles
                }

                cell.TVC.isChecked = taskTemplateParameterFormItemSampleWithMultipleTests.TVC
                cell.TVC.restorationIdentifier = taskTemplateParameter.RowId
                cell.TVC.Name = "TVC"
                cell.TVC.setTitle("", for: .normal)
                cell.TVC.delegate = self
 
                cell.EColi.isChecked = taskTemplateParameterFormItemSampleWithMultipleTests.EColi
                cell.EColi.restorationIdentifier = taskTemplateParameter.RowId
                cell.EColi.Name = "EColi"
                cell.EColi.setTitle("", for: .normal)
                cell.EColi.delegate = self
 
                cell.Coliforms.isChecked = taskTemplateParameterFormItemSampleWithMultipleTests.Coliforms
                cell.Coliforms.restorationIdentifier = taskTemplateParameter.RowId
                cell.Coliforms.Name = "Coliforms"
                cell.Coliforms.setTitle("", for: .normal)
                cell.Coliforms.delegate = self
 
                cell.PseudomonasSpp.isChecked = taskTemplateParameterFormItemSampleWithMultipleTests.PseudomonasSpp
                cell.PseudomonasSpp.restorationIdentifier = taskTemplateParameter.RowId
                cell.PseudomonasSpp.Name = "PseudomonasSpp"
                cell.PseudomonasSpp.setTitle("", for: .normal)
                cell.PseudomonasSpp.delegate = self
 
                cell.PseudomonasAeruginosa.isChecked = taskTemplateParameterFormItemSampleWithMultipleTests.PseudomonasAeruginosa
                cell.PseudomonasAeruginosa.restorationIdentifier = taskTemplateParameter.RowId
                cell.PseudomonasAeruginosa.Name = "PseudomonasAeruginosa"
                cell.PseudomonasAeruginosa.setTitle("", for: .normal)
                cell.PseudomonasAeruginosa.delegate = self
 
                cell.Cryptosporidium.isChecked = taskTemplateParameterFormItemSampleWithMultipleTests.Cryptosporidium
                cell.Cryptosporidium.restorationIdentifier = taskTemplateParameter.RowId
                cell.Cryptosporidium.Name = "Cryptosporidium"
                cell.Cryptosporidium.setTitle("", for: .normal)
                cell.Cryptosporidium.delegate = self
 
                if(!taskInstruction.RowId.isEmpty) {
                    cell.Delete.isHidden = true
                    cell.OutletType.isEnabled = false
                    cell.SampleType.isEnabled = false
                    cell.NumberOfBottles.isEnabled = false
                    cell.TVC.isEnabled = false
                    cell.EColi.isEnabled = false
                    cell.Coliforms.isEnabled = false
                    cell.PseudomonasSpp.isEnabled = false
                    cell.PseudomonasAeruginosa.isEnabled = false
                    cell.Cryptosporidium.isEnabled = false
                }
                    
                
                taskTemplateParameterFormItemSampleWithMultipleTests.cell = cell
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
        switch (taskTemplateParameter.ParameterType)
        {
        case "GS1 Data Matrix" :
            return 134
        
        case "Scan Universal" :
            return 134
    
        case "Sample":
            return 280
        
        case "SampleWithBiocide":
            return 458

        case "SampleWithMultipleTests":
            return 392
            
        default:
            return 68
        }
    }

    // MARK: Control handling

    fileprivate func ProcessDependencies(_ thisTaskTemplateParameterFormItem: TaskTemplateParameterFormItem) {
        debugPrint("ProcessDependencies: " + thisTaskTemplateParameterFormItem.TemplateParameter.RowId)
        
        //one off case for Accessible and samples
        if (thisTaskTemplateParameterFormItem.TemplateParameter.ParameterName == "Accessible")
        {
            if (thisTaskTemplateParameterFormItem.SelectedItem == "Yes")
            {
                self.AddSample.isEnabled = true;
            }
            else
            {
                self.AddSample.isEnabled = false;
            }
        }

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
    
    @IBAction func OutletTypePopupChanged(_ sender: KFPopupSelector) {
        if let thisTaskTemplateParameterId: String = sender.restorationIdentifier {
            debugPrint("OutletTypePopupChanged: " + thisTaskTemplateParameterId)
            debugPrint("OutletTypePopupChanged: " + sender.selectedValue!)
            
            let thisTaskTemplateParameterFormItem: TaskTemplateParameterFormItemSample = taskTemplateParameterFormItems[thisTaskTemplateParameterId] as! TaskTemplateParameterFormItemSample

            //get the outletid from the selcted value
            //remember to cater for no outlet
            if let outletId: String = assetOutlets[sender.selectedValue!]
            {
                // record the selected value
                if thisTaskTemplateParameterFormItem.OutletType != outletId {
                    thisTaskTemplateParameterFormItem.OutletType = outletId
                }
            }
            else if (sender.selectedValue! == "None")
            {
                thisTaskTemplateParameterFormItem.OutletType = "None"
            }
        }
    }
    
    @IBAction func SampleTypePopupChanged(_ sender: KFPopupSelector) {
        if let thisTaskTemplateParameterId: String = sender.restorationIdentifier {
            debugPrint("SampleTypePopupChanged: " + thisTaskTemplateParameterId)
            debugPrint("SampleTypePopupChanged: " + sender.selectedValue!)
            
            let thisTaskTemplateParameterFormItem: TaskTemplateParameterFormItemSample = taskTemplateParameterFormItems[thisTaskTemplateParameterId] as! TaskTemplateParameterFormItemSample

            if let flushType: String = flushTypes[sender.selectedValue!]
            {
                // record the selected value
                if thisTaskTemplateParameterFormItem.SampleType != flushType {
                    thisTaskTemplateParameterFormItem.SampleType = flushType
                }
            }
        }
    }
    
    @IBAction func BiocideTypePopupChanged(_ sender: KFPopupSelector) {
        if let thisTaskTemplateParameterId: String = sender.restorationIdentifier {
            debugPrint("BiocideTypePopupChanged: " + thisTaskTemplateParameterId)

            let thisTaskTemplateParameterFormItem: TaskTemplateParameterFormItemSampleWithBiocide = taskTemplateParameterFormItems[thisTaskTemplateParameterId] as! TaskTemplateParameterFormItemSampleWithBiocide

            // record the selected value


            if thisTaskTemplateParameterFormItem.BiocideType != sender.selectedValue {
                thisTaskTemplateParameterFormItem.BiocideType = sender.selectedValue
            }
            
            if let cell = thisTaskTemplateParameterFormItem.cell as? TaskTemplateParameterCellSampleWithBiocide
            {
                if thisTaskTemplateParameterFormItem.BiocideType == "Copper Silver Ionisation" {
                    cell.Reading1Label.text = "Copper Level"
                    cell.Reading1Label.isHidden = false
                    cell.Reading1.isHidden = false
                    cell.Reading2Label.text = "Silver Level"
                    cell.Reading2Label.isHidden = false
                    cell.Reading2.isHidden = false
                }
                else if thisTaskTemplateParameterFormItem.BiocideType == None
                {
                    cell.Reading1Label.isHidden = true
                    cell.Reading1.isHidden = true
                    cell.Reading2Label.isHidden = true
                    cell.Reading2.isHidden = true
                }
                else
                {
                    cell.Reading1Label.isHidden = false
                    cell.Reading1.isHidden = false
                    cell.Reading1Label.text = thisTaskTemplateParameterFormItem.BiocideType! + " Level"
                    cell.Reading2Label.isHidden = true
                    cell.Reading2.isHidden = true
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
                let cell: TaskTemplateParameterCellTemperature = (sender as! UIButton).superview!.superview!.superview!.superview as! TaskTemplateParameterCellTemperature
                Session.CurrentProfileControl = cell.Answer
            } else {
                Session.CurrentProfileControl = sender as? UITextField
            }

            let temperatureProfileViewController = segue.destination as! TemperatureProfileViewController
            temperatureProfileViewController.hot = (Session.CurrentProfileControl!.tag == TemperatureProfileCellHot)
            Session.GettingProfile = true

        case "ScanUniversalSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellScanUniversal = (sender as! UIButton).superview!.superview!.superview!.superview as! TaskTemplateParameterCellScanUniversal
                Session.CurrentScanUniversalControl = cell.Answer
                Session.CurrentScanUniversalCell = cell
            } else {
                Session.CurrentScanUniversalControl = sender as? UITextField
            }

            Session.GettingScanUniversal = true

        case "DataMatrixSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellDataMatrix = (sender as! UIButton).superview!.superview!.superview!.superview as! TaskTemplateParameterCellDataMatrix
                Session.CurrentDataMatrixControl = cell.Answer
                Session.CurrentDataMatrixCell = cell
            } else {
                Session.CurrentDataMatrixControl = sender as? UITextField
            }

            Session.GettingDataMatrix = true
        
        case "ScanCodeSegue":

            if sender is UIButton {
                let cell: TaskTemplateParameterCellScanCode = (sender as! UIButton).superview!.superview!.superview!.superview as! TaskTemplateParameterCellScanCode
                Session.CurrentScanCodeControl = cell.Answer
            } else {
                Session.CurrentScanCodeControl = sender as? UITextField
            }

            Session.GettingScanCode = true
            
        case "SampleScan":
            if let cell: TaskTemplateParameterCellSample = (sender as! UIButton).superview!.superview!.superview!.superview!.superview as? TaskTemplateParameterCellSample {
                Session.CurrentSampleRestorationIdentifier = cell.restorationIdentifier
                Session.GettingSampleScancode = true
            }

        case "SampleWithBiocideScan":
            if let cell: TaskTemplateParameterCellSampleWithBiocide = (sender as! UIButton).superview!.superview!.superview!.superview!.superview as? TaskTemplateParameterCellSampleWithBiocide {
                Session.CurrentSampleRestorationIdentifier = cell.restorationIdentifier
                Session.GettingSampleScancode = true
            }

        case "SampleWithMultipleTestsScan":
            if let cell: TaskTemplateParameterCellSampleWithMultipleTests = (sender as! UIButton).superview!.superview!.superview!.superview!.superview as? TaskTemplateParameterCellSampleWithMultipleTests {
                Session.CurrentSampleRestorationIdentifier = cell.restorationIdentifier
                Session.GettingSampleScancode = true
            }

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

        default:
            break
        }
        return true
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if Session.TimerRunning {
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
        
        if textField.tag >= TemperatureCell && Session.BluetoothProbeConnected || textField.tag >= TemperatureCell && Session.ThermaQBluetoothProbeConnected
        {
            stopProbeTimer()
            Session.CurrentTemperatureControl!.isEnabled = true
            Session.CurrentTemperatureControl!.backgroundColor = UIColor.white
        }

         if textField.restorationIdentifier != nil {
            if taskTemplateParameterFormItems[textField.restorationIdentifier!] is TaskTemplateParameterFormItemSampleWithBiocide
            {
                let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItemSampleWithBiocide = (taskTemplateParameterFormItems[textField.restorationIdentifier!] as? TaskTemplateParameterFormItemSampleWithBiocide)!
            
                switch textField.tag
                {
                    case 1:
                        currentTaskTemplateParameterFormItem.NumberOfBottles = textField.text
                        break
                    case 2:
                        currentTaskTemplateParameterFormItem.Reading1 = textField.text
                        break
                    case 3:
                        currentTaskTemplateParameterFormItem.Reading2 = textField.text
                        break
                    case 4:
                        currentTaskTemplateParameterFormItem.Temperature = textField.text
                        break
                    default:
                        break
                }
            }
            else if taskTemplateParameterFormItems[textField.restorationIdentifier!] is TaskTemplateParameterFormItemSampleWithMultipleTests ||  taskTemplateParameterFormItems[textField.restorationIdentifier!] is TaskTemplateParameterFormItemSample
            {
                if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItemSample = taskTemplateParameterFormItems[textField.restorationIdentifier!] as? TaskTemplateParameterFormItemSample
                {
                    currentTaskTemplateParameterFormItem.NumberOfBottles = textField.text
                }
            }
            else if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[textField.restorationIdentifier!]
            {
                currentTaskTemplateParameterFormItem.SelectedItem = textField.text
            }
            
            
        }
        activeField = nil
        textField.resignFirstResponder()
    }

    // MARK: CheckBoxDelegate\
    func CheckBoxClicked(sender: CheckBox) {
        if sender.restorationIdentifier != nil {
            let currentTaskTemplateParameterFormItemSampleWithMultipleTests: TaskTemplateParameterFormItemSampleWithMultipleTests = taskTemplateParameterFormItems[sender.restorationIdentifier!] as! TaskTemplateParameterFormItemSampleWithMultipleTests
            
            switch sender.Name {
            case "TVC":
                currentTaskTemplateParameterFormItemSampleWithMultipleTests.TVC = sender.isChecked
                break
            case "EColi":
                currentTaskTemplateParameterFormItemSampleWithMultipleTests.EColi = sender.isChecked
                break
            case "Coliforms":
                currentTaskTemplateParameterFormItemSampleWithMultipleTests.Coliforms = sender.isChecked
                break
            case "PseudomonasSpp":
                currentTaskTemplateParameterFormItemSampleWithMultipleTests.PseudomonasSpp = sender.isChecked
                break
            case "PseudomonasAeruginosa":
                currentTaskTemplateParameterFormItemSampleWithMultipleTests.PseudomonasAeruginosa = sender.isChecked
                break
            case "Cryptosporidium":
                currentTaskTemplateParameterFormItemSampleWithMultipleTests.Cryptosporidium = sender.isChecked
                break
            default:
                break
            }
            
        }
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
    @IBAction func AddPressed(_ sender: UIButton) {
        switch ((sender).titleLabel?.text) {
        case "Add Sample":
            break
        default:
            break
        }
    }
    
    @IBAction func DeletePressed(_ sender: UIButton) {
    }
    
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
            Session.TaskId = nil
            EAController.shared().callBack = nil
            _ = navigationController?.popViewController(animated: true)
        } else {
            Session.CodeScanned = nil
            Session.TaskId = nil
            _ = navigationController?.popViewController(animated: true)
        }
    }

    //MARK: Validation
    func Validate() -> Bool {
        var valid: Bool = true
        var SampleFound: Bool = false

        for (_, taskTemplateParameterFormItem) in taskTemplateParameterFormItems {
            let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItem.TemplateParameter
            
            switch taskTemplateParameter.ParameterType {
            case "Sample":
                SampleFound = true
                
                let SampleItem: TaskTemplateParameterFormItemSample = taskTemplateParameterFormItem as! TaskTemplateParameterFormItemSample
                
                let SampleCell: TaskTemplateParameterCellSample  = SampleItem.cell as! TaskTemplateParameterCellSample
                
                if SampleCell.outletType() == nil || SampleCell.outletType() == "" || SampleCell.outletType() == NotApplicable || SampleCell.outletType() == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }

                if SampleCell.sampleType() == nil || SampleCell.sampleType() == "" || SampleCell.sampleType() == NotApplicable || SampleCell.sampleType() == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                if SampleCell.numberOfBottles() == nil || SampleCell.numberOfBottles() == "" || SampleCell.numberOfBottles() == NotApplicable || SampleCell.numberOfBottles() == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                break
                
            case "SampleWithBiocide":
                SampleFound = true
                    
                let taskTemplateParameterFormItemSampleWithBiocide: TaskTemplateParameterFormItemSampleWithBiocide = taskTemplateParameterFormItem as! TaskTemplateParameterFormItemSampleWithBiocide
                
                if taskTemplateParameterFormItemSampleWithBiocide.OutletType == nil || taskTemplateParameterFormItemSampleWithBiocide.OutletType == "" || taskTemplateParameterFormItemSampleWithBiocide.OutletType == NotApplicable || taskTemplateParameterFormItemSampleWithBiocide.OutletType == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }

                if taskTemplateParameterFormItemSampleWithBiocide.SampleType == nil || taskTemplateParameterFormItemSampleWithBiocide.SampleType == "" || taskTemplateParameterFormItemSampleWithBiocide.SampleType == NotApplicable || taskTemplateParameterFormItemSampleWithBiocide.SampleType == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                if taskTemplateParameterFormItemSampleWithBiocide.NumberOfBottles == nil || taskTemplateParameterFormItemSampleWithBiocide.NumberOfBottles == "" || taskTemplateParameterFormItemSampleWithBiocide.NumberOfBottles == NotApplicable || taskTemplateParameterFormItemSampleWithBiocide.NumberOfBottles == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                if taskTemplateParameterFormItemSampleWithBiocide.BiocideType == nil || taskTemplateParameterFormItemSampleWithBiocide.BiocideType == "" || taskTemplateParameterFormItemSampleWithBiocide.BiocideType == NotApplicable || taskTemplateParameterFormItemSampleWithBiocide.BiocideType == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                else
                {
                    switch taskTemplateParameterFormItemSampleWithBiocide.BiocideType {
                    case "None":
                        break
                        
                    case "Copper Silver Ionisation":
                        if taskTemplateParameterFormItemSampleWithBiocide.Reading1 == nil || taskTemplateParameterFormItemSampleWithBiocide.Reading1 == "" || taskTemplateParameterFormItemSampleWithBiocide.Reading1 == NotApplicable || taskTemplateParameterFormItemSampleWithBiocide.Reading1 == PleaseSelect {
                            taskTemplateParameterFormItem.LabelColour = UIColor.red
                            SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                            valid = false
                        }
                        if taskTemplateParameterFormItemSampleWithBiocide.Reading2 == nil || taskTemplateParameterFormItemSampleWithBiocide.Reading2 == "" || taskTemplateParameterFormItemSampleWithBiocide.Reading2 == NotApplicable || taskTemplateParameterFormItemSampleWithBiocide.Reading2 == PleaseSelect {
                            taskTemplateParameterFormItem.LabelColour = UIColor.red
                            SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                            valid = false
                        }
                        break
                    default:
                        if taskTemplateParameterFormItemSampleWithBiocide.Reading1 == nil || taskTemplateParameterFormItemSampleWithBiocide.Reading1 == "" || taskTemplateParameterFormItemSampleWithBiocide.Reading1 == NotApplicable || taskTemplateParameterFormItemSampleWithBiocide.Reading1 == PleaseSelect {
                            taskTemplateParameterFormItem.LabelColour = UIColor.red
                            SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                            valid = false
                        }
                        break
                    }
                }
 
                if taskTemplateParameterFormItemSampleWithBiocide.Temperature == nil || taskTemplateParameterFormItemSampleWithBiocide.Temperature == "" || taskTemplateParameterFormItemSampleWithBiocide.Temperature == NotApplicable || taskTemplateParameterFormItemSampleWithBiocide.Temperature == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                break

                
            case "SampleWithMultipleTests":
                SampleFound = true
                let taskTemplateParameterFormItemSampleWithMultipleTests: TaskTemplateParameterFormItemSampleWithMultipleTests = taskTemplateParameterFormItem as! TaskTemplateParameterFormItemSampleWithMultipleTests
                
                if taskTemplateParameterFormItemSampleWithMultipleTests.OutletType == nil || taskTemplateParameterFormItemSampleWithMultipleTests.OutletType == "" || taskTemplateParameterFormItemSampleWithMultipleTests.OutletType == NotApplicable || taskTemplateParameterFormItemSampleWithMultipleTests.OutletType == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }

                if taskTemplateParameterFormItemSampleWithMultipleTests.SampleType == nil || taskTemplateParameterFormItemSampleWithMultipleTests.SampleType == "" || taskTemplateParameterFormItemSampleWithMultipleTests.SampleType == NotApplicable || taskTemplateParameterFormItemSampleWithMultipleTests.SampleType == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                if taskTemplateParameterFormItemSampleWithMultipleTests.NumberOfBottles == nil || taskTemplateParameterFormItemSampleWithMultipleTests.NumberOfBottles == "" || taskTemplateParameterFormItemSampleWithMultipleTests.NumberOfBottles == NotApplicable || taskTemplateParameterFormItemSampleWithMultipleTests.NumberOfBottles == PleaseSelect {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                if !(taskTemplateParameterFormItemSampleWithMultipleTests.TVC || taskTemplateParameterFormItemSampleWithMultipleTests.EColi || taskTemplateParameterFormItemSampleWithMultipleTests.Coliforms || taskTemplateParameterFormItemSampleWithMultipleTests.PseudomonasSpp || taskTemplateParameterFormItemSampleWithMultipleTests.PseudomonasAeruginosa || taskTemplateParameterFormItemSampleWithMultipleTests.Cryptosporidium) {
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    valid = false
                }
                
                break
                
            default:
                if !((taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "None")
                    || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "None")
                    || (taskTemplateParameter.ParameterName == "RemoveAsset")
                    || (taskTemplateParameter.ParameterName == "AlternateAssetCode")
                    || (taskTemplateParameter.ParameterName.hasPrefix("Add") && taskTemplateParameter.ParameterName.hasSuffix("Notes")))
                {
                    let value: String? = GetParameterValue(taskTemplateParameter.RowId)

                    //TBD: check collect parameter
                    if (value == nil || value == String() || value == PleaseSelect) && taskTemplateParameter.Collect {
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
                break
            }
        }
        
        if !SampleFound {
            valid = false
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

                case "Reference Data":

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

                case "Sample":
                    let cell: TaskTemplateParameterCellSample = tableCell as! TaskTemplateParameterCellSample
                    cell.Sample.textColor = colour
                    return
                    
                case "SampleWithBiocide":
                    let cell: TaskTemplateParameterCellSampleWithBiocide = tableCell as! TaskTemplateParameterCellSampleWithBiocide
                    cell.Sample.textColor = colour
                    return
                    
                case "SampleWithMultipleTests":
                    let cell: TaskTemplateParameterCellSampleWithMultipleTests = tableCell as! TaskTemplateParameterCellSampleWithMultipleTests
                    cell.Sample.textColor = colour
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

                case "Sample":
                    let cell: TaskTemplateParameterCellSample = tableCell as! TaskTemplateParameterCellSample
                    cell.Sample.backgroundColor = colour
                    return
                    
                case "SampleWithBiocide":
                    let cell: TaskTemplateParameterCellSampleWithBiocide = tableCell as! TaskTemplateParameterCellSampleWithBiocide
                    cell.Sample.backgroundColor = colour
                    return
                    
                case "SampleWithMultipleTests":
                    let cell: TaskTemplateParameterCellSampleWithMultipleTests = tableCell as! TaskTemplateParameterCellSampleWithMultipleTests
                    cell.Sample.backgroundColor = colour
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
                
                switch (taskTemplateParameter.ParameterType)
                {
                case "Sample":
                    //build the parameters for a sample
                    let SampleParameterId: String = taskTemplateParameter.RowId
                    let SampleRef: String = taskTemplateParameter.ParameterName
                     
                    let SampleItem: TaskTemplateParameterFormItemSample = taskTemplateParameterFormItems[SampleParameterId] as! TaskTemplateParameterFormItemSample
                    
                    //SampleRef
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = "SampleRef"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "SampleRef"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = SampleRef
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //SamplingFor (BacteriumType)
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "BacteriumType"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Sampling For"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = taskTemplateParameter.ParameterDisplay
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //OutletName
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "OutletId"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Hot or Cold"
                    currentTaskParameter.Collect = true
                    if((SampleItem.cell as! TaskTemplateParameterCellSample).outletType()! != "None") {
                        currentTaskParameter.ParameterValue = assetOutlets[(SampleItem.cell as! TaskTemplateParameterCellSample).outletType()!]!
                    }
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                     
                    //SampleType
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "SampleType"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Sample Type"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = flushTypes[(SampleItem.cell as! TaskTemplateParameterCellSample).sampleType()!]!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //NoOfBottles
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "NoOfBottles"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "No of Bottles"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = (SampleItem.cell as! TaskTemplateParameterCellSample).numberOfBottles()!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    break;
                    
                case "SampleWithBiocide":
                    //build the parameters for a sample
                    let SampleParameterId: String = taskTemplateParameter.RowId
                    let SampleRef: String = taskTemplateParameter.ParameterName
                    
                    let SampleItem: TaskTemplateParameterFormItemSampleWithBiocide = taskTemplateParameterFormItems[SampleParameterId] as! TaskTemplateParameterFormItemSampleWithBiocide
                    
                    //SampleRef
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = "SampleRef"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "SampleRef"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = SampleRef
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //SamplingFor (BacteriumType)
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "BacteriumType"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Sampling For"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = taskTemplateParameter.ParameterDisplay
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //OutletName
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "OutletId"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Hot or Cold"
                    currentTaskParameter.Collect = true
                    if((SampleItem.cell as! TaskTemplateParameterCellSampleWithBiocide).outletType()! != "None") {
                        currentTaskParameter.ParameterValue = assetOutlets[(SampleItem.cell as! TaskTemplateParameterCellSampleWithBiocide).outletType()!]!
                    }
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                     
                    //SampleType
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "SampleType"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Sample Type"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = flushTypes[(SampleItem.cell as! TaskTemplateParameterCellSampleWithBiocide).sampleType()!]!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //NoOfBottles
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "NoOfBottles"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "No of Bottles"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = (SampleItem.cell as! TaskTemplateParameterCellSampleWithBiocide).numberOfBottles()!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)

                    //BiocideType
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "BiocideType"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Biocide Type"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = (SampleItem.cell as! TaskTemplateParameterCellSampleWithBiocide).biocideType()!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //Reading1
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "Reading"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Reading"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = (SampleItem.cell as! TaskTemplateParameterCellSampleWithBiocide).reading1()!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //Reading2
                    if(SampleItem.Reading2 != nil)
                    {
                        currentTaskParameter = TaskParameter()
                        currentTaskParameter.RowId = UUID().uuidString
                        currentTaskParameter.CreatedBy = Session.OperativeId!
                        currentTaskParameter.CreatedOn = now
                        currentTaskParameter.TaskId = Session.TaskId!
                        currentTaskParameter.TaskTemplateParameterId = nil
                        currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "Reading2"
                        currentTaskParameter.ParameterType = "FreeText"
                        currentTaskParameter.ParameterDisplay = "Reading 2"
                        currentTaskParameter.Collect = true
                        currentTaskParameter.ParameterValue = (SampleItem.cell as! TaskTemplateParameterCellSampleWithBiocide).reading2()!
                        _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    }
                    
                    //Temperature
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "Temperature"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Temperature"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = (SampleItem.cell as! TaskTemplateParameterCellSampleWithBiocide).temperature()!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
 
                    break;
                    
                case "SampleWithMultipleTests":
                    //build the parameters for a sample
                    let SampleParameterId: String = taskTemplateParameter.RowId
                    let SampleRef: String = taskTemplateParameter.ParameterName
                    
                    let SampleItem: TaskTemplateParameterFormItemSampleWithMultipleTests = taskTemplateParameterFormItems[SampleParameterId] as! TaskTemplateParameterFormItemSampleWithMultipleTests
                    
                    //SampleRef
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = "SampleRef"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "SampleRef"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = SampleRef
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //OutletName
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "OutletId"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Hot or Cold"
                    currentTaskParameter.Collect = true
                    if((SampleItem.cell as! TaskTemplateParameterCellSampleWithMultipleTests).outletType()! != "None") {                    currentTaskParameter.ParameterValue = assetOutlets[(SampleItem.cell as! TaskTemplateParameterCellSampleWithMultipleTests).outletType()!]!
                    }
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                     
                    //SampleType
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "SampleType"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Sample Type"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = flushTypes[(SampleItem.cell as! TaskTemplateParameterCellSampleWithMultipleTests).sampleType()!]!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    //NoOfBottles
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "NoOfBottles"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "No of Bottles"
                    currentTaskParameter.Collect = true
                    currentTaskParameter.ParameterValue = (SampleItem.cell as! TaskTemplateParameterCellSampleWithMultipleTests).numberOfBottles()!
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                   
                    //Tests
                    currentTaskParameter = TaskParameter()
                    currentTaskParameter.RowId = UUID().uuidString
                    currentTaskParameter.CreatedBy = Session.OperativeId!
                    currentTaskParameter.CreatedOn = now
                    currentTaskParameter.TaskId = Session.TaskId!
                    currentTaskParameter.TaskTemplateParameterId = nil
                    currentTaskParameter.ParameterName = SampleRef + SampleRefDelimiter + "Tests"
                    currentTaskParameter.ParameterType = "FreeText"
                    currentTaskParameter.ParameterDisplay = "Tests"
                    currentTaskParameter.Collect = true
                    
                    var parameterValue: String = ""
                
                    if(SampleItem.TVC) {parameterValue += "[TVC]"}
                    if(SampleItem.EColi) {parameterValue += "[EColi]"}
                    if(SampleItem.Coliforms) {parameterValue += "[Coliforms]"}
                    if(SampleItem.PseudomonasSpp) {parameterValue += "[PseudomonasSpp]"}
                    if(SampleItem.PseudomonasAeruginosa) {parameterValue += "[PseudomonasAeruginosa]"}
                    if(SampleItem.Cryptosporidium) {parameterValue += "[Cryptosporidium]"}
                    
                    currentTaskParameter.ParameterValue = parameterValue
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    
                    break;
                    
                default:
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
                    currentTaskParameter.ParameterValue = (GetParameterValue(currentTaskParameter.TaskTemplateParameterId!) ?? "")
                    _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
                    if currentTaskParameter.ParameterName == "Accessible" && currentTaskParameter.ParameterValue == "No"
                    {
                        accessbile = false
                    }
                    break;
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
                Session.TaskId = nil
                Session.FilterAssetNumber = nil
                EAController.shared().callBack = nil
                _ = navigationController?.popViewController(animated: true)
            } else {
                Session.CodeScanned = nil
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
