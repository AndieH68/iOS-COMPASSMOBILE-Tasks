//
//  RemedialTaskViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 08/06/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class RemedialTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate {
    
    var task: Task = Task()
    var taskParameters: [TaskParameter] = [TaskParameter]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        registerForKeyboardNotifications()

        Session.CodeScanned = nil
        
        task = ModelManager.getInstance().getTask(Session.TaskId!)!
        
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
        if (task.TaskName == RemedialTask)
        {
            TaskName.text = RemedialTask
        }
        else
        {
            TaskName.text  = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup)
        }
        
        Location.text = task.LocationName
        if let assetNumber: String = task.AssetNumber {AssetNumber.text = assetNumber} else {AssetNumber.text = "no asset"}
        TaskReference.text = task.TaskRef
        

        var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        criteria["TaskId"] = task.RowId as AnyObject?
        criteria["ParameterName"] = "Instruction" as AnyObject?
        
        taskParameters = ModelManager.getInstance().findTaskParameterList(criteria)

        if (taskParameters.count > 0)
        {
            for taskParameter: TaskParameter in taskParameters
            {
                WorkInstruction.text = taskParameter.ParameterValue
                WorkInstruction.isEditable = false
            }
        }
        else
        {
            WorkInstruction.text = "no instructions"
            WorkInstruction.isEditable = false
        }
        
        WorkCarriedOut.delegate = self
        AlternateAssetCode.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NewScancode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    //MARK: Keyboard handling methods
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIControl.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIControl.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
   
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        
        let tabbarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        let toolbarHeight = navigationController?.toolbar.frame.size.height ?? 0
        let bottomInset = keyboardSize.height - tabbarHeight - toolbarHeight
        
        scrollView.contentInset.bottom = bottomInset
        scrollView.scrollIndicatorInsets.bottom = bottomInset
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.addDoneButtonOnKeyboard(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    //MARK: UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.addDoneButtonOnKeyboard(textView)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    //MARK: Actions
    
    @IBAction func CancelPressed(_ sender: UIBarButtonItem) {
        let userPrompt: UIAlertController = UIAlertController(title: "Leave task?", message: "Are you sure you want to leave this task?  Any unsaved data will be lost.", preferredStyle: UIAlertController.Style.alert)
        
        //the cancel action
        userPrompt.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertAction.Style.cancel,
            handler: nil))
        
        //the destructive option
        userPrompt.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.destructive,
            handler: self.LeaveTask))
       
        present(userPrompt, animated: true, completion: nil)
    }
    
    func LeaveTask (_ actionTarget: UIAlertAction) {
        Session.CodeScanned = nil
        Session.TaskId = nil
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func Validate() -> Bool{
        var valid: Bool = true;
        

        let value: String? = WorkCarriedOut.text
        if (value == nil || value == String() )
        {
            WorkCarriedOutLabel.textColor = UIColor.red
            valid = false
        }
        else
        {
            WorkCarriedOutLabel.textColor = UIColor.white
        }

        return valid
    }
    
    
    @IBAction func DonePressed(_ sender: UIBarButtonItem) {
        //do all the vlaidation
        if (!Validate())
        {
            let userPrompt: UIAlertController = UIAlertController(title: "Incomplete task!", message: "Please complete the fields highlighted with red.", preferredStyle: UIAlertController.Style.alert)
            
            //the cancel action
            userPrompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default,
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
        currentTaskParameter.TaskTemplateParameterId = nil
        currentTaskParameter.ParameterName = "WorkCarriedOut"
        currentTaskParameter.ParameterType = "Freetext"
        currentTaskParameter.ParameterDisplay = "Work Carried Out"
        currentTaskParameter.Collect = true
        currentTaskParameter.ParameterValue = WorkCarriedOut.text
        _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        
        currentTaskParameter = TaskParameter()
        currentTaskParameter.RowId = UUID().uuidString
        currentTaskParameter.CreatedBy = Session.OperativeId!
        currentTaskParameter.CreatedOn = now
        currentTaskParameter.TaskId = Session.TaskId!
        currentTaskParameter.TaskTemplateParameterId = nil
        currentTaskParameter.ParameterName = "WorkCompleted"
        currentTaskParameter.ParameterType = "Reference Data"
        currentTaskParameter.ParameterDisplay = "Work Completed"
        currentTaskParameter.Collect = true
        currentTaskParameter.ParameterValue = (WorkCompleted.isOn ? "Yes" : "No")
        _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        
        currentTaskParameter = TaskParameter()
        currentTaskParameter.RowId = UUID().uuidString
        currentTaskParameter.CreatedBy = Session.OperativeId!
        currentTaskParameter.CreatedOn = now
        currentTaskParameter.TaskId = Session.TaskId!
        currentTaskParameter.TaskTemplateParameterId = nil
        currentTaskParameter.ParameterName = "RemoveAsset"
        currentTaskParameter.ParameterType = "Reference Data"
        currentTaskParameter.ParameterDisplay = "Remove Asset"
        currentTaskParameter.Collect = true
        currentTaskParameter.ParameterValue = (RemoveAsset.isOn ? "Yes" : "No")
        _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        
        
        if (AlternateAssetCode.text != nil)
        {
            currentTaskParameter = TaskParameter()
            currentTaskParameter.RowId = UUID().uuidString
            currentTaskParameter.CreatedBy = Session.OperativeId!
            currentTaskParameter.CreatedOn = now
            currentTaskParameter.TaskId = Session.TaskId!
            currentTaskParameter.TaskTemplateParameterId = nil
            currentTaskParameter.ParameterName = "AlternateAssetCode"
            currentTaskParameter.ParameterType = "Freetext"
            currentTaskParameter.ParameterDisplay = "Alternate Asset Code"
            currentTaskParameter.Collect = true
            currentTaskParameter.ParameterValue = AlternateAssetCode.text!
            _ = ModelManager.getInstance().addTaskParameter(currentTaskParameter)
        }
        
        //update the task
        task.LastUpdatedBy = Session.OperativeId!
        task.LastUpdatedOn = now
        task.CompletedDate = now
        task.OperativeId = Session.OperativeId!
        task.Status = "Dockable"
        
        _ = ModelManager.getInstance().updateTask(task)
        
        Utility.SendTasks(self.navigationController!, HUD: nil)
        Session.CodeScanned = nil
        
        //close the view
        Session.TaskId = nil
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Scancode
    
    func NewScancode(){
        if (Session.CodeScanned != nil)
        {
            AlternateAssetCode.text = Session.CodeScanned!
        }
    }
    
    func addDoneButtonOnKeyboard(_ view: UIView?)
    {
        
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

