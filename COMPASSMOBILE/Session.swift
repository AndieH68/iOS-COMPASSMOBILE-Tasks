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
  
    
    static var FilterSiteId: String? = String?()
    static var FilterPropertyId: String? = String?()
    static var FilterFrequency: String? = String?()
    static var FilterPeriod: String? = String?()
    
    static var FilterJustMyTasks: Bool = false
    
    static var FilterAssetGroup: String? = String?()
    static var FilterTaskName: String? = String?()
    static var FilterAssetType: String? = String?()
    static var FilterLocationGroup: String? = String?()
    static var FilterLcoation: String? = String?()
    static var FilterAssetName: String? = String?()
    
    static var TaskCount: Int32 = 0
    
    class func BuildCriteriaFromSession() -> Dictionary<String, String> {
        var criteria: Dictionary<String, String> = Dictionary<String, String>()
        
        if (Session.FilterSiteId != nil) { criteria["SiteId"] = Session.FilterSiteId! }
        if (Session.FilterPropertyId != nil) { criteria["PropertyId"] = Session.FilterPropertyId! }
        if (Session.FilterFrequency != nil) { criteria["Frequency"] = Session.FilterFrequency! }
        
        //treat scheduled date differently
        //if (Session.FilterSiteId != nil) { criteria["SiteId"] = Session.FilterSiteId! }
        
        if (Session.FilterAssetGroup != nil) { criteria["PPMGroup"] = Session.FilterAssetGroup! }
        if (Session.FilterTaskName != nil) { criteria["TaskName"] = Session.FilterTaskName! }
        if (Session.FilterAssetType != nil) { criteria["AssetType"] = Session.FilterAssetType! }
        if (Session.FilterLocationGroup != nil) { criteria["LocationGroupName"] = Session.FilterLocationGroup! }
        if (Session.FilterLcoation != nil) { criteria["LocationName"] = Session.FilterLcoation! }
        if (Session.FilterAssetName != nil) { criteria["AssetNumber"] = Session.FilterAssetName! }
        
        return criteria
    }
}
