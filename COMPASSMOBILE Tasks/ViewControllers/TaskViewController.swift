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

    //MARK: Variables
    
    var task: Task = Task()
    var asset: Asset = Asset()

    var taskTemplateParameterFormItems: Dictionary<String, TaskTemplateParameterFormItem> = Dictionary<String, TaskTemplateParameterFormItem>()
    var formTaskTemplateParameters: [TaskTemplateParameter] = [TaskTemplateParameter]()
    
    var removeAssetParameter: TaskTemplateParameter = TaskTemplateParameter()
    var alternateAssetCodeParameter: TaskTemplateParameter = TaskTemplateParameter()
    var additionalNotesParameter: TaskTemplateParameter = TaskTemplateParameter()
    
    var taskTemperatureProfiles: Dictionary<String, TemperatureProfile> = Dictionary<String, TemperatureProfile>()
    
    var probeTimer: Timer = Timer()
    
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
    @IBOutlet var TaskTimeTakenStack: UIStackView!
    @IBOutlet var TaskTravelTimeStack: UIStackView!
    @IBOutlet var TaskTimeLabel: UILabel!
    @IBOutlet var TaskTime: UITextField!
    @IBOutlet var TravelTimeLabel: UILabel!
    @IBOutlet var TravelTime: UITextField!

    var HotType: String? = nil
    var ColdType: String? = nil
    
    //MARK: Form load & show
    
    //standard actions
    override func viewDidLoad() {
        super.viewDidLoad()
        Session.CodeScanned = nil
        
        task = ModelManager.getInstance().getTask(Session.TaskId!)!
        
        if (task.AssetId != nil)
        {
           //get the hot cold details for the task
            let asset: Asset? = ModelManager.getInstance().getAsset(task.AssetId!)
            if (asset != nil)
            {
                HotType = asset!.HotType
                ColdType = asset!.ColdType
            }
            else
            {
                //asset is missing - need to notify user to resync assets
                let userPrompt: UIAlertController = UIAlertController(title: "Missing asset", message: "The asset record for this task is missing", preferredStyle: UIAlertControllerStyle.alert)
                
                //the destructive option
                userPrompt.addAction(UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.destructive,
                    handler: self.LeaveTask))
                
                present(userPrompt, animated: true, completion: nil)
            }
            
            //are we recording task times
            TaskTimeTakenStack.isHidden = !Session.UseTaskTiming
            TaskTravelTimeStack.isHidden = !Session.UseTaskTiming
        }
        
        AssetType.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!) + " - " + ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!)
        if (task.TaskName == RemedialTask)
        {
            TaskName.text = RemedialTask
        }
        else
        {
            TaskName.text  = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup)
        }

        if let assetNumber: String = task.AssetNumber {AssetNumber.text = assetNumber} else {AssetNumber.text = "no asset"}
        TaskReference.text = task.TaskRef
        
        //get the the parameters for the table
        if (TaskName.text != RemedialTask)
        {
            let taskTemplateId = task.TaskTemplateId
            
            var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            criteria["TaskTemplateId"] = taskTemplateId as AnyObject?
            
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
                formTaskTemplateParameters.remove(at: 1)
                
                removeAssetParameter = formTaskTemplateParameters[0]
                formTaskTemplateParameters.remove(at: 0)
            }
        }
        
        AdditionalNotes.delegate = self
        AlternateAssetCode.delegate = self
        TaskTime.delegate = self
        TravelTime.delegate = self
        
        //reload the table
        taskParameterTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (Session.GettingProfile)
        {
            if (Session.CurrentProfileControl != nil && !Session.CancelFromProfile)
            {
                taskTemperatureProfiles[Session.CurrentProfileControl!.restorationIdentifier!] = Session.Profile
                Session.CurrentProfileControl!.text = Session.Profile?.ToStringForDisplay()
                Session.CurrentProfileControl = nil
                Session.Profile = nil
                Session.GettingProfile = false
            }
            Session.CancelFromProfile = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        taskParameterTable.allowsSelection = false
        
        NewScancode()
        
        if EAController.shared().callBack == nil
        {
            let eac: EAController =  EAController.shared()
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
            EAController.shared().notificationCallBack = self
            EAController.shared().callBack = self
        }
    }

    //MARK: UITableView delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formTaskTemplateParameters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let taskTemplateParameter: TaskTemplateParameter = formTaskTemplateParameters[indexPath.row]
        let taskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[taskTemplateParameter.RowId]!

        var predecessor: String? = nil
        if (taskTemplateParameter.Predecessor != nil)
        {
            predecessor = taskTemplateParameter.Predecessor!
        }
        else
        {
            taskTemplateParameterFormItem.Enabled = true
        }
        
        if (predecessor != nil)
        {
            let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[predecessor!]!
            
            currentTaskTemplateParameterFormItem.Dependencies.append(taskTemplateParameterFormItem)
            
            if (currentTaskTemplateParameterFormItem.SelectedItem == taskTemplateParameter.PredecessorTrueValue)
            {
                taskTemplateParameterFormItem.Enabled = true
            }
            
        }
        
        if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
        {

            let cell = tableView.dequeueReusableCell(withIdentifier: "TemperatureCell", for: indexPath) as! TaskTemplateParameterCellTemperature
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
            cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor
        
            cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
            cell.Answer.delegate = self
            
            
            if taskTemplateParameterFormItem.SelectedItem != nil
            {
                cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
            }
            
            cell.Answer.tag = TemperatureCell
            if (taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "None") || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "None")
            {
                taskTemplateParameterFormItem.Enabled = false
            }
            else
            {
                if ((taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "Hot") || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "Cold") || (taskTemplateParameter.ParameterName == "TemperatureFeedHot") || (taskTemplateParameter.ParameterName == "TemperatureFeedCold"))
                {
                    cell.Answer.isEnabled = (taskTemplateParameterFormItem.Enabled && !Session.UseTemperatureProfile)
                    cell.ProfileButton.isHidden = !Session.UseTemperatureProfile
                    cell.ProfileButton.isEnabled = (taskTemplateParameterFormItem.Enabled && !Session.UseTemperatureProfile)
                    
                    cell.Answer.tag = taskTemplateParameter.ParameterName.contains("Hot") ? TemperatureProfileCellHot : TemperatureProfileCellCold
                    
                    cell.ProfileButton.tag = cell.Answer.tag
                    
                }
                else
                {
                    cell.Answer.isEnabled = taskTemplateParameterFormItem.Enabled
                    cell.ProfileButton.isHidden = true
                    cell.ProfileButton.isEnabled = taskTemplateParameterFormItem.Enabled
                }
            }
            
            return cell
        }
        else
        {
            switch taskTemplateParameter.ParameterType
            {
            case "Freetext":
                let cell = tableView.dequeueReusableCell(withIdentifier: "FreetextCell", for: indexPath) as! TaskTemplateParameterCellFreetext
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                if taskTemplateParameterFormItem.SelectedItem != nil
                {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }
                cell.Answer.isEnabled = taskTemplateParameterFormItem.Enabled
                return cell
                
            case "Number":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath) as! TaskTemplateParameterCellNumber
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor

                
                if taskTemplateParameterFormItem.SelectedItem != nil
                {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }
                cell.Answer.isEnabled = taskTemplateParameterFormItem.Enabled
                return cell
                
            case "Reference Data":
                let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath) as! TaskTemplateParameterCellDropdown
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour
                
                var dropdownData: [String] = []
                
                dropdownData.append(PleaseSelect)
                dropdownData.append(contentsOf: ModelUtility.getInstance().GetLookupList(taskTemplateParameter.ReferenceDataType!, ExtendedReferenceDataType: taskTemplateParameter.ReferenceDataExtendedType))
                dropdownData.append(NotApplicable)
                
                cell.AnswerSelector.restorationIdentifier = taskTemplateParameter.RowId
                cell.AnswerSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                cell.AnswerSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
                cell.AnswerSelector.setTableFont(UIFont.systemFont(ofSize: 17))
                cell.AnswerSelector.options = dropdownData.map { KFPopupSelector.Option.text(text: $0) }
                cell.AnswerSelector.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor


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
                    cell.AnswerSelector.isEnabled = true
                }
                else
                {
                    cell.AnswerSelector.isEnabled = taskTemplateParameterFormItem.Enabled
                }
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FreetextCell", for: indexPath) as! TaskTemplateParameterCellFreetext
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Question.textColor =  taskTemplateParameterFormItem.LabelColour

                cell.Answer.restorationIdentifier = taskTemplateParameter.RowId
                cell.Answer.delegate = self
                cell.Answer.backgroundColor = taskTemplateParameterFormItem.ControlBackgroundColor
                
                if taskTemplateParameterFormItem.SelectedItem != nil
                {
                    cell.Answer.text = taskTemplateParameterFormItem.SelectedItem
                }
                
                return cell
            }

        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //need to work out here what type of cell so that we can return the correct height
        //nope all are fixed height now
        return 68
    }
    
    //MARK: Control handling
    
    @IBAction func AnswerPopupChanged(_ sender: KFPopupSelector) {
        
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
    
    
    //MARK: - segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TemperatureProfileSegue")
        {
            if (sender is UIButton)
            {
                let cell: TaskTemplateParameterCellTemperature = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellTemperature
                Session.CurrentProfileControl = cell.Answer
            }
            else
            {
                Session.CurrentProfileControl = sender as? UITextField
            }
         
            let temperatureProfileViewController = segue.destination as! TemperatureProfileViewController
            temperatureProfileViewController.hot = (Session.CurrentProfileControl!.tag == TemperatureProfileCellHot)
            Session.GettingProfile = true
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (Session.TimerRunning)
        {
            return false
        }
        
        if (identifier == "TemperatureProfileSegue")
        {
            if (sender is UIButton)
            {
                let cell: TaskTemplateParameterCellTemperature = (sender as! UIButton).superview!.superview as! TaskTemplateParameterCellTemperature
                if (cell.Answer.text != String())
                {
                    let userPrompt: UIAlertController = UIAlertController(title: "Overwrite Profile?", message: "Are you sure you want to overwrite the current profile?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                        action in
                        //do nothing
                    }

                    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive) {
                        action in
                        self.performSegue(withIdentifier: "TemperatureProfileSegue", sender: sender)
                    }

                    userPrompt.addAction(cancelAction)
                    userPrompt.addAction(OKAction)
                    
                    present(userPrompt, animated: true, completion: nil)
                }
            }
        }
        return true
    }
    
   
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (Session.TimerRunning)
        {
            return false
        }
        
        if (textField.tag >= TemperatureProfileCellHot && Session.UseTemperatureProfile)
        {
            if (textField.text != String())
            {
                let userPrompt: UIAlertController = UIAlertController(title: "Overwrite Profile?", message: "Are you sure you want to overwrite the current profile?", preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                    action in
                    //do nothing
                }
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive) {
                    action in
                    self.performSegue(withIdentifier: "TemperatureProfileSegue", sender: textField)
                }
                
                userPrompt.addAction(cancelAction)
                userPrompt.addAction(OKAction)
                
                present(userPrompt, animated: true, completion: nil)
            }
            else
            {
                self.performSegue(withIdentifier: "TemperatureProfileSegue", sender: textField)
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
        if (textField.tag >= TemperatureCell && Session.BluetoothProbeConnected)
        {
            if (!Session.TimerRunning)
            {
                Session.CurrentTemperatureControl = textField
                Session.CurrentTemperatureControl!.isEnabled = false
                Session.CurrentTemperatureControl!.backgroundColor = UIColor.green
                startProbeTimer(0.25)
            }
        }
        self.addDoneButtonOnKeyboard(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag >= TemperatureCell && Session.BluetoothProbeConnected)
        {
            stopProbeTimer()
            Session.CurrentTemperatureControl!.isEnabled = true
            Session.CurrentTemperatureControl!.backgroundColor = UIColor.white
        }
        if (textField.restorationIdentifier != nil)
        {
            if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[textField.restorationIdentifier!]
            {
                currentTaskTemplateParameterFormItem.SelectedItem = textField.text
            }
        }
        textField.resignFirstResponder()
    }
    
    //MARK: UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if (Session.TimerRunning)
        {
            return false
        }
        self.addDoneButtonOnKeyboard(textView)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.restorationIdentifier != nil)
        {
            if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[textView.restorationIdentifier!]
            {
                currentTaskTemplateParameterFormItem.SelectedItem = textView.text
            }
        }
        textView.resignFirstResponder()
    }
    
    @IBOutlet var BluetoothButton: UIBarButtonItem!

    
    //MARK: Actions
    
    @IBAction func CancelPressed(_ sender: UIBarButtonItem) {
        if(Session.TimerRunning)
        {
            let userPrompt: UIAlertController = UIAlertController(title: "Probe Active", message: "You have an active connection to the probe.  Please close the connection before proceeding", preferredStyle: UIAlertControllerStyle.alert)
  
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.cancel,
                handler: nil))

            present(userPrompt, animated: true, completion: nil)
        }
        else
        {
            let userPrompt: UIAlertController = UIAlertController(title: "Leave task?", message: "Are you sure you want to leave this task?  Any unsaved data will be lost.", preferredStyle: UIAlertControllerStyle.alert)
            
            //the cancel action
            userPrompt.addAction(UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.cancel,
                handler: nil))
            
            //the destructive option
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.destructive,
                handler: self.LeaveTask))
            
            present(userPrompt, animated: true, completion: nil)
        }
    }
    
    func LeaveTask (_ actionTarget: UIAlertAction) {
        Session.CodeScanned = nil
        Session.TaskId = nil
        EAController.shared().callBack = nil
        _ = self.navigationController?.popViewController(animated: true)
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
                
                var value: String? = GetParameterValue(taskTemplateParameter.RowId)
                if (value == nil && taskTemperatureProfiles.keys.contains(taskTemplateParameter.RowId))
                {
                    value = taskTemperatureProfiles[taskTemplateParameter.RowId]!.ToString()
                }
                
                if (value == nil || value == String() || value == PleaseSelect)
                {
                    
                    taskTemplateParameterFormItem.LabelColour = UIColor.red
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    
                    taskTemplateParameterFormItem.ControlBackgroundColor = UIColor.red
                    SetCellBackgroundColour(taskTemplateParameter.RowId, colour: UIColor.red)
                    
                    valid = false
                }
                else
                {
                    taskTemplateParameterFormItem.LabelColour = UIColor.white
                    SetCellLabelColour(taskTemplateParameter.RowId, colour: UIColor.white)
                    
                    taskTemplateParameterFormItem.ControlBackgroundColor = UIColor.white
                    SetCellBackgroundColour(taskTemplateParameter.RowId, colour: UIColor.white)
                    
                }
            }
        }
        
        if Session.UseTaskTiming
        {
            let value: String? = TaskTime.text
            if (value == nil || value == String())
            {
                TaskTimeLabel.textColor = UIColor.red
                valid = false
            }
            else
            {
                TaskTimeLabel.textColor = UIColor.white
            }
            
            let value2: String? = TravelTime.text
            if (value2 == nil || value2 == String())
            {
                TravelTimeLabel.textColor = UIColor.red
                valid = false
            }
            else
            {
                TravelTimeLabel.textColor = UIColor.white
            }
        }
        
        return valid
    }
   
    func GetParameterValue(_ taskTemplateParameterId: String) -> String?
    {
        return taskTemplateParameterFormItems[taskTemplateParameterId]?.SelectedItem
    }
    
    func SetParameterValue(_ taskTemplateParameterId: String, value: String?)
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
                            if (String(describing: options[index])  == "Text(\"" + value! + "\")")
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
    
    func EnableControl(_ taskTemplateParameterId: String, enabled: Bool)
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
                    cell.Answer.isEnabled = enabled
                    return
                    
                    
                case "Number":
                    if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                    {
                        let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature
                        
                        if (
                                (taskTemplateParameter.ParameterName == "TemperatureHot" && HotType == "Hot")
                                || (taskTemplateParameter.ParameterName == "TemperatureCold" && ColdType == "Cold")
                                || (taskTemplateParameter.ParameterName == "TemperatureFeedHot")
                                || (taskTemplateParameter.ParameterName == "TemperatureFeedCold")
                            )
                        {
                            cell.Answer.isEnabled = enabled //&& !Session.UseTemperatureProfile
                            cell.ProfileButton.isHidden = !Session.UseTemperatureProfile
                            cell.ProfileButton.isEnabled = enabled && Session.UseTemperatureProfile
                        }
                        else
                        {
                            cell.Answer.isEnabled = enabled
                            cell.ProfileButton.isHidden = true
                            cell.ProfileButton.isEnabled = false
                        }
                    }
                    else
                    {
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
    
    func SetCellLabelColour(_ taskTemplateParameterId: String, colour: UIColor)
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
    
    func SetCellBackgroundColour(_ taskTemplateParameterId: String, colour: UIColor)
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
                    cell.Answer.backgroundColor = colour
                    return
                    
                    
                case "Number":
                    if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
                    {
                        let cell: TaskTemplateParameterCellTemperature = tableCell as! TaskTemplateParameterCellTemperature
                        cell.Answer.backgroundColor = colour
                    }
                    else
                    {
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
        if(Session.TimerRunning)
        {
            let userPrompt: UIAlertController = UIAlertController(title: "Probe Active", message: "You have an active connection to the probe.  Please close the connection before proceeding", preferredStyle: UIAlertControllerStyle.alert)
            
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.cancel,
                handler: nil))
            
            present(userPrompt, animated: true, completion: nil)
        }
        else
        {
            //do all the vlaidation
            if (!Validate())
            {
                let userPrompt: UIAlertController = UIAlertController(title: "Incomplete task!", message: "Please complete the fields highlighted with red.", preferredStyle: UIAlertControllerStyle.alert)
                
                //the cancel action
                userPrompt.addAction(UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil))
                
                present(userPrompt, animated: true, completion: nil)
                
                return
            }

            let now = Date()
            
            
            //add the removea asset and alternate asset code parameters
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
            
            //commit the vales
            for taskTemplateParameter in formTaskTemplateParameters
            {
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
                if (taskTemperatureProfiles.keys.contains(taskTemplateParameter.RowId))
                {
                    currentTaskParameter.ParameterValue = taskTemperatureProfiles[taskTemplateParameter.RowId]!.ToString()
                }
                else
                {
                    currentTaskParameter.ParameterValue = GetParameterValue(currentTaskParameter.TaskTemplateParameterId!)!
                }
                _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
            }
            
            //add the additional notes parameter
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
            
            //update the task
            task.LastUpdatedBy = Session.OperativeId!
            task.LastUpdatedOn = now
            task.CompletedDate = now
            if Session.UseTaskTiming
            {
                task.ActualDuration = Int(TaskTime.text!)
                task.TravelDuration = Int(TravelTime.text!)
            }
            task.Status = "Complete"

            _ = ModelManager.getInstance().updateTask(task)
            
            Utility.SendTasks(self.navigationController!, HUD: nil)
            Session.CodeScanned = nil
            EAController.shared().callBack = nil
            
            //close the view
            Session.TaskId = nil
            _ = self.navigationController?.popViewController(animated: true)
        }
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
            Session.CurrentReading = ProbeProperties.sensor1Reading()
        }
        else
        {
            Session.CurrentReading = nil
        }
        
        //set the value on the control with focus
        Session.CurrentTemperatureControl?.text = Session.CurrentReading
    }
    
    func startProbeTimer(_ interval: Double)
    {
        
        let timerInterval: TimeInterval = TimeInterval(interval)
        probeTimer.invalidate()
        probeTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(TaskViewController.doSend), userInfo: nil, repeats: true)
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
        stopProbeTimer()
        if Session.CurrentTemperatureControl != nil
        {
            Session.CurrentTemperatureControl!.backgroundColor = UIColor.white
            Session.CurrentTemperatureControl!.isEnabled = true
            if (Session.CurrentTemperatureControl!.restorationIdentifier != nil)
            {
                if let currentTaskTemplateParameterFormItem: TaskTemplateParameterFormItem = taskTemplateParameterFormItems[Session.CurrentTemperatureControl!.restorationIdentifier!]
                {
                    currentTaskTemplateParameterFormItem.SelectedItem = Session.CurrentTemperatureControl!.text
                }
            }
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
    
    func addDoneButtonOnKeyboard(_ view: UIView?)
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: view, action: #selector(UIResponder.resignFirstResponder))
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

