//
//  Session.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 21/01/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit

class Session : NSObject
{
    //static var RootViewController: UIViewController = UIViewController()
    static var Server: String = String()
    static var CheckDatabase: Bool = false
    
    static var DatabasePresent: Bool = false
    static var DatabaseMessage: String = String()
    
    static var UseTaskTiming: Bool = false
    static var UseTemperatureProfile: Bool = false
    
    static var OperativeId: String? = String?()
    static var OrganisationId: String? = String?()
    static var LocalLoginOnly: Bool = false;
 
    static var AlertTitle: String? = String?()
    static var AlertMessage: String? = String?()

    static var PropertyList: Dictionary<String, Property> = Dictionary<String, Property>()
 
    static var LookupLists: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
    
    static var ReferenceLists: Dictionary<String, Dictionary<String, String>> = Dictionary<String, Dictionary<String, String>>()
    static var ReverseReferenceLists: Dictionary<String, Dictionary<String, String>> = Dictionary<String, Dictionary<String, String>>()
  
    static var CodeScanned: String? = String?()
    static var NoRequery: Bool = false
    
    static var FilterSiteId: String? = String?()
    static var FilterSiteName: String? = String?()
    static var FilterPropertyId: String? = String?()
    static var FilterPropertyName: String? = String?()
    static var FilterFrequency: String? = String?()
    static var FilterPeriod: String? = String?("Due Today")
    
    static var FilterJustMyTasks: Bool = false
    
    static var FilterAssetGroup: String? = String?()
    static var FilterTaskName: String? = String?()
    static var FilterAssetType: String? = String?()
    static var FilterLocationGroup: String? = String?()
    static var FilterLocation: String? = String?()
    static var FilterAssetNumber: String? = String?()
    
    static var TaskSort: TaskSortOrder = TaskSortOrder.Date
    static var TaskCount: Int32 = 0
    
    static var PageNumber: Int32 = 1
    static var PageSize: Int32 = 1000
    static var MaxPage: Int32 = 1
    
    static var BluetoothProbeConnected: Bool = false
    
    static var TaskId: String? = nil
    
    class func BuildCriteriaFromSession() -> Dictionary<String, AnyObject> {
        var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        if (Session.OrganisationId != nil) { criteria["OrganisationId"] = Session.OrganisationId! }
        if (Session.FilterSiteId != nil) { criteria["SiteId"] = Session.FilterSiteId! }
        if (Session.FilterPropertyId != nil) { criteria["PropertyId"] = Session.FilterPropertyId! }
        if (Session.FilterFrequency != nil) { criteria["Frequency"] = Session.FilterFrequency! }
        if (Session.FilterPeriod != nil) { criteria["Period"] = Session.FilterPeriod! }
        
        if (Session.FilterAssetGroup != nil) { criteria["PPMGroup"] = Session.FilterAssetGroup! }
        if (Session.FilterTaskName != nil) { criteria["TaskName"] = Session.FilterTaskName! }
        if (Session.FilterAssetType != nil) { criteria["AssetType"] = Session.FilterAssetType! }
        if (Session.FilterLocationGroup != nil) { criteria["LocationGroupName"] = Session.FilterLocationGroup! }
        if (Session.FilterLocation != nil) { criteria["LocationName"] = Session.FilterLocation! }
        if (Session.FilterAssetNumber != nil) { criteria["AssetNumber"] = Session.FilterAssetNumber! }
        
        if (Session.FilterJustMyTasks == true) { criteria["OperativeId"] = Session.OperativeId }
        
        return criteria
    }
    
    class func ClearFilter()
    {
        FilterSiteId = String?()
        FilterSiteName = String?()
        FilterPropertyId = String?()
        FilterPropertyName = String?()
        FilterFrequency = String?()
        FilterPeriod = String?("Due Today")
        
        FilterJustMyTasks = false
        
        FilterAssetGroup = String?()
        FilterTaskName = String?()
        FilterAssetType = String?()
        FilterLocationGroup = String?()
        FilterLocation = String?()
        FilterAssetNumber = String?()
    }
}
