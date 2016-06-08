//
//  TaskViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 20/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import Foundation
import UIKit

class TaskViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate, ETIPassingData, AlertMessageDelegate {

    var task: Task = Task()
    var asset: Asset = Asset()

    var taskTemplateParameterFormItems: Dictionary<String, TaskTemplateParameterFormItem> = Dictionary<String, TaskTemplateParameterFormItem>()
    var formTaskTemplateParameters: [TaskTemplateParameter] = [TaskTemplateParameter]()
    
    var removeAssetParameter: TaskTemplateParameter = TaskTemplateParameter()
    var alternateAssetCodeParameter: TaskTemplateParameter = TaskTemplateParameter()
    var additionalNotesParameter: TaskTemplateParameter = TaskTemplateParameter()
    
    var probeTimer: NSTimer = NSTimer()
    var currentReading: String? = nil
    
    var currentTemperatureControl: UITextField? = nil
    
    //parameter table
    @IBOutlet var taskParameterTable: UITableView!
        
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

    var HotType: String? = nil
    var ColdType: String? = nil
    
    //standard actions
    override func viewDidLoad() {
        super.viewDidLoad()
        Session.CodeScanned = nil
        
        task = ModelManager.getInstance().getTask(Session.TaskId!)!
        
        if (task.AssetId != nil)
        {
           //get the hot cold details for the task
            let asset: Asset = ModelManager.getInstance().getAsset(task.AssetId!)!
            HotType = asset.HotType
            ColdType = asset.ColdType
        }
        
        AssetType.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!)
        if (task.TaskName == RemedialTask)
        {
            TaskName.text = RemedialTask
        }
        else
        {
            TaskName.text  = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup)
        }
        if let locationName: String = task.LocationName {Location.text = locationName} else {Location.text = "no location"}
        if let assetNumber: String = task.AssetNumber {AssetNumber.text = assetNumber} else {AssetNumber.text = "no asset"}
        TaskReference.text = task.TaskRef
        
        //get the the parameters for the table
        if (TaskName.text != RemedialTask)
        {
            let taskTemplateId = task.TaskTemplateId
            
            var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            criteria["TaskTemplateId"] = taskTemplateId
            
            formTaskTemplateParameters = ModelManager.getInstance().findTaskTemplateParameterList(criteria)
            
            for taskTemplateParameter: TaskTemplateParameter in formTaskTemplateParameters
            {
               taskTemplateParameterFormItems[taskTemplateParameter.RowId] = TaskTemplateParameterFormItem(taskTemplateParameter: taskTemplateParameter)
            }
            
            if (formTaskTemplateParameters.count > 3)
            {
                //additional notes will always be the last record
                additionalNotesParameter = formTaskTemplateParameters[formTaskTemplateParameters.count - 1]
                formTaskTemplateParameters.removeLast()
                
                //remove alternate asset code and remove asset
                alternateAssetCodeParameter = formTaskTemplateParameters[1]
                formTaskTemplateParameters.removeAtIndex(1)
                
                removeAssetParameter = formTaskTemplateParameters[0]
                formTaskTemplateParameters.removeAtIndex(0)
            }
        }
        
        AdditionalNotes.delegate = self
        AlternateAssetCode.delegate = self
        
        //reload the table
        taskParameterTable.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NewScancode()
    }

    //MARK: UITableView delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formTaskTemplateParameters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let taskTemplateParameter: TaskTemplateParameter = formTaskTemplateParameters[indexPath.row]
        let taskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[taskTemplateParameter.RowId]!

        var predecessor: String? = String?()
     
        if (taskTemplateParameter.Predecessor != nil)
        {
            predecessor = taskTemplateParameter.Predecessor!
        }
        
        if (predecessor != nil)
        {
            if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[predecessor!]!
            {
                currentTaskTemplateParameterFormItem.Dependencies.append(taskTemplateParameterFormItem)
            }
        }
        
        if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
        {

            let cell = tableView.dequeueReusableCellWithIdentifier("TemperatureCell", forIndexPath: indexPath) as! TaskTemplateParameterCellTemperature
            cell.restorationIdentifier = taskTemplateParameter.RowId
            if (HotType == "Blended" && taskTemplateParameter.ParameterDisplay == "Hot Temperature")
            {
                cell.Question.text = "Blended Temperature"
            }
            else
            {
                cell.Question.text = taskTemplateParameter.ParameterDisplay
            }
            cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour

            cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
            cell.Answer.delegate = self
            
            
            if taskTemplateParameterFormItem.SelectedItem != nil
            {
                cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
            }
            
            cell.Answer.tag = 1
            
            if (taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "None") || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "None")
            {
                taskTemplateParameterFormItem.Enabled = false
            }
            cell.Answer.enabled = taskTemplateParameterFormItem.Enabled
            return cell
        }
        else
        {
            switch taskTemplateParameter.ParameterType
            {
            case "Freetext":
                let cell = tableView.dequeueReusableCellWithIdentifier("FreetextCell", forIndexPath: indexPath) as! TaskTemplateParameterCellFreetext
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self

                if taskTemplateParameterFormItem.SelectedItem != nil
                {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }
                cell.Answer.enabled = taskTemplateParameterFormItem.Enabled
                return cell
                
            case "Number":
                let cell = tableView.dequeueReusableCellWithIdentifier("NumberCell", forIndexPath: indexPath) as! TaskTemplateParameterCellNumber
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self
                
                if taskTemplateParameterFormItem.SelectedItem != nil
                {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }
                cell.Answer.enabled = taskTemplateParameterFormItem.Enabled
                return cell
                
            case "Reference Data":
                let cell = tableView.dequeueReusableCellWithIdentifier("DropdownCell", forIndexPath: indexPath) as! TaskTemplateParameterCellDropdown
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour
                
                var dropdownData: [String] = []
                
                dropdownData.append(PleaseSelect)
                dropdownData.appendContentsOf( ModelUtility.getInstance().GetLookupList(taskTemplateParameter.ReferenceDataType!, ExtendedReferenceDataType: taskTemplateParameter.ReferenceDataExtendedType))
                dropdownData.append(NotApplicable)
                
                cell.AnswerSelector.restorationIdentifier = taskTemplateParameter.RowId
                cell.AnswerSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                cell.AnswerSelector.setLabelFont(UIFont.systemFontOfSize(17))
                cell.AnswerSelector.setTableFont(UIFont.systemFontOfSize(17))
                cell.AnswerSelector.options = dropdownData.map { KFPopupSelector.Option.Text(text: $0) }

                var selectedItem: Int = 0
                
                if taskTemplateParameterFormItem.SelectedItem != nil
                {
                    var count: Int = 0
                    for value in dropdownData
                    {
                        if value == taskTemplateParameterFormItem.SelectedItem
                        {
                            selectedItem = count
                            break
                        }
                        count += 1
                    }

                }

                cell.AnswerSelector.selectedIndex = selectedItem
                cell.AnswerSelector.unselectedLabelText = PleaseSelect
                cell.AnswerSelector.displaySelectedValueInLabel = true
                if(taskTemplateParameter.ParameterName == Accessible)
                {
                    cell.AnswerSelector.enabled = true
                }
                else
                {
                    cell.AnswerSelector.enabled = taskTemplateParameterFormItem.Enabled
                }
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("FreetextCell", forIndexPath: indexPath) as! TaskTemplateParameterCellFreetext
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self
                
                if taskTemplateParameterFormItem.SelectedItem != nil
                {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }
                
                return cell
            }

        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //need to work out here what type of cell so that we can return the correct height
        //nope all are fixed height now
        return 68
    }
    
    //MARK: Control handling
    
    @IBAction func AnswerPopupChanged(sender: KFPopupSelector) {
        
        if let thisTaskTemplateParameterId: String = sender.restorationIdentifier
        {
            if let thisTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[thisTaskTemplateParameterId]
            {
                //record the selected value
                if (thisTaskTemplateParameterFormItem.SelectedItem != sender.selectedValue)
                {
                    thisTaskTemplateParameterFormItem.SelectedItem = sender.selectedValue
                    
                    //start up any dependent controls
                    for currentTaskTemplateParameterFormItem in thisTaskTemplateParameterFormItem.Dependencies
                    {
                        if (currentTaskTemplateParameterFormItem.TemplateParameter.PredecessorTrueValue == sender.selectedValue)
                        {
                            currentTaskTemplateParameterFormItem.Enabled = true
                            EnableControl(currentTaskTemplateParameterFormItem.TemplateParameter.RowId, enabled: true)
                            currentTaskTemplateParameterFormItem.SelectedItem = nil
                            SetParameterValue(currentTaskTemplateParameterFormItem.TemplateParameter.RowId, value: nil)
                        }
                        else
                        {
                            currentTaskTemplateParameterFormItem.Enabled = false
                            EnableControl(currentTaskTemplateParameterFormItem.TemplateParameter.RowId, enabled: false)
                            currentTaskTemplateParameterFormItem.SelectedItem =  NotApplicable
                            SetParameterValue(currentTaskTemplateParameterFormItem.TemplateParameter.RowId, value: NotApplicable)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 1
        {
            currentTemperatureControl = textField
            startProbeTimer(1)
        }
        self.addDoneButtonOnKeyboard(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1
        {
            stopProbeTimer()
        }
        if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[textField.restorationIdentifier!]
        {
            currentTaskTemplateParameterFormItem.SelectedItem = textField.text
        }
        textField.resignFirstResponder()
    }
    
    //MARK: UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.addDoneButtonOnKeyboard(textView)
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[textView.restorationIdentifier!]
        {
            currentTaskTemplateParameterFormItem.SelectedItem = textView.text
        }
        textView.resignFirstResponder()
    }
    
    @IBOutlet var BluetoothButton: UIBarButtonItem!

    //MARK: Actions
    
    @IBAction func CancelPressed(sender: UIBarButtonItem) {
        let userPrompt: UIAlertController = UIAlertController(title: "Leave task?", message: "Are you sure you want to leave this task?  Any unsaved data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
        //the cancel action
        userPrompt.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler: nil))
        
        //the destructive option
        userPrompt.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Destructive,
            handler: self.LeaveTask))
        
        presentViewController(userPrompt, animated: true, completion: nil)
    }
    
    func LeaveTask (actionTarget: UIAlertAction) {
        Session.CodeScanned = nil
        EAController.sharedController().callBack = nil
        self.navigationController?.popViewControllerAnimated(true)
    }

    func Validate() -> Bool{
        var valid: Bool = true;

        for (_,taskTemplateParameterFormItem) in taskTemplateParameterFormItems
        {
            let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItem.TemplateParameter
            if !( (taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "None")
                || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "None")
                || (taskTemplateParameter.ParameterName == "RemoveAsset")
                || (taskTemplateParameter.ParameterName == "AlternateAssetCode")
                || ((taskTemplateParameter.ParameterName.hasPrefix("Add") && taskTemplateParameter.ParameterName.hasSuffix("Notes"))))
            {
                let value: String? = GetParameterValue(taskTemplateParameter.RowId)
                if (value == nil || value == String() || value == PleaseSelect)
                {
                    taskTemplateParameterFormItem.LabelColour = UIColor.redColor()
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: taskTemplateParameterFormItem.LabelColour)
                    valid = false
                }
                else
                {
                    taskTemplateParameterFormItem.LabelColour = UIColor.whiteColor()
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: taskTemplateParameterFormItem.LabelColour)
                }
            }
        }
        return valid
    }
   
    func GetParameterValue(taskTemplateParameterId: String) -> String?
    {
        return taskTemplateParameterFormItems[taskTemplateParameterId]?.SelectedItem
    }
    
    func SetParameterValue(taskTemplateParameterId: String, value: String?)
    {
        for tableCell in tableView.visibleCells
        {
            if tableCell.restorationIdentifier == taskTemplateParameterId
            {
                let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItems[taskTemplateParameterId]!.TemplateParameter
                
                switch (taskTemplateParameter.ParameterType)
                {
                    
                case "Freetext":
                    let cell: TaskTemplateParameterCellFreetext = tableCell as! TaskTemplateParameterCellFreetext
                    cell.Answer.text = value
                    return
                    
                    
                case "Number":
                    if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                    {
                        let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature
                        cell.Answer.text = value
                    }
                    else
                    {
                        let cell: TaskTemplateParameterCellNumber = tableCell as! TaskTemplateParameterCellNumber
                        cell.Answer.text = value
                    }
                    return
                    
                case"Reference Data":

                    let cell: TaskTemplateParameterCellDropdown = tableCell as! TaskTemplateParameterCellDropdown
                    let options: [KFPopupSelector.Option] = cell.AnswerSelector.options
                    if (value != nil)
                    {
                        for index in 0...options.count - 1
                        {
                            if (String(options[index])  == "Text(\"" + value! + "\")")
                            {
                                if (cell.AnswerSelector.selectedIndex != index)
                                {
                                    cell.AnswerSelector.selectedIndex = index
                                }
                                return
                            }
                        }
                    }
                    else
                    {
                        cell.AnswerSelector.selectedIndex = 0
                    }
                    
                    return
                    
                default:
                    return
                }
            }
        }
    }
    
    func EnableControl(taskTemplateParameterId: String, enabled: Bool)
    {
        for tableCell in tableView.visibleCells
        {
            if tableCell.restorationIdentifier == taskTemplateParameterId
            {
                let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItems[taskTemplateParameterId]!.TemplateParameter
                
                switch (taskTemplateParameter.ParameterType)
                {
                    
                case "Freetext":
                    let cell: TaskTemplateParameterCellFreetext = tableCell as! TaskTemplateParameterCellFreetext
                    cell.Answer.enabled = enabled
                    return
                    
                    
                case "Number":
                    if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                    {
                        let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature
                        cell.Answer.enabled = enabled
                    }
                    else
                    {
                        let cell: TaskTemplateParameterCellNumber = tableCell as! TaskTemplateParameterCellNumber
                        cell.Answer.enabled = enabled
                    }
                    return
                    
                case"Reference Data":
                    let cell: TaskTemplateParameterCellDropdown = tableCell as! TaskTemplateParameterCellDropdown
                    cell.AnswerSelector.enabled = enabled
                    return
                    
                default:
                    return
                }
            }
        }
    }
    
    func SetCellLabelColour(taskTemplateParameterId: String, colour: UIColor)
    {
        for tableCell in tableView.visibleCells
        {
            if tableCell.restorationIdentifier == taskTemplateParameterId
            {
                let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameterFormItems[taskTemplateParameterId]!.TemplateParameter
                
                switch (taskTemplateParameter.ParameterType)
                {
                
                    case "Freetext":
                        let cell: TaskTemplateParameterCellFreetext = tableCell as! TaskTemplateParameterCellFreetext
                        cell.Question.textColor = colour
                        return

                        
                    case "Number":
                        if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                        {
                            let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature
                            cell.Question.textColor = colour
                        }
                        else
                        {
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
    
    
    @IBAction func DonePressed(sender: UIBarButtonItem) {
        //do all the vlaidation
        if (!Validate())
        {
            let userPrompt: UIAlertController = UIAlertController(title: "Incomplete task!", message: "Please complete the fields highlighted with red.", preferredStyle: UIAlertControllerStyle.Alert)
            
            //the cancel action
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: nil))
            
            presentViewController(userPrompt, animated: true, completion: nil)
            
            return
        }

        let now = NSDate()
        
        
        //add the removea asset and alternate asset code parameters
        var currentTaskParameter: TaskParameter = TaskParameter()
        currentTaskParameter.RowId = NSUUID().UUIDString
        currentTaskParameter.CreatedBy = Session.OperativeId!
        currentTaskParameter.CreatedOn = now
        currentTaskParameter.TaskId = Session.TaskId!
        currentTaskParameter.TaskTemplateParameterId = removeAssetParameter.RowId
        currentTaskParameter.ParameterName = removeAssetParameter.ParameterName
        currentTaskParameter.ParameterType = removeAssetParameter.ParameterType
        currentTaskParameter.ParameterDisplay = removeAssetParameter.ParameterDisplay
        currentTaskParameter.Collect = removeAssetParameter.Collect
        currentTaskParameter.ParameterValue = (RemoveAsset.on ? "true" : "false")
        ModelManager.getInstance().addTaskParameter(currentTaskParameter)

        currentTaskParameter = TaskParameter()
        currentTaskParameter.RowId = NSUUID().UUIDString
        currentTaskParameter.CreatedBy = Session.OperativeId!
        currentTaskParameter.CreatedOn = now
        currentTaskParameter.TaskId = Session.TaskId!
        currentTaskParameter.TaskTemplateParameterId = alternateAssetCodeParameter.RowId
        currentTaskParameter.ParameterName = alternateAssetCodeParameter.ParameterName
        currentTaskParameter.ParameterType = alternateAssetCodeParameter.ParameterType
        currentTaskParameter.ParameterDisplay = alternateAssetCodeParameter.ParameterDisplay
        currentTaskParameter.Collect = alternateAssetCodeParameter.Collect
        currentTaskParameter.ParameterValue = AlternateAssetCode.text!
        ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        
        //commit the vales
        for taskTemplateParameter in formTaskTemplateParameters
        {
            currentTaskParameter = TaskParameter()
            currentTaskParameter.RowId = NSUUID().UUIDString
            currentTaskParameter.CreatedBy = Session.OperativeId!
            currentTaskParameter.CreatedOn = now
            currentTaskParameter.TaskId = Session.TaskId!
            currentTaskParameter.TaskTemplateParameterId = taskTemplateParameter.RowId
            currentTaskParameter.ParameterName = taskTemplateParameter.ParameterName
            currentTaskParameter.ParameterType = taskTemplateParameter.ParameterType
            currentTaskParameter.ParameterDisplay = taskTemplateParameter.ParameterDisplay
            currentTaskParameter.Collect = taskTemplateParameter.Collect
            currentTaskParameter.ParameterValue = GetParameterValue(currentTaskParameter.TaskTemplateParameterId!)!
            ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        }
        
        
        //add the additional notes parameter
        currentTaskParameter = TaskParameter()
        currentTaskParameter.RowId = NSUUID().UUIDString
        currentTaskParameter.CreatedBy = Session.OperativeId!
        currentTaskParameter.CreatedOn = now
        currentTaskParameter.TaskId = Session.TaskId!
        currentTaskParameter.TaskTemplateParameterId = additionalNotesParameter.RowId
        currentTaskParameter.ParameterName = additionalNotesParameter.ParameterName
        currentTaskParameter.ParameterType = additionalNotesParameter.ParameterType
        currentTaskParameter.ParameterDisplay = additionalNotesParameter.ParameterDisplay
        currentTaskParameter.Collect = additionalNotesParameter.Collect
        currentTaskParameter.ParameterValue = AdditionalNotes.text
        ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        
        //update the task
        task.LastUpdatedBy = Session.OperativeId!
        task.LastUpdatedOn = now
        task.CompletedDate = now
        task.Status = "Complete"

        ModelManager.getInstance().updateTask(task)
        
        Utility.SendTasks(self.navigationController!, HUD: nil)
        Session.CodeScanned = nil
        EAController.sharedController().callBack = nil
        
        //close the view
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - Scancode
    
    func NewScancode(){
        if (Session.CodeScanned != nil)
        {
            AlternateAssetCode.text = Session.CodeScanned!
        }
    }
    
    //MARK: - Probe
    
    func readingAndDisplaying()
    {
        if ProbeProperties.isBlueThermConnected()
        {
            currentReading = ProbeProperties.sensor1Reading()
        }
        else
        {
            currentReading = nil
        }
        
        //set the value on the control with focus
        currentTemperatureControl?.text = currentReading
    }
    
    func startProbeTimer(interval: Int)
    {
        let timerInterval: NSTimeInterval = NSTimeInterval(interval)
        probeTimer.invalidate()
        probeTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: #selector(TaskViewController.doSend), userInfo: nil, repeats: true)
    }
    
    func stopProbeTimer()
    {
        probeTimer.invalidate()
    }
    
    func doSend()
    {
       if EAController.sharedController().callBack == nil
        {
            let eac: EAController =  EAController.sharedController()
            eac.notificationCallBack = self
            
            if !(eac.selectedAccessory.isAwaitingUI || eac.selectedAccessory.isNoneAvailable)
            {
                if (eac.selectedAccessory == nil || !(eac.openSession()))
                {
                    NSLog("No BlueTherm Connected")
                    readingAndDisplaying()
                }
                else
                {
                    NSLog("BlueThermConnected")
                    eac.callBack = self
                }
            }
            else
            {
                readingAndDisplaying()
                return
            }
        }
        EAController.doSend()
    }
    
    // MARK: Probe functions
    func settingTheProbe() {
        print("Set reply")
    }
    
    func probeButtonHasBeenPressed() {
        print("BlueTherm button has been pressed")
        stopProbeTimer()
        currentTemperatureControl?.resignFirstResponder()
    }
    
    func soundtheAlarmInBackground() {
        //displayAlarm
    }
    
    func blueThermConnected() {
        print("BlueTherm has connected")
    }
    
    func bluethermDisconnected() {
        print("BlueTherm has disconnected")
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

