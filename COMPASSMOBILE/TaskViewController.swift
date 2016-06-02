//
//  TaskViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 20/05/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import Foundation
import UIKit

class Descendant{
    var Id: String = String()
    var TrueValue: String = String()
    var Control: AnyObject? = AnyObject?()
}

class TaskViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate, ETIPassingData, AlertMessageDelegate {

    var task: Task = Task()
    var taskParameters: Dictionary<String, TaskParameter> = Dictionary<String, TaskParameter>()
    var taskTemplateParameters: [TaskTemplateParameter] = [TaskTemplateParameter]()
    
    var descendants: Dictionary<String, [Descendant]> = Dictionary<String, [Descendant]>()
    
    var cells: Dictionary<String, UITableViewCell> = Dictionary<String, UITableViewCell>()
    
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

    //standard actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        task = ModelManager.getInstance().getTask(Session.TaskId!)!
        
        AssetType.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!)
        if(task.TaskName == RemedialTask)
        {
            TaskName.text = RemedialTask
        }
        else
        {
            TaskName.text  = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup)
        }
        Location.text = task.LocationName
        AssetNumber.text = task.AssetNumber
        TaskReference.text = task.TaskRef
        
        //get the the parameters for the table
        if (TaskName.text != RemedialTask)
        {
            let taskTemplateId = task.TaskTemplateId
            
            var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            criteria["TaskTemplateId"] = taskTemplateId
            
            taskTemplateParameters = ModelManager.getInstance().findTaskTemplateParameterList(criteria)
            
            if (taskTemplateParameters.count > 3)
            {
                //additional notes will always be the last record
                taskTemplateParameters.removeLast()
                
                //remove alternate asset code and remove asset
                taskTemplateParameters.removeAtIndex(1)
                taskTemplateParameters.removeAtIndex(0)
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

    @IBAction func AnswerPopupChanged(sender: KFPopupSelector) {
        //print(sender.restorationIdentifier)
        if let currentBody: String = sender.restorationIdentifier
        {
            if(descendants[currentBody] != nil)
            {
                for descendant in descendants[sender.restorationIdentifier!]!
                {
                    if (sender.selectedValue! == descendant.TrueValue)
                    {
                        (descendant.Control as! UIControl).enabled = true
                        switch true
                        {
                        case (descendant.Control is UITextField):
                            let currentTextField: UITextField = descendant.Control as! UITextField
                            currentTextField.text = ""
                            
                        case (descendant.Control is KFPopupSelector):
                            
                            let currentPopup: KFPopupSelector = descendant.Control as! KFPopupSelector
                            currentPopup.unselectedLabelText = "Please select"
                            currentPopup.selectedIndex = 0
                            
                        case (descendant.Control is UITextView):
                            let currentTextView: UITextView = descendant.Control as! UITextView
                            currentTextView.text = ""
                            
                        default:
                            print("This is broken")
                        }                    }
                    else
                    {
                        (descendant.Control as! UIControl).enabled = false
                        switch true
                        {
                        case (descendant.Control is UITextField):
                            let currentTextField: UITextField = descendant.Control as! UITextField
                            currentTextField.text = "Not applicable"
                  
                        case (descendant.Control is KFPopupSelector):
                      
                            let currentPopup: KFPopupSelector = descendant.Control as! KFPopupSelector
                            currentPopup.unselectedLabelText = "Not applicable"
                            currentPopup.selectedIndex = nil
                            
                        case (descendant.Control is UITextView):
                            let currentTextView: UITextView = descendant.Control as! UITextView
                            currentTextView.text = "Not applicable"
                        
                        default:
                            print("This is broken")
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
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1
        {
            stopProbeTimer()
        }
        textField.resignFirstResponder()
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    //MARK: UITableView delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTemplateParameters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameters[indexPath.row]
        
        if (cells[taskTemplateParameter.RowId] == nil )
        {
        
            var predecessor: String? = String?()
            let descendant: Descendant = Descendant()
            
            if taskParameters[taskTemplateParameters[indexPath.row].RowId] == nil
            {
                let currentParameter: TaskParameter = TaskParameter()
                currentParameter.RowId = NSUUID().UUIDString
                currentParameter.TaskId = Session.TaskId!
                currentParameter.TaskTemplateParameterId = taskTemplateParameter.RowId
                currentParameter.ParameterName = taskTemplateParameter.ParameterName
                currentParameter.ParameterType = taskTemplateParameter.ParameterType
                currentParameter.ParameterDisplay = taskTemplateParameter.ParameterDisplay
                currentParameter.Collect = taskTemplateParameter.Collect
                taskParameters[taskTemplateParameters[indexPath.row].RowId] = currentParameter
            }
            
            if (taskTemplateParameter.Predecessor != nil)
            {
                predecessor = taskTemplateParameter.Predecessor!
            }
            
            if (predecessor != nil)
            {
                descendant.Id = taskTemplateParameter.RowId
                descendant.TrueValue = taskTemplateParameter.PredecessorTrueValue!
            }
        
            if taskTemplateParameter.ParameterName.hasPrefix("Temperature") && !taskTemplateParameter.ParameterName.hasSuffix("Set")
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("TemperatureCell", forIndexPath: indexPath) as! TaskTemplateParameterCellTemperature
                cell.restorationIdentifier = taskTemplateParameter.RowId
                cell.Question.text = taskTemplateParameter.ParameterDisplay
                cell.Answer.delegate = self
                
                if (taskParameters[taskTemplateParameters[indexPath.row].RowId] != nil)
                {
                    cell.Answer.text =  taskParameters[taskTemplateParameters[indexPath.row].RowId]!.ParameterValue
                }
                cell.Answer.tag = 1
                
                if (predecessor != nil)
                {
                    descendant.Control = cell.Answer
                    
                    if (descendants[predecessor!] == nil)
                    {
                        descendants[predecessor!] = [Descendant]()
                    }
                    descendants[predecessor!]?.append(descendant)
                }
                cells[taskTemplateParameter.RowId] = cell
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
                    cell.Answer.delegate = self
                    if (taskParameters[taskTemplateParameters[indexPath.row].RowId] != nil)
                    {
                        cell.Answer.text =  taskParameters[taskTemplateParameters[indexPath.row].RowId]!.ParameterValue
                    }
                
                    if (predecessor != nil)
                    {
                        descendant.Control = cell.Answer

                        if (descendants[predecessor!] == nil)
                        {
                            descendants[predecessor!] = [Descendant]()
                        }
                        descendants[predecessor!]?.append(descendant)
                    }
                
                    cells[taskTemplateParameter.RowId] = cell
                    return cell
                    
                case "Number":
                    let cell = tableView.dequeueReusableCellWithIdentifier("NumberCell", forIndexPath: indexPath) as! TaskTemplateParameterCellNumber
                    cell.restorationIdentifier = taskTemplateParameter.RowId
                    cell.Question.text = taskTemplateParameter.ParameterDisplay
                    cell.Answer.delegate = self
                    if (taskParameters[taskTemplateParameters[indexPath.row].RowId] != nil)
                    {
                        cell.Answer.text =  taskParameters[taskTemplateParameters[indexPath.row].RowId]!.ParameterValue
                    }
                   
                    if (predecessor != nil)
                    {
                        descendant.Control = cell.Answer
                        
                        if (descendants[predecessor!] == nil)
                        {
                            descendants[predecessor!] = [Descendant]()
                        }
                        descendants[predecessor!]?.append(descendant)
                    }
                    
                    cells[taskTemplateParameter.RowId] = cell
                    return cell
                    
                case "Reference Data":
                    let cell = tableView .dequeueReusableCellWithIdentifier("DropdownCell", forIndexPath: indexPath) as! TaskTemplateParameterCellDropdown
                    cell.restorationIdentifier = taskTemplateParameter.RowId
                    cell.Question.text = taskTemplateParameter.ParameterDisplay
                    
                    var dropdownData: [String] = []
                    
                    dropdownData.append("Please select")
                    dropdownData.appendContentsOf( ModelUtility.getInstance().GetLookupList(taskTemplateParameter.ReferenceDataType!, ExtendedReferenceDataType: taskTemplateParameter.ReferenceDataExtendedType))

                    var selectedIndex: Int? = 0
                    if (taskParameters[taskTemplateParameters[indexPath.row].RowId] != nil)
                    {
                        var count: Int = 1 //we already have the blank row
                        for dropdownData: String in dropdownData
                        {
                            let currentAnswer: String =  taskParameters[taskTemplateParameters[indexPath.row].RowId]!.ParameterValue
                            if (dropdownData == currentAnswer) { selectedIndex = count }
                            count += 1
                        }
                    }
                    
                    cell.AnswerSelector.restorationIdentifier = taskTemplateParameter.RowId
                    cell.AnswerSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                    cell.AnswerSelector.setLabelFont(UIFont.systemFontOfSize(17))
                    cell.AnswerSelector.setTableFont(UIFont.systemFontOfSize(17))
                    cell.AnswerSelector.options = dropdownData.map { KFPopupSelector.Option.Text(text: $0) }
                    cell.AnswerSelector.selectedIndex = selectedIndex
                    cell.AnswerSelector.unselectedLabelText = "Please select"
                    cell.AnswerSelector.displaySelectedValueInLabel = true

                    if (predecessor != nil)
                    {
                        descendant.Control = cell.AnswerSelector
                        
                        if (descendants[predecessor!] == nil)
                        {
                            descendants[predecessor!] = [Descendant]()
                        }
                        descendants[predecessor!]?.append(descendant)
                    }
                    
                    cells[taskTemplateParameter.RowId] = cell
                    return cell

                default:
                    let cell = tableView.dequeueReusableCellWithIdentifier("FreetextCell", forIndexPath: indexPath) as! TaskTemplateParameterCellFreetext
                    cell.restorationIdentifier = taskTemplateParameter.RowId
                    cell.Question.text = taskTemplateParameter.ParameterDisplay

                    if (predecessor != nil)
                    {
                        descendant.Control = cell.Answer
                        
                        if (descendants[predecessor!] == nil)
                        {
                            descendants[predecessor!] = [Descendant]()
                        }
                        descendants[predecessor!]?.append(descendant)
                    }
                    
                    cells[taskTemplateParameter.RowId] = cell
                    return cell
                }
            }
        }
        else
        {
            return cells[taskTemplateParameter.RowId]!
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //need to work out here what type of cell so that we can return the correct height
        //nope all are fixed height now
        return 68
    }
    
    @IBOutlet var BluetoothButton: UIBarButtonItem!
    //MARK: Actions
    
    
    @IBAction func CancelPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func DonePressed(sender: UIBarButtonItem) {
        //do all the vlaidation
        
        let now = NSDate()
       
        //commit the vales
        for (_,currentTaskParameter) in taskParameters
        {
            currentTaskParameter.CreatedBy = Session.OperativeId!
            currentTaskParameter.CreatedOn = now
            ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        }
        
        //update the task

        task.LastUpdatedBy = Session.OperativeId!
        task.LastUpdatedOn = now
        task.CompletedDate = now
        task.Status = "Complete"

        ModelManager.getInstance().updateTask(task)
        
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
}

