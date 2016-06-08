//
//  RemedialTaskViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 08/06/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import Foundation
import UIKit

class RemedialTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate {
    
    var task: Task = Task()
    var taskParameters: [TaskParameter] = [TaskParameter]()

    //header fields
    @IBOutlet var AssetType: UILabel!
    @IBOutlet var TaskName: UILabel!
    @IBOutlet var Location: UILabel!
    @IBOutlet var TaskReference: UILabel!
    @IBOutlet var AssetNumber: UILabel!

    @IBOutlet var WorkInstruction: UITextView!
    @IBOutlet var WorkCarriedOut: UITextView!
    
    @IBOutlet var WorkCarriedOutLabel: UILabel!
    @IBOutlet var WorkCompleted: UISwitch!
    @IBOutlet var RemoveAsset: UISwitch!
    
    @IBOutlet var AlternateAssetCode: UITextField!
    
    //standard actions
    override func viewDidLoad() {
        super.viewDidLoad()
        Session.CodeScanned = nil
        
        task = ModelManager.getInstance().getTask(Session.TaskId!)!
        
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
        

        var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        criteria["TaskId"] = task.RowId
        criteria["ParameterName"] = "Instruction"
        
        taskParameters = ModelManager.getInstance().findTaskParameterList(criteria)

        if (taskParameters.count > 0)
        {
            for taskParameter: TaskParameter in taskParameters
        {
            WorkInstruction.text = taskParameter.ParameterValue
            WorkInstruction.editable = false
            }
        }
        else
        {
            WorkInstruction.text = "no instuctions"
            WorkInstruction.editable = false
        }
        
        WorkCarriedOut.delegate = self
        AlternateAssetCode.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NewScancode()
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.addDoneButtonOnKeyboard(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    //MARK: UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.addDoneButtonOnKeyboard(textView)
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
    
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
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func Validate() -> Bool{
        var valid: Bool = true;
        

        let value: String? = WorkCarriedOut.text
        if (value == nil || value == String() )
        {
            WorkCarriedOutLabel.textColor = UIColor.redColor()
            valid = false
        }
        else
        {
            WorkCarriedOutLabel.textColor = UIColor.whiteColor()
        }

        return valid
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
        currentTaskParameter.TaskTemplateParameterId = nil
        currentTaskParameter.ParameterName = "WorkCarriedOut"
        currentTaskParameter.ParameterType = "Freetext"
        currentTaskParameter.ParameterDisplay = "Work Carried Out"
        currentTaskParameter.Collect = true
        currentTaskParameter.ParameterValue = WorkCarriedOut.text
        ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        
        currentTaskParameter = TaskParameter()
        currentTaskParameter.RowId = NSUUID().UUIDString
        currentTaskParameter.CreatedBy = Session.OperativeId!
        currentTaskParameter.CreatedOn = now
        currentTaskParameter.TaskId = Session.TaskId!
        currentTaskParameter.TaskTemplateParameterId = nil
        currentTaskParameter.ParameterName = "WorkCompleted"
        currentTaskParameter.ParameterType = "Reference Data"
        currentTaskParameter.ParameterDisplay = "Work Completed"
        currentTaskParameter.Collect = true
        currentTaskParameter.ParameterValue = (WorkCompleted.on ? "Yes" : "No")
        ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        
        currentTaskParameter = TaskParameter()
        currentTaskParameter.RowId = NSUUID().UUIDString
        currentTaskParameter.CreatedBy = Session.OperativeId!
        currentTaskParameter.CreatedOn = now
        currentTaskParameter.TaskId = Session.TaskId!
        currentTaskParameter.TaskTemplateParameterId = nil
        currentTaskParameter.ParameterName = "RemoveAsset"
        currentTaskParameter.ParameterType = "Reference Data"
        currentTaskParameter.ParameterDisplay = "Remove Asset"
        currentTaskParameter.Collect = true
        currentTaskParameter.ParameterValue = (RemoveAsset.on ? "Yes" : "No")
        ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        
        
        if (AlternateAssetCode.text != nil)
        {
            currentTaskParameter = TaskParameter()
            currentTaskParameter.RowId = NSUUID().UUIDString
            currentTaskParameter.CreatedBy = Session.OperativeId!
            currentTaskParameter.CreatedOn = now
            currentTaskParameter.TaskId = Session.TaskId!
            currentTaskParameter.TaskTemplateParameterId = nil
            currentTaskParameter.ParameterName = "AlternateAssetCode"
            currentTaskParameter.ParameterType = "Freetext"
            currentTaskParameter.ParameterDisplay = "Alternate Asset Code"
            currentTaskParameter.Collect = true
            currentTaskParameter.ParameterValue = AlternateAssetCode.text!
            ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        }
        
        //update the task
        task.LastUpdatedBy = Session.OperativeId!
        task.LastUpdatedOn = now
        task.CompletedDate = now
        task.Status = "Complete"
        
        ModelManager.getInstance().updateTask(task)
        
        Utility.SendTasks(self.navigationController!, HUD: nil)
        Session.CodeScanned = nil
        
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

