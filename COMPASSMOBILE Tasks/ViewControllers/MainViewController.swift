//
//  MainViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 11/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import Foundation
import MBProgressHUD

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate {

    @IBAction func logoutSelected(_ sender: UIBarButtonItem) {
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
    
    @IBAction func Refresh(_ sender: UIBarButtonItem) {
        DoSynchronise(nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pageNumber = 1;
        Session.TaskSort = TaskSortOrder.date
        Session.PageNumber = pageNumber
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Session.OperativeId == nil
        {
            // we don't yet have an operative and therefore the operative hasn't logged in
            // take the user to the login screen
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
        
        if Session.GettingScanCode {
            if (!Session.CancelFromScan && Session.CodeScanned != nil) {
                Session.FilterAssetNumber = "(%" + Session.CodeScanned! + ")%"
                Session.CodeScanned = nil
                Session.GettingScanCode = false
            }
            Session.CancelFromScan = false;
        }
        
        // Get the filtered list of tasks to populate the table
        if(Session.FilterSiteName == nil) { SelectedSite.text = "All" } else { SelectedSite.text = Session.FilterSiteName }
        if(Session.FilterPropertyName == nil) { SelectedProperty.text = "All" } else { SelectedProperty.text = Session.FilterPropertyName }
        if(Session.OperativeId != nil)
        {
            self.getTaskData(MainThread: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if !Session.DatabasePresent
        {
            Utility.invokeAlertMethod(self, title: "Fatal Exception", message: Session.DatabaseMessage)
            Session.OperativeId = nil
        }
        
        if Session.TaskId != nil
        {
            let task: Task = ModelManager.getInstance().getTask(Session.TaskId!)!
            var taskSwitch: String = task.TaskName
            if taskSwitch.startsWith(BiologicalMonitoringValue) {taskSwitch = BiologicalMonitoringValue}
            
            switch (taskSwitch)
            {
            case BiologicalMonitoringValue:
                self.performSegue(withIdentifier: "BiologicalMonitoringSegue", sender: self)
                
            case RemedialTaskValue:
                self.performSegue(withIdentifier: "RemedialTaskSegue", sender: self)
            
            default:
                self.performSegue(withIdentifier: "TaskSegue", sender: self)
            }
        }
        
        if Session.CheckDatabase == true
        {
            
            let userPrompt: UIAlertController = UIAlertController(title: "Synchronising", message: "The application is downloading data from COMPASS.  This process may take some time if this is the first time you have attempted to synchronise", preferredStyle: UIAlertController.Style.alert)
            
            //the default action
            userPrompt.addAction(UIAlertAction(
                title: "Ok",
                style: UIAlertAction.Style.default,
                handler: self.DoSynchronise))
            
            self.present(userPrompt, animated: true, completion: nil)

            Session.CheckDatabase = false
            
        }
    }
    
    func DoSynchronise(_ actionTarget: UIAlertAction?)
    {
       
        if(Reachability().connectedToNetwork())
        {
            HUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            HUD!.mode = .determinateHorizontalBar
            HUD!.label.text = "Synchronising"
            
            DispatchQueue.global().async
            {
                Utility.CheckSynchronisation(self, HUD: self.HUD!)
                self.getTaskData(MainThread: false)
                
                //reload the table
                DispatchQueue.main.async
                {
                    self.taskTable.reloadData()

                    self.HUD!.hide(animated: true)
                }
            }
            Session.InvalidateCachedFilterJustMyTasksClause = true
        }
        else
        {
            Utility.invokeAlertMethod(self, title: "Synchronise", message: NoNetwork)
        }
    }
 
    //MARK: Other methods
    
    func getTaskData(MainThread: Bool) {
        getTaskData(nil, pageNumber: nil, MainThread: MainThread)
    }
    
    func getTaskData( _ pageSize: Int32?,  pageNumber: Int32?, MainThread: Bool)
    {
        var page: Int32
        var size: Int32
        
        // make sure we have valid paging parameters
        if (pageNumber == nil) {page = Session.PageNumber} else {page = pageNumber!}
        if (pageSize == nil) {size = Session.PageSize} else {size = pageSize!}
        
        var count: Int32 = 0
        
        // go and get the search/filter criteria from the vlaues selected in the session
        let criteria: Dictionary<String, AnyObject> = Session.BuildCriteriaFromSession()
        
        // go and get the task data based on the criteria built
        (taskData, count) = ModelManager.getInstance().findTaskList(criteria, onlyPending: true, pageSize: size, pageNumber: page, sortOrder: Session.TaskSort)
        
        //store the tasks count in the session
        Session.TaskCount = count
        Session.MaxPage = (Int32(Int(Session.TaskCount / Session.PageSize) + 1))
        
        if(MainThread)
        {
            //reload the table
            taskTable.reloadData()
        }
    }
    
    //MARK: UITableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TaskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskCell
        
        let task: Task = taskData[indexPath.row]
        
        var taskNameInstructionExtension: String? = nil

        var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        criteria["TaskId"] = task.RowId as AnyObject?
        let taskInstructions: [TaskInstruction] = ModelManager.getInstance().findTaskInstructionList(criteria)
        if(taskInstructions.count >= 1)
        {
            let taskInstruction: TaskInstruction = taskInstructions[0]
            
            let testSuite: TestSuite = ModelManager.getInstance().getTestSuite(taskInstruction.EntityId)!
            taskNameInstructionExtension = testSuite.Name
        }
       
        cell.taskRef.text = task.TaskRef
        var TaskName: String = task.TaskName
        if (TaskName != RemedialTask && TaskName != "BiologicalMonitoring")
        {
            TaskName = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup!)
        }
        else if (TaskName == "BiologicalMonitoring")
        {
            TaskName = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: task.TaskName, parentType: "PPMAssetGroup", parentValue: task.PPMGroup!)
            if(taskNameInstructionExtension != nil)
            {
                TaskName += " - " + taskNameInstructionExtension!
            }
        }
        cell.taskName.text = TaskName
        let PropertyName: String = (Session.FilterPropertyName != nil ? String() : ModelUtility.getInstance().GetPropertyName(task.PropertyId) + ", ")
        cell.location.text = PropertyName + task.LocationName
        if(task.PPMGroup != nil)
        {
            let AssetType: String? = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!, parentType: "PPMAssetGroup", parentValue:task.PPMGroup!)
            if (AssetType != "")
            {
                cell.type.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!) + " - " + ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!, parentType: "PPMAssetGroup", parentValue:task.PPMGroup!)
            }
            else
            {
                cell.type.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: task.PPMGroup!) + " - " + ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!, parentType: "PPMAssetGroup", parentValue: "DistributionServices")
            }
        }
        else
        {
            cell.type.text = (task.AssetType ?? "Missing PPM Group")  + " - " + ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: task.AssetType!)
        }
        cell.asset.text = task.AssetNumber
        cell.dateDue.text = Utility.DateToStringForView(task.ScheduledDate)
        cell.priority.text = ModelUtility.getInstance().ReferenceDataDisplayFromValue("Priority", key: String(task.Priority))
        cell.taskId = task.RowId
        if (indexPath.row % 2 == 1)
        {
            cell.backgroundColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.75) //UIColor.white
        }
        else
        {
            cell.backgroundColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 0.75)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell: TaskCell = tableView.cellForRow(at: indexPath) as! TaskCell
        var taskSwitch: String = cell.taskName.text!
        if taskSwitch.startsWith(BiologicalMonitoring) {taskSwitch = BiologicalMonitoring}
        
        switch (taskSwitch)
        {
        case BiologicalMonitoring:
            self.performSegue(withIdentifier: "BiologicalMonitoringSegue", sender: cell)
            
        case RemedialTask:
            self.performSegue(withIdentifier: "RemedialTaskSegue", sender: cell)
        
        default:
            self.performSegue(withIdentifier: "TaskSegue", sender: cell)
        }
        
    }
    
    //MARK: Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
                
            case "BiologicalMonitoringSegue":
                if (sender is TaskCell)
                {
                    Session.TaskId = (sender as! TaskCell).taskId
                }
                
            case "Search":
                Session.GettingScanCode = true;
                
            default:
                print("Default")
            }
        }
    }
}

