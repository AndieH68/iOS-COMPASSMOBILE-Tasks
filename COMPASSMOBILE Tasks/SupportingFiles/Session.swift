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
    static var WebProtocol: String = String("https://")
    static var Server: String = String()
    static var CheckDatabase: Bool = false
    
    static var DatabasePresent: Bool = false
    static var DatabaseMessage: String = String()
    static var ResetTaskTemplateDates: Bool = false
    
    static var UseBlueToothProbe: Bool = false
    static var UseTaskTiming: Bool = false
    static var UseTemperatureProfile: Bool = false
    static var RememberFilterSettings: Bool = false
    static var FilterOnTasks: Bool = false
    
    static var OperativeId: String? = nil
    static var OrganisationId: String? = nil
    static var LocalLoginOnly: Bool = false;
 
    static var AlertTitle: String? = nil
    static var AlertMessage: String? = nil

    static var PropertyList: Dictionary<String, Property> = Dictionary<String, Property>()
 
    static var LookupLists: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
    
    static var ReferenceLists: Dictionary<String, Dictionary<String, String>> = Dictionary<String, Dictionary<String, String>>()
    static var ReverseReferenceLists: Dictionary<String, Dictionary<String, String>> = Dictionary<String, Dictionary<String, String>>()
  
    static var CodeScanned: String? = nil
    static var MatrixScanned: String? = nil

    static var NoRequery: Bool = false
    
    static var FilterSiteId: String? = nil
    static var FilterSiteName: String? = nil
    static var FilterPropertyId: String? = nil
    static var FilterPropertyName: String? = nil
    static var FilterFrequency: String? = nil
    static var FilterPeriod: String? = String?(DueCalendarMonthText)
    
    static var FilterJustMyTasks: Bool = false
    static var CachedFilterJustMyTasksClause: String? = nil
    static var InvalidateCachedFilterJustMyTasksClause: Bool = true
    
    static var FilterAssetGroup: String? = nil
    static var FilterTaskName: String? = nil
    static var FilterAssetType: String? = nil
    static var FilterLocationGroup: String? = nil
    static var FilterLocation: String? = nil
    static var FilterAssetNumber: String? = nil
    
    static var TaskSort: TaskSortOrder = TaskSortOrder.date
    static var TaskCount: Int32 = 0
    
    static var PageNumber: Int32 = 1
    static var PageSize: Int32 = 1000
    static var MaxPage: Int32 = 1
    
    static var BluetoothProbeConnected: Bool = false
    static var ThermaQBluetoothProbeConnected: Bool = false
    static var CurrentDevice: TLDevice?
    static var ReadingDevice: Int32 = 1
    
    static var TaskId: String? = nil
    
    class func BuildCriteriaFromSession() -> Dictionary<String, AnyObject> {
        var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        if (Session.OrganisationId != nil) { criteria["OrganisationId"] = Session.OrganisationId! as AnyObject? }
        if (Session.FilterSiteId != nil) { criteria["SiteId"] = Session.FilterSiteId! as AnyObject? }
        if (Session.FilterPropertyId != nil) { criteria["PropertyId"] = Session.FilterPropertyId! as AnyObject? }
        if (Session.FilterFrequency != nil) { criteria["Frequency"] = Session.FilterFrequency! as AnyObject? }
        if (Session.FilterPeriod != nil) { criteria["Period"] = Session.FilterPeriod! as AnyObject? }
        
        if (Session.FilterAssetGroup != nil) { criteria["PPMGroup"] = Session.FilterAssetGroup! as AnyObject? }
        if (Session.FilterTaskName != nil) { criteria["TaskName"] = Session.FilterTaskName! as AnyObject? }
        if (Session.FilterAssetType != nil) { criteria["AssetType"] = Session.FilterAssetType! as AnyObject? }
        if (Session.FilterLocationGroup != nil) { criteria["LocationGroupName"] = Session.FilterLocationGroup! as AnyObject? }
        if (Session.FilterLocation != nil) { criteria["LocationName"] = Session.FilterLocation! as AnyObject? }
        if (Session.FilterAssetNumber != nil) { criteria["AssetNumber"] = Session.FilterAssetNumber! as AnyObject? }
        
        if (Session.FilterJustMyTasks == true) { criteria["OperativeId"] = Session.OperativeId as AnyObject? }
        
        return criteria
    }
    
    class func ClearFilter()
    {
        FilterSiteId = nil
        FilterSiteName = nil
        FilterPropertyId = nil
        FilterPropertyName = nil
        FilterFrequency = nil
        FilterPeriod = String?(DueCalendarMonthText)
        
        FilterJustMyTasks = false
        CachedFilterJustMyTasksClause = nil
        InvalidateCachedFilterJustMyTasksClause = true
        
        FilterAssetGroup = nil
        FilterTaskName = nil
        FilterAssetType = nil
        FilterLocationGroup = nil
        FilterLocation = nil
        FilterAssetNumber = nil
    }
    
    static var CurrentReading: String? = nil
    static var CurrentTemperatureControl: UITextField? = nil
    static var TimerRunning: Bool = false
    
    static var GettingAlternateAssetCode = false
    
    static var CurrentProfileControl: UITextField? = nil
    static var Profile: TemperatureProfile? = nil
    static var GettingProfile: Bool = false
    static var CancelFromProfile: Bool = false
    
    static var CurrentScanCodeControl: UITextField? = nil
    static var ScanCode: String? = nil
    static var GettingScanCode: Bool = false
    
    static var CurrentDataMatrixCell: TaskTemplateParameterCellDataMatrix? = nil
    static var CurrentDataMatrixControl: UITextField? = nil
    static var DataMatrix: String? = nil
    static var GettingDataMatrix: Bool = false

    static var CurrentScanUniversalCell: TaskTemplateParameterCellScanUniversal? = nil
    static var CurrentScanUniversalControl: UITextField? = nil
    static var ScanUniversal: String? = nil
    static var GettingScanUniversal: Bool = false

    static var CancelFromScan: Bool = false

    
}

