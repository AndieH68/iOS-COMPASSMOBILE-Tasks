//
//  ModelUtility.swift
//  COMPASSMOBILE
//
//  Created by Andrew Harper on 18/02/2016.
//  Copyright © 2016 HYDOP E.C.S. All rights reserved.
//

import UIKit
import FMDB

let sharedModelUtility = ModelUtility()

class ModelUtility: NSObject {
    
    let DELIMITER: Character = "\u{254}"
    
    class func getInstance() -> ModelUtility{
        return sharedModelUtility
    }
    
    // MARK: Control/Cache population
    
    func PopulateListControl(_ listControl: NSObject, referenceDateType: String, extendedReferenceDataType: String) -> Bool{
        return true
    }
    
    // MARK: Reference Data
    
    fileprivate func makeKey(_ type: String, parentType: String?, parentValue: String?) -> String{
        var key: String = type
        key.append(DELIMITER)
        if (parentType != nil) { key += parentType! }
        key.append(DELIMITER)
        if (parentValue != nil) { key += parentValue! }
        return key
    }
    
    func AssetNumber(_ asset: Asset) -> String {
        return (asset.ScanCode != nil ? "(" + asset.ScanCode! + ") " : "") + (asset.ClientName != nil ? asset.ClientName! : (asset.HydropName != nil ? asset.HydropName! : "UNKNOWN"))
    }
    
    func GetPropertyName(_ PropertyId: String) -> String {
        if let currentProperty: Property = GetPropertyDetails(PropertyId)
        {
            return currentProperty.Name
        }
        else
        {
            return "Property not found"
        }
    }
    
    func GetPropertyDetails(_ PropertyId: String) -> Property? {
        
        if(Session.PropertyList.keys.contains(PropertyId))
        {
            return Session.PropertyList[PropertyId]
        }
        else
        {
            let currentProperty: Property? = ModelManager.getInstance().getProperty(PropertyId)
            if (currentProperty != nil)
            {
                Session.PropertyList[PropertyId] = currentProperty
                return currentProperty
            }
            else
            {
                return nil
            }
        }
    }
    
    func ReferenceDataValueFromDisplay(_ type: String, value: String)-> String {
        return ReferenceDataValueFromDisplay(type, value: value, parentType: nil, parentValue: nil)
    }
    
    func ReferenceDataValueFromDisplay(_ type: String, value: String, parentType: String?, parentValue: String?) -> String {
        guard let key = GetReverseReferenceDataList(type, parentType: parentType, parentValue: parentValue)[value] else {return ""}
        return key
    }
    
    func ReferenceDataDisplayFromValue(_ type: String, key: String) -> String {
        return ReferenceDataDisplayFromValue(type, key: key, parentType: nil, parentValue: nil)
    }
    
    func ReferenceDataDisplayFromValue(_ type: String, key: String, parentType: String?, parentValue: String?) -> String {
        guard let value = GetReferenceDataList(type, parentType: parentType, parentValue: parentValue)[key] else {return ""}
        return value
    }
    
    func GetReferenceDataList(_ type: String, parentType: String?, parentValue: String?) -> Dictionary<String, String> {
        
        let key: String = makeKey(type, parentType: parentType,parentValue: parentValue)
        
        //Check to see if we have already got ths list for this entity
        if (Session.ReferenceLists[key] == nil)
        {
            _ = PopulateReferenceListCache(type, parentType: parentType, parentValue: parentValue)
        }
        
        return Session.ReferenceLists[key]!  //we've already checked if it exists to unwrapping if ok
    }
    
    func GetReverseReferenceDataList(_ type: String, parentType: String?, parentValue: String?) -> Dictionary<String, String> {
        
        let key: String = makeKey(type, parentType: parentType,parentValue: parentValue)
        
        //Check to see if we have already got ths list for this entity
        if (Session.ReverseReferenceLists[key] == nil)
        {
            _ = PopulateReferenceListCache(type, parentType: parentType, parentValue: parentValue)
        }
        
        return Session.ReverseReferenceLists[key]!  //we've already checked if it exists to unwrapping if ok
    }
    
    func GetLookupList(_ referenceDataType: String, extendedReferenceDataType: String?) -> [String]
    {
        return GetLookupList(referenceDataType, extendedReferenceDataType: extendedReferenceDataType, parentType: nil, parentValue: nil)
    }
    
    func GetLookupList(_ referenceDataType: String, extendedReferenceDataType: String?, parentType: String?, parentValue: String?) -> [String]
    {
        var returnArray: [String] = [String]()
        
        let key: String = makeKey(referenceDataType, parentType: parentType, parentValue: parentValue)
        
        if (!Session.LookupLists.keys.contains(key))
        {
            var lookupList: [String] = [String]()
            
            var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            criteria["Type"] = referenceDataType as AnyObject?
            criteria["ParentType"] = parentType as String? as AnyObject?
            criteria["ParentValue"] = parentValue as String? as AnyObject?
            
            //get the list of reference data from the databse
            let (referenceDataListData, _) = ModelManager.getInstance().findReferenceDataList(criteria, pageSize: nil, pageNumber: nil, sortOrder: ReferenceDataSortOrder.ordinal)
            
            for referenceDataItem in referenceDataListData {
                lookupList.append(referenceDataItem.Display)
            }
            Session.LookupLists[key] = lookupList as AnyObject?
        }
        
        returnArray = Session.LookupLists[key] as! [String]
 
        if (extendedReferenceDataType != nil)
        {
            if (!Session.LookupLists.keys.contains(extendedReferenceDataType!))
            {
                var lookupList: [String] = [String]()
                
                var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                criteria["Type"] = extendedReferenceDataType! as AnyObject?
                
                //get the list of reference data from the databse
                let (referenceDataListData, _) = ModelManager.getInstance().findReferenceDataList(criteria, pageSize: nil, pageNumber: nil, sortOrder: ReferenceDataSortOrder.ordinal)
                
                for referenceDataItem in referenceDataListData {
                    lookupList.append(referenceDataItem.Display)
                }
                Session.LookupLists[extendedReferenceDataType!] = lookupList as AnyObject?
            }
            
            returnArray.append(contentsOf: Session.LookupLists[extendedReferenceDataType!] as! [String])
        }
        
        return returnArray
    }
    
    func PopulateReferenceListCache(_ type: String, parentType: String?, parentValue: String?) -> Bool {
        
        //get a the reference data unique key
        let key: String = makeKey(type, parentType: parentType, parentValue: parentValue)
        
        //check to see if the unique key exists in the list of lists
        if (Session.ReferenceLists[key] == nil)
        {
            //doesn't exist so we need to populate it from the database and then cache it
            var referenceDataList: Dictionary<String, String> = Dictionary<String, String>()
            var reverseReferenceDataList: Dictionary<String, String> = Dictionary<String, String>()
            
            //build the criteria
            var criteria: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            criteria["Type"] = type as AnyObject?
            if (parentType != nil && parentValue != nil)
            {
                criteria["ParentType"] = parentType! as String as AnyObject?
                criteria["ParentValue"] = parentValue! as String as AnyObject?
            }
            
            //get the list of reference data from the databse
            let referenceDataListData: [ReferenceData] = ModelManager.getInstance().findReferenceDataList(criteria)
            
            for referenceDataItem in referenceDataListData {
                
                //belt and braces: check the keys are no already present
                if (referenceDataList[referenceDataItem.Value] == nil && reverseReferenceDataList[referenceDataItem.Display] == nil)
                {
                    referenceDataList[referenceDataItem.Value] = referenceDataItem.Display
                    reverseReferenceDataList[referenceDataItem.Display] = referenceDataItem.Value
                }
            }
            
            Session.ReferenceLists[key] = referenceDataList
            Session.ReverseReferenceLists[key] = reverseReferenceDataList
        }
        
        return true
    }
    
    func UpdateLevelsForTasks() -> Void
    {
        let Query: String = "SELECT [RowId],[LocationId],[Level] FROM [Task] WHERE [Level] IS NULL"
        let whereValues: [AnyObject] = [AnyObject]()

        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                let RowId: String = resultSet.string(forColumn: "rowId")!
                let LocationId: String = resultSet.string(forColumn: "LocationId")!
                let Level: String? = ModelUtility.getInstance().GetLevelForLocationId(LocationId)
                if (Level != nil)
                {
                    let UpdateQuery: String = "UPDATE [Task] SET [Level] = '" + Level! + "' WHERE [RowId] = '" + RowId + "'"
                    sharedModelManager.database!.executeUpdate(UpdateQuery, withArgumentsIn: whereValues)
                }
            }
        }
    }
    
    func GetLevelForLocationId(_ LocationId: String) -> String?
    {
        var Level: String? = nil
        let Query: String = "SELECT DISTINCT [Location].[Level] FROM [Location] WHERE [Location].[Deleted] IS NULL AND [Location].[RowId] = '" + LocationId + "'"
        let whereValues: [AnyObject] = [AnyObject]()
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                Level = resultSet.string(forColumn: "Level")!
            }
        }
        return Level
    }
    
    
    func GetOutletsForAsset(_ FacilityId: String) -> [String]
    {
        var OutletTypes: [String] = [String]()
        let Query: String = "SELECT DISTINCT [AssetOutlet].[OutletType] FROM [AssetOutlet] WHERE [AssetOutlet].[Deleted] IS NULL AND [AssetOutlet].[FacilityId] = '" + FacilityId + "'"
        let whereValues: [AnyObject] = [AnyObject]()
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                OutletTypes.append(ReferenceDataDisplayFromValue("OutletType", key: resultSet.string(forColumn: "OutletType")!))
            }
        }
        return OutletTypes
    }
    
    
    //MARK: Filter functions
    func GetFilterSiteList(_ OrganisationId: String) -> [String]
    {
        var Sites: [String] = [String]()
        
        var Query: String = "SELECT DISTINCT [Site].[RowId] FROM [Task] INNER JOIN [Site] ON [Task].[SiteId] = [Site].[RowId] WHERE [Task].[Deleted] IS NULL AND [Site].[Deleted] IS NULL AND [Task].[OrganisationId] = '" + OrganisationId + "'"

        Query +=  " ORDER BY [Site].[Name]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                Sites.append(resultSet.string(forColumn: "RowId")!)
            }
        }
        return Sites
    }
    
    func GetTaskFilterSiteList(_ OrganisationId: String) -> [String]
    {
        var Sites: [String] = [String]()
        
        var Query: String = "SELECT DISTINCT [Task].[SiteId] FROM [Task] INNER JOIN [Site] ON [Task].[SiteId] = [Site].[RowId] WHERE [Task].[Deleted] IS NULL AND [Site].[Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterPropertyId != nil)
        {
            Query +=  " AND [Task].[PropertyId] = '" + Session.FilterPropertyId! + "'"
        }
        if (Session.FilterLevel != nil)
        {
            Query +=  " AND [Task].[Level] = '" + Session.FilterLevel! + "'"
        }
        if (Session.FilterAssetGroup != nil)
        {
            Query += " AND [Task].[PPMGroup] = '" + Session.FilterAssetGroup! + "'"
        }
        if (Session.FilterTaskName != nil)
        {
            Query += " AND [Task].[TaskName] = '" + Session.FilterTaskName! + "'"
        }
        if (Session.FilterAssetType != nil)
        {
            Query += " AND [Task].[AssetType] = '" + Session.FilterAssetType! + "'"
        }
        if (Session.FilterLocationGroup != nil)
        {
            Query += " AND [Task].[LocationGroupName] = '" + Session.FilterLocationGroup! + "'"
        }
        if (Session.FilterLocation != nil)
        {
            Query += " AND [Task].[LocationName] = '" + Session.FilterLocation! + "'"
        }
        if (Session.FilterAssetNumber != nil)
        {
            Query += " AND [Task].[AssetNumber] = '" + Session.FilterAssetNumber! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [Site].[Name]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                Sites.append(resultSet.string(forColumn: "SiteId")!)
            }
        }
        return Sites
    }
    
    func GetFilterPropertyList(_ SiteId: String) -> [String]
    {
        var Properties: [String] = [String]()
        
        var Query: String = "SELECT DISTINCT [Property].[RowId] FROM [Task] INNER JOIN [Property] ON [Task].[PropertyId] = [Property].[RowId] WHERE [Task].[Deleted] IS NULL AND [Property].[Deleted] IS NULL AND [Task].[SiteId] = '" + SiteId + "'"
        Query +=  " ORDER BY [Property].[Name]"
    
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                Properties.append(resultSet.string(forColumn: "RowId")!)
            }
        }
        return Properties
    }

    func GetTaskFilterPropertyList(_ OrganisationId: String) -> [String]
    {
        var Properties: [String] = [String]()
        
        var Query: String = "SELECT DISTINCT [Task].[PropertyId] FROM [Task] INNER JOIN [Property] ON [Task].[PropertyId] = [Property].[RowId] WHERE [Task].[Deleted] IS NULL AND [Property].[Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterSiteId != nil)
        {
            Query +=  " AND [Task].[SiteId] = '" + Session.FilterSiteId! + "'"
        }
        if (Session.FilterLevel != nil)
        {
            Query +=  " AND [Task].[Level] = '" + Session.FilterLevel! + "'"
        }
        if (Session.FilterAssetGroup != nil)
        {
            Query += " AND [Task].[PPMGroup] = '" + Session.FilterAssetGroup! + "'"
        }
        if (Session.FilterTaskName != nil)
        {
            Query += " AND [Task].[TaskName] = '" + Session.FilterTaskName! + "'"
        }
        if (Session.FilterAssetType != nil)
        {
            Query += " AND [Task].[AssetType] = '" + Session.FilterAssetType! + "'"
        }
        if (Session.FilterLocationGroup != nil)
        {
            Query += " AND [Task].[LocationGroupName] = '" + Session.FilterLocationGroup! + "'"
        }
        if (Session.FilterLocation != nil)
        {
            Query += " AND [Task].[LocationName] = '" + Session.FilterLocation! + "'"
        }
        if (Session.FilterAssetNumber != nil)
        {
            Query += " AND [Task].[AssetNumber] = '" + Session.FilterAssetNumber! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [Property].[Name]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                Properties.append(resultSet.string(forColumn: "PropertyId")!)
            }
        }
        return Properties
    }
    
    func GetFilterLevelList(_ PropertyId: String) -> [String]
    {
        var Levels: [String] = [String]()

        var Query: String = "SELECT DISTINCT [Level] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        Query +=  " ORDER BY [Level]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "Level") != nil)
                {
                    Levels.append(resultSet.string(forColumn: "Level")!)
                }
            }
        }
        return Levels
    }
    
    func GetTaskFilterLevelList(_ OrganisationId: String) -> [String]
    {
        var Levels: [String] = [String]()
        
        var Query: String = "SELECT DISTINCT [Level] FROM [Task] WHERE [Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterSiteId != nil)
        {
            Query +=  " AND [Task].[SiteId] = '" + Session.FilterSiteId! + "'"
        }
        if (Session.FilterPropertyId != nil)
        {
            Query +=  " AND [Task].[PropertyId] = '" + Session.FilterPropertyId! + "'"
        }
        if (Session.FilterTaskName != nil)
        {
            Query += " AND [Task].[TaskName] = '" + Session.FilterTaskName! + "'"
        }
        if (Session.FilterAssetGroup != nil)
        {
            Query += " AND [Task].[PPMGroup] = '" + Session.FilterAssetGroup! + "'"
        }
        if (Session.FilterAssetType != nil)
        {
            Query += " AND [Task].[AssetType] = '" + Session.FilterAssetType! + "'"
        }
        if (Session.FilterLocationGroup != nil)
        {
            Query += " AND [Task].[LocationGroupName] = '" + Session.FilterLocationGroup! + "'"
        }
        if (Session.FilterLocation != nil)
        {
            Query += " AND [Task].[LocationName] = '" + Session.FilterLocation! + "'"
        }
        if (Session.FilterAssetNumber != nil)
        {
            Query += " AND [Task].[AssetNumber] = '" + Session.FilterAssetNumber! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [Level]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "Level") != nil)
                {
                    Levels.append(resultSet.string(forColumn: "Level")!)
                }
            }
        }
        return Levels
    }
    
    func GetFilterAssetGroupList(_ PropertyId: String, LocationGroupName: String?, Location: String?) -> [String]
    {
        var AssetGroups: [String] = [String]()

        var Query: String = "SELECT DISTINCT [PPMGroup] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        if (LocationGroupName != nil)
        {
            Query += " AND [LocationGroupName] = '" + LocationGroupName! + "'"
        }
        
        if (Location != nil)
        {
            Query += " AND [LocationName] = '" + Location! + "'"
        }
        Query +=  " ORDER BY [PPMGroup]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "PPMGroup") != nil)
                {
                    AssetGroups.append(resultSet.string(forColumn: "PPMGroup")!)
                }
            }
        }
        return AssetGroups
    }
    
    func GetTaskFilterAssetGroupList(_ OrganisationId: String) -> [String]
    {
        var AssetGroups: [String] = [String]()
        
        var Query: String = "SELECT DISTINCT [PPMGroup] FROM [Task] WHERE [Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterSiteId != nil)
        {
            Query +=  " AND [Task].[SiteId] = '" + Session.FilterSiteId! + "'"
        }
        if (Session.FilterPropertyId != nil)
        {
            Query +=  " AND [Task].[PropertyId] = '" + Session.FilterPropertyId! + "'"
        }
        if (Session.FilterLevel != nil)
        {
            Query +=  " AND [Task].[Level] = '" + Session.FilterLevel! + "'"
        }
        if (Session.FilterTaskName != nil)
        {
            Query += " AND [Task].[TaskName] = '" + Session.FilterTaskName! + "'"
        }
        if (Session.FilterAssetType != nil)
        {
            Query += " AND [Task].[AssetType] = '" + Session.FilterAssetType! + "'"
        }
        if (Session.FilterLocationGroup != nil)
        {
            Query += " AND [Task].[LocationGroupName] = '" + Session.FilterLocationGroup! + "'"
        }
        if (Session.FilterLocation != nil)
        {
            Query += " AND [Task].[LocationName] = '" + Session.FilterLocation! + "'"
        }
        if (Session.FilterAssetNumber != nil)
        {
            Query += " AND [Task].[AssetNumber] = '" + Session.FilterAssetNumber! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [PPMGroup]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "PPMGroup") != nil)
                {
                    AssetGroups.append(resultSet.string(forColumn: "PPMGroup")!)
                }
            }
        }
        return AssetGroups
    }
    
    func GetFilterTaskNameList(_ PropertyId: String, AssetGroup: String, AssetType: String?, LocationGroupName: String?, Location: String?) -> [String]
    {
        var TaskNames: [String] = [String]()
        var Query: String = "SELECT DISTINCT [TaskName] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "' AND [PPMGroup] = '" + AssetGroup + "' "
        if (AssetType != nil)
        {
            Query += " AND [AssetType] = '" + AssetType! + "'"
        }
        if (LocationGroupName != nil)
        {
            Query += " AND [LocationGroupName] = '" + LocationGroupName! + "'"
        }
        if (Location != nil)
        {
            Query += " AND [LocationName] = '" + Location! + "'"
        }
        Query +=  " ORDER BY [TaskName]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "TaskName") != nil)
                {
                    TaskNames.append(resultSet.string(forColumn: "TaskName")!)
                }
            }
        }
        return TaskNames
    }
    
    func GetTaskFilterTaskNameList(_ OrganisationId: String) -> [String]
    {
        var TaskNames: [String] = [String]()
        var Query: String = "SELECT DISTINCT [TaskName] FROM [Task] WHERE [Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterSiteId != nil)
        {
            Query +=  " AND [Task].[SiteId] = '" + Session.FilterSiteId! + "'"
        }
        if (Session.FilterPropertyId != nil)
        {
            Query +=  " AND [Task].[PropertyId] = '" + Session.FilterPropertyId! + "'"
        }
        if (Session.FilterLevel != nil)
        {
            Query +=  " AND [Task].[Level] = '" + Session.FilterLevel! + "'"
        }
        if (Session.FilterAssetGroup != nil)
        {
            Query += " AND [Task].[PPMGroup] = '" + Session.FilterAssetGroup! + "'"
        }
        if (Session.FilterAssetType != nil)
        {
            Query += " AND [Task].[AssetType] = '" + Session.FilterAssetType! + "'"
        }
        if (Session.FilterLocationGroup != nil)
        {
            Query += " AND [Task].[LocationGroupName] = '" + Session.FilterLocationGroup! + "'"
        }
        if (Session.FilterLocation != nil)
        {
            Query += " AND [Task].[LocationName] = '" + Session.FilterLocation! + "'"
        }
        if (Session.FilterAssetNumber != nil)
        {
            Query += " AND [Task].[AssetNumber] = '" + Session.FilterAssetNumber! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [TaskName]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "TaskName") != nil)
                {
                    TaskNames.append(resultSet.string(forColumn: "TaskName")!)
                }
            }
        }
        return TaskNames
    }
    
    func GetFilterAssetTypeList(_ PropertyId: String, AssetGroup: String, TaskName: String?, LocationGroupName: String?, Location: String?) -> [String]
    {
        var AssetTypes: [String] = [String]()
        var Query: String = "SELECT DISTINCT [AssetType] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "' AND [PPMGroup] = '" + AssetGroup + "' "
        if (TaskName != nil)
        {
            Query += " AND [TaskName] = '" + TaskName! + "'"
        }
        if (LocationGroupName != nil)
        {
            Query += " AND [LocationGroupName] = '" + LocationGroupName! + "'"
        }
        if (Location != nil)
        {
            Query += " AND [LocationName] = '" + Location! + "'"
        }
        Query += " ORDER BY [AssetType]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "AssetType") != nil)
                {
                    AssetTypes.append(resultSet.string(forColumn: "AssetType")!)
                }
            }
        }
        return AssetTypes
    }
    
    func GetTaskFilterAssetTypeList(_ OrganisationId: String) -> [String]
    {
        var AssetTypes: [String] = [String]()
        var Query: String = "SELECT DISTINCT [AssetType] FROM [Task] WHERE [Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterSiteId != nil)
        {
            Query +=  " AND [Task].[SiteId] = '" + Session.FilterSiteId! + "'"
        }
        if (Session.FilterPropertyId != nil)
        {
            Query +=  " AND [Task].[PropertyId] = '" + Session.FilterPropertyId! + "'"
        }
        if (Session.FilterLevel != nil)
        {
            Query +=  " AND [Task].[Level] = '" + Session.FilterLevel! + "'"
        }
        if (Session.FilterAssetGroup != nil)
        {
            Query += " AND [Task].[PPMGroup] = '" + Session.FilterAssetGroup! + "'"
        }
        if (Session.FilterTaskName != nil)
        {
            Query += " AND [Task].[TaskName] = '" + Session.FilterTaskName! + "'"
        }
        if (Session.FilterLocationGroup != nil)
        {
            Query += " AND [Task].[LocationGroupName] = '" + Session.FilterLocationGroup! + "'"
        }
        if (Session.FilterLocation != nil)
        {
            Query += " AND [Task].[LocationName] = '" + Session.FilterLocation! + "'"
        }
        if (Session.FilterAssetNumber != nil)
        {
            Query += " AND [Task].[AssetNumber] = '" + Session.FilterAssetNumber! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [AssetType]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "AssetType") != nil)
                {
                    AssetTypes.append(resultSet.string(forColumn: "AssetType")!)
                }
            }
        }
        return AssetTypes
    }
    
    func GetFilterLocationGroupList(_ PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?) -> [String]
    {
        var LocationGroups: [String] = [String]()
        var Query: String = "SELECT DISTINCT [LocationGroupName] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        if (AssetGroup != nil)
        {
            Query += " AND [PPMGroup] = '" + AssetGroup! + "'"
        }
        if (TaskName != nil)
        {
            Query += " AND [TaskName] = '" + TaskName! + "'"
        }
        if (AssetType != nil)
        {
            Query += " AND [AssetType] = '" + AssetType! + "'"
        }
        Query += " ORDER BY [LocationGroupName]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "LocationGroupName") != nil)
                {
                    LocationGroups.append(resultSet.string(forColumn: "LocationGroupName")!)
                }
            }
        }
        return LocationGroups
    }
 
    func GetTaskFilterLocationGroupList(_ OrganisationId: String) -> [String]
    {
        var LocationGroups: [String] = [String]()
        var Query: String = "SELECT DISTINCT [LocationGroupName] FROM [Task] WHERE [Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterSiteId != nil)
        {
            Query +=  " AND [Task].[SiteId] = '" + Session.FilterSiteId! + "'"
        }
        if (Session.FilterPropertyId != nil)
        {
            Query +=  " AND [Task].[PropertyId] = '" + Session.FilterPropertyId! + "'"
        }
        if (Session.FilterLevel != nil)
        {
            Query +=  " AND [Task].[Level] = '" + Session.FilterLevel! + "'"
        }
        if (Session.FilterAssetGroup != nil)
        {
            Query += " AND [Task].[PPMGroup] = '" + Session.FilterAssetGroup! + "'"
        }
        if (Session.FilterTaskName != nil)
        {
            Query += " AND [Task].[TaskName] = '" + Session.FilterTaskName! + "'"
        }
        if (Session.FilterAssetType != nil)
        {
            Query += " AND [Task].[AssetType] = '" + Session.FilterAssetType! + "'"
        }
        if (Session.FilterLocation != nil)
        {
            Query += " AND [Task].[LocationName] = '" + Session.FilterLocation! + "'"
        }
        if (Session.FilterAssetNumber != nil)
        {
            Query += " AND [Task].[AssetNumber] = '" + Session.FilterAssetNumber! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [LocationGroupName]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "LocationGroupName") != nil)
                {
                    LocationGroups.append(resultSet.string(forColumn: "LocationGroupName")!)
                }
            }
        }
        return LocationGroups
    }
    
    func GetFilterLocationList(_ PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?, LocationGroupName: String) -> [String]
    {
        var Locations: [String] = [String]()
        var Query: String = "SELECT DISTINCT [LocationName] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        if (AssetGroup != nil)
        {
            Query += " AND [PPMGroup] = '" + AssetGroup! + "'"
        }
        
        if (TaskName != nil)
        {
            Query += " AND [TaskName] = '" + TaskName! + "'"
        }
        
        if (AssetType != nil)
        {
            Query += " AND [AssetType] = '" + AssetType! + "'"
        }
        Query += " AND [LocationGroupName] = '" + LocationGroupName + "'"
        Query += " ORDER BY [LocationName]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "LocationName") != nil)
                {
                    Locations.append(resultSet.string(forColumn: "LocationName")!)
                }
            }
        }
        return Locations
    }

    func GetTaskFilterLocationList(_ OrganisationId: String) -> [String]
    {
        var Locations: [String] = [String]()
        var Query: String = "SELECT DISTINCT [LocationName] FROM [Task] WHERE [Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterSiteId != nil)
        {
            Query +=  " AND [Task].[SiteId] = '" + Session.FilterSiteId! + "'"
        }
        if (Session.FilterPropertyId != nil)
        {
            Query +=  " AND [Task].[PropertyId] = '" + Session.FilterPropertyId! + "'"
        }
        if (Session.FilterLevel != nil)
        {
            Query +=  " AND [Task].[Level] = '" + Session.FilterLevel! + "'"
        }
        if (Session.FilterAssetGroup != nil)
        {
            Query += " AND [Task].[PPMGroup] = '" + Session.FilterAssetGroup! + "'"
        }
        if (Session.FilterTaskName != nil)
        {
            Query += " AND [Task].[TaskName] = '" + Session.FilterTaskName! + "'"
        }
        if (Session.FilterAssetType != nil)
        {
            Query += " AND [Task].[AssetType] = '" + Session.FilterAssetType! + "'"
        }
        if (Session.FilterLocationGroup != nil)
        {
            Query += " AND [Task].[LocationGroupName] = '" + Session.FilterLocationGroup! + "'"
        }
        if (Session.FilterAssetNumber != nil)
        {
            Query += " AND [Task].[AssetNumber] = '" + Session.FilterAssetNumber! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [LocationName]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "LocationName") != nil)
                {
                    Locations.append(resultSet.string(forColumn: "LocationName")!)
                }
            }
        }
        return Locations
    }
    
    func GetFilterAssetNumberList(_ PropertyId: String, AssetGroup: String?, TaskName: String?, AssetType: String?, LocationGroupName: String?, Location: String?) -> [String]
    {
        var AssetNumbers: [String] = [String]()
        var Query: String = "SELECT DISTINCT [AssetNumber] FROM [Task] WHERE [Deleted] IS NULL AND [PropertyId] = '" + PropertyId + "'"
        if (AssetGroup != nil)
        {
            Query += " AND [PPMGroup] = '" + AssetGroup! + "'"
        }

        if (TaskName != nil)
        {
            Query += " AND [TaskName] = '" + TaskName! + "'"
        }
        
        if (AssetType != nil)
        {
            Query += " AND [AssetType] = '" + AssetType! + "'"
        }
        
        if (LocationGroupName != nil)
        {
            Query += " AND [LocationGroupName] = '" + LocationGroupName! + "'"
        }
        
        if (Location != nil)
        {
            Query += " AND [LocationName] = '" + Location! + "'"
        }
        Query += " ORDER BY [AssetNumber]"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "AssetNumber") != nil)
                {
                    AssetNumbers.append(resultSet.string(forColumn: "AssetNumber")!)
                }
            }
        }
        return AssetNumbers
    }
    
    func GetTaskFilterAssetNumberList(_ OrganisationId: String) -> [String]
    {
        var AssetNumbers: [String] = [String]()
        var Query: String = "SELECT DISTINCT [AssetNumber] FROM [Task] WHERE [Deleted] IS NULL AND [Task].[Status] IN ('Pending','Outstanding') AND [Task].[OrganisationId] = '" + OrganisationId + "'"
        if (Session.FilterSiteId != nil)
        {
            Query +=  " AND [Task].[SiteId] = '" + Session.FilterSiteId! + "'"
        }
        if (Session.FilterPropertyId != nil)
        {
            Query +=  " AND [Task].[PropertyId] = '" + Session.FilterPropertyId! + "'"
        }
        if (Session.FilterLevel != nil)
        {
            Query +=  " AND [Task].[Level] = '" + Session.FilterLevel! + "'"
        }
        if (Session.FilterAssetGroup != nil)
        {
            Query += " AND [Task].[PPMGroup] = '" + Session.FilterAssetGroup! + "'"
        }
        if (Session.FilterTaskName != nil)
        {
            Query += " AND [Task].[TaskName] = '" + Session.FilterTaskName! + "'"
        }
        if (Session.FilterAssetType != nil)
        {
            Query += " AND [Task].[AssetType] = '" + Session.FilterAssetType! + "'"
        }
        if (Session.FilterLocationGroup != nil)
        {
            Query += " AND [Task].[LocationGroupName] = '" + Session.FilterLocationGroup! + "'"
        }
        if (Session.FilterLocation != nil)
        {
            Query += " AND [Task].[LocationName] = '" + Session.FilterLocation! + "'"
        }
        
        if (Session.FilterJustMyTasks)
        {
            Query += ModelUtility.getInstance().GetFilterJustMyTasksClause()
        }
        else
        {
            Query += " AND (OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000' OR OperativeId = '" + Session.OperativeId! + "')"
        }
        
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()
        (whereClause, whereValues) = GetPeriodClause(period: Session.FilterPeriod!)
        
        if(!whereClause.isEmpty)
        {
            Query += " AND " + whereClause
        }
        Query += " ORDER BY [AssetNumber]"
        
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: whereValues)
        if (resultSet != nil) {
            while resultSet.next()
            {
                if (resultSet.string(forColumn: "AssetNumber") != nil)
                {
                    AssetNumbers.append(resultSet.string(forColumn: "AssetNumber")!)
                }
            }
        }
        return AssetNumbers
    }

    func GetTaskCountByStatus(Status: String) -> Int32
    {
        var count: Int32 = 0
        let Query: String = "SELECT COUNT(RowId) FROM [Task] WHERE [Status] = '" + Status + "' AND [OrganisationId] = '" + Session.OrganisationId! + "'"
        sharedModelManager.database!.open()
        let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery(Query, withArgumentsIn: [])
        if (resultSet != nil) {
            while resultSet.next()
            {
                count = resultSet.int(forColumnIndex: 0)
            }
        }
        return count
    }
    
    func GetFilterJustMyTasksClause() -> String {
        if(Session.InvalidateCachedFilterJustMyTasksClause)
        {
            var whereClauseMyTasks: String = String()
            whereClauseMyTasks = " AND "
            whereClauseMyTasks += "("
            whereClauseMyTasks += "(OperativeId = '" + Session.OperativeId! + "')"
            
            var taskTemplateIds: [String] = [String]()
            //get the groups for the operative
            var operativeIds: [String] = [String]()
            operativeIds.append(Session.OperativeId!)
            let resultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT OperativeGroupId FROM OperativeGroupMembership WHERE OperativeId = ?", withArgumentsIn: operativeIds)
            if (resultSet != nil)
            {
                while resultSet.next() {
                    
                    //get the templates for the operative group
                    var operativeGroupIds: [String] = [String]()
                    operativeGroupIds.append(resultSet.string(forColumn: "OperativeGroupId")!)
                    let innerResultSet: FMResultSet! = sharedModelManager.database!.executeQuery("SELECT TaskTemplateId FROM OperativeGroupTaskTemplateMembership WHERE OperativeGroupId = ?", withArgumentsIn: operativeGroupIds)
                    
                    if (innerResultSet != nil)
                    {
                        while innerResultSet.next(){
                            
                            //add the templates to the array
                            taskTemplateIds.append(innerResultSet.string(forColumn: "TaskTemplateId")!)
                        }
                    }
                }
                
                //build the where clause
                
                if (taskTemplateIds.count > 0)
                {
                    var taskTemplateIdList: String = String()
                    var first: Bool = true
                    for taskTemplateId: String in taskTemplateIds
                    {
                        if (!first) {taskTemplateIdList += ", "} else {first = false}
                        taskTemplateIdList += "'" + taskTemplateId + "'"
                    }
                    
                    whereClauseMyTasks += " OR "
                    whereClauseMyTasks += "("
                    whereClauseMyTasks += "TaskTemplateId IN (" + taskTemplateIdList + ")"
                    whereClauseMyTasks += " AND "
                    whereClauseMyTasks += "(OperativeId IS NULL OR OperativeId = '00000000-0000-0000-0000-000000000000')"
                    whereClauseMyTasks += ")"
                }
            }
            whereClauseMyTasks += ")"
            Session.CachedFilterJustMyTasksClause = whereClauseMyTasks
            Session.InvalidateCachedFilterJustMyTasksClause = false
        }
        return Session.CachedFilterJustMyTasksClause!
    }
    
    func GetPeriodClause(period: String) -> (String,[AnyObject])
    {
        var whereClause: String = String()
        var whereValues: [AnyObject] = [AnyObject]()

        switch period
        {
        case DueTodayText:
            
            let endOfToday: Date = Date().endOfDay()
            
            whereClause += (whereClause != "" ? " AND " : " ")
            whereClause += " [ScheduledDate] <= ? "
            whereValues.append(endOfToday as AnyObject)
            
        case DueNext7DaysText:
            
            let endOfThisWeek: Date = Date().endOfWeek()
            
            whereClause += (whereClause != "" ? " AND " : " ")
            whereClause += " [ScheduledDate] <= ? "
            whereValues.append(endOfThisWeek as AnyObject)
            
        case DueCalendarMonthText:
            
            let endOfThisMonth: Date = Date().endOfMonth()
            
            whereClause += (whereClause != "" ? " AND " : " ")
            whereClause += " [ScheduledDate] <= ? "
            whereValues.append(endOfThisMonth as AnyObject)
            
        case DueThisMonthText:
            
            let startOfNextMonth: Date = Date().startOfNextMonth()
            let endOfNextMonth: Date = Date().endOfNextMonth()
            whereClause += (whereClause != "" ? " AND " : " ")
            whereClause += " [ScheduledDate] >= ? AND [ScheduledDate] <= ? "
            whereValues.append(startOfNextMonth as AnyObject)
            whereValues.append(endOfNextMonth as AnyObject)
            
        case "All":
            //nothing to do
            print("Catch All")
            
        default:
            //nothing to do
            print("Default")
            
        }
        return(whereClause, whereValues)
    }
}

