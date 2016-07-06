//
//  FilterViewController.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 25/02/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet var TaskSortSegment: UISegmentedControl!
    
    @IBOutlet var SitePopupSelector: KFPopupSelector!
    @IBOutlet var PropertyPopupSelector: KFPopupSelector!
    @IBOutlet var FrequencyPopupSelector: KFPopupSelector!
    @IBOutlet var PeriodPopupSelector: KFPopupSelector!
    
    @IBOutlet var JustMyTasks: UISwitch!
    
    @IBOutlet var AssetGroupPopupSelector: KFPopupSelector!
    @IBOutlet var TaskNamePopupSelector: KFPopupSelector!
    @IBOutlet var AssetTypePopupSelector: KFPopupSelector!
    @IBOutlet var LocationGroupPopupSelector: KFPopupSelector!
    @IBOutlet var LocationPopupSelector: KFPopupSelector!
    @IBOutlet var AssetNumberPopupSelector: KFPopupSelector!
    
    var Sites: [String] = []
    var SiteDictionary: Dictionary<String, String> = [:]
    
    var Properties: [String] = []
    var PropertyDictionary: Dictionary<String, String> = [:]

    var Frequencies: [String] = []
    var FrequencyDictionary: Dictionary<String, String> = [:]
    
    var Periods: [String] = ["Due Today", "Due This Week", "Due This Month", "Due By the End of Next Month", "All"]

    var AssetGroups: [String] = []
    var AssetGroupDictionary: Dictionary<String, String> = [:]
    
    var TaskNames: [String] = []
    var TaskNameDictionary: Dictionary<String, String> = [:]
    
    var AssetTypes: [String] = []
    var AssetTypeDictionary: Dictionary<String, String> = [:]
    
    var LocationGroups: [String] = []
    var LocationGroupDictionary: Dictionary<String, String> = [:]
    
    var Locations: [String] = []
    var LocationDictionary: Dictionary<String, String> = [:]
    
    var AssetNumbers: [String] = []
    var AssetNumberDictionary: Dictionary<String, String> = [:]
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
 
        
        switch Session.TaskSort
        {
            case .Date:
                TaskSortSegment.selectedSegmentIndex = 0
            
            case .Location:
                TaskSortSegment.selectedSegmentIndex = 1
            
            case .AssetType:
                TaskSortSegment.selectedSegmentIndex = 2

            case .Task:
                TaskSortSegment.selectedSegmentIndex = 3
        }
     
        JustMyTasks.on = Session.FilterJustMyTasks
 
        PropertyPopupSelector.unselectedLabelText = NotApplicable
        PropertyPopupSelector.enabled = false
        
        AssetGroupPopupSelector.unselectedLabelText = NotApplicable
        AssetGroupPopupSelector.enabled = false
        
        TaskNamePopupSelector.unselectedLabelText = NotApplicable
        TaskNamePopupSelector.enabled = false
        
        AssetTypePopupSelector.unselectedLabelText = NotApplicable
        AssetTypePopupSelector.enabled = false
        
        LocationGroupPopupSelector.unselectedLabelText = NotApplicable
        LocationGroupPopupSelector.enabled = false
        
        LocationPopupSelector.unselectedLabelText = NotApplicable
        LocationPopupSelector.enabled = false
        
        AssetNumberPopupSelector.unselectedLabelText = NotApplicable
        AssetNumberPopupSelector.enabled = false
        
        PopulateSiteSelector()
        PopulateFrequencySelector()
        PopulatePeriodSelector()
    }

    @IBAction func Cancel(sender: UIBarButtonItem) {
        Session.ClearFilter();
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func Done(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
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
    }

    func PopulateSiteSelector()
    {
        //Get this list of sites currently available for this user
        Sites = []
        SiteDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, String> = [:]
        criteria["OrganisationId"] = Session.OrganisationId
        
        var siteData: [Site] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        Sites.append("")
        
        // go and get the site data based on the criteria built
        siteData = ModelManager.getInstance().findSiteList(criteria)
        
        var count: Int = 1 //we already have the blank row
        for currentSite: Site in siteData
        {
            Sites.append(currentSite.Name)
            SiteDictionary[currentSite.Name] = currentSite.RowId
            if( Session.FilterSiteId != nil)
            {
                if (currentSite.RowId == Session.FilterSiteId!) { selectedIndex = count }
            }
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterSiteId = nil }
        
        SitePopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        SitePopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        SitePopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        SitePopupSelector.options = Sites.map { KFPopupSelector.Option.Text(text: $0) }
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
        var criteria: Dictionary<String, String> = [:]
        criteria["SiteId"] = Session.FilterSiteId
        
        var PropertyData: [Property] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        Properties.append("")
        
        // go and get the Property data based on the criteria built
        PropertyData = ModelManager.getInstance().findPropertyList(criteria)
        
        var count: Int = 1 //we already have the blank row
        for currentProperty: Property in PropertyData
        {
            Properties.append(currentProperty.Name)
            PropertyDictionary[currentProperty.Name] = currentProperty.RowId
            if (currentProperty.RowId == Session.FilterPropertyId) { selectedIndex = count }
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterPropertyId = nil }
        
        PropertyPopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        PropertyPopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        PropertyPopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        PropertyPopupSelector.options = Properties.map { KFPopupSelector.Option.Text(text: $0) }
        if (selectedIndex > 0) { PropertyPopupSelector.selectedIndex = selectedIndex } else { PropertyPopupSelector.selectedIndex = nil }
        PropertyPopupSelector.unselectedLabelText = "Select Property"
        PropertyPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateFrequencySelector()
    {
        //Get this list of Frequencys currently available for this user
        Frequencies = []
        FrequencyDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var criteria: Dictionary<String, String> = [:]
        criteria["Type"] = "PPMFrequency"
        
        var FrequencyData: [ReferenceData] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        Frequencies.append("")
        
        // go and get the Frequency data based on the criteria built
        (FrequencyData, _) = ModelManager.getInstance().findReferenceDataList(criteria, pageSize: nil, pageNumber: nil, sortOrder: ReferenceDataSortOrder.Ordinal)
        
        var count: Int = 1 //we already have the blank row
        for currentFrequency: ReferenceData in FrequencyData
        {
            Frequencies.append(currentFrequency.Display)
            FrequencyDictionary[currentFrequency.Display] = currentFrequency.Value
            if (currentFrequency.Display == Session.FilterFrequency) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterFrequency = nil }
        
        Frequencies.append("All")
        FrequencyDictionary["All"] = "All"
        
        FrequencyPopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        FrequencyPopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        FrequencyPopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        FrequencyPopupSelector.options = Frequencies.map { KFPopupSelector.Option.Text(text: $0) }
        if (selectedIndex > 0) { FrequencyPopupSelector.selectedIndex = selectedIndex } else { FrequencyPopupSelector.selectedIndex = nil }
        FrequencyPopupSelector.unselectedLabelText = "Select Frequency"
        FrequencyPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulatePeriodSelector()
    {
        //Get this list of Periods currently available for this user
        var selectedIndex: Int? = 0
        
        var count: Int = 0
        for currentPeriod: String in Periods
        {
            if (currentPeriod == Session.FilterPeriod) { selectedIndex = count }
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterPeriod = nil }
        
        PeriodPopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        PeriodPopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        PeriodPopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        PeriodPopupSelector.options = Periods.map { KFPopupSelector.Option.Text(text: $0) }
        if (selectedIndex > -1) { PeriodPopupSelector.selectedIndex = selectedIndex } else { PeriodPopupSelector.selectedIndex = nil }
        PeriodPopupSelector.unselectedLabelText = "Select Period"
        PeriodPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateAssetGroupSelector()
    {
        //Get this list of AssetGroups currently available for this user
        AssetGroups = []
        AssetGroupDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var AssetGroupData: [String] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        AssetGroups.append("")
        
        // go and get the AssetGroup data based on the criteria built
        AssetGroupData = ModelUtility.getInstance().GetFilterAssetGroupList(Session.FilterPropertyId!, LocationGroupName: Session.FilterLocationGroup, Location: Session.FilterLocation)
        
        var count: Int = 1 //we already have the blank row
        for currentAssetGroup: String in AssetGroupData
        {
            let currentAssetGroupDisplay: String = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetGroup", key: currentAssetGroup)
            AssetGroups.append(currentAssetGroupDisplay)
            AssetGroupDictionary[currentAssetGroupDisplay] = currentAssetGroup
            if (currentAssetGroup == Session.FilterAssetGroup) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterAssetGroup = nil }
        
        AssetGroupPopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        AssetGroupPopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        AssetGroupPopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        AssetGroupPopupSelector.options = AssetGroups.map { KFPopupSelector.Option.Text(text: $0) }
        if (selectedIndex > 0) { AssetGroupPopupSelector.selectedIndex = selectedIndex } else { AssetGroupPopupSelector.selectedIndex = nil }
        AssetGroupPopupSelector.unselectedLabelText = "Select Asset Group"
        AssetGroupPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateTaskNameSelector()
    {
        //Get this list of TaskNames currently available for this user
        TaskNames = []
        TaskNameDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var TaskNameData: [String] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        TaskNames.append("")
        
        // go and get the TaskName data based on the criteria built
        TaskNameData = ModelUtility.getInstance().GetFilterTaskNameList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup!, AssetType: Session.FilterAssetType, LocationGroupName: Session.FilterLocationGroup, Location: Session.FilterLocation)
        
        var count: Int = 1 //we already have the blank row
        for currentTaskName: String in TaskNameData
        {
            var currentTaskNameDisplay: String = currentTaskName
            if (currentTaskNameDisplay != RemedialTask)
            {
                currentTaskNameDisplay = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMTaskType", key: currentTaskName, parentType: "PPMAssetGroup", parentValue: Session.FilterAssetGroup)
            }
            TaskNames.append(currentTaskNameDisplay)
            TaskNameDictionary[currentTaskNameDisplay] = currentTaskName
            if (currentTaskName == Session.FilterTaskName) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterTaskName = nil }
        
        TaskNamePopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        TaskNamePopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        TaskNamePopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        TaskNamePopupSelector.options = TaskNames.map { KFPopupSelector.Option.Text(text: $0) }
        if (selectedIndex > 0) { TaskNamePopupSelector.selectedIndex = selectedIndex } else { TaskNamePopupSelector.selectedIndex = nil }
        TaskNamePopupSelector.unselectedLabelText = "Select Task Name"
        TaskNamePopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateAssetTypeSelector()
    {
        //Get this list of AssetTypes currently available for this user
        AssetTypes = []
        AssetTypeDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var AssetTypeData: [String] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        AssetTypes.append("")
        
        // go and get the AssetType data based on the criteria built
        AssetTypeData = ModelUtility.getInstance().GetFilterAssetTypeList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup!, TaskName: Session.FilterTaskName, LocationGroupName: Session.FilterLocationGroup, Location: Session.FilterLocation)
        
        var count: Int = 1 //we already have the blank row
        for currentAssetType: String in AssetTypeData
        {
            let currentAssetTypeDisplay: String = ModelUtility.getInstance().ReferenceDataDisplayFromValue("PPMAssetType", key: currentAssetType, parentType: "PPMAssetGroup", parentValue: Session.FilterAssetGroup)
            AssetTypes.append(currentAssetTypeDisplay)
            AssetTypeDictionary[currentAssetTypeDisplay] = currentAssetType
            if (currentAssetType == Session.FilterAssetType) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterAssetType = nil }
        
        AssetTypePopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        AssetTypePopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        AssetTypePopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        AssetTypePopupSelector.options = AssetTypes.map { KFPopupSelector.Option.Text(text: $0) }
        if (selectedIndex > 0) { AssetTypePopupSelector.selectedIndex = selectedIndex } else { AssetTypePopupSelector.selectedIndex = nil }
        AssetTypePopupSelector.unselectedLabelText = "Select Asset Type"
        AssetTypePopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateLocationGroupSelector()
    {
        //Get this list of LocationGroups currently available for this user
        LocationGroups = []
        LocationGroupDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var LocationGroupData: [String] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        LocationGroups.append("")
        
        // go and get the LocationGroup data based on the criteria built
        LocationGroupData = ModelUtility.getInstance().GetFilterLocationGroupList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup, TaskName: Session.FilterTaskName, AssetType: Session.FilterAssetType)
        
        var count: Int = 1 //we already have the blank row
        for currentLocationGroup: String in LocationGroupData
        {
            let currentLocationGroupDisplay: String = currentLocationGroup
            LocationGroups.append(currentLocationGroupDisplay)
            LocationGroupDictionary[currentLocationGroupDisplay] = currentLocationGroup
            if (currentLocationGroup == Session.FilterLocationGroup) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterLocationGroup = nil }
        
        LocationGroupPopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        LocationGroupPopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        LocationGroupPopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        LocationGroupPopupSelector.options = LocationGroups.map { KFPopupSelector.Option.Text(text: $0) }
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
        var LocationData: [String] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        Locations.append("")
        
        // go and get the Location data based on the criteria built
        LocationData = ModelUtility.getInstance().GetFilterLocationList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup, TaskName: Session.FilterTaskName, AssetType: Session.FilterAssetType, LocationGroupName: Session.FilterLocationGroup!)
        
        var count: Int = 1 //we already have the blank row
        for currentLocation: String in LocationData
        {
            let currentLocationDisplay: String = currentLocation
            Locations.append(currentLocationDisplay)
            LocationDictionary[currentLocationDisplay] = currentLocation
            if (currentLocation == Session.FilterLocation) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterLocation = nil }
        
        LocationPopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        LocationPopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        LocationPopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        LocationPopupSelector.options = Locations.map { KFPopupSelector.Option.Text(text: $0) }
        if (selectedIndex > 0) { LocationPopupSelector.selectedIndex = selectedIndex } else { LocationPopupSelector.selectedIndex = nil }
        LocationPopupSelector.unselectedLabelText = "Select Location"
        LocationPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulateAssetNumberSelector()
    {
        //Get this list of AssetNumbers currently available for this user
        AssetNumbers = []
        AssetNumberDictionary = [:]
        
        // go and get the search/filter criteria from the values selected in the session
        var AssetNumberData: [String] = [] //NSMutableArray!
        var selectedIndex: Int? = 0
        AssetNumbers.append("")
        
        // go and get the AssetNumber data based on the criteria built
        AssetNumberData = ModelUtility.getInstance().GetFilterAssetNumberList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup, TaskName: Session.FilterTaskName, AssetType: Session.FilterAssetType, LocationGroupName: Session.FilterLocationGroup, Location: Session.FilterLocation)
        
        var count: Int = 1 //we already have the blank row
        for currentAssetNumber: String in AssetNumberData
        {
            let currentAssetNumberDisplay: String = currentAssetNumber
            AssetNumbers.append(currentAssetNumberDisplay)
            AssetNumberDictionary[currentAssetNumberDisplay] = currentAssetNumber
            if (currentAssetNumber == Session.FilterAssetNumber) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterAssetNumber = nil }
        
        AssetNumberPopupSelector.buttonContentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        AssetNumberPopupSelector.setLabelFont(UIFont.systemFontOfSize(17))
        AssetNumberPopupSelector.setTableFont(UIFont.systemFontOfSize(17))
        AssetNumberPopupSelector.options = AssetNumbers.map { KFPopupSelector.Option.Text(text: $0) }
        if (selectedIndex > 0) { AssetNumberPopupSelector.selectedIndex = selectedIndex } else { AssetNumberPopupSelector.selectedIndex = nil }
        AssetNumberPopupSelector.unselectedLabelText = "Select Asset Number"
        AssetNumberPopupSelector.displaySelectedValueInLabel = true
    }
    
    
    //MARK : Action from selection
    
    @IBAction func SiteChanged(sender: KFPopupSelector) {
        //set the site filter
        if (SitePopupSelector.selectedIndex != nil && Sites[SitePopupSelector.selectedIndex!] != "")
        {
            Session.FilterSiteId = SiteDictionary[Sites[SitePopupSelector.selectedIndex!]]
            Session.FilterSiteName = Sites[SitePopupSelector.selectedIndex!]
        
            //do the property stuff
            PopulatePropertySelector()
            PropertyPopupSelector.enabled = true
        }
        else
        {
            if (SitePopupSelector.selectedIndex != nil) { SitePopupSelector.selectedIndex = nil }
            Session.FilterSiteId = nil
            Session.FilterSiteName = nil
            PropertyPopupSelector.unselectedLabelText = NotApplicable
            PropertyPopupSelector.enabled = false
        }
    }
    
    @IBAction func PropertyChanged(sender: KFPopupSelector) {
        //set the property filter
        if (PropertyPopupSelector.selectedIndex != nil  && Properties[PropertyPopupSelector.selectedIndex!] != "")
        {
            Session.FilterPropertyId = PropertyDictionary[Properties[PropertyPopupSelector.selectedIndex!]]
            Session.FilterPropertyName = Properties[PropertyPopupSelector.selectedIndex!]
        
            //do the asset group stuff
            PopulateAssetGroupSelector()
            AssetGroupPopupSelector.enabled = true
        
            //do the are stuff
            PopulateLocationGroupSelector()
            LocationGroupPopupSelector.enabled = true
        }
        else
        {
            if (PropertyPopupSelector.selectedIndex != nil) { PropertyPopupSelector.selectedIndex = nil }
            Session.FilterPropertyId = nil
            Session.FilterPropertyName = nil
            AssetGroupPopupSelector.unselectedLabelText = NotApplicable
            AssetGroupPopupSelector.enabled = false
            
            LocationGroupPopupSelector.unselectedLabelText = NotApplicable
            LocationGroupPopupSelector.enabled = false
        }
    }
 
    @IBAction func FrequencyChanged(sender: KFPopupSelector) {
        if (FrequencyPopupSelector.selectedIndex != nil && Frequencies[FrequencyPopupSelector.selectedIndex!] != "")
        {
            Session.FilterFrequency = FrequencyDictionary[Frequencies[FrequencyPopupSelector.selectedIndex!]]
        }
        else
        {
            if (FrequencyPopupSelector.selectedIndex != nil) { FrequencyPopupSelector.selectedIndex = nil }
            Session.FilterFrequency = nil
        }
    }
    
    @IBAction func PeriodChanged(sender: KFPopupSelector) {
        if (PeriodPopupSelector.selectedIndex != nil && Periods[PeriodPopupSelector.selectedIndex!] != "")
        {
            Session.FilterPeriod = Periods[PeriodPopupSelector.selectedIndex!]
        }
        else
        {
            Session.FilterPeriod = nil
        }
    }
    
    @IBAction func MyTasksChanged(sender: UISwitch) {
        Session.FilterJustMyTasks = sender.on
    }
    
    @IBAction func AssetGroupChanged(sender: KFPopupSelector) {
        //set the property filter
        if (AssetGroupPopupSelector.selectedIndex != nil && AssetGroups[AssetGroupPopupSelector.selectedIndex!] != "")
        {
            Session.FilterAssetGroup = AssetGroupDictionary[AssetGroups[AssetGroupPopupSelector.selectedIndex!]]
            
            //do the Task name stuff
            PopulateTaskNameSelector()
            TaskNamePopupSelector.enabled = true
        }
        else
        {
            if (AssetGroupPopupSelector.selectedIndex != nil) { AssetGroupPopupSelector.selectedIndex = nil }
            Session.FilterAssetGroup = nil
            TaskNamePopupSelector.unselectedLabelText = NotApplicable
            TaskNamePopupSelector.enabled = false
        }
    }
    
    @IBAction func TaskNameChange(sender: KFPopupSelector) {
        //set the property filter
        if (TaskNamePopupSelector.selectedIndex != nil && TaskNames[TaskNamePopupSelector.selectedIndex!] != "")
        {
            if(TaskNames[TaskNamePopupSelector.selectedIndex!] == RemedialTask)
            {
                 Session.FilterTaskName = RemedialTask
            }
            else
            {
                Session.FilterTaskName = TaskNameDictionary[TaskNames[TaskNamePopupSelector.selectedIndex!]]
            }
            
            //do the AssetType stuff
            PopulateAssetTypeSelector()
            AssetTypePopupSelector.enabled = true
        }
        else
        {
            if (TaskNamePopupSelector.selectedIndex != nil) { TaskNamePopupSelector.selectedIndex = nil }
            Session.FilterTaskName = nil
            AssetTypePopupSelector.unselectedLabelText = NotApplicable
            AssetTypePopupSelector.enabled = false
        }
    }
    
    @IBAction func AssetTypeChanged(sender: KFPopupSelector) {
        //set the property filter
        if (AssetTypePopupSelector.selectedIndex != nil && AssetTypes[AssetTypePopupSelector.selectedIndex!] != "")
        {
            Session.FilterAssetType = AssetTypeDictionary[AssetTypes[AssetTypePopupSelector.selectedIndex!]]
        }
        else
        {
            if (AssetTypePopupSelector.selectedIndex != nil) { AssetTypePopupSelector.selectedIndex = nil }
            Session.FilterAssetType = nil
        }
    }
    
    @IBAction func LocationGroupChanged(sender: KFPopupSelector) {
        //set the property filter
        if (LocationGroupPopupSelector.selectedIndex != nil && LocationGroups[LocationGroupPopupSelector.selectedIndex!] != "")
        {
            Session.FilterLocationGroup = LocationGroupDictionary[LocationGroups[LocationGroupPopupSelector.selectedIndex!]]
            
            //do the AssetType stuff
            PopulateLocationSelector()
            LocationPopupSelector.enabled = true
        }
        else
        {
            if (LocationGroupPopupSelector.selectedIndex != nil) { LocationGroupPopupSelector.selectedIndex = nil }
            Session.FilterLocationGroup = nil
            LocationPopupSelector.unselectedLabelText = NotApplicable
            LocationPopupSelector.enabled = false
        }
    }
    
    @IBAction func LocationChanged(sender: KFPopupSelector) {
        //set the property filter
        if (LocationPopupSelector.selectedIndex != nil && Locations[LocationPopupSelector.selectedIndex!] != "")
        {
            Session.FilterLocation = LocationDictionary[Locations[LocationPopupSelector.selectedIndex!]]
            
            //do the AssetNumber stuff
            PopulateAssetNumberSelector()
            AssetNumberPopupSelector.enabled = true
        }
        else
        {
            if (LocationPopupSelector.selectedIndex != nil) { LocationPopupSelector.selectedIndex = nil }
            Session.FilterLocation = nil
            AssetNumberPopupSelector.unselectedLabelText = NotApplicable
            AssetNumberPopupSelector.enabled = false
        }
    }
    
    @IBAction func AssetNumberChanged(sender: KFPopupSelector) {
        //set the property filter
        if (AssetNumberPopupSelector.selectedIndex != nil && AssetNumbers[AssetNumberPopupSelector.selectedIndex!] != "")
        {
            Session.FilterAssetNumber = AssetNumberDictionary[AssetNumbers[AssetNumberPopupSelector.selectedIndex!]]
        }
        else
        {
            if (AssetNumberPopupSelector.selectedIndex != nil) { AssetNumberPopupSelector.selectedIndex = nil }
            Session.FilterAssetNumber = nil
        }
    }
    
}
        

    

