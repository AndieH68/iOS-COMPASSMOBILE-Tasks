//
//  MainViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 11/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBAction func logoutSelected(sender: UIBarButtonItem) {
        Session.OperativeId = nil
        viewDidAppear(true)
    }

    var taskData: [Task] = [] //NSMutableArray!
    var pageNumber: Int32 = 1
    var updateTable: Bool = true
//    var frameView: UIView!
    
    @IBOutlet weak var SelectedSite: UILabel!
    @IBOutlet weak var SelectedProperty: UILabel!
    @IBOutlet weak var taskTable: UITableView!
    
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
        self.getTaskData()
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
    
    //MARK: Navigation Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        switch segue.identifier!
//        {
//            case "addSegue":
//                let btnAdd : UIButton = sender as! UIButton
//            
//            
//            case "filterSegue":
//                let btnAdd : UIButton = sender as! UIButton
//            
//            case "searchSegue":
//                let btnAdd : UIButton = sender as! UIButton
//            
//            case "settingsSegue":
//                let btnAdd : UIButton = sender as! UIButton
//            
//        default:
//            print("Default")
//            
//        }
        
    
    }
}

