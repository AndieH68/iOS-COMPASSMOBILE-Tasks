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

class TaskViewController: UITableViewController, UITextFieldDelegate, MBProgressHUDDelegate {

    var task: Task = Task()
    var taskParameters: [TaskParameter] = [TaskParameter]()
    var taskTemplateParameters: [TaskTemplateParameter] = [TaskTemplateParameter]()
    
    var descendants: Dictionary<String, [Descendant]> = Dictionary<String, [Descendant]>()
    
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
        let taskTemplateId = task.TaskTemplateId
        
        var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        criteria["TaskTemplateId"] = taskTemplateId
        
        taskTemplateParameters = ModelManager.getInstance().findTaskTemplateParameterList(criteria)
        
        //additional notes will always be the last record
        taskTemplateParameters.removeLast()
        
        //remove alternate asset code and remove asset
        taskTemplateParameters.removeAtIndex(1)
        taskTemplateParameters.removeAtIndex(0)
        
        //reload the table
        taskParameterTable.reloadData()
    }

    @IBAction func AnswerPopupChanged(sender: KFPopupSelector) {
        print(sender.restorationIdentifier)
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    //MARK: UITableView delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTemplateParameters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var predecessor: String? = String?()
        let descendant: Descendant = Descendant()
        let taskTemplateParameter: TaskTemplateParameter = taskTemplateParameters[indexPath.row]
        
        if (taskTemplateParameter.Predecessor != nil)
        {
            predecessor = taskTemplateParameter.Predecessor!
        }
        
        if (predecessor != nil)
        {
            descendant.Id = taskTemplateParameter.RowId
            descendant.TrueValue = taskTemplateParameter.PredecessorTrueValue!
        }
    
        
        switch taskTemplateParameter.ParameterType
        {
        case "Freetext":
            let cell = tableView.dequeueReusableCellWithIdentifier("FreetextCell", forIndexPath: indexPath) as! TaskTemplateParameterCellFreetext
            cell.Question.text = taskTemplateParameter.ParameterDisplay
            cell.Answer.delegate = self
            
            if (predecessor != nil)
            {
                descendant.Control = cell.Answer

                if (descendants[predecessor!] == nil)
                {
                    descendants[predecessor!] = [Descendant]()
                }
                descendants[predecessor!]?.append(descendant)
            }
 
            return cell
            
        case "Number":
            let cell = tableView.dequeueReusableCellWithIdentifier("NumberCell", forIndexPath: indexPath) as! TaskTemplateParameterCellNumber
            cell.Question.text = taskTemplateParameter.ParameterDisplay
            cell.Answer.delegate = self
            
            if (predecessor != nil)
            {
                descendant.Control = cell.Answer
                
                if (descendants[predecessor!] == nil)
                {
                    descendants[predecessor!] = [Descendant]()
                }
                descendants[predecessor!]?.append(descendant)
            }

            return cell
            
        case "Reference Data":
            let cell = tableView .dequeueReusableCellWithIdentifier("DropdownCell", forIndexPath: indexPath) as! TaskTemplateParameterCellDropdown
            cell.Question.text = taskTemplateParameter.ParameterDisplay
            
            var dropdownData: [String] = []
            dropdownData.append("Please select")
            dropdownData.appendContentsOf( ModelUtility.getInstance().GetLookupList(taskTemplateParameter.ReferenceDataType!, ExtendedReferenceDataType: taskTemplateParameter.ReferenceDataExtendedType))

            cell.AnswerSelector.restorationIdentifier = taskTemplateParameter.RowId
            cell.AnswerSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            cell.AnswerSelector.setLabelFont(UIFont.systemFontOfSize(17))
            cell.AnswerSelector.setTableFont(UIFont.systemFontOfSize(17))
            cell.AnswerSelector.options = dropdownData.map { KFPopupSelector.Option.Text(text: $0) }
            cell.AnswerSelector.selectedIndex = nil
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

            return cell

        case "TextArea":
            let cell = tableView.dequeueReusableCellWithIdentifier("TextAreaCell", forIndexPath: indexPath) as! TaskTemplateParameterCellNumber
            cell.Question.text = taskTemplateParameter.ParameterDisplay
            //cell.Answer.text = taskParameter.ParameterValue

            if (predecessor != nil)
            {
                descendant.Control = cell.Answer
                
                if (descendants[predecessor!] == nil)
                {
                    descendants[predecessor!] = [Descendant]()
                }
                descendants[predecessor!]?.append(descendant)
            }

            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("FreetextCell", forIndexPath: indexPath) as! TaskTemplateParameterCellFreetext
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

            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //need to work out here what type of cell so that we can return the correct height
        return 68
    }
    
    //MARK: Actions
    
    @IBAction func CancelPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func DonePressed(sender: UIBarButtonItem) {
        //do all the vlaidation
        
        //commit the vales
        
        //update the task
        
        //close the view
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func AlternateAssetCodeLaunchScan(sender: UITextField) {
        
    }
    
    
    
    
}

