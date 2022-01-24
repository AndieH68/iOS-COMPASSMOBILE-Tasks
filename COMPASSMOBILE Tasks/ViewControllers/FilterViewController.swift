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
    
    var Periods: [String] = [DueTodayText, DueNext7DaysText, DueCalendarMonthText, DueThisMonthText, "All"]

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
    
    fileprivate func resetFilter() {
        
        JustMyTasks.isOn = Session.FilterJustMyTasks
        Session.InvalidateCachedFilterJustMyTasksClause = true
        
        SitePopupSelector.unselectedLabelText = NotApplicable
        SitePopupSelector.isEnabled = false

        PropertyPopupSelector.unselectedLabelText = NotApplicable
        PropertyPopupSelector.isEnabled = false
        
        AssetGroupPopupSelector.unselectedLabelText = NotApplicable
        AssetGroupPopupSelector.isEnabled = false
        
        TaskNamePopupSelector.unselectedLabelText = NotApplicable
        TaskNamePopupSelector.isEnabled = false
        
        AssetTypePopupSelector.unselectedLabelText = NotApplicable
        AssetTypePopupSelector.isEnabled = false
        
        LocationGroupPopupSelector.unselectedLabelText = NotApplicable
        LocationGroupPopupSelector.isEnabled = false
        
        LocationPopupSelector.unselectedLabelText = NotApplicable
        LocationPopupSelector.isEnabled = false
        
        AssetNumberPopupSelector.unselectedLabelText = NotApplicable
        AssetNumberPopupSelector.isEnabled = false
        
        if(!Session.FilterOnTasks)
        {
            PopulateSiteSelector()
            PopulateFrequencySelector()
            PopulatePeriodSelector()
            SitePopupSelector.isEnabled = true
        }
        else
        {
            inChangeProcess = true
            PopulateSiteSelector()
            SitePopupSelector.isEnabled = true
            PopulatePropertySelector()
            PropertyPopupSelector.isEnabled = true
            PopulateFrequencySelector()
            FrequencyPopupSelector.isEnabled = true
            PopulatePeriodSelector()
            PeriodPopupSelector.isEnabled = true
            PopulateAssetGroupSelector()
            AssetGroupPopupSelector.isEnabled = true
            PopulateTaskNameSelector()
            TaskNamePopupSelector.isEnabled = true
            PopulateAssetTypeSelector()
            AssetTypePopupSelector.isEnabled = true
            PopulateLocationGroupSelector()
            LocationGroupPopupSelector.isEnabled = true
            PopulateLocationSelector()
            LocationPopupSelector.isEnabled = true
            PopulateAssetNumberSelector()
            AssetNumberPopupSelector.isEnabled = true
            inChangeProcess = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        
        switch Session.TaskSort
        {
            case .date:
                TaskSortSegment.selectedSegmentIndex = 0
            
            case .location:
                TaskSortSegment.selectedSegmentIndex = 1
            
            case .assetType:
                TaskSortSegment.selectedSegmentIndex = 2

            case .task:
                TaskSortSegment.selectedSegmentIndex = 3
        }
     
        resetFilter()
    }

    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        Session.ClearFilter();
        _ = self.navigationController?.popViewController(animated: true)
        //resetFilter()
    }
    
    @IBAction func Done(_ sender: UIBarButtonItem) {
        if(Session.RememberFilterSettings)
        {
            let defaults = UserDefaults.standard
            defaults.set(Session.FilterSiteId, forKey: "FilterSiteId")
            defaults.set(Session.FilterSiteName, forKey: "FilterSiteName")
            defaults.set(Session.FilterPropertyId, forKey: "FilterPropertyId")
            defaults.set(Session.FilterPropertyName, forKey: "FilterPropertyName")
            defaults.set(Session.FilterFrequency, forKey: "FilterFrequency")
            defaults.set(Session.FilterPeriod, forKey: "FilterPeriod")
            
            defaults.set(Session.FilterJustMyTasks, forKey: "FilterJustMyTasks")
            
            defaults.set(Session.FilterAssetGroup, forKey: "FilterAssetGroup")
            defaults.set(Session.FilterTaskName, forKey: "FilterTaskName")
            defaults.set(Session.FilterAssetType, forKey: "FilterAssetType")
            defaults.set(Session.FilterLocationGroup, forKey: "FilterLocationGroup")
            defaults.set(Session.FilterLocation, forKey: "FilterLocation")
            defaults.set(Session.FilterAssetNumber, forKey: "FilterAssetNumber")
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func TaskFilterSort(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            Session.TaskSort = TaskSortOrder.date
        case 1:
            Session.TaskSort = TaskSortOrder.location
        case 2:
            Session.TaskSort = TaskSortOrder.assetType
        case 3:
            Session.TaskSort = TaskSortOrder.task
        default:
            Session.TaskSort = TaskSortOrder.date
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
        
        // go and get the search/filter criteria from the values selected in the session
        var SiteIds: [String] = [] //NSMutableArray!
        var selectedIndex: Int = 0
        Sites.append("")
        
        // go and get the AssetGroup data based on the criteria built
        if (Session.FilterOnTasks)
        {
            SiteIds = ModelUtility.getInstance().GetTaskFilterSiteList(Session.OrganisationId!)
        }
        else
        {
            SiteIds = ModelUtility.getInstance().GetFilterSiteList(Session.OrganisationId!)
        }
        
        var count: Int = 1 //we already have the blank row
        for currentSiteId: String in SiteIds
        {
            let site: Site = ModelManager.getInstance().getSite(currentSiteId)!

            Sites.append(site.Name)
            SiteDictionary[site.Name] = currentSiteId
            if (currentSiteId == Session.FilterSiteId) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterSiteId = nil }
        
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
        
        var PropertyIds: [String] = [] //NSMutableArray!
        var selectedIndex: Int = 0
        Properties.append("")
        
        // go and get the AssetGroup data based on the criteria built
        if (Session.FilterOnTasks)
        {
            PropertyIds = ModelUtility.getInstance().GetTaskFilterPropertyList(Session.OrganisationId!)
        }
        else
        {
            PropertyIds = ModelUtility.getInstance().GetFilterPropertyList(Session.FilterSiteId!)
        }
        
        var count: Int = 1 //we already have the blank row
        for currentPropertyId: String in PropertyIds
        {
            let property: Property = ModelManager.getInstance().getProperty(currentPropertyId)!
            
            Properties.append(property.Name)
            PropertyDictionary[property.Name] = currentPropertyId
            if (currentPropertyId == Session.FilterPropertyId) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterPropertyId = nil }
        
        PropertyPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        PropertyPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        PropertyPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        PropertyPopupSelector.options = Properties.map { KFPopupSelector.Option.text(text: $0) }
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
        var criteria: Dictionary<String, AnyObject> = [:]
        criteria["Type"] = "PPMFrequency" as AnyObject
        
        var FrequencyData: [ReferenceData] = [] //NSMutableArray!
        var selectedIndex: Int = 0
        Frequencies.append("")

        Frequencies.append("All")
        FrequencyDictionary["All"] = "All"
        if (Session.FilterFrequency?.localizedLowercase == "all") { selectedIndex = 1 }
        
        Frequencies.append("Ad-hoc")
        FrequencyDictionary["Ad-hoc"] = "Ad-hoc"
        if (Session.FilterFrequency?.localizedLowercase == "ad-hoc") { selectedIndex = 2 }
        
        // go and get the Frequency data based on the criteria built
        (FrequencyData, _) = ModelManager.getInstance().findReferenceDataList(criteria, pageSize: nil, pageNumber: nil, sortOrder: ReferenceDataSortOrder.ordinal)
        
        var count: Int = 3 //we already have the blank row, All and Ad-hoc
        for currentFrequency: ReferenceData in FrequencyData
        {
            Frequencies.append(currentFrequency.Display)
            FrequencyDictionary[currentFrequency.Display] = currentFrequency.Display.localizedLowercase
            if (currentFrequency.Display.localizedLowercase == Session.FilterFrequency?.localizedLowercase) { selectedIndex = count}
            count += 1
        }
        if (selectedIndex == 0) { Session.FilterFrequency = nil }
        
        FrequencyPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        FrequencyPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        FrequencyPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        FrequencyPopupSelector.options = Frequencies.map { KFPopupSelector.Option.text(text: $0) }
        if (selectedIndex > 0) { FrequencyPopupSelector.selectedIndex = selectedIndex } else { FrequencyPopupSelector.selectedIndex = nil }
        FrequencyPopupSelector.unselectedLabelText = "Select Frequency"
        FrequencyPopupSelector.displaySelectedValueInLabel = true
    }
    
    func PopulatePeriodSelector()
    {
        //Get this list of Periods currently available for this user
        var selectedIndex: Int = 0
        
        var count: Int = 0
        for currentPeriod: String in Periods
        {
            if (currentPeriod == Session.FilterPeriod) { selectedIndex = count }
            count += 1
        }

        PeriodPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        PeriodPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        PeriodPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        PeriodPopupSelector.options = Periods.map { KFPopupSelector.Option.text(text: $0) }
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
        var selectedIndex: Int = 0
        AssetGroups.append("")
        
        // go and get the AssetGroup data based on the criteria built
        if (Session.FilterOnTasks)
        {
            AssetGroupData = ModelUtility.getInstance().GetTaskFilterAssetGroupList(Session.OrganisationId!)
        }
        else
        {
            AssetGroupData = ModelUtility.getInstance().GetFilterAssetGroupList(Session.FilterPropertyId!, LocationGroupName: Session.FilterLocationGroup, Location: Session.FilterLocation)
        }
        
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
        
        AssetGroupPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        AssetGroupPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        AssetGroupPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        AssetGroupPopupSelector.options = AssetGroups.map { KFPopupSelector.Option.text(text: $0) }
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
        var selectedIndex: Int = 0
        TaskNames.append("")
        
        // go and get the TaskName data based on the criteria built
        if (Session.FilterOnTasks)
        {
            TaskNameData = ModelUtility.getInstance().GetTaskFilterTaskNameList(Session.OrganisationId!)
        }
        else
        {
            TaskNameData = ModelUtility.getInstance().GetFilterTaskNameList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup!, AssetType: Session.FilterAssetType, LocationGroupName: Session.FilterLocationGroup, Location: Session.FilterLocation)
        }
        
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
        
        TaskNamePopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        TaskNamePopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        TaskNamePopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        TaskNamePopupSelector.options = TaskNames.map { KFPopupSelector.Option.text(text: $0) }
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
        var selectedIndex: Int = 0
        AssetTypes.append("")
        
        // go and get the AssetType data based on the criteria built
        if (Session.FilterOnTasks)
        {
            AssetTypeData = ModelUtility.getInstance().GetTaskFilterAssetTypeList(Session.OrganisationId!)
        }
        else
        {
            AssetTypeData = ModelUtility.getInstance().GetFilterAssetTypeList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup!, TaskName: Session.FilterTaskName, LocationGroupName: Session.FilterLocationGroup, Location: Session.FilterLocation)
        }
        
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
        
        AssetTypePopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        AssetTypePopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        AssetTypePopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        AssetTypePopupSelector.options = AssetTypes.map { KFPopupSelector.Option.text(text: $0) }
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
        var selectedIndex: Int = 0
        LocationGroups.append("")
        
        // go and get the LocationGroup data based on the criteria built
        if (Session.FilterOnTasks)
        {
            LocationGroupData = ModelUtility.getInstance().GetTaskFilterLocationGroupList(Session.OrganisationId!)
        }
        else
        {
            LocationGroupData = ModelUtility.getInstance().GetFilterLocationGroupList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup, TaskName: Session.FilterTaskName, AssetType: Session.FilterAssetType)
        }
        
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
        var LocationData: [String] = [] //NSMutableArray!
        var selectedIndex: Int = 0
        Locations.append("")
        
        //p]]
        if (Session.FilterOnTasks)
        {
            LocationData = ModelUtility.getInstance().GetTaskFilterLocationList(Session.OrganisationId!)
        }
        else
        {
            LocationData = ModelUtility.getInstance().GetFilterLocationList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup, TaskName: Session.FilterTaskName, AssetType: Session.FilterAssetType, LocationGroupName: Session.FilterLocationGroup!)
        }
        
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
        
        LocationPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        LocationPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        LocationPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        LocationPopupSelector.options = Locations.map { KFPopupSelector.Option.text(text: $0) }
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
        var selectedIndex: Int = 0
        AssetNumbers.append("")
        
        // go and get the AssetNumber data based on the criteria built
        if (Session.FilterOnTasks)
        {
            AssetNumberData = ModelUtility.getInstance().GetTaskFilterAssetNumberList(Session.OrganisationId!)
        }
        else
        {
            AssetNumberData = ModelUtility.getInstance().GetFilterAssetNumberList(Session.FilterPropertyId!, AssetGroup: Session.FilterAssetGroup, TaskName: Session.FilterTaskName, AssetType: Session.FilterAssetType, LocationGroupName: Session.FilterLocationGroup, Location: Session.FilterLocation)
        }
        
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
        
        AssetNumberPopupSelector.buttonContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        AssetNumberPopupSelector.setLabelFont(UIFont.systemFont(ofSize: 17))
        AssetNumberPopupSelector.setTableFont(UIFont.systemFont(ofSize: 17))
        AssetNumberPopupSelector.options = AssetNumbers.map { KFPopupSelector.Option.text(text: $0) }
        if (selectedIndex > 0) { AssetNumberPopupSelector.selectedIndex = selectedIndex } else { AssetNumberPopupSelector.selectedIndex = nil }
        AssetNumberPopupSelector.unselectedLabelText = "Select Asset Number"
        AssetNumberPopupSelector.displaySelectedValueInLabel = true
    }
    
    func RePopulateAllSelectors()
    {
        PopulateSiteSelector()
        PopulatePropertySelector()
        PopulateAssetGroupSelector()
        PopulateTaskNameSelector()
        PopulateAssetTypeSelector()
        PopulateLocationGroupSelector()
        PopulateLocationSelector()
        PopulateAssetNumberSelector()
    }
    
    //MARK : Action from selection
    var inChangeProcess: Bool = false
    
    @IBAction func SiteChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true
            //set the site filter
            if (SitePopupSelector.selectedIndex != nil && Sites[SitePopupSelector.selectedIndex!] != "")
            {
                Session.FilterSiteId = SiteDictionary[Sites[SitePopupSelector.selectedIndex!]]
                Session.FilterSiteName = Sites[SitePopupSelector.selectedIndex!]
                
                //do the property stuff
                if (!Session.FilterOnTasks)
                {
                    PopulatePropertySelector()
                    PropertyPopupSelector.isEnabled = true
                }
                else
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (SitePopupSelector.selectedIndex != nil) { SitePopupSelector.selectedIndex = nil }
                Session.FilterSiteId = nil
                Session.FilterSiteName = nil
                PropertyPopupSelector.unselectedLabelText = NotApplicable
                if (!Session.FilterOnTasks) {PropertyPopupSelector.isEnabled = false}
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }

    @IBAction func PropertyChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true
           
            //set the property filter
            if (PropertyPopupSelector.selectedIndex != nil  && Properties[PropertyPopupSelector.selectedIndex!] != "")
            {
                Session.FilterPropertyId = PropertyDictionary[Properties[PropertyPopupSelector.selectedIndex!]]
                Session.FilterPropertyName = Properties[PropertyPopupSelector.selectedIndex!]
                
                if (!Session.FilterOnTasks)
                {
                    //do the asset group stuff
                    PopulateAssetGroupSelector()
                    AssetGroupPopupSelector.isEnabled = true
                    
                    //do the area stuff
                    PopulateLocationGroupSelector()
                    LocationGroupPopupSelector.isEnabled = true
                }
                else
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (PropertyPopupSelector.selectedIndex != nil) { PropertyPopupSelector.selectedIndex = nil }
                Session.FilterPropertyId = nil
                Session.FilterPropertyName = nil
                AssetGroupPopupSelector.unselectedLabelText = NotApplicable
                if (!Session.FilterOnTasks) {AssetGroupPopupSelector.isEnabled = false}
                
                LocationGroupPopupSelector.unselectedLabelText = NotApplicable
                if (!Session.FilterOnTasks) {LocationGroupPopupSelector.isEnabled = false}
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
 
    @IBAction func FrequencyChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true
            //set the frequency filter
            
            if (FrequencyPopupSelector.selectedIndex != nil && Frequencies[FrequencyPopupSelector.selectedIndex!] != "")
            {
                Session.FilterFrequency = FrequencyDictionary[Frequencies[FrequencyPopupSelector.selectedIndex!]]
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (FrequencyPopupSelector.selectedIndex != nil) { FrequencyPopupSelector.selectedIndex = nil }
                Session.FilterFrequency = nil
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
    
    @IBAction func PeriodChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true
            if (PeriodPopupSelector.selectedIndex != nil && Periods[PeriodPopupSelector.selectedIndex!] != "")
            {
                Session.FilterPeriod = Periods[PeriodPopupSelector.selectedIndex!]
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                //no nil value for period selector
                //if (PeriodPopupSelector.selectedIndex != nil) { PeriodPopupSelector.selectedIndex = nil }
                Session.FilterPeriod = nil
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
    
    @IBAction func MyTasksChanged(_ sender: UISwitch) {
        Session.FilterJustMyTasks = sender.isOn
        resetFilter()
    }
    
    @IBAction func AssetGroupChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true       //set the property filter
            if (AssetGroupPopupSelector.selectedIndex != nil && AssetGroups[AssetGroupPopupSelector.selectedIndex!] != "")
            {
                Session.FilterAssetGroup = AssetGroupDictionary[AssetGroups[AssetGroupPopupSelector.selectedIndex!]]
                
                //do the Task name stuff
                if (!Session.FilterOnTasks)
                {
                    PopulateTaskNameSelector()
                    TaskNamePopupSelector.isEnabled = true
                }
                else
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (AssetGroupPopupSelector.selectedIndex != nil) { AssetGroupPopupSelector.selectedIndex = nil }
                Session.FilterAssetGroup = nil
                TaskNamePopupSelector.unselectedLabelText = NotApplicable
                if (!Session.FilterOnTasks) {TaskNamePopupSelector.isEnabled = false}
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
    
    @IBAction func TaskNameChange(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true        //set the property filter
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
                
                if (!Session.FilterOnTasks)
                {
                    //do the AssetType stuff
                    PopulateAssetTypeSelector()
                    AssetTypePopupSelector.isEnabled = true
                }
                else
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (TaskNamePopupSelector.selectedIndex != nil) { TaskNamePopupSelector.selectedIndex = nil }
                Session.FilterTaskName = nil
                AssetTypePopupSelector.unselectedLabelText = NotApplicable
                if (!Session.FilterOnTasks) {AssetTypePopupSelector.isEnabled = false}
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
    
    @IBAction func AssetTypeChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true        //set the property filter
            if (AssetTypePopupSelector.selectedIndex != nil && AssetTypes[AssetTypePopupSelector.selectedIndex!] != "")
            {
                Session.FilterAssetType = AssetTypeDictionary[AssetTypes[AssetTypePopupSelector.selectedIndex!]]
                debugPrint(Session.FilterAssetType!)
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (AssetTypePopupSelector.selectedIndex != nil) { AssetTypePopupSelector.selectedIndex = nil }
                Session.FilterAssetType = nil
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
    
    @IBAction func LocationGroupChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true       //set the property filter
            if (LocationGroupPopupSelector.selectedIndex != nil && LocationGroups[LocationGroupPopupSelector.selectedIndex!] != "")
            {
                Session.FilterLocationGroup = LocationGroupDictionary[LocationGroups[LocationGroupPopupSelector.selectedIndex!]]
                
                //do the AssetType stuff
                if (!Session.FilterOnTasks)
                {
                    PopulateLocationSelector()
                    LocationPopupSelector.isEnabled = true
                }
                else
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (LocationGroupPopupSelector.selectedIndex != nil) { LocationGroupPopupSelector.selectedIndex = nil }
                Session.FilterLocationGroup = nil
                LocationPopupSelector.unselectedLabelText = NotApplicable
                if (!Session.FilterOnTasks) {LocationPopupSelector.isEnabled = false}
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
    
    @IBAction func LocationChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true
            //set the property filter
            if (LocationPopupSelector.selectedIndex != nil && Locations[LocationPopupSelector.selectedIndex!] != "")
            {
                Session.FilterLocation = LocationDictionary[Locations[LocationPopupSelector.selectedIndex!]]
                
                //do the AssetNumber stuff
                if (!Session.FilterOnTasks)
                {
                    PopulateAssetNumberSelector()
                    AssetNumberPopupSelector.isEnabled = true
                }
                else
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (LocationPopupSelector.selectedIndex != nil) { LocationPopupSelector.selectedIndex = nil }
                Session.FilterLocation = nil
                AssetNumberPopupSelector.unselectedLabelText = NotApplicable
                if (!Session.FilterOnTasks) {AssetNumberPopupSelector.isEnabled = false}
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
    
    @IBAction func AssetNumberChanged(_ sender: KFPopupSelector) {
        if(!(inChangeProcess && Session.FilterOnTasks))
        {
            inChangeProcess = true
            //set the asset number filter
            if (AssetNumberPopupSelector.selectedIndex != nil && AssetNumbers[AssetNumberPopupSelector.selectedIndex!] != "")
            {
                Session.FilterAssetNumber = AssetNumberDictionary[AssetNumbers[AssetNumberPopupSelector.selectedIndex!]]

                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            else
            {
                if (AssetNumberPopupSelector.selectedIndex != nil) { AssetNumberPopupSelector.selectedIndex = nil }
                Session.FilterAssetNumber = nil
                
                if (Session.FilterOnTasks)
                {
                    RePopulateAllSelectors()
                }
            }
            inChangeProcess = false
        }
    }
    
}
        

    

