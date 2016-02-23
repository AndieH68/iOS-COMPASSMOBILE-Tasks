//
//  MainViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 11/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{


    let defaultPageSize: Int32 = 20
    
    var taskData: [Task] = [] //NSMutableArray!
    var pageNumber: Int32 = 1
    var sortOrder: TaskSortOrder = TaskSortOrder.Date
    
    @IBOutlet weak var taskTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pageNumber = 1;
        sortOrder = TaskSortOrder.Date
    }

    override func viewWillAppear(animated: Bool) {
        self.getTaskData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        if Session.OperativeId == nil
        {
            self.performSegueWithIdentifier("loginView", sender: self)
        }
        else
        {
            /*confirm user details*/
        }
        
        //Utility.SynchroniseData(nil)
        
    }
    
    //MARK: Other methods
    
    func getTaskData() {
        getTaskData(nil, pageNumber: nil)
    }
    
    func getTaskData(var pageSize: Int32?, var pageNumber: Int32?)
    {
        if (pageNumber == nil) {pageNumber = 1}
        if (pageSize == nil) {pageSize = defaultPageSize}
        
        var count: Int32 = 0
        let criteria: Dictionary<String, String> = Session.BuildCriteriaFromSession()
        
        (taskData, count) = ModelManager.getInstance().findTaskList(criteria, pageSize: pageSize, pageNumber: pageNumber, sortOrder: sortOrder)
        Session.TaskCount = count
        taskTable.reloadData()
    }
    
    //MARK: UITableView delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TaskCell = tableView.dequeueReusableCellWithIdentifier("cell") as! TaskCell
        
        let task:Task = taskData[indexPath.row]
        
        cell.taskRef.text = task.TaskRef
        cell.taskName.text = task.TaskName
        cell.location.text = task.LocationName
        cell.type.text = task.PPMGroup
        cell.asset.text = task.AssetNumber
        cell.dateDue.text = task.ScheduledDate.toStringForView()
        
        return cell
    }
    
    

}

