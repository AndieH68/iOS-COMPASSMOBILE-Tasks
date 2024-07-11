//
//  AddViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 25/02/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet weak var SitePopupSelector: KFPopupSelector!
    @IBOutlet weak var PropertyPopupSelector: KFPopupSelector!
    @IBOutlet weak var LocationGroupPopupSelector: KFPopupSelector!
    @IBOutlet weak var LocationPopupSelector: KFPopupSelector!
    @IBOutlet weak var AssetTypePopupSelector: KFPopupSelector!
    @IBOutlet weak var AssetGroupPopupSelector: KFPopupSelector!
    @IBOutlet weak var TaskNamePopupSelector: KFPopupSelector!
    @IBOutlet weak var AssetNumberPopupSelector: KFPopupSelector!

    var Sites: [String] = []
    var SiteDictionary: Dictionary<String, String> = [:] //name, id
    var SiteId: String? = nil
    
    var Properties: [String] = []
    var PropertyDictionary: Dictionary<String, String> = [:] //name, id
    var PropertyId: String? = nil
    
    var LocationGroups: [String] = []
    var LocationGroupDictionary: Dictionary<String, String> = [:] //name, id
    var LocationGroupId: String? = nil
    var LocationGroupName: String? = nil
    
    var Locations: [String] = []
    var LocationDictionary: Dictionary<String, String> = [:] //name, id
    var LocationId: String? = nil
    var LocationName: String? = nil
    var Room: String? = nil
    
    var AssetTypes: [String] = []
    var AssetTypeDictionary: Dictionary<String, String> = [:] //name, id
    var AssetType: String? = nil
    
    var AssetGroups: [String] = []
    var AssetGroupDictionary: Dictionary<String, String> = [:] //name, id
    var AssetGroup: String? = nil
    
    var TaskNames: [String] = []
    var TaskNameDictionary: Dictionary<String, String> = [:] //name, id
    var TaskName: String? = nil
    var TaskTemplateId: String? = nil
    var EstimatedDuration: Int? = nil
    var TaskRef: String = String()
    
    var AssetNumbers: [String] = []
    var AssetNumberDictionary: Dictionary<String, String> = [:] //name, id
    var AssetId: String? = nil
    var AssetNumber: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Session.CodeScanned = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(Session.CodeScanned != nil)
        {
            var criteria: Dictionary<String, AnyObject> = [:]

            //use the scancode to find the asset
            criteria["ScanCode"] = Session.CodeScanned as AnyObject
            let AssetData: [Asset] = ModelManager.getInstance().findAssetList(criteria)
            if (AssetData.count > 0)
            {
                
                for asset: Asset in AssetData
                {
                    AssetNumber = ModelUtility.getInstance().AssetNumber(asset)
                    AssetId = asset.RowId
                    //use the asset to find the asset types
                    AssetType = asset.AssetType
                    //use the asset to find the location
                    LocationId = asset.LocationId
                    break
                }
                
                var location: Location
                location = ModelManager().getLocation(LocationId!)!
                LocationName = location.Name
                
                //use the location to find the property
                PropertyId = location.PropertyId
                
                //use the location to find the area
                criteria.removeAll(keepingCapacity: false)
                criteria["LocationId"] = LocationId as AnyObject
                let LocationGroupMembershipData: [LocationGroupMembership] = ModelManager.getInstance().findLocationGroupMembershipList(criteria)
                for locationGroupMembership: LocationGroupMembership in LocationGroupMembershipData
                {
                    let LocationGroup = ModelManager.getInstance().getLocationGroup(locationGroupMembership.LocationGroupId)
                    LocationGroupId = LocationGroup?.RowId
                    LocationGroupName = LocationGroup?.Name
                    break
                }
                                
                //use the property to find the site
                let Property = ModelManager.getInstance().getProperty(PropertyId!)
                SiteId = Property?.SiteId

            }
            else
            {
                AssetId = nil
                AssetNumber = nil
                AssetType = nil
                LocationId = nil
                LocationName = nil
                LocationGroupId = nil
                LocationGroupName = nil
                PropertyId = nil
                SiteId = nil

                Session.FilterAssetNumber = nil
                
                PropertyPopupSelector.unselectedLabelText = NotApplicable
                PropertyPopupSelector.selectedIndex = nil
                PropertyPopupSelector.isEnabled = false
                
                LocationGroupPopupSelector.unselectedLabelText = NotApplicable
                LocationGroupPopupSelector.selectedIndex = nil
                LocationGroupPopupSelector.isEnabled = false
                
                LocationPopupSelector.unselectedLabelText = NotApplicable
                LocationPopupSelector.selectedIndex = nil
                LocationPopupSelector.isEnabled = false
                
                AssetTypePopupSelector.unselectedLabelText = NotApplicable
                AssetTypePopupSelector.selectedIndex = nil
                AssetTypePopupSelector.isEnabled = false
                
                AssetGroupPopupSelector.unselectedLabelText = NotApplicable
                AssetGroupPopupSelector.selectedIndex = nil
                AssetGroupPopupSelector.isEnabled = false
                
                TaskNamePopupSelector.unselectedLabelText = NotApplicable
                TaskNamePopupSelector.selectedIndex = nil
                TaskNamePopupSelector.isEnabled = false
                
                AssetNumberPopupSelector.unselectedLabelText = NotApplicable
                AssetNumberPopupSelector.selectedIndex = nil
                AssetNumberPopupSelector.isEnabled = false
            }
            
            //allow user to select Asset Group
            //allow user to select Task Name
            
            PopulateSiteSelector()
            
        }
        else
        {
                AssetId = nil
                AssetNumber = nil
                AssetType = nil
                LocationId = nil
                LocationName = nil
                LocationGroupId = nil
                LocationGroupName = nil
                PropertyId = nil
                SiteId = nil
                
                Session.FilterAssetNumber = nil
                PropertyPopupSelector.unselectedLabelText = NotApplicable
                PropertyPopupSelector.isEnabled = false
                
                LocationGroupPopupSelector.unselectedLabelText = NotApplicable
                LocationGroupPopupSelector.isEnabled = false
                
                LocationPopupSelector.unselectedLabelText = NotApplicable
                LocationPopupSelector.isEnabled = false
                
                AssetTypePopupSelector.unselectedLabelText = NotApplicable
                AssetTypePopupSelector.isEnabled = false
                
                AssetGroupPopupSelector.unselectedLabelText = NotApplicable
                AssetGroupPopupSelector.isEnabled = false
                
                TaskNamePopupSelector.unselectedLabelText = NotApplicable
                TaskNamePopupSelector.isEnabled = false
                
                AssetNumberPopupSelector.unselectedLabelText = NotApplicable
                AssetNumberPopupSelector.isEnabled = false
                
                PopulateSiteSelector()
            }
    }
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ScanCode(_ sender: Any) {
    }
    
    @IBAction func Done(_ sender: UIBarButtonItem) {
        //based off the optons selected we can create the task
        if (AssetId == nil)
        {
            Utility.invokeAlertMethod(self, title: "Error", message: "Please select all options")
            return
        }
        
        var criteria: Dictionary<String, AnyObject> = [:]
        criteria["OrganisationId"] = Session.OrganisationId! as AnyObject
        criteria["AssetType"] = AssetGroup! as AnyObject
        criteria["TaskName"] = TaskName! as AnyObject
        
        var TaskTemplateData: [TaskTemplate] = []

        TaskTemplateData = ModelManager.getInstance().findTaskTemplateList(criteria)
        
        for currentTaskTemplate: TaskTemplate in TaskTemplateData
        {
            TaskTemplateId = currentTaskTemplate.RowId
            break;
        }
        
        TaskRef = "CMi" + Utility.DateToStringForTaskRef(Date())
    
        //create the task and go to the task form
        let rowId: String = UUID().uuidString
        let now: Date = Date()
        let newTask: Task = Task(rowId: rowId, createdBy: Session.OperativeId!, createdOn: now, lastUpdatedBy: nil, lastUpdatedOn: nil, deleted: nil, organisationId: Session.OrganisationId!, siteId: SiteId!, propertyId: PropertyId!, locationId: LocationId!, locationGroupName: LocationGroupName!, locationName: LocationName!, room: Room, taskTemplateId: TaskTemplateId, taskRef: TaskRef, PPMGroup: AssetGroup, assetType: AssetType!, taskName: TaskName!, frequency: "One off", assetId: AssetId!, assetNumber: AssetNumber!, scheduledDate: now, completedDate: nil, status: "Pending", priority: 30, estimatedDuration: EstimatedDuration, operativeId: Session.OperativeId, actualDuration: nil, travelDuration: nil, comments: nil, alternateAssetCode: nil, level: ModelUtility.getInstance().GetLevelForLocationId(LocationId!))
        
        _ = ModelManager.getInstance().addTask(newTask)
        
        Session.TaskId = newTask.RowId
            
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier != nil)
        {
            switch segue.identifier!
            {
                case "SearchSegue":
                    Session.CodeScanned = nil
                
                default:
                    print("Default")
            }
        }
    }

    // MARK : populate the drop downs
    
    func PopulateSiteSelector()
    {
        //Get this list of sites currently available for this user
        Sites = []
        SiteDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, AnyObject> = [:]
        criteria["OrganisationId"] = Session.OrganisationId as AnyObject
        
        var siteData: [Site] = [] //NSMutableArray!
        var selectedIndex: Int = 0
        Sites.append("")
        
        // go and get the site data based on the criteria built
        siteData = ModelManager.getInstance().findSiteList(criteria)
        
        var count: Int = 1 //we already have the blank row
        for currentSite: Site in siteData
        {
            Sites.append(currentSite.Name)
            SiteDictionary[currentSite.Name] = currentSite.RowId
            if (currentSite.RowId == SiteId) { selectedIndex = count}
            count += 1
        }
        
        SitePopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        SitePopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        SitePopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        SitePopupSelector.options = Sites.map { KFPopupSelector.Option.text(text: $0) }
        if (selectedIndex > 0) { SitePopupSelector.selectedIndex = selectedIndex } else { SitePopupSelector.selectedIndex = nil }
        SitePopupSelector.unselectedLabelText = "Select Site"
        SitePopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulatePropertySelector()
    {
        //Get this list of Propertys currently available for this user
        Properties = []
        PropertyDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, AnyObject> = [:]
        criteria["SiteId"] = SiteId as AnyObject
        
        var PropertyData: [Property] = [] //NSMutableArray!
        var selectedIndex: Int = 0
        Properties.append("")
        
        // go and get the Property data based on the criteria built
        PropertyData = ModelManager.getInstance().findPropertyList(criteria)
        
        var count: Int = 1 //we already have the blank row
        for currentProperty: Property in PropertyData
        {
            Properties.append(currentProperty.Name)
            PropertyDictionary[currentProperty.Name] = currentProperty.RowId
            if (currentProperty.RowId == PropertyId) { selectedIndex = count}
            count += 1
        }
        
        PropertyPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        PropertyPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        PropertyPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        PropertyPopupSelector.options = Properties.map { KFPopupSelector.Option.text(text: $0) }
        if (selectedIndex > 0) { PropertyPopupSelector.selectedIndex = selectedIndex } else { PropertyPopupSelector.selectedIndex = nil }
        PropertyPopupSelector.unselectedLabelText = "Select Property"
        PropertyPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateLocationGroupSelector()
    {
        //Get this list of LocationGroups currently available for this user
        LocationGroups = []
        LocationGroupDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, AnyObject> = [:]
        var selectedIndex: Int = 0
        criteria["PropertyId"] = PropertyId! as AnyObject
        
        // go and get the search/filter criteria from the values selected in the session
        var LocationGroupData: [LocationGroup] = [] //NSMutableArray!
        LocationGroups.append("")
        
        // go and get the LocationGroup data based on the criteria built
        LocationGroupData = ModelManager.getInstance().findLocationGroupList(criteria)
        
        var count: Int = 1 //we already have the blank row
        for currentLocationGroup: LocationGroup in LocationGroupData
        {
            if (currentLocationGroup.Name == nil) {currentLocationGroup.Name = "missing name"}
            LocationGroups.append(currentLocationGroup.Name!)
            LocationGroupDictionary[currentLocationGroup.Name!] = currentLocationGroup.RowId
            if (currentLocationGroup.RowId == LocationGroupId) { selectedIndex = count}
            count += 1
        }
        
        LocationGroupPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        LocationGroupPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        LocationGroupPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        LocationGroupPopupSelector.options = LocationGroups.map { KFPopupSelector.Option.text(text: $0) }
        if (selectedIndex > 0) { LocationGroupPopupSelector.selectedIndex = selectedIndex } else { LocationGroupPopupSelector.selectedIndex = nil }
        LocationGroupPopupSelector.unselectedLabelText = "Select Area"
        LocationGroupPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateLocationSelector()
    {
        //Get this list of Locations currently available for this user
        Locations = []
        LocationDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, AnyObject> = [:]
        var selectedIndex: Int = 0
        criteria["PropertyId"] = PropertyId as AnyObject
        
        // go and get the search/filter criteria from the values selected in the session
        var LocationData: [Location] = [] //NSMutableArray!

        Locations.append("")
        
        // go and get the Location data based on the criteria built
        (LocationData, _) = ModelManager.getInstance().findLocationListByLocationGroup(LocationGroupId!, criteria: criteria, pageSize: nil, pageNumber: nil)
        
        var count: Int = 1 //we already have the blank row
        for currentLocation: Location in LocationData
        {
            Locations.append(currentLocation.Name)
            LocationDictionary[currentLocation.Name] = currentLocation.RowId
            if (currentLocation.RowId == LocationId) { selectedIndex = count}
            count += 1
        }
        
        LocationPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        LocationPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        LocationPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        LocationPopupSelector.options = Locations.map { KFPopupSelector.Option.text(text: $0) }
        if (selectedIndex > 0) { LocationPopupSelector.selectedIndex = selectedIndex } else { LocationPopupSelector.selectedIndex = nil }
        LocationPopupSelector.unselectedLabelText = "Select Location"
        LocationPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateAssetTypeSelector()
    {
        //Get this list of AssetGroups currently available for this user
        AssetTypes = []
        AssetTypeDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, AnyObject> = [:]
        var selectedIndex: Int = 0
        criteria["LocationId"] = LocationId as AnyObject
        
        // go and get the search/filter criteria from the values selected in the session
        var AssetData: [Asset] = [] //NSMutableArray!
        AssetTypes.append("")
        
        // go and get the Asset data based on the criteria built
        AssetData = ModelManager.getInstance().findAssetList(criteria)
        
        var count: Int = 1 //we already have the blank row
        for currentAsset: Asset in AssetData
        {
            var currentAssetTypeDisplay: String = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: currentAsset.AssetType)
            if(currentAssetTypeDisplay.isEmpty) { currentAssetTypeDisplay = currentAsset.AssetType}
            if(!AssetTypeDictionary.keys.contains(currentAssetTypeDisplay))
            {
                AssetTypes.append(currentAssetTypeDisplay)
                AssetTypeDictionary[currentAssetTypeDisplay] = currentAsset.AssetType
                if (currentAsset.AssetType == AssetType) { selectedIndex = count  }
                count += 1
            }
            
        }
        
        AssetTypePopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        AssetTypePopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        AssetTypePopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        AssetTypePopupSelector.options = AssetTypes.map { KFPopupSelector.Option.text(text: $0) }
        if (selectedIndex > 0) { AssetTypePopupSelector.selectedIndex = selectedIndex } else { AssetTypePopupSelector.selectedIndex = nil }
        AssetTypePopupSelector.unselectedLabelText = "Select Asset Type"
        AssetTypePopupSelector.displaySelectedValueInLabel = true
    }
    
    
    func PopulateAssetGroupSelector()
    {
        //Get this list of AssetGroups currently available for this user
        AssetGroups = []
        AssetGroupDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, AnyObject> = [:]
        criteria["Type"] = "PPMAssetType" as AnyObject
        criteria["Value"] = AssetType as AnyObject
        criteria["ParentType"] = "PPMAssetGroup" as AnyObject
        
        // go and get the search/filter criteria from the values selected in the session
        var AssetGroupData: [ReferenceData] = [] //NSMutableArray!
        AssetGroups.append("")
        
        // go and get the Asset data based on the criteria built
        AssetGroupData = ModelManager.getInstance().findReferenceDataList(criteria)
        
        for currentAssetGroup: ReferenceData in AssetGroupData
        {
            let currentAssetGroupDisplay: String = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: currentAssetGroup.ParentValue!)
            if(!AssetGroupDictionary.keys.contains(currentAssetGroupDisplay))
            {
                AssetGroups.append(currentAssetGroupDisplay)
                AssetGroupDictionary[currentAssetGroupDisplay] = currentAssetGroup.ParentValue
            }
         }
        
        AssetGroupPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        AssetGroupPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        AssetGroupPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        AssetGroupPopupSelector.options = AssetGroups.map { KFPopupSelector.Option.text(text: $0) }
        AssetGroupPopupSelector.selectedIndex = nil
        AssetGroupPopupSelector.unselectedLabelText = "Select Asset Group"
        AssetGroupPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateTaskNameSelector()
    {
        //Get this list of TaskNames currently available for this user
        TaskNames = []
        TaskNameDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, AnyObject> = [:]
        criteria["Type"] = "PPMTaskType" as AnyObject
        criteria["ParentValue"] = AssetGroup as AnyObject
        criteria["ParentType"] = "PPMAssetGroup" as AnyObject
        
        // go and get the search/filter criteria from the values selected in the session
        var TaskNameData: [ReferenceData] = [] //NSMutableArray!
        TaskNames.append("")
        
        // go and get the TaskName data based on the criteria built
        TaskNameData = ModelManager.getInstance().findReferenceDataList(criteria)
        
        for currentTaskName: ReferenceData in TaskNameData
        {
            //get the relvant task template
            var criteria: Dictionary<String, AnyObject> = [:]
            criteria["OrganisationId"] = Session.OrganisationId! as AnyObject
            criteria["AssetType"] = AssetGroup! as AnyObject
            criteria["TaskName"] = currentTaskName.Value as AnyObject
            criteria["CanCreateFromDevice"] = true as AnyObject
            
            var TaskTemplateData: [TaskTemplate] = []

            TaskTemplateData = ModelManager.getInstance().findTaskTemplateList(criteria)

            if TaskTemplateData.count > 0
            {
                TaskNames.append(currentTaskName.Display)
                TaskNameDictionary[currentTaskName.Display] = currentTaskName.Value
            }
        }
        
        TaskNamePopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        TaskNamePopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        TaskNamePopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        TaskNamePopupSelector.options = TaskNames.map { KFPopupSelector.Option.text(text: $0) }
        TaskNamePopupSelector.selectedIndex = nil
        TaskNamePopupSelector.unselectedLabelText = "Select Task Name"
        TaskNamePopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateAssetNumberSelector()
    {
        //Get this list of AssetNumbers currently available for this user
        AssetNumbers = []
        AssetNumberDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, AnyObject> = [:]
        criteria["PropertyId"] = PropertyId as AnyObject
        criteria["LocationId"] = LocationId as AnyObject
        criteria["AssetType"] = AssetType as AnyObject
        
        // go and get the search/filter criteria from the values selected in the session
        var AssetNumberData: [Asset] = [] //NSMutableArray!
        var selectedIndex: Int = 0
        AssetNumbers.append("")
        
        // go and get the AssetNumber data based on the criteria built
        AssetNumberData = ModelManager.getInstance().findAssetList(criteria)
        
        var count: Int = 1 //we already have the blank row
        for currentAsset: Asset in AssetNumberData
        {
            let currentAssetNumber: String = ModelUtility.getInstance().AssetNumber(currentAsset)
            AssetNumbers.append(currentAssetNumber)
            AssetNumberDictionary[currentAssetNumber] = currentAsset.RowId
            if (currentAssetNumber == AssetNumber) { selectedIndex = count}
            count += 1
        }
        
        AssetNumberPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        AssetNumberPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        AssetNumberPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        AssetNumberPopupSelector.options = AssetNumbers.map { KFPopupSelector.Option.text(text: $0) }
        if (selectedIndex > 0) { AssetNumberPopupSelector.selectedIndex = selectedIndex } else { AssetNumberPopupSelector.selectedIndex = nil }
        AssetNumberPopupSelector.unselectedLabelText = "Select Asset Number"
        AssetNumberPopupSelector.displaySelectedValueInLabel = true
    }
    
    
    @IBAction func SiteChanged(_ sender: KFPopupSelector) {
        //set the site
        if (SitePopupSelector.selectedIndex != nil && Sites[SitePopupSelector.selectedIndex!] != "")
        {
            SiteId = SiteDictionary[Sites[SitePopupSelector.selectedIndex!]]
            
            //do the property stuff
            PopulatePropertySelector()
            PropertyPopupSelector.isEnabled = true
        }
        else
        {
            if (SitePopupSelector.selectedIndex != nil) { SitePopupSelector.selectedIndex = nil }
            SiteId = nil
            PropertyPopupSelector.unselectedLabelText = NotApplicable
            PropertyPopupSelector.isEnabled = false
        }
    }
    
    @IBAction func PropertyChanged(_ sender: KFPopupSelector) {
        //set the property
        if (PropertyPopupSelector.selectedIndex != nil  && Properties[PropertyPopupSelector.selectedIndex!] != "")
        {
            PropertyId = PropertyDictionary[Properties[PropertyPopupSelector.selectedIndex!]]
            
            //do the locationgroup stuff
            PopulateLocationGroupSelector()
            LocationGroupPopupSelector.isEnabled = true
        }
        else
        {
            if (PropertyPopupSelector.selectedIndex != nil) { PropertyPopupSelector.selectedIndex = nil }
            PropertyId = nil
            LocationGroupPopupSelector.unselectedLabelText = NotApplicable
            LocationGroupPopupSelector.isEnabled = false
        }
    }

    @IBAction func LocationGroupChanged(_ sender: KFPopupSelector) {
        //set the location group
        if (LocationGroupPopupSelector.selectedIndex != nil && LocationGroups[LocationGroupPopupSelector.selectedIndex!] != "")
        {
            LocationGroupId = LocationGroupDictionary[LocationGroups[LocationGroupPopupSelector.selectedIndex!]]
            LocationGroupName = LocationGroups[LocationGroupPopupSelector.selectedIndex!]
            
            //do the location stuff
            PopulateLocationSelector()
            LocationPopupSelector.isEnabled = true
        }
        else
        {
            if (LocationGroupPopupSelector.selectedIndex != nil) { LocationGroupPopupSelector.selectedIndex = nil }
            LocationGroupId = nil
            LocationGroupName = nil
            LocationPopupSelector.unselectedLabelText = NotApplicable
            LocationPopupSelector.isEnabled = false
        }
    }
    
    @IBAction func LocationChanged(_ sender: KFPopupSelector) {
        //set the location
        if (LocationPopupSelector.selectedIndex != nil && Locations[LocationPopupSelector.selectedIndex!] != "")
        {
            LocationId = LocationDictionary[Locations[LocationPopupSelector.selectedIndex!]]
            LocationName = Locations[LocationPopupSelector.selectedIndex!]
            //do the asset type stuff
            PopulateAssetTypeSelector()
            AssetTypePopupSelector.isEnabled = true
        }
        else
        {
            if (LocationPopupSelector.selectedIndex != nil) { LocationPopupSelector.selectedIndex = nil }
            LocationId = nil
            LocationName = nil
            AssetTypePopupSelector.unselectedLabelText = NotApplicable
            AssetTypePopupSelector.isEnabled = false
        }
    }
    
    @IBAction func AssetTypeChanged(_ sender: KFPopupSelector) {
        //set the asset type
        if (AssetTypePopupSelector.selectedIndex != nil && AssetTypes[AssetTypePopupSelector.selectedIndex!] != "")
        {
            AssetType = AssetTypeDictionary[AssetTypes[AssetTypePopupSelector.selectedIndex!]]

            //do the AssetNumber stuff
            PopulateAssetNumberSelector()
            AssetNumberPopupSelector.isEnabled = true        }
        else
        {
            if (AssetTypePopupSelector.selectedIndex != nil) { AssetTypePopupSelector.selectedIndex = nil }
            AssetType = nil
            AssetNumberPopupSelector.unselectedLabelText = NotApplicable
            AssetNumberPopupSelector.isEnabled = false
       }
    }
    
    @IBAction func AssetGroupChanged(_ sender: KFPopupSelector) {
        //set the asset group
        if (AssetGroupPopupSelector.selectedIndex != nil && AssetGroups[AssetGroupPopupSelector.selectedIndex!] != "")
        {
            AssetGroup = AssetGroupDictionary[AssetGroups[AssetGroupPopupSelector.selectedIndex!]]
            
            //do the Task name stuff
            PopulateTaskNameSelector()
            TaskNamePopupSelector.isEnabled = true
        }
        else
        {
            if (AssetGroupPopupSelector.selectedIndex != nil) { AssetGroupPopupSelector.selectedIndex = nil }
            AssetGroup = nil
            TaskNamePopupSelector.unselectedLabelText = NotApplicable
            TaskNamePopupSelector.isEnabled = false
        }
    }
    
    @IBAction func TaskNameChanged(_ sender: KFPopupSelector) {
        //set the task name
        if (TaskNamePopupSelector.selectedIndex != nil && TaskNames[TaskNamePopupSelector.selectedIndex!] != "")
        {
            TaskName = TaskNameDictionary[TaskNames[TaskNamePopupSelector.selectedIndex!]]
        }
        else
        {
            if (TaskNamePopupSelector.selectedIndex != nil) { TaskNamePopupSelector.selectedIndex = nil }
            TaskName = nil
        }
    }
    
    @IBAction func AssetNumberChanged(_ sender: KFPopupSelector) {
        //set the AssetNumber
        if (AssetNumberPopupSelector.selectedIndex != nil && AssetNumbers[AssetNumberPopupSelector.selectedIndex!] != "")
        {
            AssetId = AssetNumberDictionary[AssetNumbers[AssetNumberPopupSelector.selectedIndex!]]
            AssetNumber = AssetNumberPopupSelector.selectedValue
            
            //do the asset group stuff
            PopulateAssetGroupSelector()
            AssetGroupPopupSelector.isEnabled = true
        }
        else
        {
            if (AssetNumberPopupSelector.selectedIndex != nil) { AssetNumberPopupSelector.selectedIndex = nil }
            AssetId = nil
            AssetGroupPopupSelector.unselectedLabelText = NotApplicable
            AssetGroupPopupSelector.isEnabled = false
       }
    }
}
