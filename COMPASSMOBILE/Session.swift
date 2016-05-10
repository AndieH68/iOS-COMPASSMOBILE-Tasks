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
    static var OperativeId: String? = String?()
    static var OrganisationId: String? = String?()
 
    static var LookupLists: Dictionary<String, AnyObject> = Dictionary<String,AnyObject>()
    
    static var ReferenceLists: Dictionary<String, Dictionary<String, String>> = Dictionary<String, Dictionary<String, String>>()
    static var ReverseReferenceLists: Dictionary<String, Dictionary<String, String>> = Dictionary<String, Dictionary<String, String>>()
  
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
    static var PageSize: Int32 = 20
    static var MaxPage: Int32 = 1
    
    class func BuildCriteriaFromSession() -> Dictionary<String, String> {
        var criteria: Dictionary<String, String> = Dictionary<String, String>()
        
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
        
        return criteria
    }
}
