//
//  MainViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 11/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate {

    @IBAction func logoutSelected(sender: UIBarButtonItem) {
        Session.OperativeId = nil
        viewDidAppear(true)
    }

    var HUD: MBProgressHUD?
    
    var taskData: [Task] = [] //NSMutableArray!
    var pageNumber: Int32 = 1
    var updateTable: Bool = true
    
    @IBOutlet weak var SelectedSite: UILabel!
    @IBOutlet weak var SelectedProperty: UILabel!
    @IBOutlet weak var taskTable: UITableView!
    
    @IBAction func Refresh(sender: UIBarButtonItem) {
        HUD!.labelText = "Downloading"
        HUD!.showWhileExecuting({Utility.DownloadAll(self, HUD: self.HUD)}, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pageNumber = 1;
        Session.TaskSort = TaskSortOrder.Date
        Session.PageNumber = pageNumber
    }
    
    override func viewWillAppear(animated: Bool) {
        // Get the filtered list of tasks to populate the table
        if(Session.FilterSiteName == nil) { SelectedSite.text = "All" } else { SelectedSite.text = Session.FilterSiteName }
        if(Session.FilterPropertyName == nil) { SelectedProperty.text = "All" } else { SelectedProperty.text = Session.FilterPropertyName }
        if(Session.OperativeId != nil)
        {
            self.getTaskData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        
        if !Session.DatabasePresent
        {
            Utility.invokeAlertMethod(self, title: "Fatal Exception", message: Session.DatabaseMessage, delegate: nil)
            Session.OperativeId = nil
        }
        
        //check that we have already populated the operativeid for the session.
        if Session.OperativeId == nil
        {
            // we don't yet have an operative and therefore the operative hasn't logged in
            // take the user to the login screen
            self.performSegueWithIdentifier("loginView", sender: self)
        }
        
        if Session.TaskId != nil
        {
            self.performSegueWithIdentifier("TaskSegue", sender: self)
        }
        
        if Session.CheckDatabase == true
        {
            
            let userPrompt: UIAlertController = UIAlertController(title: "Synchronising", message: "The application is downloading data from COMPASS.  This process may take some time if this is the first time you have attempted to synchronise", preferredStyle: UIAlertControllerStyle.Alert)
            
            //the default action
            userPrompt.addAction(UIAlertAction(
                title: "Ok",
                style: UIAlertActionStyle.Default,
                handler: self.DoSynchronise))
            
            self.presentViewController(userPrompt, animated: true, completion: nil)

            Session.CheckDatabase = false
        }
    }
    
    func DoSynchronise (actionTarget: UIAlertAction)
    {
        HUD = MBProgressHUD(view: self.navigationController!.view)
        
        self.navigationController!.view.addSubview(HUD!)
        
        //set the HUD mode
        HUD!.mode = .DeterminateHorizontalBar;
        
        // Register for HUD callbacks so we can remove it from the window at the right time
        HUD!.delegate = self
        HUD!.labelText = "Synchronising"
        
        HUD!.showWhileExecuting({
                Utility.CheckSynchronisation(self, HUD: self.HUD!);
                self.getTaskData()
            }, animated: true)
    }
 
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
        let criteria: Dictionary<String, AnyObject> = Session.BuildCriteriaFromSession()
        
        // go and get the task data based on the criteria built
        (taskData, count) = ModelManager.getInstance().findTaskList(criteria, onlyPending: true, pageSize: size, pageNumber: page, sortOrder: Session.TaskSort)
        
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
        
        let cell: TaskCell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as! TaskCell
        
        let task: Task = taskData[indexPath.row]
       
        cell.taskRef.text = task.TaskRef
        var TaskName: String = task.TaskName
        if (TaskName != RemedialTask)
        {
            TaskName = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup!)
        }
        cell.taskName.text = TaskName
        let PropertyName: String = (Session.FilterPropertyName != nil ? String() : ModelUtility.getInstance().GetPropertyName(task.PropertyId) + ", ")
        cell.location.text = PropertyName + task.LocationName
        if(task.PPMGroup != nil)
        {
            cell.type.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!)
        }
        else
        {
            cell.type.text = "Missing PPM Group"
        }
        cell.asset.text = task.AssetNumber
        cell.dateDue.text = Utility.DateToStringForView(task.ScheduledDate)
        cell.taskId = task.RowId
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: TaskCell = tableView.cellForRowAtIndexPath(indexPath) as! TaskCell
        switch (cell.taskName.text!)
        {
        case RemedialTask:
            self.performSegueWithIdentifier("RemedialTaskSegue", sender: cell)
        default:
            self.performSegueWithIdentifier("TaskSegue", sender: cell)
        }
        
    }
    
    //MARK: Navigation Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != nil)
        {
            switch segue.identifier!
            {
                case "TaskSegue":
                    if (sender is TaskCell)
                    {
                        Session.TaskId = (sender as! TaskCell).taskId
                    }
                
                case "RemedialTaskSegue":
                    if (sender is TaskCell)
                    {
                        Session.TaskId = (sender as! TaskCell).taskId
                    }
                default:
                    print("Default")
            }
        }
    }
}

