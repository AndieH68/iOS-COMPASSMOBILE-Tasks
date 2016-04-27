//
//  MainViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 11/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBAction func logoutSelected(sender: UIBarButtonItem) {
        Session.OperativeId = nil
        viewDidAppear(true)
    }

    var taskData: [Task] = [] //NSMutableArray!
    var pageNumber: Int32 = 1
    var updateTable: Bool = true
//    var frameView: UIView!
    
    @IBAction func TaskSort(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
            case 0:
                Session.TaskSort = TaskSortOrder.Date
            case 1:
                Session.TaskSort = TaskSortOrder.Location
            case 2:
                Session.TaskSort = TaskSortOrder.AssetType
            case 3:
                Session.TaskSort = TaskSortOrder.Task
            default:
                Session.TaskSort = TaskSortOrder.Date
        }
        
        getTaskData(Session.PageSize, pageNumber: Session.PageNumber)
    }
    
    @IBAction func PageFirst(sender: UIButton) {
        Session.PageNumber = 1
        self.UserPageNumber.text = String(Session.PageNumber)
        getTaskData(Session.PageSize, pageNumber: Session.PageNumber)
    }
    
    @IBAction func PagePrevious(sender: UIButton) {
        if (Session.PageNumber > 1)
        {
            Session.PageNumber -= 1
        }
        self.UserPageNumber.text = String(Session.PageNumber)
        getTaskData(Session.PageSize, pageNumber: Session.PageNumber)
    }
    
    @IBAction func PageNext(sender: UIButton) {
        if (Session.PageNumber < Session.MaxPage)
        {
            Session.PageNumber += 1
        }
        self.UserPageNumber.text = String(Session.PageNumber)
        getTaskData(Session.PageSize, pageNumber: Session.PageNumber)
    }
    
    @IBAction func PageLast(sender: UIButton) {
        
        Session.PageNumber = Session.MaxPage
        self.UserPageNumber.text = String(Session.PageNumber)
        getTaskData(Session.PageSize, pageNumber: Session.PageNumber)
    }
    
    @IBAction func PageNumberChanged(sender: UITextField) {
    }
    
    @IBOutlet weak var UserPageNumber: UITextField!
    @IBOutlet weak var taskTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pageNumber = 1;
        Session.TaskSort = TaskSortOrder.Date
        self.UserPageNumber.delegate = self;
        addDoneButtonTo(self.UserPageNumber)
        Session.PageNumber = pageNumber
        self.UserPageNumber.text = String(Session.PageNumber)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Get the filtered list of tasks to populate the table
        self.getTaskData()
        
//        // Keyboard stuff.
//        debugPrint("Adding observers")
//        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
//        center.addObserver(self, selector: #selector(MainViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
//        center.addObserver(self, selector: #selector(MainViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        //check that we have already populated the operativeid for the session.
        if Session.OperativeId == nil
        {
            // we don't yet have an operative and therefore the operative hasn't logged in
            // take the user to the login screen
            self.performSegueWithIdentifier("loginView", sender: self)
        }
    }
 
//    override func viewWillDisappear(animated: Bool) {
//        debugPrint("Removing observers")
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//    }
    
    
    //MARK: Other methods
    
    func getTaskData() {
        getTaskData(nil, pageNumber: nil)
    }
    
    func getTaskData( pageSize: Int32?,  pageNumber: Int32?)
    {
        var page: Int32
        var size: Int32
        
        // make sure w ehave vlaid paging parameters
        if (pageNumber == nil) {page = Session.PageNumber} else {page = pageNumber!}
        if (pageSize == nil) {size = Session.PageSize} else {size = pageSize!}
        
        var count: Int32 = 0
        
        // go and get the search/filter criteria from the vlaues selected in the session
        let criteria: Dictionary<String, String> = Session.BuildCriteriaFromSession()
        
        // go and get the task data based on the criteria built
        (taskData, count) = ModelManager.getInstance().findTaskList(criteria, pageSize: size, pageNumber: page, sortOrder: Session.TaskSort)
        
        //store the tasks count in the session
        Session.TaskCount = count
        Session.MaxPage = (Int(Session.TaskCount / Session.PageSize) + 1)
        
        //reload the table
        taskTable.reloadData()
    }
    
    //MARK: UITableView delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:TaskCell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as! TaskCell
        
        let task:Task = taskData[indexPath.row]
       
        cell.taskRef.text = task.TaskRef
        cell.taskName.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup!)
        cell.location.text = task.LocationName
        cell.type.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!)
        cell.asset.text = task.AssetNumber
        cell.dateDue.text = task.ScheduledDate.toStringForView()
        
        return cell
    }
    
    //MARK: UITextField delegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        updateTable = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateTable = true
        if let numberCheck = Int32(UserPageNumber.text!)
        {
            if (numberCheck >= 1 && numberCheck <= Session.MaxPage)
            {
                Session.PageNumber = numberCheck
                getTaskData(Session.PageSize, pageNumber: Session.PageNumber)
            }
            else if (numberCheck > Session.MaxPage)
            {
                Session.PageNumber = Session.MaxPage
                self.UserPageNumber.text = String(Session.PageNumber)
                getTaskData(Session.PageSize, pageNumber: Session.PageNumber)
            }
        }
    }
    
    //MARK: UIText Field Keyboard handling
 
    func didTapDone(sender: AnyObject?) {
        UserPageNumber.endEditing(true)
    }
    
    func addDoneButtonTo(textField: UITextField) {
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: nil, action: #selector(MainViewController.didTapDone(_:)))
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textField.inputAccessoryView = keyboardToolbar
    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        self.frameView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
//        
//        let info:NSDictionary = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
//        
//        let keyboardHeight: CGFloat = keyboardSize.height
//        
//        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
//        
//        
//        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//            self.frameView.frame = CGRectMake(0, (self.frameView.frame.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
//            }, completion: nil)
//        
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        let info: NSDictionary = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
//        
//        let keyboardHeight: CGFloat = keyboardSize.height
//        
//        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
//        
//        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//            self.frameView.frame = CGRectMake(0, (self.frameView.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
//            }, completion: nil)
//        
//    }

}

